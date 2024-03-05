//
//  Order.swift
//  CupcakeCorner
//
//  Created by Jeong Deokho on 2024/02/05.
//

import Foundation

@Observable
class Order: Codable {
    static let types = ["바닐라", "딸기", "초콜릿", "레인보우"]
    
    var type: String = "바닐라"
    var quantity = 0 {
        didSet {
            guard quantity == 0 else { return }
            specialRequestEnabled = false
        }
    }
    
    var specialRequestEnabled = false {
        didSet {
            guard specialRequestEnabled == false else { return }
            extraProsting = false
            addSprinkles = false
        }
    }
    var extraProsting = false
    var addSprinkles = false
    
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraProsting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _city = "city"
        case _streetAddress = "streetAddress"
        case _zip = "zip"
    }
    
}
