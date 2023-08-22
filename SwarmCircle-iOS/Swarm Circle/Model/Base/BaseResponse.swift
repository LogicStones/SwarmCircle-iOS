//
//  BaseResponse.swift
//  Swarm Circle
//
//  Created by Macbook on 03/08/2022.
//

import Foundation

struct BaseResponse<ResponseData: Codable> : Codable {
    let statusCode : Int?
    let message : String?
    let statusMessage : String?
    let data : ResponseData?
    let recordCount : Int?
    let isSuccess : Bool?
}
