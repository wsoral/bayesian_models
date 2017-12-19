## lab 11 - linear regression with multiple predictors

## load package foreign to get data straight from the website
library(foreign)

## download and read data on crime rate in United States 
## (working internet connection required)
cdata <- read.dta("https://stats.idre.ucla.edu/stat/data/crime.dta")


## installing and loading package for 3D plotting
install.packages('plot3D')
library(plot3D)

## we want to create a scatterplot of points in 3 dimensions
scatter3D(cdata$poverty, cdata$pctmetro, cdata$crime, theta=45, phi=10,
          xlab='poverty',ylab='pctmetro',zlab='crime')

## we want to find a (hyper)plane that will describe the cloud o points
pct <- seq(24,100,length.out = 10)
pov <- seq(8,26.4,length.out = 10)
M <- mesh(pov, pct)
z <- -915.273+52.386*M$x + 11.591*M$y
surf3D(M$x,M$y, z,add = T)

## 3D plots require a lot of effort, with often mixed effects
## they are useless with more than 2 predictors
## we usually work with projections on 2D 
## load ggplot2 for plots
library(ggplot2)

## plot the data on poverty rates, percent of metro area and crime
## with added (frequentist) regression lines
qplot(poverty, crime, data= cdata, geom=c('point','smooth'), method='lm')
qplot(pctmetro, crime, data= cdata, geom=c('point','smooth'), method='lm')

## load rjags
library(rjags)


## model code
## notice that this is almost exactly the same code as with simple linear regression
mod_code <- "
data {
  # here we are standardizing our values
  Ntotal <- length(y)
  ym <- mean(y)
  ysd <- sd(y)
  for (i in 1:length(y)) {
    zy[i] <- (y[i] - ym) / ysd
  }
  for (j in 1:Nx){
    xm[j] <- mean(x[,j])
    xsd[j] <- mean(x[,j])
    for (i in 1:length(y)){
      zx[i,j] <- (x[i,j] - xm[j]) / xsd[j]
    }
  }
}
model {
  for (i in 1:Ntotal){
    zy[i] ~ dt( mu[i], 1/zsigma^2, nu )
    mu[i] <- zbeta0 + sum( zbeta[1:Nx] * zx[i, 1:Nx] )
} 
  # Priors on standardized scale
  zbeta0 ~ dnorm( 0, 1/2^2 )
  for (j in 1:Nx){
    zbeta[j] ~ dnorm( 0, 1/2^2 )
  }
  zsigma ~ dunif( 1.0e-5, 1.0e+1 )
  nu <- nuMinusOne + 1
  nuMinusOne ~ dexp( 1/29.0 )
  # Here we move back to unstandardized values for the parameters
  beta[1:Nx] <- ( zbeta[1:Nx] / xsd[1:Nx] ) * ysd
  beta0 <- zbeta0 * ysd + ym - sum( zbeta[1:Nx] * xm[1:Nx] / xsd[1:Nx] )*ysd
  sigma <- zsigma * ysd
}
"

## We generate rjags data file
predictors <- cbind(cdata$poverty, cdata$pctmetro)
jags.data <- list(y = cdata$crime, x = predictors, Nx = ncol(predictors))

## We initialize our model
model <- jags.model(textConnection(mod_code), data=jags.data, n.chains = 4)

## We are updating our model
update(model, 1000)

## We draw posterior samples (only unstandardized values)
post <- coda.samples(model, c('beta0','beta','sigma'),
                     n.iter = 10000)

## Basic diagnostics
gelman.diag(post, multivariate = F)
effectiveSize(post)

## Model summary
summary(post)


## Plotting our predictions
## We merge chains
posterior <- do.call(rbind, post)

## We compute mean values for beta0, beta1, and beta2
mbeta0 = mean(posterior[,'beta0'])
mbeta1 = mean(posterior[,'beta[1]'])
mbeta2 = mean(posterior[,'beta[2]'])

## We collect the values to the data frame (for plotting)
means <- data.frame(beta0=mbeta0, beta1=mbeta1, beta2=mbeta2)

## We draw random sample of 20 lines from posterior
## we set random index
idx <- sample(1:nrow(posterior), 20, replace = F)
random_lines <- as.data.frame(posterior[idx, c('beta0', 'beta[1]','beta[2]')])
names(random_lines) <- c('beta0','beta1','beta2')

## we draw observed values, expected int and slope , and random draws (ints and slopes)
mPctMet <- mean(cdata$pctmetro)
hPctMet <- mean(cdata$pctmetro)+sd(cdata$pctmetro)
lPctMet <- mean(cdata$pctmetro)-sd(cdata$pctmetro)

## with only a single predictor (poverty), the predictive uncertainty is high
qplot(poverty, crime, data= cdata)+
  geom_abline(aes(intercept=beta0+(beta2*mPctMet), slope=beta1), data=random_lines, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*mPctMet), slope=beta1), data=means, size=0.5, col='red')

## adding additional predictor (pctmetro), decreases predictive uncertainty
## green line fits regression for states with high perc. of metro. area
## read line fits regression for states with mean perc. of metro. area
## blue line fits regression for states with low perc. of metro. area

qplot(poverty, crime, data= cdata)+
  geom_abline(aes(intercept=beta0+(beta2*mPctMet), slope=beta1), data=random_lines, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*lPctMet), slope=beta1), data=random_lines, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*hPctMet), slope=beta1), data=random_lines, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*mPctMet), slope=beta1), data=means, size=0.5, col='red')+
  geom_abline(aes(intercept=beta0+(beta2*hPctMet), slope=beta1), data=means, size=0.5, col='green')+
  geom_abline(aes(intercept=beta0+(beta2*lPctMet), slope=beta1), data=means, size=0.5, col='blue')



## Models with interactions

## All we need to do is to add 3 predictor: poverty * pctmetro
predictors <- cbind(cdata$poverty, cdata$pctmetro, cdata$poverty*cdata$pctmetro)
jags.data <- list(y = cdata$crime, x = predictors, Nx = ncol(predictors))

model_int <- jags.model(textConnection(mod_code), data=jags.data, n.chains = 4)

## We are updating our model
update(model_int, 1000)

## We draw posterior samples
post_int <- coda.samples(model_int, c('beta0','beta','sigma','nu'),
                         n.iter = 10000)

## Diagnostics
gelman.diag(post_int, multivariate = F)
effectiveSize(post_int)


## Summary
summary(post_int)

## Once again we plot our predictions
## We merge chains
posterior_int <- do.call(rbind, post_int)

## We compute mean values for beta0 and beta1
## The same as with summary(), here for plotting
mbeta0i = mean(posterior_int[,'beta0'])
mbeta1i = mean(posterior_int[,'beta[1]'])
mbeta2i = mean(posterior_int[,'beta[2]'])
mbeta3i = mean(posterior_int[,'beta[3]'])

## We collect the values to the data frame (for plotting)
means_int <- data.frame(beta0=mbeta0i, beta1=mbeta1i, beta2=mbeta2i,
                        beta3=mbeta3i)

## We draw random sample of 20 lines from posterior
## we set random index
idxi <- sample(1:nrow(posterior_int), 20, replace = F)
random_linesi <- as.data.frame(posterior_int[idxi, c('beta0', 'beta[1]','beta[2]','beta[3]')])
names(random_linesi) <- c('beta0','beta1','beta2','beta3')

## plot with interaction
## green line fits regression for states with high perc. of metro. area
## read line fits regression for states with mean perc. of metro. area
## blue line fits regression for states with low perc. of metro. area
qplot(poverty, crime, data= cdata)+
  geom_abline(aes(intercept=beta0+(beta2*mPctMet), slope=beta1+(beta3*mPctMet)), data=random_linesi, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*lPctMet), slope=beta1+(beta3*lPctMet)), data=random_linesi, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*hPctMet), slope=beta1+(beta3*hPctMet)), data=random_linesi, size=0.2, col='grey')+
  geom_abline(aes(intercept=beta0+(beta2*mPctMet), slope=beta1+(beta3*mPctMet)), data=means_int, size=0.5, col='red')+
  geom_abline(aes(intercept=beta0+(beta2*hPctMet), slope=beta1+(beta3*lPctMet)), data=means_int, size=0.5, col='green')+
  geom_abline(aes(intercept=beta0+(beta2*lPctMet), slope=beta1+(beta3*hPctMet)), data=means_int, size=0.5, col='blue')


## to test separate slopes for different levels of pctmetro
## we use this short line of code
## it assumes that you have run the code above
## in lines 102, 103, 104, and 151, 
beta1 <- posterior_int[,'beta[1]']
beta3 <- posterior_int[,'beta[3]']

lowSlope <- beta1 + beta3*lPctMet
meanSlope <- beta1 + beta3*mPctMet
highSlope <- beta1 + beta3*hPctMet
simpleSlopes <- as.mcmc(cbind(lowSlope,meanSlope,highSlope))

summary(simpleSlopes)




