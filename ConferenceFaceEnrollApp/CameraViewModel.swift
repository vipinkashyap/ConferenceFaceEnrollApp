// MARK: - Camera ViewModel

class CameraViewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput!

    @Published var isFlashOn = false
    @Published var capturedImage: UIImage?
    @Published var navigateToPreview = false

    override init() {
        super.init()
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

        session.commitConfiguration()
        session.startRunning()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
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
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.capturedImage = image
                self.navigateToPreview = true
            }
        }
    }
}