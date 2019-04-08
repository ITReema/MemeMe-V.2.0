//
//  MemeEditorViewController.swift
//  MemeMe 2.0
//
//  Created by mac_os on 26/03/1440 AH.
//  Copyright © 1440 mac_os. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //Text Attributes
    let memeTextAttributes: [String: Any] = [
        NSAttributedString.Key.strokeColor.rawValue: UIColor.black,
        NSAttributedString.Key.foregroundColor.rawValue: UIColor.white,
        NSAttributedString.Key.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth.rawValue: -5.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //image
        imageView.contentMode = .scaleAspectFit
        //text
        prepareTextField(textField: topTextField, defaultText:"TOP")
        prepareTextField(textField: bottomTextField, defaultText:"BOTTOM")
        //share
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Disabling the Camera Button
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    //keyboard dismissed when presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //select an image from album button
    @IBAction func pickAnImage(_ sender: Any) {
        imagePickerSourceType(sourceType: .photoLibrary)
    }
    //Receiving an Image Using a Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let Image = info[.originalImage] as? UIImage {
            imageView.image  = Image
        }
        //After adding the photo you can now share
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    
    //cancel image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // image from camera button
    @IBAction func pickAnImageForCamera(_ sender: Any) {
        imagePickerSourceType(sourceType: .camera)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        
        //Add it to the memes array on the Application Delegate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        
    }
    
    func generateMemedImage() -> UIImage {
        //Hide toolbar and navbar
        toolBar.isHidden = true
        navigationBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //Show Toolbar and Navigation Bar
        toolBar.isHidden = false
        navigationBar.isHidden = false
        
        return memedImage
    }
    //sharing a meme
    @IBAction func share(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activity, completed, items, error) in
            if completed{
                self.save()
            }
            self.dismiss(animated: true, completion: nil)
        }
        present(controller, animated: true, completion: nil)
    }
    //cancle Button "Reset"
    @IBAction func cancel(_ sender: Any) {
        //topTextField.text = "TOP"
        //bottomTextField.text = "BOTTOM"
        //self.imageView.image = nil
        //shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    //text Attributes
    func prepareTextField(textField: UITextField, defaultText: String){
        textField.defaultTextAttributes = memeTextAttributes as [NSObject: AnyObject] as! [NSAttributedString.Key : Any]
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }
    
    // Present image depending on sourceType
    func imagePickerSourceType(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
}


