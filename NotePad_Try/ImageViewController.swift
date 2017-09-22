//
//  ImageViewController.swift
//  NotePad_Try
//
//  Created by Berkay AYAZ on 2016-07-30.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController,UINavigationControllerDelegate {
    
    var imageArr = [String]()
    var imageIndex = 0;
    
    @IBOutlet weak var myView: UIView!
    var currImage = UIImageView()
    var rightImage = UIImageView()
    var leftImage = UIImageView()
    var animationActivity = true
    var db: DB?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = DB()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.myView.backgroundColor = UIColor.black
        let bounds:CGRect = myView.bounds
        let width:CGFloat = bounds.size.width
        let height:CGFloat = bounds.size.height
        
        navigationController?.delegate = self
        
        // hide navigation bar but it doesnt work... ##################
        let hiddenNavigationBar = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.singleTap(_:)))
        //  hiddenNavigationBar = navigationController?.barHideOnTapGestureRecognizer
        hiddenNavigationBar.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(hiddenNavigationBar)
        
        
        print(imageArr.count)
        if (imageArr.count) == 1 {
            currImage.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            currImage.image = UIImage(contentsOfFile: imageArr[0])
            self.myView.addSubview(currImage)
        } else {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ImageViewController.handleSwipe(_:)))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            self.view.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ImageViewController.handleSwipe(_:)))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            self.view.addGestureRecognizer(swipeRight)
            
            
            if imageArr.count - 1 == imageIndex {
                
                currImage.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
                currImage.image = UIImage(contentsOfFile: imageArr[imageIndex])
                
                rightImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
                rightImage.image = UIImage(contentsOfFile: imageArr[0])
                leftImage.frame = CGRect(x: -width, y: 0.0, width: width, height: height)
                leftImage.image = UIImage(contentsOfFile: imageArr[imageArr.count - 1])
                
                self.myView.addSubview(currImage)
                self.myView.addSubview(rightImage)
                self.myView.addSubview(leftImage)
                
            } else if imageIndex == 0 {
                currImage.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
                currImage.image = UIImage(contentsOfFile: imageArr[imageIndex])
                
                rightImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
                rightImage.image = UIImage(contentsOfFile: imageArr[imageIndex + 1])
                
                self.myView.addSubview(currImage)
                self.myView.addSubview(rightImage)
            } else {
                currImage.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
                currImage.image = UIImage(contentsOfFile: imageArr[imageIndex])
                
                rightImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
                rightImage.image = UIImage(contentsOfFile: imageArr[imageIndex + 1])
                leftImage.frame = CGRect(x: -width, y: 0.0, width: width, height: height)
                leftImage.image = UIImage(contentsOfFile: imageArr[imageIndex - 1])
                
                self.myView.addSubview(currImage)
                self.myView.addSubview(rightImage)
                self.myView.addSubview(leftImage)
                
            }
        }
        
        //                    let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.singleTap(_:)))
        //                    singleTap.numberOfTapsRequired = 1
        //                    view.addGestureRecognizer(singleTap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func handleSwipe(_ gesture: UIGestureRecognizer) {
        
        let bounds:CGRect = myView.bounds
        let width:CGFloat = bounds.size.width
        let height:CGFloat = bounds.size.height
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if (swipeGesture.direction == UISwipeGestureRecognizerDirection.left ) {
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    
                    
                    self.currImage.frame = CGRect(x: -width, y: 0.0, width: width, height: height)
                    self.rightImage.frame = CGRect(x: 0.0, y:0.0, width: width, height: height)
                    
                    }, completion: { finished in
                        
                        if (!finished) { return }
                        
                        self.imageIndex += 1
                        self.imageIndex = self.imageIndex <= self.imageArr.count-1 ? self.imageIndex : 0
                        
                        let leftIndex = self.imageIndex - 1 < 0 ? self.imageArr.count - 1 : self.imageIndex - 1
                        
                        self.leftImage.image = UIImage(contentsOfFile: self.imageArr[leftIndex])
                        self.leftImage.frame = CGRect(x: -width, y: 0.0, width: width, height: height)
                        
                        let tempImg = self.currImage
                        
                        self.currImage = self.rightImage
                        
                        self.rightImage = tempImg
                        
                        self.rightImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
                        
                        let rightIndex = self.imageIndex + 1 > self.imageArr.count - 1 ? 0 : self.imageIndex + 1
                        self.rightImage.image = UIImage(contentsOfFile: self.imageArr[rightIndex])
                        
                })
            }
            
            if (swipeGesture.direction == UISwipeGestureRecognizerDirection.right) {
                
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    
                    self.currImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
                    self.leftImage.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
                    
                    }, completion: { finished in
                        
                        
                        self.imageIndex -= 1
                        self.imageIndex = self.imageIndex < 0 ? self.imageArr.count - 1 : self.imageIndex
                        
                        let rightIndex = self.imageIndex + 1 > self.imageArr.count - 1 ? 0 : self.imageIndex + 1
                        
                        self.rightImage.image = UIImage(contentsOfFile: self.imageArr[rightIndex])
                        self.rightImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
                        
                        let tempImg = self.currImage
                        
                        self.currImage = self.leftImage
                        self.leftImage = tempImg
                        
                        self.leftImage.frame = CGRect(x: -width, y: 0.0, width: width, height: height)
                        let leftIndex = self.imageIndex - 1 < 0 ? self.imageArr.count - 1 : self.imageIndex - 1
                        self.leftImage.image = UIImage(contentsOfFile: self.imageArr[leftIndex])
                        
                })
            }
            
        }
    }
    
    func deleteAction(){
        self.imageArr.remove(at: self.imageIndex)
        if self.imageArr.count == 0 {
            navigationController?.popViewController(animated: true)
        } else if self.imageArr.count == 1 {
            self.imageIndex = 0
            self.currImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex])
            
            
            for recognizer in self.view.gestureRecognizers ?? [] {
                self.view.removeGestureRecognizer(recognizer)
            }
            
        } else if imageIndex == 0 {
            self.currImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex])
            self.rightImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex + 1])
        } else if imageIndex == imageArr.count - 1 {
            self.currImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex])
            self.leftImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex - 1])

        } else {
//            self.imageIndex -= 1
            self.currImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex])
            self.leftImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex - 1])
            self.rightImage.image = UIImage(contentsOfFile: self.imageArr[imageIndex + 1])
            
        }
        
        //Photos.delete(db!, photo: imageArr[imageIndex])
        //performSegueWithIdentifier("goBackNoteDetails", sender: self)
    }
    
    func singleTap(_ gesture: UIGestureRecognizer){
        if ((navigationController?.isNavigationBarHidden) != nil){
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
        else{
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title:"Delete Photo",
                                                message: "Are you sure to delete this photo?",
                                                preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Yes",
                                     style: UIAlertActionStyle.destructive, handler: { void in self.deleteAction() })
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "No",
                                         style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? NoteDetails_ViewController {
            controller.imageSource = self.imageArr
            controller.collectionView.reloadData()
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
        return orientation
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval)
    {
        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
        {
            self.myView.frame = UIScreen.main.bounds
            let bounds:CGRect = myView.bounds
            let width:CGFloat = bounds.size.width
            let height:CGFloat = bounds.size.height + (navigationController?.navigationBar.frame.height)!
            currImage.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            rightImage.frame = CGRect(x: width, y: 0.0, width: width, height: height)
            leftImage.frame = CGRect(x: -width, y: 0.0, width: width, height: height)
            
        }
    }
    
    
    
}
