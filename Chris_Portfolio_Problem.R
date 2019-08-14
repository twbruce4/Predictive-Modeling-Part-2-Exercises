library(mosaic)
library(quantmod) # quantitstive models
library(foreach) # for more sophosticated loops for loops with return values.




#Long-Short EFTs
################################################################################

#### Now use a bootstrap approach
#### With more efts

myefts = c("CSM", "QAI", "HDG") # Long-Short EFTs

myprices = getSymbols(myefts, from = "2014-08-07")


# A chunk of code for adjusting all efts
# creates a new object adding 'a' to the end
# For example, WMT becomes WMTa, etc
for(ticker in myefts) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}

head(CSMa)

# Combine all the returns in a matrix long - Short
all_returns = cbind(	ClCl(CSMa),
                     ClCl(QAIa),
                     ClCl(HDGa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

# Compute the returns from the closing prices
pairs(all_returns)

set.seed(47)
# Now loop over two trading weeks
total_wealth = 100000
weights = c(0.3,0.4,0.3)
holdings = weights * total_wealth
n_days = 20
wealthtracker = rep(0, n_days) # Set up a placeholder to track total wealth
for(today in 1:n_days) {
  return.today = resample(all_returns, 1, orig.ids=FALSE)
  holdings = holdings + holdings*return.today
  total_wealth = sum(holdings)
  wealthtracker[today] = total_wealth
  weights = c(0.3,0.4,0.3)
  holdings = weights * total_wealth
}
total_wealth
plot(wealthtracker, type='l')

initial_wealth = 100000
sim1 = foreach(i=1:5000, .combine='rbind') %do% {
  total_wealth = initial_wealth
  weights = c(0.3,0.4,0.3)
  holdings = weights * total_wealth
  n_days = 20
  wealthtracker = rep(0, n_days)
  for(today in 1:n_days) {
    return.today = resample(all_returns, 1, orig.ids=FALSE)
    holdings = holdings + holdings*return.today
    total_wealth = sum(holdings)
    wealthtracker[today] = total_wealth
    weights = c(0.3,0.4,0.3)
    holdings = weights * total_wealth
  }
  wealthtracker
}

# Profit/loss
mean(sim1[,n_days])
hist(sim1[,n_days]- initial_wealth, breaks=30)

quantile(sim1[,n_days]- initial_wealth, 0.05)


# End of Long-Short EFTs
################################################################################


#Emerging Markets EFTs
################################################################################


myefts = c("RSX", "FM", "ERUS", "GREK", "PIE") # Emerging Markets
myprices = getSymbols(myefts, from = "2014-08-07")

for(ticker in myefts) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}

all_returns = cbind(	ClCl(RSXa),
                     ClCl(FMa),
                     ClCl(ERUSa),
                     ClCl(GREKa),
                     ClCl(PIEa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

set.seed(55)
# Now loop over two trading weeks
total_wealth = 100000
weights = c(0.2,0.3,0.2,0.2,0.1)
holdings = weights * total_wealth
n_days = 20
wealthtracker = rep(0, n_days) # Set up a placeholder to track total wealth
for(today in 1:n_days) {
  return.today = resample(all_returns, 1, orig.ids=FALSE)
  holdings = holdings + holdings*return.today
  total_wealth = sum(holdings)
  wealthtracker[today] = total_wealth
  #weights = c(0.2,0.3,0.2,0.2,0.1)
  #holdings = weights * total_wealth
}
total_wealth
plot(wealthtracker, type='l')

initial_wealth = 100000
sim1 = foreach(i=1:5000, .combine='rbind') %do% {
  total_wealth = initial_wealth
  weights = c(0.2,0.3,0.2,0.2,0.1)
  holdings = weights * total_wealth
  n_days = 20
  wealthtracker = rep(0, n_days)
  for(today in 1:n_days) {
    return.today = resample(all_returns, 1, orig.ids=FALSE)
    holdings = holdings + holdings*return.today
    total_wealth = sum(holdings)
    wealthtracker[today] = total_wealth
    weights = c(0.2,0.3,0.2,0.2,0.1)
    holdings = weights * total_wealth
  }
  wealthtracker
}

# Profit/loss
mean(sim1[,n_days])
hist(sim1[,n_days]- initial_wealth, breaks=30)

quantile(sim1[,n_days]- initial_wealth, 0.05)

#End of Emerging Markets EFTs
################################################################################

#Diversifying EFTs
################################################################################

myefts = c("MDIV", "YYY", "AOM", "AOA", "GAL", "GCE") # Diversifying
myprices = getSymbols(myefts, from = "2014-08-07")


for(ticker in myefts) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}
all_returns = cbind(	ClCl(MDIVa),
                     ClCl(YYYa),
                     ClCl(AOMa),
                     ClCl(AOAa),
                     ClCl(GALa),
                     ClCl(GCEa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

set.seed(60)
# Now loop over two trading weeks
total_wealth = 100000
weights = c(0.2,0.2,0.1,0.2,0.2,0.1)
holdings = weights * total_wealth
n_days = 20
wealthtracker = rep(0, n_days) # Set up a placeholder to track total wealth
for(today in 1:n_days) {
  return.today = resample(all_returns, 1, orig.ids=FALSE)
  holdings = holdings + holdings*return.today
  total_wealth = sum(holdings)
  wealthtracker[today] = total_wealth
  weights = c(0.2,0.2,0.1,0.2,0.2,0.1)
  holdings = weights * total_wealth
}
total_wealth
plot(wealthtracker, type='l')

initial_wealth = 100000
sim1 = foreach(i=1:5000, .combine='rbind') %do% {
  total_wealth = initial_wealth
  weights = c(0.2, 0.2, 0.1, 0.2, 0.2, 0.1)
  holdings = weights * total_wealth
  n_days = 20
  wealthtracker = rep(0, n_days)
  for(today in 1:n_days) {
    return.today = resample(all_returns, 1, orig.ids=FALSE)
    holdings = holdings + holdings*return.today
    total_wealth = sum(holdings)
    wealthtracker[today] = total_wealth
    weights = c(0.2, 0.2, 0.1, 0.2, 0.2, 0.1)
    holdings = weights * total_wealth
  }
  wealthtracker
}

head(sim1)
hist(sim1[,n_days], 25)

# Profit/loss
mean(sim1[,n_days])
hist(sim1[,n_days]- initial_wealth, breaks=30)

quantile(sim1[,n_days]- initial_wealth, 0.05)

# End of Diversifying EFTs
################################################################################
