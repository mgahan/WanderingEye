# WanderingEye

A **R** package that allows the user to capture classification data from the following APIs:

- AWS Rekognition (https://aws.amazon.com/rekognition/)
- Google Cloud Vision (https://cloud.google.com/vision/)
- Microsoft Computer Vision (https://azure.microsoft.com/en-us/services/cognitive-services/computer-vision/)
- IBM Watson Visual Recognition (https://www.ibm.com/watson/services/visual-recognition/)
- ClarifAI (https://www.clarifai.com/)

## Vignettes

Several vignettes exist (or will soon exist) for this package. Please check out the links:

[Detect Labels](https://github.com/mgahan/WanderingEye/blob/master/vignettes/Detect_Labels.md)

[API Setup](https://github.com/mgahan/WanderingEye/blob/master/vignettes/API_Setup.md)

[Animal Trap Labeling](https://github.com/mgahan/WanderingEye/blob/master/vignettes/Animal_Trap_Labeling.md)

[Batch Processing](https://github.com/mgahan/WanderingEye/blob/master/vignettes/Batch_Processing.md)

[Docker setup](https://github.com/mgahan/WanderingEye/blob/master/vignettes/Run_With_Docker.md)

## API Keys

A major component of getting results from these APIs is to go through the process of creating
accounts and receiving API KEYS from each of the vendors. If you only want to use a couple of
these, don't sweat it. You only need the API KEYS for the output you want.

## Install

### Normal way

Since this package connects to various APIs, it does have some external dependencies via the terminal.
The `AWS Reognition` part of the package depends on the AWS Command Line Interface 
(http://docs.aws.amazon.com/cli/latest/userguide/installing.html).

#### Ubuntu 

```{bash}
sudo apt-get install python-pip
sudo pip install awscli
sudo R -e 'devtools::install_github("mgahan/WanderingEye")'
```

#### Mac OSX

```{bash}
sudo easy_install pip
sudo pip install awscli
sudo R -e 'devtools::install_github("mgahan/WanderingEye")'
```

#### Windows

This code should be able to work on Windows, but I am unable to test on that platform.

### Docker Way

Due to all the different APIs involved in this project, it is best to run the package from a 
Docker container. If you are not familiar with Docker, don't sweat it. Docker makes running
apps like this **EASIER**, not harder. Docker can be installed from most major platforms and the
link below can walk you through the installation process.

https://www.docker.com/community-edition

Link to **WanderingEye** docker hub page:

https://hub.docker.com/r/mgahan/wanderingeye/

#### Docker Container

Once you have the API KEYS you need, you are now ready to create the `docker` container
using the `mgahan/wanderingeye` Docker repo.

##### Create Docker container

```{bash}
containerID=$(docker run -it -d -p 8787:8787 mgahan/wanderingeye:latest)
```

##### Add API Keys as environmental variables
```{bash}
docker exec -it $containerID /bin/bash
sleep 5
echo "GCLOUD_VISION_API_KEY"="SGDFKLJGBFKLBG12345" >> /usr/local/lib/R/etc/Renviron
echo "AWS_ACCESS_KEY_ID"="AKVDNVKBFKN123" >> /usr/local/lib/R/etc/Renviron
echo "AWS_SECRET_ACCESS_KEY"="AKFJLDNkjflaldfld132" >> /usr/local/lib/R/etc/Renviron
echo "AWS_BUCKET"="test-bucket" >> /usr/local/lib/R/etc/Renviron
echo "AWS_DEFAULT_REGION"="us-west-2" >> /usr/local/lib/R/etc/Renviron
echo "MICROSOFT_API_ENDPOINT"="https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/" >> /usr/local/lib/R/etc/Renviron
echo "MICROSOFT_API_KEY1"="940nsdgnfkjgnkjgnkfmldnlds" >> /usr/local/lib/R/etc/Renviron
echo "MICROSOFT_API_KEY2"="3904nmdnfdsnfldsnflsdfnsdlfndlsk" >> /usr/local/lib/R/etc/Renviron
echo "CLARIFAI_API_KEY"="rndvlsnvlmvfnkffnmnfk3" >> /usr/local/lib/R/etc/Renviron
echo "IBM_WATSON_API"="983fnjklndknlsjnfsdlnksfln2" >> /usr/local/lib/R/etc/Renviron
echo "IBM_WATSON_VERSION"="2016-05-20" >> /usr/local/lib/R/etc/Renviron
exit
```

##### Open up RStudio-Server Container and login

```{bash}
open http://$(docker-machine ip):8787
```

## Processing Images with WanderingEye

### Setup

The `WanderingEye` package allows you to process both local images stored on disk as well
as URL images. We will show you both ways

```{r}
library(WanderingEye)

URLImagePath <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
DiskImagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
```

### Images

#### Local Disk

![](inst/ImageTests/chimney_rock.jpg?raw=true)

#### URL

![](https://sports.cbsimg.net/images/blogs/nike-football.jpg?raw=true)


### AWS Rekognition

```{r}
ImagePath1 <- "http://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/1966.png"
ImagePath2 <- "https://cdn-s3.si.com/s3fs-public/teams/basketball/nba/players/214152-300x300.png"
awsRekognition(imagePath=ImagePath1, feature="detect-labels")
awsRekognition(imagePath=ImagePath1, feature="detect-faces")
awsRekognition(imagePath=ImagePath1, feature="recognize-celebrities")
awsRekognition(imagePath=ImagePath1, targetPath=ImagePath2, feature="compare-faces")
```

### Google Cloud Vision

```{r}
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
```

### Microsoft Computer Vision

```{r}
ImagePath1 <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
ImagePath2 <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
ImagePath3 <- system.file("ImageTests", "HandwrittenNote.jpg", package="WanderingEye")
microsoftComputerVision(imagePath=ImagePath1, feature="analyze")
microsoftComputerVision(imagePath=ImagePath2, feature="analyze")
microsoftComputerVision(imagePath=ImagePath3, feature="handwriting")
```

### IBM Watson Visual Recognition

```{r}
IBMWatsonVision(imagePath=URLImagePath)
IBMWatsonVision(imagePath=DiskImagePath)
```

### ClarifAI

```{r}
clarifaiPredict(imagePath=URLImagePath)
clarifaiPredict(imagePath=DiskImagePath)
```

## Inspiration

Image recognition of camera trap photos is a promising technology for monitoring the abundance and distribution of rare animal species. There are many platforms that provide image recognition service, each with its own strengths and weaknesses. Large conservation projects that monitor diverse sets of species are in need of generalized image recognition tools that leverage multiple platforms.

## What it does

WanderingEye is a universal service layer that compiles the output from four computer vision APIs: Google Cloud Vision, Amazon Rekognition, ClarifAI, Microsoft Computer Vision, and IBM Watson. The main end goal of this product is to create a code pipeline for camera trap users or existing camera trap analysis apps such as SMART to query four image recognition APIs to receive compiled species identification data for large file sets. We provide also "composite output" which ranks the results across the four engines based on the certainty of the ID and the specificity of the output. Today, we present a demo that allows side by comparison of these computer vision algorithms for pre-processed training images.

