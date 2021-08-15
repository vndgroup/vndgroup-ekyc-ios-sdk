//
//  IdCardDetectorVC.swift
//  Demo
//
//  Created by Hung Truong Khanh on 14/08/2021.
//

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
        
        //Set Delegate
        camera?.cameraDelegate = self
        camera?.idCardDetectorDelegate = self
        
        //Set Type
        camera?.isType = .idCard
        //Show debug view
        camera?.showDebug = true
        //Position
        camera?.cameraPosition = .back
        
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

extension IdCardDetectorVC: VNDGEKYCCameraDelegate {
    
    func VNDGEKYCCameraPermissionCameraDenied(status: AVAuthorizationStatus) {
        
    }
    
    func VNDCEKYCCameraDidStart() {
        
    }
    
    func VNDGEKYCCameraDidFail(error: LocalizedError) {
        
    }
    
    func VNDGEKYCCameraChangePosition(newPosision: AVCaptureDevice.Position) {
        
    }
    
}

extension IdCardDetectorVC: VNDGEKYCIdCardDetectorDelegate {
    
    func VNDGEKYCIdCardDetectionResult(valid: Bool, result: IdCardResult?) {
        DispatchQueue.main.async {
            self.correctView.image = self.correctView.image?.withRenderingMode(.alwaysTemplate)
            self.correctView.tintColor = valid ? UIColor.green : UIColor.red
        }
        if let result = result, valid {
            let type: IdCardType = result.type
            let image: UIImage = result.image
        }
    }
    
    
}
