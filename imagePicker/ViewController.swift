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
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    //set local memes array to access AppDelegate memes array
    var memes: [Meme] {
        get {
            return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        }
        set {
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes = newValue
        }
    }
    
    //MARK: View Functions

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setMemeTextFieldProperties(topText)
        setMemeTextFieldProperties(bottomText)
        
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        topText.tag = TextFieldTags.top.rawValue
        bottomText.tag = TextFieldTags.bottom.rawValue
        
        //Hides keyboard when user taps anywhere outside of a TextField.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Delegate hides keyboard upon pressing return
        topText.delegate = self
        bottomText.delegate = self
        
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
    
    func generateMemedImage() -> UIImage {
        
        hideToolBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        hideToolBars(false)
        
        return memedImage
    }
    
    func hideToolBars(hidden: Bool) {
        topBar.hidden = hidden
        bottomBar.hidden = hidden
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
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        pickAnImage(.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        pickAnImage(.Camera)
    }
    
    @IBAction func shareMeme() {
        let memedImage = generateMemedImage()
        let nextController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        nextController.completionWithItemsHandler = {
            (activityType, completed, returnedItems, activityError) in
            if completed {
                self.saveMeme(memedImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(nextController, animated: true, completion: nil)
    }
    
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(top: topText.text!, bottom: bottomText.text!, originalImage: imageView.image!, memedImage: memedImage)
        memes.append(meme)
        print("saveMeme called. there are now \(memes.count) memes stored in the AppDelegate")
    }
    
    @IBAction func dismissController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Image Picking
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin]
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
        
        shareButton.enabled = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
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
        if bottomText.isFirstResponder(){
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
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
    
    enum TextFieldTags: Int {
        case top = 0
        case bottom = 1
    }
    
    //If textfield is empty when editing ends, insert "TOP" or "BOTTOM"
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text!
        let tag = textField.tag
        switch (text, tag) {
        case ("", TextFieldTags.top.rawValue):
            textField.text = "TOP"
        case ("", TextFieldTags.bottom.rawValue):
            textField.text = "BOTTOM"
        default:
            break
        }
    }
    
}

