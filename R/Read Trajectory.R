"*********************************************************
GEOM90007 Spatial Visualistion
A3 Data Preprocessing
744870 Fumi Wu
Description: Using R to read trajectory data from plt file
             and integrate them with transport mode data 
             then export into csv for processing to use.
**********************************************************"

allposition <- NULL ##store all the trajectory data

nouser <- NULL
uc <- array(NA, dim = c(100000,6))
an <- 1 ##number of trajectory

"*********************************************************
Description: List all the trajectory with transport mode,
             using in trajectory sampling
Output:      csv file with six colomns, which is unique
             ID of trajectory, start day, start time, end
             day, end time, transport mode
*********************************************************"
for (j  in 0:182)
{
  ##find the users with transport mode record
  ff <- list.files(path= sprintf("Data/Geolife Trajectories 1.3/Data/%03d", j), full.names=TRUE) 
  if (length(ff) == 2)
  {
    nouser = rbind(nouser,j)
    ##read file of the trajectory with transport mode in txt
    att <- read.table(sprintf("Data/Geolife Trajectories 1.3/Data/%03d/labels.txt", j), header = FALSE, quote = "\"", skip = 1, sep = "",stringsAsFactors=FALSE)
    for (ii in 1:nrow(att))
    {
      times <- NULL
      timee <- NULL
      fftime <- NULL
      uc[an,1] <- paste(sprintf("%03d",j),as.character(sprintf("%04d", ii)),sep = "") ##create a unique code of each trajectory
      
      ##Time transformation, from London timezone to Beijing timezone
      times <- format(as.POSIXct(paste(att[ii,1],att[ii,2]), tz="Europe/London"), tz="Asia/Shanghai",usetz=TRUE) ##trajectory start time
      fftime <- do.call(rbind, strsplit(times," "))
      uc[an,2] <- format(as.Date(fftime[1,1], "%Y-%m-%d"), "%u") #get the days of dates
      if (fftime[1,2] != "CST")
      {
        uc[an,3] <- fftime[1,2]
      }
      else
      {
        uc[an,3] <- "00:00:00"
      }
 
      fftime <- NULL
      timee <- format(as.POSIXct(paste(att[ii,3],att[ii,4]), tz="Europe/London"), tz="Asia/Shanghai",usetz=TRUE) ##trajectory end time
      fftime <- do.call(rbind, strsplit(timee," "))
      uc[an,4] <- format(as.Date(fftime[1,1], "%Y-%m-%d"), "%u")
      if (fftime[1,2] != "CST")
      {
        uc[an,5] <- fftime[1,2]
      }
      else
      {
        uc[an,5] <- "00:00:00"
      }
      uc[an,6] <- att[ii,5] ##add transport mode
      an = an+1
    }
  }
}
an = an-1
colnames <- c("id","Sday","Stime","Eday", "Etime","transport")
uc <- rbind(colnames, uc[1:an,1:6])
write.csv(uc, file = "unicode.csv", row.names = FALSE)

"*********************************************************
Description: List all the position during trajectory with 
             transport mode
Output:      csv file with five colomns, which is unique
             ID of trajectory, longtitude, latitude, day,
             time
*********************************************************"
##read the list of trajectories with transport mode
csample <- as.matrix(read.table("unicode.csv", skip =2, header = FALSE, quote = "\"", sep = ",",stringsAsFactors=FALSE))

for (jj in 1:length(nouser)) #for each user with transport mode labels
{
  un <- as.numeric(nouser[jj]) ##user ID
  print(un)
  c1 <- NULL ##store all the trajectory of one user
 
  ##read all the positions of this user from plt file
  ff <- list.files(path= sprintf("Data/Geolife Trajectories 1.3/Data/%03d/Trajectory", un), full.names=TRUE)
  for(i in 1:length(ff)) #
  {
    b <- read.table(ff[i], header = FALSE, quote = "\"", skip = 6, sep = ",",stringsAsFactors=FALSE, colClasses=c(NA,NA,"NULL","NULL","NULL",NA,NA))
    c1 <- rbind(c1,b,deparse.level = 0)
  }
  c1 <- as.matrix(c1)
  
  #read the transport labels of this user from txt file
  at <- read.table(sprintf("D:/2016Semester2/Spatial visualisation/Assignment/A3/Geolife Trajectories 1.3/Data/%03d/labels.txt", un), header = FALSE, quote = "\"", skip = 1, sep = "",stringsAsFactors=FALSE)
  rn <- array(0,dim = c(nrow(at),1))
  for (i in 1:nrow(at))
  {
    ii <- sprintf("%04d", i)
    rn[i][1] <- paste(sprintf("%03d",un),as.character(ii),sep = "")
  }
  at <- as.matrix(cbind(rn,at))
  
  ##time from plt file
  timet1 <- array(NA,dim = c(nrow(c1),1))
  for (t1 in 1:nrow(c1))
  {
    timet1[t1,1] <- paste(c1[t1,3],c1[t1,4])
    timet1[t1,1] <- gsub("-", "/", timet1[t1,1], useBytes = TRUE)
  }
  
  ##start time from txt file
  timet2 <- array(NA,dim = c(nrow(at),1))
  for (t2 in 1:nrow(at))
  {
    timet2[t2,1] <- paste(at[t2,2],at[t2,3])
  }
  
  ##end time from txt file
  timet3 <- array(NA,dim = c(nrow(at),1))
  for (t3 in 1:nrow(at))
  {
    timet3[t3,1] <- paste(at[t3,4],at[t3,5])
  }

  rnn <- array(0,dim = c(nrow(c1),1))
  ttmode <- array(0,dim = c(nrow(c1),1))
  cc1 <- array(0,dim = c(nrow(c1),2))
  ftime <-  array(0, dim = c(nrow(c1),2))

  ncc1 <- 1

  ## match the the time from plt file with that from txt file, to find out all the positions of one trajectory with transport mode
  ##only keep the position with transport mode
  for (bb in 1:nrow(at)) ##for all the trajectory with transport labels
  {
    ##if trajectory ID from txt file is matched with ID from plt file
    if (as.numeric(at[bb,1]) %in% as.numeric(csample[,1])) 
    {
      #if the time from plt file within the time from txt file, which means this position has transport labels
      if (timet2[bb,1] %in% timet1)
      {
        nor <- NULL
        nrr <- NULL
        nor <- which(grepl(timet2[bb,1], timet1)) ##get the line of start point matched trajectory
        ncc2 <- ncc1
        ptime <- as.POSIXct(timet1[1,1], "%Y/%m/%d %H:%M:%S", tz="Europe/London")
        for (nrr in nor:nrow(c1))
        {
          ##only keep the point within study area
          if ((c1[nrr,1]>39.7420 && c1[nrr,1]<40.0702) && (c1[nrr,2]>116.0431 && c1[nrr,2]<116.7393)) 
          {
            ##only keep the positions every 20 seconds to reduce the data size
            tinterval <- as.numeric(difftime(strptime(timet1[nrr,1],"%Y/%m/%d %H:%M:%S"), ptime), unit = "secs") 
            if (tinterval > 20)
            {
              ##if the time of positon is at the start time or before end time of a trajectory, the position will be recorded
              if (timet1[nrr,1] == timet2[bb,1] || timet1[nrr,1] == timet3[bb,1])
              {
                rnn[ncc1,1] <- at[bb,1] 
                cc1 [ncc1,1] <- c1[nrr,1]
                cc1 [ncc1,2] <- c1[nrr,2]
                timec <- format(as.POSIXct(timet1[nrr,1], tz="Europe/London"), tz="Asia/Shanghai",usetz=TRUE)
                fftime <- do.call(rbind, strsplit(timec," "))
                ftime[ncc1,1] <- format(as.Date(fftime[1,1], "%Y-%m-%d"), "%u")
                ftime[ncc1,2] <- fftime[1,2]
                ptime <- timet1[nrr,1]
                ncc1 = ncc1 + 1
              }
              else if (timet1[nrr,1] > timet2[bb,1] && timet1[nrr,1] < timet3[bb,1])
              {
                rnn[ncc1,1] <- at[bb,1]
                cc1 [ncc1,1] <- c1[nrr,1]
                cc1 [ncc1,2] <- c1[nrr,2]
                timec <- format(as.POSIXct(timet1[nrr,1], tz="Europe/London"), tz="Asia/Shanghai",usetz=TRUE)
                fftime <- do.call(rbind, strsplit(timec," "))
                ftime[ncc1,1] <- format(as.Date(fftime[1,1], "%Y-%m-%d"), "%u")
                ftime[ncc1,2] <- fftime[1,2]
                ptime <- timet1[nrr,1]
                ncc1 = ncc1 + 1
              }
              else
              {
                break
              }
            }
          }
        }
        ##if the positions of one trajectory is less than 10 points, considering this trajectory is too short, it won't be recorded
        if ((nrr-nor)< 10)
        {
          ncc1 = ncc2
        }
      }
    }
  }
  
  ##if this user has position recorded, combine it into the whole record table
  if (ncc1 > 1)
  { 
    cc2 <- as.matrix(cbind(rnn[1:(ncc1-1),1], cc1[1:(ncc1-1),], ftime[1:(ncc1-1),], deparse.level = 0)) #, ttmode[1:(ncc1-1),]
    allposition <- rbind(allposition, cc2[,])
  }
}
 
	colnames <- c("id","latitude","longtitude","days", "time")
  allposition <- as.matrix(rbind(colnames,allposition))
  write.csv(allposition, file = "All.csv", row.names = FALSE)
  ccd <- as.matrix(read.table("All.csv", header = FALSE, quote = "\"", skip = 2, sep = ",",stringsAsFactors=FALSE, col.names = colnames)) 
  write.csv(ccd, file = "All.csv", row.names = FALSE)

"*********************************************************
Excel was used in sampling, and gain two csv files.
unicode_WK.csv recorded the sampled trajectories in weekend
unicode_WD.csv recorded the sampled trajectories in weekday
they have the same number of trajectories
*********************************************************"

"*********************************************************
Description: Get the positions of sampled trajectories
             Using to create geojson file for interface
Output:      csv file with six colomns, which is unique
             ID of trajectory, longtitude, latitude, day,
             time, transport mode
*********************************************************"
colnames <- c("id","latitude","longtitude","days", "time","transport")
file1 <- as.matrix(read.table("All.csv", header = FALSE, quote = "\"", skip = 1, sep = ",",stringsAsFactors=FALSE)) 

##Weekend
file2 <- as.matrix(read.table("unicode_WK.csv", header = FALSE, quote = "\"", skip = 2, sep = ",",stringsAsFactors=FALSE)) 
  
tmode <- array(NA, dim = c(nrow(file1),1))
tsecs <- array(NA, dim = c(nrow(file1),1))
  
for (i in 1:nrow(file1))
{
  if (as.numeric(file1[i,1]) %in% as.numeric(file2[,1])) ##match sampled trajectory ID with all trajectory ID
  {
    fftime <- do.call(rbind, strsplit(file1[i,5],":"))
    ftime = as.numeric(fftime[1,1])*3600+as.numeric(fftime[1,2])*60+as.numeric(fftime[1,3])
    nor <- which(grepl(file1[i,1], file2[,1]))
    tmode[i,1] = file2[nor,6]
    tsecs[i,1] = ftime
   }
}
  
fileall <- NULL
fileall <- cbind(file1[,1:4], tsecs, tmode)
fileall <- rbind(colnames,fileall)
write.csv(fileall, file = "Weekend.csv", row.names = FALSE)

##Weekday
file2 <- as.matrix(read.table("unicode_WD.csv", header = FALSE, quote = "\"", skip = 2, sep = ",",stringsAsFactors=FALSE)) 

tmode <- array(NA, dim = c(nrow(file1),1))
tsecs <- array(NA, dim = c(nrow(file1),1))

for (i in 1:nrow(file1))
{
  if (as.numeric(file1[i,1]) %in% as.numeric(file2[,1])) ##match sampled trajectory ID with all trajectory ID
  {
    fftime <- do.call(rbind, strsplit(file1[i,5],":"))
    ftime = as.numeric(fftime[1,1])*3600+as.numeric(fftime[1,2])*60+as.numeric(fftime[1,3])
    nor <- which(grepl(file1[i,1], file2[,1]))
    tmode[i,1] = file2[nor,6]
    tsecs[i,1] = ftime
  }
}

fileall <- NULL
fileall <- cbind(file1[,1:4], tsecs, tmode)
fileall <- rbind(colnames,fileall)
write.csv(fileall, file = "Weekday.csv", row.names = FALSE)

"*********************************************************
QGIS was used create geojson files from csv files
Finally got Weekend.geojson and Weekday.geojson
*********************************************************"