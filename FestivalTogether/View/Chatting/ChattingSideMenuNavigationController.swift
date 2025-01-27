//
//  ChattingSideMenuNavigationController.swift
//  FestivalTogether
//
//  Created by SIKim on 11/16/24.
//

import UIKit
import SideMenu

class ChattingSideMenuNavigationController: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //스타일 설정
        self.presentationStyle = .menuSlideIn
        //상태바 보이게 설정
        self.statusBarEndAlpha = 0.0
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
