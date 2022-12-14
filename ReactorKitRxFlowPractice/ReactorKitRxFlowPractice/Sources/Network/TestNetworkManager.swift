//
//  TestNetworkManager.swift
//  ReactorKitRxFlowPractice
//
//  Created by JongHoon on 2022/10/30.
//

import Foundation

enum JokesAPI {
    case randomJokes
    
    static let baseURL = "https://api.icndb.com/"
    var path: String { "jokes/random" }
    var url: URL { URL(string: JokesAPI.baseURL + path)! }
    
    var sampleData: Data {
        Data(
            """
            {
                "type": "success",
                    "value": {
                    "id": 459,
                    "joke": "Chuck Norris can solve the Towers of Hanoi in one move.",
                    "categories": []
                }
            }
            """.utf8
        )
    }
}

enum APIError: LocalizedError {
    case unknownError
    var errorDescription: String? { "unknownError" }
}

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

