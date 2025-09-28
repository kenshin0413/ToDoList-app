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
    var priority: Priority = .middle
    var memo: String = ""
}

enum Priority: String, Codable, CaseIterable, Comparable {
    case high = "高"
    case middle = "中"
    case low = "低"
    
    var priorityOrder: Int {
        switch self {
        case .high: return 0
        case .middle: return 1
        case .low: return 2
        }
    }
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.priorityOrder < rhs.priorityOrder
        }
}
enum SortOption: String, CaseIterable {
    case priority = "優先順"
    case dueDate = "期限順"
}
