//
//  CameraView.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//

import SwiftUICore
import SwiftUI
import AVFoundation


// MARK: - CameraView

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.session, viewModel: viewModel)
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))

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
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear { viewModel.configure() }
        .sheet(isPresented: $viewModel.navigateToPreview) {
            if let image = viewModel.capturedImage {
                PreviewView(image: image)
            }
        }
    }
}

// MARK: - Camera Preview Wrapper

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


