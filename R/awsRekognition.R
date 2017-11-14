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
  
  # Create TMP image filenames
  EXT1 <- tools::file_ext(imagePath)
  EXT2 <- ifelse(is.null(targetPath), ".jpg", tools::file_ext(targetPath))
  TMP_FILE1 <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time(),rnorm(1))))
  TMP_FILE2 <- gsub("\\s+","",gsub("[[:punct:]]","",paste0(Sys.time(),rnorm(1))))
  TMP_FILE1 <- paste0(TMP_FILE1,".",EXT1)
  TMP_FILE2 <- paste0(TMP_FILE2,".",EXT2)
  TMP_DIR <- substr(TMP_FILE1,1,8)
  
  # Download source image
  if (imagePath %like% "http") {
    download.file(url=imagePath, destfile=TMP_FILE1,quiet=TRUE)
    # Download target image
    if (feature=="compare-faces") {
      download.file(url=targetPath, destfile=TMP_FILE2,quiet=TRUE)
    }
  }
  
  # Upload image
  if (imagePath %like% "http") {
    AWS_IMAGE_PATH <- paste0("Images",TMP_DIR,"/",TMP_FILE1)
    UploadTxt <- paste0("aws s3 mv '",TMP_FILE1,"' 's3://", AWS_BUCKET,"/",AWS_IMAGE_PATH,"'")
    UploadSys <- system(UploadTxt, intern=TRUE)
    #removeFile <- file.remove(TMP_FILE1)
  } else {
    AWS_IMAGE_PATH <- paste0("Images",TMP_DIR,"/",TMP_FILE1)
    UploadTxt <- paste0("aws s3 cp '",imagePath,"' 's3://", AWS_BUCKET,"/",AWS_IMAGE_PATH,"'")
    UploadSys <- system(UploadTxt, intern=TRUE)
  }
  
  # Upload source image
  if (feature=="compare-faces") {
    if (targetPath %like% "http") {
      AWS_IMAGE_PATH_SOURCE <- paste0("Images",TMP_DIR,"/",TMP_FILE2)
      UploadTxt <- paste0("aws s3 mv ",TMP_FILE2," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH_SOURCE)
      UploadSys <- system(UploadTxt, intern=TRUE)
      #removeFile <- file.remove(basename(targetPath))
    } else {
      AWS_IMAGE_PATH_SOURCE <- paste0("Images",TMP_DIR,"/",TMP_FILE2)
      UploadTxt <- paste0("aws s3 cp ",targetPath," s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH_SOURCE)
      UploadSys <- system(UploadTxt, intern=TRUE)
    }
  }

  # Code to retrieve image data
  if (feature=="detect-labels") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'"," --output text")
    # if fread has error, it is probably empty
    awsDat = tryCatch({
      fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE, header=FALSE)
    }, error = function(e) {
      data.table(V1="No data returned")
    }, finally = {
    })
    setnames(awsDat, c("Feature","Score","Description"))
    awsDat[, File := imagePath]
    
  } else if (feature=="detect-faces") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'",' --attributes "ALL" --output text')
    # if fread has error, it is probably empty
    awsDat = tryCatch({
      fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE, header=FALSE)
    }, error = function(e) {
      data.table(V1="No data returned")
    }, finally = {
    })
    awsDat[, File := imagePath]
 
  } else if (feature=="compare-faces") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--source-image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",AWS_IMAGE_PATH,"\"}}' ",
               "--target-image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",AWS_IMAGE_PATH_SOURCE,"\"}}' ",
               " --output text")
    # if fread has error, it is probably empty
    awsDat = tryCatch({
      fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE, header=FALSE)
    }, error = function(e) {
      data.table(V1="No data returned")
    }, finally = {
    })
    awsDat[, File1 := imagePath]
    awsDat[, File2 := targetPath] 
    
  } else if (feature=="recognize-celebrities") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'"," --output text")
    # if fread has error, it is probably empty
    awsDat = tryCatch({
      fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, header=FALSE, fill=TRUE)
    }, error = function(e) {
      data.table(V1="No data returned")
    }, finally = {
    })
    setnames(awsDat, c("Feature","V1","V2","V3","V4"))
    awsDat[, File := imagePath] 

  } else if (feature=="detect-moderation-labels") {
    
    awsCall <- paste0("aws rekognition ",feature," ",
               "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
               AWS_IMAGE_PATH,"\"}}'"," --output text")

    # if fread has error, it is probably empty
    awsDat = tryCatch({
      fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0, fill=TRUE, header=FALSE)
    }, error = function(e) {
      data.table(V1="No data returned")
    }, finally = {
    })
    awsDat[, File := imagePath] 
    
  } else {
    stop("Feature is not available")
  }

  # Remove Image from S3 bucket
  RemoveTxt1 <- paste0("aws s3 rm s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH)
  RemoveSys1 <- system(RemoveTxt1, intern=TRUE)
  
  # Remove target image from S3 bucket
  if (feature=="compare-faces") {
    RemoveTxt2 <- paste0("aws s3 rm s3://", AWS_BUCKET,"/",AWS_IMAGE_PATH_SOURCE)
    RemoveSys2 <- system(RemoveTxt2, intern=TRUE)
  }

  # Return output
  return(awsDat[])
}


