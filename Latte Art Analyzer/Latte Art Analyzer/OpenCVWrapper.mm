//
//  OpenCVWrapper.m
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/13/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import "OpenCVWrapper.h"
#import "opencv2/imgcodecs/ios.h"
#import "opencv2/imgproc/imgproc.hpp"
#import <cmath>

@implementation OpenCVWrapper

//Returns the version of OpenCV
+(NSString *) openCVVersionString
{
	return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}


//Draws circles onto the given image
+(UIImage *) drawCircles: (UIImage *) image with:(NSMutableArray *) circle latteArtRadiusPercentage:(double)latteRadiusPercentage
{
	//Convert UIImage to cv::Mat
	cv::Mat imgRGB;
	UIImageToMat(image, imgRGB);
	
	//Ughz Objective C is so gross
	int x = (int) [[circle objectAtIndex:0] integerValue];
	int y = (int) [[circle objectAtIndex:1] integerValue];
	int radius = (int) [[circle objectAtIndex:2] integerValue];
	
	float latteArtRadius = latteRadiusPercentage; //Latte are should be within bounds of x-% of the outter cup circle
	int lineWidth = 2;
	//Draw the circle and it's center
	cv::circle(imgRGB, cv::Point(x, y), radius, cv::Scalar(255, 0, 0), lineWidth);
	cv::circle(imgRGB, cv::Point(x, y), 2, cv::Scalar(255, 0, 0), lineWidth);
	cv::circle(imgRGB, cv::Point(x, y), radius*latteArtRadius, cv::Scalar(255, 0, 0), lineWidth);
	
	return MatToUIImage(imgRGB);
}


//Returns a gray scale version of the image
+(UIImage *) makeGrayImage:(UIImage *)image
{
	//Transform the UIImage into cv::Mat
	cv::Mat imageMat;
	UIImageToMat(image, imageMat);
	
	//Return the image if it's already grayscale
	if (imageMat.channels() == 1) return image;
	
	cv::Mat grayMat;
	cv::cvtColor(imageMat, grayMat, cv::COLOR_BGR2GRAY);
	
	return MatToUIImage(grayMat);
}


//Performs fast feature and draws them onto the image
+(UIImage *) drawFeatureDetection:(UIImage *)image
{
	//Convert image into OpenCV Matrix
	cv::Mat imgMat;
	UIImageToMat(image, imgMat);

	//Setup vector to hold keypoints
	std::vector<cv::KeyPoint> keypoints;
	
	int featureThreshold = 30; //Smaller the value the most sensative feature detection is
	//Run feature selection with your favorite detection algorithm
	cv::Ptr<cv::FeatureDetector> detector = cv::FastFeatureDetector::create(featureThreshold);
	detector->detect(imgMat, keypoints);
	
	//To draw the features, it must be in RGB without the alpha channel
	cv::Mat rgbMat;
	cv::cvtColor(imgMat, rgbMat, cv::COLOR_RGBA2RGB);
	
	//Draw the keypoints onto the image Mat
	cv::Mat userMatWithKP;
	cv::drawKeypoints(rgbMat, keypoints, userMatWithKP, cv::Scalar(0, 0, 255), cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
	
	//Convert from Mat into UIImage
	UIImage *userImgWithKP = [[UIImage alloc] init];
	userImgWithKP = MatToUIImage(userMatWithKP);

	return userImgWithKP;
}


//Performs fast feature and draws them onto the image
+(std::vector<cv::KeyPoint>) applyFeatureDetection:(UIImage *) image
{
	//Convert image into OpenCV Matrix
	cv::Mat imgMat;
	UIImageToMat(image, imgMat);
	
	//Setup vector to hold keypoints
	std::vector<cv::KeyPoint> keypoints;
	
	int featureThreshold = 20; //Smaller the value the most sensative feature detection is
	//Run feature selection with your favorite detection algorithm
	cv::Ptr<cv::FeatureDetector> detector = cv::FastFeatureDetector::create(featureThreshold);
	detector->detect(imgMat, keypoints);
	
	return keypoints;
}


//Circle detection via Hough Circle algorithm
+(NSMutableArray *) circleDetection:(UIImage *) image
{
	cv::Mat imgRGB;
	UIImageToMat(image, imgRGB);
	
	//Convert to grayscale
	UIImage *grayImage = [[UIImage alloc] init];
	grayImage = [self makeGrayImage:image];
	
	//Convert to Matrix
	cv::Mat grayMat;
	UIImageToMat(grayImage, grayMat);
	
	//Holds the circles
	std::vector<cv::Vec3f> circles;
	
	//Holds the image with detected circles
	cv::Mat outputMat;
	
	int dp = 1.2;         //The larger the value, the smaller the image gets rasterized
	int minRadius = 400;  //The minimum radius a circle can be
	
	//Find them circles
	cv::HoughCircles(grayMat, circles, cv::HOUGH_GRADIENT, dp, minRadius);
	std::cout << "\nHough Circles Found: " << circles.size() << std::endl;

	//Store the point / radius into a NSMutableArray (x, y, radius)
	NSMutableArray *circle = [[NSMutableArray alloc] init];
	if(circles.size() > 0) {
		cv::Vec3i c = circles[0];
		
		int x = (int) c[0];
		int y = (int) c[1];
		int radius = (int) c[2];
	
		//You can't put primitive types in NSMutableArrays...
		[circle addObject: [NSNumber numberWithInt:x]];
		[circle addObject: [NSNumber numberWithInt:y]];
		[circle addObject: [NSNumber numberWithInt:radius]];
	} else {
		std::cout << "************** Could not find a circle ********************" << std::endl;
		[circle addObject: [NSNumber numberWithInt:150]];
		[circle addObject: [NSNumber numberWithInt:150]];
		[circle addObject: [NSNumber numberWithInt:70]];
	}
	
	return circle;
}


//Applys adaptive thresholding to an image and returns it
+(UIImage *)applyAdaptiveThreshold:(UIImage*)image {

	//Convert to grayscale
	UIImage *grayImage = [[UIImage alloc] init];
	grayImage = [self makeGrayImage:image];
	
	cv::Mat imgMat;
	UIImageToMat(grayImage, imgMat);
	
	cv::Mat destMat;
	
	int maxValue = 100;                     //Amount given if threshold value is greater than the pixel value
	int thresholdType = cv::THRESH_BINARY;  //Type of threshold being used
	int blockSize = 51;                     //Represents the size of neighborhood to calculate the threshold from
	double C = 12;                          //Some constant that affects the type
	
	cv::adaptiveThreshold(imgMat, destMat, maxValue, cv::ADAPTIVE_THRESH_GAUSSIAN_C, thresholdType, blockSize, C);
	
	return MatToUIImage(destMat);
}

//Blurs an image so that feature detection can focus on what is important
+(UIImage *) blurImage: (UIImage *) image blur:(int) blurRadius{
	
	//Convert to cv Matrix
	cv::Mat imgMat;
	UIImageToMat(image, imgMat);	
	
	cv::Mat blurredMat;
	cv::GaussianBlur(imgMat	, blurredMat, cv::Size(blurRadius, blurRadius), 10);
	
	return MatToUIImage(blurredMat);
}

//Crops the outside of a latte cup by filling in anything outside of the circle to black
+(UIImage *) cropToCup: (UIImage *) image outterRadius:(double)oRadius
{
	UIImage *threshImg = [self applyAdaptiveThreshold:image];
	
	//Calculate circle using non-blurred adaptive threshold image
	NSMutableArray *circle = [self circleDetection:threshImg];
	
	//Parse the circle point and radius
	int cup_x = (int) [[circle objectAtIndex:0] integerValue];
	int cup_y = (int) [[circle objectAtIndex:1] integerValue];
	int radius = (int) [[circle objectAtIndex:2] integerValue];
	
	//Determine the outter and inner radius of the cup
	float outterRadius = oRadius * radius;
	
	//Crop the image to the size of the cup by making any pixel not in bounds black
	cv::Mat imgMat;
	UIImageToMat(image, imgMat);
	int width = imgMat.cols;
	int height = imgMat.rows;
	
	//Iterate through the entire image
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			
			double dist = [self distBetweenPoints:x y1:y x2:cup_x y2:cup_y];
			
			//Make pixel black if outside of bounds
			if (dist > outterRadius) {
				imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 0] = 0;
				imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 1] = 0;
				imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 2] = 0;
			}
		}
	}
	
	return MatToUIImage(imgMat);
}

//This function determines symmetry specifically by the balance of key points per quadrant
+(void) determineSymmetry: (UIImage *)image latteArtRadiusPercentage:(double)latteRadiusPercentage overallSymmetryRating:(double*)overallSymmetryRating topSymmetryRating:(double*)topSymmetryRating bottomSymmetryRating:(double*)bottomSymmetryRating
{
	UIImage *blurredImg = [self blurImage:image blur:9];
	UIImage *blurredThreshImg = [self applyAdaptiveThreshold:blurredImg];
	UIImage *threshImg = [self applyAdaptiveThreshold:image];
	
	//Calculate circle using non-blurred adaptive threshold image
	NSMutableArray *circle = [self circleDetection:threshImg];

	//Parse the circle point and radius
	int cup_x = (int) [[circle objectAtIndex:0] integerValue];
	int cup_y = (int) [[circle objectAtIndex:1] integerValue];
	int radius = (int) [[circle objectAtIndex:2] integerValue];

	float latteArtRadius = latteRadiusPercentage * radius; //Latte are should be within bounds of x-% of the outter cup circle
	
	std::vector<cv::KeyPoint> keypoints;
	keypoints = [self applyFeatureDetection:blurredThreshImg];
	
	//Talleys to keep track of how many keypoints lie in which quadrant
	int quadrantOne = 0;
	int quadrantTwo = 0;
	int quadrantThree = 0;
	int quadrantFour = 0;
	
	//Iterate keypoints
	int keypointSize = (int) keypoints.size();
	for (int i = 0; i < keypointSize; ++i) {
		
		int x = keypoints[i].pt.x;
		int y = keypoints[i].pt.y;
		
		//Calculate distance bewteen center of cup with keypoint
		double dist = [self distBetweenPoints:x y1:y x2:cup_x y2:cup_y];

		//Check if the keypoint is inbetween the cup circle and the latte art circle
		if (dist <= radius && dist >= latteArtRadius) {
			//Count how many are in each quadrant
			if (x >= cup_x && y >= cup_y) ++quadrantOne;
			if (x >= cup_x && y < cup_y) ++quadrantTwo;
			if (x < cup_x && y <= cup_y) ++quadrantThree;
			if (x < cup_x && y > cup_y) ++quadrantFour;
		}
	}
	
	//Determine how symmetric it is along the y-axis
	double diff_top = 100 - [self calcPercentDifference:quadrantOne b:quadrantFour];
	double diff_bottom = 100 - [self calcPercentDifference:quadrantThree b:quadrantTwo];
	double overallSymmetry = ((diff_top + diff_bottom) / 200) * 100;
	
	//Can assign them since they are passed by reference
	*overallSymmetryRating = overallSymmetry;
	*topSymmetryRating = diff_top;
	*bottomSymmetryRating = diff_bottom;
}

//Determines how framed the latte art is by examining a radius from the otter cup circle
//And calculating a ratio of darker/espresso colored pixels versus white / milk pixels
+(void) determineFraming: (UIImage *) image latteArtRadiusPercentage:(double)latteRadiusPercentage overallFramingRating:(double*)overallFramingRating colorDiffThreshold:(double)colorDiffThreshold latteArtOutterRadiusPercentage:(double)latteArtOutterRadiusPercentage luminanceThreshold:(double)lumThreshold {
	UIImage *threshImg = [self applyAdaptiveThreshold:image];
	
	//Calculate circle using non-blurred adaptive threshold image
	NSMutableArray *circle = [self circleDetection:threshImg];
	
	//Parse the circle point and radius
	int cup_x = (int) [[circle objectAtIndex:0] integerValue];
	int cup_y = (int) [[circle objectAtIndex:1] integerValue];
	int radius = (int) [[circle objectAtIndex:2] integerValue];
	
	float latteArtRadius = latteRadiusPercentage * radius; //Latte are should be within bounds of x-% of the outter cup circle
	float outterRadius = radius * latteArtOutterRadiusPercentage;
	std::cout << "radius: " << radius << std::endl;
	std::cout << "outter radius: " << outterRadius << std::endl;
	
	//Convert to cv Matrix so that we can access the pixel data
	cv::Mat imgMat;
	UIImageToMat(image, imgMat);
	
	int width = imgMat.cols;
	int height = imgMat.rows;
	
	//Define our espresso color to compare with
	int espresso_B = 47;
	int espresso_G = 74;
	int espresso_R = 97;
	
	float totalPixelsInFrame = 0.0f;
	float espressoColoredPixels = 0.0f;
	
	//Iterate through the image
	for (int x = 0; x < width; ++x) {
		for (int y = 0; y < height; ++y) {

			//Calculate distance bewteen center of cup with keypoint
			double dist = [self distBetweenPoints:x y1:y x2:cup_x y2:cup_y];
			
			//Check if the keypoint is inbetween the cup circle and the latte art circle
			if (dist <= outterRadius && dist >= latteArtRadius) {
				++totalPixelsInFrame;
				int b = imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 0];
				int g = imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 1];
				int r = imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 2];
				
				//Calculate the human perceived luminance of each pixel
				int perceivedLuminance = (b*0.114 + g*0.587 + r*0.299);
				
				//Calculate the absolute sum of differences between our defined espresso color and the current pixel
				float differenceSum = 0.0f;
				differenceSum += abs(b - espresso_B);
				differenceSum += abs(g - espresso_G);
				differenceSum += abs(r - espresso_R);
				
				//Check if the color is close enough to espresso color
				if (perceivedLuminance >= lumThreshold && differenceSum <= colorDiffThreshold) {
					++espressoColoredPixels;
				}
			}
		}
	}
	std::cout << "espressoColored: " << espressoColoredPixels << std::endl;
	std::cout << "total: " << totalPixelsInFrame << std::endl;
	*overallFramingRating = (espressoColoredPixels / totalPixelsInFrame) * 100;
}

//Calculates the entropy within a radius of an image by first calculating the histogram of the image
+(int*) calcContrastHistogram: (UIImage *) image innerRadius:(double)iRadius outterRadius:(double)oRadius lightThreshold:(double)lightThreshold darkThreshold:(double)darkThreshold;
{
	UIImage *threshImg = [self applyAdaptiveThreshold:image];
	
	//Calculate circle using non-blurred adaptive threshold image
	NSMutableArray *circle = [self circleDetection:threshImg];
	
	//Parse the circle point and radius
	int cup_x = (int) [[circle objectAtIndex:0] integerValue];
	int cup_y = (int) [[circle objectAtIndex:1] integerValue];
	int radius = (int) [[circle objectAtIndex:2] integerValue];
	
	//Determine the outter and inner radius of the cup
	float innerRadius = iRadius * radius;
	float outterRadius = oRadius * radius;
	
	std::cout << "Entropy radius': " << std::endl;
	std::cout << "inner radius: " << innerRadius << std::endl;
	std::cout << "outter radius: " << outterRadius << std::endl;
	
	
	//Crop the image to the size of the cup by making any pixel not in bounds black
	cv::Mat imgMat;
	UIImageToMat(image, imgMat);
	int width = imgMat.cols;
	int height = imgMat.rows;
	
	//Mini histogram to catch light (0), medium (1), and dark pixels (2)
	int *hist = new int[3];
	hist[0] = 0; hist[1] = 0; hist[2] = 0;
	
	//Histogram to hold all degrees of luminance
	//TODO: Reasearch why this returns values up to 255,
	//when I believe it should be 100
	int const fullHistogramSize = 255;
	int *fullHistogram = new int[fullHistogramSize];
	
	//Histogram to hold all color data
	int const colorHistogramSize = 255;
	int * r_hist = new int[colorHistogramSize];
	int * g_hist = new int[colorHistogramSize];
	int * b_hist = new int[colorHistogramSize];
	
	//Initalize to zero
	for (int i = 0; i < fullHistogramSize; ++i) {
		fullHistogram[i] = 0;
		r_hist[i] = 0;
		g_hist[i] = 0;
		b_hist[i] = 0;
	}
	
	//Convert to HSV
	cv::Mat hsvMat;
	cv::cvtColor(imgMat, hsvMat, cv::COLOR_BGR2HSV);
	
	//Iterate through the entire image
	for (int y = 0; y < height; ++y) {
		for (int x = 0; x < width; ++x) {
			
			double dist = [self distBetweenPoints:x y1:y x2:cup_x y2:cup_y];
			
			//Make pixel black if outside of bounds
			if (dist > outterRadius) {
				imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 0] = 0;
				imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 1] = 0;
				imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 2] = 0;
			} else {
				//We are within the latte cup
				
				//Separate out the RGB channels
				int b = imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 0];
				int g = imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 1];
				int r = imgMat.data[imgMat.channels()*(imgMat.cols*y + x) + 2];
				
				//Populate each colors histogram
				++r_hist[r-1];
				++g_hist[g-1];
				++b_hist[b-1];
				
				//Calculate luminance of each pixel
				int perceivedLuminance = (b*0.0722 + g*0.7152 + r*0.2126);
				
				//Talley the histogram
				if (perceivedLuminance <= 100 && perceivedLuminance > 0) {
					fullHistogram[perceivedLuminance] += 1;
				}
				
				//Luminance is a scale from 1 - 100 where 1 is the darkest and 100 is the lightest
				if (perceivedLuminance >= 90) {
					//Then it's light
					++hist[0];
				} else if (perceivedLuminance <= 48) {
					//Then it's dark
					++hist[2];
				} else {
					//Otherwise it's milky espresso that does not have a lot of contrast
					++hist[1];
				}
				
				cv::Vec3b hsv = hsvMat.at<cv::Vec3b>(x, y);
				int h = hsv[0];
				int s = hsv[1];
				int v = hsv[2];
				//TODO: See if HSV values helps with light variance
				
			}
		}
	}
	
	//Find a threshold value for both light and dark
	int indexOfMax = (int) std::distance(fullHistogram, std::max_element(fullHistogram, fullHistogram + fullHistogramSize));
	std::cout << "Index of max: " << indexOfMax << " : " << fullHistogram[indexOfMax] << std::endl;
	for (int i = 0; i < fullHistogramSize; ++i) {
		if (fullHistogram[i] > 0) {
		//std::cout << "(" << i << ", " << fullHistogram[i] << ")" << std::endl;
		}
	}
	
	return hist;
}


//Returns the percent difference between two numbers
+(double) calcPercentDifference: (double)a b:(double)b
{
	if (a <= b) {
		return abs(((a - b) / b) * 100);
	} else {
		return abs(((b - a) / a) * 100);
	}
}

//Calculate the distance between two points
+(double) distBetweenPoints: (int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2
{
	double xDiff = x2 - x1;
	double yDiff = y2 - y1;
	double dist = std::sqrt(xDiff * xDiff + yDiff * yDiff);
	
	return dist;
}

@end
