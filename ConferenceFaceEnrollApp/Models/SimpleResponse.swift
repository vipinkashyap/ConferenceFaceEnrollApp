//
//  SimpleResponse.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//


    struct SimpleResponse: Decodable {
        let id: Int
        let username: String?
        let note: String?
    }