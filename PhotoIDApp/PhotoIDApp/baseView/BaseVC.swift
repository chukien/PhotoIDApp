//
//  BaseVC.swift
//  PhotoIDApp
//
//  Created by QRVN on 22/4/25.
//
import UIKit
import Photos
import AVFoundation
import Vision
import VisionKit
import CoreML

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

extension BaseVC {
    func phanTichNoiDungImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImg = image.cgImage else {
            completion("Không thể phân tích ảnh!")
            return
        }
        
        // Load CoreML model
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            completion("Failed to load ML model")
            return
        }
        
        // Create request
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                completion("Could not classify image")
                return
            }
            
            let topLabel = topResult.identifier.lowercased()
            let confidence = topResult.confidence
            
            // Optional: Print top 3 results
            print("Top Results:")
            for r in results.prefix(3) {
                print("• \(r.identifier) – \(r.confidence)")
            }
            
            // Basic logic to classify
            if topLabel.contains("person") || topLabel.contains("human") {
                let isPortrait = image.size.height > image.size.width
                completion(isPortrait ? "Portrait of one person" : "One person (not portrait format)")
            } else if topLabel.contains("cat") || topLabel.contains("dog") || topLabel.contains("animal") {
                completion("Animal detected")
            } else if topLabel.contains("plant") || topLabel.contains("tree") || topLabel.contains("flower") {
                completion("Plant or nature")
            } else {
                completion("Other: \(topLabel.capitalized)")
            }
        }
        
        // Run request
        let handler = VNImageRequestHandler(cgImage: cgImg, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion("Image analysis failed: \(error.localizedDescription)")
            }
        }
    }
}
