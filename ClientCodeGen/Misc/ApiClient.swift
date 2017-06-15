//
//  ApiClient.swift
//  JSONExport
//
//  Created by Vinh Vo on 4/19/17.
//  Copyright © 2017 Vinh Vo. All rights reserved.
//

import Foundation
typealias ServiceResponse = (_ success: Bool, _ jsonString: String?) -> ()

enum HttpMethod:String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case detele = "DELETE"
}

class ApiClient{
    
    static let shared = ApiClient()
    
    // MARK: - Perform a GET Request
    func makeGetRequest(strURL:String, headers:[String:Any]? = nil, onCompletion: @escaping ServiceResponse)
    {
        
        let urlRequest = clientURLRequest(urlString: strURL, headers: headers)
        
        get(request: urlRequest) { (result, jsonString) in
            runOnUiThread{
                onCompletion(result, jsonString)
            }
        }
    }
    
    
    // MARK: - Perform a POST Request
    func makePostRequest(strURL: String, body: [String:Any]?, headers:[String:Any]? = nil, onCompletion: @escaping ServiceResponse) {
        let urlRequest = clientURLRequest(urlString: strURL,params: body, headers: headers)
        
        post(request: urlRequest) { (result, jsonString) in
            runOnUiThread{
                onCompletion(result, jsonString)
            }
        }
        
    }
    
    // MARK: - Perform a PUST Request
    func makePutRequest(strURL: String, body: [String:Any]?, headers:[String:Any]? = nil, onCompletion: @escaping ServiceResponse) {
        let urlRequest = clientURLRequest(urlString: strURL,params: body, headers: headers)
        
        put(request: urlRequest) { (result, jsonString) in
            runOnUiThread{
                onCompletion(result, jsonString)
            }
        }
    }
    
    // MARK: - Perform a DELETE Request
    func makeDeleteRequest(strURL: String, body: [String:Any]?, headers:[String:Any]? = nil, onCompletion: @escaping ServiceResponse) {
        let urlRequest = clientURLRequest(urlString: strURL,params: body, headers: headers)
        
        delete(request: urlRequest) { (result, jsonString) in
            runOnUiThread{
                onCompletion(result, jsonString)
            }
        }
    }
    
    // MARK: -
    private func clientURLRequest(urlString: String, params:[String:Any]? = nil, headers:[String:Any]? = nil) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        //set params
        if let params = params {
            //            var paramString = ""
            //            for (key, value) in params {
            //                let escapedKey = key.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            //                let escapedValue = (value as AnyObject).addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            //                paramString += "\(String(describing: escapedKey))=\(String(describing: escapedValue))&"
            //            }
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                //                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            } catch let error as NSError {
                print(error)
            }
        }
        
        //set headers
        if let headers = headers {
            for (key,value) in headers {
                request.setValue("\(value)", forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    
    
    // MARK: -
    private func post(request: NSMutableURLRequest, completion: @escaping ServiceResponse) {
        dataTask(request: request, method: "POST", completion: completion)
    }
    
    private func put(request: NSMutableURLRequest, completion: @escaping ServiceResponse) {
        dataTask(request: request, method: "PUT", completion: completion)
    }
    
    private func get(request: NSMutableURLRequest, completion: @escaping ServiceResponse) {
        dataTask(request: request, method: "GET", completion: completion)
    }
    
    private func delete(request: NSMutableURLRequest, completion: @escaping ServiceResponse) {
        dataTask(request: request, method: "DELETE", completion: completion)
    }
    
    
    
    // MARK: - Data task
    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping ServiceResponse) {
        
        request.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                
                var jsonString = String(data: data, encoding: String.Encoding.utf8)
                
                do {
                    let jsonData : Any = try JSONSerialization.jsonObject(with: data, options: [])
                    let data1 =  try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)
                    jsonString = String(data: data1, encoding: String.Encoding.utf8)
                } catch let error as NSError {
                    print(error)
                }
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, jsonString )
                } else {
                    completion(false, jsonString)
                }
                
            }
            }.resume()
    }
    
}

