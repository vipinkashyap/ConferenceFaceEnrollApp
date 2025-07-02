// MARK: - CameraView
  
  struct CameraView: View {
      @StateObject private var viewModel = CameraViewModel()
  
      var body: some View {
          ZStack {
              CameraPreview(session: viewModel.session)
                  .clipShape(Circle())
                  .frame(width: 300, height: 300)
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
  
              NavigationLink(destination: {
                  if let image = viewModel.capturedImage {
                      PreviewView(image: image)
                  }
              }, isActive: $viewModel.navigateToPreview) {
                  EmptyView()
              }
          }
          .background(Color.black.edgesIgnoringSafeArea(.all))
          .onAppear { viewModel.configure() }
      }
  }