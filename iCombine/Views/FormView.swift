//
//  FormView.swift
//  iCombine
//
//  Created by Артём Мошнин on 21/2/21.
//

import SwiftUI

struct FormView: View {
    @StateObject private var formViewModel = FormViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("USERNAME")) {
                        TextField("Username", text: $formViewModel.username)
                            .autocapitalization(.none)
                    } //: SECTION
                    
                    Section(header: Text("PASSWORD"),
                            footer: Text(formViewModel.inlineErrorPassword).foregroundColor(.red)) {
                        SecureField("Password", text: $formViewModel.password)
                        SecureField("Repeat password", text: $formViewModel.passwordAgain)
                    } //: SECTION
                    
                    Section(header: Text("ABOUT ME"),
                            footer: Text(formViewModel.inlineErrorDescription).foregroundColor(.red)) {
                        TextField("About me", text: $formViewModel.description)
                    }
                } //: FORM
                
                Button(action: {}, label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 60)
                        .overlay( Text("Continue").foregroundColor(.white) )
                }) //: BUTTON
                .padding()
                .disabled(!formViewModel.isValid)
            } //: VSTACK
            .navigationTitle("Registration")
        } //: NAVIGATION VIEW
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
