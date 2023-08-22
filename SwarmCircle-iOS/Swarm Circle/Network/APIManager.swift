//
//  APIManager.swift
//  Swarm Circle
//
//  Created by Macbook on 03/08/2022.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON
import Moya


protocol Networkable {
//    var provider: MoyaProvider<API> { get }

    func postLogin(params: [String: Any], completion: @escaping (Result<BaseResponse<LoginDM>, Error>) -> ()) // change to userDM later.
    func postRegister(params: [String: Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ())
    func postVerify2FA(params: [String: Any], completion: @escaping (Result<BaseResponse<LoginDM>, Error>) -> ())
    func postVerifyForgetPassword(params: [String: Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ())
    func postVerifyEmail(params: [String: Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ())
    func postForgotPassword(params: [String: Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ())
    func postUpdatePassword(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func postChangePassword(params: [String : Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func postLogout(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func postDeleteAccount(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    // Friends
    
    func getUsersList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[UsersListDM]>, Error>) -> ())
    func sendFriendRequest(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
//    func cancelFriendRequest(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func getFriendsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[FriendDM]>, Error>) -> ())
    func getPendingFriendsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[PendingUserDM]>, Error>) -> ())
    
    func getBlockFriendsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[BlockedFriendDM]>, Error>) -> ())
    func blockFriend(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func unblockFriend(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
//    func getPendingSendRequestsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[UsersListDM]>, Error>) -> ())
    func acceptFriendInviteRequest(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func removeFriend(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func rejectFriendInviteRequest(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func viewProfileDetails(profileIdentifier: String, completion: @escaping (Result<BaseResponse<ViewProfileDM>, Error>) -> ())
    
    // Circle
    
    func createCircle(memberIds: String, circleName: String, imageFile: Data?, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func createCircleV2(memberIds: String, circleName: String, imageFile: Data, circleCategory: String, privacy: Int, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func editCircleV2(id: Int, memberIds: String, circleName: String, imageFile: Data?, circleCategory: String, privacy: Int, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func getCircleList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[ExploreCircleDM]>, Error>) -> ())
    func sendCircleJoinRequest(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func isDiscoverable(completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    func getJoinedCircleList(pageNumber: Int, searchText: String, category: String, completion: @escaping (Result<BaseResponse<[JoinedCircleDM]>, Error>) -> ())
    func getPendingCircleList(circleIdentifier: String, pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[PendingCircleJoinDM]>, Error>) -> ())
    func acceptCircleJoinRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func rejectCircleJoinRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func getPollDurationList(completion: @escaping (Result<BaseResponse<[PollDurationDM]>, Error>) -> ())
    func createPoll(params: [String: Any], completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    
    func getPendingCircleInviteList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[PendingCircleInviteDM]>, Error>) -> ())
    func acceptCircleInviteRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<AcceptCircleInviteDM>, Error>) -> ())
    func rejectCircleInviteRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    func getCircleNewPollList(circleIdentifier: String, completion: @escaping (Result<BaseResponse<[NewPollDM]>, Error>) -> ())
    func submitPollAnswer(params: [String: Any], completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    
    func getFriendsToInviteToCircleList(circleId: Int, completion: @escaping (Result<BaseResponse<[GetFriendListToInviteToCircleDM]>, Error>) -> ())
    func inviteFriendToCircle(status: Bool, toUserId: Int, circleId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    func getCirclePastPollList(circleIdentifier: String, completion: @escaping (Result<BaseResponse<[PastPollDM]>, Error>) -> ())
    
    func getCircleDetails(identifier: String, completion: @escaping (Result<BaseResponse<CircleDetailDM>, Error>) -> ())
    
    func getCircleMembersByCircleIdsList(params: [String: Any], completion: @escaping (Result<BaseResponse<[CircleMembersByCircleIdDM]>, Error>) -> ())
    func getCirclePollsByCircleIdsList(params: [String: Any], completion: @escaping (Result<BaseResponse<[CirclePollsByCircleIdDM]>, Error>) -> ())
    
    func createCircleIntersection(circleIds: [Int], imageFile: Data, circleName: String, memberIds: [Int], pollIds: [Int], circleCategory: String, privacy: Int, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    
    func getCircleMemberList(circleId: Int, pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[CircleMemberDM]>, Error>) -> ())
    
    func getUserListPollOption(pollId: Int, optionId: Int, completion: @escaping (Result<BaseResponse<[UserListPollOptionDM]>, Error>) -> ())
    func trendingCircleCategoryList(search: String, completion: @escaping (Result<BaseResponse<[TagDM]>, Error>) -> ())
    func deleteCirclePoll(pollId: Int, completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    
    // Wallet
    func getWalletBalance(completion: @escaping (Result<BaseResponse<Double>, Error>) -> ())
    func getWalletDetail(completion: @escaping (Result<BaseResponse<WalletDetailDM>, Error>) -> ())
    func cryptoWithdraw(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func transferToFriend(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func getMyTransactionList(fromDate: String, toDate: String, transType: String, pageNumber: Int, completion: @escaping (Result<BaseResponse<[TransactionDM]>, Error>) -> ())
    func getStripeCardList(completion: @escaping (Result<BaseResponse<[CardDM]>, Error>) -> ())
    func getPaymentIntent(completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
//    func saveUserCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func makeDefaultCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func depositWithNewCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func depositWithDefaultCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func saveCheckoutOrderDetailPayPal(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func getBankAccountList(completion: @escaping (Result<BaseResponse<[BankAccountDM]>, Error>) -> ())
    func withdrawAmountToBankAccount(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func removeBankAccount(accountIdentifier: String, completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    func getCountryList(completion: @escaping (Result<BaseResponse<[CountryDM]>, Error>) -> ())
    func createBankAccount(accHolderName: String, accNumber: String, routingNumber: String, city: String, country: String, line1: String, line2: String, state: String, postalCode: String, ssn: String, dob: String, documentFile: Data, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    
    // Notification
    func getNotificationList(pageNumber: Int, completion: @escaping (Result<BaseResponse<[NotificationDM]>, Error>) -> ())
//    func markAsReadNotification(notificationId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func getNotificationCount(completion: @escaping (Result<BaseResponse<[NotificationDM]>, Error>) -> ())
    
    // News Feed
    func savePost(content: String, privacy: String, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int, completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    func savePostV2(content: String, privacyType: Int, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int, friendIds: [Int], shareWithFriendIds: [Int], completion: @escaping (Result<BaseResponse<Int>, Error>) -> ())
    
    func getPostList(pageNumber: Int, pageLimit: Int, postId: Int, postIdentifier: String, profileIdentifier: String, hashtag: String, completion: @escaping (Result<BaseResponse<[PostDM]>, Error>) -> ())
    
    func getCommentList(pageNumber: Int, postId: Int, commentId: Int, completion: @escaping (Result<BaseResponse<[ComRepDM]>, Error>) -> ())
    func getReplyList(pageNumber: Int, postId: Int, replyId: Int, commentId: Int, completion: @escaping (Result<BaseResponse<[ComRepDM]>, Error>) -> ())
    func saveCommentReply(params: [String: Any], completion: @escaping (Result<BaseResponse<SaveCommentReplyDM>, Error>) -> ())
    func saveLike(params: [String: Any], completion: @escaping (Result<BaseResponse<CommentReplyDetailDM>, Error>) -> ())
    func deletePost(postId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func deleteComment(commentId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func deleteReply(replyId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    func editComment(params: [String : Any], completion: @escaping (Result<BaseResponse<ComRepDM>, Error>) -> ())
    func editReply(params: [String : Any], completion: @escaping (Result<BaseResponse<CommentReplyDetailDM>, Error>) -> ())
    
    
    // Report
    func getReportTypeList(completion: @escaping (Result<BaseResponse<[ReportTypeDM]>, Error>) -> ())
    func saveReport(params: [String : Any], completion: @escaping (Result<BaseResponse<Double>, Error>) -> ())
    
    // User
    func getUserDetails(completion: @escaping (Result<BaseResponse<UserDetailDM>, Error>) -> ())
    func updateProfile(userDetail: UserDetailDM, completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ())
    
    //Chats
    func getMessagesList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[MessagesListDM]>, Error>) -> ())
    func getChat(pageNumber: Int, identifier: String, isCircle: Bool, completion: @escaping (Result<BaseResponse<[MessagesRecordDM]>, Error>) -> ())
    func sendMessage(identifier: String, isCircle: Bool, message: String,completion: @escaping (Result<BaseResponse<ChatList>, Error>) -> ())
    func deleteMessages(identifier: String, completion: @escaping (Result<BaseResponse<Double>, Error>) -> ())
    
    //Avatar & Polls
    func getPastPolls(pageNumber: Int, pageLimit: Int, completion: @escaping (Result<BaseResponse<[AVPastPoll]>, Error>) -> ())
    func updatePollPrivacy(pollResponseId: Int, privacy: Int, completion: @escaping (Result<BaseResponse<Double>, Error>) -> ())
    func removeAnsweredPollOption(pollResponseId: Int, completion: @escaping (Result<BaseResponse<Double>, Error>) -> ())
    func getAllAvatarPropsByGender(completion: @escaping (Result<BaseResponse<[AvatarPropsDM]>, Error>) -> ())
    func getCurrentAvatar(completion: @escaping (Result<BaseResponse<AvatarDM>, Error>) -> ())
    func saveUserAvatar(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    // App Information
    func getTermsNConditions(completion: @escaping (Result<BaseResponse<[AppInfoDM]>, Error>) -> ())
    func getPrivacyPolicy(completion: @escaping (Result<BaseResponse<[AppInfoDM]>, Error>) -> ())
    func contactUs(params: [String: Any], completion: @escaping (Result<BaseResponse<Double>, Error>) -> ())
    
    // Calling
    func startCallSession(callTo: String, callType: Int, completion: @escaping (Result<BaseResponse<StartCellSessionDM>, Error>) -> ())
    func groupCallHostStop(broadcastId: String, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func callMemberStop(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func groupCallSession(callToCircle: String, callType: Int, callMembers: String, completion: @escaping (Result<BaseResponse<StartGroupCallSession>, Error>) -> ())
    func broadCastCall(callIdentifier: String, circleIdentifier: String, completion: @escaping (Result<BaseResponse<BroadCastCallDM>, Error>) -> ())
    func callReceived(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    func resendTransferCode(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    
    func getPrivacySettings(completion: @escaping (Result<BaseResponse<PrivacySettingsDM>, Error>) -> ())
    func changePrivacySettings(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
    func resend2FACode(identifier: String, completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ())
    func changeTwoFactorAuthentication(isEnabled: Bool, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func verifyTransferCode(code: String, completion: @escaping (Result<BaseResponse<String>, Error>) -> ())
    func getUploadOptions(completion: @escaping (Result<BaseResponse<UploadOptions>, Error>) -> ())
    func postIdentityVerificationDoc(frontImage: Data, backImage: Data?, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ())
}

class APIManager: Networkable {

    var provider = MoyaProvider<API>(plugins: [NetworkLoggerPlugin()])
    
    func postLogin(params: [String : Any], completion: @escaping (Result<BaseResponse<LoginDM>, Error>) -> ()) {
        request(target: .loginUser(params: params), completion: completion)
    }
    
    func postRegister(params: [String : Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ()) {
        request(target: .registerUser(params: params), completion: completion)
    }
    
    func postVerify2FA(params: [String : Any], completion: @escaping (Result<BaseResponse<LoginDM>, Error>) -> ()) {
        request(target: .verify2FA(params: params), completion: completion)
    }
    
    func postVerifyForgetPassword(params: [String : Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ()) {
        request(target: .verifyForgetPassword(params: params), completion: completion)
    }
    
    func postVerifyEmail(params: [String : Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ()) {
        request(target: .verifyEmail(params: params), completion: completion)
    }
    
    func postForgotPassword(params: [String : Any], completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ()) {
        request(target: .forgotPassword(params: params), completion: completion)
    }
    
    func postUpdatePassword(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .updatePassword(params: params), completion: completion)
    }
    
    func postChangePassword(params: [String : Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .changePassword(params: params), completion: completion)
    }
    
    func postLogout(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .logout, completion: completion)
    }
    
    func postDeleteAccount(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .deleteAccount, completion: completion)
    }
    
    // Friends
    
    func getUsersList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[UsersListDM]>, Error>) -> ()) {
        request(target: .getUsersList(pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func sendFriendRequest(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .sendFriendRequest(params: params), completion: completion)
    }
    
//    func cancelFriendRequest(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
//        request(target: .cancelFriendRequest(params: params), completion: completion)
//    }
    
    func getFriendsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[FriendDM]>, Error>) -> ()) {
        request(target: .getFriendsList(pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func getPendingFriendsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[PendingUserDM]>, Error>) -> ()) {
        request(target: .getPendingFriendsList(pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func getBlockFriendsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[BlockedFriendDM]>, Error>) -> ()) {
        request(target: .getBlockFriendsList(pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func blockFriend(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .blockFriend(params: params), completion: completion)
    }
    
    func unblockFriend(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .unblockFriend(params: params), completion: completion)
    }
    
//    func getPendingSendRequestsList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[UsersListDM]>, Error>) -> ()) {
//        request(target: .getPendingSendRequestsList(pageNumber: pageNumber, searchText: searchText), completion: completion)
//    }
    
    func acceptFriendInviteRequest(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .acceptFriendInviteRequest(params: params), completion: completion)
    }
    
    func removeFriend(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .removeFriend(params: params), completion: completion)
    }
    
    func rejectFriendInviteRequest(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .rejectFriendInviteRequest(params: params), completion: completion)
    }
    
    func viewProfileDetails(profileIdentifier: String, completion: @escaping (Result<BaseResponse<ViewProfileDM>, Error>) -> ()) {
        request(target: .getViewProfileDetails(profileIdentifier: profileIdentifier), completion: completion)
    }
    
    // Circle
    
    func createCircle(memberIds: String, circleName: String, imageFile: Data?, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .createCircle(memberIds: memberIds, circleName: circleName, imageFile: imageFile), completion: completion)
    }
    
    func createCircleV2(memberIds: String, circleName: String, imageFile: Data, circleCategory: String, privacy: Int, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .createCircleV2(memberIds: memberIds, circleName: circleName, imageFile: imageFile, circleCategory: circleCategory, privacy: privacy), completion: completion)
    }
    func editCircleV2(id: Int, memberIds: String, circleName: String, imageFile: Data?, circleCategory: String, privacy: Int, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .editCircleV2(id: id, memberIds: memberIds, circleName: circleName, imageFile: imageFile, circleCategory: circleCategory, privacy: privacy), completion: completion)
    }
    
    func getCircleList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[ExploreCircleDM]>, Error>) -> ()) {
        request(target: .getCircleList(pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func sendCircleJoinRequest(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .sendCircleRequest(params: params), completion: completion)
    }
    
    func isDiscoverable(completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .isDiscoverable, completion: completion)
    }
    
    func getJoinedCircleList(pageNumber: Int, searchText: String, category: String, completion: @escaping (Result<BaseResponse<[JoinedCircleDM]>, Error>) -> ()) {
        request(target: .getMyCircleList(pageNumber: pageNumber, searchText: searchText, category: category), completion: completion)
    }
    
    func getPendingCircleList(circleIdentifier: String, pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[PendingCircleJoinDM]>, Error>) -> ()) {
        request(target: .getPendingCircleJoinList(circleIdentifier: circleIdentifier, pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func acceptCircleJoinRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .acceptCircleJoinRequest(inviteId: inviteId), completion: completion)
    }
    func rejectCircleJoinRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .rejectCircleJoinRequest(inviteId: inviteId), completion: completion)
    }
    
    func getPollDurationList(completion: @escaping (Result<BaseResponse<[PollDurationDM]>, Error>) -> ()) {
        request(target: .getPollDurationList, completion: completion)
    }
    
    func createPoll(params: [String: Any], completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .createPoll(params: params), completion: completion)
    }
    
    
    func getPendingCircleInviteList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[PendingCircleInviteDM]>, Error>) -> ()) {
        request(target: .getPendingCircleInviteList(pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    func acceptCircleInviteRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<AcceptCircleInviteDM>, Error>) -> ()) {
        request(target: .acceptCircleInviteRequest(inviteId: inviteId), completion: completion)
    }
    func rejectCircleInviteRequest(inviteId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .rejectCircleInviteRequest(inviteId: inviteId), completion: completion)
    }
    func getCircleNewPollList(circleIdentifier: String, completion: @escaping (Result<BaseResponse<[NewPollDM]>, Error>) -> ()) {
        request(target: .getCircleNewPollList(circleIdentifier: circleIdentifier), completion: completion)
    }
    
    func submitPollAnswer(params: [String: Any], completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .submitPollAnswer(params: params), completion: completion)
    }
    
    func getFriendsToInviteToCircleList(circleId: Int, completion: @escaping (Result<BaseResponse<[GetFriendListToInviteToCircleDM]>, Error>) -> ()) {
        request(target: .getFriendsToInviteToCircle(circleId: circleId), completion: completion)
    }
    func inviteFriendToCircle(status: Bool, toUserId: Int, circleId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .inviteFriendToCircle(status: status, toUserId: toUserId, circleId: circleId), completion: completion)
    }
    
    func getCirclePastPollList(circleIdentifier: String, completion: @escaping (Result<BaseResponse<[PastPollDM]>, Error>) -> ()) {
        request(target: .getCirclePastPollList(circleIdentifier: circleIdentifier), completion: completion)
    }
    
    func getCircleDetails(identifier: String, completion: @escaping (Result<BaseResponse<CircleDetailDM>, Error>) -> ()) {
        request(target: .getCircleDetails(identifier: identifier), completion: completion)
    }
    
    func getCircleMembersByCircleIdsList(params: [String: Any], completion: @escaping (Result<BaseResponse<[CircleMembersByCircleIdDM]>, Error>) -> ()) {
        request(target: .getCircleMembersByCircleIdsList(params: params), completion: completion)
    }
    func getCirclePollsByCircleIdsList(params: [String: Any], completion: @escaping (Result<BaseResponse<[CirclePollsByCircleIdDM]>, Error>) -> ()) {
        request(target: .getCirclePollsByCircleIdsList(params: params), completion: completion)
    }
    
    func createCircleIntersection(circleIds: [Int], imageFile: Data, circleName: String, memberIds: [Int], pollIds: [Int], circleCategory: String, privacy: Int, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .createCircleInterection(circleIds: circleIds, imageFile: imageFile, circleName: circleName, memberIds: memberIds, pollIds: pollIds, circleCategory: circleCategory, privacy: privacy), completion: completion)
    }
    
    func getCircleMemberList(circleId: Int, pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[CircleMemberDM]>, Error>) -> ()) {
        request(target: .getCircleMemberList(circleId: circleId, pageNumber: pageNumber, searchText: searchText), completion: completion)
    }
    
    func getUserListPollOption(pollId: Int, optionId: Int, completion: @escaping (Result<BaseResponse<[UserListPollOptionDM]>, Error>) -> ()) {
        request(target: .getUserListOnPollOption(pollId: pollId, optionId: optionId), completion: completion)
    }
    
    func trendingCircleCategoryList(search: String, completion: @escaping (Result<BaseResponse<[TagDM]>, Error>) -> ()) {
        request(target: .getTrendingCircleCategoryList(search: search), completion: completion)
    }
    
    func deleteCirclePoll(pollId: Int, completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .deleteCirclePoll(pollId: pollId), completion: completion)
    }
    
    // Wallet
    
    func getWalletBalance(completion: @escaping (Result<BaseResponse<Double>, Error>) -> ()) {
        request(target: .getWalletBalance, completion: completion)
    }
    
    func getWalletDetail(completion: @escaping (Result<BaseResponse<WalletDetailDM>, Error>) -> ()) {
        request(target: .getWalletDetail, completion: completion)
    }
    
    func cryptoWithdraw(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .cryptoWithdraw(params: params), completion: completion)
    }
    
    func transferToFriend(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .transferToFriend(params: params), completion: completion)
    }

    func getMyTransactionList(fromDate: String, toDate: String, transType: String, pageNumber: Int, completion: @escaping (Result<BaseResponse<[TransactionDM]>, Error>) -> ()) {
        request(target: .getMyTransactionList(fromDate: fromDate, toDate: toDate, transType: transType, pageNumber: pageNumber), completion: completion)
    }
    
    func getStripeCardList(completion: @escaping (Result<BaseResponse<[CardDM]>, Error>) -> ()) {
        request(target: .getStripeCardList, completion: completion)
    }
    
    func getPaymentIntent(completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .getPaymentIntent, completion: completion)
    }
    
//    func saveUserCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
//        request(target: .saveUserCardStripe(params: params), completion: completion)
//    }
    
    func makeDefaultCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .makeDefaultCardStripe(params: params), completion: completion)
    }
    
    func depositWithNewCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .depositWithNewCardStripe(params: params), completion: completion)
    }
    
    func depositWithDefaultCardStripe(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .depositWithDefaultCardStripe(params: params), completion: completion)
    }
    
    func saveCheckoutOrderDetailPayPal(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .saveCheckoutOrderDetailPayPal(params: params), completion: completion)
    }
    
    func getBankAccountList(completion: @escaping (Result<BaseResponse<[BankAccountDM]>, Error>) -> ()) {
        request(target: .getBankAccountList, completion: completion)
    }
    
    func withdrawAmountToBankAccount(params: [String: Any], completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .withdrawAmountToBankAccount(params: params), completion: completion)
    }
    
    func removeBankAccount(accountIdentifier: String, completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .removeBankAccount(accountIdentifier: accountIdentifier), completion: completion)
    }
    
    
    func getCountryList(completion: @escaping (Result<BaseResponse<[CountryDM]>, Error>) -> ()) {
        request(target: .getCountryList, completion: completion)
    }
    
    func createBankAccount(accHolderName: String, accNumber: String, routingNumber: String, city: String, country: String, line1: String, line2: String, state: String, postalCode: String, ssn: String, dob: String, documentFile: Data, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .createBankAccount(accHolderName: accHolderName, accNumber: accNumber, routingNumber: routingNumber, city: city, country: country, line1: line1, line2: line2, state: state, postalCode: postalCode, ssn: ssn, dob: dob, documentFile: documentFile), completion: completion)
    }
    
    // Notification
    func getNotificationList(pageNumber: Int, completion: @escaping (Result<BaseResponse<[NotificationDM]>, Error>) -> ()) {
        request(target: .getNotificationList(pageNumber: pageNumber), completion: completion)
    }
//    func markAsReadNotification(notificationId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
//        request(target: .markAsReadNotification(notificationId: notificationId), completion: completion)
//    }
    
    func getNotificationCount(completion: @escaping (Result<BaseResponse<[NotificationDM]>, Error>) -> ()) {
        request(target: .getNotificationCount, completion: completion)
    }
    
    // News Feed
    func savePost(content: String, privacy: String, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int, completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .savePost(content: content, privacy: privacy, imageFiles: imageFiles, videoFiles: videoFiles, videoThumbnails: videoThumbnails, deletePostMediaIds: deletePostMediaIds, postId: postId), completion: completion)
    }
    
    func savePostV2(content: String, privacyType: Int, imageFiles: [Data], videoFiles: [Data], videoThumbnails: [Data], deletePostMediaIds: String, postId: Int, friendIds: [Int], shareWithFriendIds: [Int], completion: @escaping (Result<BaseResponse<Int>, Error>) -> ()) {
        request(target: .savePostV2(content: content, privacyType: privacyType, imageFiles: imageFiles, videoFiles: videoFiles, videoThumbnails: videoThumbnails, deletePostMediaIds: deletePostMediaIds, postId: postId, friendIds: friendIds, shareWithFriendIds: shareWithFriendIds), completion: completion)
    }
    
    func getPostList(pageNumber: Int, pageLimit: Int, postId: Int, postIdentifier: String = "", profileIdentifier: String, hashtag: String, completion: @escaping (Result<BaseResponse<[PostDM]>, Error>) -> ()) {
        request(target: .getPostList(pageNumber: pageNumber, pageLimit: pageLimit, postId: postId, postIdentifier: postIdentifier, profileIdentifier: profileIdentifier, hashtag: hashtag), completion: completion)
    }
    
    func getCommentList(pageNumber: Int, postId: Int, commentId: Int, completion: @escaping (Result<BaseResponse<[ComRepDM]>, Error>) -> ()) {
        request(target: .getCommentList(pageNumber: pageNumber, commentId: commentId, postId: postId), completion: completion)
    }
    
    func getReplyList(pageNumber: Int, postId: Int, replyId: Int, commentId: Int, completion: @escaping (Result<BaseResponse<[ComRepDM]>, Error>) -> ()) {
        request(target: .getReplyList(pageNumber: pageNumber, replyId: replyId, commentId: commentId), completion: completion)
    }
    
    func saveCommentReply(params: [String : Any], completion: @escaping (Result<BaseResponse<SaveCommentReplyDM>, Error>) -> ()) {
        request(target: .saveCommentReply(params: params), completion: completion)
    }
    
    func saveLike(params: [String : Any], completion: @escaping (Result<BaseResponse<CommentReplyDetailDM>, Error>) -> ()) {
        request(target: .saveLike(params: params), completion: completion)
    }
    
    func deletePost(postId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .deletePost(postId: postId), completion: completion)
    }
    
    func deleteComment(commentId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .deleteComment(commentId: commentId), completion: completion)
    }
    
    func deleteReply(replyId: Int, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .deleteReply(replyId: replyId), completion: completion)
    }
    
    func editComment(params: [String : Any], completion: @escaping (Result<BaseResponse<ComRepDM>, Error>) -> ()) {
        request(target: .editComment(params: params), completion: completion)
    }
    
    func editReply(params: [String : Any], completion: @escaping (Result<BaseResponse<CommentReplyDetailDM>, Error>) -> ()) {
        request(target: .editReply(params: params), completion: completion)
    }
    
    
    
    // Report
    func getReportTypeList(completion: @escaping (Result<BaseResponse<[ReportTypeDM]>, Error>) -> ()) {
        request(target: .getReportTypeList, completion: completion)
    }
    
    func saveReport(params: [String : Any], completion: @escaping (Result<BaseResponse<Double>, Error>) -> ()) {
        request(target: .saveReport(params: params), completion: completion)
    }
    
    // User
    func getUserDetails(completion: @escaping (Result<BaseResponse<UserDetailDM>, Error>) -> ()) {
        request(target: .getUserDetails, completion: completion)
    }
    
    func updateProfile(userDetail: UserDetailDM, completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ()) {
        request(target: .updateProfile(userDetail: userDetail), completion: completion)
    }
    
    //Chats
    func getMessagesList(pageNumber: Int, searchText: String, completion: @escaping (Result<BaseResponse<[MessagesListDM]>, Error>) -> ()) {
        request(target: .getChatList(searchText: searchText, pageNumber: pageNumber, pageLimit: 50), completion: completion)
    }
    
    func getChat(pageNumber: Int, identifier: String, isCircle: Bool, completion: @escaping (Result<BaseResponse<[MessagesRecordDM]>, Error>) -> ()){
        request(target: .getChat(identifier: identifier, isCircle: isCircle, pageNumber: pageNumber, pageLimit: 50), completion: completion)
    }
    
    func sendMessage(identifier: String, isCircle: Bool, message: String, completion: @escaping (Result<BaseResponse<ChatList>, Error>) -> ()){
        request(target: .sendMessage(identifier: identifier, isCircle: isCircle, message: message), completion: completion)
    }
    
    func deleteMessages(identifier: String, completion: @escaping (Result<BaseResponse<Double>, Error>) -> ()){
        request(target: .deleteMessages(identifier: identifier), completion: completion)
    }
    
    // Avatar & Past Poll
    func getPastPolls(pageNumber: Int, pageLimit: Int, completion: @escaping (Result<BaseResponse<[AVPastPoll]>, Error>) -> ()) {
        request(target: .getPastPoll(pageNumber: pageNumber, pageLimit: pageLimit), completion: completion)
    }
    func updatePollPrivacy(pollResponseId: Int, privacy: Int, completion: @escaping (Result<BaseResponse<Double>, Error>) -> ()) {
        request(target: .updatePollPrivacy(pollResponseId: pollResponseId, privacy: privacy), completion: completion)
    }
    func removeAnsweredPollOption(pollResponseId: Int, completion: @escaping (Result<BaseResponse<Double>, Error>) -> ()) {
        request(target: .removeAnsweredPollOption(pollResponseId: pollResponseId), completion: completion)
    }
    func getAllAvatarPropsByGender(completion: @escaping (Result<BaseResponse<[AvatarPropsDM]>, Error>) -> ()) {
        request(target: .getAllAvatarPropsByGender, completion: completion)
    }
    func getCurrentAvatar(completion: @escaping (Result<BaseResponse<AvatarDM>, Error>) -> ()) {
        request(target: .getCurrentAvatar, completion: completion)
    }
    func saveUserAvatar(params: [String: Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .saveUserAvatar(params: params), completion: completion)
    }
    
    // App Information
    func getTermsNConditions(completion: @escaping (Result<BaseResponse<[AppInfoDM]>, Error>) -> ()) {
        request(target: .termsNConditions, completion: completion)
    }
    func getPrivacyPolicy(completion: @escaping (Result<BaseResponse<[AppInfoDM]>, Error>) -> ()) {
        request(target: .privacyPolicy, completion: completion)
    }
    func contactUs(params: [String: Any], completion: @escaping (Result<BaseResponse<Double>, Error>) -> ()) {
        request(target: .contactUs(params: params), completion: completion)
    }
    
    // Calling
    func startCallSession(callTo: String, callType: Int, completion: @escaping (Result<BaseResponse<StartCellSessionDM>, Error>) -> ()) {
        request(target: .startCallSession(callTo: callTo, callType: callType), completion: completion)
    }
    func groupCallHostStop(broadcastId: String, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .groupCallHostStop(broadcastId: broadcastId), completion: completion)
    }
    func callMemberStop(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .callMemberStop, completion: completion)
    }
    func groupCallSession(callToCircle: String, callType: Int, callMembers: String, completion: @escaping (Result<BaseResponse<StartGroupCallSession>, Error>) -> ()) {
        request(target: .groupCallSession(callToCircle: callToCircle, callType: callType, callMembers: callMembers), completion: completion)
    }
    func broadCastCall(callIdentifier: String, circleIdentifier: String, completion: @escaping (Result<BaseResponse<BroadCastCallDM>, Error>) -> ()) {
        request(target: .broadCastCall(callIdentifier: callIdentifier, circleIdentifier: circleIdentifier), completion: completion)
    }
    func callReceived(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .callReceived, completion: completion)
    }
    
    func resendTransferCode(completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .resendTransferCode, completion: completion)
    }
    
    
    func getPrivacySettings(completion: @escaping (Result<BaseResponse<PrivacySettingsDM>, Error>) -> ()) {
        request(target: .getPrivacySettings, completion: completion)
    }
    func changePrivacySettings(params: [String : Any], completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()) {
        request(target: .changePrivacySetting(params: params), completion: completion)
    }
    func resend2FACode(identifier: String, completion: @escaping (Result<BaseResponse<UserDM>, Error>) -> ()) {
        request(target: .resend2FACode(identifier: identifier), completion: completion)
    }
    func changeTwoFactorAuthentication(isEnabled: Bool, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .twoFactorAuthenticationToggle(isEnabled: isEnabled), completion: completion)
    }
    func verifyTransferCode(code: String, completion: @escaping (Result<BaseResponse<String>, Error>) -> ()) {
        request(target: .verifyTransferCode(code: code), completion: completion)
    }
    
    func getUploadOptions(completion: @escaping (Result<BaseResponse<UploadOptions>, Error>) -> ()) {
        request(target: .getAMLKYCUploadOptions, completion: completion)
    }
    
    func postIdentityVerificationDoc(frontImage: Data, backImage: Data?, completion: @escaping (Result<BaseResponse<Bool>, Error>) -> ()){
        request(target: .verifyAMLKYC(frontImage: frontImage, backImage: backImage), completion: completion)
    }
    
}
private extension APIManager {
    private func request<T: Decodable>(target: API, completion: @escaping (Result<T, Error>) -> ()) {
        
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    print(JSON(response.data))
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
//                }
//                catch DecodingError.keyNotFound(let key, let context) {
//                    Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
//                } catch DecodingError.valueNotFound(let type, let context) {
//                    Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
//                } catch DecodingError.typeMismatch(let type, let context) {
//                    Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
//                    print("codingPath:", context.codingPath)
//                } catch DecodingError.dataCorrupted(let context) {
//                    Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                } catch let error as NSError {
                    NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    completion(.failure(error))
                }
                //
                //                catch let error {
                //                    completion(.failure(error))
                //                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
//    func errorCompletion() {
//        do {
//            let results = try JSONDecoder().decode(T.self, from: response.data)
//        } catch let error as NSError {
//            completion(.failure(error))
//        }
//    }
}



//struct VerbosePlugin: PluginType {
//    let verbose: Bool
//
//    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//#if DEBUG
//        if let body = request.httpBody,
//           let str = String(data: body, encoding: .utf8) {
//            if verbose {
//                print("request to send: \(str))")
//            }
//        }
//#endif
//        return request
//    }
//
//    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
//#if DEBUG
//        switch result {
//        case .success(let body):
//            if verbose {
//                print("Response:")
//                if let json = try? JSONSerialization.jsonObject(with: body.data, options: .mutableContainers) {
//                    print(json)
//                } else {
//                    let response = String(data: body.data, encoding: .utf8)!
//                    print(response)
//                }
//            }
//        case .failure( _):
//            break
//        }
//#endif
//    }
//}


