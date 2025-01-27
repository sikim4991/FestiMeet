//
//  TabBarController.swift
//  FestivalTogether
//
//  Created by SIKim on 9/23/24.
//

import UIKit

///탭바
class TabBarController: UITabBarController {
    private let appearance = UITabBarAppearance()
    private let homeViewController = HomeViewController()
    private let festivalInformationViewController = FestivalListViewController()
    private let communityViewController = CommunityViewController()
    private let chattingViewController = ChattingListViewController(member: nil)
    private let myPageViewController = MyPageViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setTabBarAndNavigationBar()
    }
    
    ///탭바와 내비게이션
    func setTabBarAndNavigationBar() {
        //탭바 설정 관련
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
        
        self.tabBar.layer.masksToBounds = false
        self.tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.tabBar.layer.shadowOpacity = 0.1
        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
        self.tabBar.layer.shadowRadius = 8
        
        self.tabBar.tintColor = UIColor.signatureTintColor()
        
        //탭바 아이템 설정 관련
        homeViewController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(resource: .home), tag: 0)
        festivalInformationViewController.tabBarItem = UITabBarItem(title: "축제정보", image: UIImage(resource: .confetti), tag: 1)
        communityViewController.tabBarItem = UITabBarItem(title: "게시판", image: UIImage(resource: .community), tag: 2)
        chattingViewController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(resource: .chat), tag: 3)
        myPageViewController.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(resource: .person), tag: 4)
        
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        let festivalInfoNavigationController = UINavigationController(rootViewController: festivalInformationViewController)
        let communityNavigationController = UINavigationController(rootViewController: communityViewController)
        let chattingNavigationController = UINavigationController(rootViewController: chattingViewController)
        let myPageNavigationController = UINavigationController(rootViewController: myPageViewController)
        
        setViewControllers([homeNavigationController, festivalInfoNavigationController, communityNavigationController, chattingNavigationController, myPageNavigationController], animated: false)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
