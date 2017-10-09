Load library
------------

Sample files
------------

In order to test the package, it is good to have a set of sample files.
Feel free to use your own, but here some sample files that I uploaded to
Google Cloud

    # Download file
    downloadURL <- "https://storage.googleapis.com/mike-public-data/SampleAnimalPhotos.zip"
    destFile <- "SampleAnimalPhotos.zip"
    if (!file.exists(destFile)) {
      download.file(url=downloadURL, destfile = destFile)
    }

    # Unzip file
    destDir <- gsub(".zip","",destFile)
    if (!dir.exists(destDir)) {
      unzip(zipfile=destFile)
    }

File explore
------------

We can first check out how many files we have available to us.

    FileListDat <- data.table(Filename=list.files(path=destDir, recursive = TRUE, full.names = TRUE))
    kable(head(FileListDat))

Filename
--------

SampleAnimalPhotos/12227\_tapir.jpg  
SampleAnimalPhotos/12231\_porcupine.jpg  
SampleAnimalPhotos/3743-2.JPG  
SampleAnimalPhotos/ave rapaz-3734-19.JPG  
SampleAnimalPhotos/Cchinga B-Rancho Chico 3715-14.JPG
SampleAnimalPhotos/chunga 3728-5.JPG

Google Cloud Vision
-------------------

We can now forge ahead and attempt to detect labels of the image using
Google Cloud Vision. If you have not gone through the process of
extracting the Google Cloud Vision API keys, please do this before
moving onto this next step.

    SampleImage <- FileListDat[35, Filename]

![alt
text](https://storage.googleapis.com/mike-public-data/SampleAnimalPhotos/IMG_0095.JPG "IMG_0095.JPG")

    GoogleOutput <- 
      googleCloudVision(
        imagePath=SampleImage,
        feature = "LABEL_DETECTION", 
        numResults = 10,
        API_KEY = Sys.getenv("GCLOUD_VISION_API_KEY"))

    kable(GoogleOutput[])

<table>
<thead>
<tr class="header">
<th align="left">mid</th>
<th align="left">description</th>
<th align="right">score</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">/m/083jv</td>
<td align="left">white</td>
<td align="right">0.9630147</td>
</tr>
<tr class="even">
<td align="left">/m/019sc</td>
<td align="left">black</td>
<td align="right">0.9617918</td>
</tr>
<tr class="odd">
<td align="left">/m/01g6gs</td>
<td align="left">black and white</td>
<td align="right">0.9549949</td>
</tr>
<tr class="even">
<td align="left">/m/04rky</td>
<td align="left">mammal</td>
<td align="right">0.9270029</td>
</tr>
<tr class="odd">
<td align="left">/m/035qhg</td>
<td align="left">fauna</td>
<td align="right">0.9162718</td>
</tr>
<tr class="even">
<td align="left">/m/03d49p1</td>
<td align="left">monochrome photography</td>
<td align="right">0.9149839</td>
</tr>
<tr class="odd">
<td align="left">/m/01280g</td>
<td align="left">wildlife</td>
<td align="right">0.9146594</td>
</tr>
<tr class="even">
<td align="left">/m/04hgtk</td>
<td align="left">head</td>
<td align="right">0.8594266</td>
</tr>
<tr class="odd">
<td align="left">/m/0898b</td>
<td align="left">zebra</td>
<td align="right">0.8483723</td>
</tr>
<tr class="even">
<td align="left">/m/05wkw</td>
<td align="left">photography</td>
<td align="right">0.8124335</td>
</tr>
</tbody>
</table>

Microsoft Computer Vision
-------------------------

    MicrosoftOutput <- 
      microsoftComputerVision(
        imagePath=SampleImage,
        feature = "analyze",
        MICROSOFT_API_ENDPOINT = Sys.getenv("MICROSOFT_API_ENDPOINT"),
        MICROSOFT_API_KEY1 = Sys.getenv("MICROSOFT_API_KEY1"))

    kable(MicrosoftOutput$Tags[])

<table>
<thead>
<tr class="header">
<th align="left">name</th>
<th align="right">confidence</th>
<th align="left">hint</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">zebra</td>
<td align="right">0.9985831</td>
<td align="left">animal</td>
</tr>
<tr class="even">
<td align="left">animal</td>
<td align="right">0.9855506</td>
<td align="left">NA</td>
</tr>
<tr class="odd">
<td align="left">mammal</td>
<td align="right">0.7482966</td>
<td align="left">animal</td>
</tr>
</tbody>
</table>

    kable(MicrosoftOutput$Descriptions[])

<table>
<thead>
<tr class="header">
<th align="left">text</th>
<th align="right">confidence</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">a zebra is looking at the camera</td>
<td align="right">0.8817827</td>
</tr>
</tbody>
</table>

    kable(MicrosoftOutput$Meta[])

<table>
<thead>
<tr class="header">
<th align="right">width</th>
<th align="right">height</th>
<th align="left">format</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">1280</td>
<td align="right">1024</td>
<td align="left">Jpeg</td>
</tr>
</tbody>
</table>

AWS Rekognition
---------------

    AWSOutput <- 
      awsRekognition(
        imagePath=SampleImage,
        targetPath = NULL, 
        feature = "detect-labels",
        AWS_ACCESS_KEY_ID = Sys.getenv("AWS_ACCESS_KEY_ID"),
        AWS_SECRET_ACCESS_KEY = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
        AWS_BUCKET = Sys.getenv("AWS_BUCKET"),
        AWS_DEFAULT_REGION = Sys.getenv("AWS_DEFAULT_REGION"))

    kable(AWSOutput[])

<table>
<thead>
<tr class="header">
<th align="left">Feature</th>
<th align="right">Score</th>
<th align="left">Description</th>
<th align="left">File</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">LABELS</td>
<td align="right">96.46908</td>
<td align="left">Animal</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">LABELS</td>
<td align="right">96.46908</td>
<td align="left">Mammal</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">LABELS</td>
<td align="right">96.46908</td>
<td align="left">Zebra</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">LABELS</td>
<td align="right">84.84178</td>
<td align="left">Ct Scan</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">LABELS</td>
<td align="right">84.84178</td>
<td align="left">X-Ray</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
</tbody>
</table>

IBM Watson Visual Recognition
-----------------------------

    IBMOutput <-IBMWatsonVision(
      imagePath=SampleImage, 
      IBM_WATSON_API = Sys.getenv("IBM_WATSON_API"),
      IBM_WATSON_VERSION = Sys.getenv("IBM_WATSON_VERSION"))

    kable(IBMOutput[])

<table>
<thead>
<tr class="header">
<th align="left">Class</th>
<th align="left">Score</th>
<th align="left">Hierarchy</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">zebra</td>
<td align="left">0.893</td>
<td align="left">/animal/mammal/odd-toed ungulate (hoofed mammal)/zebra</td>
</tr>
<tr class="even">
<td align="left">odd-toed ungulate (hoofed mammal)</td>
<td align="left">0.992</td>
<td align="left">NA</td>
</tr>
<tr class="odd">
<td align="left">mammal</td>
<td align="left">0.992</td>
<td align="left">NA</td>
</tr>
<tr class="even">
<td align="left">animal</td>
<td align="left">0.992</td>
<td align="left">NA</td>
</tr>
<tr class="odd">
<td align="left">grevy's zebra</td>
<td align="left">0.803</td>
<td align="left">/animal/mammal/odd-toed ungulate (hoofed mammal)/grevy's zebra</td>
</tr>
<tr class="even">
<td align="left">mountain zebra</td>
<td align="left">0.5</td>
<td align="left">/animal/mammal/odd-toed ungulate (hoofed mammal)/mountain zebra</td>
</tr>
<tr class="odd">
<td align="left">coal black color</td>
<td align="left">0.961</td>
<td align="left">NA</td>
</tr>
<tr class="even">
<td align="left">black color</td>
<td align="left">0.893</td>
<td align="left">NA</td>
</tr>
</tbody>
</table>

ClarfAI
-------

    ClarifaiOutput <- clarifaiPredict(
      imagePath=SampleImage, 
      CLARIFAI_API_KEY = Sys.getenv("CLARIFAI_API_KEY"))

    kable(ClarifaiOutput[])

<table>
<thead>
<tr class="header">
<th align="left">id</th>
<th align="left">name</th>
<th align="right">value</th>
<th align="left">app_id</th>
<th align="left">File</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">ai_786Zr311</td>
<td align="left">no person</td>
<td align="right">0.9927144</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_RmpTltl9</td>
<td align="left">stripe</td>
<td align="right">0.9916375</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_8Z5lBHrh</td>
<td align="left">zebra</td>
<td align="right">0.9911756</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_fbqvMwRm</td>
<td align="left">wildlife</td>
<td align="right">0.9887770</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_tBcWlsCp</td>
<td align="left">nature</td>
<td align="right">0.9869842</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_vfV1Zf9w</td>
<td align="left">horizontal</td>
<td align="right">0.9857935</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_SzsXMB1w</td>
<td align="left">animal</td>
<td align="right">0.9585371</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_5DDJGZxT</td>
<td align="left">skin</td>
<td align="right">0.9446588</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_Zmhsv0Ch</td>
<td align="left">outdoors</td>
<td align="right">0.9396828</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_XNzGRk0F</td>
<td align="left">side view</td>
<td align="right">0.9283557</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_T85WqSNl</td>
<td align="left">camouflage</td>
<td align="right">0.9162263</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_43sQsmXM</td>
<td align="left">safari</td>
<td align="right">0.8985974</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_bBl132T0</td>
<td align="left">zoo</td>
<td align="right">0.8980871</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_6pRrC0WT</td>
<td align="left">danger</td>
<td align="right">0.8656017</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_j6rltf8j</td>
<td align="left">elegant</td>
<td align="right">0.8605607</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_xDm4LRvF</td>
<td align="left">zoology</td>
<td align="right">0.8495933</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_SVshtN54</td>
<td align="left">one</td>
<td align="right">0.8491531</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_N6BnC4br</td>
<td align="left">mammal</td>
<td align="right">0.8446156</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="odd">
<td align="left">ai_0Ngv01Hf</td>
<td align="left">contrast</td>
<td align="right">0.8444431</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
<tr class="even">
<td align="left">ai_wLQ7hLvK</td>
<td align="left">identity</td>
<td align="right">0.8337676</td>
<td align="left">main</td>
<td align="left">SampleAnimalPhotos/IMG_0095.JPG</td>
</tr>
</tbody>
</table>
