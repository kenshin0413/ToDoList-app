//
//  ContentView.swift
//  ToDoList
//
//  Created by miyamotokenshin on R 7/09/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ToDoListViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("新しいタスクを入力", text: $viewModel.newTask)
                        .textFieldStyle(.roundedBorder)
                    Button("追加") {
                        viewModel.addTask()
                    }
                }
                .padding()
                
                List {
                    ForEach(viewModel.tasks) { task in
                        Text("\(task.title)")
                    }
                    .onDelete { Indexset in
                        viewModel.deleteOffset = Indexset
                        viewModel.showDeleteAlert = true
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
        }
    }
}

#Preview {
    ContentView()
}
