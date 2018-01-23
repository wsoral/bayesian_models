# lab 13 - analysis of factorial ANOVA

# we will need 3 packages for the exercises
library(car)
library(ggplot2)
# install.packages("emmeans")
library(emmeans)

# dataset is from Adler study on experimenter expectations
data(Adler)
?Adler

# lets look at first rows of our dataset
head(Adler)

# lets look at frequencies in each cell of the experiment
with(Adler, table(instruction, expectation))

# first we will plot the results
qplot(instruction, rating, data=Adler, geom=c('boxplot'), fill=expectation)

# lets first take a frequentist approach
# our model looks like this
mod <- lm(rating ~ instruction * expectation, data=Adler)

# we will perform omnibus tests with type III SS
Anova(mod, type=3)


# after obtaining significant omnibus tests we can perform post-hocs

# check differences in the levels of instructions
lsmeans(mod, pairwise~instruction)

# check differences in the level of expectation
lsmeans(mod, pairwise~expectation)

# check differences in the level of expectation at each level of instruction
lsmeans(mod, pairwise~expectation | instruction)

# check differences in the level of instruction at each level of expectation
lsmeans(mod, pairwise~instruction | expectation)

# check all differences of means 
# note that because of increased number of comparison, penalty is higher
lsmeans(mod, pairwise~instruction * expectation)


# lets try Bayesian approach
library(rjags)

# next lines are similar as in one-way ANOVA
# We will use this function to find prior distribution for variance of between group differences
gammaShRaFromModeSD = function( mode , sd ) {
  if ( mode <=0 ) stop("mode must be > 0")
  if ( sd <=0 ) stop("sd must be > 0")
  rate = ( mode + sqrt( mode^2 + 4 * sd^2 ) ) / ( 2 * sd^2 )
  shape = 1 + mode * rate
  return( list( shape=shape , rate=rate ) )
}

# Define DV as y
y = Adler$rating
# Define factor 1 as x1 (it should be numeric variable with numbers enumerating different factor levels)
x1 = as.numeric(Adler$instruction)
# Define factor 2 as x2 (it should be numeric variable with numbers enumerating different factor levels)
x2 = as.numeric(Adler$expectation)
# Once you define DV and IV above, use the command below to create jags.data
jags.data <- list(y = y,
                  x1 = x1,
                  x2 = x2,
                  Ntotal = length(y),
                  Nx1Lvl = length(unique(x1)),
                  Nx2Lvl = length(unique(x2)),
                  yMean = mean(y),
                  ySD = sd(y),
                  agammaShRa = gammaShRaFromModeSD(sd(y)/2, 2*sd(y))
)

# model for factorial ANOVA with 2 factors
# normality of within-group residuals is assumed
# as well as homogeneity of variances
mod_code <- "
model {
  for ( i in 1:Ntotal ) {
    y[i] ~ dnorm( mu[i], 1/ySigma^2 )
    mu[i] <- a0 + a1[x1[i]] + a2[x2[i]] + a1a2[x1[i], x2[i]]
  }
  # prior for within group standard deviation
  ySigma ~ dunif( ySD/100, ySD*10 )

  # prior for grand mean (unconstrained)
  a0 ~ dnorm( yMean, 1/(ySD*5)^2 )

  # priors for deflections (unconstrained) associated with factor 1
  for ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm( 0.0, 1/a1SD^2 ) }
  # prior for standard deviation of deflections associated with factor 1
  a1SD ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # priors for deflections (unconstrained) associated with factor 2
  for ( j2 in 1:Nx2Lvl ) { a2[j2] ~ dnorm( 0.0, 1/a2SD^2 ) }
  # prior for standard deviation of deflections associated with factor 2
  a2SD ~ dgamma( agammaShRa[1], agammaShRa[2] )
  
  # priors for deflections (unconstrained) associated with interaction of 2 factors
  # a1a2[j1,j2] denotes that parameters are group in a matrix
  for ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {
    a1a2[j1,j2] ~ dnorm( 0.0, 1/a1a2SD^2 )
  }}
  # prior for standard deviation of deflections associated with interactions
  a1a2SD ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # now we want to constrain deflections a, to sum up to 0
  for ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {
    m[j1,j2] <- a0 + a1[j1] + a2[j2] + a1a2[j1,j2] # cell means
  }}
  # contrained grand mean
  b0 <- mean( m[1:Nx1Lvl,1:Nx2Lvl] )
  # constrained deflections factor 1
  for ( j1 in 1:Nx1Lvl ) { b1[j1] <- mean( m[j1,1:Nx2Lvl] ) - b0 }
  # constrained deflections factor 2
  for ( j2 in 1:Nx2Lvl ) { b2[j2] <- mean( m[1:Nx1Lvl,j2] ) - b0 }
  # contrained deflections interaction
  for ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {
    b1b2[j1,j2] <- m[j1,j2] - ( b0 + b1[j1] + b2[j2] )
  }}
}
"

# compiling the model
model2way <- jags.model(textConnection(mod_code), 
                        data=jags.data, 
                        n.chains = 4)

# updating - burning period
update(model2way, 1000)

# lets define parameters we want to monitor
pars <- c('b1','a1SD','b2','a2SD','b1b2','a1a2SD','ySigma','m')

# due to high autocorrelations we have increased nominal sample size a little bit (4 x 20000 = 80000)
fit <- coda.samples(model2way, variable.names = pars, n.iter = 20000)

# diagnostics
gelman.diag(fit, multivariate = F)
effectiveSize(fit)

# summarize fit
summary(fit)

# lets plot the output
library(bayesplot)

# lets compare between group sd's to withing group sd's
mcmc_areas(fit, pars=c('a1SD','a2SD','a1a2SD','ySigma'))

# lets extract samples for further analyses
posterior <- do.call(rbind, fit)

# lets draw predicted means
defIdM <- grep("m\\[.,.\\]", colnames(posterior))
# I have created new matrix with parameters for means
means <- posterior[,defIdM]
# I have reshaped data for ggplot
meansL <- stack(as.data.frame(means))
# I have use violin plots
qplot(ind, values, data=meansL, geom='violin')

# main effects contrasts - factor 1
# using regular expressions I have found columns that refer to deflections from the baseline
defIdF1 <- grep("b1\\[.\\]", colnames(posterior))
# I have created new matrix with parameters for deflections
deflF1 <- posterior[,defIdF1]


# Here you should define contrasts of interest
CF1 <- cbind(none.vs.all = c(1/2,-1,1/2),
             good.vs.scie = c(-1, 0, 1))
CF1
# you can create your own contrasts (remember that they should some to 0)

# now with contrasts coefficients matrix and deflections
# we can calculate contrasts estimates
dF1_contrast <- as.mcmc(deflF1 %*% CF1)
summary(dF1_contrast)


# main effects contrasts - factor 2
# using regular expressions I have found columns that refer to deflections from the baseline
defIdF2 <- grep("b2\\[.\\]", colnames(posterior))
# I have created new matrix with parameters for deflections
deflF2 <- posterior[,defIdF2]


# because this factor has only two levels, only one contrast makes sense
CF2 <- cbind(high.vs.low = c(-1,1))
CF2
# you can create your own contrasts (remember that they should some to 0)

# now with contrasts coefficients matrix and deflections
# we can calculate contrasts estimates
dF2_contrast <- as.mcmc(deflF2 %*% CF2)
summary(dF2_contrast)


# simple effects contrasts - interaction
# using regular expressions I have found columns that refer to deflections from the baseline
defIdInt <- grep("b1b2\\[.,.\\]", colnames(posterior))
# I have created new matrix with parameters for deflections
deflInt <- posterior[,defIdInt]


# interaction matrix (assuming Instruction is x1, and expectation is x2)
# to understand the order of contrast coef. count cells from top to bottom in the most left column, 
# and then move to the column to the right 
#      Expectation  high  low
# Instruction good    1    4
#             none    2    5
#             scie    3    6

#                                       1  2  3  4  5  6                                    
CFInt <- cbind(high.vs.low.at.good = c(-1, 0, 0, 1, 0, 0 ),
               high.vs.low.at.scie = c( 0, 0,-1, 0, 0, 1 ),
               high.vs.low.at.none = c( 0,-1, 0, 0, 1, 0 ),
               hi.lo.x.good.scient = c(-1, 0, 1, 1, 0,-1 ))
CFInt
# you can create your own contrasts (remember that they should some to 0)

# now with contrasts coefficients matrix and deflections
# we can calculate contrasts estimates
dFInt_contrast <- as.mcmc(deflInt %*% CFInt)
summary(dFInt_contrast)



## Model comparison approach
## this is the same model as previously but with added
## additional parameters delta1, delta2, delta1x2
## that indicate importance of each factors, and interaction
mod_code_model_com <- "
model {
  for ( i in 1:Ntotal ) {
    y[i] ~ dnorm( mu[i], 1/ySigma^2 )
    mu[i] <- a0 + delta1 * a1[x1[i]] + delta2 * a2[x2[i]] + delta1x2 * delta1 * delta2 * a1a2[x1[i], x2[i]]
  }
  # priors for deltas (factor inclusion probabilities)
  delta1 ~ dbern( 0.5 )
  delta2 ~ dbern( 0.5 )
  delta1x2 ~ dbern( 0.5 )

  # prior for within group standard deviation
  ySigma ~ dunif( ySD/100, ySD*10 )

  # prior for grand mean (unconstrained)
  a0 ~ dnorm( yMean, 1/(ySD*5)^2 )

  # priors for deflections (unconstrained) associated with factor 1
  for ( j1 in 1:Nx1Lvl ) { a1[j1] ~ dnorm( 0.0, 1/a1SD^2 ) }
  # prior for standard deviation of deflections associated with factor 1
  a1SD ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # priors for deflections (unconstrained) associated with factor 2
  for ( j2 in 1:Nx2Lvl ) { a2[j2] ~ dnorm( 0.0, 1/a2SD^2 ) }
  # prior for standard deviation of deflections associated with factor 2
  a2SD ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # priors for deflections (unconstrained) associated with interaction of 2 factors
  # a1a2[j1,j2] denotes that parameters are group in a matrix
  for ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {
    a1a2[j1,j2] ~ dnorm( 0.0, 1/a1a2SD^2 )
  }}
  # prior for standard deviation of deflections associated with interactions
  a1a2SD ~ dgamma( agammaShRa[1], agammaShRa[2] )

  # now we want to constrain deflections a, to sum up to 0
  for ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {
    m[j1,j2] <- a0 + a1[j1] + a2[j2] + a1a2[j1,j2] # cell means
  }}
  # contrained grand mean
  b0 <- mean( m[1:Nx1Lvl,1:Nx2Lvl] )
  # constrained deflections factor 1
  for ( j1 in 1:Nx1Lvl ) { b1[j1] <- mean( m[j1,1:Nx2Lvl] ) - b0 }
  # constrained deflections factor 2
  for ( j2 in 1:Nx2Lvl ) { b2[j2] <- mean( m[1:Nx1Lvl,j2] ) - b0 }
  # contrained deflections interaction
  for ( j1 in 1:Nx1Lvl ) { for ( j2 in 1:Nx2Lvl ) {
    b1b2[j1,j2] <- m[j1,j2] - ( b0 + b1[j1] + b2[j2] )
  }}
}
"


# compiling the model
model2wayMC <- jags.model(textConnection(mod_code_model_com), 
                          data=jags.data, 
                          n.chains = 4)

# this model is actually very hard to fit
# adjust the values of burnin and monitored iterations
# untill you will obtain satisfactory diagnostic values
update(model2wayMC, 1000)

# we are only interested in new parameters
parsMC <- c('delta1','delta2','delta1x2')

# monitored samples
fitMC <- coda.samples(model2wayMC, 
                      variable.names = parsMC, 
                      n.iter = 10000)

# diagnostics
gelman.diag(fitMC, multivariate = F)
effectiveSize(fitMC)

# lets summarize our results
summary(fitMC)

mcmc_areas(fitMC, pars=c('delta1','delta2','delta1x2'))
