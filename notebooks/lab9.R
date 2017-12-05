## lab 9 - Bayes Factor

# install and load package Bayes Factor
install.packages('BayesFactor')
library(BayesFactor)

# load dataset power.csv - use readr package
library(readr)
power <- read_csv("power.csv")

# save the dataset as dataframe (by default it is saved as tibble, but this does not work with BayesFactor)
power <- as.data.frame(power)

# save cond as factor - it will help with analyses
power$cond <- as.factor(power$cond)

# check order of the levels witin cond factor
levels(power$cond) # baseline is 1; powerlessness is 2


# load ggplot2 - for graphics
library(ggplot2)
# look at the boxplots
qplot(cond, jc_mean, data=power, geom='boxplot') 
# it seems like feelings of powerlessness resulted in increased belief in Jewish conspiracy

# check difference by using classical approach
t.test(jc_mean ~ cond, data=power)


# now try Bayes factor to check for the difference of group means
ttestBF(formula=jc_mean ~ cond, data=power)

# how it works?
# see Wagenmakers, Lodewyckx, Kuriyal, & Grasman (2010)
curve(dnorm(x, -0.5006, 0.18120), lwd=2, lty=3, from=-2, to=2, xlab='difference',ylab='density',
      main='Savage-Dickey method of computing Bayes factor')
curve(dcauchy(x, 0, 0.707), lwd=2, lty=2, from=-2,add=T)
lines(c(0,0), c(0, dcauchy(0, 0, 0.707)), lwd=2)
points(c(0,0), c(dcauchy(0, 0, 0.707), dnorm(0, -0.5006, 0.18120)), pch=16, cex=2)
points(c(0,0), c(dcauchy(0, 0, 0.707), dnorm(0, -0.5006, 0.18120)), pch=16, col='white')
legend('topright', c('H0 (r=0.707)', 'H1'), lwd=c(2,2), lty=c(2,3))


# we can also use one-sided tests
# here we check the Bayes factor for mu1 < mu2
# our null interval is from -infinity to 0
ttestBF(formula=jc_mean ~ cond, data=power, nullInterval = c(-Inf, 0))

# the value of the Bayes factor will change if we use different prior distribution
# here we assume greater uncertainty about prior scale of difference of means
ttestBF(formula=jc_mean ~ cond, data=power, rscale='wide')

# example with wide prior
curve(dnorm(x, -0.5006, 0.18120), lwd=2, lty=3, from=-2, to=2, xlab='difference',ylab='density',
      main='Savage-Dickey method of computing Bayes factor')
curve(dcauchy(x, 0, 1), lwd=2, lty=2, from=-2,add=T)
lines(c(0,0), c(0, dcauchy(0, 0, 1)), lwd=2)
points(c(0,0), c(dcauchy(0, 0, 1), dnorm(0, -0.5006, 0.18120)), pch=16, cex=2)
points(c(0,0), c(dcauchy(0, 0, 1), dnorm(0, -0.5006, 0.18120)), pch=16, col='white')
legend('topright', c('H0 (r=1)', 'H1'), lwd=c(2,2), lty=c(2,3))

# we can also set ultrawide prior
ttestBF(formula=jc_mean ~ cond, data=power, rscale='ultrawide')

# we can also use Bayes factor to perform paired test
# here we test whether belief in Jewish conspiracy was lower or higher that belief in Russian conspiracy
ttestBF(power[,'jc_mean'], power[,'rc_mean'],paired = T)


# Here begins the homework part. Use robust approach (BEST) to compare 2 means.
# Load the data below to start. Remember about loading rjags package.

muM <- mean(power$jc_mean)
# Lets set priors variances of group means to some large multiple of total std.
# Because JAGS uses precisions (inverse of variances), we invert prior expectations.
# This actually means that we put uninformative priors on group mean differences.
muP <- 0.000001 * 1/sd(power$jc_mean)^2
# Lets set lower and upper bounds of priors for group variances, to some large multiple and divisor of std.  
sigmaLow <- sd(power$jc_mean)/1000
sigmaHigh <- sd(power$jc_mean)*1000


# Lets set data for JAGS.
# y - should be some numerical vector of values (dependent variable)
# x - should be some numerical vector of group indices (1 or 2)
# Ntotal - should be set to total number of cases.
# Other values are prior setting defined above.
jags.data <- list(y=power$jc_mean, x=as.numeric(power$cond), 
                  muM=muM, muP=muP, sigmaLow=sigmaLow,
                  sigmaHigh=sigmaHigh, 
                  Ntotal=nrow(power))


        