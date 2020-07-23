//
//  User.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation

struct User: Decodable, Identifiable {
    var id: Int
    var name: String
    var username: String
    var email: String
}

struct Address: Decodable {
    var street: String
    var suite: String
    var city: String
    var zipcode: String
    var geo: Geo
}

struct Geo: Decodable {
    var lat: String
    var lng: String
}

struct Company: Decodable {
    var name: String
    var catchPhrase: String
    var bs: String
}
