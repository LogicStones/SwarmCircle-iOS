//
//  API.swift
//  Swarm Circle
//
//  Created by Macbook on 03/08/2022.
//

import Moya

enum API {

    /// Login & Session Endpoints
    case loginUser(params: [String: Any])
    case registerUser(params: [String: Any])
    case verify2FA(params: [String: Any])
    case verifyForgetPassword(params: [String: Any])
    case verifyEmail(params: [String: Any])
    case forgotPassword(params: [String: Any])
    case updatePassword(params: [String: Any])
    case changePassword(params: [String: Any])
    case logout
    case deleteAccount
    
    /// Users & Friends Endpoints
    case getUsersList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    
    case sendFriendRequest(params: [String: Any])
    //    case cancelFriendRequest(params: [String: Any])
    
    case getFriendsList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    case getPendingFriendsList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    
    case getBlockFriendsList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    case blockFriend(params: [String: Any])
    case unblockFriend(params: [String: Any])
    
    //    case getPendingSendRequestsList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    
    case acceptFriendInviteRequest(params: [String: Any])
    case removeFriend(params: [String: Any])
    case rejectFriendInviteRequest(params: [String: Any])
    case getViewProfileDetails(profileIdentifier: String)
    
    // Circle
    case createCircle(memberIds: String, circleName: String, imageFile: Data?)
    case createCircleV2(memberIds: String, circleName: String, imageFile: Data, circleCategory: String, privacy: Int)
    case editCircleV2(id: Int, memberIds: String, circleName: String, imageFile: Data?, circleCategory: String, privacy: Int)
    case getCircleList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    case sendCircleRequest(params: [String: Any])
    case isDiscoverable
    case getMyCircleList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "", category: String)
    case getPendingCircleJoinList(circleIdentifier: String, pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    case acceptCircleJoinRequest(inviteId: Int)
    case rejectCircleJoinRequest(inviteId: Int)
    case getPollDurationList
    case createPoll(params: [String: Any])
    case getPendingCircleInviteList(pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    case acceptCircleInviteRequest(inviteId: Int)
    case rejectCircleInviteRequest(inviteId: Int)
    case getCircleNewPollList(circleIdentifier: String)
    case submitPollAnswer(params: [String: Any])
    case getFriendsToInviteToCircle(circleId: Int)
    case inviteFriendToCircle(status: Bool, toUserId: Int, circleId: Int)
    case getCirclePastPollList(circleIdentifier: String)
    case getCircleDetails(identifier: String)
    case getCircleMembersByCircleIdsList(params: [String: Any])
    case getCirclePollsByCircleIdsList(params: [String: Any])
    case createCircleInterection(circleIds: [Int], imageFile: Data, circleName: String, memberIds: [Int], pollIds: [Int], circleCategory: String, privacy: Int)
    case getCircleMemberList(circleId: Int, pageNumber: Int = 0, pageLimit: Int = 20, searchText: String = "")
    case deleteCirclePoll(pollId: Int)
    
    case getUserListOnPollOption(pollId: Int, optionId: Int)
    case getTrendingCircleCategoryList(search: String)
    
    // Wallet
    case getWalletBalance
    case getWalletDetail
    case cryptoWithdraw(params: [String: Any])
    case transferToFriend(params: [String: Any])
    case getMyTransactionList(fromDate: String, toDate: String, transType: String, pageNumber: Int, pageLimit: Int = 20)
    case getStripeCardList
    case getPaymentIntent
    //    case saveUserCardStripe(params: [String: Any])
    case makeDefaultCardStripe(params: [String: Any])
    case depositWithNewCardStripe(params: [String: Any])
    case depositWithDefaultCardStripe(params: [String: Any])
    case saveCheckoutOrderDetailPayPal(params: [String: Any])
    case getBankAccountList
    case withdrawAmountToBankAccount(params: [String: Any])
    case removeBankAccount(accountIdentifier: String)
    case getCountryList
    case createBankAccount(accHolderName: String, accNumber: String, routingNumber: String, city: String, country: String, line1: String, line2: String, state: String, postalCode: String, ssn: String, dob: String, documentFile: Data)
    
    // Notification
    case getNotificationList(pageNumber: Int = 0, pageLimit: Int = 20)
    //    case markAsReadNotification(notificationId: Int)
    case getNotificationCount
    
    // News Feeds
    case savePost(content: String, privacy: String, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int)
    case savePostV2(content: String, privacyType: Int, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int, friendIds: [Int], shareWithFriendIds: [Int])
    
    case getPostList(pageNumber: Int, pageLimit: Int, postId: Int, postIdentifier: String, profileIdentifier: String, hashtag: String)
    
    
    case getCommentList(pageNumber: Int, pageLimit: Int = 20, commentId: Int, postId: Int)
    case getReplyList(pageNumber: Int, pageLimit: Int = 20, replyId: Int, commentId: Int) // page limit will not be used here 
    case saveCommentReply(params: [String: Any])
    case saveLike(params: [String: Any])
    case deletePost(postId: Int)
    case deleteComment(commentId: Int)
    case deleteReply(replyId: Int)
    
    
    case editComment(params: [String: Any])
    case editReply(params: [String: Any])
    
    // Report
    case getReportTypeList
    case saveReport(params: [String: Any])
    
    // User
    case getUserDetails
    case updateProfile(userDetail: UserDetailDM)
    
    // Chat APIs
    case getChatList(searchText: String = "", pageNumber: Int = 0, pageLimit: Int = 50)
    case getChat(identifier: String = "", isCircle: Bool = false, pageNumber: Int = 0, pageLimit: Int = 50)
    case sendMessage(identifier: String = "", isCircle: Bool = false, message: String = "")
    case deleteMessages(identifier: String)
    
    // Avatar & PAst Polls
    case getPastPoll(pageNumber: Int, pageLimit: Int = 20)
    case updatePollPrivacy(pollResponseId: Int, privacy: Int)
    case removeAnsweredPollOption(pollResponseId: Int)
    case getAllAvatarPropsByGender
    case getCurrentAvatar
    case saveUserAvatar(params: [String: Any])
      
    // App Information
    case termsNConditions
    case privacyPolicy
    case contactUs(params: [String: Any])
    
    // Calling
    case startCallSession(callTo: String, callType: Int)
    case groupCallHostStop(broadcastId: String)
    case callMemberStop
    case groupCallSession(callToCircle: String, callType: Int, callMembers: String)
    case broadCastCall(callIdentifier: String, circleIdentifier: String)
    case callReceived
    
    case resendTransferCode
    
    case getPrivacySettings
    case changePrivacySetting(params: [String: Any])
    case resend2FACode(identifier: String)
    case twoFactorAuthenticationToggle(isEnabled: Bool)
    case verifyTransferCode(code: String)
    
    case getAMLKYCUploadOptions
    case verifyAMLKYC(frontImage: Data, backImage: Data?)
    
}

extension API: TargetType, AccessTokenAuthorizable{
    
    var baseURL: URL {
        guard let url = URL(string: AppConstants.baseURL) else { fatalError() }
        return url
    }
    
    var path: String {
        switch self {
            /// Login & Session Endpoints
        case .loginUser:
            return "api/ApiAccount/Login"
        case .registerUser:
            return "api/ApiAccount/Register"
        case .verify2FA:
            return "api/ApiAccount/VerifyTwoFA"
        case .verifyForgetPassword:
            return "api/ApiAccount/VerifyForgotPassword"
        case .verifyEmail:
            return "api/ApiAccount/VerifyEmail"
        case .forgotPassword:
            return "api/ApiAccount/ForgotPassword"
        case .updatePassword:
            return "api/ApiAccount/ResetPassword"
        case .changePassword:
            return "api/ApiAccount/ChangePassword"
        case .logout:
            return "api/ApiAccount/Logout"
        case .deleteAccount:
            return "api/ApiAccount/DeleteAccount"
        
            
            /// Users & Friends Endpoints
        case .getUsersList:
            return "api/ApiFriend/SearchUserList"
            
        case .sendFriendRequest:
            return "api/ApiFriend/InviteFriend"
            //        case .cancelFriendRequest:
            //            return "api/ApiFriend/CancelInviteRequest"
            
        case .getFriendsList:
            return "api/ApiFriend/FriendsList"
        case .getPendingFriendsList:
            return "api/ApiFriend/GetInvitePendingRequests"
            
        case .getBlockFriendsList:
            return "api/ApiFriend/GetBlockList"
        case .blockFriend:
            return "api/ApiFriend/BlockFriend"
        case .unblockFriend:
            return "api/ApiFriend/UnblockFriend"
            //        case .getPendingSendRequestsList:
            //            return "api/ApiFriend/GetInviteSentRequests"
        case .acceptFriendInviteRequest:
            return "api/ApiFriend/AcceptInviteRequest"
        case .removeFriend:
            return "api/ApiFriend/RemoveFriend"
        case .rejectFriendInviteRequest:
            return "api/ApiFriend/RejectInviteRequest"
        case .getViewProfileDetails:
            return "api/ApiFriend/GetPublicProfileDetails"
            
            // Circle
        case .createCircle:
            return "api/ApiCircle/CreateCircle"
        case .createCircleV2:
            return "api/ApiCircle/CreateCircleV2"
        case .editCircleV2:
            return "api/ApiCircle/EditCircleV2"
        case .getCircleList:
            return "api/ApiCircle/ExploreCircles"
        case .sendCircleRequest:
            return "api/ApiCircle/JoinCircleRequest"
        case .isDiscoverable:
            return "api/ApiAccount/Discoverable"
        case .getMyCircleList:
            return "api/ApiCircle/MyCircles"
        case .getPendingCircleJoinList:
            return "api/ApiCircle/GetPendingCircleJoinRequests"
        case .acceptCircleJoinRequest:
            return "api/ApiCircle/AcceptCircleJoinRequest"
        case .rejectCircleJoinRequest:
            return "api/ApiCircle/RejectCircleJoinRequest"
        case .getPollDurationList:
            return "api/ApiCircle/GetPollDurations"
        case .createPoll:
            return "api/ApiCircle/CreatePoll"
        case .getPendingCircleInviteList:
            return "api/ApiCircle/GetPendingCircleInvitations"
        case .acceptCircleInviteRequest:
            return "api/ApiCircle/AccepCircleInvite"
        case .rejectCircleInviteRequest:
            return "api/ApiCircle/RejectCircleInvite"
        case .getCircleNewPollList:
            return "api/ApiCircle/GetCircleNewPolls"
        case .submitPollAnswer:
            return "api/ApiCircle/SubmitPollAnswer"
        case .getFriendsToInviteToCircle:
            return "api/ApiCircle/GetFriendsToInviteInCircle"
        case .inviteFriendToCircle:
            return "api/ApiCircle/InviteFriendToCircle"
        case .getCirclePastPollList:
            return "api/ApiCircle/GetCirclePastPolls"
        case .getCircleDetails:
            return "api/ApiCircle/GetCircleDetails"
        case .getCircleMembersByCircleIdsList:
            return "api/ApiCircle/GetCirclesMembersByCircleIds"
        case .getCirclePollsByCircleIdsList:
            return "api/ApiCircle/GetCirclePollsByCircleIds"
        case .createCircleInterection:
            return "api/ApiCircle/CreateIntersectionCircle"
        case .getCircleMemberList:
            return "api/ApiCircle/CircleMemberList"
        case .getUserListOnPollOption:
            return "api/ApiCircle/GetPollResponsesByOptionID"
        case .getTrendingCircleCategoryList:
            return "api/ApiCircle/GetTrendingCircleCategories"
        case .deleteCirclePoll:
            return "api/ApiCircle/DeleteCirclePoll"
            
        case .getWalletBalance:
            return "api/ApiWallet/GetWalletBalance"
        case .getWalletDetail:
            return "api/ApiWallet/GetCryptoInfoAndBalance"
        case .cryptoWithdraw:
            return "api/ApiWallet/CryptoWithdraw"
        case .transferToFriend:
            return "api/ApiWallet/TransferToFriend"
        case .getMyTransactionList:
            return "api/ApiTransaction/MyTransactions"
        case .getStripeCardList:
            return "api/ApiWallet/stripeGetCards"
        case .getPaymentIntent:
            return "api/ApiWallet/CreateStripeIntent"
            //        case .saveUserCardStripe:
            //            return "api/ApiWallet/StripeSaveUserCard"
        case .makeDefaultCardStripe:
            return "api/ApiWallet/StripeMakeCardDefault"
        case .depositWithNewCardStripe:
            return "api/ApiWallet/StripeDepositWithNewCard"
        case .depositWithDefaultCardStripe:
            return "api/ApiWallet/StripeDepositWithDefaultCard"
        case .saveCheckoutOrderDetailPayPal:
            return "api/ApiWallet/PaypalSaveCheckoutOrderDetails"
            
        case .getBankAccountList:
            return "api/ApiWallet/GetMyBankAccounts"
        case .withdrawAmountToBankAccount:
            return "api/ApiWallet/WithdrawAmountToBankAccount"
        case .removeBankAccount:
            return "api/ApiWallet/RemoveBankAccount"
        case .getCountryList:
            return "api/ApiWallet/GetCountries"
        case .createBankAccount:
            return "api/ApiWallet/CreateBankAccount"
            
            // Notifications
        case .getNotificationList:
            return "api/ApiNotification/GetNotifications"
            //        case .markAsReadNotification:
            //            return "api/ApiNotification/NotificationSeen"
        case .getNotificationCount:
            return "api/ApiNotification/GetLayoutNotifications"
            
            // News Feeds
        case .savePost:
            return "api/ApiNewsfeed/SavePost"
        case .savePostV2:
            return "api/ApiNewsfeed/SavePostV2"
            
        case .getPostList:
            return "api/ApiNewsfeed/GetNewsfeedPosts"
            
            
        case .getCommentList:
            return "api/ApiNewsfeed/GetNewsfeedComments"
        case .getReplyList:
            return "api/ApiNewsfeed/GetNewsfeedReplies"
        case .saveCommentReply:
            return "api/ApiNewsfeed/SaveCommentReplies"
        case .saveLike:
            return "api/ApiNewsfeed/SaveLikePostComment"
        case .deletePost:
            return "api/ApiNewsfeed/DeletePost"
        case .deleteComment:
            return "api/ApiNewsfeed/DeleteComment"
        case .deleteReply:
            return "api/ApiNewsfeed/DeleteReply"
            
        case .editComment:
            return "api/ApiNewsfeed/EditComment"
        case .editReply:
            return "api/ApiNewsfeed/EditReply"
            
            
            
            
        // Report
        case .getReportTypeList:
            return "api/ApiReport/GetReportTypes"
        case .saveReport:
            return "api/ApiReport/SaveReport"
            
            
        // User
        case .getUserDetails:
            return "api/ApiUser/GetUserDetails"
        case .updateProfile:
            return "api/ApiUser/UpdateProfile"
            
            //Chats API
        case .getChatList:
            return "api/ApiChat/GetChatList"
            
        case .getChat:
            return "api/ApiChat/GetMessages"
            
        case .sendMessage:
            return "api/ApiChat/SendMessage"
        case .deleteMessages:
            return "api/ApiChat/PartialDeleteMessage"
            
            // Avatar
        case .getPastPoll:
            return "api/ApiAvatar/GetUserAnsweredPastPolls"
        case .updatePollPrivacy:
            return "api/ApiAvatar/UpdatePollResponsePrivacy"
        case .removeAnsweredPollOption:
            return "api/ApiAvatar/RemovePollAnsweredOption"
        case .getAllAvatarPropsByGender:
            return "api/ApiAvatar/GetAllAvatarPropsByGender"
        case .getCurrentAvatar:
            return "api/ApiAvatar/GetCurrentAvatar"
        case .saveUserAvatar:
            return "api/ApiAvatar/SaveUserAvatar"
            
            
            // App Information
        case .termsNConditions:
            return "api/ApiAbout/GetTerms"
        case .privacyPolicy:
            return "api/ApiAbout/GetPrivacy"
        case .contactUs:
            return "api/ApiAbout/SaveContactUs"
            
        // Calling
        case .startCallSession:
            return "api/ApiVideo/StartCallSession"
        case .groupCallHostStop:
            return "api/ApiVideo/GroupCallHostStop"
        case .callMemberStop:
            return "api/ApiVideo/CallMemberStop"
        case .groupCallSession:
            return "api/ApiVideo/GetGroupCallSession"
        case .broadCastCall:
            return "api/ApiVideo/StartBroadCastCall"
        case .callReceived:
            return "api/ApiVideo/CallRecieved"
            
        case .resendTransferCode:
            return "api/ApiWallet/ResendTransferCode"
            
        case .getPrivacySettings:
            return "api/ApiAccount/GetPrivacySettings"
        case .changePrivacySetting:
            return "api/ApiAccount/ChangePrivacy"
        case .resend2FACode:
            return "api/ApiAccount/ResendTwoFACode"
        case .twoFactorAuthenticationToggle:
            return "api/ApiAccount/ToggleTwoFactorAuthentication"
        case .verifyTransferCode:
            return "api/ApiWallet/VerifyTransferCode"
            
        case .getAMLKYCUploadOptions:
            return "api/ApiUser/GetAMLKYCUploadOptions"
        case .verifyAMLKYC:
            return "api/ApiUser/VerifyAMLKYC"
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
            //        case .countriesList, .searchBlogs, .compareList, .filterList, .languageList, .getCountryFlag, .getCountryByLocation:
            //            return .requestPlain
            //        case .bestcryptobettingsite, .topDailyBets, .blogsList, .localbettingSite, .bestBettingApps:
            //            return .requestParameters(parameters: ["lcode" : "SharedPreferences.getCurrentLanguage()"], encoding: URLEncoding.queryString)
            //            //        case .movie:
            //            //            return .requestParameters(parameters: ["api_key": ""], encoding: URLEncoding.queryString)
            //        case .filterResults(_, let envelope, let cryptocurrency, let deposit, let language, let product, let country):
            //            return .requestParameters(parameters: ["envelope" : envelope, "cryptocurrency" : cryptocurrency, "deposit" : deposit, "language" : language, "product" : product, "country" : country], encoding: URLEncoding.queryString)
            //
            //        case .getCommentsList(let postID), .getAverateRating(let postID):
            //            return .requestParameters(parameters: ["PostID" : postID], encoding: URLEncoding.queryString)
            //
            //        case .getFavouriteList(_):
            //            return .requestParameters(parameters: ["user_id" : "Constants.deviceId"], encoding: URLEncoding.queryString)
            //
            //        case .reviewsList, .searchReviews:
            //            return .requestParameters(parameters: ["UserID" : "Constants.deviceId"], encoding: URLEncoding.queryString)
            //
            //
            //        case .search(let query):
            //            return .requestParameters(parameters: ["query" : query, "api_key": "Constants.API.apiKey"], encoding: URLEncoding.queryString)
            
            /// Users & Friends Endpoints
        case .loginUser(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .registerUser(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .verify2FA(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .verifyForgetPassword(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .verifyEmail(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .forgotPassword(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .updatePassword(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .changePassword(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .logout:
            return .requestPlain
            
        case .deleteAccount:
            return .requestPlain
            
            /// Users & Friends Endpoints
        case .getUsersList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
            
        case .sendFriendRequest(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            //        case .cancelFriendRequest(params: let params):
            //            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .getFriendsList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .getPendingFriendsList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
            
        case .getBlockFriendsList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .blockFriend(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .unblockFriend(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
            //        case .getPendingSendRequestsList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            //            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .acceptFriendInviteRequest(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .removeFriend(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .rejectFriendInviteRequest(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getViewProfileDetails(profileIdentifier: let profileIdentifier):
            return .requestParameters(parameters: ["ProfileIdentifier": profileIdentifier], encoding: URLEncoding.queryString)
            
            // Circle
        case .createCircle(memberIds: let memberIds, circleName: let circleName, imageFile: let imageFile):
            var formData: [MultipartFormData] = []
            
            if let imageFile {
                formData.append(MultipartFormData(provider: .data(imageFile), name: "ImageFile", fileName: "circleImage.jpeg", mimeType: "image/jpeg"))
            }
            formData.append(MultipartFormData(provider: .data(memberIds.data(using: .utf8)!), name: "MembersIDs"))
            formData.append(MultipartFormData(provider: .data(circleName.data(using: .utf8)!), name: "CircleName"))
            return .uploadMultipart(formData)
        
        case .createCircleV2(memberIds: let memberIds, circleName: let circleName, imageFile: let imageFile, circleCategory: let circleCategory, privacy: let privacy):
            
            var formData: [MultipartFormData] = []

            formData.append(MultipartFormData(provider: .data(imageFile), name: "ImageFile", fileName: "circleImage.jpeg", mimeType: "image/jpeg"))
            formData.append(MultipartFormData(provider: .data(memberIds.data(using: .utf8)!), name: "MembersIDs"))
            formData.append(MultipartFormData(provider: .data(circleName.data(using: .utf8)!), name: "CircleName"))
            formData.append(MultipartFormData(provider: .data(circleCategory.data(using: .utf8)!), name: "CircleCategory"))
            formData.append(MultipartFormData(provider: .data("\(privacy)".data(using: .utf8)!), name: "Privacy"))
            
            return .uploadMultipart(formData)
            
        case .editCircleV2(id: let id, memberIds: let memberIds, circleName: let circleName, imageFile: let imageFile, circleCategory: let circleCategory, privacy: let privacy):
            
            var formData: [MultipartFormData] = []

            formData.append(MultipartFormData(provider: .data("\(id)".data(using: .utf8)!), name: "ID"))
            if let imageFile {
                formData.append(MultipartFormData(provider: .data(imageFile), name: "ImageFile", fileName: "circleImage.jpeg", mimeType: "image/jpeg"))
            }
            formData.append(MultipartFormData(provider: .data(memberIds.data(using: .utf8)!), name: "MembersIDs"))
            formData.append(MultipartFormData(provider: .data(circleName.data(using: .utf8)!), name: "CircleName"))
            formData.append(MultipartFormData(provider: .data(circleCategory.data(using: .utf8)!), name: "CircleCategory"))
            formData.append(MultipartFormData(provider: .data("\(privacy)".data(using: .utf8)!), name: "Privacy"))
            
            return .uploadMultipart(formData)
            
        case .getCircleList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .sendCircleRequest(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .isDiscoverable:
            return .requestParameters(parameters: ["IsDiscoverable": "true"], encoding: URLEncoding.queryString)
        case .getMyCircleList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText, category: let category):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText, "category": category], encoding: URLEncoding.queryString)
        case .getPendingCircleJoinList(circleIdentifier: let circleIdentifier, pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["CircleIdentifier": circleIdentifier, "pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .acceptCircleJoinRequest(inviteId: let inviteId):
            return .requestParameters(parameters: ["InviteID": inviteId], encoding: URLEncoding.queryString)
        case .rejectCircleJoinRequest(inviteId: let inviteId):
            return .requestParameters(parameters: ["InviteID": inviteId], encoding: URLEncoding.queryString)
        case .getPollDurationList:
            return .requestPlain
        case .createPoll(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .getPendingCircleInviteList(pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .acceptCircleInviteRequest(inviteId: let inviteId):
            return .requestParameters(parameters: ["InviteID": inviteId], encoding: URLEncoding.queryString)
        case .rejectCircleInviteRequest(inviteId: let inviteId):
            return .requestParameters(parameters: ["InviteID": inviteId], encoding: URLEncoding.queryString)
        case .getCircleNewPollList(circleIdentifier: let circleIdentifier):
            return .requestParameters(parameters: ["CircleIdentifier": circleIdentifier], encoding: URLEncoding.queryString)
        case .submitPollAnswer(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getFriendsToInviteToCircle(circleId: let circleId):
            return .requestParameters(parameters: ["CircleID": circleId], encoding: URLEncoding.queryString)
        case .inviteFriendToCircle(status: let status, toUserId: let toUserId, circleId: let circleId):
            return .requestParameters(parameters: ["status": "\(status)", "toUserId": toUserId, "circleID": circleId], encoding: URLEncoding.queryString)
        case .getCirclePastPollList(circleIdentifier: let circleIdentifier):
            return .requestParameters(parameters: ["CircleIdentifier": circleIdentifier], encoding: URLEncoding.queryString)
        case .getCircleDetails(identifier: let identifier):
            return .requestParameters(parameters: ["Identifier": identifier], encoding: URLEncoding.queryString)
        case .getCircleMembersByCircleIdsList(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getCirclePollsByCircleIdsList(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .createCircleInterection(circleIds: let circleIds, imageFile: let imageFile, circleName: let circleName, memberIds: let memberIds, pollIds: let pollIds, circleCategory: let circleCategory, privacy: let privacy):
            
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(provider: .data(imageFile), name: "ImageFile", fileName: "circleImage.jpeg", mimeType: "image/jpeg"))
            formData.append(MultipartFormData(provider: .data(circleName.data(using: .utf8)!), name: "CircleName"))
            formData.append(MultipartFormData(provider: .data(circleCategory.data(using: .utf8)!), name: "CircleCategory"))
            formData.append(MultipartFormData(provider: .data("\(privacy)".data(using: .utf8)!), name: "Privacy"))
            
            for (i, circleId) in circleIds.enumerated() {
                formData.append(MultipartFormData(provider: .data("\(circleId)".data(using: .utf8)!), name: "CircleIds[\(i)]"))
            }
            
            for (i, memberId) in memberIds.enumerated() {
                formData.append(MultipartFormData(provider: .data("\(memberId)".data(using: .utf8)!), name: "MembersIDs[\(i)]"))
            }
            for (i, pollId) in pollIds.enumerated() {
                formData.append(MultipartFormData(provider: .data("\(pollId)".data(using: .utf8)!), name: "PollIds[\(i)]"))
            }
            return .uploadMultipart(formData)
            
        case .getCircleMemberList(circleId: let circleId, pageNumber: let pageNumber, pageLimit: let pageLimit, searchText: let searchText):
            return .requestParameters(parameters: ["CircleID": circleId, "pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
            
        case .getUserListOnPollOption(pollId: let pollId, optionId: let optionId):
            return .requestParameters(parameters: ["pollID": pollId, "optionID": optionId], encoding: URLEncoding.queryString)
            
        case .getTrendingCircleCategoryList(search: let search):
            return .requestParameters(parameters: ["search": search], encoding: URLEncoding.queryString)
        
        case .deleteCirclePoll(pollId: let pollId):
            return .requestParameters(parameters: ["PollID": pollId], encoding: URLEncoding.queryString)
            
        case .getWalletBalance:
            return .requestPlain
        case .getWalletDetail:
            return .requestPlain
        case .cryptoWithdraw(params: let params):
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .transferToFriend(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getMyTransactionList(fromDate: let fromDate, toDate: let toDate, transType: let transType, pageNumber: let pageNumber, pageLimit: let pageLimit):
            return .requestParameters(parameters: ["FromDate": fromDate, "ToDate": toDate, "TransType": transType, "pageNumber": pageNumber, "pageLimit": pageLimit], encoding: URLEncoding.queryString)
            
        case .getStripeCardList:
            return .requestPlain
        case .getPaymentIntent:
            return .requestPlain
            //        case .saveUserCardStripe(params: let params):
            //            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .makeDefaultCardStripe(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .depositWithNewCardStripe(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .depositWithDefaultCardStripe(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .saveCheckoutOrderDetailPayPal(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .getBankAccountList:
            return .requestPlain
        case .withdrawAmountToBankAccount(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .removeBankAccount(accountIdentifier: let accountIdentifier):
            return .requestParameters(parameters: ["AccountIdentifier": accountIdentifier], encoding: URLEncoding.queryString)
            
        case .getCountryList:
            return .requestPlain
            
        case .createBankAccount(accHolderName: let accHolderName, accNumber: let accNumber, routingNumber: let routingNumber, city: let city, country: let country, line1: let line1, line2: let line2, state: let state, postalCode: let postalCode, ssn: let ssn, dob: let dob, documentFile: let documentFile):
            
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(provider: .data(accHolderName.data(using: .utf8)!), name: "AccountHolderName"))
            formData.append(MultipartFormData(provider: .data(accNumber.data(using: .utf8)!), name: "AccountNumber"))
            formData.append(MultipartFormData(provider: .data(routingNumber.data(using: .utf8)!), name: "RoutingNumber"))
            formData.append(MultipartFormData(provider: .data(city.data(using: .utf8)!), name: "City"))
            formData.append(MultipartFormData(provider: .data(country.data(using: .utf8)!), name: "Country"))
            formData.append(MultipartFormData(provider: .data(line1.data(using: .utf8)!), name: "Line1"))
            formData.append(MultipartFormData(provider: .data(line2.data(using: .utf8)!), name: "Line2"))
            formData.append(MultipartFormData(provider: .data(state.data(using: .utf8)!), name: "State"))
            formData.append(MultipartFormData(provider: .data(postalCode.data(using: .utf8)!), name: "PostalCode"))
            formData.append(MultipartFormData(provider: .data(ssn.data(using: .utf8)!), name: "Ssn"))
            formData.append(MultipartFormData(provider: .data(dob.data(using: .utf8)!), name: "Dob"))
            
            formData.append(MultipartFormData(provider: .data(documentFile), name: "DocumentFile", fileName: "File"))
            
            return .uploadMultipart(formData)
            
            // Notifications
        case .getNotificationList(pageNumber: let pageNumber, pageLimit: let pageLimit):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit], encoding: URLEncoding.queryString)
            //        case .markAsReadNotification(notificationId: let notificationId):
            //            return .requestParameters(parameters: ["NotificationId": notificationId], encoding: URLEncoding.queryString)
        case .getNotificationCount:
            return .requestPlain
            
            // News Feeds
        case .savePost(content: let content, privacy: let privacy, imageFiles: let imageFiles, videoFiles: let videoFiles, let videoThumbnails, let deletePostMediaIds, let postId):
            
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(provider: .data(deletePostMediaIds.data(using: .utf8)!), name: "PostMediaIdsDelete"))
            
            formData.append(MultipartFormData(provider: .data("\(postId)".data(using: .utf8)!), name: "ID"))
            
            formData.append(MultipartFormData(provider: .data(content.data(using: .utf8)!), name: "Content"))
            formData.append(MultipartFormData(provider: .data(privacy.data(using: .utf8)!), name: "Privacy"))
            
            for imageFile in imageFiles {
                formData.append(MultipartFormData(provider: .data(imageFile), name: "ImageFile", fileName: "feed.jpeg", mimeType: "image/jpeg"))
            }
            for videoFile in videoFiles {
                formData.append(MultipartFormData(provider: .data(videoFile), name: "VideoFile", fileName: "feed.mp4", mimeType: "video/mp4"))
            }
            for (i, videoThumbnail) in videoThumbnails.enumerated() {
                formData.append(MultipartFormData(provider: .data(videoThumbnail), name: "videoThumbnail[\(i)]", fileName: "feedThumbnail.jpeg", mimeType: "image/jpeg"))
            }

            return .uploadMultipart(formData)
            
        case .savePostV2(content: let content, privacyType: let privacyType, imageFiles: let imageFiles, videoFiles: let videoFiles, videoThumbnails: let videoThumbnails, deletePostMediaIds: let deletePostMediaIds, postId: let postId, friendIds: let friendIds, shareWithFriendIds: let shareWithFriendIds):
            
            var formData: [MultipartFormData] = []
            
            formData.append(MultipartFormData(provider: .data(deletePostMediaIds.data(using: .utf8)!), name: "PostMediaIdsDelete"))
            
            formData.append(MultipartFormData(provider: .data("\(postId)".data(using: .utf8)!), name: "ID"))
            
            formData.append(MultipartFormData(provider: .data(content.data(using: .utf8)!), name: "Content"))
            formData.append(MultipartFormData(provider: .data("\(privacyType)".data(using: .utf8)!), name: "PrivacyType"))
            
            for imageFile in imageFiles {
                formData.append(MultipartFormData(provider: .data(imageFile), name: "ImageFile", fileName: "feed.jpeg", mimeType: "image/jpeg"))
            }
            for videoFile in videoFiles {
                formData.append(MultipartFormData(provider: .data(videoFile), name: "VideoFile", fileName: "feed.mp4", mimeType: "video/mp4"))
            }
            for (i, videoThumbnail) in videoThumbnails.enumerated() {
                formData.append(MultipartFormData(provider: .data(videoThumbnail), name: "videoThumbnail[\(i)]", fileName: "feedThumbnail.jpeg", mimeType: "image/jpeg"))
            }
            
            for (i, friendId) in friendIds.enumerated() {
                formData.append(MultipartFormData(provider: .data("\(friendId)".data(using: .utf8)!), name: "FriendIds[\(i)]"))
            }
            
            for (i, shareWithFriendId) in shareWithFriendIds.enumerated() {
                formData.append(MultipartFormData(provider: .data("\(shareWithFriendId)".data(using: .utf8)!), name: "ShareWithFriendIds[\(i)]"))
            }

            return .uploadMultipart(formData)
            
            
        case .getPostList(pageNumber: let pageNumber, pageLimit: let pageLimit, postId: let postId, postIdentifier: let postIdentifier, profileIdentifier: let profileIdentifier, hashtag: let hashtag):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "PostID": postId, "NewsfeedIdentifier": postIdentifier, "ProfileIdentifier": profileIdentifier, "HashTag": hashtag], encoding: URLEncoding.queryString)
            
        case .getCommentList(pageNumber: let pageNumber, pageLimit: let pageLimit, commentId: let commentId, postId: let postId):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "CommentID": commentId, "PostId": postId], encoding: URLEncoding.queryString)
        case .getReplyList(pageNumber: let pageNumber, pageLimit: let pageLimit, replyId: let replyId, commentId: let commentId):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "ReplyID": replyId, "CommentId": commentId], encoding: URLEncoding.queryString)
        case .saveCommentReply(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .saveLike(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .deletePost(postId: let postId):
            return .requestParameters(parameters: ["PostID": postId], encoding: URLEncoding.queryString)
        case .deleteComment(commentId: let commentId):
            return .requestParameters(parameters: ["CommentID": commentId], encoding: URLEncoding.queryString)
        case .deleteReply(replyId: let replyId):
            return .requestParameters(parameters: ["ReplyID": replyId], encoding: URLEncoding.queryString)
        case .editComment(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .editReply(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
    
            
            
            
            
    // Report
        case .getReportTypeList:
            return .requestPlain
        case .saveReport(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        // User
        case .getUserDetails:
            return .requestPlain
            
        case .updateProfile(userDetail: let userDetail):
            
            var formData: [MultipartFormData] = []

            if let imgData = userDetail.imageFile {
                formData.append(MultipartFormData(provider: .data(imgData), name: "ImageFile", fileName: "user.jpeg", mimeType: "image/jpeg"))
            }
            formData.append(MultipartFormData(provider: .data(userDetail.firstName!.data(using: .utf8)!), name: "FirstName"))
            formData.append(MultipartFormData(provider: .data(userDetail.lastName!.data(using: .utf8)!), name: "LastName"))
            formData.append(MultipartFormData(provider: .data(userDetail.phoneNumber!.data(using: .utf8)!), name: "PhoneNumber"))
            
            if let tagListString = userDetail.tag {
                formData.append(MultipartFormData(provider: .data(tagListString.data(using: .utf8)!), name: "Tag"))
            }
            
            if let link = userDetail.facebookLink {
                formData.append(MultipartFormData(provider: .data(link.data(using: .utf8)!), name: "FacebookLink"))
            }
            if let link = userDetail.twitterLink {
                formData.append(MultipartFormData(provider: .data(link.data(using: .utf8)!), name: "TwitterLink"))
            }
            if let link = userDetail.youtubeLink {
                formData.append(MultipartFormData(provider: .data(link.data(using: .utf8)!), name: "YoutubeLink"))
            }
            if let link = userDetail.instagramLink {
                formData.append(MultipartFormData(provider: .data(link.data(using: .utf8)!), name: "InstagramLink"))
            }
            
            //            formData.append(MultipartFormData(provider: .data("\(userDetail.id!)".data(using: .utf8)!), name: "ID"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.identifier!.data(using: .utf8)!), name: "Identifier"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.emailAddress!.data(using: .utf8)!), name: "EmailAddress"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.displayImageURL!.data(using: .utf8)!), name: "DisplayImageURL"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.typeOfLink!.data(using: .utf8)!), name: "TypeOfLink"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.link!.data(using: .utf8)!), name: "Link"))
            //            formData.append(MultipartFormData(provider: .data("\(userDetail.userTypeID!)".data(using: .utf8)!), name: "UserTypeID"))
            //            formData.append(MultipartFormData(provider: .data("\(userDetail.countryID!)".data(using: .utf8)!), name: "CountryID"))
            //            formData.append(MultipartFormData(provider: .data("\(userDetail.isDiscoverable!)".data(using: .utf8)!), name: "IsDiscoverable"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.city!.data(using: .utf8)!), name: "City"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.dateOfBirth!.data(using: .utf8)!), name: "DateOfBirth"))
            //            formData.append(MultipartFormData(provider: .data("\(userDetail.genderID!)".data(using: .utf8)!), name: "GenderID"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.genderName.data(using: .utf8)!), name: "GenderName"))
            //            formData.append(MultipartFormData(provider: .data(userDetail.zipCode.data(using: .utf8)!), name: "Zipcode"))
            //            formData.append(MultipartFormData(provider: .data("\(userDetail.isTwoFAEnabled!)".data(using: .utf8)!), name: "IsTwoFAEnabled"))
            
            return .uploadMultipart(formData)
            
            // Chat APIs
        case .getChatList(searchText: let searchText, pageNumber: let pageNumber, pageLimit: let pageLimit):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "searchTerm": searchText], encoding: URLEncoding.queryString)
        case .getChat(identifier: let identifier, isCircle: let isCircle, pageNumber: let pageNumber, pageLimit: let pageLimit):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit, "Identifier": identifier, "IsCircle": "\(isCircle)"], encoding: URLEncoding.queryString)
        case .sendMessage(identifier: let identifier, isCircle: let isCircle, message: let message):
            return .requestParameters(parameters: ["IsCircle": "\(isCircle)", "Identifier": identifier, "message": message], encoding: URLEncoding.queryString)
        case .deleteMessages(identifier: let identifier):
            return .requestParameters(parameters: ["Identifier": identifier], encoding: URLEncoding.queryString)
            
            //Avatar
        case .getPastPoll(pageNumber: let pageNumber, pageLimit: let pageLimit):
            return .requestParameters(parameters: ["pageNumber": pageNumber, "pageLimit": pageLimit], encoding: URLEncoding.queryString)
        case .updatePollPrivacy(pollResponseId: let pollResponseId, privacy: let privacy):
            return .requestParameters(parameters: ["pollResponseID": pollResponseId, "privacy": privacy], encoding: URLEncoding.queryString)
        case .removeAnsweredPollOption(pollResponseId: let pollResponseId):
            return .requestParameters(parameters: ["pollResponseID": pollResponseId], encoding: URLEncoding.queryString)
        case .getAllAvatarPropsByGender:
            return .requestPlain
        case .getCurrentAvatar:
            return .requestPlain
        case .saveUserAvatar(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        // App Information
        case .termsNConditions:
            return .requestPlain
        case .privacyPolicy:
            return .requestPlain
        case .contactUs(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        // Calling
        case .startCallSession(callTo: let callTo, callType: let callType):
            return .requestParameters(parameters: ["call_to": callTo, "callType": callType], encoding: URLEncoding.queryString)
        case .groupCallHostStop(broadcastId: let broadcastId):
            return .requestParameters(parameters: ["broadcastId": broadcastId], encoding: URLEncoding.queryString)
        case .callMemberStop:
            return .requestPlain
        case .groupCallSession(callToCircle: let callToCircle, callType: let callType, callMembers: let callMembers):
            return .requestParameters(parameters: ["call_to_circle": callToCircle, "callType": callType, "call_members": callMembers], encoding: URLEncoding.queryString)
        case .broadCastCall(callIdentifier: let callIdentifier, circleIdentifier: let circleIdentifier):
            return .requestParameters(parameters: ["callIdentifier": callIdentifier, "circleIdentifier": circleIdentifier], encoding: URLEncoding.queryString)
        case .callReceived:
            return .requestPlain
            
        case .resendTransferCode:
            return .requestPlain
            
        case .getPrivacySettings:
            return .requestPlain
        case .changePrivacySetting(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .resend2FACode(identifier: let identifier):
            return .requestParameters(parameters: ["identifier": identifier], encoding: URLEncoding.queryString)
        case .twoFactorAuthenticationToggle(isEnabled: let isEnabled):
            return .requestParameters(parameters: ["IsTwoFAEnabled": "\(isEnabled)"], encoding: URLEncoding.queryString)
        case .verifyTransferCode(code: let code):
            return .requestParameters(parameters: ["code": code], encoding: URLEncoding.queryString)
            
        case .getAMLKYCUploadOptions:
            return .requestPlain
            
        case .verifyAMLKYC(frontImage: let frontImage, backImage: let backImage):
            
            var formData: [MultipartFormData] = []

            formData.append(MultipartFormData(provider: .data(frontImage), name: "NationalityCardFront", fileName: "user.jpeg", mimeType: "image/jpeg"))
            if let imgData = backImage {
                formData.append(MultipartFormData(provider: .data(imgData), name: "NationalityCardBack", fileName: "user.jpeg", mimeType: "image/jpeg"))
            }
            return .uploadMultipart(formData)
        }
    }
    
    var method: Method {
        switch self {
        case .loginUser, .registerUser, .verify2FA, .verifyForgetPassword, .verifyEmail, .forgotPassword, .updatePassword, .changePassword, .logout, .sendFriendRequest, .blockFriend, .unblockFriend, .acceptFriendInviteRequest, .removeFriend, .rejectFriendInviteRequest, .createCircle, .createCircleV2, .editCircleV2, .sendCircleRequest, .isDiscoverable, .acceptCircleJoinRequest, .createPoll, .rejectCircleJoinRequest, .acceptCircleInviteRequest, .rejectCircleInviteRequest, .submitPollAnswer, .inviteFriendToCircle, .getCircleMembersByCircleIdsList, .getCirclePollsByCircleIdsList, .createCircleInterection, .getTrendingCircleCategoryList, .cryptoWithdraw, .transferToFriend, .getPaymentIntent, .makeDefaultCardStripe, .depositWithDefaultCardStripe, .saveCheckoutOrderDetailPayPal, .depositWithNewCardStripe, .withdrawAmountToBankAccount, .removeBankAccount, .createBankAccount, .savePost, .savePostV2, .saveCommentReply, .saveLike, .deletePost, .deleteComment, .deleteReply, .editComment, .editReply, .saveReport, .updateProfile,  .sendMessage, .deleteMessages, .updatePollPrivacy, .removeAnsweredPollOption, .saveUserAvatar, .contactUs, .startCallSession, .callMemberStop, .groupCallSession, .broadCastCall, .callReceived, .resendTransferCode, .changePrivacySetting, .twoFactorAuthenticationToggle, .verifyTransferCode, .deleteCirclePoll, .deleteAccount, .verifyAMLKYC: //, .saveUserCardStripe
            return .post
        default:
            return .get
        }
    }
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .loginUser, .registerUser, .verify2FA, .verifyForgetPassword, .verifyEmail, .forgotPassword, .updatePassword:
            return .none
        default:
            return .bearer
        }
    }
    
    var headers: [String : String]? {
        if let token = PreferencesManager.getUserModel()?.authToken{
            return ["Authorization": "Bearer \(token)"]
        } else {
            return nil
        }
    }
}
