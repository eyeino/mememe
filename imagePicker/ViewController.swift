//
//  ViewController.swift
//  imagePicker
//
//  Created by Ian MacFarlane on 7/1/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //MARK: Outlet Declarations
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    
    //MARK: View Functions

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setMemeTextFieldProperties(topText)
        setMemeTextFieldProperties(bottomText)
        
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        topText.tag = 0 //referenced by textFieldTags.top enum
        bottomText.tag = 1 //referenced by textFieldTags.bottom enum
        
        //Hides keyboard when user taps anywhere outside of a TextField.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Delegate hides keyboard upon pressing return
        self.topText.delegate = self
        self.bottomText.delegate = self
        
        shareButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        //Disable camera button if camera is not available on device
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Meme Making
    
    struct Meme {
        let top: String
        let bottom: String
        let originalImage: UIImage
        let memedImage: UIImage
    }
    
    func generateMemedImage() -> UIImage {
        
        topBar.hidden = true
        bottomBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topBar.hidden = false
        bottomBar.hidden = false
        
        return memedImage
    }
    
    func setMemeTextFieldProperties(textField: UITextField) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName: -3.6
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        textField.backgroundColor = UIColor.clearColor()
        textField.borderStyle = .None
    }
    
    //MARK: Buttons
    
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        pickAnImage(.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        pickAnImage(.Camera)
    }
    
    //Initializes Meme object and sends .memedImage to the ActivityViewController
    @IBAction func shareMeme() {
        let meme = Meme(top: topText.text!, bottom: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        let nextController = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        self.presentViewController(nextController, animated: true, completion: nil)
    }

    //MARK: Image Picking
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = image
            imageView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin]
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
        
        shareButton.enabled = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Keyboard Functions
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //View will only shift up if bottom textfield is being edited
        if bottomText.editing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                if view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: UITextFieldDelegate Functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Clears textfields when editing begins
    func textFieldDidBeginEditing(textField: UITextField) {
        let text = textField.text
        if text == "TOP" || text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    enum textFieldTags: Int {
        case top = 0
        case bottom = 1
    }
    
    //If textfield is empty when editing ends, insert "TOP" or "BOTTOM"
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text!
        let tag = textField.tag
        switch (text, tag) {
        case ("", textFieldTags.top.rawValue):
            textField.text = "TOP"
        case ("", textFieldTags.bottom.rawValue):
            textField.text = "BOTTOM"
        default:
            break
        }
    }
    
}

