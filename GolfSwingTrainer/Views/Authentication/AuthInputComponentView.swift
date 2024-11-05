//
//  AuthInputView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-30.
// 

import SwiftUI

struct AuthInputComponentView: View {
    @Binding var text: String
    let title: String
    let placeHolder: String
    var isSecureField = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text(title).foregroundStyle(Color(.darkGray)).fontWeight(.semibold).font(.footnote)
            
            if isSecureField{
                SecureField(placeHolder, text: $text).font(.system(size: 14))
            }else{
                TextField(placeHolder, text: $text).font(.system(size: 14))
            }
            Divider()
        }
    }
}

#Preview {
    
    AuthInputComponentView(text: .constant(""), title: "Email Address", placeHolder: "Admin@Admin.com")
}
