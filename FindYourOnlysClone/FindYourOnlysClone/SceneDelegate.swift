//
//  SceneDelegate.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/13.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let adoptListVC = makeAdoptListViewController()
        adoptListVC.title = "領養列表"
        
//        let viewModel = AdoptDetailViewModel<UIImage>(pet: <#T##Pet#>, image: <#T##UIImage?#>)
//        let adoptDetailVC = AdoptDetailViewController(viewModel: <#T##AdoptDetailViewModel<UIImage>#>)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: adoptListVC)
        
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func makeAdoptListViewController() -> AdoptListViewController {
        let baseURL = URL(string: "https://data.coa.gov.tw/Service/OpenData/TransService.aspx")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let petLoader = RemotePetLoader(baseURL: baseURL, client: client)
        let imageLoader = makeLocalImageDataLoaderWithRemoteFallback(with: client)
        
        let vc = AdoptListUIComposer.adoptListComposedWith(petLoader: petLoader, imageLoader: imageLoader)
        
        return vc
    }
    
    func makeLocalImageDataLoaderWithRemoteFallback(with client: HTTPClient) -> PetImageDataLoader {
        let remote = RemotePetImageDataLoader(client: client)
        
        guard let store = try? CoreDataPetImageDataStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("PetStore.sqlite")) else {
            return remote
        }
        
        let local = LocalPetImageDataLoader(store: store, currentDate: Date.init)
        let docoratedRemote = PetImageDataLoaderWithCacheDecorator(decoratee: remote, cache: local)
        return PetImageDataLoaderWithFallbackComposite(primary: local, fallback: docoratedRemote)
    }
}
