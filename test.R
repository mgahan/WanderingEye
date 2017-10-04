
# Compile package
# sudo R CMD INSTALL --no-multiarch --with-keep.source ~/WanderingEye # Install R package

# Bring in package and Environmental variables
library(WanderingEye)
source("ENV_VARS.R")

# sudo apt-get install ruby-full

# Test package with URLs
ImagePath <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
googleCloudVision(imagePath=ImagePath)
microsoftComputerVision(imagePath=ImagePath)
awsRekognition(imagePath=ImagePath)
clarifaiPredict(imagePath=ImagePath)
IBMWatsonVision(imagePath=ImagePath)

# Test package with local files
ImagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
googleCloudVision(imagePath=ImagePath)
microsoftComputerVision(imagePath=ImagePath)
awsRekognition(imagePath=ImagePath)
clarifaiPredict(imagePath=ImagePath)
IBMWatsonVision(imagePath=ImagePath)

