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

##==============================================
##Create Plot
##==============================================

png(filename="plot4.png", width=480, height=480)
par(mfrow=c(2,2))
Sys.setlocale(category = "LC_ALL", locale = "english")

##Plot first graphic
with(consumnew, plot(datetime, Global_active_power, type="l", xlab="", ylab="Global Active Power"))

##Plot second graphic
with(consumnew, plot(datetime, Voltage, type="l", xlab="datetime", ylab="Voltage"))

##Plot third graphic
with(consumnew, plot(datetime, Sub_metering_1, xlab="", ylab="Energy sub metering", type="n"))
with(consumnew, lines(datetime, Sub_metering_1, col="black", type="l"))
with(consumnew, lines(datetime, Sub_metering_2, col="red", type="l"))
with(consumnew, lines(datetime, Sub_metering_3, col="blue", type="l"))
legend(x="topright", bty="n", lty=c(1,1,1), legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col=c("black", "red", "blue"))

##Plot fourth graphic
with(consumnew, plot(datetime, Global_reactive_power, type="l", xlab="datetime"))
dev.off()