//
//  MandelbrotView.swift
//  Mandelbrot
//
//  Created by Preethi Shenoy on 12/29/23.
//

import SwiftUI

struct MandelbrotView: View {
    let width: Int = 800
    let height: Int = 800
    let iterations: Int = 300
    @State private var scale: CGFloat = 1.0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var previousScale: CGFloat = 1.0
    @State private var isZooming: Bool = false
    @GestureState private var dragOffset: CGSize = CGSize.zero

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                scale = previousScale * value
                isZooming = true
            }
            .onEnded { _ in
                previousScale = scale
                isZooming = false
            }

        let dragGesture = DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onChanged { value in
                if isZooming {
                    offsetX += value.translation.width
                    offsetY += value.translation.height
                }
            }

        Image(uiImage: generateMandelbrotImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: CGFloat(width), height: CGFloat(height))
            .scaleEffect(scale)
            .offset(x: offsetX + dragOffset.width, y: offsetY + dragOffset.height)
            .gesture(magnificationGesture)
            .gesture(dragGesture)
            .onTapGesture {
                scale = 1.0
                previousScale = 1.0
                offsetX = 0.0
                offsetY = 0.0
            }
    }

    func generateMandelbrotImage() -> UIImage {
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        return renderer.image { context in
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
    }

    func map(value: CGFloat, fromRange: Range<CGFloat>, toRange: Range<Double>) -> CGFloat {
        let fromRangeSize = fromRange.upperBound - fromRange.lowerBound
        let toRangeSize = toRange.upperBound - toRange.lowerBound

        let scaleFactor = toRangeSize / Double(fromRangeSize)
        let scaledValue = Double(value - fromRange.lowerBound) * scaleFactor

        return CGFloat(toRange.lowerBound + scaledValue)
    }
}

struct MandelbrotView_Previews: PreviewProvider {
    static var previews: some View {
        MandelbrotView()
    }
}

