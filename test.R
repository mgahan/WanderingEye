
# Compile package
# sudo R CMD INSTALL --no-multiarch --with-keep.source ~/WanderingEye # Install R package
# sudo apt-get install ruby-full

# Bring in package and Environmental variables
library(WanderingEye)
source("ENV_VARS.R")

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

# Test Google
ImagePath1 <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
ImagePath2 <- "http://ohscurrent.org/wp-content/uploads/2015/09/domus-01-google.jpg"
ImagePath3 <- "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Statue_of_Liberty_7.jpg/1200px-Statue_of_Liberty_7.jpg"
ImagePath4 <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
ImagePath5 <- "http://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/1966.png"
ImagePath6 <- system.file("ImageTests", "TextSample.png", package="WanderingEye")
googleCloudVision(imagePath=ImagePath1, feature="LABEL_DETECTION")
googleCloudVision(imagePath=ImagePath2, feature="LOGO_DETECTION")
googleCloudVision(imagePath=ImagePath3, feature="LANDMARK_DETECTION")
googleCloudVision(imagePath=ImagePath4, feature="WEB_DETECTION")
googleCloudVision(imagePath=ImagePath5, feature="FACE_DETECTION")
googleCloudVision(imagePath=ImagePath6, feature="TEXT_DETECTION")
googleCloudVision(imagePath=ImagePath6, feature="DOCUMENT_TEXT_DETECTION")
googleCloudVision(imagePath=ImagePath5, feature="SAFE_SEARCH_DETECTION")
googleCloudVision(imagePath=ImagePath5, feature="CROP_HINTS")
googleCloudVision(imagePath=ImagePath5, feature="IMAGE_PROPERTIES")

# Test AWS
imagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
awsRekognition(imagePath=imagePath,
               targetPath=NULL,
               feature="detect-labels",
               AWS_ACCESS_KEY_ID=Sys.getenv("AWS_ACCESS_KEY_ID"), 
               AWS_SECRET_ACCESS_KEY=Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
               AWS_BUCKET=Sys.getenv("AWS_BUCKET"), 
               AWS_DEFAULT_REGION=Sys.getenv("AWS_DEFAULT_REGION"))
ImagePath1 <- "http://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/1966.png"
ImagePath2 <- "https://cdn-s3.si.com/s3fs-public/teams/basketball/nba/players/214152-300x300.png"
awsRekognition(imagePath=ImagePath1, feature="detect-labels")
awsRekognition(imagePath=ImagePath1, feature="detect-faces")
awsRekognition(imagePath=ImagePath1, feature="recognize-celebrities")
awsRekognition(imagePath=ImagePath1, targetPath=ImagePath2, feature="compare-faces")

# Test Microsoft
ImagePath1 <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
ImagePath2 <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
ImagePath3 <- system.file("ImageTests", "HandwrittenNote.jpg", package="WanderingEye")
microsoftComputerVision(imagePath=ImagePath1, feature="analyze")
microsoftComputerVision(imagePath=ImagePath2, feature="analyze")
microsoftComputerVision(imagePath=ImagePath3, feature="handwriting")
