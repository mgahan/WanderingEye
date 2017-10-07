#' Retrieve output from IBM Watson Visual Recognition
#'
#' Retrieve output from IBM Watson Visual Recognition
#' @keywords image processing
#' @param imagePath local path, url path, google storage path
#' @param IBM_WATSON_API This defaults to Sys.getenv("IBM_WATSON_API")
#' @param IBM_WATSON_VERSION This defaults to Sys.getenv("IBM_WATSON_VERSION")
#' @export
#' @examples
#' IBMWatsonVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
#' imagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' IBMWatsonVision(imagePath=imagePath)

IBMWatsonVision <- function(imagePath, 
                            IBM_WATSON_API=Sys.getenv("IBM_WATSON_API"),
                            IBM_WATSON_VERSION=Sys.getenv("IBM_WATSON_VERSION")) {

  # Create URL with API Key and Version Date
  main_url <- paste0("https://watson-api-explorer.mybluemix.net/visual-recognition/api/v3/classify?api_key=")
  url <- paste0(main_url, IBM_WATSON_API,"&version=",IBM_WATSON_VERSION)
  
  # Grab output from IBM Watson Visual API
  if (imagePath %like% "http") {
    
    # Name temporay JSON file
    TMP_FILE <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time(),rnorm(1))))
    TMP_FILE <- paste0(TMP_FILE,".json")
    
    # Process web image
    ImageFormFileTxt <- paste0('{  "url": "',imagePath,'"  }')
    cat(ImageFormFileTxt, file=TMP_FILE)
    ImageFormFile <- upload_file(TMP_FILE)
    Output <- POST(url=url,
                   config=list(add_headers("Accept"="application/json","Accept-Language"="en")),
                   body = list(images_file=ImageFormFile))
    removeFil <- file.remove(TMP_FILE)
  } else {
    ImageFormFile <- upload_file(imagePath)
    Output <- POST(url=url,
                   config=list(add_headers("Accept"="application/json","Accept-Language"="en")),
                   body = list(images_file=ImageFormFile))
  }
  
  # Search if output returned an error or not
  if (http_error(Output)) {
  	errorCode <- status_code(Output)
  	ErrorMessage <- paste0("Query returned error code ",errorCode)
  	print(ErrorMessage)
  	dat <- data.table(Class=errorCode,Score=NA_real_, Hierarchy="Error")
  } else {
	  # Parse output
	  parsed <- jsonlite::fromJSON(content(Output, "text",encoding="UTF-8"), simplifyVector = FALSE)
	  Class <- lapply(parsed$images[[1]]$classifiers[[1]]$classes, "[[", "class")
	  Class[sapply(Class, is.null)] <- NA_character_
	  Score <- lapply(parsed$images[[1]]$classifiers[[1]]$classes, "[[", "score")
	  Score[sapply(Score, is.null)] <- NA_real_
	  Hierarchy <- lapply(parsed$images[[1]]$classifiers[[1]]$classes, "[[", "type_hierarchy")
	  Hierarchy[sapply(Hierarchy, is.null)] <- NA_character_
	  dat <- data.table(Class, Score, Hierarchy)  	
  } 
  
  # Return output
  return(dat[])
}


