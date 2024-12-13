//
//  OutgoingRequestRowComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct OutgoingRequestRowComponentView: View {
    let outgoing: String
    var body: some View {
        HStack {
            Text(outgoing)
            Spacer()
            Text("Pending")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    OutgoingRequestRowComponentView(outgoing: "")
}
