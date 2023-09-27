//
//  RefreshableScrollView.swift
//  Top Secret
//
//  Created by Bruce Blake on 1/4/23.
//

import SwiftUI

//struct RefreshableScrollView<Content:View> : View {
//    init(action: @escaping () -> (Void), @ViewBuilder content: @escaping () -> Content){
//        self.content = content
//        self.refreshAction = action
//    }
//        private var content: () -> Content
//        private var refreshAction: () -> (Void)
//        private let threshold:CGFloat = 50.0
//        @State var geom : CGFloat = .zero
//    
//    var body: some View {
//        GeometryReader{ geometry in
//            ScrollView(showsIndicators: false){
//                content()
//                    .anchorPreference(key: OffsetPreferenceKey.self, value: .top) {
//                                            geometry[$0].y
//                                        }
//            }
//            .onPreferenceChange(OffsetPreferenceKey.self) { offset in
//                if offset > threshold {
//                    refreshAction()
//                }
//            }
//        }
//    }
//}
//
//fileprivate struct OffsetPreferenceKey: PreferenceKey{
//    static var defaultValue: CGFloat = 0
//
//        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//            value = nextValue()
//        }
//}
