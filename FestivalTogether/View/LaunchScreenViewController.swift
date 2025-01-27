//
//  LaunchScreenViewController.swift
//  FestivalTogether
//
//  Created by SIKim on 1/12/25.
//

import UIKit
import Lottie

///런치 스크린
class LaunchScreenViewController: UIViewController {
    private let festiMeetLogoImageView = UIImageView(image: UIImage(resource: .festiMeetLogo))
    private let fireworksAnimationView = LottieAnimationView(name: "fireworksAnimation")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBaseView()
        animationPlayAndAfter()
    }
    
    ///기본적인 뷰
    func setBaseView() {
        view.backgroundColor = .signatureBackgroundColor()
        
        festiMeetLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        fireworksAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(festiMeetLogoImageView)
        view.addSubview(fireworksAnimationView)
        
        festiMeetLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        festiMeetLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50.0).isActive = true
        
        fireworksAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        fireworksAnimationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        fireworksAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        fireworksAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    ///애니메이션 실행 후 본 화면 진입
    func animationPlayAndAfter() {
        fireworksAnimationView.play(fromProgress: 0.0, toProgress: 0.9) { _ in
            DispatchQueue.main.async {
                let viewController = TabBarController()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = viewController
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        }
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
