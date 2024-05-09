import UIKit
import Alamofire

extension UIImageView {
    func af_setImage(withURL url: URL?,
                     placeholderImage placeholder: UIImage?,
                     progress: ((Double) -> Void)? = nil,
                     completed: ((Result<UIImage, AFError>) -> Void)? = nil) {
        
        guard let url = url else {
            self.image = placeholder
            return
        }
        
        self.image = placeholder
        
        AF.request(url).validate().downloadProgress { (downloadProgress) in
            progress?(downloadProgress.fractionCompleted)
        }.responseData { (response) in
            switch response.result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.image = image
                        completed?(.success(image))
                    }
                } else {
                    completed?(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                }
            case .failure(let error):
                completed?(.failure(error))
            }
        }
    }
}
