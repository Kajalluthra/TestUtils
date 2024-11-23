import Foundation
import XCTest
import os
@testable import LoggerExtension

extension XCTestCase {
    
    // custom URLSession for mock network calls
    private static var _urlSession = URLSession.shared
    
    public var urlSession: URLSession {
        get {
            return XCTestCase._urlSession
        }
        set(newValue) {
            XCTestCase._urlSession = newValue
        }
    }
    
    open override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        self.urlSession = URLSession(configuration: configuration)
    }
    
    public func configureMockResponse(with bundle: Bundle? = nil, jsonFilename: String, statusCode: Int) {
        let mockData = self.loadJSON(bundle: bundle, filename: jsonFilename)
        MockURLProtocol.requestHandler = { request in
            // Safe to unwrap here because a request is always coming with an url
            return (HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, mockData)
        }
    }
    
    public func configureMockResponse(with bundle: Bundle, dataFilename: String, statusCode: Int) {
        let mockData = self.loadLocalFile(bundle: bundle, name: dataFilename)
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, mockData)
        }
    }
    
    public func loadLocalFile(bundle: Bundle, name: String) -> Data {
        guard let filePath = bundle.path(forResource: name, ofType: nil) else {
            fatalError("File \(name) not found")
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return data
    }
    
    func loadJSON(bundle: Bundle?, filename: String) -> Data {
        let bundle = bundle ?? Bundle.module
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }
        
        do {
            let data = try Data(contentsOf: path)
            return data
        } catch let error {
            Logger.test.log(level: .error, message: error.localizedDescription)
            fatalError("Failed to decode loaded JSON")
        }
    }
}
