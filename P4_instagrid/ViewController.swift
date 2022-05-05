//
//  ViewController.swift
//  P4_instagrid
//
//  Created by Elora on 29/04/2022.
//

//
import SwiftUI
import UIKit

class ViewController: UIViewController {
    
    // global var stocking the image view tapped
    weak var imageView: UIImageView?
    
    @IBOutlet weak var topLeftImage: UIImageView!
    @IBOutlet weak var bottomLeftImage: UIImageView!
    @IBOutlet weak var layout1selected: UIImageView!
    @IBOutlet weak var layout2selected: UIImageView!
    @IBOutlet weak var layout3selected: UIImageView!
    
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
    
    // func with in parametres the TGR activated
    @IBAction func changeLayout(_ sender: UITapGestureRecognizer){
        // switch on the tag depending on the sender in parameter
        switch sender.view?.tag {
            
        case 1:
            // hidden le top left
            print("change for Layout 1")
            topLeftImage.isHidden = true
            bottomLeftImage.isHidden = false
            layout1selected.isHidden = false
            layout2selected.isHidden = true
            layout3selected.isHidden = true
        case 2:
            //hidden le bottom left
            print("change for layout 2")
            bottomLeftImage.isHidden = true
            topLeftImage.isHidden = false
            layout1selected.isHidden = true
            layout2selected.isHidden = false
            layout3selected.isHidden = true
        case 3:
            // aucun hidden
            print("change for layout 3")
            topLeftImage.isHidden = false
            bottomLeftImage.isHidden = false
            layout1selected.isHidden = true
            layout2selected.isHidden = true
            layout3selected.isHidden = false
        default:
            print("default")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

