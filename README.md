# SDK cung cấp nhưng tính năng sau
- Camera Preview
- Liveness
- Nhận diện mặt trước, mặt sau của 4 loại (Chứng minh nhân dân 9 số, Chứng minh nhân dân 12 số, Căn cước công dân, Căn
- Cước công dân gắn chip)
- Phát hiện và tự động chụp
- Align ảnh

# Tích hợp SDK
## Yêu cầu
- iOS phiên bản 12.1 trở lên
- Swift phiên bản 5.0 trở lên

## Thêm thư viện kèm SDK
Thêm các thư viện sau vào dự án
- GoogleMLKit/FaceDetection (phiên bản từ 2.1.0)
- TensorFlowLiteSwift (phiên bản từ 2.5.0)
- OpenCV2 (phiên bản từ 4.3.0)

Có thể manual add các file thư viện đi kèm *.framework vào project hoặc có thể sử dụng Cocoapods
```
- pod 'GoogleMLKit/FaceDetection', '~> 2.1.0'
- pod 'TensorFlowLiteSwift', '~> 2.5.0'
- pod 'OpenCV2', '~> 4.3.0'
```

## Thêm SDK
(Project -> Target -> Genneral)
- Thêm file VNDG_EKYC.framework, và set Embed & Sign

## Cách sử dụng
- Import VNDG_EKYC trong dự án
- Import AVFoundation trong dự án
- Xin quyền Privacy - Camera Usage Description ở Info.plist
- Kế thừa VNDGEKYCCameraDelegate, VNDGEKYCIdCardDetectorDelegate, VNDGEKYCFaceDetectorDelegate
- Khởi tạo view VNDGEKYC và cài đặt các thuộc tính

### Nhận diện khuôn mặt
```
import UIKit
import VNDG_EKYC
import AVFoundation
```
```
class FaceDetectorVC: UIViewController {

  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var correctView: UIImageView!
  
  var camera: VNDGEKYC?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    camera = VNDGEKYC.init(frameCameraPreview: self.cameraView.bounds, frameCorrect: self.correctView.frame)
    if let camera = self.camera {
      self.cameraView.addSubview(camera.cameraPreview)
    }
    self.cameraView.bringSubviewToFront(self.correctView)
    self.cameraView.bringSubviewToFront(self.imageCropView)

    // Set Delegate
    camera?.cameraDelegate = self
    camera?.faceDetectorDelegate = self

    //Set Type
    camera?.isType = .face

    //Show debug view
    camera?.showDebug = true

    //Position
    camera?.cameraPosition = .front
    
     //Khởi chạy session camera
    camera?.startSession()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //Restart session - Khởi tạo lại camera nếu đã tạm dừng camera trước đó
    self.camera?.restartSession()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    //Tạm dừng session Camera - Nếu cần tạm dừng camera
    self.camera?.stopSession()
  }
}
```
Dữ liệu sẽ được xử lý và trả kết quả thông qua các phương thức
```
extension FaceDetectorVC: VNDGEKYCCameraDelegate {
  
  ///Người dùng từ chối cấp quyền camera
  func VNDGEKYCCameraPermissionCameraDenied(status: AVAuthorizationStatus) {
  }
  
  //Camera khởi tạo thành công
  func VNDCEKYCCameraDidStart() {
  }

  /// Camera session khởi tạo thất bại
  func VNDGEKYCCameraDidFail(error: LocalizedError) {
  }

  /// Camera thay đổi
  func VNDGEKYCCameraChangePosition(newPosision: AVCaptureDevice.Position) {
  }
}
```
```
extension FaceDetectorVC: VNDGEKYCFaceDetectorDelegate {
  /// Kết quả trả về: valid trả về kết quả có đang nhận diện được khuôn mặt và 
  /// đạt đủ điều kiện nhìn thẳng và không nghiên đầu
  func VNDGEKYCFaceDetectionResult(valid: Bool, image: UIImage?) {
    // Phương thức này sẽ vẫn được gọi mỗi lần nhận được được khuôn mặt
    // Hãy gắn flag đánh dấu khi nhận được ảnh để tạm dừng không chạy block này tùy theo cách dùng
    DispatchQueue.main.async {
      self.correctView.image = self.correctView.image?.withRenderingMode(.alwaysTemplate)    
      self.correctView.tintColor = valid ? UIColor.green : UIColor.red
    }

    if let imageResult = image, valid {
      // Nhận được ảnh
      // flag
    }
  }
}
```

### Nhận diện ID Card
```
import UIKit
import VNDG_EKYC
import AVFoundation
class IdCardDetectorVC: UIViewController {

  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var correctView: UIImageView!
  
  var camera: VNDGEKYC?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    camera = VNDGEKYC.init(frameCameraPreview: self.cameraView.bounds, frameCorrect: self.correctView.frame)
    if let camera = self.camera {
      self.cameraView.addSubview(camera.cameraPreview)
    }
  
    self.cameraView.bringSubviewToFront(self.correctView)
  
    // Set Delegate
    camera?.cameraDelegate = self
    camera?.idCardDetectorDelegate = self
  
    // Set Type
    camera?.isType = .idCard
  
    // Show debug view  
    camera?.showDebug = true
    
    // Position
    camera?.cameraPosition = .back
    
    //Khởi chạy session camera
    camera?.startSession()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //Restart session - Khởi tạo lại camera nếu đã tạm dừng camera trước đó
    self.camera?.restartSession()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    //Tạm dừng session Camera - Nếu cần tạm dừng camera
    self.camera?.stopSession()
  }
}
```
Dữ liệu sẽ được xử lý và trả kết quả thông qua các phương thức
```
extension IdCardDetectorVC: VNDGEKYCIdCardDetectorDelegate {
  func VNDGEKYCIdCardDetectionResult(valid: Bool, result: IdCardResult?) {
    // Phương thức này sẽ vẫn được gọi mỗi lần nhận được được ID Card
    // Hãy gắn flag đánh dấu khi nhận được ảnh để tạm dừng không chạy block này tùy theo cách dùng
    DispatchQueue.main.async {
      self.correctView.image = self.correctView.image?.withRenderingMode(.alwaysTemplate)
      self.correctView.tintColor = valid ? UIColor.green : UIColor.red
    }
    if let result = result, valid {
      let type: IdCardType = result.type
      let image: UIImage = result.image
      //Nhận được dữ liệu
      //flag
    }
  }
}
```
