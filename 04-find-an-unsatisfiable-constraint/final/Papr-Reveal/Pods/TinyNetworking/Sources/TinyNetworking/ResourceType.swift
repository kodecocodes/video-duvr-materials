//
//  ResourceType.swift
//  TinyNetworking
//
//  Created by Joan Disho on 29.03.18.
//

import Foundation

public protocol Resource {
    var baseURL: URL { get }
    var endpoint: Endpoint { get }
    var task: Task { get }
    var headers: [String: String] { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

