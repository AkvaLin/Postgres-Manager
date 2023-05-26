//
//  iOSCheckboxToggleStyle.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 14.05.2023.
//

import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                configuration.label
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
        })
    }
}
