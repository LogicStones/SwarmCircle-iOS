//
//  PreferencesManager.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 10/08/2022.
//

import Foundation

class PreferencesManager {
    
    // MARK: - Keys
    static let userData = "userData"
    static let userDetailData = "userDetailData"
    static let loginState = "loginState"
    static let discoverableState = "discoverableState"
    static let walletInfo = "walletInfo"
    static let FCMToken = "FCMToken"
    static let initial50Posts = "initial50Posts"
    static let reportType = "reportType"
    static let country = "country"
    static let profileEditedState = "profileEditedState"
    static let callState = "callState"
    static let lockState = "lockState"
    static let applicationTerminationState = "applicationTerminationState"
    
    // MARK: - Save User Login State
    static func saveLoginState(isLogin: Bool) {
        UserDefaults.standard.set(isLogin, forKey: loginState)
    }
    
    // MARK: - Check if User is Logged In
    static func isUserLoggedIn() -> Bool {
        UserDefaults.standard.value(forKey: loginState) as? Bool ?? false
    }
    
    // MARK: - Save Discoverable State
    static func saveDiscoverableState(state: Bool) {
        UserDefaults.standard.set(state, forKey: discoverableState)
    }
    
    // MARK: - Get Discoverable State
    static func getDiscoverableState() -> Bool {
        return UserDefaults.standard.value(forKey: discoverableState) as? Bool ?? false
    }

    // MARK: - Inverse Discoverable State
    static func changeDiscoverableState() {
        
        if let currentState = UserDefaults.standard.value(forKey: discoverableState) as? Bool {
            UserDefaults.standard.set(!currentState, forKey: discoverableState)
        }
    }
    
    // MARK: - Save User Model
    static func saveUserModel(user: UserDM?) {
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode User object
            let data = try encoder.encode(user)

//            UserDefaults.standard.removeObject(forKey: userData)
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: userData)

        } catch {
            print("Unable to Encode User (\(error))")
        }
    }
    
    // MARK: - Get User Model
    static func getUserModel() -> UserDM? {
        
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: userData) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let user = try decoder.decode(UserDM.self, from: data)
                return user

            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    // MARK: - Save User Details Model
    static func saveUserDetailsModel(user: UserDetailDM?) {
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode User object
            let data = try encoder.encode(user)

//            UserDefaults.standard.removeObject(forKey: userData)
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: userDetailData)

        } catch {
            print("Unable to Encode User (\(error))")
        }
    }
    
    // MARK: - Get User Model
    static func getUserDetailModel() -> UserDetailDM? {
        
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: userDetailData) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let user = try decoder.decode(UserDetailDM.self, from: data)
                return user

            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    // MARK: - Save User Wallet Detail
    static func saveWalletDetail(info: WalletDetailDM?) {
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode User object
            let data = try encoder.encode(info)

            // Write/Set Data
            UserDefaults.standard.removeObject(forKey: walletInfo)
            
            UserDefaults.standard.set(data, forKey: walletInfo)

        } catch {
            print("Unable to Encode User (\(error))")
        }
    }
    
    // MARK: - Get User Wallet Detail
    static func getWalletDetail() -> WalletDetailDM? {
        
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: walletInfo) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let walletInfo = try decoder.decode(WalletDetailDM.self, from: data)
                return walletInfo

            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    // MARK: - Save firebase Token
    static func saveFirebaseToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: FCMToken)
    }
    
    // MARK: - Get firebase Token
    static func getFirebaseToken() -> String {
        return UserDefaults.standard.value(forKey: FCMToken) as? String ?? "No Token Found"
    }

    // MARK: - Save Initial 50 Posts
    static func saveInitial50Posts(list: [PostDM]) {
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode User object
            let data = try encoder.encode(list)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: initial50Posts)

        } catch {
            print("Unable to Encode User (\(error))")
        }
    }
    
    // MARK: - Get Initial 50 Posts
    static func getInitial50Feeds() -> [PostDM]? {
        
        // Read/Get Data
        if let dataList = UserDefaults.standard.data(forKey: initial50Posts) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let list = try decoder.decode([PostDM].self, from: dataList)
                return list

            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    // MARK: - Save Report Type List
    static func saveReportTypeList(list: [ReportTypeDM]?) {
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode User object
            let data = try encoder.encode(list)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: reportType)

        } catch {
            print("Unable to Encode User (\(error))")
        }
    }
    
    // MARK: - Get Report Type List
    static func getReportTypeList() -> [ReportTypeDM]? {
        
        // Read/Get Data
        if let dataList = UserDefaults.standard.data(forKey: reportType) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let list = try decoder.decode([ReportTypeDM].self, from: dataList)
                return list

            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    // MARK: - Save Country List
    static func saveCountryList(list: [CountryDM]?) {
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode User object
            let data = try encoder.encode(list)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: country)

        } catch {
            print("Unable to Encode User (\(error))")
        }
    }
    
    // MARK: - Get Country List
    static func getCountryList() -> [CountryDM]? {
        
        // Read/Get Data
        if let dataList = UserDefaults.standard.data(forKey: country) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let list = try decoder.decode([CountryDM].self, from: dataList)
                return list

            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    // MARK: - Save Call State
    static func saveCallState(isCallActivated: Bool) {
        UserDefaults.standard.set(isCallActivated, forKey: callState)
    }
    
    // MARK: - Get Call State
    static func isCallActive() -> Bool {
        let state = UserDefaults.standard.value(forKey: callState) as? Bool ?? false
//        UserDefaults.standard.removeObject(forKey: callState)
        return state
    }
    
    static func isDeviceLocked() -> Bool {
        let state = UserDefaults.standard.value(forKey: lockState) as? Bool ?? false
        UserDefaults.standard.removeObject(forKey: lockState)
        return state
    }
    
    static func changeDeviceLockState(_ state: Bool){
        UserDefaults.standard.set(state, forKey: lockState)
    }
//    
//    static func wasApplicationTerminated() -> Bool {
//        let state = UserDefaults.standard.value(forKey: applicationTerminationState) as? Bool ?? false
//        UserDefaults.standard.removeObject(forKey: applicationTerminationState)
//        return state
//    }
}
