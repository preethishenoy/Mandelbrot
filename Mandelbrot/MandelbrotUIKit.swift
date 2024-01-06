//
//  MandelbrotView.swift
//  Mandelbrot
//
//  Created by Preethi Shenoy on 12/29/23.
//

import SwiftUI

struct MandelbrotUIKit: View {
    var body: some View {
        GeometryReader { geometry in
            MandelbrotScrollView(size: geometry.size)
        }
        .navigationBarTitle("Mandelbrot Set")
    }
}

struct MandelbrotScrollView: UIViewRepresentable {
    let size: CGSize

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5.0

        let imageView = UIImageView(image: generateMandelbrotImage(size: size))
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.frame.size
        
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(size: size)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let size: CGSize

        init(size: CGSize) {
            self.size = size
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }

    func generateMandelbrotImage(size: CGSize) -> UIImage {
        let width = Int(size.width)
        let height = Int(size.height)
        let iterations = 80

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            for x in stride(from: 0, to: width, by: 1) {
                for y in stride(from: 0, to: height, by: 1) {
                    let a = map(value: CGFloat(x), fromRange: 0..<CGFloat(width), toRange: -2..<2)
                    let b = map(value: CGFloat(y), fromRange: 0..<CGFloat(height), toRange: -2..<2)

                    var z = CGPoint(x: 0, y: 0)
                    var iteration = 0

                    while z.x * z.x + z.y * z.y < 4 && iteration < iterations {
                        let tempA = z.x * z.x - z.y * z.y + a
                        let tempB = 2 * z.x * z.y + b
                        z = CGPoint(x: tempA, y: tempB)
                        iteration += 1
                    }

                    let color = iteration == iterations ? UIColor.black : UIColor(hue: CGFloat(iteration) / CGFloat(iterations), saturation: 1, brightness: 1, alpha: 1)
                    context.cgContext.setFillColor(color.cgColor)
                    context.cgContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        return image
    }
    
    func map(value: CGFloat, fromRange: Range<CGFloat>, toRange: Range<Double>) -> CGFloat {
        let fromRangeSize = fromRange.upperBound - fromRange.lowerBound
        let toRangeSize = toRange.upperBound - toRange.lowerBound

        let scaleFactor = toRangeSize / Double(fromRangeSize)
        let scaledValue = Double(value - fromRange.lowerBound) * scaleFactor

        return CGFloat(toRange.lowerBound + scaledValue)
    }
}
