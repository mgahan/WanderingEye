
# Compile package
# sudo R CMD INSTALL --no-multiarch --with-keep.source ~/WanderingEye # Install R package

# Bring in package and Environmental variables
library(WanderingEye)
source("ENV_VARS.R")

# sudo apt-get install ruby-full

# Test package with URLs
googleCloudVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
microsoftComputerVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
awsRekognition(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
clarifaiPredict(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
IBMWatsonVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")

# Path to sample image from library
ImagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")

# Test package with local files
googleCloudVision(imagePath=ImagePath)
microsoftComputerVision(imagePath=ImagePath)
awsRekognition(imagePath=ImagePath)
clarifaiPredict(imagePath=ImagePath)
IBMWatsonVision(imagePath=ImagePath)

