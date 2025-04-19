//
//  HomeViewController.swift
//  PhotoIDApp
//
//  Created by QRVN on 26/3/25.
//

import UIKit
import Photos
import AVFoundation

class HomeViewController: UIViewController {

    @IBOutlet weak var typeImageLbl: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    
    private var typeImage: TypeImage = .Other
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeImageLbl.text = typeImage.title
        imageV.image = nil
    }
    
    @IBAction func takeLibPhotoAction(_ sender: UIButton) {
        permissionLibPhoto()
    }
    
    @IBAction func takeCamPhotoAction(_ sender: UIButton) {
        permissionCamPhoto()
    }
    
    @IBAction func clearPhotoAction(_ sender: UIButton) {
        imageV.image = nil
    }
}

extension HomeViewController {
    private func permissionLibPhoto() {
        requestPhotoLibraryPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.typeImageLbl.text = "Đã cho phép truy cập thư viện ảnh"
            } else {
                self.showPermissionDeniedAlert(on: self)
            }
        }
    }
    
    private func permissionCamPhoto() {}
    
    private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
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
    
    private func showPermissionDeniedAlert(on viewController: UIViewController) {
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
    
    
}

enum TypeImage {
    case Person
    case Animal
    case Plant
    case Other
    
    var title: String {
        switch self {
        case .Person:
            return "Người"
        case .Animal:
            return "Động vật"
        case .Plant:
            return "Thực vật"
        case .Other:
            return "Khác"
        }
    }
}
