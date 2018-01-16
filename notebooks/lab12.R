# lab 12 - Bayesian ANOVA

# lets start with loading our small dataset
self <- read.csv('https://raw.githubusercontent.com/wsoral/bayesian_models/master/notebooks/selfesteem.csv')[,2:3]
View(self)

# lets draw a boxplot of self-esteem measures in each condition
library(ggplot2)
qplot(condition, selfesteem, data=self, geom="boxplot")

# if you would like to use frequentist ANOVA you could
summary(aov(selfesteem ~ condition, data=self))
# this is based on type I SS, which is appropriate only if groups are equal

# to use type II and type III SS use e.g. car package
# install.package("car")
library(car)
Anova(lm(selfesteem ~ condition, data=self), type=3)
# in this case the difference is only minor


# lets try Bayesian approach

# load rjags
library(rjags)

# we will now prepare data for rjags

# We will use this function to find prior distribution for variance of between group differences
gammaShRaFromModeSD = function( mode , sd ) {
  if ( mode <=0 ) stop("mode must be > 0")
  if ( sd <=0 ) stop("sd must be > 0")
  rate = ( mode + sqrt( mode^2 + 4 * sd^2 ) ) / ( 2 * sd^2 )
  shape = 1 + mode * rate
  return( list( shape=shape , rate=rate ) )
}

# Define DV as y
y = self$selfesteem
# Define IV as x (it should be numeric variable with numbers enumerating different factor levels)
x = as.numeric(self$condition)
# Once you define DV and IV above, use the command below to create jags.data
jags.data <- list(y = y,
                  x = x,
                  Ntotal = length(y),
                  NxLvl = length(unique(x)),
                  yMean = mean(y),
                  ySD = sd(y),
                  agammaShRa = gammaShRaFromModeSD(sd(y)/2, 2*sd(y))
                  )

# This is a prior that we assign to SD of between group differences
curve(dgamma(x, jags.data$agammaShRa[[1]],jags.data$agammaShRa[[2]]), 
      from=0, to =10, lwd=2, ylab="", xlab='aSigma prior')

# we will use code from Kruschke
mod_code <- "
model {
  for (i in 1:Ntotal) {
    y[i] ~ dnorm( a0 + a[x[i]], 1/ySigma^2 )
  }
  # Prior on parameters
  # on within group error (within group SS)
  ySigma ~ dunif( ySD/100, ySD*10 )

  # on baseline value
  a0 ~ dnorm( yMean, 1/(ySD*5)^2 )

  # on deflections from baseline value
  for ( j in 1:NxLvl ) {
    a[j] ~ dnorm( 0.0, 1/aSigma^2 )
  }
  # on sd of deflections from baseline value (between group SS)
  # finding appropriate priors for aSigma is very difficult
  # in this example we let data inform us about probable values
  aSigma ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # Convert a0,a[] to sum-to-zero b0,b[]
  for (j in 1:NxLvl ) { m[j] <- a0 + a[j] }
  b0 <- mean( m[1:NxLvl] )
  for (j in 1:NxLvl ) { b[j] <- m[j] - b0 }
}
"

# we are now ready to compile model
model <- jags.model(textConnection(mod_code),
                  data = jags.data,
                  n.chains = 4)

# burnin period
update(model, 1000)

# draw 10000 posterior samples
post <- coda.samples(model, c("aSigma", "ySigma","b0","b","m"),
                     n.iter=10000)

# simple diagnostics
gelman.diag(post, multivariate = F)
# as noted by Kruscke due to high autocorrelation 
# it common to have low ESS for aSigma
effectiveSize(post)

# we can now summarize parameters
summary(post)

# and graph some of the most interesting
library(bayesplot)

# we can draw mean with credible intervals
# I have used here regular expression to select all parameters 
# that match the pattern for group means, i.e. m[1], m[2], m[3], m[4]
mcmc_intervals(post, regex_pars = 'm\\[.\\]',prob = 0.95, prob_outer = 0.95)


# we can test contrasts with our posterior distribution
# first lets prepare the posterior

# I have merged the chains
posterior <- do.call(rbind, post)
# using regular expressions I have found columns that refer to deflections from the baseline
defId <- grep("b\\[.\\]", colnames(posterior))
# I have created new matrix with parameters for deflections
deflections <- posterior[,defId]


# Here you should define contrasts of interest
# c1 compares group 2 to 1, 3, and 4
# c2 compares group 2 to 3 and 4
# c3 compares group 1 to 2
C <- cbind(c1 = c(-1/3,1,-1/3,-1/3),
           c2 = c(0,1,-1/2,-1/2),
           c3 = c(-1,1,0,0))
C
# you can create your own contrasts (remember that they should some to 0)

# now with contrasts coefficients matrix and deflections
# we can calculate contrasts estimates
d_contrast <- as.mcmc(deflections %*% C)
summary(d_contrast)
mcmc_areas(d_contrast, prob = 0.9)

# by dividing each contrast by ySigma from our posterior we can obtain effect sizes
e_contrast <- as.mcmc(d_contrast / posterior[,"ySigma"])
summary(e_contrast)


# lets try robust approach with Student t distribution
# and unequal variances

mod_r_code <- "
model {
  for (i in 1:Ntotal) {
    y[i] ~ dt( a0 + a[x[i]], 1/ySigma[x[i]]^2, nu )
  }
  # Prior on parameters
  nu <- nuMinusOne + 1
  nuMinusOne ~ dexp( 1/29.0 )
  # on within group error (within group SS), different for each group
  for (j in 1:NxLvl){
    ySigma[j] ~ dgamma( ySigmaSh, ySigmaRa )
  }
  ySigmaSh <- 1 + ySigmaMode * ySigmaRa
  ySigmaRa <- (( ySigmaMode + sqrt( ySigmaMode^2 + 4*ySigmaSD^2 ))
                / ( 2*ySigmaSD^2 ))
  ySigmaMode ~ dgamma( agammaShRa[1], agammaShRa[2] )
  ySigmaSD ~ dgamma( agammaShRa[1], agammaShRa[2] )
  # on baseline value
  a0 ~ dnorm( yMean, 1/(ySD*10)^2 )

  # on deflections from baseline value
  for ( j in 1:NxLvl ) {
    a[j] ~ dnorm( 0.0, 1/aSigma^2 )
  }
  # on sd of deflections from baseline value (between group SS)
  aSigma ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # Convert a0,a[] to sum-to-zero b0,b[]
  for (j in 1:NxLvl ) { m[j] <- a0 + a[j] }
  b0 <- mean( m[1:NxLvl] )
  for (j in 1:NxLvl ) { b[j] <- m[j] - b0 }
}
"

# we are compiling our model
model_r <- jags.model(textConnection(mod_r_code),
                    data = jags.data,
                    n.chains = 4)

# burnin period
update(model_r, 1000)

# we draw 10000 samples from posterior
post_r <- coda.samples(model_r, c("aSigma", "ySigma","b0","b","m","nu"),
                     n.iter=10000)

# simple diagnostics
gelman.diag(post_r, multivariate = F)
effectiveSize(post_r)

# we can now summarize our results
summary(post_r)

# once again we can compute contrasts
posterior_r <- do.call(rbind, post_r)
defId_r <- grep("b\\[.\\]", colnames(posterior_r))
deflections_r <- posterior_r[,defId_r]

C <- cbind(c1 = c(-1/3,1,-1/3,-1/3),
           c2 = c(0,1,-1/2,-1/2),
           c3 = c(-1,1,0,0))

d_contrast_r <- as.mcmc(deflections_r %*% C)

summary(d_contrast_r)

