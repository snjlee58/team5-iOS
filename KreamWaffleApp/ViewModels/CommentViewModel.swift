//
//  CommentViewModel.swift
//  KreamWaffleApp
//
//  Created by 최성혁 on 2023/02/01.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel {
    let postTextRelay = BehaviorRelay<String>(value: "")
    private let commentUsecase: CommentUsecase
    private var isAlreadyFetchingDataFromServer = false
    private let id: Int //style탭 포스팅이든 shop탭 상품이든 아무튼 그 대상 ID
    var currentReplyTarget: Int = 0
    
    var isWritingReply = false {
        didSet {
            isWritingReplyRelay.accept(isWritingReply)
        }
    }
    let isWritingReplyRelay = BehaviorRelay<Bool>(value: false)
    
    var currentReplyToProfile: ReplyToProfile?

    var commentDataSource: Observable<[Comment]> {
        return self.commentUsecase.commentRelay.asObservable()
    }
    
    init(commentUsecase: CommentUsecase, id: Int) {
        self.commentUsecase = commentUsecase
        self.id = id
    }
    
    var commentCount: Int {
        get {
            self.commentUsecase.commentList.count
        }
    }
    
    func replyCountOfComment(at index: Int) -> Int {
        return self.commentUsecase.commentList[index].replies.count
    }
    
    func getComment(at index: Int) -> Comment {
        return self.commentUsecase.commentList[index]
    }
    
    func getCommentId(at index: Int) -> Int {
        return self.commentUsecase.commentList[index].id
    }
    
    func requestInitialData(token: String) {
        isAlreadyFetchingDataFromServer = true
        self.commentUsecase.requestInitialData(token: token, id: id) { [weak self] in
            self?.isAlreadyFetchingDataFromServer = false
        }
    }
    
    func requestNextData(token: String) {
        if (!isAlreadyFetchingDataFromServer) {
            self.isAlreadyFetchingDataFromServer = true
            self.commentUsecase.requestNextData(token: token, id: id) { [weak self] in
                self?.isAlreadyFetchingDataFromServer = false
            }
        }
    }
    
    func sendComment(token: String, content: String, completion: @escaping ()->(), onNetworkFailure: @escaping () -> ()) {
        if (!isWritingReply) { //reply 아니라 comment일 때
            self.commentUsecase.sendComment(token: token, content: content, id: id, completion: completion, onNetworkFailure: onNetworkFailure)
        } else {
            self.commentUsecase.sendReply(token: token, content: content, replyTarget: currentReplyTarget, completion: completion, onNetworkFailure: onNetworkFailure)
        }
    }
}
