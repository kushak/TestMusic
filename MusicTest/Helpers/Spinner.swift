//
//  Spinner.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 05.11.2023.
//

import UIKit

final class Spinner {
    private static var viewController: ViewController? {
        let window = UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last

        return window?.rootViewController as? ViewController
    }

    static func startLoading() {
        viewController?.startLoading()
    }

    static func stopLoading() {
        viewController?.stopLoading()
    }
}




