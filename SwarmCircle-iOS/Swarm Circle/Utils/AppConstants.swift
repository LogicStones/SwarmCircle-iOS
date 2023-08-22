//
//  AppConstants.swift
//  Swarm Circle
//
//  Created by Macbook on 02/08/2022.
//

import Foundation

class AppConstants{
    
//    static let baseURL = "https://beta.softwareistic.com/swarmcircleapp/" // Devs
    
  //  static let baseURL = "https://swarmcircle.softwareistic.com/" // UAT
    
    static let baseURL = "https://swarm-circle.logicstones.com/" //"https://swarmcircle.com/" // Production
    
//    static let baseImageURL = "https://beta.softwareistic.com/swarmcircleapp" // Old
    
//    static let baseImageURL = "https://swarmcircle.softwareistic.com" // UAT
    
    static let baseImageURL = "https://swarmcircle.com/" // Production
    
//    static let passwordRegex = "^.*(?=.{6,})(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*\\d)|(?=.*[!#$%&?]).*$"
    static let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"

    static let emailRegex = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" + "\\@" + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" + "(" + "\\." + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+"
    
    static let specialCharacterRegex = ".*[^A-Za-z0-9].*"
    
    static let serverURL = "216.108.238.109" // testing url for signal R
    static let serverPort = "7927" // testing port for signal R

}

