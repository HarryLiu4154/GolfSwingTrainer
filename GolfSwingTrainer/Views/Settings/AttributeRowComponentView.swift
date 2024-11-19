//
//  AttributeRowComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import SwiftUI

struct AttributeRowComponentView: View {
    let title: String
    @State var value: String
    let isEditing: Bool
    let onCommit: (String) -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            if isEditing {
                TextField("Enter \(title)", text: $value, onCommit: {
                    onCommit(value)
                })
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 150)
            } else {
                Text(value)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    AttributeRowComponentView(
            title: "Height",
            value: "180",
            isEditing: true,
            onCommit: { newValue in
                print("New value: \(newValue)")
            }
        )
}
