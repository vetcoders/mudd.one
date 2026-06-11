#!/usr/bin/env swift
// mudd.one — headless CreateML image classifier trainer.
// Usage: swift scripts/train_classifier.swift <dataset_dir> <out.mlmodel>
//   <dataset_dir> must contain train/<class>/*.png (+ optional test/<class>/*.png)
// Produces a CoreML .mlmodel consumable by app/mudd/Services/ClassifierService.swift.
// Created by M&K (c)2026 VetCoders

import CreateML
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write(
        "usage: train_classifier.swift <dataset_dir> <out.mlmodel>\n".data(using: .utf8)!)
    exit(2)
}

let datasetDir = URL(fileURLWithPath: args[1], isDirectory: true)
let outURL = URL(fileURLWithPath: args[2])
let trainDir = datasetDir.appendingPathComponent("train", isDirectory: true)
let testDir = datasetDir.appendingPathComponent("test", isDirectory: true)

do {
    let trainData = MLImageClassifier.DataSource.labeledDirectories(at: trainDir)
    // Light augmentation — the dataset is small and clip-correlated.
    let params = MLImageClassifier.ModelParameters(
        validation: .none,
        maxIterations: 25,
        augmentationOptions: [.flip])

    print("training image classifier from \(trainDir.path) ...")
    let classifier = try MLImageClassifier(trainingData: trainData, parameters: params)

    let trainAcc = (1.0 - classifier.trainingMetrics.classificationError) * 100
    print(String(format: "training accuracy: %.1f%%", trainAcc))

    if FileManager.default.fileExists(atPath: testDir.path) {
        let testData = MLImageClassifier.DataSource.labeledDirectories(at: testDir)
        let eval = classifier.evaluation(on: testData)
        let testAcc = (1.0 - eval.classificationError) * 100
        print(String(format: "held-out test accuracy: %.1f%% (overstated — clip-correlated)", testAcc))
    }

    let metadata = MLModelMetadata(
        author: "VetCoders",
        shortDescription:
            "mudd-classifier-v0 — PATH VALIDATOR, not clinical. Separates ATLAS acquisition contexts (machine + SAM2 overlay), not anatomy.",
        version: "0.0")
    try classifier.write(to: outURL, metadata: metadata)
    print("wrote model → \(outURL.path)")
} catch {
    FileHandle.standardError.write("training failed: \(error)\n".data(using: .utf8)!)
    exit(1)
}
