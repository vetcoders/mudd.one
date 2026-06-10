// mudd.one — CoreML classifier service (Swift-side inference)
// The model is trained externally (CreateML — models/mudd-classifier.mlproj);
// Rust core never runs classification, it only carries results into export.
// Created by M&K (c)2026 VetCoders

import AppKit
import CoreML
import Vision

enum ClassifierError: LocalizedError {
    case notLoaded
    case badFrame
    case noResult

    var errorDescription: String? {
        switch self {
        case .notLoaded: return "Classifier model not loaded"
        case .badFrame: return "Frame could not be converted to an image"
        case .noResult: return "Model returned no classification"
        }
    }
}

/// Loads a CoreML image classifier and classifies pipeline frames.
/// All model state is confined to a private serial queue; completions
/// are delivered on the main queue.
final class ClassifierService: @unchecked Sendable {
    static let shared = ClassifierService()

    private let queue = DispatchQueue(label: "io.vetcoders.mudd.classifier", qos: .userInitiated)
    private var model: VNCoreMLModel?
    private var modelName: String?

    /// Load a CoreML model. Accepts .mlmodel / .mlpackage (compiled on the fly)
    /// or an already-compiled .mlmodelc.
    func loadModel(at url: URL, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
        queue.async {
            do {
                let compiledURL: URL
                if url.pathExtension == "mlmodelc" {
                    compiledURL = url
                } else {
                    compiledURL = try MLModel.compileModel(at: url)
                }
                let config = MLModelConfiguration()
                config.computeUnits = .all // ANE / GPU / CPU
                let mlModel = try MLModel(contentsOf: compiledURL, configuration: config)
                let vnModel = try VNCoreMLModel(for: mlModel)
                let name = url.deletingPathExtension().lastPathComponent
                self.model = vnModel
                self.modelName = name
                DispatchQueue.main.async { completion(.success(name)) }
            } catch {
                self.model = nil
                self.modelName = nil
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    /// Classify a single frame; returns the top observation.
    func classify(
        frame: FfiFrame,
        completion: @escaping @Sendable (Result<FfiClassification, Error>) -> Void
    ) {
        queue.async {
            do {
                guard let model = self.model else { throw ClassifierError.notLoaded }
                guard let cgImage = Self.makeCGImage(from: frame) else {
                    throw ClassifierError.badFrame
                }
                let request = VNCoreMLRequest(model: model)
                request.imageCropAndScaleOption = .scaleFill
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([request])
                guard let top = (request.results as? [VNClassificationObservation])?.first
                else {
                    throw ClassifierError.noResult
                }
                let result = FfiClassification(label: top.identifier, confidence: top.confidence)
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: - Frame conversion

    private static func makeCGImage(from frame: FfiFrame) -> CGImage? {
        let w = Int(frame.width)
        let h = Int(frame.height)
        guard w > 0, h > 0 else { return nil }

        let colorSpace: CGColorSpace
        let bitmapInfo: CGBitmapInfo
        let bitsPerPixel: Int

        switch frame.channels {
        case 1:
            colorSpace = CGColorSpaceCreateDeviceGray()
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            bitsPerPixel = 8
        case 3:
            colorSpace = CGColorSpaceCreateDeviceRGB()
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            bitsPerPixel = 24
        case 4:
            colorSpace = CGColorSpaceCreateDeviceRGB()
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
            bitsPerPixel = 32
        default:
            return nil
        }

        let bytesPerRow = w * bitsPerPixel / 8
        guard frame.data.count >= bytesPerRow * h,
              let provider = CGDataProvider(data: frame.data as CFData)
        else { return nil }

        return CGImage(
            width: w,
            height: h,
            bitsPerComponent: 8,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
}
