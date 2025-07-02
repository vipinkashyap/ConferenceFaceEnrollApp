//
//  APIResponse.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//


    struct APIResponse: Decodable {
        let status: Bool
        let message: String
        let face_id: String?
    }