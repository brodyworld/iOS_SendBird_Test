//
//  NetworkClientImplement.swift
//  SendbirdUserManager
//
//  Created by Brody Byun on 2023/10/21.
//

import Foundation
import Moya

struct NetworkClientImplement: SBNetworkClient {
//    let provider = MoyaProvider<SendbirdRouter>()
    let provider = MoyaProvider<SendbirdRouter>(plugins: [NetworkLoggerPlugin()])

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
    
    func request<R: Request>(request: R) async -> (Result<R.Response, Error>) {
        let result = await provider.request(request.router)
        switch result {
        case .success(let sucess):
            let decodedReponse = JSONDecoder().decodeResponse(R.Response.self, from: sucess.data)
            switch decodedReponse {
            case .success(let decodeSuccess):
                return .success(decodeSuccess)
            case .failure(let decodeError):
                return .failure(decodeError)
            }
        case .failure(let error):
            return .failure(error)
        }

    }
    
}
