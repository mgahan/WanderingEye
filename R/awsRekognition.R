#' Retrieve output from AWS Rekognition
#'
#' Retrieve output from AWS Rekognition
#' @keywords image processing
#' @param imagePath path to image
#' @param AWS_ACCESS_KEY_ID defauts to Sys.getenv("AWS_ACCESS_KEY_ID")
#' @param AWS_SECRET_ACCESS_KEY defauts to Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' @param AWS_BUCKET defauts to Sys.getenv("AWS_BUCKET")
#' @param AWS_DEFAULT_REGION defauts to Sys.getenv("AWS_DEFAULT_REGION")
#' @export
#' @examples
#' imagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' awsRekognition(imagePath=imagePath,
#'                AWS_ACCESS_KEY_ID=Sys.getenv("AWS_ACCESS_KEY_ID"), 
#'                AWS_SECRET_ACCESS_KEY=Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
#'                AWS_BUCKET=Sys.getenv("AWS_BUCKET"), 
#'                AWS_DEFAULT_REGION=Sys.getenv("AWS_DEFAULT_REGION"))

awsRekognition <- function(imagePath, 
                           AWS_ACCESS_KEY_ID=Sys.getenv("AWS_ACCESS_KEY_ID"), 
                           AWS_SECRET_ACCESS_KEY=Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
                           AWS_BUCKET=Sys.getenv("AWS_BUCKET"), 
                           AWS_DEFAULT_REGION=Sys.getenv("AWS_DEFAULT_REGION")) {

  # If http image, then download
  if (imagePath %like% "http") {
    download.file(url=imagePath, destfile=basename(imagePath))
  }
  
  # Upload image
  TMP_DIR <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time())))
  TMP_DIR <- substr(TMP_DIR,1,8)
  AWS_IMAGE_PATH <- paste0("Images",TMP_DIR,"/",basename(ImagePath))
  UploadTxt <- paste0("aws s3 cp ",ImagePath," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH)
  UploadSys <- system(UploadTxt, intern=TRUE)
  
  # If http image, then download
  if (imagePath %like% "http") {
    removeFile <- file.remove(basename(imagePath))
  }
  
  # Code to retrieve image data
  awsCall <- paste0("aws rekognition detect-labels ",
                  "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
                  AWS_IMAGE_PATH,"\"}}'"," --output text")
  awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0)
  setnames(awsDat, c("Feature","Score","Description"))
  awsDat[, File := basename(AWS_IMAGE_PATH)]
  
  # Remove Image from S3 bucket
  RemoveTxt <- gsub(paste0("cp ",ImagePath),"rm",UploadTxt)
  RemoveSys <- system(RemoveTxt, intern=TRUE)

  # Return output
  return(awsDat[])
}


