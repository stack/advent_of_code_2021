//
//  RenderableWorkViewTestingApp.swift
//  RenderableWorkViewTesting
//
//  Created by Stephen H. Gerstacker on 2021-12-01.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import SwiftUI
import Utilities

@main
struct RenderableWorkViewTestingApp: App {
    var body: some Scene {
        WindowGroup {
            RenderableWorkView(width: 400, height: 400, frameTime: 0.1) { animator in
                var currentTime = 0.0
                let step = 0.1
                let max = 100.0

                while currentTime < max {
                    animator.draw { (context) in
                        let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)

                        let red: CGFloat = (CGFloat(sin(currentTime)) + 1.0) / 2.0
                        let green: CGFloat = 0.0
                        let blue: CGFloat = 0.0
                        let alpha: CGFloat = 1.0

                        let backgroundColor = CGColor(red: red, green: green, blue: blue, alpha: alpha)

                        context.setFillColor(backgroundColor)
                        context.fill(backgroundBounds)
                    }

                    currentTime += step
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
