//
//  PostModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//
import Foundation

struct Post: Identifiable {
    let id: String
    let text: String
    let timestamp: Date // Time when the post was created
    let duration: String? // Duration of the associated swing session
    let userName: String // User's name
    let profilePictureURL: String? // URL to the user's profile picture
}
extension Post{
    //test user
    static var MOCK_POST = Post(
        id: "",
        text: "Fake post",
        timestamp: Date(),
        duration: "",
        userName: "FakeUserName",
        profilePictureURL: "")
}
