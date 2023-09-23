//
//  ViewModel.swift
//  Swarm Circle
//
//  Created by Macbook on 04/08/2022.
//

import Foundation

@objc protocol NetworkResponseProtocols: AnyObject{
    @objc optional func didLogin()
    @objc optional func didRegistered()
    @objc optional func didVerify2FA()
    @objc optional func didVerifyForgetPAssword()
    @objc optional func didVerifyEmail()
    @objc optional func didSendForgotPasswordRequest()
    @objc optional func didUpdatePassword()
    @objc optional func didChangePassword()
    @objc optional func didLogout()
    @objc optional func didDeleteAccount()
    
    @objc optional func didGetUsersList()
    @objc optional func didSentFriendRequest(indexPath: IndexPath)
//    @objc optional func didCancelFriendRequest()
    @objc optional func didGetFriendsList()
    @objc optional func didGetPendingFriendsList()
    
    @objc optional func didGetBlockFriendList()
    @objc optional func didBlockedFriend(object: AnyObject)
    @objc optional func didUnblockFriend(object: AnyObject)
//    @objc optional func didGetPendingSendRequestsList()
    @objc optional func didAcceptFriendInviteRequest(object: AnyObject)
    @objc optional func didRemovedFriend(object: AnyObject)
    @objc optional func didRejectFriendInviteRequest(object: AnyObject)
    @objc optional func didGetViewProfileDetails()
    
    // Circle
    @objc optional func didCreateCircle()
    @objc optional func didCreateCircleV2()
    @objc optional func didEditCircleV2()
    @objc optional func didGetCircleList()
    @objc optional func didSentCircleJoinRequest(indexPath: IndexPath)
    @objc optional func didChangeDiscoverableState()
    @objc optional func didGetJoinedCircleList()
    @objc optional func didGetPendingCircleJoinList()
    @objc optional func didAcceptCircleJoinRequest(object: AnyObject)
    @objc optional func didRejectCircleJoinRequest(object: AnyObject)
    @objc optional func didGetPollDurationList()
    @objc optional func didCreatePoll()
    
    @objc optional func didGetPendingCircleInviteList()
    @objc optional func didAcceptCircleInviteRequest(object: AnyObject)
    @objc optional func didRejectCircleInviteRequest(object: AnyObject)
    
    @objc optional func didGetCircleNewPollList()
    
    @objc optional func didSubmitPollAnswer(indexPath: IndexPath, pollObject: AnyObject)
    
    @objc optional func didGetFriendsToInviteToCircleList()
    @objc optional func didInviteFriendToCircle(indexPath: IndexPath, isInvitedInitialState: Bool)
    
    @objc optional func didGetCirclePastPollList()
    
    @objc optional func didGetCircleDetails()
    
    @objc optional func didGetCircleMembersByCircleIdsList()
    @objc optional func didGetCirclePollsByCircleIdsList()
    @objc optional func didIntersectCircles()
    @objc optional func didGetCircleMemberList()
    
    @objc optional func didGetUserListOnPollOption()
    @objc optional func didGetTrendingCircleCategoryList()
    @objc optional func didDeleteCirclePoll(object: AnyObject)
    
    // Wallet
    @objc optional func didGetWalletBalance()
    @objc optional func didGetWalletDetail()
    @objc optional func didCryptoWithdraw()
    @objc optional func didTransferToFriend()
    @objc optional func didGetTransactionList()
    @objc optional func didGetStripeCardList()
    @objc optional func didGetPaymentIntentStripe()
    @objc optional func didSaveUserCardStripe()
    @objc optional func didMakeDefaultCardStripe()
    @objc optional func didDepositWithNewCardStripe()
    @objc optional func didDepositWithDefaultCardStripe()
    @objc optional func didSaveCheckoutDetailPayPal()
    @objc optional func didGetBankAccountList()
    @objc optional func didWithdrawAmountToBank()
    @objc optional func didRemoveBankAccount(object: AnyObject)
    @objc optional func didGetCountryList()
    @objc optional func didCreateBankAccount()


    // Notification
    @objc optional func didGetNotificationList()
//    @objc optional func didMarkedAsReadNotification()
    @objc optional func didGetNotificationCount()
    
    // News Feed
    @objc optional func didAddPost()
    @objc optional func didAddPostV2()
    
    @objc optional func didGetPostList()
    
    @objc optional func didGetCommentList()
    @objc optional func didGetReplyList(commentId: Int)
    @objc optional func didSaveCommentReply()
    @objc optional func didSaveLike(object: AnyObject, sourceType: Int, replyId: Int)
    @objc optional func didDeletePost(object: AnyObject)
    @objc optional func didDeleteComment(commentId: Int)
    @objc optional func didDeleteReply(replyId: Int, object: AnyObject) // Parent object i.e: Comment Object
    
    @objc optional func didEditComment(commentId: Int, originalComment: String)
    @objc optional func didEditReply(commentId: Int, replyId: Int, originalReply: String)
    
    
    // Report
    @objc optional func didGetReportTypeList()
    @objc optional func didSaveReport()
    
    // User
    @objc optional func didGetUserDetails()
    @objc optional func didUpdateProfile()
    
    // Chats
    @objc optional func didReceiveChatList()
    @objc optional func didReceiveChat()
    @objc optional func didSendMessage()
    @objc optional func didDeleteMessages(indexPath: IndexPath)
    
    //Avatar & Past Polls
    @objc optional func didReceivePastPolls()
    @objc optional func didUpdatePollPrivacy()
    @objc optional func didRemoveAnsweredPollOption(id: Int, object: AnyObject)
    @objc optional func didGetAllAvatarPropsByGender()
    @objc optional func didGetCurrentAvatar(refreshPollList: Bool)
    @objc optional func didSaveUserAvatar()
    
    // App Information
    @objc optional func didGetTermsNConditions()
    @objc optional func didGetPrivacyPolicy()
    @objc optional func didContactUs()
    
    // Calling
    @objc optional func didStartCallSession()
    @objc optional func didGroupCallHostStop()
    @objc optional func didCallMemberStop()
    @objc optional func didGetGroupCallSession(isVideoCalling: Bool)
    @objc optional func didGetGroupCallSession() // remove above later
    @objc optional func didBroastCastCall()
    @objc optional func didReceiveCall()
    
    @objc optional func didResendTransferCode()
    
    @objc optional func didGetPrivacySettings()
    @objc optional func didChangePrivacySettings(privacyType: Any, currentPrivacyText: String)
    @objc optional func didResend2FACode()
    @objc optional func didChangeTwoFactorAuthentication(isEnabled: Bool)
    @objc optional func didVerifyTransferCode()
    
    @objc optional func diduploadOptions()
    @objc optional func didIdentityVerificationDoc()
    
    //Subscriptions
    @objc optional func didGetSubscriptionList()
    @objc optional func didGetSubscriptionDetails()
    @objc optional func didSubscriptionThroughWallet()
    @objc optional func didSubscriptionThroughNewCard()
    @objc optional func didSubscriptionThroughSaveCard()
    @objc optional func didDowngradSubscription()
}

class ViewModel {
    
    //Constructor
    private let networkManager: APIManager
    
    init(networkManager: APIManager = APIManager()) {
        self.networkManager = networkManager
    }
    
    //Delegate Variable
    weak var delegateNetworkResponse: NetworkResponseProtocols?
    
    //Response Objects
    fileprivate(set) var baseStringResponse: BaseResponse<String>?
    fileprivate(set) var loginResponse: BaseResponse<LoginDM>?
    fileprivate(set) var registerResponse: BaseResponse<UserDM>?
    fileprivate(set) var verify2FAResponse: BaseResponse<LoginDM>?
    fileprivate(set) var verifyForgetPasswordResponse: BaseResponse<UserDM>?
    fileprivate(set) var verifyEmailResponse: BaseResponse<UserDM>?
    fileprivate(set) var forgotPasswordResponse: BaseResponse<UserDM>?
    fileprivate(set) var updatePasswordResponse: BaseResponse<Bool>?
    fileprivate(set) var changePasswordResponse: BaseResponse<String>?
    fileprivate(set) var logoutResponse: BaseResponse<Bool>?
    fileprivate(set) var deleteAccountResponse: BaseResponse<Bool>?
    
    // Friends
    fileprivate(set) var userListResponse: BaseResponse<[UsersListDM]>?
    fileprivate(set) var friendRequestSentResponse: BaseResponse<Bool>?
//    fileprivate(set) var friendRequestCancelResponse: BaseResponse<Bool>?
    fileprivate(set) var friendListResponse: BaseResponse<[FriendDM]>?
    fileprivate(set) var pendingFriendsListResponse: BaseResponse<[PendingUserDM]>?
    
    fileprivate(set) var getBlockFriendListResponse: BaseResponse<[BlockedFriendDM]>?
    fileprivate(set) var blockFriendResponse: BaseResponse<Bool>?
    fileprivate(set) var unblockFriendResponse: BaseResponse<Bool>?
//    fileprivate(set) var getPendingSendRequestsListResponse: BaseResponse<[UsersListDM]>?
    fileprivate(set) var acceptFriendInviteRequestResponse: BaseResponse<Bool>?
    fileprivate(set) var removeFriendResponse: BaseResponse<Bool>?
    fileprivate(set) var rejectFriendInviteRequestResponse: BaseResponse<Bool>?
    fileprivate(set) var viewProfileDetailsResponse: BaseResponse<ViewProfileDM>?
    
    // Circle
    fileprivate(set) var createCircleResponse: BaseResponse<String>?
    fileprivate(set) var createCircleV2Response: BaseResponse<String>?
    fileprivate(set) var editCircleV2Response: BaseResponse<String>?
    fileprivate(set) var circleListResponse: BaseResponse<[ExploreCircleDM]>?
    fileprivate(set) var circleJoinRequestSentResponse: BaseResponse<Bool>?
    fileprivate(set) var discoveryStateChangeResponse: BaseResponse<Int>?
    fileprivate(set) var joinedCircleListResponse: BaseResponse<[JoinedCircleDM]>?
    fileprivate(set) var pendingCircleJoinListResponse: BaseResponse<[PendingCircleJoinDM]>?
    fileprivate(set) var acceptCircleJoinRequestResponse: BaseResponse<Bool>?
    fileprivate(set) var rejectCircleJoinRequestResponse: BaseResponse<Bool>?
    fileprivate(set) var getPollDurationListResponse: BaseResponse<[PollDurationDM]>?
    fileprivate(set) var createPollResponse: BaseResponse<Int>?
    fileprivate(set) var deleteCirclePollResponse: BaseResponse<Int>?
    
    fileprivate(set) var pendingCircleInviteListResponse: BaseResponse<[PendingCircleInviteDM]>?
    fileprivate(set) var acceptCircleInviteRequestResponse: BaseResponse<AcceptCircleInviteDM>?
    fileprivate(set) var rejectCircleInviteRequestResponse: BaseResponse<Bool>?
    fileprivate(set) var getCircleNewPollListResponse: BaseResponse<[NewPollDM]>?
    
    fileprivate(set) var submitPollAnswerResponse: BaseResponse<Int>?
    
    fileprivate(set) var getFriendsToInviteToCircleListResponse: BaseResponse<[GetFriendListToInviteToCircleDM]>?
    fileprivate(set) var inviteFriendToCircleResponse: BaseResponse<Bool>?
    
    fileprivate(set) var getCirclePastPollListResponse: BaseResponse<[PastPollDM]>?
    
    fileprivate(set) var circleDetailsResponse: BaseResponse<CircleDetailDM>?
    
    fileprivate(set) var didGetCircleMemberByCircleIdsListResponse: BaseResponse<[CircleMembersByCircleIdDM]>?
    fileprivate(set) var didGetCirclePollsByCircleIdsResponse: BaseResponse<[CirclePollsByCircleIdDM]>?
    
    fileprivate(set) var intersectCircleResponse: BaseResponse<String>?
    
    fileprivate(set) var circleMemberListResponse: BaseResponse<[CircleMemberDM]>?
    
    fileprivate(set) var userListPollOptionResponse: BaseResponse<[UserListPollOptionDM]>?
    
    fileprivate(set) var trendingCircleCategoryListResponse: BaseResponse<[TagDM]>?
    
    // Wallet
    fileprivate(set) var walletBalanceResponse: BaseResponse<Double>?
    
    fileprivate(set) var walletDetailResponse: BaseResponse<WalletDetailDM>?
    
    fileprivate(set) var cryptoWithdrawResponse: BaseResponse<String>?
    
    fileprivate(set) var transferToFriendResponse: BaseResponse<String>?
    
    fileprivate(set) var transactionListResponse: BaseResponse<[TransactionDM]>?
    
    
    fileprivate(set) var stripeCardListResponse: BaseResponse<[CardDM]>?
    fileprivate(set) var paymentIntentStripeResponse: BaseResponse<String>?
    fileprivate(set) var userCardSaveStripeResponse: BaseResponse<String>?
    fileprivate(set) var defaultCardStripeResponse: BaseResponse<Bool>?
    fileprivate(set) var depositWithNewCardStripeResponse: BaseResponse<Bool>?
    fileprivate(set) var depositWithDefaultCardStripeResponse: BaseResponse<Bool>?
    fileprivate(set) var checkoutPayPalResponse: BaseResponse<Bool>?
    fileprivate(set) var bankAccountListResponse: BaseResponse<[BankAccountDM]>?
    fileprivate(set) var withdrawAmountToBankResponse: BaseResponse<String>?
    fileprivate(set) var removeBankAccountResponse: BaseResponse<Int>?
    fileprivate(set) var countryListResponse: BaseResponse<[CountryDM]>?
    fileprivate(set) var bankAccountCreateResponse: BaseResponse<String>?
    
    
    // Notification
    fileprivate(set) var notificationListResponse: BaseResponse<[NotificationDM]>?
//    fileprivate(set) var markAsReadResponse: BaseResponse<Bool>?
    fileprivate(set) var notificationCountResponse: BaseResponse<[NotificationDM]>?
    
    // News Feed
    fileprivate(set) var addPostResponse: BaseResponse<Int>?
    fileprivate(set) var addPostResponseV2: BaseResponse<Int>?
    
    fileprivate(set) var postListResponse: BaseResponse<[PostDM]>?

    fileprivate(set) var commentListResponse: BaseResponse<[ComRepDM]>?
    fileprivate(set) var replyListResponse: BaseResponse<[ComRepDM]>?
    fileprivate(set) var saveCommentReplyResponse: BaseResponse<SaveCommentReplyDM>?
    fileprivate(set) var saveLikeResponse: BaseResponse<CommentReplyDetailDM>?
    fileprivate(set) var deletePostResponse: BaseResponse<Bool>?
    fileprivate(set) var deleteCommentResponse: BaseResponse<Bool>?
    fileprivate(set) var deleteReplyResponse: BaseResponse<Bool>?
    
    fileprivate(set) var editCommentResponse: BaseResponse<ComRepDM>?
    fileprivate(set) var editReplyResponse: BaseResponse<CommentReplyDetailDM>?
    
    // Report
    fileprivate(set) var reportTypeListResponse: BaseResponse<[ReportTypeDM]>?
    fileprivate(set) var saveReportResponse: BaseResponse<Double>?
    
    
    // User
    fileprivate(set) var userDetailsResponse: BaseResponse<UserDetailDM>?
    fileprivate(set) var updateProfileResponse: BaseResponse<UserDM>?
    
    
    //Chats
    fileprivate(set) var chatListResponse: BaseResponse<[MessagesListDM]>?
    fileprivate(set) var chatResponse: BaseResponse<[MessagesRecordDM]>?
    fileprivate(set) var sendMessageResponse: BaseResponse<ChatList>?
    fileprivate(set) var deleteMessagesResponse: BaseResponse<Double>?
    
    // Avatar & Past Polls
    fileprivate(set) var pastPollsResponse: BaseResponse<[AVPastPoll]>?
    fileprivate(set) var updatePollPrivacyResponse: BaseResponse<Double>?
    fileprivate(set) var removeAnsweredPollOptionResponse: BaseResponse<Double>?
    fileprivate(set) var avatarPropsByGenderResponse: BaseResponse<[AvatarPropsDM]>?
    fileprivate(set) var currentAvatarResponse: BaseResponse<AvatarDM>?
    fileprivate(set) var saveUserAvatarResponse: BaseResponse<Bool>?
    
    // App Information
    fileprivate(set) var termsNConditionsResponse: BaseResponse<[AppInfoDM]>?
    fileprivate(set) var privacyPolicyResponse: BaseResponse<[AppInfoDM]>?
    fileprivate(set) var contactUsResponse: BaseResponse<Double>?
    
    // Calling
    fileprivate(set) var startCallSessionResponse: BaseResponse<StartCellSessionDM>?
    fileprivate(set) var groupCallHostStopResponse: BaseResponse<Bool>?
    fileprivate(set) var callMemberStopResponse: BaseResponse<Bool>?
    fileprivate(set) var groupCallSessionResponse: BaseResponse<StartGroupCallSession>?
    fileprivate(set) var broadCastCallResponse: BaseResponse<BroadCastCallDM>?
    fileprivate(set) var receiveCallResponse: BaseResponse<Bool>?
    
    fileprivate(set) var resendTransferCodeResponse: BaseResponse<Bool>?
    
    fileprivate(set) var privacySettingsResponse: BaseResponse<PrivacySettingsDM>?
    fileprivate(set) var changePrivacyResponse: BaseResponse<Bool>?
    fileprivate(set) var resend2FACodeResponse: BaseResponse<UserDM>?
    fileprivate(set) var changeTwoFactorAuthenticationResponse: BaseResponse<String>?
    fileprivate(set) var verifyTransferCodeResponse: BaseResponse<String>?
    
    fileprivate(set) var getUploadOptionsResponse: BaseResponse<UploadOptions>?
    fileprivate(set) var identityVerificationDocResponse: BaseResponse<Bool>?
    
    //Subscription
    fileprivate(set) var getSubscriptionPackagesResponse: BaseResponse<[SubscriptionListDM]>?
    fileprivate(set) var getSubscriptionDetailsResponse: BaseResponse<SubscriptionListDM>?
    fileprivate(set) var subscriptionThroughWalletResponse: BaseResponse<Bool>?
    fileprivate(set) var subscriptionThroughNewCardResponse: BaseResponse<Bool>?
    fileprivate(set) var subscriptionThroughSaveCardResponse: BaseResponse<Bool>?
    fileprivate(set) var downgradSubscriptionResponse: BaseResponse<Bool>?

    // MARK: Login
    func loginUser(params: [String: Any]) {
        //        ActivityIndicator.sharedInstance.showLoader()
        networkManager.postLogin(params: params, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.loginResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didLogin?()
                //                ActivityIndicator.sharedInstance.hideLoader()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.loginResponse = nil
                strongSelf.delegateNetworkResponse?.didLogin?()
                //                ActivityIndicator.sharedInstance.hideLoader()
            }
        })
    }
    
    // MARK: Registration
    func registerUser(params: [String: Any]) {
        
        networkManager.postRegister(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.registerResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRegistered?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.registerResponse = nil
                strongSelf.delegateNetworkResponse?.didRegistered?()
            }
        }
    }
    
    // MARK: 2FA Verification
    func verify2FA(params: [String: Any]) {
        
        networkManager.postVerify2FA(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.verify2FAResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didVerify2FA?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.verify2FAResponse = nil
                strongSelf.delegateNetworkResponse?.didVerify2FA?()
            }
        }
    }
    
    // MARK: Forget Password Verification
    func verifyForgetPassword(params: [String: Any]) {
        
        networkManager.postVerifyForgetPassword(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.verifyForgetPasswordResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didVerifyForgetPAssword?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.verifyForgetPasswordResponse = nil
                strongSelf.delegateNetworkResponse?.didVerifyForgetPAssword?()
            }
        }
    }
    
    // MARK: Email Verification
    func verifyEmail(params: [String: Any]) {
        
        networkManager.postVerifyEmail(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.verifyEmailResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didVerifyEmail?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.verifyEmailResponse = nil
                strongSelf.delegateNetworkResponse?.didVerifyEmail?()
            }
        }
    }
    
    // MARK: Forgot Password
    func forgotPassword(params: [String: Any]) {
        
        networkManager.postForgotPassword(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.forgotPasswordResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSendForgotPasswordRequest?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.forgotPasswordResponse = nil
                strongSelf.delegateNetworkResponse?.didSendForgotPasswordRequest?()
            }
        }
    }
    
    // MARK: Update Password
    func updatePassword(params: [String: Any]) {
        
        networkManager.postUpdatePassword(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.updatePasswordResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didUpdatePassword?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.updatePasswordResponse = nil
                strongSelf.delegateNetworkResponse?.didUpdatePassword?()
            }
        }
    }
    
    // MARK: Change Password
    func changePassword(params: [String: Any]) {
        
        networkManager.postChangePassword(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.changePasswordResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didChangePassword?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.changePasswordResponse = nil
                strongSelf.delegateNetworkResponse?.didChangePassword?()
            }
        }
    }
    
    // MARK: Logout
    func logout() {
        
        networkManager.postLogout { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.logoutResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didLogout?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.logoutResponse = nil
                strongSelf.delegateNetworkResponse?.didLogout?()
            }
        }
    }
    
    // MARK: Delete Account
    func deleteAccount() {
        
        networkManager.postDeleteAccount{ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.deleteAccountResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDeleteAccount?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.deleteAccountResponse = nil
                strongSelf.delegateNetworkResponse?.didDeleteAccount?()
            }
        }
    }
    
    
    // MARK: Get user lists for suggestion
    func getUsersList(pageNumber: Int, searchText: String) {
        networkManager.getUsersList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.userListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetUsersList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.userListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetUsersList?()
            }
        }
    }
    
    // MARK: Friend request sent
    func sentFriendRequest(params: [String: Any], indexPath: IndexPath) {
        networkManager.sendFriendRequest(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.friendRequestSentResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSentFriendRequest?(indexPath: indexPath)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.friendRequestSentResponse = nil
                strongSelf.delegateNetworkResponse?.didSentFriendRequest?(indexPath: indexPath)
            }
        }
    }
    
//    // MARK: Friend request cancelled
//    func cancelFriendRequest(params: [String: Any]) {
//        networkManager.cancelFriendRequest(params: params) { [weak self] result in
//
//            guard let strongSelf = self else { return }
//
//            switch result {
//
//            case .success(let apiResponse):
//                print(apiResponse)
//                strongSelf.friendRequestCancelResponse = apiResponse
//                strongSelf.delegateNetworkResponse?.didCancelFriendRequest?()
//
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    // MARK: Get Friends list
    func getFriendsList(pageNumber: Int, searchText: String) {
        networkManager.getFriendsList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.friendListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetFriendsList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.friendListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetFriendsList?()
            }
        }
    }
    
    // MARK: Get Pending Friends list
    func getPendingFriendsList(pageNumber: Int, searchText: String) {
        networkManager.getPendingFriendsList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.pendingFriendsListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPendingFriendsList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.pendingFriendsListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPendingFriendsList?()
            }
        }
    }
    
    // MARK: Get Block Friends list
    func getBlockFriendsList(pageNumber: Int, searchText: String) {
        networkManager.getBlockFriendsList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getBlockFriendListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetBlockFriendList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getBlockFriendListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetBlockFriendList?()
            }
        }
    }

    // MARK: Block a friend
    func blockFriend(params: [String: Any], object: AnyObject) {
        networkManager.blockFriend(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.blockFriendResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didBlockedFriend?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.blockFriendResponse = nil
                strongSelf.delegateNetworkResponse?.didBlockedFriend?(object: object)
            }
        }
    }
    
    // MARK: Unblock a friend
    func unblockFriend(params: [String: Any], object: AnyObject) {
        networkManager.unblockFriend(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.unblockFriendResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didUnblockFriend?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.unblockFriendResponse = nil
                strongSelf.delegateNetworkResponse?.didUnblockFriend?(object: object)
            }
        }
    }
    
//    // MARK: Send Friend Request List (Pending)
//    func getPendingFriendRequestsList(pageNumber: Int, searchText: String) {
//        networkManager.getPendingSendRequestsList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
//            
//            guard let strongSelf = self else { return }
//            
//            switch result {
//                
//            case .success(let apiResponse):
//                print(apiResponse)
//                strongSelf.getPendingSendRequestsListResponse = apiResponse
//                strongSelf.delegateNetworkResponse?.didGetPendingSendRequestsList?()
//                
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    // MARK: Accept Friend Invite Request
    func acceptFriendInviteRequest(params: [String: Any], object: AnyObject) {
        networkManager.acceptFriendInviteRequest(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.acceptFriendInviteRequestResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didAcceptFriendInviteRequest?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.acceptFriendInviteRequestResponse = nil
                strongSelf.delegateNetworkResponse?.didAcceptFriendInviteRequest?(object: object)
            }
        }
    }
    
    // MARK: Remove Friend
    func removeFriend(params: [String: Any], object: AnyObject) {
        networkManager.removeFriend(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.removeFriendResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRemovedFriend?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.removeFriendResponse = nil
                strongSelf.delegateNetworkResponse?.didRemovedFriend?(object: object)
            }
        }
    }
    
    // MARK: Reject Friend Invite Request
    func rejectFriendInviteRequest(params: [String: Any], object: AnyObject) {
        networkManager.rejectFriendInviteRequest(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.rejectFriendInviteRequestResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRejectFriendInviteRequest?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.rejectFriendInviteRequestResponse = nil
                strongSelf.delegateNetworkResponse?.didRejectFriendInviteRequest?(object: object)
            }
        }
    }
    
    // MARK: Get View Profile Details
    func getViewProfileDetails(profileIdentifier: String) {
        networkManager.viewProfileDetails(profileIdentifier: profileIdentifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.viewProfileDetailsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetViewProfileDetails?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.viewProfileDetailsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetViewProfileDetails?()
            }
        }
    }
    
    // MARK: ============================= Circle =============================
    
    // MARK: Create Circle
    func createCircle(memberIds: String, circleName: String, imageFile: Data?) {
        networkManager.createCircle(memberIds: memberIds, circleName: circleName, imageFile: imageFile) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.createCircleResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didCreateCircle?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.createCircleResponse = nil
                strongSelf.delegateNetworkResponse?.didCreateCircle?()
            }
        }
    }
    
    // MARK: Create Circle V2
    func createCircleV2(memberIds: String, circleName: String, imageFile: Data, circleCategory: String, privacy: Int) {
        networkManager.createCircleV2(memberIds: memberIds, circleName: circleName, imageFile: imageFile, circleCategory: circleCategory, privacy: privacy) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.createCircleV2Response = apiResponse
                strongSelf.delegateNetworkResponse?.didCreateCircleV2?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.createCircleV2Response = nil
                strongSelf.delegateNetworkResponse?.didCreateCircleV2?()
            }
        }
    }
    
    // MARK: Edit Circle V2
    func editCircleV2(id: Int, memberIds: String, circleName: String, imageFile: Data?, circleCategory: String, privacy: Int) {
        networkManager.editCircleV2(id: id, memberIds: memberIds, circleName: circleName, imageFile: imageFile, circleCategory: circleCategory, privacy: privacy) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.editCircleV2Response = apiResponse
                strongSelf.delegateNetworkResponse?.didEditCircleV2?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.editCircleV2Response = nil
                strongSelf.delegateNetworkResponse?.didEditCircleV2?()
            }
        }
    }
    
    // MARK: Get Circle List (Explore Circle)
    func getCircleList(pageNumber: Int, searchText: String) {
        networkManager.getCircleList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.circleListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCircleList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.circleListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCircleList?()
            }
        }
    }
    
    // MARK: Circle request sent
    func sendCircleJoinRequest(params: [String: Any], indexPath: IndexPath) {
        networkManager.sendCircleJoinRequest(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.circleJoinRequestSentResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSentCircleJoinRequest?(indexPath: indexPath)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.circleJoinRequestSentResponse = nil
                strongSelf.delegateNetworkResponse?.didSentCircleJoinRequest?(indexPath: indexPath)
            }
        }
    }
    
    // MARK: Change discovery state
    func changeDiscoveryState() {
        networkManager.isDiscoverable() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.discoveryStateChangeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didChangeDiscoverableState?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.discoveryStateChangeResponse = nil
                strongSelf.delegateNetworkResponse?.didChangeDiscoverableState?()
            }
        }
    }
    
    // MARK: Get Joined Circle List (may include my own circles)
    func getJoinedCircleList(pageNumber: Int, searchText: String, category: String) {
        networkManager.getJoinedCircleList(pageNumber: pageNumber, searchText: searchText, category: category) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.joinedCircleListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetJoinedCircleList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.joinedCircleListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetJoinedCircleList?()
            }
        }
    }
    
    // MARK: Get Pending Circle Join list
    func getPendingCircleJoinList(circleIdentifier: String, pageNumber: Int, searchText: String) {
        networkManager.getPendingCircleList(circleIdentifier: circleIdentifier, pageNumber: pageNumber, searchText: searchText) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.pendingCircleJoinListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPendingCircleJoinList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.pendingCircleJoinListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPendingCircleJoinList?()
            }
        }
    }
    
    // MARK: Accept Circle Join Request
    func acceptCircleJoinRequest(inviteId: Int, object: AnyObject) {
        networkManager.acceptCircleJoinRequest(inviteId: inviteId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.acceptCircleJoinRequestResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didAcceptCircleJoinRequest?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.acceptCircleJoinRequestResponse = nil
                strongSelf.delegateNetworkResponse?.didAcceptCircleJoinRequest?(object: object)
            }
        }
    }
    
    // MARK: Reject Circle Join Request
    func rejectCircleJoinRequest(inviteId: Int, object: AnyObject) {
        networkManager.rejectCircleJoinRequest(inviteId: inviteId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.rejectCircleJoinRequestResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRejectCircleJoinRequest?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.rejectCircleJoinRequestResponse = nil
                strongSelf.delegateNetworkResponse?.didRejectCircleJoinRequest?(object: object)
            }
        }
    }
    
    // MARK: Get Poll Duration List
    func getPollDurationList() {
        networkManager.getPollDurationList() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getPollDurationListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPollDurationList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getPollDurationListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPollDurationList?()
            }
        }
    }
    
    // MARK: Create Poll
    func createPoll(params: [String: Any]) {
        networkManager.createPoll(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.createPollResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didCreatePoll?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.createPollResponse = nil
                strongSelf.delegateNetworkResponse?.didCreatePoll?()
            }
        }
    }
    
    // MARK: Get Pending Circle Invite list
    func getPendingCircleInviteList(pageNumber: Int, searchText: String) {
        networkManager.getPendingCircleInviteList(pageNumber: pageNumber, searchText: searchText) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.pendingCircleInviteListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPendingCircleInviteList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.pendingCircleInviteListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPendingCircleInviteList?()
            }
        }
    }
    
    // MARK: Accept Circle Invite Request
    func acceptCircleInviteRequest(inviteId: Int, object: AnyObject) {
        networkManager.acceptCircleInviteRequest(inviteId: inviteId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                
                strongSelf.acceptCircleInviteRequestResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didAcceptCircleInviteRequest?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.acceptCircleInviteRequestResponse = nil
                strongSelf.delegateNetworkResponse?.didAcceptCircleInviteRequest?(object: object)
            }
        }
    }
    
    // MARK: Reject Circle Invite Request
    func rejectCircleInviteRequest(inviteId: Int, object: AnyObject) {
        networkManager.rejectCircleInviteRequest(inviteId: inviteId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.rejectCircleInviteRequestResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRejectCircleInviteRequest?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.rejectCircleInviteRequestResponse = nil
                strongSelf.delegateNetworkResponse?.didRejectCircleInviteRequest?(object: object)
            }
        }
    }
    
    // MARK: Get Circle New Poll List
    func getCircleNewPollList(circleIdentifier: String) {
        networkManager.getCircleNewPollList(circleIdentifier: circleIdentifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getCircleNewPollListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCircleNewPollList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getCircleNewPollListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCircleNewPollList?()
            }
        }
    }
    
    // MARK: Submit Poll Answer
    func submitPollAnswer(params: [String: Any], indexPath: IndexPath, pollObject: AnyObject) {
        networkManager.submitPollAnswer(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.submitPollAnswerResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSubmitPollAnswer?(indexPath: indexPath, pollObject: pollObject)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.submitPollAnswerResponse = nil
                strongSelf.delegateNetworkResponse?.didSubmitPollAnswer?(indexPath: indexPath, pollObject: pollObject)
            }
        }
    }
    
    // MARK: Get Friends to Invite to a Circle List
    func getFriendsToInviteToCircleList(circleId: Int) {
        
        networkManager.getFriendsToInviteToCircleList(circleId: circleId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getFriendsToInviteToCircleListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetFriendsToInviteToCircleList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getFriendsToInviteToCircleListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetFriendsToInviteToCircleList?()
            }
        }
    }
    
    // MARK: Invite a Friend to Circle
    func inviteFriendToCircle(status: Bool, toUserId: Int, circleId: Int, indexPath: IndexPath, isInvitedInitialState: Bool) {
        networkManager.inviteFriendToCircle(status: status, toUserId: toUserId, circleId: circleId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.inviteFriendToCircleResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didInviteFriendToCircle?(indexPath: indexPath, isInvitedInitialState: isInvitedInitialState)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.inviteFriendToCircleResponse = nil
                strongSelf.delegateNetworkResponse?.didInviteFriendToCircle?(indexPath: indexPath, isInvitedInitialState: isInvitedInitialState)
            }
        }
    }
    
    // MARK: Get Circle Past Poll List
    func getCirclePastPollList(circleIdentifier: String) {
        networkManager.getCirclePastPollList(circleIdentifier: circleIdentifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getCirclePastPollListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCirclePastPollList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getCirclePastPollListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCirclePastPollList?()
            }
        }
    }
    
    // MARK: Get Circle Details
    func getCircleDetails(identifier: String) {
        networkManager.getCircleDetails(identifier: identifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.circleDetailsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCircleDetails?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.circleDetailsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCircleDetails?()
            }
        }
    }
    
    // MARK: Get Circle Members By Circle Ids List
    func getCircleMembersByCircleIdsList(params: [String: Any]) {
        networkManager.getCircleMembersByCircleIdsList(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.didGetCircleMemberByCircleIdsListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCircleMembersByCircleIdsList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.didGetCircleMemberByCircleIdsListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCircleMembersByCircleIdsList?()
            }
        }
    }
    
    // MARK: Get Circle Polls By Circle Ids List
    func getCirclePollsByCircleIdsList(params: [String: Any]) {
        networkManager.getCirclePollsByCircleIdsList(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.didGetCirclePollsByCircleIdsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCirclePollsByCircleIdsList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.didGetCirclePollsByCircleIdsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCirclePollsByCircleIdsList?()
            }
        }
    }
    
    // MARK: Intersect 2 or more circles
    func intersectCircles(circleIds: [Int], imageFile: Data, circleName: String, memberIds: [Int], pollIds: [Int], circleCategory: String, privacy: Int) {
        networkManager.createCircleIntersection(circleIds: circleIds, imageFile: imageFile, circleName: circleName, memberIds: memberIds, pollIds: pollIds, circleCategory: circleCategory, privacy: privacy) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.intersectCircleResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didIntersectCircles?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.intersectCircleResponse = nil
                strongSelf.delegateNetworkResponse?.didIntersectCircles?()
            }
        }
    }
    
    // MARK: Get Circle Member List
    func getCircleMemberList(circleId: Int, pageNumber: Int, searchText: String) {
        networkManager.getCircleMemberList(circleId: circleId, pageNumber: pageNumber, searchText: searchText) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.circleMemberListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCircleMemberList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.circleMemberListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCircleMemberList?()
            }
        }
    }
    
    // MARK: Get user list on particular poll option
    func getUserListOnPollOption(pollId: Int, optionId: Int) {
        networkManager.getUserListPollOption(pollId: pollId, optionId: optionId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.userListPollOptionResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetUserListOnPollOption?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.userListPollOptionResponse = nil
                strongSelf.delegateNetworkResponse?.didGetUserListOnPollOption?()
            }
        }
    }
    
    // MARK: Get trending circle category list
    func getTrendingCircleCategoryList(search: String) {
        
        networkManager.trendingCircleCategoryList(search: search) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.trendingCircleCategoryListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetTrendingCircleCategoryList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.trendingCircleCategoryListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetTrendingCircleCategoryList?()
            }
        }
    }
    
    // MARK: Delete circle poll
    func deleteCirclePoll(pollId: Int, object: AnyObject) {
        
        networkManager.deleteCirclePoll(pollId: pollId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.deleteCirclePollResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDeleteCirclePoll?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.deleteCirclePollResponse = nil
                strongSelf.delegateNetworkResponse?.didDeleteCirclePoll?(object: object)
            }
        }
    }
    
    
    
    // MARK: Get Wallet Detail
    func getWalletDetail() {
        networkManager.getWalletDetail { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.walletDetailResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetWalletDetail?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.walletDetailResponse = nil
                strongSelf.delegateNetworkResponse?.didGetWalletDetail?()
            }
        }
    }
    
    // MARK: Crypto Withdraw
    func cryptoWithdraw(params: [String: Any]) {
        networkManager.cryptoWithdraw(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.cryptoWithdrawResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didCryptoWithdraw?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.cryptoWithdrawResponse = nil
                strongSelf.delegateNetworkResponse?.didCryptoWithdraw?()
            }
        }
    }
    
    // MARK: Transfer to Friend
    func transferToFriend(params: [String: Any]) {
        networkManager.transferToFriend(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.transferToFriendResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didTransferToFriend?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.transferToFriendResponse = nil
                strongSelf.delegateNetworkResponse?.didTransferToFriend?()
            }
        }
    }
    
    // MARK: Get Transaction List
    func getTransactionList(fromDate: String, toDate: String, transType: String, pageNumber: Int) {
        networkManager.getMyTransactionList(fromDate: fromDate, toDate: toDate, transType: transType, pageNumber: pageNumber) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.transactionListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetTransactionList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.transactionListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetTransactionList?()
            }
        }
    }
    
    // MARK: Get Stripe Card List
    func getStripeCardList() {
        networkManager.getStripeCardList() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.stripeCardListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetStripeCardList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.stripeCardListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetStripeCardList?()
            }
        }
    }
    
    
    // MARK: Get Payment Intent (Stripe)
    func getPaymentIntent() {
        networkManager.getPaymentIntent() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.paymentIntentStripeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPaymentIntentStripe?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.paymentIntentStripeResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPaymentIntentStripe?()
            }
        }
    }
    
    
//    // MARK: Save User Card (Stripe)
//    func saveUserCardStripe(params: [String: Any]) {
//        networkManager.saveUserCardStripe(params: params) { [weak self] result in
//
//            guard let strongSelf = self else { return }
//
//            switch result {
//
//            case .success(let apiResponse):
//                print(apiResponse)
//                strongSelf.userCardSaveStripeResponse = apiResponse
//                strongSelf.delegateNetworkResponse?.didSaveUserCardStripe?()
//
//            case .failure(let error):
//                print(error.localizedDescription)
//                strongSelf.delegateNetworkResponse?.didSaveUserCardStripe?()
//            }
//        }
//    }
    
    
    // MARK: Make Default Card (Stripe)
    func makeDefaultCardStripe(params: [String: Any]) {
        networkManager.makeDefaultCardStripe(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.defaultCardStripeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didMakeDefaultCardStripe?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.defaultCardStripeResponse = nil
                strongSelf.delegateNetworkResponse?.didMakeDefaultCardStripe?()
            }
        }
    }
    
    // MARK: Deposit with New card (Stripe)
    func depositWithNewCardStripe(params: [String: Any]) {
        networkManager.depositWithNewCardStripe(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.depositWithNewCardStripeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDepositWithNewCardStripe?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.depositWithNewCardStripeResponse = nil
                strongSelf.delegateNetworkResponse?.didDepositWithNewCardStripe?()
            }
        }
    }
    
    // MARK: Deposit with default card (Stripe)
    func depositWithDefaultCardStripe(params: [String: Any]) {
        networkManager.depositWithDefaultCardStripe(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.depositWithDefaultCardStripeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDepositWithDefaultCardStripe?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.depositWithDefaultCardStripeResponse = nil
                strongSelf.delegateNetworkResponse?.didDepositWithDefaultCardStripe?()
            }
        }
    }
    
    // MARK: Save User Checkout details (PayPal)
    func saveCheckoutOrderDetailPayPal(params: [String: Any]) {
        networkManager.saveCheckoutOrderDetailPayPal(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.checkoutPayPalResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSaveCheckoutDetailPayPal?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.checkoutPayPalResponse = nil
                strongSelf.delegateNetworkResponse?.didSaveCheckoutDetailPayPal?()
            }
        }
    }
    
    // MARK: Get Bank Account List
    func getBankAccountList() {
        networkManager.getBankAccountList() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.bankAccountListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetBankAccountList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.bankAccountListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetBankAccountList?()
            }
        }
    }
    
    // MARK: Withdraw Amount To Bank Account
    func withdrawAmountToBankAccount(params: [String: Any]) {
        networkManager.withdrawAmountToBankAccount(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.withdrawAmountToBankResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didWithdrawAmountToBank?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.withdrawAmountToBankResponse = nil
                strongSelf.delegateNetworkResponse?.didWithdrawAmountToBank?()
            }
        }
    }
    
    // MARK: Remove Bank Account
    func removeBankAccount(accountIdentifier: String, object: AnyObject) {
        networkManager.removeBankAccount(accountIdentifier: accountIdentifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.removeBankAccountResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRemoveBankAccount?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.removeBankAccountResponse = nil
                strongSelf.delegateNetworkResponse?.didRemoveBankAccount?(object: object)
            }
        }
    }
    
    
    // MARK: Get Country List
    func getCountryList() {
        networkManager.getCountryList() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.countryListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCountryList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.countryListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCountryList?()
            }
        }
    }
    
    // MARK: Create Bank Account
    func createBankAccount(accHolderName: String, accNumber: String, routingNumber: String, city: String, country: String, line1: String, line2: String, state: String, postalCode: String, ssn: String, dob: String, documentFile: Data) {
        networkManager.createBankAccount(accHolderName: accHolderName, accNumber: accNumber, routingNumber: routingNumber, city: city, country: country, line1: line1, line2: line2, state: state, postalCode: postalCode, ssn: ssn, dob: dob, documentFile: documentFile) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.bankAccountCreateResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didCreateBankAccount?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.bankAccountCreateResponse = nil
                strongSelf.delegateNetworkResponse?.didCreateBankAccount?()
            }
        }
    }
    
    // MARK: Get Notification List
    func getNotificationList(pageNumber: Int) {
        networkManager.getNotificationList(pageNumber: pageNumber) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.notificationListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetNotificationList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.notificationListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetNotificationList?()
            }
        }
    }
    
//    // MARK: Mark as read Notification
//    func markAsReadNotification(notificationId: Int) {
//        networkManager.markAsReadNotification(notificationId: notificationId) { [weak self] result in
//
//            guard let strongSelf = self else { return }
//
//            switch result {
//
//            case .success(let apiResponse):
//                print(apiResponse)
//                strongSelf.markAsReadResponse = apiResponse
//                strongSelf.delegateNetworkResponse?.didMarkedAsReadNotification?()
//
//            case .failure(let error):
//                print(error.localizedDescription)
//                strongSelf.delegateNetworkResponse?.didMarkedAsReadNotification?()
//            }
//        }
//    }
    
    
    // MARK: Save Post
    func savePost(content: String, privacy: String, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int) {
        
        networkManager.savePost(content: content, privacy: privacy, imageFiles: imageFiles, videoFiles: videoFiles, videoThumbnails: videoThumbnails, deletePostMediaIds: deletePostMediaIds, postId: postId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.addPostResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didAddPost?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.addPostResponse = nil
                strongSelf.delegateNetworkResponse?.didAddPost?()
            }
        }
    }
    
    // MARK: Save Post V2
    func savePostV2(content: String, privacyType: Int, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int, friendIds: [Int], shareWithFriendIds: [Int]) {
        
        networkManager.savePostV2(content: content, privacyType: privacyType, imageFiles: imageFiles, videoFiles: videoFiles, videoThumbnails: videoThumbnails, deletePostMediaIds: deletePostMediaIds, postId: postId, friendIds: friendIds, shareWithFriendIds: shareWithFriendIds) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.addPostResponseV2 = apiResponse
                strongSelf.delegateNetworkResponse?.didAddPostV2?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.addPostResponseV2 = nil
                strongSelf.delegateNetworkResponse?.didAddPostV2?()
            }
        }
    }
    
    
    
    // MARK: Get Post(Feed) List
    func getPostList(pageNumber: Int, pageLimit: Int = Utils.feedsPageLimit, postId: Int, postIdentifier: String = "", profileIdentifier: String, hashtag: String) {
        
        networkManager.getPostList(pageNumber: pageNumber, pageLimit: pageLimit, postId: postId, postIdentifier: postIdentifier, profileIdentifier: profileIdentifier, hashtag: hashtag) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.postListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPostList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.postListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPostList?()
            }
        }
    }
    
    // MARK: Get Comment List
    func getCommentList(pageNumber: Int, postId: Int, commentId: Int) {
        networkManager.getCommentList(pageNumber: pageNumber, postId: postId, commentId: commentId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.commentListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCommentList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.commentListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCommentList?()
            }
        }
    }
    
    // MARK: Get Reply List
    func getReplyList(pageNumber: Int, postId: Int, replyId: Int, commentId: Int) {
        networkManager.getReplyList(pageNumber: pageNumber, postId: postId, replyId: replyId, commentId: commentId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.replyListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetReplyList?(commentId: commentId)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.replyListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetReplyList?(commentId: commentId)
            }
        }
    }
    
    // MARK: Save Comment Reply
    func saveCommentReply(params: [String: Any]) {
        networkManager.saveCommentReply(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.saveCommentReplyResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSaveCommentReply?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.saveCommentReplyResponse = nil
                strongSelf.delegateNetworkResponse?.didSaveCommentReply?()
            }
        }
    }
    
    // MARK: Save Like
    func saveLike(params: [String: Any], object: AnyObject, sourceType: Int, replyId: Int) {
        networkManager.saveLike(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.saveLikeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSaveLike?(object: object, sourceType: sourceType, replyId: replyId)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.saveLikeResponse = nil
                strongSelf.delegateNetworkResponse?.didSaveLike?(object: object, sourceType: sourceType, replyId:  replyId)
            }
        }
    }
    
    
    // MARK: Delete Post
    func deletePost(postId: Int, object: AnyObject) {
        networkManager.deletePost(postId: postId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.deletePostResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDeletePost?(object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.deletePostResponse = nil
                strongSelf.delegateNetworkResponse?.didDeletePost?(object: object)
            }
        }
    }
    
    // MARK: Delete Comment
    func deleteComment(commentId: Int) {
        networkManager.deleteComment(commentId: commentId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.deleteCommentResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDeleteComment?(commentId: commentId)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.deleteCommentResponse = nil
                strongSelf.delegateNetworkResponse?.didDeleteComment?(commentId: commentId)
            }
        }
    }
    
    
    
    // MARK: Delete Reply
    func deleteReply(replyId: Int, object: AnyObject) { // Parent object i.e: Comment Object
        networkManager.deleteReply(replyId: replyId) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.deleteReplyResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDeleteReply?(replyId: replyId, object: object)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.deleteReplyResponse = nil
                strongSelf.delegateNetworkResponse?.didDeleteReply?(replyId: replyId, object: object)
            }
        }
    }
    
    
    
    
    // MARK: Edit Comment
    func editComment(params: [String: Any], originalComment: String) {
        networkManager.editComment(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.editCommentResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didEditComment?(commentId: params["commentID"] as! Int, originalComment: originalComment)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.editCommentResponse = nil
                strongSelf.delegateNetworkResponse?.didEditComment?(commentId: params["commentID"] as! Int, originalComment: originalComment)
            }
        }
    }
    
    // MARK: Edit Reply
    func editReply(params: [String: Any], originalReply: String) {
        networkManager.editReply(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.editReplyResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didEditReply?(commentId: params["commentID"] as! Int, replyId: params["replyID"] as! Int, originalReply: originalReply)
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.editReplyResponse = nil
                strongSelf.delegateNetworkResponse?.didEditReply?(commentId: params["commentID"] as! Int, replyId: params["replyID"] as! Int, originalReply: originalReply)
            }
        }
    }
    
    
    // MARK: Get Report Type List
    func getReportTypeList() {
        networkManager.getReportTypeList { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.reportTypeListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetReportTypeList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.reportTypeListResponse = nil
                strongSelf.delegateNetworkResponse?.didGetReportTypeList?()
            }
        }
    }
    
    // MARK: Save Report
    func saveReport(params: [String: Any]) {
        networkManager.saveReport(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.saveReportResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSaveReport?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.saveReportResponse = nil
                strongSelf.delegateNetworkResponse?.didSaveReport?()
            }
        }
    }
    
    
    // MARK: - Get User Details
    func getUserDetails() {
        networkManager.getUserDetails() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.userDetailsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetUserDetails?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.userDetailsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetUserDetails?()
            }
        }
    }
    
    // MARK: - Update User Profile
    func updateProfile(userDetail: UserDetailDM) {
        
        networkManager.updateProfile(userDetail: userDetail) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.updateProfileResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didUpdateProfile?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.updateProfileResponse = nil
                strongSelf.delegateNetworkResponse?.didUpdateProfile?()
            }
        }
    }
    
    // MARK: Get Chat list
    func getChatsList(pageNumber: Int, searchText: String) {
        networkManager.getMessagesList(pageNumber: pageNumber, searchText: searchText){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.chatListResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didReceiveChatList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.chatListResponse = nil
                strongSelf.delegateNetworkResponse?.didReceiveChatList?()
            }
        }
    }
    
    // MARK: Get Chat
    func getChat(pageNumber: Int, identifier: String, isCircle: Bool) {
        networkManager.getChat(pageNumber: pageNumber, identifier: identifier, isCircle: isCircle){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.chatResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didReceiveChat?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.chatResponse = nil
                strongSelf.delegateNetworkResponse?.didReceiveChat?()
            }
        }
    }
    
    
    // MARK: Send Message
    func sendMessage(identifier: String, isCircle: Bool, message: String) {
        networkManager.sendMessage(identifier: identifier, isCircle: isCircle, message: message){ [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.sendMessageResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSendMessage?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.sendMessageResponse = nil
                strongSelf.delegateNetworkResponse?.didSendMessage?()
            }
        }
    }
    
    // MARK: Send Message
    func deleteMessages(identifier: String, indexPath: IndexPath) {
        networkManager.deleteMessages(identifier: identifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.deleteMessagesResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDeleteMessages?(indexPath: indexPath)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.deleteMessagesResponse = nil
                strongSelf.delegateNetworkResponse?.didDeleteMessages?(indexPath: indexPath)
            }
        }
    }
    
    // MARK: Get Past Polls For Avatar Screen
    func getPastPolls(pageNumber: Int, pageLimit: Int){
        networkManager.getPastPolls(pageNumber: pageNumber, pageLimit: pageLimit) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.pastPollsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didReceivePastPolls?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.pastPollsResponse = nil
                strongSelf.delegateNetworkResponse?.didReceivePastPolls?()
            }
        }
    }
    
    // MARK: Update Poll Privacy
    func updatePollPrivacy(pollResponseId: Int, privacy: Int){
        networkManager.updatePollPrivacy(pollResponseId: pollResponseId, privacy: privacy) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.updatePollPrivacyResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didUpdatePollPrivacy?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.updatePollPrivacyResponse = nil
                strongSelf.delegateNetworkResponse?.didUpdatePollPrivacy?()
            }
        }
    }
    
    // MARK: Remove Answered Poll Option
    func removeAnsweredPollOption(pollResponseId: Int, object: AnyObject) {
        networkManager.removeAnsweredPollOption(pollResponseId: pollResponseId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.removeAnsweredPollOptionResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didRemoveAnsweredPollOption?(id: pollResponseId, object: object)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.removeAnsweredPollOptionResponse = nil
                strongSelf.delegateNetworkResponse?.didRemoveAnsweredPollOption?(id: pollResponseId, object: object)
            }
        }
    }
    
    // MARK: - Get Avatar Props By Gender List
    func getAvatarPropsByGenderList() {
        networkManager.getAllAvatarPropsByGender { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.avatarPropsByGenderResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetAllAvatarPropsByGender?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.avatarPropsByGenderResponse = nil
                strongSelf.delegateNetworkResponse?.didGetAllAvatarPropsByGender?()
            }
        }
    }
    
    // MARK: Get Current Avatar
    func getCurrentAvatar(refreshPollList: Bool) {
        networkManager.getCurrentAvatar { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.currentAvatarResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetCurrentAvatar?(refreshPollList: refreshPollList)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.currentAvatarResponse = nil
                strongSelf.delegateNetworkResponse?.didGetCurrentAvatar?(refreshPollList: refreshPollList)
            }
        }
    }
    
    
    // MARK: Save User Avatar
    func saveUserAvatar(params: [String: Any]) {
        networkManager.saveUserAvatar(params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.saveUserAvatarResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSaveUserAvatar?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.saveUserAvatarResponse = nil
                strongSelf.delegateNetworkResponse?.didSaveUserAvatar?()
            }
        }
    }
    
    // MARK: Get Terms and Conditions
    func getTermsNConditions() {
        networkManager.getTermsNConditions { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.termsNConditionsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetTermsNConditions?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.termsNConditionsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetTermsNConditions?()
            }
        }
    }
    
    // MARK: Get Privacy Policy
    func getPrivacyPolicy() {
        networkManager.getPrivacyPolicy { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.privacyPolicyResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPrivacyPolicy?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.privacyPolicyResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPrivacyPolicy?()
            }
        }
    }
    
    // MARK: Contact Us
    func contactUs(params: [String: Any]) {
        networkManager.contactUs(params: params) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.contactUsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didContactUs?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.contactUsResponse = nil
                strongSelf.delegateNetworkResponse?.didContactUs?()
            }
        }
    }
    
    // MARK: Start Call Session
    func startCallSession(callTo: String, callType: Int) {
        networkManager.startCallSession(callTo: callTo, callType: callType) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.startCallSessionResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didStartCallSession?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.startCallSessionResponse = nil
                strongSelf.delegateNetworkResponse?.didStartCallSession?()
            }
        }
    }
    
    // MARK: Group Call Host Stop
    func groupCallHostStop(broadcastId: String) {
        networkManager.groupCallHostStop(broadcastId: broadcastId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.groupCallHostStopResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGroupCallHostStop?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.groupCallHostStopResponse = nil
                strongSelf.delegateNetworkResponse?.didGroupCallHostStop?()
            }
        }
    }
    
    // MARK: Call Member Stop
    func callMemberStop() {
        PreferencesManager.saveCallState(isCallActivated: false)
        networkManager.callMemberStop { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.callMemberStopResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didCallMemberStop?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.callMemberStopResponse = nil
                strongSelf.delegateNetworkResponse?.didCallMemberStop?()
            }
        }
    }
    
    // MARK: Group Call Session
    func startGroupCallSession(callToCircle: String, callType: Int, callMembers: String, isVideoCalling: Bool) {
        networkManager.groupCallSession(callToCircle: callToCircle, callType: callType, callMembers: callMembers) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.groupCallSessionResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetGroupCallSession?(isVideoCalling: isVideoCalling)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.groupCallSessionResponse = nil
                strongSelf.delegateNetworkResponse?.didGetGroupCallSession?(isVideoCalling: isVideoCalling)
            }
        }
    }
    
    // MARK: Group Call Session
    func startGroupCallSession(callToCircle: String, callType: Int, callMembers: String) {
        networkManager.groupCallSession(callToCircle: callToCircle, callType: callType, callMembers: callMembers) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.groupCallSessionResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetGroupCallSession?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.groupCallSessionResponse = nil
                strongSelf.delegateNetworkResponse?.didGetGroupCallSession?()
            }
        }
    }
    
    
    // MARK: BroadCast Call
    func broadCastCall(callIdentifier: String, circleIdentifier: String) {
        networkManager.broadCastCall(callIdentifier: callIdentifier, circleIdentifier: circleIdentifier) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.broadCastCallResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didBroastCastCall?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.broadCastCallResponse = nil
                strongSelf.delegateNetworkResponse?.didBroastCastCall?()
            }
        }
    }
    
    // MARK: Receive Call
    func receiveCall() {
        networkManager.callReceived() { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.receiveCallResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didReceiveCall?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.receiveCallResponse = nil
                strongSelf.delegateNetworkResponse?.didReceiveCall?()
            }
        }
    }
    
    
    
    
    // MARK: Resend transfer code
    func resendTransferCode() {
        networkManager.resendTransferCode() { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.resendTransferCodeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didResendTransferCode?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.resendTransferCodeResponse = nil
                strongSelf.delegateNetworkResponse?.didResendTransferCode?()
            }
        }
    }
    
    
    
    
    // MARK: Get privacy settings
    func getPrivacySettings() {
        networkManager.getPrivacySettings() { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.privacySettingsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetPrivacySettings?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.privacySettingsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetPrivacySettings?()
            }
        }
    }
    
    // MARK: Change privacy settings
    func changePrivacySettings(params: [String: Any], currentPrivacyText: String) {
        
        networkManager.changePrivacySettings(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.changePrivacyResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didChangePrivacySettings?(privacyType: params["privacyType"]!, currentPrivacyText: currentPrivacyText)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.changePrivacyResponse = nil
                strongSelf.delegateNetworkResponse?.didChangePrivacySettings?(privacyType: params["privacyType"]!, currentPrivacyText: currentPrivacyText)
            }
        }
    }
    
    // MARK: Resend two factor authentication code
    func resend2FACode(identifier: String) {
        
        networkManager.resend2FACode(identifier: identifier) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.resend2FACodeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didResend2FACode?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.resend2FACodeResponse = nil
                strongSelf.delegateNetworkResponse?.didResend2FACode?()
            }
        }
    }
    
    // MARK: Change two factor authentication (enable/disable)
    func changeTwoFactorAuthentication(isEnabled: Bool) {
        
        networkManager.changeTwoFactorAuthentication(isEnabled: isEnabled) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.changeTwoFactorAuthenticationResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didChangeTwoFactorAuthentication?(isEnabled: isEnabled)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.changeTwoFactorAuthenticationResponse = nil
                strongSelf.delegateNetworkResponse?.didChangeTwoFactorAuthentication?(isEnabled: isEnabled)
            }
        }
    }
    
    // MARK: Verify transfer code
    func verifyTransferCode(code: String) {
        
        networkManager.verifyTransferCode(code: code) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.verifyTransferCodeResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didVerifyTransferCode?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.verifyTransferCodeResponse = nil
                strongSelf.delegateNetworkResponse?.didVerifyTransferCode?()
            }
        }
    }
    
    
    
    // MARK: Get Upload Options
    func getUploadOptions() {
        
        networkManager.getUploadOptions() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getUploadOptionsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.diduploadOptions?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getUploadOptionsResponse = nil
                strongSelf.delegateNetworkResponse?.diduploadOptions?()
            }
        }
    }
    
    
    // MARK: uploadVerification Document
    func uploadIdentificationDoc(frontImage: Data, backImage: Data?) {
        
        networkManager.postIdentityVerificationDoc(frontImage: frontImage, backImage: backImage) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.identityVerificationDocResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didIdentityVerificationDoc?()
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.identityVerificationDocResponse = nil
                strongSelf.delegateNetworkResponse?.didIdentityVerificationDoc?()
            }
        }
    }
    
    
    
    
    // MARK: Customized Response
    
    // MARK: Notification Count
    func getNotificationCount(recordCount: @escaping(Int)->Void) {
        
        networkManager.getNotificationCount() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.notificationCountResponse = apiResponse
                recordCount(strongSelf.notificationCountResponse?.recordCount ?? 0)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.notificationCountResponse = nil
                recordCount(strongSelf.notificationCountResponse?.recordCount ?? 0)
            }
        }
    }
    
    // MARK: Get Wallet Balance
    func getWalletBalance(walletBalance: @escaping(Double?)->Void) {
        
        networkManager.getWalletBalance() { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.walletBalanceResponse = apiResponse
                walletBalance(strongSelf.walletBalanceResponse?.data)
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.walletBalanceResponse = nil
                walletBalance(strongSelf.walletBalanceResponse?.data)
            }
        }
    }
    
    // MARK: Get List of subscription packages
    func getSubscriptionPackages() {
        networkManager.getSubscriptionsList { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getSubscriptionPackagesResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetSubscriptionList?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getSubscriptionPackagesResponse = nil
                strongSelf.delegateNetworkResponse?.didGetSubscriptionList?()
            }
        }
    }

    func getSubscriptionDetails() {
        networkManager.getSubcriptionDetail { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.getSubscriptionDetailsResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didGetSubscriptionDetails?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getSubscriptionDetailsResponse = nil
                strongSelf.delegateNetworkResponse?.didGetSubscriptionDetails?()
            }
        }
    }
    
    func subscriptionThroughWallet(params: [String: Any]) {
        networkManager.subscriptionThroughWallet(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.subscriptionThroughWalletResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSubscriptionThroughWallet?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.subscriptionThroughWalletResponse = nil
                strongSelf.delegateNetworkResponse?.didSubscriptionThroughWallet?()
            }
        }
    }
    func subscriptionThroughNewCardStripe(params: [String: Any]) {
        networkManager.subscriptionThroughNewCard(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.subscriptionThroughNewCardResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSubscriptionThroughNewCard?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.subscriptionThroughNewCardResponse = nil
                strongSelf.delegateNetworkResponse?.didSubscriptionThroughNewCard?()
            }
        }
    }
    
    func subscriptionThroughSaveCardStripe(params: [String: Any]) {
        networkManager.subscriptionThroughSaveCard(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.subscriptionThroughSaveCardResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didSubscriptionThroughSaveCard?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.getSubscriptionDetailsResponse = nil
                strongSelf.delegateNetworkResponse?.didSubscriptionThroughSaveCard?()
            }
        }
    }
    
    func postDowngradSubscription(params: [String: Any]) {
        networkManager.postDowngradSubscription(params: params) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                strongSelf.downgradSubscriptionResponse = apiResponse
                strongSelf.delegateNetworkResponse?.didDowngradSubscription?()
                
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.downgradSubscriptionResponse = nil
                strongSelf.delegateNetworkResponse?.didDowngradSubscription?()
            }
        }
    }

}
