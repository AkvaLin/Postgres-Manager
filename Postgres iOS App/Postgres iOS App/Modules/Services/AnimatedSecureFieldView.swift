//
//  AnimatedSecureFieldView.swift
//  Postgres iOS App
//
//  Created by Никита Пивоваров on 10.05.2023.
//

import SwiftUI

struct AnimatedSecureTextField: View {
    static let eyeIcon: String = "eye"
    static let eyeSlahIcon: String = eyeIcon + ".slash"
    
    @Binding var text: String
    @State var isSecure: Bool = true
    var titleKey: String
    
    var body: some View {
        ZStack(alignment: .trailing){
            if isSecure{
                SecureField(titleKey, text: $text)
            }else{
                TextField(titleKey, text: $text)
            }
            
            Button(action: {
                isSecure = !isSecure
            }, label: {
                Image(systemName: !isSecure ? AnimatedSecureTextField.eyeSlahIcon : AnimatedSecureTextField.eyeIcon)
                    .foregroundColor(.gray)
                    .padding()
            })
            
        }
        .animation(.easeInOut(duration: 0.3), value: isSecure)
    }
}
