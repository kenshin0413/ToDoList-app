//
//  Model.swift
//  ToDoList
//
//  Created by miyamotokenshin on R 7/09/21.
//

import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
    var dueDate: Date? = nil
}
