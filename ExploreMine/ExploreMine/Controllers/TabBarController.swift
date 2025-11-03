//
//  TabBarController.swift
//  ExploreMine
//
//  Created by Silstone on 10/12/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 4
        initUI()
    }
    
    func initUI() {
        let tabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        tabBarItem1.image = UIImage(named: "feed_unsel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem1.selectedImage = UIImage(named: "feed_sel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let tabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
        tabBarItem2.image = UIImage(named: "content_unsel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem2.selectedImage = UIImage(named: "content_sel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let tabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
        tabBarItem3.image = UIImage(named: "arBtnImage")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem3.selectedImage = UIImage(named: "arBtnImage")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem3.imageInsets = UIEdgeInsets(top: -12, left: 0, bottom: 0, right: 0)
        
        let tabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
        tabBarItem4.image = UIImage(named: "explore_unsel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem4.selectedImage = UIImage(named: "explore_sel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let tabBarItem5 = (self.tabBar.items?[4])! as UITabBarItem
        tabBarItem5.image = UIImage(named: "profile_unsel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem5.selectedImage = UIImage(named: "profile_sel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
    }
    
}
