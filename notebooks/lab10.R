## lab 10 - simple linear regression

## load package foreign to get data straight from the website
library(foreign)

## download and read data on crime rate in United States 
## (working internet connection required)
cdata <- read.dta("https://stats.idre.ucla.edu/stat/data/crime.dta")

## load ggplot2 for plots
library(ggplot2)

## plot the data on poverty rates and crime
## with added (frequentist) regression line
qplot(poverty, crime, data= cdata, geom=c('point','smooth'), method='lm')

## load rjags
library(rjags)


## model code
## note that we've added additional block 'data' where we standardize our variables
## standardizing variables is additionally necessery with JAGS
## due to large correlation between slope and intercept model with
## raw variables has poor convergence rate
mod_code <- "
data {
  # here we are standardizing our values
  Ntotal <- length(y)
  xm <- mean(x)
  ym <- mean(y)
  xsd <- sd(x)
  ysd <- sd(y)
  for (i in 1:length(y)) {
    zx[i] <- (x[i] - xm) / xsd
    zy[i] <- (y[i] - ym) / ysd
  }
}
model {
  for (i in 1:Ntotal){
    zy[i] ~ dnorm( mu[i], 1/zsigma^2 )
    mu[i] <- zbeta0 + zbeta1*zx[i]
  }
  # Priors on standardized scale
  zbeta0 ~ dnorm( 0, 1/10^2 )
  zbeta1 ~ dnorm( 0, 1/10^2 )
  zsigma ~ dunif( 1.0e-3, 1.0e+3 )
  # Here we move back to unstandardized values for the parameters
  beta1 <- zbeta1 * ysd / xsd
  beta0 <- zbeta0 * ysd + ym - zbeta1 * xm * ysd / xsd
  sigma <- zsigma * ysd
}
"

## We generate rjags data file
jags.data <- list(y = cdata$crime, x = cdata$poverty)

## We initialize our model
model <- jags.model(textConnection(mod_code), data=jags.data, n.chains = 4)

## We are updating our model
update(model, 1000)

## We draw posterior samples
post <- coda.samples(model, c('beta0','beta1','sigma','zbeta0','zbeta1','zsigma'),
                     n.iter = 10000)

## Basic diagnostics
gelman.diag(post, multivariate = F)
effectiveSize(post)

## Model summary
summary(post)

## Plot posterior distributions with bayesplot
library(bayesplot)
## for intercept
mcmc_areas(post, pars=c('beta0'), prob = 0.95)
## for slope
mcmc_areas(post, pars=c('beta1'), prob = 0.95)
## for residual error
mcmc_areas(post, pars=c('sigma'), prob = 0.95)

## We merge chains
posterior <- do.call(rbind, post)

## We compute mean values for beta0 and beta1
## The same as with summary(), here for plotting
mbeta0 = mean(posterior[,'beta0'])
mbeta1 = mean(posterior[,'beta1'])

## We collect the values to the data frame (for plotting)
means <- data.frame(beta0=mbeta0, beta1=mbeta1)

## We draw random sample of 20 lines from posterior
## we set random index
idx <- sample(1:nrow(posterior), 20, replace = F)
random_lines <- as.data.frame(posterior[idx, c('beta0', 'beta1')])

## we draw observed values, expected int and slope , and random draws (ints and slopes)
qplot(poverty, crime, data= cdata)+
  geom_abline(aes(intercept=beta0, slope=beta1), data=random_lines, size=0.5, col='grey')+
  geom_abline(aes(intercept=beta0, slope=beta1), data=means, size=2, col='red')

## Notice, although red line (average int and slope) seemed to worked well, 
## grey lines (random ints and slopes) seemed to vary largely
## This indicates huge uncertainty about our estimates


# Lets try robust approach

mod_code_rob <- "
data {
  # here we are standardizing our values
  Ntotal <- length(y)
  xm <- mean(x)
  ym <- mean(y)
  xsd <- sd(x)
  ysd <- sd(y)
  for (i in 1:length(y)) {
    zx[i] <- (x[i] - xm) / xsd
    zy[i] <- (y[i] - ym) / ysd
  }
}
model {
  for (i in 1:Ntotal){
    zy[i] ~ dt( mu[i], 1/zsigma^2, nu )
    mu[i] <- zbeta0 + zbeta1*zx[i]
  }
  # Priors on standardized scale
  zbeta0 ~ dnorm( 0, 1/10^2 )
  zbeta1 ~ dnorm( 0, 1/10^2 )
  zsigma ~ dunif( 1.0e-3, 1.0e+3 )
  # Prior on normality parameter
  nu <- nuMinusOne + 1
  nuMinusOne ~ dexp(1/29.0)
  # Here we move back to unstandardized values for the parameters
  beta1 <- zbeta1 * ysd / xsd
  beta0 <- zbeta0 * ysd + ym - zbeta1 * xm * ysd / xsd
  sigma <- zsigma * ysd
}
"

model_rob <- jags.model(textConnection(mod_code_rob), data=jags.data, n.chains = 4)

## We are updating our model
update(model_rob, 1000)

## We draw posterior samples
post_rob <- coda.samples(model_rob, c('beta0','beta1','sigma','zbeta0','zbeta1','zsigma','nu'),
                     n.iter = 10000)

## Diagnostics
gelman.diag(post_rob, multivariate = F)
effectiveSize(post_rob)


## Summary
summary(post_rob)

## Once again we plot our predictions
## We merge chains
posterior_rob <- do.call(rbind, post_rob)

## We compute mean values for beta0 and beta1
## The same as with summary(), here for plotting
mbeta0r = mean(posterior_rob[,'beta0'])
mbeta1r = mean(posterior_rob[,'beta1'])

## We collect the values to the data frame (for plotting)
meansr <- data.frame(beta0=mbeta0r, beta1=mbeta1r)

## We draw random sample of 20 lines from posterior
## we set random index
idxr <- sample(1:nrow(posterior_rob), 20, replace = F)
random_linesr <- as.data.frame(posterior_rob[idxr, c('beta0', 'beta1')])

## we draw observed values, expected int and slope , and random draws (ints and slopes)
qplot(poverty, crime, data= cdata)+
  geom_abline(aes(intercept=beta0, slope=beta1), data=random_linesr, size=0.5, col='grey')+
  geom_abline(aes(intercept=beta0, slope=beta1), data=meansr, size=2, col='red')

## Now our estimate is more credible and robust against the outliers
