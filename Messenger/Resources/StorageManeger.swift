//
//  StorageManeger.swift
//  Messenger
//
//  Created by Alexandr Onischenko on 29.01.2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public enum StorageErrorType: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else {
                completion(.failure(StorageErrorType.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrorType.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrorType.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
}
