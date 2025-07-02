enum UploadStatus: String, Codable {
    case pending
    case uploading
    case uploaded
    case failed
}