//
//  RectangleView.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/26/22.
//

import SwiftUI

struct RectangleView: View {
    var isRotated: Bool = true
    var index: Int
    
    var width: CGFloat = 80
    var xDegree: Double = 60
    var rotationDegree: Double = 180
    var cornerRadius: CGFloat = 25.0
    var shadowRadius: CGFloat = 10
    var yOffset: CGFloat = -60
    
    var animation: Animation {
        Animation.easeInOut.speed(0.3).repeatForever(autoreverses: true)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
            .shadow(radius: shadowRadius)
            .foregroundColor(Color("AccentColor")).brightness(0 + (0.04 * Double(index)))
            .frame(width: width, height: width)
            .rotationEffect(Angle.degrees(isRotated ? rotationDegree : 0), anchor: .center)
            .rotation3DEffect(Angle.degrees(xDegree), axis: (x: 1, y: 0, z: 0))
            .offset(x: 0, y: yOffset * CGFloat(index))
            .zIndex(Double(-index))
            .animation(animation.delay(0.4 + (0.1 * Double(index))))
    }
}
