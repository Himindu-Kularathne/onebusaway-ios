//
//  MockDataLoader.swift
//  OBAKitTests
//
//  Created by Aaron Brethorst on 5/1/20.
//

import Foundation
import OBAKitCore

typealias MockDataLoaderMatcher = (URLRequest) -> Bool

struct MockDataResponse {
    let data: Data?
    let urlResponse: URLResponse?
    let error: Error?
    let matcher: MockDataLoaderMatcher
}

class MockDataLoader: NSObject, URLDataLoader {
    var mockResponses = [MockDataResponse]()

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        guard let response = matchResponse(to: request) else {
            fatalError("Missing response to URL: \(request.url!)")
        }

        completionHandler(response.data, response.urlResponse, response.error)

        return URLSessionDataTask()
    }

    // MARK: - Response Mapping

    func matchResponse(to request: URLRequest) -> MockDataResponse? {
        for r in mockResponses {
            if r.matcher(request) {
                return r
            }
        }

        return nil
    }

    func mock(data: Data, matcher: @escaping MockDataLoaderMatcher) {
        let urlResponse = buildURLResponse(URL: URL(string: "https://mockdataloader.example.com")!, statusCode: 200)
        let mockResponse = MockDataResponse(data: data, urlResponse: urlResponse, error: nil, matcher: matcher)
        mock(response: mockResponse)
    }

    func mock(URLString: String, with data: Data) {
        mock(url: URL(string: URLString)!, with: data)
    }

    func mock(url: URL, with data: Data) {
        let urlResponse = buildURLResponse(URL: url, statusCode: 200)
        let mockResponse = MockDataResponse(data: data, urlResponse: urlResponse, error: nil) {
            let requestURL = $0.url!
            return requestURL.host == url.host && requestURL.path == url.path
        }
        mock(response: mockResponse)
    }

    func mock(response: MockDataResponse) {
        mockResponses.append(response)
    }

    func removeMappedResponses() {
        mockResponses.removeAll()
    }

    // MARK: - URL Response

    func buildURLResponse(URL: URL, statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL, statusCode: statusCode, httpVersion: "2", headerFields: ["Content-Type": "application/json"])!
    }

    // MARK: - Description

    override var debugDescription: String {
        var descriptionBuilder = DebugDescriptionBuilder(baseDescription: super.debugDescription)
        descriptionBuilder.add(key: "mockResponses", value: mockResponses)
        return descriptionBuilder.description
    }
}