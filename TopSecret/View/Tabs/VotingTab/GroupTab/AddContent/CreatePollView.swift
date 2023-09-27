//
//  CreatePollView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/1/22.
//

import SwiftUI


struct AnswerOption : Identifiable{

    var id: String = UUID().uuidString
    var option: String = ""
}

struct CreatePollView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var createPollVM = CreatePollViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var options : [PollOptionModel] = [PollOptionModel()]
    @State var question = ""
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    
    func ableToCreatePoll() -> Bool {
        // must be atleast 2 options and no more than 5
        // must have a question
        return options.count > 1 && question != ""
    }
    var body: some View {
        ZStack{
        
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }.padding(.leading)
                        
                        
                        Spacer()
                        
                        
                        Circle().foregroundColor(Color.clear).frame(width: 40, height: 40)
                    })
                }.padding(.top,50)
                
                
                VStack(spacing: 20){
                    VStack(){
                        
                        TextField("Poll Question",text: $question).multilineTextAlignment(.center).font(.system(size: 25, weight: .bold))
                        Rectangle().frame(width: UIScreen.main.bounds.width-50, height: 2).foregroundColor(Color.gray)
                        
                    }.padding(10)
                    
                    VStack(alignment: .leading){
                       
                        VStack(spacing: 15){
                            ForEach(0..<options.count, id: \.self){ index in
                                HStack{
                                    CustomTextField(text: $options[index].choice, placeholder: "Option \(index + 1)")
                                    if options.count > 1 {
                                        Button {
                                            withAnimation{
                                                let _ = options.remove(at: index)
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                        }
                                    }
                                  

                                }
                            }
                        }
                     
                      
                      
                    }.padding(.horizontal)
                    
                    if options.count < 5 {
                        HStack{
                            Spacer()
                            Button(action:{
                                    withAnimation{
                                        options.append(PollOptionModel())
                                    }
                                
                            },label:{
                                Text("Add Option").padding(10).background(Color("AccentColor") ).foregroundColor(FOREGROUNDCOLOR).cornerRadius(12)
                            })
                            Spacer()
                        }
                    }
                  
                
                     
                    
                    Button(action:{
                        createPollVM.createPoll(creatorID: userVM.user?.id ?? " ", pollOptions: options, groupID: groupVM.group.id ?? " ", question: question, usersVisibleToID: groupVM.group.usersID ?? [])
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Create Poll").foregroundColor(FOREGROUNDCOLOR)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(ableToCreatePoll() ? Color("AccentColor") : Color.gray).cornerRadius(15)
                    }).padding().disabled(!ableToCreatePoll())
                  
                    Spacer()

                }
                
                
                
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}





