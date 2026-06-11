#!/usr/bin/env swift
// mudd.one — verify the classification path with a real CoreML model.
// Mirrors app/mudd/Services/ClassifierService.swift: compile model, VNCoreMLModel,
// VNCoreMLRequest with .scaleFill, top VNClassificationObservation.
// Usage: swift scripts/verify_classifier.swift <model.mlmodel> <test_dir>
//   <test_dir> contains <expected_label>/*.png
// Exit 0 if every frame's top label matches its directory; non-zero otherwise.
// Created by M&K (c)2026 VetCoders

import CoreImage
import CoreML
import Foundation
import Vision

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write(
        "usage: verify_classifier.swift <model.mlmodel> <test_dir>\n".data(using: .utf8)!)
    exit(2)
}

let modelURL = URL(fileURLWithPath: args[1])
let testDir = URL(fileURLWithPath: args[2], isDirectory: true)

func classify(_ vnModel: VNCoreMLModel, _ image: CGImage) throws -> (String, Float) {
    let request = VNCoreMLRequest(model: vnModel)
    request.imageCropAndScaleOption = .scaleFill
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    try handler.perform([request])
    guard let top = (request.results as? [VNClassificationObservation])?.first else {
        throw NSError(domain: "verify", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "no classification result"])
    }
    return (top.identifier, top.confidence)
}

func loadCGImage(_ url: URL) -> CGImage? {
    guard let ci = CIImage(contentsOf: url) else { return nil }
    return CIContext().createCGImage(ci, from: ci.extent)
}

do {
    let compiled = try MLModel.compileModel(at: modelURL)
    let config = MLModelConfiguration()
    config.computeUnits = .all
    let mlModel = try MLModel(contentsOf: compiled, configuration: config)
    let vnModel = try VNCoreMLModel(for: mlModel)

    let fm = FileManager.default
    let labelDirs = try fm.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)
        .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }

    var total = 0, correct = 0
    for dir in labelDirs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
        let expected = dir.lastPathComponent
        let frames = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.lowercased() == "png" }
            .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        for frame in frames {
            guard let cg = loadCGImage(frame) else {
                FileHandle.standardError.write("skip (decode): \(frame.lastPathComponent)\n".data(using: .utf8)!)
                continue
            }
            let (label, conf) = try classify(vnModel, cg)
            total += 1
            let ok = (label == expected)
            if ok { correct += 1 }
            print(String(format: "%@  expected=%@  got=%@ (%.1f%%)  %@",
                         ok ? "PASS" : "FAIL", expected, label, conf * 100,
                         frame.lastPathComponent))
        }
    }

    let acc = total > 0 ? Double(correct) / Double(total) * 100 : 0
    print(String(format: "\n%d/%d correct (%.1f%%) — path verified with real CoreML model", correct, total, acc))
    exit(correct == total && total > 0 ? 0 : 1)
} catch {
    FileHandle.standardError.write("verify failed: \(error)\n".data(using: .utf8)!)
    exit(1)
}
