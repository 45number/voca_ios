//
//  InitialSettingsVC.swift
//  Vocabularity
//
//  Created by Admin on 13.10.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class InitialSettingsVC: UIPageViewController {

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVC(viewController: "initLanguages"), self.newVC(viewController: "initWords")]
    }()
    
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InitialSettingsVC.languagesChanged(_:)), name: NOTIF_LANGUAGES_DID_CHANGE, object: nil)
        
        
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
        // Do any additional setup after loading the view.
    }

    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = 0
        pageControl.tintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        self.view.addSubview(pageControl)
    }
    
    func newVC(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }

    
    
    
    
    //Funcs
    @objc func languagesChanged(_ notif: Notification) {
//        let learningLanguages = getLearningLanguages()
//        getCurrentLearningLanguage()
//        updateView()
//        setTabView(learningLanguages: learningLanguages)
        
        self.setViewControllers(orderedViewControllers,
                                direction: UIPageViewControllerNavigationDirection.forward,
                                              animated: true,
                                              completion: nil)
        
    }
    
//    func getLearningLanguages() -> [LearningLanguage] {
//        var learningLanguages: [LearningLanguage] = []
//        if defaults.bool(forKey: "english") {
//            learningLanguages.append(LearningLanguage(name: "English", tag: 1, image: nil, selectedImage: nil))
//        }
//        if defaults.bool(forKey: "russian") {
//            learningLanguages.append(LearningLanguage(name: "Russian", tag: 2, image: nil, selectedImage: nil))
//        }
//        if defaults.bool(forKey: "arabic") {
//            learningLanguages.append(LearningLanguage(name: "Arabic", tag: 3, image: nil, selectedImage: nil))
//        }
//        return learningLanguages
//    }
    
    
}

extension InitialSettingsVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {return nil}
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
//            return orderedViewControllers.last
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {return nil}
        return orderedViewControllers[previousIndex]
//        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {return nil}
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else {
//            return orderedViewControllers.first
            return nil
        }
        guard orderedViewControllers.count > nextIndex else {return nil}
        return orderedViewControllers[nextIndex]
//        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
}
