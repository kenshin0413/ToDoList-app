//
//  Model.swift
//  ToDoList
//
//  Created by miyamotokenshin on R 7/09/21.
//

import Foundation

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var idOn: Bool = false
}
