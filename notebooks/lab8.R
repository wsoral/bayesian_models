# lab 8 - Bayesian estimation supersedes
# Lets start with a small warmup exercise. 
# We will draw samples from Normal-Normal model using JAGS to check mean and std of a vector y.
y <- c(4.48, 2.53, 8.78, 6.59, 4.84, 3.93, 6, 7.3, 6.02, 5.8, 3.55, 3.78, 2.56, 3.17, 5.08, 7.64, 1.62, 4.04, 4.68, 6.52)
# We will load rjags
library(rjags)

# We will set JAGS data. We will use N as a number of elements in vector y.
jags.data <- list(y=y, N=length(y))

# We could write a code like this. 
mod_code0 <- "
model {
  y[1] ~ dnorm(mu, tau)
  y[2] ~ dnorm(mu, tau)
  y[3] ~ dnorm(mu, tau)
  y[4] ~ dnorm(mu, tau)
  y[5] ~ dnorm(mu, tau)
  y[6] ~ dnorm(mu, tau)
  y[7] ~ dnorm(mu, tau)
  y[8] ~ dnorm(mu, tau)
  y[9] ~ dnorm(mu, tau)
  y[11] ~ dnorm(mu, tau)
  y[12] ~ dnorm(mu, tau)
  y[13] ~ dnorm(mu, tau)
  y[14] ~ dnorm(mu, tau)
  y[15] ~ dnorm(mu, tau)
  y[16] ~ dnorm(mu, tau)
  y[17] ~ dnorm(mu, tau)
  y[18] ~ dnorm(mu, tau)
  y[19] ~ dnorm(mu, tau)
  y[20] ~ dnorm(mu, tau)
  # Priors
  mu ~ dnorm(0, 0.0001)
  tau <- 1/pow( sigma, 2 )
  sigma ~ dunif(0, 100)
}
"

# However, this is tedious and error prone work. Hence we will use a little bit more complex approach.
mod_code0 <- "
model {
  for (i in 1:N) {
    y[i] ~ dnorm(mu, tau)
  }
  # Priors  
  mu ~ dnorm(0, 0.0001)
  tau <- 1/pow( sigma, 2 )
  sigma ~ dunif(0, 100)
}
"

# We will initialize our model.
model0 <- jags.model(textConnection(mod_code0), data=jags.data, n.chains = 4)

# We will draw 1000 burnin samples.
update(model0, 1000)

# We will draw samples from posterior
post0 <- coda.samples(model0, variable.names = c('mu','sigma'),
                      n.iter=10000)

# Diagnostic checks
gelman.diag(post0)
effectiveSize(post0)

# Summary
summary(post0)

## Now let try something more serious. 


# We will load ptsd.sav - this a dataset from a fake study, where the aim was to examine:
# How new (1) vs. old (2) method of psychotherapy affects number of daily PTSD intrusions.
library(ggplot2)

# First lets try to plot our data, to see what's going on.
qplot(as.factor(gr), y, data=ptsd, geom='boxplot')
# There are certain outliers in this dataset.
# Moreover, variances in both groups seem to be unequal.

# Typically, you would run Levene's test for equality of variances.
# Install car packages for Levene's test
# install.packages("car")
library(car)
leveneTest(y ~ as.factor(gr), data=ptsd)
# Levene's test does not seem to detect the obvious problem with variances.
# Can you deduct why?

# Lets run t test (assuming equal variances).
t.test(y ~ as.factor(gr), data=ptsd, var.equal=TRUE)

# Lets try t test for unequal group variances (Welch test).
t.test(y ~ as.factor(gr), data=ptsd, var.equal=FALSE)

# Wait, actually we should use one sided test!
t.test(y ~ as.factor(gr), data=ptsd, var.equal=FALSE, alternative="less")

# With frequentist approach, you should technically give up.
# Or you could remove outliers and re-run the analysis.
# But are 23, 25, 33 in fact 'true' outliers?
# Removing outliers is controversial and criteria for their selection are usually quite blurry.


# Lets try Bayesian approach to robust comparison of 2 means.

# Lets use the approach from Kruschke.
mod_code <- "
model {
  # Instead of writing likelihood for each participant, we will use loop.
  for ( i in 1:Ntotal ) {
    y[i] ~ dt( mu[x[i]], tau[x[i]], nu )
  }
  # Set priors for means and variances (precisions).
  for ( j in 1:2 ) {
    mu[j] ~ dnorm( muM, muP )
    tau[j] <- 1/pow( sigma[j], 2 )
    sigma[j] ~ dunif( sigmaLow, sigmaHigh )  
  }
  # set priors for nu
  nu <- nuMinusOne + 1
  nuMinusOne ~ dexp(1/29)
  # Compute difference of means
  diffM <- mu[1] - mu[2]
  # Compute difference of scales
  diffS <- sigma[1] - sigma[2]
  # Compute effect size
  effSize <- (mu[1]-mu[2])/sqrt((sigma[1]^2 + sigma[2]^2)/2)
}
"

# Lets set prior means of group means equal to the total mean in sample. 
muM <- mean(ptsd$y)
# Lets set priors variances of group means to some large multiple of total std.
# Because JAGS uses precisions (inverse of variances), we invert prior expectations.
# This actually means that we put uninformative priors on group mean differences.
muP <- 0.000001 * 1/sd(ptsd$y)^2
# Lets set lower and upper bounds of priors for group variances, to some large multiple and divisor of std.  
sigmaLow <- sd(ptsd$y)/1000
sigmaHigh <- sd(ptsd$y)*1000

# Lets set data for JAGS.
# y - should be some numerical vector of values (dependent variable)
# x - should be some numerical vector of group indices (1 or 2)
# Ntotal - should be set to total number of cases.
# Other values are prior setting defined above.
jags.data <- list(y=ptsd$y, x=ptsd$gr, 
                  muM=muM, muP=muP, sigmaLow=sigmaLow,
                  sigmaHigh=sigmaHigh, 
                  Ntotal=nrow(ptsd))

# Lets initialize our model.
model <- jags.model(textConnection(mod_code),
                    data=jags.data,
                    n.chains = 4)

# Update 1000 burnin iterations
update(model, 1000)

# Lets draw 10000 samples from posterior.
# We will draw samples from:
# mu - group means
# sigma - group stds.
# nu - "normality" parameter
# diffM - difference of group means
# diffS - difference of stds.
# effSize - effect size (Cohen's d)
posterior <- coda.samples(model, 
                          variable.names = c('mu','sigma', 'nu', 'diffM','diffS','effSize'),
                          n.iter = 10000)

# Diagnostics of convergence and effective samples sizes
gelman.diag(posterior, multivariate = F)
effectiveSize(posterior)

# Lets summarize our results
summary(posterior)

# And plot some of the results
library(bayesplot)
mcmc_areas(posterior, pars=c("sigma[1]","sigma[2]"), prob = 0.95)

mcmc_areas(posterior, pars=c("diffS"), prob = 0.95)

mcmc_areas(posterior, pars=c("mu[1]","mu[2]"), prob = 0.95)

mcmc_areas(posterior, pars=c("diffM"), prob = 0.95)

mcmc_areas(posterior, pars=c("effSize"), prob = 0.95)


## What if you REALLY need to have p-values?

# Lets first aggregate chains from our posterior
post <- as.mcmc(do.call(rbind, posterior))

# Testing one sided hypothesis is straighforward.
# Here we will check "null" hypothesis that the difference is greater than 0.
mean(post[,'diffM'] > 0)
# What is probabilitiy that the difference is less than 0.
mean(post[,'diffM'] < 0)

## What if you really need to test two-sided hypothesis.
# Only frequentists think that the difference of any 2 population means can be equal to 0. 
# The probability of a parameter (with contiuous scale)
# taking the value of 0 (or any specific other) is infinitely small.
# From Bayesian viewpoint testing whether some parameter is different from 0 makes no sense.

## Please, I REALLY need to test two-sided hypothesis!!!
# There are at least 2 solutions to this problem.

# First solution:
# You could approximate posterior of some parameter with normal distribution and then use
# Normal tables to find p-value.

# Find the values of mean and SD of difference of means.
postNormalMean = -2.405
postNormalSD = 1.1270

# If the observed difference of means is less than 0:
2*pnorm(0, postNormalMean, postNormalSD, lower.tail = F)

# If the observed difference of means is greater than 0:
2*pnorm(0, postNormalMean, postNormalSD, lower.tail = T)

# You can treat this value as a two-sided test of your hypothesis.
# However, it's interpretation is somewhat unclear.


# Second solution:
# Instead of testing whether parameter is different than 0, check probability,
# that the value of parameter lies outside the region of practical equivalence (ROPE).
# ROPE - interval of values around 0, which we can treat as if they are actually 0.
# Defining ROPE can be quite hard and subjective, it also strongy depends on the scale.

# Lets assume, that we treat as practical difference a situation, where
# we observe an increase/decrease in number of daily intrusions by 1, among half of the participants.
# This means that we would treat as practically equivalent differences smaller than 0.5 (or greated than -0.5)

# Lets check the probability that the posterior of diffM lies within ROPE.
mean(post[,'diffM'] > -0.5 & post[,'diffM'] < 0.5)

# And probability that the posterior of diffM lies outside ROPE.
mean(post[,'diffM'] < -0.5 | post[,'diffM'] > 0.5)

# However, if you could also decide that practical difference is a group difference of 1 (or some higher).
mean(post[,'diffM'] > -1 & post[,'diffM'] < 1)
# ...reverse
mean(post[,'diffM'] < -1 | post[,'diffM'] > 1)
# This can change our conclusions. 

# You should define ROPE before starting to analyze your data.
# If possible you should even preregister it (using OSF or some other platform).