#Synthetic Control Method for analysing EU membership and Balance of Payments records

rm(list = ls())
setwd("~/PUBL0055")

#install.packages("Synth") # Remember that you only need to install the package once
library(Synth)
library(dplyr)
library(ggplot2)

#The hope_emu.csv file contains data on these 16 countries across the years 1980 to 2010.
emu <- read.csv("hope_emu.csv", stringsAsFactors = FALSE)
str(emu)
summary(emu)

#Remove NAs
emu[, colSums(is.na(emu)) == 0]
sum(is.na(emu))
emu$invest[is.na(emu$invest)] <- mean(emu$invest, na.rm = TRUE)
emu$gov_debt[is.na(emu$gov_debt)] <- mean(emu$gov_debt, na.rm = TRUE)
emu$gov_deficit[is.na(emu$gov_deficit)] <- mean(emu$gov_deficit, na.rm = TRUE)
emu$credit[is.na(emu$credit)] <- mean(emu$credit, na.rm = TRUE)
sum(is.na(emu))

#Explatory Plots
ggplot(emu, aes(x = openness, y = invest))+
  geom_point()
ggplot(emu, aes(x = CAB, y = invest))+
  geom_point() 

#Current Account Balance
plot(x = emu[emu$country_ID == "ESP",]$period,
     y = emu[emu$country_ID == "ESP",]$CAB,
     type = "l",
     xlab = "Year",
     ylab = "Current Account Balance",
     col = "red",
     lwd = 3,
     frame.plot = FALSE, # Frame.plot tells R whether we want a box around our plot
     ylim = range(emu$CAB)) # Because we are plotting multiple lines, we need to manually set the y-axis limits (here I am just using the range of the entire data)
lines(x = emu[emu$country_ID == "USA",]$period,
      y = emu[emu$country_ID == "USA",]$CAB,
      col = "orange")
lines(x = emu[emu$country_ID == "GBR",]$period,
      y = emu[emu$country_ID == "GBR",]$CAB,
      col = "blue")
lines(x = emu[emu$country_ID == "JPN",]$period,
      y = emu[emu$country_ID == "JPN",]$CAB,
      col = "darkgreen")
abline(v = 1999, 
       lty = 3) # Lty specifies the line type (1 is solid, 2 dashed, 3 dotted, etc)
legend("topleft",
       legend = c("ESP","USA", "GBR", "JPN"),
       col = c("red", "orange", "blue", "darkgreen"),
       lty = 1,
       lwd = 2) #None of these individual countries is a perfect approximation to the pre-treatment trend for Spain, although the US and the UK lines are clearly closer than the Japanese line. The goal of the synthetic control analysis is to create a weighting scheme which, when applied to all countries in the donor pool, creates a closer match to the pre-intervention treated unit trend than any of the individual countries do alone.

#We need to prepare the data for synthetic control:
dataprep_out <- dataprep(foo = emu,
                         predictors = c("GDPPC_PPP","openness","demand","x_price","GDP_gr", 
                                        "invest", "gov_debt", "gov_deficit", "credit", "CAB"),
                         dependent = "CAB",
                         unit.variable = "country_no",
                         time.variable = "period",
                         treatment.identifier = 1, # 1 is spain
                         controls.identifier = c(2:16),
                         time.predictors.prior = c(1980:1998),
                         time.optimize.ssr = c(1980:1998),
                         unit.names.variable = "country_ID",
                         time.plot = 1980:2010
)
#Calling the synthetic control:
synth_out <- synth(dataprep_out)

#Plotting the synthetic control:
path.plot(synth.res = synth_out,
          dataprep.res = dataprep_out,
          Xlab = "Time",
          Ylab = "Current account balance",
          Legend = c("Spain", "Synthetic Spain"),
          Ylim = c(-10,5),
          tr.intake = 1999)

gaps.plot(synth.res = synth_out,
          dataprep.res = dataprep_out,
          Xlab = "Time",
          Ylab = "Current Account Balance Difference (Real - Synthetic Spain)",
          tr.intake = 1999) #The synthetic version of Spain provides a reasonably good approximation to the pre-treatment trend of Spain, as there are only small differences in the Current Account Balance between real Spain and synthetic Spain before 1999. 

#The country weights are stored in the folowing object
synth_out$solution.w

#Exclude Spanish observations
emu_australia <- emu[emu$country_ID != "ESP",]

#Prepare the data for Australia
dataprep_out_australia <- dataprep(foo = emu_australia,
                                   predictors = c("GDPPC_PPP","openness","demand","x_price","GDP_gr", 
                                                  "invest", "gov_debt", "gov_deficit", "credit", "CAB"),
                                   dependent = "CAB",
                                   unit.variable = "country_no",
                                   time.variable = "period",
                                   treatment.identifier = 2, # 2 is Australia
                                   controls.identifier = c(3:16), #Excluding Australia from the donor pool
                                   time.predictors.prior = c(1980:1998),
                                   time.optimize.ssr = c(1980:1998),
                                   unit.names.variable = "country_ID",
                                   time.plot = 1980:2010
)

#Estimate the new synthetic control
synth_out_australia <- synth(dataprep_out_australia)

#Plot the results
path.plot(synth.res = synth_out_australia,
          dataprep.res = dataprep_out_australia,
          Xlab = "Time",
          Ylab = "Current account balance",
          Legend = c("Australia", "Synthetic Australia"),
          Ylim = c(-10,5),
          tr.intake = 1999)  

#Comparison Spain vs Australia
#Define function for calculating the RMSE
rmse <- function(x,y){
  sqrt(mean((x - y)^2))
}

#Define vector for pre/post-intervention subsetting
pre_intervention <- c(1980:2010) < 1999

### Spain
#Extract the weights for synthetic spain
spain_weights <- synth_out$solution.w

#Calculate the outcome for synthetic spain using matrix multiplication
synthetic_spain <- as.numeric(dataprep_out$Y0plot %*% spain_weights)

#Extract the true outcome for spain
true_spain <- emu[emu$country_ID == "ESP",]$CAB

#Calculate the RMSE for the pre-intervention period for spain
pre_rmse_spain <- rmse(x = true_spain[pre_intervention], y = synthetic_spain[pre_intervention])

#Calculate the RMSE for the post-intervention period for spain
post_rmse_spain <- rmse(x = true_spain[!pre_intervention], y = synthetic_spain[!pre_intervention])
post_rmse_spain/pre_rmse_spain 

###Australia
#Extract the weights for synthetic Australia
australia_weights <- synth_out_australia$solution.w

#Calculate the outcome for synthetic Australia using matrix multiplication
synthetic_australia <- as.numeric(dataprep_out_australia$Y0plot %*% australia_weights)

#Extract the true outcome for Australia
true_australia <- emu_australia[emu_australia$country_ID == "AUS",]$CAB

#Calculate the RMSE for the pre-intervention period for Australia
pre_rmse_australia <- rmse(x = true_australia[pre_intervention], y = synthetic_australia[pre_intervention])

#Calculate the RMSE for the post-intervention period for Australia
post_rmse_australia <- rmse(x = true_australia[!pre_intervention], y = synthetic_australia[!pre_intervention])
post_rmse_australia/pre_rmse_australia