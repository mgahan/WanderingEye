#' Retrieve output from Microsoft Computer Vision API
#'
#' Retrieve output from Microsoft Computer Vision API
#' @keywords image processing
#' @param imagePath local path, url path, google storage path
#' @export
#' @examples
#' microsoftComputerVision(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
#' imagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' microsoftComputerVision(imagePath=imagePath)

microsoftComputerVision <- function(imagePath) {

  # Apply different functions if image is URL or if it is a local image
  if (imagePath %like% "http") {
    
    # Post URL using Microsoft API
    body <- paste0('{"url": "',imagePath,'"}')
    output <- POST(paste0(Sys.getenv("MICROSOFT_API_ENDPOINT"),"analyze?visualFeatures=Description,Tags"), body=body,
                   add_headers("Content-Type"="application/json","Ocp-Apim-Subscription-Key"=Sys.getenv("MICROSOFT_API_KEY1")))
    # status_code(output)
    # str(output)
  
    # Search if output returned an error or not
    if (http_error(output)) {
      errorCode <- status_code(output)
      ErrorMessage <- paste0("Query returned error code ",errorCode)
      print(ErrorMessage)
      datTags <- data.table(name="Error",confidence=NA_real_)
      datDescriptions <- data.table(text="Error",confidence=NA_real_)
      datMeta <- data.table(width=NA_integer_,height=NA_integer_,format=NA_character_)
      outList <- list(datTags,datDescriptions,datMeta)
      names(outList) <- c("Tags","Descriptions","Meta")
    } else {
      # If no error, parse output
      parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
      datTags <- rbindlist(lapply(parsed$tags, as.data.table), fill=TRUE)
      datDescriptions <- rbindlist(lapply(parsed$description$captions, as.data.table), fill=TRUE)
      datMeta <- as.data.table(parsed$metadata)
      outList <- list(datTags,datDescriptions,datMeta)
      names(outList) <- c("Tags","Descriptions","Meta")
    }
  } else {
    # Apply algorithm to local file using Ruby
    TMP_FILE <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time(),rnorm(1))))
    TMP_FILE <- paste0(TMP_FILE,".json")
    ScriptPath <- system.file("RubyScripts", "CallMicrosoft.rb", package="WanderingEye")
    MicrosoftRubyCall <- paste0('ruby ',ScriptPath,' "',
                                Sys.getenv("MICROSOFT_API_KEY1"),
                                '" "',imagePath,'" > ',TMP_FILE)
    MicrosoftRubySys <- system(MicrosoftRubyCall, intern=TRUE)
    
    # Read in data
    outList <- fromJSON(TMP_FILE)
    deleteFile <- file.remove(TMP_FILE)
    
    # Reorganize
    datTags <- as.data.table(outList$tags)
    datDescriptions <- as.data.table(outList$description$captions)
    datMeta <- as.data.table(outList$metadata)
    outList <- list(datTags,datDescriptions,datMeta)
    names(outList) <- c("Tags","Descriptions","Meta")
  }

  # Return output
  return(outList)
}
