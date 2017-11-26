# 1. Bayesian Theorem

We know that:

P( + | suffer ) = 0.95

P( + | non suffer ) = 0.10

P( suffer ) = 0.005


This also means that:

P( - | suffer ) = 0.05

P( - | non suffer ) = 0.90

P( non suffer ) = 0.995


we want to find P( + ) - probability that the test will be positive

A person can obtain positive result while being sufferer or not.

P( + ) = P( + and suffer ) + P( + and non suffer )

Recall the relation between joint and conditional Ps.

P( + ) = [P( + | suffer ) x P( suffer )] + [P( + | non suffer ) x P( non suffer )]

After substituting known values.

P( + ) = [0.95 x 0.005] + [0.10 x 0.995] = 0.10425


b) we want to find P( suffer | + ) - that, given a positive result, the person is a sufferer

We use Bayes theorem

P( suffer | + ) = [P( + | suffer ) x P( suffer )] / P( + )

Because we know P( + ) from previous part we can substitute known values

P( suffer | + ) = [0.95 x 0.005] / 0.10425 = 0.05 (after rounding)


c) we want to find P( non suffer | - )

We use Bayes theorem

P( non suffer | - ) = [P( - | non suffer ) x P( non suffer )] / P( - )

If we know P( + ), we can easily calculate P( - )

P( - ) = 1 - P( + ) = 0.89575

Now we, can substitute known values

P( non suffer | - ) = [0.90 x 0.995] / 0.89575 = 0.99972 (after rounding)

c) we want to find P that the person will be misclassified

This means that the test is positive and the person is not sufferer or the test is negative and the person is sufferer

P( miss ) = P( + and non suffer) + P( - and suffer)

Once again, recall the relation between joint and conditional Ps.

P( miss ) = [P( + | non suffer ) x P( non suffer )] + [P( - | suffer ) x P( suffer )]

We can substitute known values

P( miss ) = [0.10 x 0.995] + [0.05 x 0.005] = 0.10 (after rounding)


# 2. Beta-Binomial Model

## Finding beta prior

The code is:
```
# load package
library(LearnBayes)

# define prior beliefs
# your friend is 50% sure that the proportion of
# individuals after road vehicle accident, with
# diagnosed PTSD is no more than 10%
quantile1 = list(p = 0.50, x = 0.10)
# your friend is 95% sure that this proportion is no higher than 25%
quantile2 = list(p = 0.95, x = 0.25)

# using beta.select
betaPars = beta.select(quantile1, quantile2)
```

The values of beta parameters are 2.15 and 16.79

```
# save beta parameters into separate variables
betaPar1 = betaPars[1]
betaPar2 = betaPars[2]

# draw curve with beta prior
curve(dbeta(x, betaPar1, betaPar2), lwd=2, col='green')
```

## Finding beta posterior

a) find an updated posterior beta distribution

12 people were diagnosed with PTSD

42 people were not diagnosed with PTSD

Posterior beta distribution is then defined by the parameters:

a = 2.15 + 12 = 14.15

b = 16.79 + 42 = 58.79

b) draw a curve of the posterior beta distribution with correct parameters

The code for drawing the posterior curve:
```
post_a = betaPar1 + 12
post_b = betaPar2 + 42

curve(dbeta(x, post_a, post_b), lwd=2, col='red')
```

d) Does you friend thinks in a Bayesian way? Compare 50% and 95% quantiles of the posterior beta distribution with beliefs of your friend.

Finding quantiles of the posterior
```
# 50% CI
qbeta(c(0.25, 0.75), post_a, post_b)
```
[0.16; 0.23]

```
# 95% CI
qbeta(c(0.025, 0.975), post_a, post_b)
```
[0.11; 0.29]

If your friend is resistant to changing mind about the value of the proportion of people with PTSD, the it means that s/he treats data as random values, but parameters as fixed values. The deviation from the observation is not big enough to force him/her to change beliefs.
If s/he was a Bayesian, s/he would treat data as fixed, but parameters as random values. New data would force him to change belief about the parameters.


# 3. Normal-Normal Model with known variance

We now that the mean of IQ is 100, and 95% CI is [95, 105].

This means that prior variance of IQ mean is 2.5.

Therefore IQ ~ N(100, 2.5)

We can plot this with
```
mu_prior = 100
sd_prior = 2.5
curve(dnorm(x, mu_prior, sd_prior), lwd=2, col='blue')
```

Finding posterior for 1st study
```
# mean from 1st study
x_hat = 80
# sd from 1st study
x_sd = 15
# sample size from 1st study
n = 50

# posterior mean
(mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2)))

# posterior sd
(sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2)))
```
N(88.37, 1.62)


Finding posterior for 2nd study
```
# mean from 2nd study
x_hat = 90
# sd from 2nd study
x_sd = 15
# sample size from 2nd study
n = 50

# posterior mean
(mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2)))

# posterior sd
(sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2)))
```
N(94.19, 1.62)


Finding posterior for 3rd study
```
# mean from 3rd study
x_hat = 100
# sd from 3rd study
x_sd = 15
# sample size from 3rd study
n = 50

# posterior mean
(mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2)))

# posterior sd
(sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2)))
```
N(100, 1.62)

Finding posterior for 4th study
```
# mean from 4th study
x_hat = 110
# sd from 4th study
x_sd = 15
# sample size from 4th study
n = 50

# posterior mean
(mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2)))

# posterior sd
(sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2)))
```
N(105.81, 1.62)


Finding posterior for 5th study
```
# mean from 5th study
x_hat = 120
# sd from 5th study
x_sd = 15
# sample size from 5th study
n = 50

# posterior mean
(mu_post = ((mu_prior / sd_prior^2) + (n*x_hat/x_sd^2)) / ((1 / sd_prior^2) + (n / x_sd^2)))

# posterior sd
(sd_post = sqrt((sd_prior^2 * x_sd^2)/(x_sd^2 + n*sd_prior^2)))
```
N(111.63, 1.62)

c) compare the dispersion of raw means and posterior means - what can you see? are the posterior means lower or higher than raw means?

Raw means = [80, 90, 100, 110, 120]
Posterior means = [88.37, 94.19, 100, 105.81, 111.63]

Strong prior tends to penalize large deviations from the expected mean, so that the larger the deviation, the larger the change  induced on posterior mean.
Bayesian analysis is thus more robust against outlying observations, and more robust to unexpected results (some of which maybe due to pure chance).

# 4. Some basic R exercises

```
# a)
theta1 = seq(0, 1, length.out=100)
theta2 = seq(-4, 4, length.out=400)

# b)
p1 = dbeta(theta1, 0.5, 0.5)

# c)
p2 = dnorm(theta2, 0, 1)

# d)
plot(theta1, p1, type='l')
plot(theta2, p2, type='l')

# e)
qbeta(c(0.025, 0.50, 0.975), 2, 1)

# f)
pbeta(0.2, 1, 2)

# g)
set.seed(1234)
x = rnorm(1000, 50, 25)
quantile(x, c(0.025, 0.25, 0.50, 0.75, 0.975))

# h)
# loading library
library(ggplot2)

# drawing histograms
qplot(x=cont_var1, data=my_dataset, geom='histogram')
qplot(x=cont_var2, data=my_dataset, geom='histogram')

# drawing boxplots
qplot(x=cat_var, y=cont_var1, data=my_dataset, geom='boxplot')
qplot(x=cat_var, y=cont_var2, data=my_dataset, geom='boxplot')

# drawing scatterplots
qplot(x=cont_var1, y=cont_var2, data=my_dataset, geom = c('point', 'smooth'), method='lm')
```

# 5. Use of MCMCpack and bayesplot

```
# a) load MCMCpack, bayesplot, and MASS
library(MCMCpack)
library(bayesplot)
library(MASS)

# b) load dataset Boston and scale the predictors:
data(Boston)
Boston[,1:13] <- as.data.frame(scale(Boston[,1:13]))

# c) try to model median value of owner-occupied homes by all  
# other variables in the dataset. Use MCMCregress function and
# summarize your model.
model = MCMCregress(medv ~ crim + zn + indus + chas + nox + rm + age + dis + rad + tax + ptratio + black + lstat, data=Boston)

summary(model)

# d) uses mcmc_ares function to plot the posterior distribution,
# exclude Intercept and sigma2 from the plot (i.e. include only
# predictors' posteriors)
mcmc_areas(model, pars=c('crim','zn','indus','chas','nox','rm','age','dis','rad','tax','ptratio','black','lstat'))
```

# 6. Basics of JAGS

```
# Suppose you have a JAGS model as below,
# and data (k1=4, k2=7, n1=15, n2=20):

model_code = "
model {
  k1 ~ dbin(theta1, n1)
  k2 ~ dbin(theta2, n2)

  theta1 ~ dbeta(0.5, 0.5)
  theta2 ~ dbeta(0.5, 0.5)

  d <- theta1 - theta2
}
"

jags_data = list(k1=4, k2=7, n1=15, n2=20)

# 0) load rjags package
library(rjags)


# a) initialize the model in JAGS with 4 chains
model = jags.model(textConnection(model_code), data=jags_data, n.chains=4)

# b) update the model for 1000 burnin samples
update(model, 1000)

# c) draw 10000 posterior samples,
# set monitors on theta1, theta2, and d variables
posterior = coda.samples(model, c('theta1','theta2','d'), n.iter=10000)

# d) go to point 7 and perform convergence tests,
# after that go back here and summarize/describe your results
summary(posterior)
```

*e) is the proportion of individuals interested in Bayesian modeling course at WISP and PSU reliably different*

28% (95% CI: [9%; 52%]) at WISP declared interest in Bayesian statistics. 36% (95% CI: [17%; 56%]) at PSU declared interest in Bayesian statistics. The posterior distribution overlap to large extent. The difference of two proporotions was equalt to 7% (95% CI: [-22%; 36%]), meaning that we cannot say that this differnce is reliable.

# 7. Convergence tests

```
# a) draw traceplots and check their shapes - mcmc_trace
mcmc_trace(posterior)

# Shapes does not indicate any suspicious trend,
# Four separate chains overlap to large extent.

# b) conduct diagnostic tests and interpret them

geweke.diag(posterior)
# All values are within [-2, 2] - good.

heidel.diag(posterior)
# All tests were passed - good.

gelman.diag(posterior)
# All PSRFs are less that 1.1 - good.

# We have no evidence to reject the hypothesis
# that the model has converged.

# c) draw autocorrelation plots of the chains
mcmc_acf_bar(posterior)

# Autocorrelations for all variables are almost 0.
# This is an indication of good mixing.
# We should expect that effective samples sizes will be large
# (in comparison to nominal samples sizes)

# d) check effective sample sizes - effectiveSize -
# and compare them with nominal sample sizes

# Nominal sample size was 4 x 10 000 = 40 000.

# Effective sample sizes were greater than 39 500.
effectiveSize(posterior)
