//
//  NoAccountComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct NoAccountComponentView: View {
    let onCreate: () -> Void
    var body: some View {
        VStack {
            Text("No account found. Create one to unlock more features.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Create Account", action: onCreate)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    //NoAccountComponentView(onCreate: <#() -> Void#>)
}
