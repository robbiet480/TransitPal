//
//  SceneDelegate.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, InterfaceStyleDelegate, NFCReaderDelegate {
    var window: UIWindow?

    var userData: UserData = UserData()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller

        self.userData.nfcReader.tagDelegate = self

        let window = ColorChangingWindow(frame: UIScreen.main.bounds)
        window.styleDelegate = self
        window.rootViewController = UIHostingController(rootView: NavigationView(){
            CardHistoryList().environmentObject(self.userData)
        })
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func interfaceStyleChanged(_ previousStyle: UIUserInterfaceStyle, _ newStyle: UIUserInterfaceStyle) {
        // Pass through style changes
        self.userData.colorScheme = newStyle.colorScheme
    }

    func transitTagProcessed(_ tag: TransitTag) {
        self.userData.processedTag = tag
    }

}

protocol InterfaceStyleDelegate {
    func interfaceStyleChanged(_ previousStyle: UIUserInterfaceStyle, _ newStyle: UIUserInterfaceStyle)
}

class ColorChangingWindow: UIWindow {
    var styleDelegate: InterfaceStyleDelegate?

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let previousStyle = previousTraitCollection?.userInterfaceStyle, previousStyle != self.traitCollection.userInterfaceStyle {
            self.styleDelegate?.interfaceStyleChanged(previousStyle, self.traitCollection.userInterfaceStyle)
        }
    }
}

extension UIUserInterfaceStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .unspecified:
            return "Unspecified"
        @unknown default:
            return "Unknown"
        }
    }

    var colorScheme: ColorScheme? {
        if self == .dark {
            return .dark
        } else if self == .light {
            return .light
        }

        return nil
    }
}
