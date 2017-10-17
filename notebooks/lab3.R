## Lab 3 - working sheet

## 1. Why Be Normal?

## Lets draw a sample of 1000 cases from uniform distribution and plot it on a histogram?
## runif() - (r)andom (unif)orm, hist() - (hist)ogram
x1 = runif(1000, -4, 4)
hist(x1, col='lightblue', main="", xlab="", breaks=20)

## Now draw another sample of 1000 cases from uniform distribution 
## and add it to respective values from the previous sample, and draw a histogram
x_another = runif(1000, -4, 4)
x2 = x1 + x_another
hist(x2, col='lightblue', main="", xlab="", breaks=20)

## Repeat several times, go through each of the lines and notice how the histogram changes
x_another = runif(1000, -4, 4)
x3 = x2 + x_another
hist(x3, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x4 = x3 + x_another
hist(x4, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x5 = x4 + x_another
hist(x5, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x6 = x5 + x_another
hist(x6, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x7 = x6 + x_another
hist(x7, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x8 = x7 + x_another
hist(x8, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x9 = x8 + x_another
hist(x9, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x10 = x9 + x_another
hist(x10, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x11 = x10 + x_another
hist(x11, col='lightblue', main="", xlab="", breaks=20)

x_another = runif(1000, -4, 4)
x12 = x11 + x_another
hist(x12, col='lightblue', main="", xlab="", breaks=20)

## 2. Using Normal distribution
## How long does it takes for the Faculty students to get from their place to the Faculty? In minutes
## Try not to think about point but about range. What is the range for 2/3 of the Faculty students? 
## If you divide this range by 2 you will obtain standard deviation.

average_time = ?
std_dev_time = ?

## Plot your Normal distribution and check whether it looks OK? Try some other values of mean, and standard deviation.
## Choose values that best fits with your beliefs

minX = average_time - 3*std_dev_time
maxX = average_time + 3*std_dev_time
curve(dnorm(x, average_time, std_dev_time),
      from = minX, to=maxX,
      ylab="", xlab='Time to get to the Faculty (in minutes)',
      lwd=2, col='blue2')
values = c(average_time - 2*std_dev_time,
           average_time - std_dev_time,
           average_time,
           average_time + std_dev_time,
           average_time + 2*std_dev_time)
for (i in values){
  lines(c(i,i), c(0, dnorm(i, average_time, std_dev_time)), lwd=2, lty=2, col='gray2')
}
arrows(values[2],dnorm(values[2], average_time, std_dev_time), 
       values[4], dnorm(values[4], average_time, std_dev_time), length=.1, code = 3, col='gray2')
arrows(values[1],dnorm(values[1], average_time, std_dev_time), 
       values[5], dnorm(values[5], average_time, std_dev_time), length=.1, code = 3, col='gray2')
text(values[3], dnorm(values[2], average_time, std_dev_time), "68 %", cex=1.5)
text(values[3], dnorm(values[1], average_time, std_dev_time), "95 %", cex=1.5)

## 3. Normal Model with Unknown Mean and Known Variance

## Know lets construct prior on our beliefs about about the average time to get to the Faculty (in minutes)

mu_prior = ?

## Think about how certain you are about this estimate. With 95% certainty what is the range of the most typical value?
## Note that this is not the same as the range in the previous example. We are talking about certainty corresponding to central tendency?
## In previous example we were talking about (un)certainty corresponding to the whole population students.

upper_bound = ?
lower_bound = ?

## Note that we can easily find the standard deviation. Think about this equation and try to understand why?

sd_prior = (upper_bound - lower_bound) / 4


## Now observe. You can work collectively. Write your average time to get to the Faculty and collect times from your classmates.
## Put values between brackets in c(), separated by , .

x = c(,)


## Now we will calculate mean and sd of the observed values. Suppose that sd is fixed and it is equal to the observed value.

x_hat = mean(x)
x_sd = sd(x)
n = length(x) # number of observations


## We will calculate posterior for our beliefs regarding central tendency

mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2))

sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2))


## Lets plot our prior and posterior to compare them

curve(dnorm(x, mu_post, sd_post), from=mu_post-3*sd_post, to=mu_post+3*sd_post, lwd=2, col='red2', 
      xlab='Average time to get to the Faculty (in minutes)', ylab='', main='Prior vs. posterior')
curve(dnorm(x, x_hat, x_sd/sqrt(n)), add=TRUE, lwd=2, col='blue2')
curve(dnorm(x, mu_prior, sd_prior), add=TRUE, lwd=2, col='green2')
legend('topright', c('Prior','Likelihood','Posterior'), lty=c(1,1,1), lwd=c(2,2,2), col=c('green2','blue2','red2'))

## We can summarize obtained posterior distribution with quantiles

quant = qnorm(c(0.025, 0.25, 0.5, 0.75, 0.975), mu_post, sd_post)
names(quant) = c("2.5%", "25%", "50%", "75%", "97.5%")
quant

## We can test specific hypotheses, e.g. what is the probability that the average time is less than 40 minutes

pnorm(40, mu_post, sd_post)

## or that the average time is more than 40 minutes

1-pnorm(40, mu_post, sd_post)

## 4. Uninformative priors
## Sometimes when we don't have specific guess we can use prior with a huge variance - meaning that we are completely uncertain.

mu_prior = 0
sd_prior = 1000

mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2))

sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2))

curve(dnorm(x, mu_post, sd_post), from=mu_post-3*sd_post, to=mu_post+3*sd_post, lwd=2, col='red2', 
      xlab='Average time to get to the Faculty (in minutes)', ylab='', main='Prior vs. posterior')
curve(dnorm(x, x_hat, x_sd/sqrt(n)), add=TRUE, lwd=2, col='blue2', lty=2)
curve(dnorm(x, mu_prior, sd_prior), add=TRUE, lwd=2, col='green2')
legend('topright', c('Prior','Likelihood','Posterior'), lty=c(1,2,1), lwd=c(2,2,2), col=c('green2','blue2','red2'))


## 5. Prior elicitation

## Consider a population of psychology students. 
## How many books (fiction or non-fiction) a typical psychology student reads in a year?
## Which quantity you would consider as low (10 percentile), median (50 percentile), high (90 percentile)?

x10_1 = ?
x50_1 = ?
x90_1 = ?
  
## Now collect assessments from 3 of your classmates.
  
x10_2 = ?
x50_2 = ?
x90_2 = ?

x10_3 = ?
x50_3 = ?
x90_3 = ?

x10_4 = ?
x50_4 = ?
x90_4 = ?

## Gather responses into one single vector

responses = c(x10_1, x50_1, x90_1,
              x10_2, x50_2, x90_2,
              x10_3, x50_3, x90_3,
              x10_4, x50_4, x90_4)

responses

## 10, 50, and 90 percentile correspond to z values of -1.28, 0, 1.28 respectively
## You can check z-value corresponding to x percentile of standard normal distribution with qnorm
qnorm(0.10)
qnorm(0.50)
qnorm(0.90)

## You can check all values at the same time by giving a vector as an input
qnorm(c(0.10, 0.50, 0.90))

## We need to obtain corrending z-values for all assessors. In R we can replicate the vector n times with rep() function.
zvalues = rep(qnorm(c(0.10, 0.50, 0.90)), 4) # 4 is the number of assessors
zvalues

## Now we simply regress responses on z-values. Regression function in R is lm() (linear model)
## In regression formula value to the left of ~ is an outcome variable, and value to the right of ~ is a predictor
lm(responses ~ zvalues)

## (intercept) is elicited mean of our normal prior distribution
## zvalues (slope) is elicited standad deviation of our normal distribution

## We can plot our prior normal distribution
## Change the limits of plot by adjusting values from and to if necessary
curve(dnorm(x, mean = 6.583, sd = 2.829),
      from=0, to=20,
      lwd=2, col='green',
      xlab='Number of books read by psychology students',
      ylab='')
