//
//  ChatView.swift
//
//
//  Created by Moi Gutierrez on 10/14/23.
//

import SwiftUI

import Firebase
import ExyteChat
import CloudyLogs

public struct ChatView: View {
    
    public struct ChatUser: Hashable, Identifiable {
        public var id: String
        public var name: String
        public var avatarURL: URL?
        public var isCurrentUser: Bool
    }
    
    public class ChatViewModel: ObservableObject {
        @Published var messages: [ExyteChat.Message] = []
        @Published var isUserInfoSet: Bool = false // To check if user has provided info
        
        private var chatRoomId: String
        private var db = Firestore.firestore()
        
        var currentUser: ExyteChat.User? = nil
        
        public init(chatRoomId: String) {
            self.chatRoomId = chatRoomId
        }
        
        func fetchMessages() {
            db.collection("chatRooms")
                .document(chatRoomId)
                .collection("messages")
                .order(by: "timestamp")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async { // Ensure updates are on the main thread
                        guard let documents = querySnapshot?.documents else {
                            print("Error fetching messages: \(error?.localizedDescription ?? "Unknown Error")")
                            return
                        }
                        self.messages = documents.compactMap { (queryDocumentSnapshot) -> ExyteChat.Message? in
                            let data = queryDocumentSnapshot.data()
                            guard let id = data["id"] as? String,
                                  let text = data["text"] as? String,
                                  let userId = data["user.id"] as? String,
                                  let userName = data["user.name"] as? String
                            else {
                                return nil
                            }
                            return ExyteChat.Message(
                                id: id,
                                user: ExyteChat.User(
                                    id: userId,
                                    name: userName,
                                    avatarURL: nil,
                                    isCurrentUser: userId == self.currentUser?.id
                                ),
                                text: text
                            )
                        }
                    }
                }
        }
        
        func send(draft: ExyteChat.DraftMessage) {
            guard let currentUser = currentUser else { return }
            
            let newMessage = ExyteChat.Message(
                id: UUID().uuidString,
                user: currentUser,
                text: draft.text
            )
            
            let chatRoomsCollection = db.collection("chatRooms")
            
            chatRoomsCollection
                .document(chatRoomId)
                .setData([
                    "user.id": newMessage.user.id,
                    "user.name": newMessage.user.name,
                ])
            
            chatRoomsCollection
                .document(chatRoomId)
                .collection("messages")
                .addDocument(data: [
                    "user.id": newMessage.user.id,
                    "user.name": newMessage.user.name,
                    "id": newMessage.id,
                    "text": newMessage.text,
                    "timestamp": FieldValue.serverTimestamp()
                ])
            
            chatRoomsCollection
                .document(chatRoomId)
                .updateData([
                    "latestMessage.text": draft.text
                ])
        }
        
        func setUserInfo(name: String, email: String) {
            let userID = UUID().uuidString
            currentUser = ExyteChat.User(id: userID, name: name, avatarURL: nil, isCurrentUser: true)
            isUserInfoSet = true
            fetchMessages()
        }
    }
    
    @ObservedObject var viewModel: ChatViewModel
    
    @State private var name: String = ""
    @State private var email: String = ""
    
    public init(chatRoomId: String) {
        viewModel = ChatViewModel(chatRoomId: chatRoomId)
    }
    
    public var body: some View {
        Group {
            if viewModel.isUserInfoSet {
                ExyteChat.ChatView(messages: viewModel.messages) { draft in
                    viewModel.send(draft: draft)
                }
            } else {
                VStack(spacing: 20) {
                    TextField("Name", text: $name)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    
                    TextField("Email", text: $email)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    
                    Button(action: {
                        viewModel.setUserInfo(name: name, email: email)
                    }, label: {
                        Text("Start Chatting")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    })
                }
                .padding()
            }
        }
    }
}


public struct RepresentativeChatsView: View {
    
    public class RepresentativeChatViewModel: ObservableObject {
        
        public struct ChatPreview: Hashable, Identifiable {
            public var id: String
            public var user: ChatView.ChatUser
            public var lastMessage: String
        }
        
        @Published var selecedChatRoomId: String? = nil
        @Published var chats: [ChatPreview] = []
        
        public var db = Firestore.firestore()
        
        public init() {
        }
        
        struct RepresentativeUser {
            var id: String
            var name: String
            
            static func defaultUser() -> RepresentativeUser {
                RepresentativeUser(id: "0", name: "Representative")
            }
        }
        
        func send(draft: ExyteChat.DraftMessage) {
            
            guard let selecedChatRoomId = selecedChatRoomId else {
                Logger.log("selecedChatRoomId is nil")
                return
            }
            
            let defaultUser = RepresentativeUser.defaultUser()
            
            let newMessage = ExyteChat.Message(
                id: UUID().uuidString,
                user: ExyteChat.User(
                    id: defaultUser.id,
                    name: defaultUser.name,
                    avatarURL: nil,
                    isCurrentUser: true  // Since you're the current user when sending a message
                ),
                text: draft.text
            )
            
            let chatRoomsCollection = db.collection("chatRooms")
            
            chatRoomsCollection
                .document(selecedChatRoomId)
                .setData([
                    "user.id": newMessage.user.id,
                    "user.name": newMessage.user.name,
                ])
            
            chatRoomsCollection
                .document(selecedChatRoomId)
                .collection("messages")
                .addDocument(data: [
                    "user.id": newMessage.user.id,
                    "user.name": newMessage.user.name,
                    "id": newMessage.id,
                    "text": newMessage.text,
                    "timestamp": FieldValue.serverTimestamp()
                ])
            
            chatRoomsCollection
                .document(selecedChatRoomId)
                .updateData([
                    "latestMessage.text": draft.text
                ])
        }
    }
    
    @ObservedObject var viewModel = RepresentativeChatViewModel()
    
    public var body: some View {
        NavigationStack {
            List(viewModel.chats) { chat in
                NavigationLink(destination: ChatView(chatRoomId: chat.id)) {
                    HStack {
                        Text(chat.user.name)
                        Spacer()
                        Text(chat.lastMessage)
                    }
                }
            }
            .navigationTitle("Customer Chats")
            .refreshable {
                fetchChats()
            }
            .onAppear {
                fetchChats()
            }
        }
    }
    
    public init() {
        
    }
    
    func fetchChats() {
        viewModel.db.collection("chatRooms")
            .limit(to: 50)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching chat rooms: \(error?.localizedDescription ?? "Unknown Error")")
                    return
                }
                
                DispatchQueue.main.async { // Ensure updates are on the main thread
                    self.viewModel.chats = documents.compactMap { document in
                        let data = document.data()
                        
                        guard
                            let userId = data["user.id"] as? String,
                            let userName = data["user.name"] as? String,
                            let latestMessageDict = data["latestMessage"] as? [String: Any],
                            let latestMessageText = latestMessageDict["text"] as? String
                        else {
                            return nil
                        }
                        
                        return RepresentativeChatViewModel.ChatPreview(id: document.documentID, user: ChatView.ChatUser(id: userId, name: userName, avatarURL: nil, isCurrentUser: false), lastMessage: latestMessageText)
                    }
                }
            }
    }

}
