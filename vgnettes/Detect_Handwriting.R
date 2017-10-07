
# Bring in package and Environmental variables
library(WanderingEye)
source("ENV_VARS.R")

# Convert handwritten to digital
# convert *.pdf WellnessSurvey.png
# mv *.png ./HandwrittenImages
# zip -r PTI_WellnessScans.zip PTI_WellnessScans

# Function to digitize handwriting samples
digitizeHandwriting <- function(x) {
  # Apply Microsoft Handwritten algorithm
  outList = tryCatch({
    microsoftComputerVision(imagePath=x, feature="handwriting")
  }, error = function(e) {
    data.table(Line=NA_integer_,Text=NA_character_,File=x)
  }, finally = {
  })
  Sys.sleep(3)
  return(outList)
}

# List all files
AllFiles <- list.files("~/Documents/HandwrittenImages", pattern = ".png", full.names = TRUE)

# Process files
AllOutput_01_10 <- lapply(AllFiles[1:10], digitizeHandwriting)
AllOutput_11_20 <- lapply(AllFiles[11:20], digitizeHandwriting)
AllOutput_21_50 <- lapply(AllFiles[21:50], digitizeHandwriting)
AllOutput_51_100 <- lapply(AllFiles[51:100], digitizeHandwriting)
AllOutput_101_200 <- lapply(AllFiles[101:200], digitizeHandwriting)
AllOutput_201_288 <- lapply(AllFiles[201:288], digitizeHandwriting)
AllOutput_01_10_Dat <- rbindlist(AllOutput_01_10, fill=TRUE)
AllOutput_11_20_Dat <- rbindlist(AllOutput_11_20, fill=TRUE)
AllOutput_21_50_Dat <- rbindlist(AllOutput_21_50, fill=TRUE)
AllOutput_51_100_Dat <- rbindlist(AllOutput_51_100, fill=TRUE)
AllOutput_101_200_Dat <- rbindlist(AllOutput_101_200, fill=TRUE)
AllOutput_201_288_Dat <- rbindlist(AllOutput_201_288, fill=TRUE)
AllOutputDat <- rbindlist(list(AllOutput_01_10_Dat,AllOutput_11_20_Dat,AllOutput_21_50_Dat,AllOutput_51_100_Dat,
                            AllOutput_101_200_Dat,AllOutput_201_288_Dat), fill=TRUE)
AllOutputDat[, Filename := basename(File)]

# These two images are upside down. Rotate them
AllOutputDat[Filename=="WellnessSurvey-13.png"]
AllOutputDat[Filename=="WellnessSurvey-14.png"]
AllOutputDat <- AllOutputDat[Filename!="WellnessSurvey-13.png"]
AllOutputDat <- AllOutputDat[Filename!="WellnessSurvey-14.png"]

AllFilesSub <- AllFiles[which(basename(AllFiles) %in% paste0("WellnessSurvey-",c(13,14),".png"))]
AllOutput_13_14 <- lapply(AllFilesSub, digitizeHandwriting)
AllOutput_13_14_Dat <- rbindlist(AllOutput_13_14, fill=TRUE)
AllOutputDat <- rbindlist(list(AllOutputDat, AllOutput_13_14_Dat), fill=TRUE)
AllOutputDat[!is.na(File), Filename := basename(File)]
AllOutputDat <- AllOutputDat[, .(Line, Text, Filename)]

# Save data
AllOutputDat[, File := NULL]
saveRDS(AllOutputDat, file="~/Documents/PTI_Wellness_Handwritten_Conversion.rds")
fwrite(AllOutputDat, "PTI_Wellness_Handwritten_Conversion.csv")       

# Convert questions
AllOutputDat <- AllOutputDat[, .(Line, Text, Filename)]
AllOutputDat[, .SD[1], keyby=.(Filename)][, .N, keyby=.(Text)]
AllOutputDat[, Text := tolower(Text)]
AllOutputDat[, Question := NA_integer_]
AllOutputDat[Text %like% "you choose the"]
AllOutputDat[Text %like% "you choose the", Question := 1L]
AllOutputDat[Text %like% "like field of polic", Question := 1L]
AllOutputDat[Text %like% "why did you", Question := 1L]
AllOutputDat[Text %like% "your career goals"] 
AllOutputDat[Text %like% "your career goals", Question := 2L]
AllOutputDat[Text %like% "your career", Question := 2L]
AllOutputDat[Text %like% "what are your", Question := 2L]
AllOutputDat[Text %like% "and rank what"]
AllOutputDat[Text %like% "and rank what", Question := 3L]
AllOutputDat[Text %like% "list and rank", Question := 3L]
AllOutputDat[Text %like% "you think", Question := 3L]
AllOutputDat[Text %like% "most important things"]
AllOutputDat[Text %like% "most important things", Question := 4L]
AllOutputDat[Text %like% "in your life", Question := 4L]
AllOutputDat[Text %like% "mostimport", Question := 4L]
AllOutputDat[Filename=="WellnessSurvey-0.png"]
AllOutputDat[is.na(Question), Question := 0]
AllOutputDat[, Question := cummax(Question), keyby=.(Filename)]
AllOutputCollapsed <- AllOutputDat[, .(Q_Txt=paste0(Text, collapse = " ")), by=.(Filename,Question)]
AllOutputCollapsed[, ID := as.numeric(gsub(".png","",gsub("WellnessSurvey-","",Filename)))]
AllOutputCollapsed[, ID2 := stringr::str_pad(ID,3,pad="0")]
AllOutputCollapsed[, Filename := paste0("WellnessSurvey-",ID2,".png")]
AllOutputCollapsed[, c("ID","ID2") := NULL]
setorder(AllOutputCollapsed, Filename, Question)
fwrite(AllOutputCollapsed, "PTI_Wellness_Handwritten_Conversion_Collapsed.csv")       


# AllOutputDat[Question==1L, QuestionTxt := "why did you choose the field of policing ?"]
# AllOutputDat[Question==2L, QuestionTxt := "what are your career goals in this field ?"]
# AllOutputDat[Question==3L, QuestionTxt := "list and rank what you think the 3 primary stressors will be"]
# AllOutputDat[Question==4L, QuestionTxt := "what are the 5 most important things in your life ?"]
# AllOutputDat[, QuestionInd := 1*(!is.na(Question))]
# AllOutputDat[, QuestionAssoc := cumsum(QuestionInd), by=.(Filename)]
# AllOutputDat[QuestionAssoc==1]
# checkQ1 <- AllOutputDat[, sum(Question==4, na.rm=TRUE), keyby=.(Filename)][order(V1)]
# checkQ1[V1==0]
# AllOutputDat[Filename=="WellnessSurvey-126.png"]
# AllOutputDat[Filename=="WellnessSurvey-167.png"]
# AllOutputDat[Filename=="WellnessSurvey-271.png"]

#file.copy(from="./HandwrittenImages/WellnessSurvey-13.png", to="WellnessSurvey-13_upsidedown.png")
#file.copy(from="./HandwrittenImages/WellnessSurvey-14.png", to="WellnessSurvey-14_upsidedown.png")
#convert WellnessSurvey-13_upsidedown.png -rotate 180 ./HandwrittenImages/WellnessSurvey-13.png
#convert WellnessSurvey-14_upsidedown.png -rotate 180 ./HandwrittenImages/WellnessSurvey-14.png

# Do some spell-checking
library(hunspell)
test <- AllOutputDat[64, Text]
test <- paste0("To help people when they are In the dentist what")
text <- "whatare the mostimportant things in your life?"
bad <- hunspell(text)
hunspell_suggest(bad[[1]][1])
hunspell_suggest(bad[[1]][2])

# imagePath="outfile-0.png"
# feature="DOCUMENT_TEXT_DETECTION"
# API_KEY=Sys.getenv("GCLOUD_VISION_API_KEY")
# numResults=100
# 
# # Function to transform image to text (such as Base64 encoding)
# imageToText <- function(imagePath) {
#   # Process is different if it is a url or a local message
#   if (imagePath %like% "http") {### its a url!
#     content <- RCurl::getBinaryURL(imagePath)
#     txt <- RCurl::base64Encode(content, "txt")
#   } else {
#     txt <- RCurl::base64Encode(readBin(imagePath, "raw", file.info(imagePath)[1, "size"]), "txt")
#   }
#   return(txt)
# }
# 
# # Transform image to text (such as Base64 encoding)
# txt <- imageToText(imagePath=imagePath)
# body <- paste0('{  "requests": [    {   "image": { "content": "',txt,'" }, "features": [  { "type": "',feature,'", "maxResults": ',numResults,'} ],  }    ],}')
# 
# # Extract results for Google Cloud Vision
# output <- POST(paste0("https://vision.googleapis.com/v1/images:annotate?key=",API_KEY), body=body)
# parsed <- jsonlite::fromJSON(content(output, "text"), simplifyVector = FALSE)
#  
# dat <- rbindlist(lapply(parsed$responses[[1]]$fullTextAnnotation$text, as.data.table), fill=TRUE)
# sampleText <- dat[1, V1]
# 
# Q1 <- "Why did you choose the field of policing?"
# Q2 <- "What are your career goals in this field?"
# Q3 <- "List and rank what you think the 3 primary stressors will be."
# Q4 <- "What are the most important things in your life?"
# 
# A1 <- gsub(paste0('^.*',Q1,'\\s*|\\s*',Q2,'.*$'), '', sampleText)
# A2 <- gsub(paste0('^.*',Q2,'\\s*|\\s*',Q3,'.*$'), '', sampleText)
# A3 <- gsub(paste0('^.*',Q3,'\\s*|\\s*',Q4,'.*$'), '', sampleText)
# A3 <- strsplit(A3,"\n")
# A4 <- gsub(paste0('^.*',Q4,'\\s*|\\s*',Q4,'.*$'), '', sampleText)
# A4 <- strsplit(A4,"\n")
