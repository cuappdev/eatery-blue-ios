//
//  ProfileAPIModels.swift
//  Eatery Blue
//
//  Created by Amy Yang on 11/18/26.
//

import UIKit

struct ProfileResponse: Decodable {
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let email: String?
    let photo: Photo?

    struct Photo: Decodable {
        let mimeType: String
        let data: String
    }

    var fullName: String? {
        let parts = [firstName, middleName, lastName].compactMap { $0 }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: " ").capitalized
    }

    var decodedImage: UIImage? {
        guard let photo, let data = Data(base64Encoded: photo.data) else { return nil }
        return UIImage(data: data)
    }
}

enum ProfileRequestError: Error {
    case sessionIdMissing
    case unauthorized
    case cbordUnreachable
    case server
}
