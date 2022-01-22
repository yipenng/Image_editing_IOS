//
//  EditImageViewController.swift
//  TakeHomeChallengeImage
//
//  Created by yipeng li on 1/21/22.
//

import UIKit
import Alamofire
import CoreImage

class EditImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var textField: UITextField!
    
    var currentAct = "CISepiaTone"
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    var imageUrl: String = ""
    var upLoadLink: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        AF.request(imageUrl).responseImage { response in
            if case .success(let image) = response.result {
//                print("image downloaded: \(image)")
                self.currentImage = image
                self.imageView.image = self.currentImage
                
                let filterImage = CIImage(image: self.currentImage)
                self.currentFilter.setValue(filterImage, forKey: kCIInputImageKey)
//                self.applyProcessing()
            }
    }
        title = "Filter"
        context = CIContext()
        currentFilter = CIFilter(name: currentAct)
        
        let url = URL(string: "https://eulerity-hackathon.appspot.com/upload")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                 let link = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                 self.upLoadLink = link["url"] as! String
             }
        }
        task.resume()
        
}
    
    
    
    func applyProcessing() {
            let inputKeys = currentFilter.inputKeys
            
            if inputKeys.contains(kCIInputIntensityKey){
                currentFilter.setValue(slider.value, forKey: kCIInputIntensityKey)
            }
            
            if inputKeys.contains(kCIInputScaleKey){
                currentFilter.setValue(slider.value * 10, forKey: kCIInputScaleKey)
            }
            
            if inputKeys.contains(kCIInputCenterKey){
                currentFilter.setValue(CIVector(x: imageView.image!.size.width / 2, y: imageView.image!.size.height / 2), forKey: kCIInputCenterKey)
            }
            
            guard let outputImage = currentFilter.outputImage else {return}
            
            // .extent - is a rectangle that specifies the extent of the image.
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgImage)
                imageView.image = processedImage
            }
        }
    
    
    func setFilter(action: UIAlertAction){
        
        var curImage = imageView.image!
        guard currentImage != nil else {return}
        guard let actionTitle = action.title else {return}
        self.currentAct = actionTitle
        title = actionTitle
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: curImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        }
    
    @IBAction func sliderChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Chose filter", message: nil, preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
         ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
         
         if let popoverController = ac.popoverPresentationController {
             popoverController.sourceView = sender
             popoverController.sourceRect = sender.bounds
         }
         present(ac, animated: true)
    }
    
    
    @IBAction func onAddButton(_ sender: UIButton) {
        
        let text = textField.text! as String
        
        let newImage = generateImageWithText(text: text)
        self.textField.text = ""
        imageView.image = newImage
    }
    
    func generateImageWithText(text: String) -> UIImage? {
        var image = imageView.image!

        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: imageView.image!.size.width, height: imageView.image!.size.height))
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = text
        label.font = label.font.withSize(300)


        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithText
    }
    

    
    @IBAction func save(_ sender: UIButton) {
        let imageData = imageView.image!.pngData()
        imageSubmit(fileData: imageData!, creator: "Yipengg@gmail.com", oldUrl: self.imageUrl)
    }
    
    func imageSubmit(fileData: Data, creator: String, oldUrl: String){
        guard let url = URL(string: upLoadLink) else{
            print("Link failed")
            return
        }

        AF.upload(multipartFormData: {multipartFormData in
            multipartFormData.append(fileData, withName: "editedImage: ")
            multipartFormData.append(creator.data(using: .utf8, allowLossyConversion: false)!, withName: "creator")
            multipartFormData.append(oldUrl.data(using: .utf8, allowLossyConversion: false)!, withName: "oldUrl")
        }, to: url, method: .post).uploadProgress(closure: {
            progress in print(progress.fractionCompleted * 100)
        })
            .response{
                response in
                if let data = response.data{
                    print(String(data: data, encoding: .utf8) ?? "")
                }else{
                    print("Upload failed")
                }
            }
    }
    
    
    @IBAction func clearImage(_ sender: Any) {
        imageView.image = currentImage
    }
    
    


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
