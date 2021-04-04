//
//  HTTPURLResponse+StatusCode.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 03/04/21.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
