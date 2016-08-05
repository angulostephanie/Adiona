//
//  IDPicturePageVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/12/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import ParseUI

class IDPicturePageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, IDPicturePageContentDelegate {
    
    var numPics: Int {
        get {
            return pictures.count
        }
    }
    var numScreens: Int {
        get {
            if numPics < 3 {
                return numPics + 1
            } else {
                return 3
            }
        }
    }
    var pictures: [PFFile] = []
    var pageVCs: [IDPicturePageContentVC] = []
    let pageControl = UIPageControl.appearanceWhenContainedInInstancesOfClasses([IDPicturePageVC.self])
    var currentIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setInitialVC() {
        // create content view controllers
        for i in 0..<numScreens {
            let vc = createPageVCWithIndex(i)
            if vc != nil {
                pageVCs.append(vc!)
            }
        }
        
        if pageVCs.count > 0 {
            self.setViewControllers([pageVCs[0]], direction: .Forward, animated: true, completion: nil)
            currentIndex = 0
        }
    }
    
    func createPageVCWithIndex(index: Int) -> IDPicturePageContentVC? {
        if numScreens <= 0 || index >= numScreens {
            return nil
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("picturePageContent") as! IDPicturePageContentVC
        vc.delegate = self
        vc.pageIndex = index
        
        vc.dismissCompletion = { () -> () in
            self.setViewControllers([self.pageVCs[index]], direction: .Forward, animated: false, completion: nil)
        }
        
        if index < numPics {
            vc.picture = pictures[index]
        }
        
        if index == numPics && numPics < 3 {
            vc.showAddNewPhoto = true
        } else {
            vc.showAddNewPhoto = false
        }
        
        return vc
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let contentVC = self.viewControllers!.first as? IDPicturePageContentVC
            if let vc = contentVC {
                currentIndex = vc.pageIndex
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! IDPicturePageContentVC).pageIndex
        
        if let index = index {
            if index > 0 {
                return pageVCs[index - 1]
            }
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! IDPicturePageContentVC).pageIndex
        
        if let index = index {
            if index < numScreens - 1 {
                return pageVCs[index + 1]
            }
        }
        
        return nil
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return numScreens
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIndex ?? 0
    }
    
    func setPicture(index: Int, picture: PFFile) {
        if index >= self.numPics {
            pictures.append(picture)
            if numPics < 3 {
                // create new view controller
                let newVC = createPageVCWithIndex(index + 1)
                if let vc = newVC {
                    pageVCs.append(vc)
                }
            } else {
                // edit current view controller to have picture
            }
        } else {
            pictures[index] = picture
        }
    }
}
