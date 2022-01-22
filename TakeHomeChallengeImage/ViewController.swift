//
//  ViewController.swift
//  TakeHomeChallengeImage
//
//  Created by yipeng li on 1/20/22.
//

import UIKit
import Combine


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var images = [Images]()
    private var api = ImageApi()
    private var cancellable = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        changeLayout()
        getImages()
        
    }
    
    
    
    fileprivate func changeLayout(){
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let width = (view.frame.size.width - layout.minimumInteritemSpacing ) / 2
        layout.itemSize = CGSize(width: width, height: width )
    }
    
    fileprivate func getImages() {
        api.images()
            .receive(on: DispatchQueue.main)
            .sink {
                (images) in
                self.images = images
                self.collectionView.reloadData()
            }
            .store(in: &cancellable)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        cell.image = images[indexPath.item]
    
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let img = images[indexPath.item]
//        AF.request(img.url).responseImage { response in
//            if case .success(let image) = response.result {
//                print("image downloaded: \(image)")
//            }
//}
//
//}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        print("Loading up the datails screen")

        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        let img = images[indexPath![1]]

        let sendViewController = segue.destination as! EditImageViewController

        sendViewController.imageUrl = img.url
    }
    
}
