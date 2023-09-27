//
//  PostCell.swift
//  TopSecret
//
//  Created by nathan frenzel on 6/12/21.
//

import SwiftUI

struct PostCell: View {
    let post: PostModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(post.groupName)
                    .font(.system(size: 15, weight: .semibold))
                
                Text(" - " + post.fullName)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            
            Text(post.caption)
        }
    }
}

