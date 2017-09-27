# sudo R CMD INSTALL --no-multiarch --with-keep.source WanderingEye # Install R pacakge
library(WanderingEye)
source("ENV_VARS.R")
googleCloudVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")

system("aws s3 ls s3://metabiota-rescale-west/")

# Function to grab AWS IDs
grabAWS_ID <- function(x) {
  print(x)
  awsCall <- paste0("aws rekognition detect-labels ",
                  "--image '{\"S3Object\":{\"Bucket\":\"BUCKET\",\"Name\":\"Images/",x,"\"}}'",
                  " --region us-west-2 --profile PROFILE")
  awsDat <- fread(awsCall, skip=0)
  awsDat[, File := x]
  return(awsDat)
}
