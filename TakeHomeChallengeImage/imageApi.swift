//
//  ImageApi.swift
//  TakeHomeChallengeImage
//
//  Created by yipeng li on 1/20/22.
//

import Foundation
import Combine

class ImageApi {
    
    private var cancellable = Set<AnyCancellable>()
    
    func images() -> Future<[Images], Never>{
        return Future{ promise in
            let taskPublisher = URLSession.shared.dataTaskPublisher(for: URL(string: "https://eulerity-hackathon.appspot.com/image")!)
            taskPublisher.map{
                $0.data
            }
            .decode(type:[Images].self, decoder: JSONDecoder())
            .sink{ completion in
                switch completion {
                case.finished:
                    print("finished")
                case .failure(_):
                    promise(.success([Images]()))
                }
            } receiveValue: { (images) in
                promise(.success(images))
            }.store(in: &self.cancellable)
        }
    }
    
}
