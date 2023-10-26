//
//  NetworkClientImplement.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation
import Moya

struct NetworkClientImplement: SBNetworkClient {
    let provider = MoyaProvider<SendbirdRouter>(
        callbackQueue: DispatchQueue.global(qos: .utility),
        plugins: [NetworkLoggerPlugin()]
    )

    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, Error>) -> Void) where R : Request {
        
        provider.request(request.router) { result in
            switch result {
            case .success(let success):
                let decodedReponse = JSONDecoder().decodeResponse(R.Response.self, from: success.data)
                switch decodedReponse {
                case .success(let decodeSuccess):
                    completionHandler(.success(decodeSuccess))
                case .failure(let decodeError):
                    completionHandler(.failure(decodeError))
                }
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
            
        }
    }
    
}
