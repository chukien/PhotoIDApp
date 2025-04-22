//
//  EnumFile.swift
//  PhotoIDApp
//
//  Created by QRVN on 22/4/25.
//

enum TypeImage {
    case Person
    case Animal
    case Plant
    case Other
    
    var title: String {
        switch self {
        case .Person:
            return "Người"
        case .Animal:
            return "Động vật"
        case .Plant:
            return "Thực vật"
        case .Other:
            return "Khác"
        }
    }
}
