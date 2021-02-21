//
//  FormViewModel.swift
//  iCombine
//
//  Created by Артём Мошнин on 21/2/21.
//

import Foundation
import Combine

final class FormViewModel: ObservableObject {
    // MARK: - Variables
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var inlineErrorForPassword = ""
    
    @Published var isValid = false
    
    // MARK: - Constants
    private var cancellables = Set<AnyCancellable>()
    private static let predicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{6,}$")
    
    // MARK: - Initializer
    init() {
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                switch passwordStatus {
                case .empty:
                    return "Password cannot be empty!"
                case .notStrongEnough:
                    return "Password is too weak!"
                case .notMatchPasswords:
                    return "Passwords do not match!"
                case .valid:
                    return ""
                }
            }
            .assign(to: \.inlineErrorForPassword, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Validator Publishers
    // Form
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isUsernameValidPublisher, isPasswordValidPublisher)
            .map { $0 && $1 == .valid }
            .eraseToAnyPublisher()
    }
    
    // Username
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $username
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.count >= 3 }
            .eraseToAnyPublisher()
    }
    
    // Password
    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, isPasswordStrongPublisher, doPasswordsMatchPublisher)
            .map {
                if $0 { return PasswordStatus.empty }
                else if !$1 { return PasswordStatus.notStrongEnough }
                else if !$2 { return PasswordStatus.notMatchPasswords }
                return PasswordStatus.valid
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    private var doPasswordsMatchPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main).removeDuplicates()
            .map { Self.predicate.evaluate(with: $0) }
            .eraseToAnyPublisher()
    }
}
