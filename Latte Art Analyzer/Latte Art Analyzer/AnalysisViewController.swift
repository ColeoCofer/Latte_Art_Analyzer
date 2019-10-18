//
//  AnalysisViewController.swift
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/27/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController {
	
	let ROUND_TO = 2 //Decimal places to round floats to
	
	//Symmetry UI elements
	@IBOutlet weak var topSymmetryLabel: UILabel!
	@IBOutlet weak var bottomSymmetryLabel: UILabel!
	@IBOutlet weak var overallSymmetryLabel: UILabel!
	@IBOutlet weak var faceRatingImageView: UIImageView!
	
	//Framing UI elements
	@IBOutlet weak var overallFramingLabel: UILabel!
	@IBOutlet weak var framingRatingImageView: UIImageView!
	
	//Contrast UI elements
	@IBOutlet weak var contrastRatingImageView: UIImageView!
	@IBOutlet weak var overallContrastLabel: UILabel!
	
	//Grand Total
	@IBOutlet weak var grandTotalRatingLabel: UILabel!
	@IBOutlet weak var grandTotalMessageLabel: UILabel!
	@IBOutlet weak var grandTotalRatingImageView: UIImageView!
	
	
	//Smiley face rating ranges (> value gives that rating)
	let rating_5 = 85.0
	let rating_4 = 75.0
	let rating_3 = 65.0
	let rating_2 = 55.0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		updateSymmetryResults()
		updateFramingResults()
		updateContrastRating()
		updateGrandTotalRating()
    }
	
	//Populates the UI with the grand total rating
	func updateGrandTotalRating() {
		let symmetry = AnalyzerModel.model.overallSymmetry * 100
		let contrast = AnalyzerModel.model.overallContrast * 100
		let framing = AnalyzerModel.model.overallFraming * 100
		var weightedScore = ((symmetry * 0.45) + (contrast * 0.35) + (framing * 0.20)) / 100
		
		weightedScore = weightedScore.roundToDecimal(ROUND_TO)
		grandTotalRatingLabel.text = String("\(weightedScore)%")
		
		//Determine smiley face rating and the final display message.
		if (weightedScore >= rating_5) {
			grandTotalRatingImageView.image = UIImage(named: "rating5")
			grandTotalMessageLabel.text = "Wow, amazing!"
		} else if (weightedScore >= rating_4) {
			grandTotalRatingImageView.image = UIImage(named: "rating4")
			grandTotalMessageLabel.text = "Hey, that's pretty good."
		} else if (weightedScore >= rating_3) {
			grandTotalRatingImageView.image = UIImage(named: "rating3")
			grandTotalMessageLabel.text = "It could be worse..."
		} else if (weightedScore >= rating_2) {
			grandTotalRatingImageView.image = UIImage(named: "rating2")
			grandTotalMessageLabel.text = "Well, at least your tried."
		} else {
			grandTotalRatingImageView.image = UIImage(named: "rating1")
			grandTotalMessageLabel.text = "Hm... I heard Starbucks is hiring!"
		}
	}
	
	//Populates the UI with contrast results
	func updateContrastRating() {
		let overallContrastRatings = AnalyzerModel.model.overallContrast.roundToDecimal(ROUND_TO)
		
		overallContrastLabel.text = String("Overall: \(overallContrastRatings)%")
		
		//Determine which face should be displayed. More contrast => Happier face
		if (overallContrastRatings >= rating_5) {
			contrastRatingImageView.image = UIImage(named: "rating5")
		} else if (overallContrastRatings >= rating_4) {
			contrastRatingImageView.image = UIImage(named: "rating4")
		} else if (overallContrastRatings >= rating_3) {
			contrastRatingImageView.image = UIImage(named: "rating3")
		} else if (overallContrastRatings >= rating_2) {
			contrastRatingImageView.image = UIImage(named: "rating2")
		} else {
			contrastRatingImageView.image = UIImage(named: "rating1")
		}
	}
	
	//Populates the UI with the framing results
	func updateFramingResults() {
		let overallFramingRating = AnalyzerModel.model.overallFraming.roundToDecimal(ROUND_TO)
		overallFramingLabel.text = String("Overall: \(overallFramingRating)%")
		
		//Determine which face should be displayed depending on how highly it was rated
		if (overallFramingRating >= rating_5) {
			framingRatingImageView.image = UIImage(named: "rating5")
		} else if (overallFramingRating >= rating_4) {
			framingRatingImageView.image = UIImage(named: "rating4")
		} else if (overallFramingRating >= rating_3) {
			framingRatingImageView.image = UIImage(named: "rating3")
		} else if (overallFramingRating >= rating_2) {
			framingRatingImageView.image = UIImage(named: "rating2")
		} else {
			framingRatingImageView.image = UIImage(named: "rating1")
		}
		
	}
	
	//Populates the UI with the symmetry results stored in the model
	func updateSymmetryResults() {
		let topSymmetry = AnalyzerModel.model.topSymmetry.roundToDecimal(ROUND_TO)
		let bottomSymmetry = AnalyzerModel.model.bottomSymmetry.roundToDecimal(ROUND_TO)
		let overallSymmetry = AnalyzerModel.model.overallSymmetry.roundToDecimal(ROUND_TO)

		topSymmetryLabel.text = String("Top: \(topSymmetry)%")
		bottomSymmetryLabel.text = String("Bottom: \(bottomSymmetry)%")
		overallSymmetryLabel.text = String("Overall: \(overallSymmetry)%")
		
		//Determine which face should be displayed depending on how highly it was rated
		if (overallSymmetry >= rating_5) {
			faceRatingImageView.image = UIImage(named: "rating5")
		} else if (overallSymmetry >= rating_4) {
			faceRatingImageView.image = UIImage(named: "rating4")
		} else if (overallSymmetry >= rating_3) {
			faceRatingImageView.image = UIImage(named: "rating3")
		} else if (overallSymmetry >= rating_2) {
			faceRatingImageView.image = UIImage(named: "rating2")
		} else {
			faceRatingImageView.image = UIImage(named: "rating1")
		}
	}
}

//An extension to make percision rounding easier
extension Double {
	func roundToDecimal(_ fractionDigits: Int) -> Double {
		let multiplier = pow(10, Double(fractionDigits))
		return Darwin.round(self * multiplier) / multiplier
	}
}
