//
//  AccountActionButtonsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct AccountActionButtonsView: View {
    let isEditing: Bool
    let onEdit: () -> Void
    let onCancel: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            if isEditing {
                Button("Save Changes", action: onSave)
                    .buttonStyle(.borderedProminent)
                
                Button("Cancel", action: onCancel)
                    .foregroundColor(.red)
            } else {
                Button("Edit Account", action: onEdit)
                    .buttonStyle(.borderedProminent)
                
                Button("Delete Account", action: onDelete)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    //AccountActionButtonsView()
}
