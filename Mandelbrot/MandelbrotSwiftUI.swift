//
//  MandelbrotApproach2.swift
//  Mandelbrot
//
//  Created by Preethi Shenoy on 1/6/24.
//

import SwiftUI

struct MandelbrotSwiftUI: View {
    @State private var mandelbrotImage: Image?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                let newScale = value / self.lastScale
                self.lastScale = value
                self.scale *= newScale
                self.generateMandelbrotImage()
            }
            .onEnded { value in
                self.lastScale = 1.0
            }

        let dragGesture = DragGesture()
            .onChanged { value in
                self.offset = CGSize(
                    width: self.lastOffset.width + value.translation.width,
                    height: self.lastOffset.height + value.translation.height
                )
                self.generateMandelbrotImage()
            }
            .onEnded { value in
                self.lastOffset = self.offset
            }

        return VStack {
            if let image = mandelbrotImage {
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(magnificationGesture.simultaneously(with: dragGesture))
            } else {
                ProgressView()
                    .onAppear {
                        self.generateMandelbrotImage()
                    }
            }
        }
        .navigationBarTitle("Mandelbrot Set")
    }

    func generateMandelbrotImage() {
        let imageSize = CGSize(width: 1000 * scale, height: 1000 * scale)
        let mandelbrot = MandelbrotGenerator()
        self.mandelbrotImage = mandelbrot.generateImage(size: imageSize)
    }
}

struct MandelbrotGenerator{
    func generateImage(size: CGSize) -> Image {
        let width = Int(size.width)
        let height = Int(size.height)
        let iterations = 100

        let uiImage = UIGraphicsImageRenderer(size: size).image { context in
            for x in stride(from: 0, to: width, by: 2) {
                for y in stride(from: 0, to: height, by: 2) {
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
                    context.cgContext.fill(CGRect(x: x, y: y, width: 2, height: 2))
                }
            }
        }

        return Image(uiImage: uiImage)
    }

    func map(value: CGFloat, fromRange: Range<CGFloat>, toRange: Range<Double>) -> CGFloat {
        let fromRangeSize = fromRange.upperBound - fromRange.lowerBound
        let toRangeSize = toRange.upperBound - toRange.lowerBound

        let scaleFactor = toRangeSize / Double(fromRangeSize)
        let scaledValue = Double(value - fromRange.lowerBound) * scaleFactor

        return CGFloat(toRange.lowerBound + scaledValue)
    }
}
