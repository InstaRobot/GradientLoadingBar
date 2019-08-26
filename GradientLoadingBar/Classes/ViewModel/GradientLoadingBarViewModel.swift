//
//  GradientLoadingBarViewModel.swift
//  GradientLoadingBar
//
//  Created by Felix Mau on 12/26/17.
//  Copyright © 2017 Felix Mau. All rights reserved.
//

import Foundation
import LightweightObservable

/// The `GradientLoadingBarViewModel` class is responsible for the visibility state of the gradient view.
class GradientLoadingBarViewModel {
    
    // MARK: - Public properties

    /// Observable for the superview of the gradient-view.
    var superview: Observable<UIView?> {
        return superviewSubject.asObservable
    }

    // MARK: - Private properties

    private let superviewSubject: Variable<UIView?> = Variable(nil)

    // MARK: - Dependencies

    private let sharedApplication: UIApplicationProtocol
    private let notificationCenter: NotificationCenter

    // MARK: - Constructor

    init(sharedApplication: UIApplicationProtocol = UIApplication.shared,
         notificationCenter: NotificationCenter = .default) {
        self.sharedApplication = sharedApplication
        self.notificationCenter = notificationCenter

        if let keyWindow = sharedApplication.keyWindow {
            // We have a valid key window.
            superviewSubject.value = keyWindow
        } else {
            // The key window is not available yet. This can happen, if the initializer is called from
            // `UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:)`.
            // Therefore we setup an observer to inform the view model when a `UIWindow` object becomes the key window.
            notificationCenter.addObserver(self,
                                           selector: #selector(didReceiveUIWindowDidBecomeKeyNotification(_:)),
                                           name: UIWindow.didBecomeKeyNotification,
                                           object: nil)
        }
    }

    // MARK: - Private methods

    @objc private func didReceiveUIWindowDidBecomeKeyNotification(_: Notification) {
        guard let keyWindow = sharedApplication.keyWindow else { return }

        // Prevent informing the listener multiple times.
        notificationCenter.removeObserver(self)

        // Now that we have a valid key window, we can use it as superview.
        superviewSubject.value = keyWindow
    }
}

// MARK: - Helper

/// This allows mocking `UIApplication` in tests.
protocol UIApplicationProtocol: AnyObject {
    var keyWindow: UIWindow? { get }
}

extension UIApplication: UIApplicationProtocol {}
