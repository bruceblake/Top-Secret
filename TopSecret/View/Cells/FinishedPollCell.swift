import Firebase
import SwiftUI
import Foundation

struct FinishedPollCell : View {
    var poll : PollModel
    var body: some View {
        VStack{
            HStack{
                Text(poll.question ?? "")
            }
            Divider()
            VStack{
                HStack{
                    Button(action:{
                        
                    },label:{
                        Text(poll.pollOptions[0].choice ?? "")
                    })
                    
                    
                    Button(action:{
                        
                    },label:{
                        Text(poll.pollOptions[1].choice ?? "")
                    })
                }
                Divider()
                HStack{
                    Button(action:{
                        
                    },label:{
                        Text(poll.pollOptions[2].choice ?? "")
                    })
                    
                    
                    Button(action:{
                        
                    },label:{
                        Text(poll.pollOptions[3].choice ?? "")
                    })
                }
            }
        }.background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
    }
}

