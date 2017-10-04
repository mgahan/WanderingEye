N<-28
RC<-27
secs<-numeric(N)
speeds<-numeric(N)
con<-file("test.jpg", "rb")
for(i in seq.int(N)) {
    print(i)
    secs[i] <- as.numeric(readChar(con,8))
    stopifnot(readChar(con,2)==":$") #check
    readBin(con,"raw",3) #skip 3 bytes
    speeds[i] <- readBin(con, "int",1,2, signed=F)
    readBin(con,"raw",10) #skip 10 bytes
    stopifnot(readBin(con,"raw",2)==c(13,10)) #check
}
data.frame(secs,speeds)
close(con)

library(hexView)
tst <- readRaw("test.jpg",machine = "binary", human = "char")
tst
print(tst, machine="binary", showHuman = TRUE)
tst22 <- as.character(tst, machine="binary")
out <- lapply(tst22, function(x) substr(x, nchar(x)-13, nchar(x)))
out <- unlist(out)
out <- paste0(out, collapse = "")
intToUtf8(tst22, multiple = TRUE)
#tst33 <- atomicBlock
vectorBlock(block = tst22, length = 1)
atomicBlock(tst22[[1]],type="ASCIIchar")
blockValue(tst22$blocks$int2)
