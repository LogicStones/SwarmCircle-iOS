//
//  Delegate.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 26/09/2022.
//

import Foundation

protocol AppProtocol {
    
    // MARK: - Move from MyAccountVC (account details) to MyWalletVC after tapping My Wallet Image
    func moveToWalletTab() // Change selected tab index to 3
    
    // MARK: - Refresh friend list in MyFriendsVC after a friend request is accepted from PendingFriendRequestVC (pending friends screen) and ConnectWithFriendsVC
    func refreshFriendList()
    
    // MARK: - Update friend request status in ConnectWithFriendsVC, after a friend is invited/cancelled from ViewProfileVC
    func updateFriendRequestStatus()
    
    // MARK: - Refresh CircleDetailVC after pending circle request is accepted from PendingCirclesVC
    func refreshCircleDetail()
    
    // MARK: - Refresh Circle list in MyCircleVC after pending circle request is accepted from PendingCirclesVC
    func refreshCircleList() // PendingCirclesVC request accepted -> refreshCircleDetail() delegate is called, which calls -> refreshCircleList() delegate
    
    // MARK: - Update New Polls count in  CircleDetailVC after, a poll is created in CreatePollVC, a poll is answered in NewPollVC
    func updateNewPollsCount(_ count: Int)
    
    // MARK: - Move circle back to circle list in MyCircleVC after, a circle is removed from CreateCircleIntersectionVC, any other screen is pushed in MyCircleVC except CreateCircleIntersectionVC
    func moveCircleBackToList(circleInfo: JoinedCircleDM)
    
    // MARK: - Remove circle from Circle intersection cell's collection view after, a circle is removed from CreateCircleIntersectionVC, any other screen is pushed in MyCircleVC except CreateCircleIntersectionVC
    func removeCircleFromIntersectionCell(circleInfo: JoinedCircleDM)
    
    // MARK: - Tap Circle Intersection cell when circle intersection collection view (contained with in circle intersection cell) is tapped
    func tapCircleIntersectionCell()
    
    // MARK: - Refresh card list in DepositByCardVC after a card is added in Add StripeCardVC
    func refreshCardList()
    
    // MARK: - Refresh Wallet amount in MyWalletVC after cryto withdrawal in CryptoWithdrawalVC
    func refreshWalletAmount()
    
    // MARK: - Set Friend (Receiver) Wallet id (in TextField) in TransferVC after a friend is selected in FriendsListVC
    func setReceiverWalletId()
    
    // MARK: - Set friend(receiver) wallet id in TransferVC after a friend is selected in FriendsListVC
    func setReceiverWalletId(selectedFriend: FriendDM?)
    
    // MARK: - Refresh Bank Account List in WithdrawVC after a new bank account is added in AddBankAccountVC
    func refreshBankAccountList()
    
    // MARK: - Fetch Post in HomeVC After Editing in CreatePostVC
    func updatePost(postId: Int, index: Int?)
    
    // MARK: - Create Post in CreatePostVC and add that Post on top in HomeVC
    func addNewPost()
    
    // MARK: - Remove User from list in ConnectWithFriendsVC after accepting Friend Request in ViewProfileVC
    func removeUserFromList()
    
    // MARK: - Refresh Pending Friend List after accepting/rejecting Friend Request in ViewProfileVC
    func refreshPendingFriendList(refreshList: Int) // 0: pending friend request list and friend list (Accept), 1: pending friend request list (Reject), 2: friend list (Remove)
    
    // MARK: - Remove Friend From List in FriendsListVC after a Friend is removed in ViewProfileVC
    func removeFriendFromList()
    
    // MARK: - Refresh Invite Friends To Circle List in PendingFriendRequestVC after a Friend is removed in ViewProfileVC
    func refreshInviteFriendToCircleList()
    
    // MARK: - Update Comment Count of Post in HomeVC after a comment is added or deleted in CommentsVC
    func updateCommentCount(postIndex: Int, increment: Int)
    
    // MARK: - Delete Post in HomeVC after a Post is found deleted in CommentVC
    func deletePost(index: Int)
    
    // MARK: - Passing User Identifier for Creating New Chat
    func createNewChat(friendObject: FriendDM)
    
    // MARK: - Update Social Links (in UserDetail Object) in EditProfileVC after Add Button is tapped in  AddSocialLinksVC
    func updateSocialLink(facebookLink: String?, twitterLink: String?, youtubeLink: String?, instagramLink: String?)
    
    // MARK: - Update Poll Privacy in MyAvatarVC after selecting a privacy in PollsBottomSheetVC
    func updatePrivacyOfPoll(pollResponseId: Int, privacy: Int)
    
    // MARK: - Remove Answered Poll in MyAvatarVC after selecting a remove in PollsBottomSheetVC
    func removeAnsweredOptionOfPoll(pollResponseId: Int, object: AVPastPoll, index: Int)
    
    // MARK: - Update User Info in ProfileVC after Profile has been edited in EditProfileVC
    func updateUserInfo()
    
    // MARK: - Refresh User Avatar in MyAvatarVC after Avatar has been updated in EditAvatarVC
    func refreshAvatar()
    
    // MARK: - Go To GroupAVCallingVC after circle members are selected in FriendsListVC
    func goToGroupCallingVC(members: String, isVideoCalling: Bool)
    
    // MARK: - Set selected tags in MyCircleVC's tagCollectionView
    func setAndApplySelectedFilter(tagListSelected: [TagDM])
    
    // MARK: - Update selected friend list in CreateCircleVC after done button is tapped in FriendListVC
    func updateSelectedFriendList(friendListSelected: [FriendDM])
    
    // MARK: - Update share with or except friend list in CreateCircleVC after done button is tapped in FriendListVC
    func updateShareWithORExceptSelectedFriendList(shareWithORExceptfriendListSelected: [FriendDM])
    
    // MARK: - Refresh PrivacySettingsVC and turn on 2FA if check is true, after two factor process is successful in EnterOTPVC
    func refreshPrivacySettingsScreen(turnOnTwoFactor: Bool)
    
    // MARK: - Hit 'transfer to friend' API in ConfirmTransferVC after OTP is verified in EnterOTPVC
    func hitTransferAPI()
    
    // MARK: - Hit 'withdraw amount to bank account' API in ConfirmWithdrawalVC after OTP is verified in EnterOTPVC
    func hitWithdrawalAPI()
    
    // MARK: - Hit 'crypto withdrawal to bank account' API in CryptoWithdrawalVC after OTP is verified in EnterOTPVC
    func hitCryptoWithdrawalAPI()
    
    // MARK: - Set member list with updated selection in EditCircleVC after 'remove members' button is tapped in CircleMemberListVC
    func setUpdatedMemberList(memberList: [CircleMemberDM])
}

extension AppProtocol {
    func moveToWalletTab() { }
    func refreshFriendList() { }
    func updateFriendRequestStatus() { }
    func refreshCircleList() { }
    func refreshCircleDetail() { }
    func updateNewPollsCount(_ count: Int) { }
    func moveCircleBackToList(circleInfo: JoinedCircleDM) { }
    func removeCircleFromIntersectionCell(circleInfo: JoinedCircleDM) { }
    func tapCircleIntersectionCell() { }
    func refreshCardList() { }
    func refreshWalletAmount() { }
    func setReceiverWalletId() { }
    func setReceiverWalletId(selectedFriend: FriendDM?) { }
    func refreshBankAccountList() { }
    func updatePost(postId: Int, index: Int? = nil) { }
    func addNewPost() { }
    func removeUserFromList() { }
    func refreshPendingFriendList(refreshList: Int) { }
    func removeFriendFromList() { }
    func refreshInviteFriendToCircleList() { }
    func removeCircleMemberFromList() { }
    func updateCommentCount(postIndex: Int, increment: Int) { }
    func deletePost(index: Int) { }
    func createNewChat(friendObject: FriendDM) { }
    func updateSocialLink(facebookLink: String?, twitterLink: String?, youtubeLink: String?, instagramLink: String?) { }
    func updatePrivacyOfPoll(pollResponseId: Int, privacy: Int) { }
    func removeAnsweredOptionOfPoll(pollResponseId: Int, object: AVPastPoll, index: Int) { }
    func updateUserInfo() { }
    func refreshAvatar() { }
    func goToGroupCallingVC(members: String, isVideoCalling: Bool) { }
    func setAndApplySelectedFilter(tagListSelected: [TagDM]) { }
    func updateSelectedFriendList(friendListSelected: [FriendDM]) { }
    func updateShareWithORExceptSelectedFriendList(shareWithORExceptfriendListSelected: [FriendDM]) { }
    func refreshPrivacySettingsScreen(turnOnTwoFactor: Bool) { }
    func hitTransferAPI() { }
    func hitWithdrawalAPI() { }
    func hitCryptoWithdrawalAPI() { }
    func setUpdatedMemberList(memberList: [CircleMemberDM]) { }
}
