#' Retrieve output from AWS Rekognition
#'
#' Retrieve output from AWS Rekognition
#' @keywords image processing
#' @param imagePath path to image
#' @param targetPath target image for the "compare-faces" features
#' @param feature defaults to "detect-labels","detect-faces","compare-faces",
#'                "recognize-celebrities","detect-moderation-labels"
#' @param AWS_ACCESS_KEY_ID defauts to Sys.getenv("AWS_ACCESS_KEY_ID")
#' @param AWS_SECRET_ACCESS_KEY defauts to Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' @param AWS_BUCKET defauts to Sys.getenv("AWS_BUCKET")
#' @param AWS_DEFAULT_REGION defauts to Sys.getenv("AWS_DEFAULT_REGION")
#' @export
#' @examples
#' imagePath <- system.file("ImageTests", "chimney_rock.jpg", package="WanderingEye")
#' awsRekognition(imagePath=imagePath,
#'                targetPath=NULL,
#'                feature="detect-labels",
#'                AWS_ACCESS_KEY_ID=Sys.getenv("AWS_ACCESS_KEY_ID"), 
#'                AWS_SECRET_ACCESS_KEY=Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
#'                AWS_BUCKET=Sys.getenv("AWS_BUCKET"), 
#'                AWS_DEFAULT_REGION=Sys.getenv("AWS_DEFAULT_REGION"))
#' ImagePath1 <- "http://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/1966.png"
#' ImagePath2 <- "https://cdn-s3.si.com/s3fs-public/teams/basketball/nba/players/214152-300x300.png"
#' awsRekognition(imagePath=ImagePath1, feature="detect-labels")
#' awsRekognition(imagePath=ImagePath1, feature="detect-faces")
#' awsRekognition(imagePath=ImagePath1, feature="recognize-celebrities")
#' awsRekognition(imagePath=ImagePath1, targetPath=ImagePath2, feature="compare-faces")

awsRekognition <- function(imagePath,
                           targetPath=NULL,
                           feature="detect-labels",
                           AWS_ACCESS_KEY_ID=Sys.getenv("AWS_ACCESS_KEY_ID"), 
                           AWS_SECRET_ACCESS_KEY=Sys.getenv("AWS_SECRET_ACCESS_KEY"), 
                           AWS_BUCKET=Sys.getenv("AWS_BUCKET"), 
                           AWS_DEFAULT_REGION=Sys.getenv("AWS_DEFAULT_REGION")) {

  # Make sure all required fields are available
  if (feature=="compare-faces" & is.null(targetPath)) {
    stop("compare-faces needs a non-null targetPath")
  }
  
  # Download source image
  if (imagePath %like% "http") {
    download.file(url=imagePath, destfile=basename(imagePath),quiet=TRUE)
  }
  
  # Download target image
  if (feature=="compare-faces") {
    download.file(url=targetPath, destfile=basename(targetPath),quiet=TRUE)
  }
  
  # Upload image
  if (imagePath %like% "http") {
    TMP_DIR <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time())))
    TMP_DIR <- substr(TMP_DIR,1,8)
    AWS_IMAGE_PATH <- paste0("Images",TMP_DIR,"/",basename(imagePath))
    UploadTxt <- paste0("aws s3 cp ",basename(imagePath)," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH)
    UploadSys <- system(UploadTxt, intern=TRUE)
    removeFile <- file.remove(basename(imagePath))
  } else {
    TMP_DIR_LNG <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time(),rnorm(1))))
    TMP_DIR <- substr(TMP_DIR_LNG,1,8)
    AWS_IMAGE_PATH <- paste0("Images",TMP_DIR,"/",basename(imagePath))
    UploadTxt <- paste0("aws s3 cp ",imagePath," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH)
    UploadSys <- system(UploadTxt, intern=TRUE)
  }
  
  # Upload source image
  if (feature=="compare-faces") {
    if (targetPath %like% "http") {
      TMP_DIR <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time())))
      TMP_DIR <- substr(TMP_DIR,1,8)
      AWS_IMAGE_PATH_SOURCE <- paste0("Images",TMP_DIR,"/",basename(targetPath))
      UploadTxt <- paste0("aws s3 cp ",basename(targetPath)," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH_SOURCE)
      UploadSys <- system(UploadTxt, intern=TRUE)
      removeFile <- file.remove(basename(targetPath))
    } else {
      TMP_DIR_LNG <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time(),rnorm(1))))
      TMP_DIR <- substr(TMP_DIR_LNG,1,8)
      AWS_IMAGE_PATH_SOURCE <- paste0("Images",TMP_DIR,"/",basename(targetPath))
      UploadTxt <- paste0("aws s3 cp ",targetPath," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH_SOURCE)
      UploadSys <- system(UploadTxt, intern=TRUE)
    }
  }

  # Code to retrieve image data
  if (feature=="detect-labels") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'"," --output text")
    awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0)
    setnames(awsDat, c("Feature","Score","Description"))
    awsDat[, File := basename(AWS_IMAGE_PATH)]
    
  } else if (feature=="detect-faces") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'",' --attributes "ALL" --output text')
    awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE)
    awsDat[, File := basename(AWS_IMAGE_PATH)]
    # awsJSON <- system(awsCall, intern=TRUE)
    # awsJSON <- paste0(awsJSON, collapse="")
    # awsJSON <- fromJSON(awsJSON)
    # awsDat <- awsJSON$FaceDetails
    # awsDat1 <- as.data.table(awsDat$Landmarks)
    # awsDat2 <- copy(awsDat)
    # awsDat2$Landmarks <- NULL
    # awsDat2 <- lapply(awsDat2, function(x) unlist(x))
    # awsDat2_Names <- names(awsDat2)
    # awsDat2_List <- lapply(1:length(awsDat2), function(x) data.table(Type=names(awsDat2[x]), Value=awsDat2[x]))
    # awsDat2 <- rbindlist(awsDat2_List, fill=TRUE)
    # awsDat1[, File := basename(AWS_IMAGE_PATH)] 
    # awsDat2[, File := basename(AWS_IMAGE_PATH)]
    # awsDat <- list(awsDat1, awsDat2)
 
  } else if (feature=="compare-faces") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--source-image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",AWS_IMAGE_PATH,"\"}}' ",
               "--target-image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",AWS_IMAGE_PATH,"\"}}' ",
               " --output text")
    awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE)
    awsDat[, File1 := basename(AWS_IMAGE_PATH)]
    awsDat[, File2 := basename(AWS_IMAGE_PATH_SOURCE)] 
    
  } else if (feature=="recognize-celebrities") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'"," --output text")
    awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE)
    setnames(awsDat, c("Feature","V1","V2","V3","V4"))
    awsDat[, File := basename(AWS_IMAGE_PATH)] 

  } else if (feature=="detect-moderation-labels") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'"," --output text")
    awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE)
    awsDat[, File := basename(AWS_IMAGE_PATH)] 
    
  } else {
    stop("Feature is not available")
  }

  
  # Remove Image from S3 bucket
  if (imagePath %like% "http") {
    RemoveTxt <- gsub(paste0("cp ",basename(imagePath)),"rm",UploadTxt)
    RemoveSys <- system(RemoveTxt, intern=TRUE)
  } else {
    RemoveTxt <- paste0("aws s3 rm s3://",AWS_BUCKET,"/",AWS_IMAGE_PATH)
    RemoveSys <- system(RemoveTxt, intern=TRUE)
  }

  # Return output
  return(awsDat[])
}


