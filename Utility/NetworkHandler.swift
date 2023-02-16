//
//  NetworkHandler.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import Foundation
import Alamofire

struct ResponseMessage: Codable, Hashable {
    let message: String
}

typealias NetResponse = ((_ response: Data?, _ error: NetError?) -> Void)

final class NetworkHandler {
    static func request(method: HTTPMethod, endpoint: APIEndpointProtocol, queryParameters: [String : String]? = nil, completion: @escaping NetResponse) {
        var requestURL: String = endpoint.url()
        
        if let qo = queryParameters {
            
            requestURL += "?"
            
            for x in qo {
                requestURL += (x.key + "=" + x.value + "&")
            }
        }
        
        AF.request(requestURL, method: method, encoding: JSONEncoding.default, headers: generateHeaders())
            .responseData { response in
                switch response.result {
                case .success(let rData):
                    switch response.response?.statusCode {
                    case 200:
                        completion(rData, nil)
                        return
                    default:
                        let x = try? JSONDecoder().decode(ResponseMessage.self, from: rData)
                        completion(nil, .unknownError(x?.message))
                        return
                    }
                case .failure(let rErr):
                    completion(nil, NetError.unknownError(rErr.localizedDescription))
                }
            }
//            .responseJSON { data in
//                print(requestURL)
//                print(data)
//            }
    }
    
    static private func generateHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = HTTPHeaders()
        headers.add(name: "apikey", value: "MzKP97j3EIFXcNyV7Il8R9WcSDzX1LJe")
        return headers
    }
}
