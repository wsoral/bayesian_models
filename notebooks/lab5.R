# Lab 5 - working with R - part 2, Bayesian simulations


## 1. Some quick Bayesian functions

install.packages('MCMCpack')
library(MCMCpack)

## We will work with data on risk factors associated with low infant birth weight

View(birthwt)
help(birthwt)


## Just for comparative reasons lets start with frequentist multiple regression approach
modelFreq <- lm(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt)
summary(modelFreq)


## With MCMCpack we can easily compute Bayesian alternative and find posterior for regression weights
## By default the function uses uninformative priors, we will cover setting informative priors later
modelBayes <- MCMCregress(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt)

## We can print a summary with Bayesian point estimates and credible intervals
summary(modelBayes)

## We can also print Highest Posterior Density Intervals (see Kruschke, p.87)
HPDinterval(modelBayes)

## Usually we plot the obtained posterior distribution - bayesplot package has some very convenient functions
install.packages('bayesplot')
library(bayesplot)
library(ggplot2)
color_scheme_set('red')

# We plot the posterior for reg. coefficient of mother's weight in pounds at last menstrual period
mcmc_areas(modelBayes, pars = c('lwt'), prob = 0.95)+theme_classic()

# We plot the posterior for reg. coefficients of smoking status during pregnancy, history of hypertension, and presence of uterine irritability
mcmc_areas(modelBayes, pars = c('smoke','ht', 'ui'), prob = 0.95)+theme_classic()

# We plot the posterior for reg. coefficient of mother's race (1 = white, 2 = black, 3 = other)
mcmc_areas(modelBayes, pars=c('as.factor(race)2', 'as.factor(race)3'), prob= 0.95)+theme_classic()

## 2. Model selection and model averaging

## Sometimes when we don't know the model, we can try to choose the best based on it's fit to the data
## This is where Bayesian approach exceeds classical approach to a great extent
## Not only we can select the best model, but also we can base our predictions on average of all models

## We can use BMS package to perfom Bayesian Model Selection and Bayesian Model Averaging
model_sel <- bms(bwt ~ age + lwt + smoke + ptl + ht + ui + ftv, data=birthwt)

image(model_sel)

## 3. Computing integrals with simulations

## Recall our example with beta binomial model
curve(dbeta(x, 0.1, 0.1), col='green', lwd=2, ylim=c(0,3.5))
curve(dbinom(7, 10, p=x)*11, col='blue', lwd=2, add=TRUE)
legend('topright', c('Prior', 'Likelihood'), col=c('green','blue'), lwd=c(2,2))

## To calculate posterior we multiply prior and likelihood for each value of parameter
thetas = seq(0.1, 0.99, length.out = 100)
ps_un = dbeta(thetas, 0.1,0.1)*dbinom(7, size = 10, p=thetas)*11

## Note however, that when we plot the results, we have incorrect functional form
## This is because we have to normalize the posterior by dividing each of its value by evidence
lines(thetas, ps_un, col='red', lwd=2)

## Lets calculate evidence by calculating integral of unnormalized posterior
plot(thetas, ps_un, type = 'l', lwd=2, col='red', ylim=c(0,1), xlim=c(0,1))

## We will use rejection sampling - first we draw a rectangle around our distribution
## The area of the rectangle is 0.8
rect(0, 0, 1, 0.8, border='pink', lwd=2)


## Now we draw 1000 sample points within the rectangle and plot it
xs <- runif(1000, 0, 1)
ys <- runif(1000, 0, 0.8)
points(xs, ys, col='pink')

## Next we select only those samples with value of y lower than the value of the curve
xs_rej <- xs[ys <= dbeta(xs, 0.1,0.1)*dbinom(7, size = 10, p=xs)*11]
ys_rej <- ys[ys <= dbeta(xs, 0.1,0.1)*dbinom(7, size = 10, p=xs)*11]

## To check computation we highlight selected samples
points(xs_rej, ys_rej, pch=16, col='pink')

## Proportion of the selected samples is easy to calculate if we just check the length of the vector of selected samples
length(xs_rej)

## And divide it by a total number of samples - length of xs
(prop_rej <- length(xs_rej) / length(xs))

## We can compute the value of integral (evidence) by multiplying the area of the rectangle by the obtained proportion
(evidence <- prop_rej * 0.8)

## We can normalize the posterior by dividing each value of the unnormalized posterior by evidence
ps_no <- ps_un / evidence

## Lets plot normalized posterior against prior and likelihood
curve(dbeta(x, 0.1, 0.1), col='green', lwd=2, ylim=c(0,3.5))
curve(dbinom(7, 10, p=x)*11, col='blue', lwd=2, add=TRUE)
lines(thetas, ps_no, col='red', lwd=2)
legend('topright', c('Prior', 'Likelihood', 'Posterior - sim.'), col=c('green','blue', 'red'), lwd=c(2,2))

## Lets compare to posterior from analytical solution
curve(dbeta(x,7.1, 3.1), col='black', lwd=2, add=TRUE)

## Now increase the number of samples and check whether simulated and derived analytically posteriors match closer
## Go back to line 71 and redo, change the number of simulations to 100000, don't plot the points (it will get messy). Just calculate the values


## 4. Summarizing sampled posterior

## If we know the distributional form and parameters we can sample values from posterior directly
posterior_beta <- rbeta(1000, 7.1, 3.1)

## We can calculate mean and standard error of sampling with simple formulas
mean(posterior_beta)
sd(posterior_beta)/sqrt(length(posterior_beta))

## We can compute credible intervals for our samples
cis <- quantile(posterior_beta, c(0.025, 0.25, 0.5, 0.75, 0.975))
names(cis) <- c("2.5%", "25%", "50%", "75%", "97.5%")
cis

## We can also compute HPD intervals
HPDinterval(as.mcmc(cis), prob = .95)
