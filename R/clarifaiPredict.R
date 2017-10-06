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

  # Grab output from Clarifai API
  if (imagePath %like% "http") {
    txt <- paste0('{"inputs":[{"data":{"image":{"url":"',imagePath,'"}}}]}')
  } else {
    imageBin = readBin(imagePath, "raw", file.info(imagePath)[1, "size"])
    imageBase64 = base64Encode(imageBin, "character")
    txt <- paste0('{"inputs":[{"data":{"image":{"base64":"',imageBase64,'"}}}]}')
  }

  # Grab output with POST
  output <- POST(url="https://api.clarifai.com/v2/models/aaa03c23b3724a16a56b629203edc62c/outputs",
                 body=txt,
                 add_headers("Authorization"=paste0("Key ",Sys.getenv("CLARIFAI_API_KEY")),"Content-Type"="application/json"))
  
  # Search if output returned an error or not
  if (http_error(output)) {
    errorCode <- status_code(output)
    ErrorMessage <- paste0("Query returned error code ",errorCode)
    print(ErrorMessage)
    outDat <- data.table(id=NA_character_,name=NA_character_,value=NA_real_,app_id=NA_character_)
    outDat[, File := imagePath]
  } else {
    # Parse output
    parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
    outDat <- rbindlist(lapply(parsed$outputs[[1]]$data$concepts, as.data.table), fill=TRUE)
    outDat[, File := imagePath]
  }
  
  # Return output
  return(outDat[])
}
