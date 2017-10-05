#' Retrieve output from Google Cloud Vision
#'
#' Retrieve output from Google Cloud Vision
#' @keywords image processing
#' @param imagePath local path, url path, google storage path
#' @param feature Defaults to "LABEL_DETECTION". One of many features:
#'                  "LABEL_DETECTION","SAFE_SEARCH_DETECTION","LOGO_DETECTION",
#'                  "IMAGE_PROPERTIES","FACE_DETECTION","CROP_HINTS","DOCUMENT_TEXT_DETECTION",
#'                  "TEXT_DETECTION","WEB_DETECTION","LANDMARK_DETECTION"
#' @param numResults Value. Probably between 5 and 10. Defaults to 10.
#' @param API_KEY This defaults to Sys.getenv("GCLOUD_VISION_API_KEY")
#' @export
#' @examples
#' ImagePath1 <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
#' ImagePath2 <- "http://ohscurrent.org/wp-content/uploads/2015/09/domus-01-google.jpg"
#' ImagePath3 <- "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Statue_of_Liberty_7.jpg/1200px-Statue_of_Liberty_7.jpg"
#' ImagePath4 <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' ImagePath5 <- "http://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/1966.png"
#' ImagePath6 <- system.file("ImageTests", "TextSample.png", package="WanderingEye")
#' googleCloudVision(imagePath=ImagePath1, feature="LABEL_DETECTION")
#' googleCloudVision(imagePath=ImagePath2, feature="LOGO_DETECTION")
#' googleCloudVision(imagePath=ImagePath3, feature="LANDMARK_DETECTION")
#' googleCloudVision(imagePath=ImagePath4, feature="WEB_DETECTION")
#' googleCloudVision(imagePath=ImagePath5, feature="FACE_DETECTION")
#' googleCloudVision(imagePath=ImagePath6, feature="TEXT_DETECTION")
#' googleCloudVision(imagePath=ImagePath6, feature="DOCUMENT_TEXT_DETECTION")
#' googleCloudVision(imagePath=ImagePath5, feature="SAFE_SEARCH_DETECTION")
#' googleCloudVision(imagePath=ImagePath5, feature="CROP_HINTS")
#' googleCloudVision(imagePath=ImagePath5, feature="IMAGE_PROPERTIES")

googleCloudVision <- function(imagePath, feature="LABEL_DETECTION", numResults=10, API_KEY=Sys.getenv("GCLOUD_VISION_API_KEY")) {

  # Function to transform image to text (such as Base64 encoding)
  imageToText <- function(imagePath) {
    # Process is different if it is a url or a local message
    if (imagePath %like% "http") {### its a url!
      content <- RCurl::getBinaryURL(imagePath)
      txt <- RCurl::base64Encode(content, "txt")
    } else {
      txt <- RCurl::base64Encode(readBin(imagePath, "raw", file.info(imagePath)[1, "size"]), "txt")
    }
    return(txt)
  }

  ############################################ LABEL DETECTION  ############################################  
  
  if (feature=="LABEL_DETECTION") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'", "maxResults": ',numResults,'} ],  }    ],}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- rbindlist(lapply(parsed$responses[[1]]$labelAnnotations, as.data.table), fill=TRUE)
      }
  ############################################ DOCUMENT TEXT DETECTION  #############################
    
  } else if (feature %in% c("TEXT_DETECTION","DOCUMENT_TEXT_DETECTION")) {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- parsed$responses[[1]]$fullTextAnnotation$text
      }
  } else if (feature=="LOGO_DETECTION") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- rbindlist(lapply(parsed$responses[[1]]$logoAnnotations, as.data.table), fill=TRUE)
      }
  } else if (feature=="LANDMARK_DETECTION") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- rbindlist(lapply(parsed$responses[[1]]$landmarkAnnotations, as.data.table), fill=TRUE)
      }
  } else if (feature=="WEB_DETECTION") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat1 <- rbindlist(lapply(parsed$responses[[1]]$webDetection$webEntities, as.data.table), fill=TRUE)
        dat2 <- rbindlist(lapply(parsed$responses[[1]]$webDetection$fullMatchingImages, as.data.table), fill=TRUE)
        dat3 <- rbindlist(lapply(parsed$responses[[1]]$webDetection$partialMatchingImages, as.data.table), fill=TRUE)
        dat4 <- rbindlist(lapply(parsed$responses[[1]]$webDetection$pagesWithMatchingImages, as.data.table), fill=TRUE)
        if (nrow(dat1) > 0) dat1[, Type := "WebEntities"]
        if (nrow(dat2) > 0) dat2[, Type := "FullMatchingImages"]
        if (nrow(dat3) > 0) dat3[, Type := "PartialMatchingImages"]
        if (nrow(dat4) > 0) dat4[, Type := "PagesWithMatchingImages"]
        dat <- rbindlist(list(dat1,dat2,dat3,dat4), fill=TRUE)
      }
  } else if (feature=="FACE_DETECTION") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- rbindlist(lapply(parsed$responses[[1]]$faceAnnotations, as.data.table), fill=TRUE)
      }
  } else if (feature=="SAFE_SEARCH_DETECTION") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- as.data.table(parsed$responses[[1]]$safeSearchAnnotation)
      }
  } else if (feature=="CROP_HINTS") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- rbindlist(lapply(parsed$responses[[1]]$cropHintsAnnotation$cropHints, as.data.table), fill=TRUE)
      }
  } else if (feature=="IMAGE_PROPERTIES") {
      # Transform image to text (such as Base64 encoding)
      txt <- imageToText(imagePath=imagePath)
      body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'"} ]  }    ]}')
    
      # Extract results for Google Cloud Vision
      output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
    
      # Search if output returned an error or not
      if (http_error(output)) {
        errorCode <- status_code(output)
        ErrorMessage <- paste0("Query returned error code ",errorCode)
        print(ErrorMessage)
        dat <- data.table(mid="Error",description=errorCode, score=NA_real_)
      } else {
        # If no error, parse output
        parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
        dat <- rbindlist(lapply(parsed$responses[[1]]$imagePropertiesAnnotation$dominantColors$colors, as.data.table), fill=TRUE)
      }
  } else {
    stop("Choose correct feature")
  }

  # Return output
  return(dat[])
}


