//
//  CommentUsecase.swift
//  KreamWaffleApp
//
//  Created by 최성혁 on 2023/02/01.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentUsecase {
    private let commentRepository: CommentRepositoryProtocol
    private var cursor: String?
    private let disposeBag = DisposeBag()
    
    let commentRelay: BehaviorRelay<[Comment]> = .init(value: [])
    
    var commentList = [Comment]() {
        didSet {
            self.commentRelay.accept(self.commentList)
        }
    }
    
    init(commentRepository: CommentRepositoryProtocol) {
        self.commentRepository = commentRepository
    }
    
    func requestInitialData(token: String, id: Int, completion: @escaping ()->()) {
        self.commentRepository
            .requestInitialCommentData(token: token, id: id, completion: completion)
            .subscribe { event in
                switch event {
                case .success(let commentResponse):
                    self.cursor = commentResponse.next
                    self.commentList = commentResponse.results
                case .failure(let error):
                    self.cursor = nil
                    self.commentList.removeAll()
                    print(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func requestNextData(token: String, id: Int, completion: @escaping ()->()) {
        if let cursor = self.cursor {
            self.commentRepository
                .requestNextCommentData(token: token, cursor: cursor, completion: completion)
                .subscribe { event in
                    switch event {
                    case .success(let commentResponse):
                        self.cursor = commentResponse.next
                        self.commentList += commentResponse.results
                    case .failure(let error):
                        self.cursor = nil
                        self.commentList.removeAll()
                        print(error)
                    }
                }
                .disposed(by: disposeBag)
        }
        
    }
    
    func sendComment(token: String, content: String, id: Int, completion: @escaping ()->(), onNetworkFailure: @escaping ()->()) {
        self.commentRepository
            .sendComment(token: token, content: content, id: id, completion: completion, onNetworkFailure: onNetworkFailure)
    }
    
    func sendReply(token: String, to_profile: String, content: String, replyTarget: Int, completion: @escaping ()->(), onNetworkFailure: @escaping ()->()) {
        self.commentRepository
            .sendReply(token: token, to_profile: to_profile, content: content, replyTarget: replyTarget, completion: completion, onNetworkFailure: onNetworkFailure)
    }

}
