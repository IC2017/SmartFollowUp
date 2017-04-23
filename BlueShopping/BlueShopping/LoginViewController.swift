//
//  LoginViewController.swift
//  BlueShopping
//
//  Created by Anantha Krishnan K G on 05/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BMSCore
import BMSCore
import BMSAnalytics

class LoginViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet var containerView1: UIView!
    @IBOutlet var faceBookView: UIView!
    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var activitycontroller: UIActivityIndicatorView!
    @IBOutlet var containerView2: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let notificationName = Notification.Name("sendFeedBack1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitycontroller.isHidden = true

        // Do any additional setup after loading the view.
        self.containerView2.layer.borderWidth = 2.0;
        self.containerView2.layer.borderColor = UIColor(colorLiteralRed: 128.0/255.0, green: 203.0/255.0, blue: 196.0/255.0, alpha: 1.0).cgColor
        self.containerView2.layer.cornerRadius = 12.0;
        
        self.faceBookView.layer.cornerRadius = 9.0
        self.faceBookView.layer.borderColor = UIColor.white.cgColor
        self.faceBookView.layer.borderWidth = 2.0
        
        self.view.isUserInteractionEnabled = true;
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardDidShow(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sendFeedBack1"), object: nil);

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.loadMain), name: NSNotification.Name(rawValue: "sendFeedBack1"), object: nil)


    }
    func tap() {
        self.view.endEditing(true)
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                //isKeyboardActive = false
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: {
                                // move scroll view height to 0.0
                                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                                
                },
                               completion: { _ in
                })
            } else {
                //isKeyboardActive = true
                
                var userInfo = notification.userInfo!
                var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                
                
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0),
                               options: animationCurve,
                               animations: {
                                // move scroll view height to    endFrame?.size.height ?? 0.0
                                self.view.frame = CGRect(x: 0, y:  -(keyboardFrame.size.height), width: self.view.frame.size.width, height: self.view.frame.size.height)
                                
                },
                               completion: { _ in
                })
            }
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadMain(notification: NSNotification){
        
        self.view.isUserInteractionEnabled = false;
        self.activitycontroller.isHidden = true
       // performSegue(withIdentifier: "unwind1", sender: self)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func mfpLogin(_ sender: Any) {
        
        if (!(userName.text?.isEmpty)! && !(password.text?.isEmpty)!){
            self.activitycontroller.isHidden = false
            MyChallengeHandler.loginG(password: password.text!, userName: userName.text!)

        }

    }
    
}

/*

    @IBAction func googleSignin(_ sender: Any) {
        
        self.activitycontroller.isHidden = false
        //Invoking AppID login
        class delegate : AuthorizationDelegate {
            var view:UIViewController
            
            init(view:UIViewController) {
                self.view = view
            }
            public func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
                let myDict = [ "AccessToken": accessToken, "IdentityToken":identityToken] as [String : Any]

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendFeedBack1"), object: myDict)

            }
            public func onAuthorizationCanceled() {
                print("cancel")
            }
            
            public func onAuthorizationFailure(error: AuthorizationError) {
                print(error)
            }
        }
        AppID.sharedInstance.loginWidget?.launch(delegate: delegate(view: self))
    }
    
 
    @IBAction func faceBookSignin(_ sender: Any) {
        //Invoking AppID login

        class delegate : AuthorizationDelegate {
            var view:UIViewController
            
            init(view:UIViewController) {
                self.view = view
            }
            public func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
                let myDict = [ "AccessToken": accessToken, "IdentityToken":identityToken] as [String : Any]
                
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendFeedBack1"), object: myDict)

            }
            public func onAuthorizationCanceled() {
                print("cancel")
            }
            
            public func onAuthorizationFailure(error: AuthorizationError) {
                print(error)
            }
        }
        AppID.sharedInstance.loginWidget?.launch(delegate: delegate(view: self))
    }
    

}
 */
