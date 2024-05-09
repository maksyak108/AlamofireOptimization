import Alamofire
import Gzip
import Foundation

extension Alamofire.Session {
    func requestGzipped(_ url: URLConvertible,
                         method: HTTPMethod = .get,
                         parameters: Parameters? = nil,
                         headers: HTTPHeaders? = nil) -> DataRequest {
        do {
            var request = try URLRequest(url: url, method: method, headers: headers)
            let jsonData = try JSONSerialization.data(withJSONObject: parameters ?? [:])
            let compressedData = try jsonData.gzipped()
            request.httpBody = compressedData
            request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            
            return self.request(request)
        } catch {
            print("Error creating request: \(error)")
            return self.request(url, method: method, parameters: parameters, headers: headers)
        }
    }
}
