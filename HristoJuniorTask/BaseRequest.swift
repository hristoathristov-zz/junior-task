//
//  BaseRequest.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Alamofire
import ObjectMapper

class BaseRequest<T: Mappable> {
    
    var url: URLConvertible
    var method: HTTPMethod
    var parameters: Parameters?
    var encoding: ParameterEncoding
    var headers: HTTPHeaders?
    
    init(url: URLConvertible, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers
    }
    
    func execute(successBlock: @escaping (T)->(), failureBlock: ((Error)->())? = nil) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
            print(response.debugDescription)
            guard let json = response.result.value as? Dictionary<String, Any>, let statusCode = response.response?.statusCode else {
                failureBlock?(NSError(domain: "", code: 0, userInfo: nil))
                return
            }
            switch statusCode {
            case 200...299:
                if let object = T(map: Map(mappingType: .fromJSON, JSON: json)) {
                    successBlock(object)
                }
            default:
                failureBlock?(NSError(domain: "", code: statusCode, userInfo: json))
            }
        }
    }
}
