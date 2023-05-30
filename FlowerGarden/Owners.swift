//
//  Owners.swift
//  FlowerGarden
//
//  Created by 김두원 on 2022/10/14.
//

import Foundation
import CoreLocation

struct Owners: Codable {
    
    let email: String
    let name: String
    let uid: String
    let store_address: String
    let store_name: String
    let store_number: String
    let x: String
    let y: String
    var distance: Double?
    
    init(email: String = "", name: String = "", store_name: String = "", store_address: String = "", store_number:String = "", uid: String = "", x: String = "", y: String = "") {
        self.email = email
        self.name = name
        self.uid = uid
        self.store_address = store_address
        self.store_name = store_name
        self.store_number = store_number
        self.x = x
        self.y = y
    }
    
}
