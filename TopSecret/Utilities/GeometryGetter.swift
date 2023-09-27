////
////  GeometryGetter.swift
////  Top Secret
////
////  Created by Bruce Blake on 7/4/22.
////
//
//import Foundation
//import SwiftUI
//
//struct GeometryGetter: View {
//    @Binding var rect: CGRect
//
//    var body: some View {
//        GeometryReader { geometry in
//            Group { () -> AnyView in
//                DispatchQueue.main.async {
//                    self.rect = geometry.frame(in: .global)
//                }
//
//                return AnyView(Color.clear)
//            }
//        }
//    }
//}
