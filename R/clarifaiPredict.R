#' Retrieve output from Clarifai Image API
#'
#' Retrieve output from Clarifai Image API
#' @keywords image processing
#' @param imagePath local path, url path, google storage path
#' @param CLARIFAI_API_KEY defaults to Sys.getenv("CLARIFAI_API_KEY")
#' @export
#' @examples
#' clarifaiPredict(imagePath="https://sports.cbsimg.net/images/blogs/nike-football.jpg")
#' imagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' clarifaiPredict(imagePath=imagePath)

clarifaiPredict <- function(imagePath, CLARIFAI_API_KEY=Sys.getenv("CLARIFAI_API_KEY")) {

  # Apply algorithm to local file using bash
  ScriptPath <- system.file("Scripts", "CallClarifai.sh", package="WanderingEye")
    
  # Grab output from Clarifai API
  if (imagePath %like% "http") {
    ClarifaiHTTPTxt <- paste0("bash ",ScriptPath," ",CLARIFAI_API_KEY," ",imagePath," url")
    ClarifaiHTTPSys <- system(ClarifaiHTTPTxt, intern=TRUE, ignore.stderr = TRUE)
    Output <- fromJSON(txt=ClarifaiHTTPSys)
  } else {
    imageBin = readBin(imagePath, "raw", file.info(imagePath)[1, "size"])
    imageBase64 = base64Encode(imageBin, "character")
    ClarifaiLocalTxt <- paste0("bash ./inst/Scripts/CallClarifai.sh ",CLARIFAI_API_KEY," ",imageBase64," base64")
    ClarifaiLocalSys <- system(ClarifaiLocalTxt, intern=TRUE, ignore.stderr = TRUE)
    Output <- fromJSON(txt=ClarifaiHTTPSys)
  }

  # Organize Output
  StatusOutput <- as.data.table(Output$outputs$status)
  DataOutput <- as.data.table(Output$outputs$data$concepts)
  
  # Check if there was an error and return output
  outList <- list(StatusOutput,DataOutput)
  names(outList) <- c("Status","Date")
  return(outList)

  # Return output
  return(outList)
}
