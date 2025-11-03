//
//  GetDirectionViewController.swift
//  ExploreMine
//
//  Created by Silstone Group on 27/11/19.
//  Copyright © 2019 Silstone Group. All rights reserved.
//

import UIKit

class TutorialVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var Collection_View: UICollectionView!
    
    // MARK: - variables declaration
    var commonFunctions = CommonFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.outlinedEllipse(size: CGSize(width: 7.0, height: 7.0), color: .white)
        self.pageControl.pageIndicatorTintColor = UIColor.init(patternImage: image!)
        self.pageControl.currentPageIndicatorTintColor = .black
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if pageNumber == 0{
            pageControl.currentPage = 0
        }else if pageNumber == 1{
            pageControl.currentPage = 1
        }else if pageNumber == 2{
            pageControl.currentPage = 2
        }else if pageNumber == 3{
            pageControl.currentPage = 3
        }else{
            UserDefaults.standard.set(true, forKey: kTutorialViewed)
            pageControl.currentPage = 4
        }
    }
    //MARK:DATASOURCE
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCVCell", for: indexPath) as! TutorialCVCell
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: kTutorialViewed)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func btnSignupClicked(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: kTutorialViewed)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

