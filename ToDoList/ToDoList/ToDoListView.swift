//
//  ToDoListView.swift
//  ToDoList
//
//  Created by miyamotokenshin on R 7/09/21.
//

import SwiftUI

struct ToDoListView: View {
    @StateObject var viewModel = ToDoListViewModel()
    @State var selectedDate: Date = Date()
    var body: some View {
        NavigationStack {
            VStack(spacing: -10) {
                HStack {
                    TextField("タスクを検索", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("検索") {
                        viewModel.searchTasks()
                    }
                }
                .padding()
                HStack {
                    TextField("新しいタスクを入力", text: $viewModel.newTask)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 150)
                    
                    Button("追加") {
                        viewModel.addTask(dueDate: selectedDate)
                        selectedDate = Date()
                    }
                }
                .padding()
                
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        HStack {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            VStack(alignment: .leading) {
                                Text("\(task.title)")
                                    .strikethrough(task.isDone)
                                    .foregroundColor(task.isDone ? .gray : .primary)
                                
                                if let due = task.dueDate {
                                    // 今日の日付を取得できる
                                    let today = Calendar.current.startOfDay(for: Date())
                                    let dueDay = Calendar.current.startOfDay(for: due)
                                    // 日付省略形、時刻表記なし
                                    Text("期限: \(due.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(dueDay < today ? .red : today == dueDay ? .blue : .secondary)
                                }
                            }
                        }
                        .onTapGesture {
                            viewModel.toggleTask(task)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteOffset = indexSet
                        viewModel.showDeleteAlert = true
                    }
                    .onMove { indices, newOffset in
                        viewModel.moveTasks(from: indices, to: newOffset)
                    }
                }
            }
            .navigationTitle("ToDoList")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "完了" : "編集") {
                        withAnimation {
                            viewModel.isEditing.toggle()
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(viewModel.isEditing ? EditMode.active : EditMode.inactive))
            .alert("削除しますか？", isPresented: $viewModel.showDeleteAlert, presenting: viewModel.deleteOffset) { offset in
                Button("削除", role: .destructive) {
                    viewModel.deleteTask(at: offset)
                    viewModel.deleteOffset = nil
                }
                Button("キャンセル", role: .cancel) {
                    viewModel.deleteOffset = nil
                }
            } message: { _ in
                Text("選択したタスクを削除します。")
            }
            .onAppear {
                NotificationManager.shared.requestPermission()
            }
        }
    }
}

#Preview {
    ToDoListView()
}
