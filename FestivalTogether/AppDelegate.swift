//
//  AppDelegate.swift
//  FestivalTogether
//
//  Created by SIKim on 9/9/24.
//

import UIKit
import RxSwift
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import NaverThirdPartyLogin
import RxKakaoSDKAuth
import RxKakaoSDKCommon
import KakaoSDKAuth
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let disposeBag = DisposeBag()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for cust1omization after application launch.
        // 네이버 로그인 설정
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        let naverInstanceConsumerKey = Bundle.main.infoDictionary?["NaverInstanceConsumerKey"] as! String
        let naverInstanceConsumerSecret = Bundle.main.infoDictionary?["NaverInstanceConsumerSecret"] as! String
        let kakaoAppKey = Bundle.main.infoDictionary?["KakaoAppKey"] as! String
        let naverMapClientId = Bundle.main.infoDictionary?["NaverMapClientId"] as! String
        
        instance?.isNaverAppOauthEnable = true
        instance?.isInAppOauthEnable = true
        instance?.setOnlyPortraitSupportInIphone(true)
        
        instance?.serviceUrlScheme = "net.macnpc.FestivalTogether"
        instance?.consumerKey = naverInstanceConsumerKey
        instance?.consumerSecret = naverInstanceConsumerSecret
        instance?.appName = "페스티밋"
        
        
        //파이어베이스 설정
        FirebaseApp.configure()
        
        
        //카카오 로그인 설정
        RxKakaoSDK.initSDK(appKey: kakaoAppKey)
        
        
        //네이버 지도 설정
        NMFAuthManager.shared().clientId = naverMapClientId
        
        //search bar 전체에 폰트 적용
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.font: UIFont.mainFontRegular(size: 12.0)]
        
        //알림 설정
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        //SNS 로그인 URL 연결
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return GIDSignIn.sharedInstance.handle(url) || NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options) || AuthController.rx.handleOpenUrl(url: url)
        }
        return GIDSignIn.sharedInstance.handle(url) || NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
    }
}

extension AppDelegate: MessagingDelegate {
    // 기기 토큰과 apns토큰 연결
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken;
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

