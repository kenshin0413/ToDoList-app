//
//  ViewModel.swift
//  ToDoList
//
//  Created by miyamotokenshin on R 7/09/21.
//

import Foundation

class ToDoListViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var tasks: [Task] = []
    @Published var newTask = ""
    @Published var deleteOffset: IndexSet?
    @Published var showDeleteAlert = false
    func addTask() {
        if !newTask.isEmpty {
            let task = Task(title: newTask)
            tasks.append(task)
            newTask = ""
        }
    }
    
    func deleteTask(at offset: IndexSet) {
        tasks.remove(atOffsets: offset)
    }
}

