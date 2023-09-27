//
//  GroupUsersProfilePictureCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 12/9/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupUsersProfilePictureCell: View {
    var image : String = ""
    var body: some View {
        WebImage(url: URL(string: image)).resizable()
            .scaledToFill()
            .frame(width: 30, height:30).clipShape(Circle())
    }
}

struct GroupUsersProfilePictureCell_Previews: PreviewProvider {
    static var previews: some View {
        GroupUsersProfilePictureCell()
    }
}
