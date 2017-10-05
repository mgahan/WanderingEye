# WanderingEye

A **R** package that allows the user to capture classification data from the following APIs:

- AWS Rekognition (https://aws.amazon.com/rekognition/)
- Google Cloud Vision (https://cloud.google.com/vision/)
- Microsoft Computer Vision (https://azure.microsoft.com/en-us/services/cognitive-services/computer-vision/)
- IBM Watson Visual Recognition (https://www.ibm.com/watson/services/visual-recognition/)
- ClarifAI (https://www.clarifai.com/)

## Install

### Docker

Due to all the different APIs involved in this project, it is best to run the package from a 
Docker container. If you are not familiar with Docker, don't sweat it. Docker makes running
apps like this **EASIER**, not harder. Docker can be installed from most major platforms and the
link below can walk you through the installation process.

https://www.docker.com/community-edition

Link to **WanderingEye** docker hub page:

https://hub.docker.com/r/mgahan/wanderingeye/

### API Keys

A major component of getting results from these APIs is to go through the process of creating
accounts and receiving API KEYS from each of the vendors. If you only want to use a couple of
these, don't sweat it. You only need the API KEYS for the output you want.

### Docker Container

Once you have the API KEYS you need, you are now ready to create the `docker` container
using the `mgahan/wanderingeye` Docker repo.

```{bash}
docker run -it --rm \
  -e "GCLOUD_VISION_API_KEY"="SGDFKLJGBFKLBG12345" \
  -e "AWS_ACCESS_KEY_ID"="AKVDNVKBFKN123" \
  -e "AWS_SECRET_ACCESS_KEY"="AKFJLDNkjflaldfld132" \
  -e "AWS_BUCKET"="test-bucket" \
  -e "AWS_DEFAULT_REGION"="us-west-2" \
  -e "MICROSOFT_API_ENDPOINT"="https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/" \
  -e "MICROSOFT_API_KEY1"="940nsdgnfkjgnkjgnkfmldnlds" \
  -e "MICROSOFT_API_KEY2"="3904nmdnfdsnfldsnflsdfnsdlfndlsk" \
  -e "CLARIFAI_API_KEY"="rndvlsnvlmvfnkffnmnfk3" \
  -e "IBM_WATSON_API"="983fnjklndknlsjnfsdlnksfln2" \
  -e "IBM_WATSON_VERSION"="2016-05-20" \
mgahan/wanderingeye:latest /usr/local/bin/R
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
awsRekognition(imagePath=URLImagePath)
awsRekognition(imagePath=DiskImagePath)
```

### Google Cloud Vision

```{r}
googleCloudVision(imagePath=URLImagePath)
googleCloudVision(imagePath=DiskImagePath)
```

### Microsoft Computer Vision

```{r}
microsoftComputerVision(imagePath=URLImagePath)
microsoftComputerVision(imagePath=DiskImagePath)
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

