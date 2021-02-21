//
//  ContentView.swift
//  iCombine
//
//  Created by Артём Мошнин on 20/2/21.
//

import SwiftUI

// MARK: - Decodable
struct User: Decodable, Identifiable {
    let id: Int
    let name: String
}

// MARK: - ViewModels
import Combine
final class ViewModel: ObservableObject {
    @Published var time = ""
    @Published var users = [User]()
    private var cancellables = Set<AnyCancellable>()
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
    
    init() {
        self.setupPublishers()
        self.setupDataTaskPublisher()
    }
    
    private func setupPublishers() {
        setupTimerPublisher()
    }
    
    private func setupDataTaskPublisher() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data: Data, response: URLResponse) -> Data  in
                guard let httpResponse = response as? HTTPURLResponse,  httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { (_) in } receiveValue: { (users) in
                print(users)
                self.users = users
            }
            .store(in: &cancellables)
    }
    
    private func setupTimerPublisher() {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: RunLoop.main)
            .map { self.formatter.string(from: $0) }
            .assign(to: \.time, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - Views
struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.time)
                .padding()
            List {
                ForEach(0..<viewModel.users.count, id: \.self) { index in
                    Text(viewModel.users[index].name)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
