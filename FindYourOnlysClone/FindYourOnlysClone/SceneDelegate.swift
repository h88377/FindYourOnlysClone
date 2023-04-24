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
        
        let adoptListVC = makeAdoptListViewController()
        adoptListVC.title = "領養列表"
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: adoptListVC)
        
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    func makeAdoptListViewController() -> AdoptListViewController {
        let baseURL = URL(string: "https://data.coa.gov.tw/Service/OpenData/TransService.aspx")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let petLoader = RemotePetLoader(baseURL: baseURL, client: client)
        let imageLoader = RemotePetImageDataLoader(client: client)
        let vc = AdoptListUIComposer.adoptListComposedWith(petLoader: petLoader, imageLoader: imageLoader)
        
        return vc
    }
}
