//
//  FullScreenPostView.swift
//  TopSecret
//
//  Created by nathan frenzel on 6/15/21.
//

import SwiftUI

struct FullScreenPostView: View {
    @ObservedObject var viewModel = UserAuthViewModel()
    @Binding var selectedTab: Int
    @Binding var isPresented: Bool
    @Binding var storedTab: Int
    @State var captionText: String = ""
    @State var selectedOption = PostFilterOptions.text
    
    init(selectedTab: Binding<Int>, isPresented: Binding<Bool>, storedTab: Binding<Int>, selectedOption: String) {
        self._selectedTab = selectedTab
        self._isPresented = isPresented
        self._storedTab =  storedTab
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    HStack(alignment: .top, spacing: 8) {
                        Text(viewModel.user?.username ?? "")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.vertical, 12)
                            .padding(2)
                        
                        TextArea("What's Happening?", text: $captionText)
                            .font(.system(size: 15, weight: .semibold))

                    }
                    .navigationTitle("Top Secret")
                    .navigationBarItems(leading: Button(action: { isPresented.toggle(); selectedTab = storedTab }, label: {
                        Text("Cancel")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .font(.system(size: 15, weight: .semibold))
                            .background(Color("TestColor"))
                            .foregroundColor(.white)
                            .cornerRadius(32)
                    }))
                    Spacer()
                   
                    ZStack(alignment:.bottom) {
                        RoundedRectangle(cornerSize: CGSize(width: 20,height: 10))
                            .ignoresSafeArea()
                            .foregroundColor(Color("TestColor"))
                        GeometryReader { maths in
                            PostViewFilterOptions(selectedOption: $selectedOption)
                                .frame(width: maths.size.width, height: maths.size.height * 0.5)
                                .padding(.top, 10)
                        }.frame(width: geometry.size.width * 0.9)
                    }.frame(height: geometry.size.height * 0.15)
                }
            }
        }
    }
}




