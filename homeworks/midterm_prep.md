# 1. Bayes Theorem
A diagnostic test has a probability 0.95 of giving a positive result when applied to a person suffering
from a certain disease, and a probability 0.10 of giving a (false) positive when applied to a non-sufferer. It is
estimated that 0.5% of the population are sufferers. Suppose that the test is now administered to a person about
whom we have no relevant information relating to the disease (apart from the fact that he/she comes from this
population). Calculate the following probabilities:

(a) that the test result will be positive;
Recall what the denominator of the Bayes Theorem stands for.

(b) that, given a positive result, the person is a sufferer;
This should be pretty easy.

(c) that, given a negative result, the person is a non-sufferer;
This should be also pretty easy.

(d) that the person will be misclassified.
The last one is a little bit tricky. You don't need to use Bayes Theorem here.
What you need to do is to calculate the sum of joint probabilities: P(test positive and non-sufferer) + P(test negative and sufferer).
Recall the relation between conditional and joint probabilities.

# 2. Beta-Binomial Model

## Finding beta prior
Suppose your friend is 50% sure that the proportion of individuals after road vehicle accident, with diagnosed PTSD is no more than 10%.
Moreover, you friend is 95% sure that this proportion is no higher than 25%.

(a) find a correct beta distribution describing beliefs of your friend (use package `LearnBayes`)

(b) draw a curve of the prior beta distribution with correct parameters

## Finding beta posterior
Both with your friend you read an article reporting that among 54 individuals after road vehicle accident, 12 were diagnosed with PTSD.

(a) find an updated posterior beta distribution

(b) draw a curve of the posterior beta distribution with correct parameters

(c) after seeing the data your friend tells you that they are consistent with his thinking (the result is within the 95%CI he formulated) and therefore he will not change his mind.

(d) Does you friend thinks in a Bayesian way? Compare 50% and 95% quantiles of the posterior beta distribution with beliefs of your friend.

# 3. Normal-Normal Model with known variance

From the basis of psychometrics, we know that the mean of IQ in the general population is around 100. Taking in mind some random processes, we can say that we are 95% sure that the mean IQ is in the interval [95, 105]. Suppose you have conducted 5 studies on samples (each n = 50) from the general population. You obtained following means (80, 90, 100, 110, 120). Standard deviations were equal to 15.

(a) find a correct normal distribution taking into account previous knowledge about mean IQ

(b) calculate updated posterior means from each of the studies (as if they were conducted at the same time)

(c) compare the dispersion of raw means and posterior means - what can you see? are the posterior means lower or higher than raw means?

# 4. Some basic R exercises

(0) review the use of RStudio, and how to obtain help in R

(a) create a vector `theta1` with numbers from 0 to 1 of length 100, create another vector `theta2` with numbers from -4 to 4 of length 400

(b) find density estimates of beta distribution (with parameters a=0.5 and b=0.5) for each element of `theta1` (use dbeta function on the vector), save the result to variable `p1`

(c) find density estimates of Normal distribution (with parameters m=0.0 and sd=1) for each element of `theta2` (use dbeta function on the vector), save the result to variable `p2`  

(d) draw a line plot of the relation between `theta1` and `p1`; do the same for variables `theta2` and `p2`

(e) find the 50%, 2.5%, and 97.5% quantiles for beta distribution with parameters a=2 and b=1 (use function qbeta)

(f) find a probability of x <= 0.2 distributed as beta with parameters a=1 and b=2 (use function pbeta)

(g) draw a random sample of 1000 elements from Normal distribution (with rnorm function) with m=50 and sd=25, and summarize 2.5%, 25%, 50%, 75%, and 97.5% quantiles of the samples (using quantile function); just before using rnorm function enter this: `set.seed(1234)` - this will make the random results replicable

(h) use your own SPSS dataset (from your own research):
- load the dataset to RStudio
- choose two continuous variables and one categorical
- load ggplot2 library
- using qplot funtion draw histograms of the two continuous variables
- using qplot funtion draw boxplots of the two continuous variables on the categorical variable
- using qplot function draw a scatterplot of the two continuous variables with fitted linear regression line

# 5. Use of MCMCpack and bayesplot

(a) load MCMCpack, bayesplot, and MASS (this should be already installed with base R) packages

(b) load dataset Boston and scale the predictors:
```
data(Boston)
Boston[,1:13] <- as.data.frame(scale(Boston[,1:13]))
```
(c) the dataset consists of housing values in suburbs of Boston, try to model median value of owner-occupied homes by all other variables in the dataset.
Use MCMCregress function and summarize your model.

(d) uses mcmc_ares function to plot the posterior distribution, exclude Intercept and sigma2 from the plot (i.e. include only predictors' posteriors)

# 6. Basics of JAGS

(a) Suppose you have a JAGS model as below, and data (k1=4, k2=7, n1=15, n2=20):

```
model {
  k1 ~ dbin(theta1, n1)
  k2 ~ dbin(theta2, n2)

  theta1 ~ dbeta(0.5, 0.5)
  theta2 ~ dbeta(0.5, 0.5)

  d <- theta1 - theta2
}
```
The data are from a fake study where participants at WISP (n1) and Polish psychology unit (PSU) (n2), indicated their interest in Bayesian modeling course.
k1=4 indicated interest at WISP, and k2=7 indicated interest at PSU.
The aim is to compare percent of interest in Bayesian modeling at WISP (theta1) and at PSU (theta2); i.e. d = theta1 - theta2

(0) load rjags package

(a) initialize the model in JAGS with 4 chains - use jags.model function

(b) update the model for 1000 burnin samples - use update function

(c) draw 10000 posterior samples, set monitors on theta1, theta2, and d variables

(d) go to point 7 and perform convergence tests, after that go back here and summarize/describe your results

(e) is the proportion of individuals interested in Bayesian modeling course at WISP and PSU reliably different

# 7. Convergence tests

On the samples from previous exercise perform diagnostic tests:

(a) draw traceplots and check their shapes - mcmc_trace

(b) conduct diagnostic tests and interpret them (geweke.diag, gelman.diag, heidel.diag)

(c) draw autocorrelation plots of the chains and check for too high autocorrelations - mcmc_acf_bar

(d) check effective sample sizes - effectiveSize - and compare them with nominal sample sizes
