#' Retrieve output from AWS Rekognition
#'
#' Retrieve output from AWS Rekognition
#' @keywords image processing
#' @param x
#' @export
#' @examples
#' awsRekognition(x="chimney_rock.jpg")

awsRekognition <- function(x) {

  # Upload image
  # Code to upload image

  # Code to retrieve image data
  AWS_BUCKET <- "metabiota-rescale-west"
  AWS_IMAGE_PATH <- "Images/chimney_rock.jpg"
  awsCall <- paste0("aws rekognition detect-labels ",
                  "--image '{\"S3Object\":{\"Bucket\":\"",AWS_BUCKET,"\",\"Name\":\"",
                  AWS_IMAGE_PATH,"\"}}'"," --output text")
  awsDat <- fread(paste0(awsCall," | grep -v 'ROTATE_0'"), skip=0)
  setnames(awsDat, c("Feature","Score","Description"))
  awsDat[, File := x]

  # Return output
  return(awsDat[])
}


