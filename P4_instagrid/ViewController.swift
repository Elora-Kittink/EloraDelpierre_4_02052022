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
    var position: CGAffineTransform?
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var layoutComposed: UIView!
    @IBOutlet weak var swipeStackView: UIStackView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGestureRecognizerPortrait = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragSwipeUp(_:)))
        panGestureRecognizerLandscape = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragSwipeLeft(_:)))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print(self.windowInterfaceOrientation.isPortrait)
        if self.windowInterfaceOrientation.isPortrait {
            print("je suis en portrait !")
            self.isOrientationPortrait = true
            swipeOrientation()
        } else {
            self.isOrientationPortrait = false
            swipeOrientation()
            print("je suis en paysage !")
            
        }
    }
    
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
                print("je suis en paysage")
                self.isOrientationPortrait = false
                self.swipeOrientation()
                self.swipeLabel.text = "Swipe left to share"
            } else if self.windowInterfaceOrientation.isPortrait {
                print("je suis en portrait")
                self.isOrientationPortrait = true
                self.swipeOrientation()
                self.swipeLabel.text = "Swipe up to share"
            }
        })
    }
    
    private var windowInterfaceOrientation: UIInterfaceOrientation {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    @objc func dragSwipeUp(_ sender: UIPanGestureRecognizer){
        let layoutView = sender.view!
        let point = sender.translation(in: self.view)
        // re paramettrer .center
        layoutView.center = CGPoint(x: layoutView.center.x, y: layoutView.center.y + point.y)
        // capter le mouvement du doigt dans la vue layoutComposed
        let movement = sender.translation(in: layoutComposed)
        // donner a la vue layoutComposed le mouvement verticale correspondant au mouvement du doigt
        layoutComposed.transform = CGAffineTransform(translationX: 0, y: movement.y )
        print(layoutView.center.y)
        // si l'utilisateur a finit sont mouvement
        if sender.state == .ended {
            // et que layoutComposed a swipé jusqu'à être à suffisament haut
            if layoutView.center.y < -90 {
                // alors déclencher l'animation qui envoie le layout loin et lance swpipeFunction
                UIView.animate(withDuration: 2, animations: {
                    self.layoutComposed.center = CGPoint(x: self.layoutComposed.center.x, y: self.layoutComposed.center.y - 200)
                    self.swipeFunction(sendr: sender)
                })
            } else {
                self.layoutComposed.transform = .identity
            }
        } else {
            print("nop")
        }
    }
    
    
    @objc func dragSwipeLeft(_ sender: UIPanGestureRecognizer){
        let layoutView = sender.view!
        let point = sender.translation(in: self.view)
        // re paramettrer .center
        layoutView.center = CGPoint(x: layoutView.center.x + point.x, y: layoutView.center.y)
        // capter le mouvement du doigt dans la vue layoutComposed
        let movement = sender.translation(in: layoutComposed)
        // donner a la vue layoutComposed le mouvement verticale correspondant au mouvement du doigt
        layoutComposed.transform = CGAffineTransform(translationX: movement.x, y: 0 )
        // si l'utilisateur a finit sont mouvement
        if sender.state == .ended {
            // et que layoutComposed a swipé jusqu'à être à suffisament haut
            if layoutView.center.x < -100 {
                // alors déclencher l'animation qui envoie le layout loin et lance swpipeFunction
                UIView.animate(withDuration: 2, animations: {
                    self.layoutComposed.center = CGPoint(x: self.layoutComposed.center.x - 200, y: self.layoutComposed.center.y)
                    self.swipeFunction(sendr: sender)
                })
            } else {
                self.layoutComposed.transform = .identity
            }
        } else {
            print("nop")
        }
    }
    
    
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
        
        displayLayout(layoutStyle: layoutStyle)
    }
    
    func displayLayout(layoutStyle: LayoutStyle) {
        topLeftImage.isHidden = layoutStyle.topLeftImage
        bottomLeftImage.isHidden = layoutStyle.bottomLeftImageIsHidden
        layout1selected.isHidden = layoutStyle.layoutLeftSelectedIsHidden
        layout2selected.isHidden = layoutStyle.layoutCenterSelectedIsHIdden
        layout3selected.isHidden = layoutStyle.layoutRightSelectedIsHidden
        
    }
    
 
    
    func layoutComeBack(){
        UIView.animate(withDuration: 0.2) {
            self.layoutComposed.center = self.view.center
        }
    }
    
    
    // fonction de lancement de l'UIActivity controller
    @IBAction func swipeFunction(sendr: UIPanGestureRecognizer?){
        if sendr != nil {
            if let image = layoutComposed?.takeScreenshot() {
                let activityviewcontroller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                present(activityviewcontroller, animated: true)
                activityviewcontroller.completionWithItemsHandler = { activity, success, items, error in
                    
                    self.returnInitial()
                    self.layoutComeBack()
                }
            }
        }
        
    }
    // re mets les + a la place des images
    func returnInitial() {
        displayLayout(layoutStyle: .center)
        self.topLeftImage.image = UIImage(named: "Plus")
        self.topLeftImage.contentMode = .center
        self.topRightImage.image = UIImage(named: "Plus")
        self.topRightImage.contentMode = .center
        self.bottomLeftImage.image = UIImage(named: "Plus")
        self.bottomLeftImage.contentMode = .center
        self.bottomRightImage.image = UIImage(named: "Plus")
        self.bottomRightImage.contentMode = .center
    }
}


// extension for the pickercontroller

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // convert in an image and launch it in the current imageView global var
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView?.image = image
            imageView?.contentMode = .scaleAspectFill        }
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
        
        //        guard let image = image else {
        //            return UIImage()
        //        }
        return image ?? UIImage()
    }
}
