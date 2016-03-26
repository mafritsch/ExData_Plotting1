library(dplyr)
library(lubridate)
filename <- "dataset.zip"
fileurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"

##==========================================
##Read file and manipulate columns
##==========================================

##Check that file does not exist, download the file
if (!file.exists(filename)){
    download.file(fileurl, destfile=".\\dataset.zip", method="curl")
}

##When not yet extracted, extract Zip-file
if(!file.exists(".\\data")) {
    unzip(filename, exdir = ".\\data") 
}

##Read file in data
consumdata <- read.table(".\\data\\household_power_consumption.txt", stringsAsFactors=FALSE, header=TRUE, sep=";", na.strings="?")

consumtbl <- tbl_df(consumdata)
consumtbl$Date <- as.Date(consumtbl$Date, format="%d/%m/%Y")

##Only take measurements from 01/02/2007 and 02/02/2007
consumfiltered <- filter(consumtbl, Date == as.Date("2007-02-01") | Date == as.Date("2007-02-02"))
consumfiltered$Time <- as.POSIXct(strptime(consumfiltered$Time, format="%H:%M:%S"))

##Combine date and time in one column
year(consumfiltered$Time) <- year(consumfiltered$Date)
month(consumfiltered$Time) <- month(consumfiltered$Date)
day(consumfiltered$Time) <- day(consumfiltered$Date)

##Remove old Time and Date columns and move datetime to beginning
consumnew <- mutate(consumfiltered, datetime = Time )
consumnew <- select(consumnew, datetime, Global_active_power:Sub_metering_3)

##====================================================================
##Create Plot
##====================================================================
png(filename="plot1.png", width=480, height=480)
hist(consumnew$Global_active_power, col="red", main="Global Active Power", xlab="Global Active Power (kilowatts)")
dev.off()