//
//  OpenCVWrapper.h
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/13/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

//Interfaces for OpenCV

//Gets a string with the version number
+(NSString *) openCVVersionString;

//Draw circles onto an image
+(UIImage *) drawCircles: (UIImage *) image with:(NSMutableArray *) circles latteArtRadiusPercentage:(double)latteRadiusPercentage;

//Converts an image from color into grayscale
+(UIImage *) makeGrayImage: (UIImage *) image;

//Performs fast feature detection via openCV and returns an image with them draw on it
+(UIImage *) drawFeatureDetection: (UIImage *) image;

//Circle detection via HoughCircles
//This is used to detect the outer circle of the cup
//Returns a vector of the circles (point and center)
+(NSMutableArray *) circleDetection: (UIImage *) image;

//Applys adaptive threshold to an image
+(UIImage *) applyAdaptiveThreshold: (UIImage *) image;

//Blurs an image for more affective feature detection
+(UIImage *) blurImage: (UIImage *) image blur:(int) blurRadius;

//Crops the outside of a latte cup by filling in anything outside of the circle to black
+(UIImage *) cropToCup: (UIImage *) image outterRadius:(double)oRadius;

//Determines how symmetric the latte art is across the y-axis
//Returns an array where index 0 = overallSymmetry, 1 = top symmetry, 2 = bottom symmetry
+(void) determineSymmetry: (UIImage *) image latteArtRadiusPercentage:(double)latteRadiusPercentage overallSymmetryRating:(double*)overallSymmetryRating topSymmetryRating:(double*)topSymmetryRating bottomSymmetryRating:(double*)bottomSymmetryRating;

//Determines how framed the latte art is
+(void) determineFraming: (UIImage *) image latteArtRadiusPercentage:(double)latteRadiusPercentage overallFramingRating:(double*)overallFramingRating colorDiffThreshold:(double)colorDiffThreshold latteArtOutterRadiusPercentage:(double)latteArtOutterRadiusPercentage luminanceThreshold:(double)lumThreshold;

//Calculate entropy from histogram
+(int*) calcContrastHistogram: (UIImage *) image innerRadius:(double)innerRadius outterRadius:(double)outterRadius lightThreshold:(double)lightThreshold darkThreshold:(double)darkThreshold;

@end

NS_ASSUME_NONNULL_END
