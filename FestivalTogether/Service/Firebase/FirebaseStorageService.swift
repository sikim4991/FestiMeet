//
//  FirebaseStorageService.swift
//  FestivalTogether
//
//  Created by SIKim on 10/25/24.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseStorage

///Firebase - FireStorage 관련 서비스
class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    let storage = Storage.storage()
    
    private init() { }
    
    ///프로필 이미지 Storage에 업로드
    func uploadImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.1) else { return }
        let path = "profileImage/\(UUID().uuidString).jpg"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //storage에 저장 후 firestore에 해당 User 프로필 url 저장
        storage.reference().child(path).putData(data, metadata: metaData) { [weak self] (metaData, error) in
            self?.storage.reference().child(path).downloadURL { (url, error) in
                guard let urlString = url?.absoluteString else { return }
                Task {
                    await FirebaseFirestoreService.shared.updateProfileImageURLString(imageURLString: urlString)
                }
            }
        }
    }
    
    ///프로필 이미지 Storage에서 삭제
    func removeImage(profileImageURLString: String) async {
        do {
            try await storage.reference(forURL: profileImageURLString).delete()
        } catch {
            print("Remove Image Error : \(error)")
        }
    }
}
