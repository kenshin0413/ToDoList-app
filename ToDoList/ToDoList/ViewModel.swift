//
//  ViewModel.swift
//  ToDoList
//
//  Created by miyamotokenshin on R 7/09/21.
//

import Foundation
import SwiftUI

class ToDoListViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var tasks: [Task] = []
    @Published var newTask = ""
    @Published var deleteOffset: IndexSet?
    @Published var showDeleteAlert = false
    @Published var searchText = ""
    @Published var filteredTasks: [Task] = []
    @Published var selectedPriority: Priority = .middle
    @Published var sortOption: SortOption = .priority
    var sortedTasks: [Task] {
        switch sortOption {
        case .priority:
            return tasks.sorted(by: { (a: Task, b: Task) in
                a.priority.priorityOrder < b.priority.priorityOrder })
        case .dueDate:
            return tasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        }
    }
    
    func searchTasks() {
        if searchText.isEmpty {
            filteredTasks = sortedTasks
        } else {
            filteredTasks = sortedTasks.filter { task in
                // 大文字小文字を区別せずに検索文字列を含むかどうか判定できる
                task.title.localizedCaseInsensitiveContains(searchText)
            }
            switch sortOption {
            case .priority:
                 filteredTasks.sorted(by: { $0.priority.priorityOrder < $1.priority.priorityOrder })
            case .dueDate:
                 filteredTasks.sorted(by: { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) })
            }
        }
    }
    
    private let taskkey = "tasks"
    
    init() {
        loadTasks()
        filteredTasks = sortedTasks
    }
    
    func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: taskkey)
        }
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: taskkey),
           let saveTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = saveTasks
        }
    }
    
    func addTask(dueDate: Date? = nil) {
        if !newTask.isEmpty {
            let task = Task(title: newTask, dueDate: dueDate, priority: selectedPriority)
            tasks.append(task)
            newTask = ""
            saveTasks()
            sortedTasks
            if let dueDate = dueDate {
                NotificationManager.shared.scheduleNotification(id: task.id.uuidString, title: "タスクの期限です。", body: task.title, date: dueDate)
            }
            searchTasks()
        }
    }
    
    func deleteTask(at offset: IndexSet) {
        
        let deletingTasks = offset.map { filteredTasks[$0] }
        
        for task in deletingTasks {
            NotificationManager.shared.cancelNotification(id: task.id.uuidString)
        }
        
        for task in deletingTasks {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks.remove(at: index)
            }
        }
        saveTasks()
        searchTasks()
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
            saveTasks()
            searchTasks()
        }
    }
    
    func moveTasks(from o: IndexSet, to n: Int) {
        tasks.move(fromOffsets: o, toOffset: n)
        saveTasks()
        searchTasks()
    }
    
    func backgroundColor(for priority: Priority) -> Color {
        switch priority {
        case .high: return Color.pink.opacity(0.9)
        case .middle: return Color.green.opacity(0.9)
        case .low: return Color.yellow.opacity(0.7)
        }
    }
}


