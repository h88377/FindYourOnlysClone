//
//  SceneDelegate.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController()
        
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

