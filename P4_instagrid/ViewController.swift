//
//  ViewController.swift
//  P4_instagrid
//
//  Created by Elora on 29/04/2022.
//

import SwiftUI
import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    weak var imageView: UIImageView?
    
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var layoutComposed: UIView!
    @IBOutlet weak var topLeftImage: UIImageView!
    @IBOutlet weak var topRightImage: UIImageView!
    @IBOutlet weak var bottomLeftImage: UIImageView!
    @IBOutlet weak var bottomRightImage: UIImageView!
    @IBOutlet weak var layout1selected: UIImageView!
    @IBOutlet weak var layout2selected: UIImageView!
    @IBOutlet weak var layout3selected: UIImageView!
    
    var panGestureRecognizerPortrait: UIPanGestureRecognizer!
    var panGestureRecognizerLandscape: UIPanGestureRecognizer!
    var isOrientationPortrait = true
    
    var plusImage: UIImage = UIImage(named: "Plus") ?? UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizerPortrait = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragSwipeUp(_:)))
        panGestureRecognizerLandscape = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragSwipeUp(_:)))
        returnInitial()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.windowInterfaceOrientation.isPortrait {
            self.isOrientationPortrait = true
            swipeOrientation()
        } else {
            self.isOrientationPortrait = false
            swipeOrientation()
        }
    }
    
    // check the layout has been completed
    func pictureControl() -> Bool {
        let tableau: [UIImageView] = [topLeftImage, topRightImage, bottomLeftImage, bottomRightImage]
        let filtered = tableau.filter { image in
            guard let imageActuelle = image.image else { return false }
            return !image.isHidden && imageActuelle.isEqual(plusImage)
        }
        return filtered.isEmpty
    }
    
    // add and remove the swipe gesture recognizer matching the orientation
    func swipeOrientation(){
        if isOrientationPortrait {
            layoutComposed.addGestureRecognizer(panGestureRecognizerPortrait)
            layoutComposed.removeGestureRecognizer(panGestureRecognizerLandscape)
        } else {
            layoutComposed.addGestureRecognizer(panGestureRecognizerLandscape)
            layoutComposed.removeGestureRecognizer(panGestureRecognizerPortrait)
        }
    }
    
    // listen to orientation change
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            if self.windowInterfaceOrientation.isLandscape {
                self.isOrientationPortrait = false
                self.swipeOrientation()
                self.swipeLabel.text = "Swipe left to share"
            } else if self.windowInterfaceOrientation.isPortrait {
                self.isOrientationPortrait = true
                self.swipeOrientation()
                self.swipeLabel.text = "Swipe up to share"
            }
        })
    }
    // check orientation
    private var windowInterfaceOrientation: UIInterfaceOrientation {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    // manage drag swipe UP movements
    @objc func dragSwipeUp(_ sender: UIPanGestureRecognizer){
        // check orientation
        if isOrientationPortrait {
            let touch = sender.translation(in: self.view).y
            // check if layout is complete
            if pictureControl(){
                // check the movement is going up
                if touch <= 1  {
                    print(touch)
                    UIView.animate(withDuration: 1) {
                        self.layoutComposed.transform = CGAffineTransform(translationX: 0, y: -500)
                    } completion: { _ in
                        self.shareFunction(sendr: sender)
                    }
                }
            } else {
                // if layoutcomposed is not complete, block share and shake to alert user
                shakeAnimation()
            }
            
        } else {
            let touch = sender.translation(in: self.view).x
            if pictureControl(){
                if touch <= 1 {
                    UIView.animate(withDuration: 1) {
                        self.layoutComposed.transform = CGAffineTransform(translationX: -500, y: 0 )
                    } completion: { _ in
                        self.shareFunction(sendr: sender)
                    }
                }
            } else {
                // if layoutcomposed is not complete, block share and shake to alert user
                shakeAnimation()
            }
        }
    }
    
    // animation launch when user try to share uncomplete photo grid
    func shakeAnimation(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: layoutComposed.center.x - 10, y: layoutComposed.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: layoutComposed.center.x + 10, y: layoutComposed.center.y))
        
        layoutComposed.layer.add(animation, forKey: "position")
    }
    
    
    // check access permission and call the imagepickercontroller delegate
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer){
        guard let senderImageView = sender.view as? UIImageView else {
            return
        }
        // update de global var with the image view just tapped
        imageView = senderImageView
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            PHPhotoLibrary.requestAuthorization { (status ) in
                switch status {
                    
                case .limited:
                    showPopup(title: "Photo library access limited", message: "photo library access previously limited, you must change in settings .", okButton: false, settingsButton: true, cancelButton: true)
                    
                case .authorized:
                    DispatchQueue.main.async {
                        let myPickerController = UIImagePickerController()
                        myPickerController.sourceType = .photoLibrary
                        myPickerController.delegate = self
                        myPickerController.allowsEditing = true
                        self.present(myPickerController, animated: true)
                    }
                case .notDetermined: break
                    
                case .restricted:
                    showPopup(title: "Photo library access restricted",
                              message: "photo library access is restricted and cannot be accessed.",
                              okButton: true,
                              settingsButton: false, cancelButton: false)
                    
                case .denied:
                    showPopup(title: "Photo library access denied", message: "photo library access previously denied, you must change in settings .", okButton: false, settingsButton: true, cancelButton: true)
                    
                }
            }
        }
        
        // launch a custom popup depending on the permission status
        func showPopup(title: String, message: String, okButton: Bool, settingsButton: Bool, cancelButton: Bool) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok", style: .default)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                let goInSettingsButton = UIAlertAction(title: "go to settings", style: .default){ (action) in
                    DispatchQueue.main.async {
                        let url = URL(string: UIApplicationOpenNotificationSettingsURLString)!
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                if settingsButton {
                    alert.addAction(goInSettingsButton)
                }
                if cancelButton {
                    alert.addAction(cancel)
                }
                if okButton {
                    alert.addAction(ok)
                }
                self.present(alert, animated: true)
            }
        }
    }
    
    // sending to the phone settings
    func goToAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // manage the layout composition
    enum LayoutStyle {
        case left, center, right
        
        var topLeftImage: Bool {
            switch self {
            case .left: return true
            case .center: return false
            case .right: return false
            }
        }
        var bottomLeftImageIsHidden: Bool {
            switch self {
            case .left: return false
            case .center: return true
            case .right: return false
            }
        }
        var layoutLeftSelectedIsHidden: Bool {
            switch self {
            case .left: return false
            case .center: return true
            case .right: return true
            }
        }
        var layoutCenterSelectedIsHIdden: Bool {
            switch self {
            case .left: return true
            case .center: return false
            case .right: return true
            }
        }
        var layoutRightSelectedIsHidden: Bool {
            switch self {
            case .left: return true
            case .center: return true
            case .right: return false
            }
        }
        
    }
    
    
    
    // switch in layout enum
    @IBAction func changeLayout(_ sender: UITapGestureRecognizer){
        
        let layoutChosen = sender.view?.tag
        var layoutStyle: LayoutStyle
        
        switch layoutChosen {
            
        case 1:
            // layout left
            layoutStyle = .left
        case 2:
            // layout center
            layoutStyle = .center
        case 3:
            // layout right
            layoutStyle = .right
        default:
            layoutStyle = .center
            print("default")
        }
        
        displayLayout(layoutStyle: layoutStyle)
    }
    
    // display the layout according to the layout composition choose before
    
    func displayLayout(layoutStyle: LayoutStyle) {
        topLeftImage.isHidden = layoutStyle.topLeftImage
        bottomLeftImage.isHidden = layoutStyle.bottomLeftImageIsHidden
        layout1selected.isHidden = layoutStyle.layoutLeftSelectedIsHidden
        layout2selected.isHidden = layoutStyle.layoutCenterSelectedIsHIdden
        layout3selected.isHidden = layoutStyle.layoutRightSelectedIsHidden
        
    }
    
    
    // return the grid to its original position after sharing
    func layoutComeBack(sender: UIPanGestureRecognizer){
        UIView.animate(withDuration: 0.3) {
            self.layoutComposed.transform = .identity
            
        }
    }
    
    
    // launch UIActivity controller
 func shareFunction(sendr: UIPanGestureRecognizer?){
        if sendr != nil {
            if let image = layoutComposed?.takeScreenshot() {
                let activityviewcontroller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                present(activityviewcontroller, animated: true)
                activityviewcontroller.completionWithItemsHandler = { activity, success, items, error in
                    // after sharing, empty the photos and return at initial place
                    self.returnInitial()
                    self.layoutComeBack(sender: sendr!)
                }
            }
        }
        
    }
    // re put the + image in place of image
    func returnInitial() {
        displayLayout(layoutStyle: .center)
        self.topLeftImage.image = plusImage
        self.topLeftImage.contentMode = .center
        self.topRightImage.image = plusImage
        self.topRightImage.contentMode = .center
        self.bottomLeftImage.image = plusImage
        self.bottomLeftImage.contentMode = .center
        self.bottomRightImage.image = plusImage
        self.bottomRightImage.contentMode = .center
    }
}


// extension for the pickercontroller

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // convert in an image and launch it in the current imageView global var
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView?.image = image
            self.imageView?.contentMode = .scaleAspectFill        }
        // close the window when finish
        picker.dismiss(animated: true, completion: nil)
        
    }
    // close the window with cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
