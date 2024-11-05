//
//  UserProfileView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import SwiftUI

struct UserProfileView: View {
    var body: some View {
        List{
            Section{
                HStack{
                    Text("TW")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4){
                        Text("Tiger Woods")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                        Text("admin@admin.com")
                            .font(.footnote)
                            .accentColor(.gray)
                        
                    }
                    
                }
            }
            Section("General"){
                HStack{
                    SettingRowComponentView(imageName: "gear", title: String(localized: "Version"), tintColor: Color(.systemGray))
                    
                    Spacer()
                    
                    Text("v1.0.0" + " - " + String(localized: "Alpha")).foregroundStyle(.gray)
                }
            }
            Section("Account"){
                Button{
                    print("Signing user out...")
                }label: {
                    SettingRowComponentView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: Color.yellow)
                    
                }
                Button{
                    print("Deleting user account...")
                }label: {
                    SettingRowComponentView(imageName: "trash", title: "DELETE ACCOUNT", tintColor: Color.red)
                    
                }
                
            }
        }
    }
}

#Preview {
    UserProfileView()
}
