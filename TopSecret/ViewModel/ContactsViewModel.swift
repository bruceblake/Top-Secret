//
//  ContactsViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/27/23.
//

//import Foundation
//import Contacts
//import os
//
//class ContactsViewModel : ObservableObject {
//    @Published var contacts : [CNContact] = []
//    @Published var error : Error? = nil
//
//    func fetch() {
//           os_log("Fetching contacts")
//
//               let store = CNContactStore()
//
//               store.requestAccess(for: .contacts) { granted, error in
//                   if let error = error {
//                       print("Failed to request access")
//                       return
//                   }
//
//                   if granted {
//                       do {
//                       let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
//                                          CNContactMiddleNameKey as CNKeyDescriptor,
//                                          CNContactFamilyNameKey as CNKeyDescriptor,
//                                          CNContactImageDataAvailableKey as CNKeyDescriptor,
//                                          CNContactImageDataKey as CNKeyDescriptor,
//                                        ]
//                       os_log("Fetching contacts: now")
//                       let containerId = store.defaultContainerIdentifier()
//                       let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
//                       let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
//                       os_log("Fetching contacts: succesfull with count = %d", contacts.count)
//                       self.contacts = contacts
//                   }catch {
//                       os_log("Fetching contacts: failed with %@", error.localizedDescription)
//                       self.error = error
//                   }
//
//               }else{
//                   print("access denied")
//               }
//           }
//       }
//}
//
//extension CNContact: Identifiable {
//    var name: String {
//        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
//    }
//}
