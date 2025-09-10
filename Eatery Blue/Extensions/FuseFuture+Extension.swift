//
//  FuseFuture+Extension.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Combine
import Fuse

extension Fuse {
    func searchPublisher(
        _ text: String,
        in aList: [Fuseable],
        chunkSize: Int = 100
    ) -> AnyPublisher<[FusableSearchResult], Never> {
        Future { [self] promise in
            search(text, in: aList, chunkSize: chunkSize) { result in
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
}
