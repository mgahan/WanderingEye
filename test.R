# sudo R CMD INSTALL --no-multiarch --with-keep.source WanderingEye # Install R pacakge
library(WanderingEye)
source("ENV_VARS.R")
googleCloudVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
