#' Retrieve output from Microsoft Computer Vision API
#'
#' Retrieve output from Microsoft Computer Vision API
#' @keywords image processing
#' @param imagePath local path, url path, google storage path
#' @param feature defaults to 'analyze'. 'analyze','handwriting'
#' @param MICROSOFT_API_ENDPOINT defaults to Sys.getenv("MICROSOFT_API_ENDPOINT")
#' @param MICROSOFT_API_KEY1 defaults to Sys.getenv("MICROSOFT_API_KEY1")
#' @export
#' @examples
#' ImagePath1 <- "https://sports.cbsimg.net/images/blogs/nike-football.jpg"
#' ImagePath2 <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' ImagePath3 <- system.file("ImageTests", "HandwrittenNote.jpg", package="WanderingEye")
#' microsoftComputerVision(imagePath=ImagePath1, feature="analyze")
#' microsoftComputerVision(imagePath=ImagePath2, feature="analyze")
#' microsoftComputerVision(imagePath=ImagePath3, feature="handwriting")

microsoftComputerVision <- function(imagePath, 
                                    feature="analyze",
                                    MICROSOFT_API_ENDPOINT=Sys.getenv("MICROSOFT_API_ENDPOINT"),
                                    MICROSOFT_API_KEY1=Sys.getenv("MICROSOFT_API_KEY1")) {

  # What IP to query
  if (feature=="analyze") {
    API_PATH <- paste0(MICROSOFT_API_ENDPOINT,"analyze?visualFeatures=Description,Tags")
  } else if (feature=="handwriting") {
    API_PATH <- paste0(MICROSOFT_API_ENDPOINT,"recognizeText?handwriting=true")
  } else {
    stop("Please check feature argument")
  }
  
  # Apply different functions if image is URL or if it is a local image
  if (imagePath %like% "http") {
    # Post URL using Microsoft API
    body <- paste0('{"url": "',imagePath,'"}')
    outputPOST <- POST(API_PATH, body=body, add_headers("Content-Type"="application/json","Ocp-Apim-Subscription-Key"=MICROSOFT_API_KEY1))
    
    # Retry if error code is 429
    if (status_code(outputPOST)==429) {
    	Sys.sleep(3)
    	outputPOST <- POST(API_PATH, body=body, add_headers("Content-Type"="application/json","Ocp-Apim-Subscription-Key"=MICROSOFT_API_KEY1))
    }
  } else {
    txt <- (readBin(imagePath, "raw", file.info(imagePath)[1, "size"]))
    outputPOST <- POST(API_PATH, body=txt, add_headers("Content-Type"="application/octet-stream","Ocp-Apim-Subscription-Key"=MICROSOFT_API_KEY1))
    
    # Retry if error code is 429
    if (status_code(outputPOST)==429) {
    	Sys.sleep(3)
    	outputPOST <- POST(API_PATH, body=body, add_headers("Content-Type"="application/json","Ocp-Apim-Subscription-Key"=MICROSOFT_API_KEY1))
    }
  }
  
  # Search if output returned an error or not
  if (http_error(outputPOST)) {
      
    # Detect errors
    errorCode <- status_code(outputPOST)
    ErrorMessage <- paste0("Query returned error code ",errorCode)
    print(ErrorMessage)
      
    # Return in appropriate output
    if (feature=="analyze") {
      datTags <- data.table(name="Error",confidence=NA_real_)
      datDescriptions <- data.table(text="Error",confidence=NA_real_)
      datMeta <- data.table(width=NA_integer_,height=NA_integer_,format=NA_character_)
      outList <- list(datTags,datDescriptions,datMeta)
      names(outList) <- c("Tags","Descriptions","Meta")
      return(outList[])
    } else if (feature=="handwriting") {
      outDat <- data.table(Line=NA_integer_, Text=paste0("Error= ",errorCode))
      return(outDat)
    } else {
      stop("Incorrect 'feature' parameter")
    }
  }
  
  if (feature=="analyze") {
    parsed <- jsonlite::fromJSON(content(outputPOST, "text"), simplifyVector = FALSE)
    datTags <- rbindlist(lapply(parsed$tags, as.data.table), fill=TRUE)
    datDescriptions <- rbindlist(lapply(parsed$description$captions, as.data.table), fill=TRUE)
    datMeta <- as.data.table(parsed$metadata)
    outDat <- list(datTags,datDescriptions,datMeta)
    names(outDat) <- c("Tags","Descriptions","Meta")
  } else if (feature=="handwriting") {
    # Extract using GET
    operationLocation <- outputPOST$all_headers[[1]]$headers$`operation-location`
    Sys.sleep(3)
    outputGET <- GET(operationLocation, body=body, add_headers("Content-Type"="application/json","Ocp-Apim-Subscription-Key"=MICROSOFT_API_KEY1))
    
    # Extract content
    parsed <- jsonlite::fromJSON(content(outputGET, "text"), simplifyVector = FALSE)
    out1 <- lapply(parsed$recognitionResult$lines, "[[", "words")
    extractLine <- function(x) {
      outLine <- paste0(unlist(lapply(out1[[x]], "[[", "text")), collapse = " ")
      return(outLine)
    }
    outTxt <- lapply(1:length(out1), extractLine)
    outDat <- rbindlist(lapply(outTxt,as.data.table), fill=TRUE)
    outDat <- outDat[, .(Line=1:.N, Text=V1)]
    outDat[, File := imagePath]
  }
  
  # Return output
  return(outDat[])
}
