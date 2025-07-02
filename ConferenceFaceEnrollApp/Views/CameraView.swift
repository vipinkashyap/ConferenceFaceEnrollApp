//
//  CameraView.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//
//  This file defines the `CameraView` which is the main interface for capturing photos.
//  It integrates with the camera hardware using `AVFoundation` and provides a user-friendly UI for photo capture.
//
//  The view includes:
//  - A live camera preview displayed in a circular frame.
//  - Buttons for toggling flash, capturing a photo, and switching the camera.
//  - A sheet to preview the captured image.
//

import SwiftUICore
import SwiftUI
import AVFoundation


// MARK: - CameraView

/**
 * The `CameraView` struct represents the main camera interface.
 *
 * - Parameters:
 *   - savedImagePath: A binding to store the path of the saved image.
 *
 * The view uses a `CameraViewModel` to manage camera-related logic and state.
 */

struct CameraView: View {
    @Binding var savedImagePath: String?
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.session, viewModel: viewModel)
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(viewModel.isFaceDetected ? Color.green : Color.white, lineWidth: 4))

            VStack {
                Text("Snap & Sign Up!")
                    .font(.title2).bold().padding(.top, 50)
                Spacer()

                HStack {
                    Button(action: { viewModel.toggleFlash() }) {
                        Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: { viewModel.capturePhoto() }) {
                        Circle().fill(Color.white).frame(width: 70, height: 70)
                    }

                    Spacer()

                    Button(action: { viewModel.switchCamera() }) {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
            }
        }
        .onReceive(viewModel.$savedImagePath) {
            newPath in self.savedImagePath = newPath
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear { viewModel.configure() }
        .sheet(isPresented: $viewModel.navigateToPreview) {
            if let image = viewModel.capturedImage {
                PreviewView(savedImagePath: $savedImagePath, image: image)
            }
        }
    }
}

// MARK: - Camera Preview Wrapper

/**
 * The `CameraPreview` struct wraps the `AVCaptureSession` in a SwiftUI-compatible view.
 *
 * - Parameters:
 *   - session: The `AVCaptureSession` used for capturing video input.
 *   - viewModel: The `CameraViewModel` to manage camera state and interactions.
 */

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    @ObservedObject var viewModel: CameraViewModel
    

    func makeUIView(context: Context) -> UIView {
        let view = LiveCameraUIView()
        view.videoPreviewLayer.session = session
        viewModel.setPreviewLayer(view.videoPreviewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }
}

/**
 * The `LiveCameraUIView` class provides a `UIView` with a `AVCaptureVideoPreviewLayer`.
 *
 * This class is used to display the live camera feed in the `CameraPreview`.
 */

final class LiveCameraUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


