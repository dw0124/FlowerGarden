//
//  AppDelegate.swift
//  FlowerGarden
//
//  Created by 박지용 on 2022/09/13.
//

import UIKit
import NMapsMap
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    // GIDSignInDelegate 프로토콜 준수
    // Google 로그인 인증 후 전달된 값 처리하기
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {    // 에러 처리
          print("ERROR Google Sign In \(error.localizedDescription)")
          return
        }
        
        // 사용자 인증값 가져오기
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        // Firebase Auth에 인증정보 등록하기
        Auth.auth().signIn(with: credential) { _, _ in
            
            var ref: DatabaseReference!
            ref = Database.database().reference()
            
            if LoginViewController.onwer {
                let user = Auth.auth().currentUser
                
                // DB 데이터 가져오기
                ref.child("owner_list/\(user?.uid ?? "")/uid").getData(completion:  { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    let uid = snapshot?.value as? String ?? "Non-uid";
                    
                    // 로그인된 uid가 이미 DB에 있으면 메인화면으로
                    if user?.uid == uid {
                        self.showMainViewController()
                    }
                    // 로그인된 uid가 DB에 없으면
                    else {
                        // 점포 정보 입력하는 화면으로 이동
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let mainViewController = storyboard.instantiateViewController(withIdentifier: "GSignUpOwnerViewController")
                        mainViewController.modalPresentationStyle = .fullScreen
                        //UIApplication.shared.windows.first?.rootViewController?.show(mainViewController, sender: nil)
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScene = scenes.first as? UIWindowScene
                        windowScene?.windows.first?.rootViewController?.show(mainViewController, sender: nil)
                        // Real Database에 회원 저장
                    }
                });
            }
            // 사용자 로그인일 경우
            else {
                let user = Auth.auth().currentUser
                // DB 데이터 가져오기
                ref.child("user_list/\(user?.uid ?? "")/uid").getData(completion:  { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    let uid = snapshot?.value as? String ?? "Non-uid";
                    
                    // 로그인된 uid가 이미 DB에 있으면 메인화면으로
                    if user?.uid == uid {
                        self.showMainViewController()    // 메인 화면으로 이동
                    }
                    // 로그인된 uid가 DB에 없을때 DB에 저장
                    else {
                        // 구글 회원 정보 불러오기
                        if let userInfo = Auth.auth().currentUser?.providerData[0] {
                            let user = Auth.auth().currentUser
                            
                            // Real Database에 회원 저장
                            ref.child("user_list").child(user?.uid ?? "uid").setValue(["uid": user?.uid, "name": userInfo.displayName, "email": userInfo.email])
                            self.showMainViewController()    // 메인 화면으로 이동
                        }
                    }
                });
            }
        }
    }

    // 메인 화면으로 이동하기
    private func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        mainViewController.modalPresentationStyle = .fullScreen
        //UIApplication.shared.windows.first?.rootViewController?.show(mainViewController, sender: nil)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController?.show(mainViewController, sender: nil)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 네이버 지도 헤더
        NMFAuthManager.shared().clientId = "oawdp0aaj8"
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Google 로그인 Delgate 초기화
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      // 구글의 인증 프로세스가 끝날 때 앱이 수신하는 url 처리
      return GIDSignIn.sharedInstance().handle(url)
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

