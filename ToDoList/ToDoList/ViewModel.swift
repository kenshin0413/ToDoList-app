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
    @Published var searchText = ""
    @Published var filteredTasks: [Task] = []
    var sortedTasks: [Task] {
        let undone = tasks.filter { !$0.isDone }
        let done = tasks.filter { $0.isDone }
        return undone + done
    }
    
    func searchTasks() {
        if searchText.isEmpty {
            filteredTasks = sortedTasks
        } else {
            filteredTasks = sortedTasks.filter { task in
                // 大文字小文字を区別せずに検索文字列を含むかどうか判定できる
                task.title.localizedCaseInsensitiveContains(searchText)
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
            let task = Task(title: newTask, dueDate: dueDate)
            tasks.append(task)
            newTask = ""
            saveTasks()
            
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
        }
    }
    
    func moveTasks(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        saveTasks()
        searchTasks()
    }
}


