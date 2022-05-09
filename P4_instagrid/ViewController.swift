//
//  ViewController.swift
//  P4_instagrid
//
//  Created by Elora on 29/04/2022.
//

//PHPhotoLibrary.requestAuthorization   pour gérer le cas ou l'utilisateur de donne pas son autorisation??


import SwiftUI
import UIKit

class ViewController: UIViewController {
    
    // global var stocking the image view tapped
    weak var imageView: UIImageView?
    
    @IBOutlet weak var layoutComposed: UIView!
    @IBOutlet weak var swipeStackView: UIStackView!
    @IBOutlet weak var topLeftImage: UIImageView!
    @IBOutlet weak var bottomLeftImage: UIImageView!
    @IBOutlet weak var layout1selected: UIImageView!
    @IBOutlet weak var layout2selected: UIImageView!
    @IBOutlet weak var layout3selected: UIImageView!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    
    // function with in parameters the TGR activated
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer){
        // transform the sender view in an image view
        guard let senderImageView = sender.view as? UIImageView else {
            return
        }
        // update de global var with the image view just tapped
        imageView = senderImageView
        // picker controller process
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    // test
    
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
    
    
    
    // func with in parametres the TGR activated
    @IBAction func changeLayout(_ sender: UITapGestureRecognizer){
        // switch on the tag depending on the sender in parameter
        
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
        
        topLeftImage.isHidden = layoutStyle.topLeftImage
        bottomLeftImage.isHidden = layoutStyle.bottomLeftImageIsHidden
        layout1selected.isHidden = layoutStyle.layoutLeftSelectedIsHidden
        layout2selected.isHidden = layoutStyle.layoutCenterSelectedIsHIdden
        layout3selected.isHidden = layoutStyle.layoutRightSelectedIsHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
            
            if windowInterfaceOrientation.isLandscape {
                print("je suis en paysage")
                self.swipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.left
            } else if windowInterfaceOrientation.isPortrait {
                print("je suis en portrait")
                self.swipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.up
            }
        })
    }
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation
    }
    
    
    @IBAction func swipeFunction(sendr: UISwipeGestureRecognizer?){
        if sendr != nil {
            if let image = topLeftImage.image {
                let activityviewcontroller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                present(activityviewcontroller, animated: true)
            }
            
            
        }
    }
    
}

// extension for the pickercontroller

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // convert in an image and launch it in the current imageView global var
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView?.image = image
        }
        // close the window when finish
        picker.dismiss(animated: true, completion: nil)
        
    }
    // close the window with cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

