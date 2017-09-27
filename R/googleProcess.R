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
#' googleCloudVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")

googleCloudVision <- function(imagePath, feature="LABEL_DETECTION", numResults=10, API_KEY=Sys.getenv("GCLOUD_VISION_API_KEY")) {

  # Function to transform image to text (such as Base64 encoding)
  imageToText <- function(imagePath) {
    # Process is different if it is a url or a local message
    if (stringr::str_count(imagePath, "http")>0) {### its a url!
      content <- RCurl::getBinaryURL(imagePath)
      txt <- RCurl::base64Encode(content, "txt")
    } else {
      txt <- RCurl::base64Encode(readBin(imagePath, "raw", file.info(imagePath)[1, "size"]), "txt")
    }
    return(txt)
  }

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

  # Return output
  return(dat[])
}


