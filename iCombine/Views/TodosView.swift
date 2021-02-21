//
//  TodosView.swift
//  iCombine
//
//  Created by Артём Мошнин on 21/2/21.
//

import SwiftUI
import CoreData

struct TodosView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: false)])
    private var tasks: FetchedResults<Task>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    self.taskItem(task: task)
                } //: FOR_EACH
                .onDelete(perform: self.deleteTask)
            } //: LIST
            .navigationTitle("Todo List")
            .navigationBarItems(trailing: self.navigationLeadingButton())
        } //: NAVIGATION_VIEW
    }
    
    // MARK: - UI Components
    private func taskItem(task: FetchedResults<Task>.Element) -> some View {
        return Text(task.title ?? "Untitled")
            .onTapGesture { self.updateTask(task) }
    }
    
    private func navigationLeadingButton() -> some View {
        return Button("Add task") { addTask() }
    }
    
    // MARK: - Functions
    private func addTask() {
        withAnimation {
            let newTask = Task(context: viewContext)
            newTask.title = "New Task \(Date())"
            newTask.date = Date()
            
            self.saveContext()
        }
    }
    
    private func updateTask(_ task: FetchedResults<Task>.Element) {
        withAnimation {
            task.title = "Updated"
            saveContext()
        }
    }
    
    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            self.saveContext()
        }
    }
    
    private func saveContext() {
        do { try self.viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error \(error)")
        }
    }
}


struct TodosView_Preview: PreviewProvider {
    static var previews: some View {
        TodosView()
    }
}
