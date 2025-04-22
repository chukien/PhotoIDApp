//
//  BaseVC.swift
//  PhotoIDApp
//
//  Created by QRVN on 22/4/25.
//
import UIKit
import Photos
import AVFoundation

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                        DispatchQueue.main.async {
                            completion(newStatus == .authorized || newStatus == .limited)
                        }
                    }
        default:
            completion(false)
        }
    }
    
    func showPermissionDeniedAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Không có quyền truy cập",
            message: "Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Đi tới Cài đặt", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })

        viewController.present(alert, animated: true)
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                        DispatchQueue.main.async {
                            completion(granted)
                        }
                    }
        default:
            completion(false)
        }
    }
    
    func showCameraPermissionAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
                title: "Không có quyền sử dụng Camera",
                message: "Vui lòng vào Cài đặt và cấp quyền truy cập camera cho ứng dụng.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
            alert.addAction(UIAlertAction(title: "Đi tới Cài đặt", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            viewController.present(alert, animated: true)
    }

}
