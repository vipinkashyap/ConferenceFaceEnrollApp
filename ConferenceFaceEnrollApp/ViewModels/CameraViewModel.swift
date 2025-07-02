//
//  CameraViewModel.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//
//  This file defines the `CameraViewModel` class, which serves as the ViewModel for the `CameraView`.
//  It handles camera configuration, photo capture, face detection, and image processing.
//
//  Key Features:
//  - Configures the `AVCaptureSession` for video and photo capture.
//  - Provides methods to toggle flash, switch cameras, and capture photos.
//  - Detects faces using Vision framework and updates the UI accordingly.
//  - Crops and saves captured images to disk.
//


// MARK: - CameraViewModel

/**
 * The `CameraViewModel` class manages the camera session and provides functionality for:
 * - Configuring the camera session.
 * - Capturing photos with optional flash.
 * - Switching between front and back cameras.
 * - Detecting faces using Vision framework.
 * - Cropping and saving images to disk.
 *
 * Published Properties:
 * - `isFlashOn`: Indicates whether the flash is enabled.
 * - `capturedImage`: Stores the most recently captured image.
 * - `navigateToPreview`: Triggers navigation to the preview screen.
 * - `isFaceDetected`: Indicates whether a face is detected in the camera feed.
 * - `savedImagePath`: Stores the file path of the saved image.
 */

import Foundation
import AVFoundation
import UIKit
import Vision
import Combine



// MARK: - Camera ViewModel

class CameraViewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput!
    var previewLayer: AVCaptureVideoPreviewLayer?
    private let sequenceHandler = VNSequenceRequestHandler()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    

    @Published var isFlashOn = false
    @Published var capturedImage: UIImage?
    @Published var navigateToPreview = false
    @Published var isFaceDetected: Bool = false
    @Published var savedImagePath: String?


    override init() {
        super.init()
    }
    
    
    // Call this from your CameraPreview UIViewRepresentable coordinator or update method:
    func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = layer
    }

    func configure() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.setupSession()
                }
            }
        }
    }

    private func setupSession() {
        session.beginConfiguration()

        if let currentInput = videoDeviceInput {
            session.removeInput(currentInput)
        }

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }

        videoDeviceInput = videoInput

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        // Add video data output for Vision
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Vision.FaceDetection"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }

        session.commitConfiguration()
        session.startRunning()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off

        if let connection = photoOutput.connection(with: .video) {
            if #available(iOS 17.0, *) {
                connection.videoRotationAngle = 0
            } else {
                connection.videoOrientation = .portrait
            }
        }

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func toggleFlash() {
        isFlashOn.toggle()
    }

    func switchCamera() {
        guard let currentInput = videoDeviceInput else { return }
        session.beginConfiguration()
        session.removeInput(currentInput)

        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            return
        }

        videoDeviceInput = newInput

        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }

        session.commitConfiguration()
    }
    

    private func detectFace(in sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            DispatchQueue.main.async {
                guard let results = request.results as? [VNFaceObservation], let face = results.first else {
                    self?.isFaceDetected = false
                    return
                }

                // Check for key landmarks to verify full face visibility
                let landmarks = face.landmarks
                let hasFullFace = landmarks?.leftEye != nil &&
                                  landmarks?.rightEye != nil &&
                                  landmarks?.nose != nil &&
                                  landmarks?.outerLips != nil &&
                                  landmarks?.faceContour != nil

                self?.isFaceDetected = hasFullFace
            }
        }

        do {
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: .leftMirrored)
        } catch {
            print("Face detection failed: \(error)")
        }
    }

    private func cropCenterSquare(from image: UIImage) -> UIImage {
        let originalSize = min(image.size.width, image.size.height)
        let originX = (image.size.width - originalSize) / 2
        let originY = (image.size.height - originalSize) / 2
        let cropRect = CGRect(x: originX, y: originY, width: originalSize, height: originalSize)

        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }

        return image
    }
    
    private func cropCenterCircle(from image: UIImage) -> UIImage {
        let imageSize = image.size
        let squareLength = min(imageSize.width, imageSize.height)
        let cropOrigin = CGPoint(
            x: (imageSize.width - squareLength) / 2,
            y: (imageSize.height - squareLength) / 2
        )
        let cropRect = CGRect(origin: cropOrigin, size: CGSize(width: squareLength, height: squareLength))

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        let squareImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)

        // Circular mask
        let renderer = UIGraphicsImageRenderer(size: squareImage.size)
        return renderer.image { ctx in
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: squareImage.size))
            circlePath.addClip()
            squareImage.draw(in: CGRect(origin: .zero, size: squareImage.size))
        }
    }
    
    private func cropToPreviewCircle(from image: UIImage, previewSize: CGSize, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        // 1. Get the rect of the video within the preview layer coordinate system
        let videoRect = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)

        // 2. Calculate the cropping rect on the captured image
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)

        // Map the videoRect (0...1) to the image size
        let cropX = videoRect.origin.x * imageWidth
        let cropY = videoRect.origin.y * imageHeight
        let cropWidth = videoRect.size.width * imageWidth
        let cropHeight = videoRect.size.height * imageHeight

        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight).integral

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return image }

        let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)

        // 3. Now crop to circle in center (same as before)
        let squareSize = min(croppedImage.size.width, croppedImage.size.height)
        let origin = CGPoint(x: (croppedImage.size.width - squareSize)/2,
                             y: (croppedImage.size.height - squareSize)/2)
        _ = CGRect(origin: origin, size: CGSize(width: squareSize, height: squareSize))

        UIGraphicsBeginImageContextWithOptions(CGSize(width: squareSize, height: squareSize), false, image.scale)
        _ = UIGraphicsGetCurrentContext()!

        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: squareSize, height: squareSize)))
        circlePath.addClip()

        croppedImage.draw(in: CGRect(x: -origin.x, y: -origin.y, width: croppedImage.size.width, height: croppedImage.size.height))

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage ?? croppedImage
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), var image = UIImage(data: data) {
            if videoDeviceInput.device.position == .front {
                image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
            }

            DispatchQueue.main.async {
                guard let previewLayer = self.previewLayer else {
                    self.capturedImage = image
                    self.navigateToPreview = true
                    return
                }

                let cropped = self.cropToPreviewCircle(
                    from: image,
                    previewSize: CGSize(width: 300, height: 300),
                    previewLayer: previewLayer
                )

                self.capturedImage = cropped

                // 🆕 Save image to disk
                if let data = cropped.jpegData(compressionQuality: 0.9) {
                    let filename = UUID().uuidString + ".jpg"
                    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent(filename)

                    do {
                        try data.write(to: fileURL)
                        print("✅ Saved image to Documents at: \(fileURL.path)")
                        self.savedImagePath = filename
                    } catch {
                        print("❌ Failed to save image: \(error)")
                    }
                }

                self.navigateToPreview = true
            }
        }
    }
}


extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        detectFace(in: sampleBuffer)
    }
}
