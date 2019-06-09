//
//  ViewController.swift
//  HackThatTrash
//
//  Created by Shruti Jana on 6/8/19.
//  Copyright © 2019 SJ. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    // @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing image.")
        }
        guard let ciimage = CIImage(image: selectedImage) else {
            fatalError("Could not convert to CIImage")
        }
        //  photoImageView.image = selectedImage
        detect(image: ciimage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: trashModel().model) else {
            fatalError("Loading CoreML Model failed.")
        }
        let request = VNCoreMLRequest(model: model) { ( request, error ) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image.")
            }
            if let firstResult = results.first {
                //self.navigationItem.title = firstResult.identifier
                
                if firstResult.identifier.contains("aluminum cans"){
                    self.navigationItem.title = "recycle"
                }
                else if firstResult.identifier.contains("apple core"){
                    self.navigationItem.title = "compost"
                }
                else if firstResult.identifier.contains("banana peel"){
                    self.navigationItem.title = "compost"
                }
                else if firstResult.identifier.contains("cardboard"){
                    self.navigationItem.title = "recycle"
                }
                else if firstResult.identifier.contains("chip bags"){
                    self.navigationItem.title = "trash"
                }
                else if firstResult.identifier.contains("compostable plates"){
                    self.navigationItem.title = "compost"
                }
                else if firstResult.identifier.contains("egg cartons"){
                    self.navigationItem.title = "recycle or trash"
                }
                else if firstResult.identifier.contains("glass bottles"){
                    self.navigationItem.title = "recycle"
                }
                else if firstResult.identifier.contains("leaf"){
                    self.navigationItem.title = "compost"
                }
                else if firstResult.identifier.contains("napkin"){
                    self.navigationItem.title = "compost"
                }
                else if firstResult.identifier.contains("paper"){
                    self.navigationItem.title = "recycle"
                }
                else if firstResult.identifier.contains("paper cups"){
                    self.navigationItem.title = "laptop"
                }
                else if firstResult.identifier.contains("plastic bags"){
                    self.navigationItem.title = "trash"
                }
                else if firstResult.identifier.contains("plastic bottles"){
                    self.navigationItem.title = "recycle"
                }
                else if firstResult.identifier.contains("plastic cups"){
                    self.navigationItem.title = "trash"
                }
                else if firstResult.identifier.contains("plastic straws"){
                    self.navigationItem.title = "trash"
                }
                else if firstResult.identifier.contains("plastic utensils"){
                    self.navigationItem.title = "trash"
                }
                else if firstResult.identifier.contains("styrofoam"){
                    self.navigationItem.title = "trash"
                }
               
                /*else do {
                     self.navigationItem.title = "Try again"
                }*/
            }
        }
        let handler = VNImageRequestHandler(ciImage: image )
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: trashModel().model)
            
            
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                
                //self.updateClassifications(for: request)
            })
            
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        self.navigationItem.title = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.navigationItem.title = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.navigationItem.title = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", /*classification.confidence,*/ classification.identifier)
                }
                self.navigationItem.title = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
  
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}
