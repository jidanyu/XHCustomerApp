//
//  UserCentreVC.swift
//  XianHui
//
//  Created by Seppuu on 16/7/28.
//  Copyright © 2016年 mybook. All rights reserved.
//

import UIKit

import Proposer
import Kingfisher
import MBProgressHUD
import SwiftyJSON

let HistoryNoti = "HistoryNoti"
let LessonsLikedNoti = "LessonsLikedNoti"
let FeedBackNoti = "FeedBackNoti"
let CertificateNoti = "CertificateNoti"
let UserAvatarUpdatedNoti = "UserAvatarUpdatedNoti"


class UserCentreVC: BaseViewController {
    
    var userTableView: UITableView!
    
    fileprivate let AddUserAvatarCell = "UserAvatarCell"
    
    fileprivate let UserAvatarEditCellId = "UserAvatarEditCell"
    
    fileprivate let logOutCellId = "SingleTapCell"
    
    fileprivate var editUserInfo = false
    
    fileprivate var uploadingAvatar = false
    
    var section1 = [String]()

    var agentId:Int?
    
    fileprivate var imageUploading = UIImage()
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        section1 = ["我的评价","邀请有奖","在线客服"]
        
        
        setTableView()
    }
    
    func setTableView() {
        
        userTableView = UITableView(frame: view.bounds, style: .grouped)
        view.addSubview(userTableView)
        
        userTableView.delegate = self
        userTableView.dataSource = self
        
        userTableView.register(UINib(nibName: logOutCellId, bundle: nil), forCellReuseIdentifier: logOutCellId)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func changeAllContacts() {
        userTableView.reloadData()
    }
    
}

extension UserCentreVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else {
            return section1.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 220
        }
        else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let user = User.currentUser()
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            let cardView = CustomerCardView.instanceFromNib()
            cardView.frame = cell.bounds
            cell.addSubview(cardView)
            
            cardView.nameLabel.text = (user?.displayName)! + " >"
            if let url = URL(string: (user?.avatarURL)!) {
               cardView.avatarImageView.kf.setImage(with: url)
            }
            
            
            return cell
            
        }
        else {
            let cellID = "cellIDs1"
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            
            
            cell.textLabel?.text = section1[indexPath.row]
            cell.selectionStyle = .none
            return cell
            

        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            
            
        }
    }
    
}

extension UserCentreVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func avatarTap() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //选择照片
        let choosePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("图库", comment: ""), style: .default) { action -> Void in
            
            let openCameraRoll: ProposerAction = { [weak self] in
                
                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                    self?.alertCanNotAccessCameraRoll()
                    return
                }
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .photoLibrary
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }
            
            proposeToAccess(.photos, agreed: openCameraRoll, rejected: {
                self.alertCanNotAccessCameraRoll()
            })
        }
        alertController.addAction(choosePhotoAction)
        
        //拍照
        let takePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("相机", comment: ""), style: .default) { action -> Void in
            
            let openCamera: ProposerAction = { [weak self] in
                
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self?.alertCanNotOpenCamera()
                    return
                }
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .camera
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }
            
            proposeToAccess(.camera, agreed: openCamera, rejected: {
                self.alertCanNotOpenCamera()
            })
        }
        alertController.addAction(takePhotoAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        // touch to create (if need) for faster appear
        delay(0.2) { [weak self] in
            self?.imagePicker.hidesBarsOnTap = false
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        //save image to local and back
        self.uploadingAvatar = true
        self.imageUploading = image
        self.userTableView.reloadData()
        
        User.saveAvatarWith(image) { (success) in
            
            if success == true {
                self.uploadingAvatar = false
                self.userTableView.reloadData()
                NotificationCenter.default.post(name: Notification.Name(rawValue: UserAvatarUpdatedNoti), object: nil)
            }
            else {
                
            }
        }
    }
}










