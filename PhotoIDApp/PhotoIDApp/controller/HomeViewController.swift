//
//  HomeViewController.swift
//  PhotoIDApp
//
//  Created by QRVN on 26/3/25.
//

import UIKit
import Photos
import AVFoundation
import CropViewController

class HomeViewController: BaseVC, UINavigationControllerDelegate {

    @IBOutlet weak var typeImageLbl: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    
    private var picker = UIImagePickerController()
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

extension HomeViewController: UIImagePickerControllerDelegate, CropViewControllerDelegate {
    private func permissionLibPhoto() {
        requestPhotoLibraryPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
                self.typeImageLbl.text = "Đã cho phép truy cập thư viện ảnh"
                openCamera_LibPhoto()
            } else {
                self.showPermissionDeniedAlert(on: self)
            }
        }
    }
    
    private func permissionCamPhoto() {
        requestCameraPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                picker.delegate = self
                picker.sourceType = .camera
                picker.allowsEditing = false
                self.typeImageLbl.text = "Đã cho phép truy cập camera"
                openCamera_LibPhoto()
            } else {
                self.showCameraPermissionAlert(on: self)
            }
        }
    }
    
    private func openCamera_LibPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.present(picker, animated: true, completion: nil)
        } else {
            print("Thiết bị không có camera")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Xử lý ảnh đã chụp
            let fixedImg = image.fixedOrientation()
            let cropController = CropViewController(croppingStyle: .default, image: fixedImg)
            cropController.delegate = self
            
            // Cố định tỉ lệ 3:4
            cropController.customAspectRatio = CGSize(width: 3, height: 4)
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
            })
        }
        picker.dismiss(animated: true)
    }

    // Nhận ảnh đã crop
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            // Dùng ảnh đã crop (hiển thị hoặc upload)
            self.imageV.image = image
            self.phanTichNoiDungImage(image: image) { [weak self] result in
                guard let self = self else { return }
                self.typeImageLbl.text = result
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

