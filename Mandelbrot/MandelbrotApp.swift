//
//  MandelbrotApp.swift
//  Mandelbrot
//
//  Created by Preethi Shenoy on 12/29/23.
//

import SwiftUI

@main
struct MandelbrotApp: App {
    var body: some Scene {
        WindowGroup {
            /* Implemented Mandelbrot using UIKit gestures which renders image with smooth gesture handling */
            MandelbrotUIKit()
            /* Implemented Mandelbrot using SwiftUI gestures which renders high definition image but relatively slow gesture handling */
//            MandelbrotSwiftUI()
        }
    }
}
