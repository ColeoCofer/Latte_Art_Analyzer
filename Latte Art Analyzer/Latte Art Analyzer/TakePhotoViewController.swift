//
//  TakePhotoViewController.swift
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/1/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

import UIKit

class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var takePhotoButton: UIButton!
	
	@IBOutlet weak var analyzeButtonPressed: UIButton!
	
	@IBOutlet weak var nextButton: UIBarButtonItem!
	
	//Progress bar / timer data
	@IBOutlet weak var progressBar: ProgressBarView!
	var timer: Timer!
	var progressCounter:Float = 0
	let duration:Float = 1.0
	var progressIncrement:Float = 0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		initUI()
		nextButton.isEnabled = false
    }
	
	//Next button has been pushed and will transition to the next view
	@IBAction func nextButtonPushed(_ sender: Any) {
	}
	
	//Run the detection visually so the user can see
	@IBAction func analyzeButtonPressed(_ sender: Any) {
		//Reduce the size of the image
		determineSymmetry(radius: 0.10)
		determineFraming(radius: 0.80, colorDiffThreshold: 250, outterRadius: 0.96, lumThreshold: 0.50)
		determineContrast(lightThreshold: 30, darkThreshold: 30)
		
		//Process the timer
		progressBar.isHidden = false
		progressIncrement = 1.0/duration
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.showProgress), userInfo: nil, repeats: true)
		nextButton.isEnabled = true
//		blurFirstFeatureDetection(radius: 0.89) //Uncomment to see what the photo looks like with adaptive thresh & feature detection drawn
	}
	
	//Updates progress bar
	@objc func showProgress() {
		if(progressCounter > 1.0){
			timer.invalidate()
			
			//Hide the progress bar once it's finished
			progressBar.isHidden = true
			
			//Transition to the results view
			performSegue(withIdentifier: "resultSegueID", sender: nil)

		} else {
			progressBar.progress = progressCounter
			progressCounter = progressCounter + progressIncrement
		}
	}
	
	//Take Photo button was clicked
	@IBAction func takePhotoButtonClicked(_ sender: Any) {
		//Use the camera but only if we are allowed to
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerController.SourceType.camera
			imagePicker.cameraCaptureMode = UIImagePickerController.CameraCaptureMode.photo
			imagePicker.allowsEditing = true  //Doesn't let the user to crop the image
			self.present(imagePicker, animated: true, completion: nil)
		}
	} 
	
	//This function is involked after the user has either taken a photo or selected one from their iphone photos
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imageView.contentMode = .scaleToFill
			imageView.image = pickedImage
		}
		
		//Reduce the size
		let (fullWidth, fullHeight) = getImageSize(image: imageView.image!)
		print("Full size (w, h): \(fullWidth), \(fullHeight)")
		imageView.image = resize(imageView.image!) //Maybe don't make the image smaller to the user so that it's still nice looking...
		AnalyzerModel.model.reducedResImage = imageView.image!
		let (width, height) = getImageSize(image: AnalyzerModel.model.reducedResImage!)
		print("Reduced size (w, h): \(width), \(height)")
		
		//Uncomment this code to crop the image to the center		
		/*Crop the image
		let newWidth: CGFloat = width
		let newHeight: CGFloat = width
		let origin = CGPoint(x: (width - newWidth)/2, y: (height - newHeight)/2)
		let size = CGSize(width: newWidth, height: newHeight)
		imageView.image = imageView.image?.crop(rect: CGRect(origin:origin, size:size))
		
		let (croppedWidth, croppedHeight) = getImageSize(image: imageView.image!)
		print("Cropped size: \(croppedWidth), \(croppedHeight)") */
		
		//Dismiss the pickerview back to the TakePhoto View Controller
		picker.dismiss(animated: true, completion: nil)
	}
	
	//The upload from photos button was pushed
	@IBAction func uploadPhotoButtonPushed(_ sender: Any) {
		if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = .savedPhotosAlbum
			imagePicker.allowsEditing = false
			present(imagePicker, animated: true, completion: nil)
		}
	}
	
	//Determines how much contrast is an the latte art by calculating a histogram
	func determineContrast(lightThreshold: Double, darkThreshold: Double) {
		let hist = OpenCVWrapper.calcContrastHistogram(imageView.image!, innerRadius: 0.0, outterRadius: 1, lightThreshold: lightThreshold, darkThreshold: darkThreshold)
		print("Light: \(hist[0]) Medium: \(hist[1]) Dark: \(hist[2])")
		let lightPixels = hist[0]
		let dullPixels = hist[1]
		let darkPixels = hist[2]
		let totalPixels = lightPixels + darkPixels + dullPixels
		
		let contrast = (Double(lightPixels + darkPixels - dullPixels) / Double(totalPixels)) * 100
		
		print("Contrast diff: \(contrast)")
		AnalyzerModel.model.overallContrast = contrast
	}
	
	func determineFraming(radius: Double, colorDiffThreshold: Double, outterRadius: Double, lumThreshold: Double) {
		let image = imageView.image!
		var overallFramingRating = 0.0
		
		OpenCVWrapper.determineFraming(image, latteArtRadiusPercentage: radius, overallFramingRating: &overallFramingRating, colorDiffThreshold: colorDiffThreshold, latteArtOutterRadiusPercentage: outterRadius, luminanceThreshold: lumThreshold)
		AnalyzerModel.model.overallFraming = overallFramingRating
	}
	
	//Determines the symmertry of the imageView's given
	//Takes a radius to determine how intense the blurring before
	//feature detection occurs.
	func determineSymmetry(radius: Double) {
		let image = imageView.image!
		var overall = 0.0
		var top = 0.0
		var bottom = 0.0
		
		OpenCVWrapper.determineSymmetry(image, latteArtRadiusPercentage: radius, overallSymmetryRating: &overall, topSymmetryRating: &top, bottomSymmetryRating: &bottom)
		
		//Set the symmetry amounts into the model
		AnalyzerModel.model.topSymmetry = top
		AnalyzerModel.model.bottomSymmetry = bottom
		AnalyzerModel.model.overallSymmetry = overall
	}
	
	
	//Blurs the image before feature detection to reduce the noise
	//This calculates the image too, but before the blurring occurs
	//It often doesn't find the circle when it's blurred
	func blurFirstFeatureDetection(radius: Double) {
		let image = imageView.image!
		let blurredImg = OpenCVWrapper.blurImage(image, blur:9)
		
		//Get a blurred threshold image for feature detection, but a regular threshold img for circle detection
		let blurredThreshImg = OpenCVWrapper.applyAdaptiveThreshold(blurredImg)
		let threshImg = OpenCVWrapper.applyAdaptiveThreshold(image)
		
		//Apply feature detection to blurred image
		let featThreshImg = OpenCVWrapper.drawFeatureDetection(blurredThreshImg)
		
		//Apply circle detection on regular image
		let circles = OpenCVWrapper.circleDetection(threshImg)
		
		//Draw the circles onto the image
		let circImg = OpenCVWrapper.drawCircles(featThreshImg, with:circles, latteArtRadiusPercentage: radius)
		
		imageView.image = circImg
	}
	
	//Apply adaptive thresholding,
	//Performs feature detection
	//Then calculates and draws the circle
	func featureAndCircleDetection(radius: Double) {
		let image = imageView.image!
		
		let threshImg = OpenCVWrapper.applyAdaptiveThreshold(image)
		let featThreshImg = OpenCVWrapper.drawFeatureDetection(threshImg)
		let circles = OpenCVWrapper.circleDetection(threshImg)
		let circImg = OpenCVWrapper.drawCircles(featThreshImg, with:circles, latteArtRadiusPercentage: radius)
		
		imageView.image = circImg
	}
	
	//Blurs the image in the imageview
	func blurImage() {
		let image = imageView.image!
		let blurredImg = OpenCVWrapper.blurImage(image, blur:13)
		imageView.image = blurredImg
	}
	
	//Applies adaptive thresholding to an image
	func applyAdaptiveThresholding() {
		let image = imageView.image!
		let threshImg = OpenCVWrapper.applyAdaptiveThreshold(image)
		imageView.image = threshImg
	}
	
	//Detects the outter circle, but first applies adaprive thresholding
	func drawCupCircle(radius: Double) {
		let image = imageView.image!
		let threshImg = OpenCVWrapper.applyAdaptiveThreshold(image)
		let circles = OpenCVWrapper.circleDetection(threshImg)
		let circImg = OpenCVWrapper.drawCircles(threshImg, with:circles, latteArtRadiusPercentage: radius)
		imageView.image = circImg

	}
	
	//Returns the height and width in pixels of a UIImage
	func getImageSize(image: UIImage) -> (CGFloat, CGFloat){
		let heightInPixels = image.size.height
		let widthInPixels = image.size.width
		return (heightInPixels, widthInPixels)
	}
	
	//Any UI initialization goes here
	func initUI() {
		takePhotoButton.layer.borderColor = UIColor.black.cgColor
	}
	
	//Resize an image
	//I tweaked this code but did not write the base of it
	//It can be found here:
	//https://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
	//Provided from user4267201
	func resize(_ image: UIImage) -> UIImage {
		var actualHeight = Float(image.size.height)
		var actualWidth = Float(image.size.width)
		let maxHeight: Float = 400.0
		let maxWidth: Float = 400.0
		var imgRatio: Float = actualWidth / actualHeight
		let maxRatio: Float = maxWidth / maxHeight
		let compressionQuality: Float = 0.5
		//50 percent compression
		if actualHeight > maxHeight || actualWidth > maxWidth {
			if imgRatio < maxRatio {
				//adjust width according to maxHeight
				imgRatio = maxHeight / actualHeight
				actualWidth = imgRatio * actualWidth
				actualHeight = maxHeight
			}
			else if imgRatio > maxRatio {
				//adjust height according to maxWidth
				imgRatio = maxWidth / actualWidth
				actualHeight = imgRatio * actualHeight
				actualWidth = maxWidth
			}
			else {
				actualHeight = maxHeight
				actualWidth = maxWidth
			}
		}
		let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
		UIGraphicsBeginImageContext(rect.size)
		image.draw(in: rect)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
		UIGraphicsEndImageContext()
		return UIImage(data: imageData!) ?? UIImage()
	}
}

//Extension to make cropping images easier
extension UIImage {
	func crop( rect: CGRect) -> UIImage {
		var rect = rect
		rect.origin.x*=self.scale
		rect.origin.y*=self.scale
		rect.size.width*=self.scale
		rect.size.height*=self.scale
		
		let imageRef = self.cgImage!.cropping(to: rect)
		let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
		return image
	}
}
