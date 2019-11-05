# Latte_Art_Analyzer

### Overview
I created this iPhone App for a computer vision course at Portland State University. 
It leverages OpenCV (called in C++, wrapped by Objective-C and Swift) to analyze pictures of latte art and rate them in a non-bias manner.
While it's far from finished, I've been pretty happy on the outcome for a terms worth of work. 

The app rates latte art on three main criteria: Symmetry, Framing, and Contrast.
To detect the cup I used Hough Circle Detection after first applying an Adaptive Threshold to bring extra contrast to the outter cup ring.

#### Symmetry
* It uses Fast Feature Detection to detect the key points. This worked best for my after applying gaussion blur and adaptive thresholding.
* Next, it checks if key point distances across the y-axis are within a neighborhood have similar luminance and similar color
* With this information, it determines the symmetry by splitting the cup into quadrants and calculating the ratio of key points between quadrants <br>

![An example of what the latte art looks like after applying adaptive thresholding and comparing keypoints across the y-axis.](https://raw.githubusercontent.com/ColeoCofer/Latte_Art_Analyzer/master/Images/sym.png)

![Finding key points, the outter cup ring, and the inner cup ring that circles the latte art.](https://raw.githubusercontent.com/ColeoCofer/Latte_Art_Analyzer/master/Images/adaptiveThresholdKeyPoints.png)

#### Framing
* Inserts concentric circles and compares amount of intersecting key points to best fit frame
* Iterates through pixels within frame and calculates ration of espresso colored pixels to milky ones
* Determines framing by then splitting frame into quadrants and comparing the centeredness

#### Contrast
* Creates a histogram of luminance
* Finds the max on each side
* Checks where each value falls within range.


### Results
Example Results for a latte image:<br>
![Test latte art image.](https://raw.githubusercontent.com/ColeoCofer/Latte_Art_Analyzer/master/Images/test1.png)

![Results from App.](https://raw.githubusercontent.com/ColeoCofer/Latte_Art_Analyzer/master/Images/sampleResults.png)

### Future Work
* While most of these metrics work well, they all greatly depend on environment lighting, and could be improved by accomodating for that. 
  * Many of the constants need to be "hand tweaked" for different environments where light is not uniform.
* Cup detection could be improved by calculating contours and using the area to determine the cup.
