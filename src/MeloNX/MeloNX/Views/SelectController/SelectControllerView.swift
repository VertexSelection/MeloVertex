//
//  SelectControllerView.swift
//  MeloNX
//
//  Created by Stossy11 on 9/12/2024.
//

import SwiftUI

struct SelectControllerView: View {
    
    @Binding var controllersList: [Controller]
    @Binding var currentControllers: [Controller]
    
    @Binding var onscreencontroller: Controller
    
    var body: some View {
        List {
            
            Section {
                ForEach(controllersList, id: \.self) { controller in
                    controllerRow(for: controller)
                }
            } footer: {
                Text("If no controllers are selected, the keyboard will be used.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
    
    private func controllerRow(for controller: Controller) -> some View {
        HStack {
            Button(controller.name) {
                toggleController(controller)
            }
            Spacer()
            if currentControllers.contains(where: { $0.id == controller.id }) {
                Image(systemName: "checkmark.circle.fill")
            }
        }
    }
    
    private func toggleController(_ controller: Controller) {
        if currentControllers.contains(where: { $0.id == controller.id }) {
            currentControllers.removeAll(where: { $0.id == controller.id })
        } else {
            currentControllers.append(controller)
        }
    }
    
}
