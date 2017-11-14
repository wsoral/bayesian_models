# using JAGS

library(rjags)
library(LearnBayes)
library(bayesplot)

# Here we will analyze data collected by Open Science Collaboration.
# The aim of the collaboration was an independent replication of 
# 97 studies published in psychological papers.

# What is the probability of a successful replication of a published study?

# Before going into the results lets think about our prior.

# If you are very optimistic towards the results in psych. papers, you
# could assume that the probability of replicating the effect will be
# equal to the statistical power obtained in replications, it was p = .90.
# In practice, general estimation of this probability is almost impossible.
# For the purpose of this exercise lets choose p = .50.

# We can say that we are 50% sure that the proportion is not higher than .5
q1 <- list(p = .5, x = .5)
# We can say that we are 95% sure that the proportion is not higher than .9
q2 <- list(p = .95, x = .9)

beta.select(q1, q2)

# Lets draw our prior beliefs
curve(dbeta(x, 1.53, 1.53), lwd=2, col='red')

# With our prior beta distribution, we could just use beta-binomial model.
# However, here we will use JAGS simulations.

# Of the total of 97 attempts, 
# 35 succeeded in replication with p < 0.05 in the same direction.

# When working with JAGS we should put our data in a named list.
replications1 <- list(n = 97, s = 35, a = 1.53, b = 1.53)

# Then we need to create model (you will learn a lot about coding in JAGS later)
model_code1 <- "
model {
  s ~ dbin(theta, n)
  theta ~ dbeta(a,b)
}
"

# We have to initialize our model.
# It is good to have the model code in a separate file and then to point 
# the first argument to the file location. Like below:
# model1 <- jags.model("C:\codes\model_code1.txt", 
#                      data=replications1,
#                      n.chains = 4)
# Here, for simplicity we will point the first argument to the text 
# object model_code1. Because of how the function was programmed,
# we cannot simply include text object, but first we have to create
# text connection.
model1 <- jags.model(textConnection(model_code1), 
                     data=replications1,
                     n.chains = 4)

# First we will run model for 1000 iterations. This is a burnin period.
# No samples are saved. You should adjust the value of iterations
# for more complex analyses.
update(model1, 1000)

# Next we will run model for 10000 iterations. We will monitor (save) variables
# indicated in the argument variable.names, i.e. theta.
posterior1 <- coda.samples(model1, variable.names = c('theta'),
                           n.iter = 10000)

# First you should run some diagnostics. Here we will use Gelman and Rubin diag.
gelman.diag(posterior1)

# We can summarize our posterior - note the mean is almost identical as with
# analytical approach (i.e. 0.365081)
summary(posterior1)

# We can also plot the posterior. We will adjust shaded area to show 95% CI
mcmc_areas(posterior1, prob = 0.95)


# Now lets divide the data into those published in
# 1 - social psychology journals
# 2 - cognitive psychology journals.
# We will stick with the same prior.
replications2 <- list(n1 = 55, s1 = 14,
                     n2 = 42, s2 = 21, 
                     a = 1.53, b = 1.53)

# We will model these two proportions at the same time.
# First we model a situation where replications from social and cognitive
# journals have different probabilities of success.
# We will include deterministic node d as the difference between 2 probs.
model_code2 <- "
model {
  s1 ~ dbin(theta1, n1)
  s2 ~ dbin(theta2, n2)
  theta1 ~ dbeta(a,b)
  theta2 ~ dbeta(a,b)

  d <- theta1 - theta2
}
"

# We initialize a new model.
model2 <- jags.model(textConnection(model_code2), 
                     data=replications2,
                     n.chains = 4)

# We update a new model - burnin period.
update(model2, 1000)

# We draw 10000 iterations, saving 3 variables.
posterior2 <- coda.samples(model2, 
                           variable.names = c('theta1','theta2', 'd'),
                           n.iter = 10000)

# Diagnostic test
gelman.diag(posterior2)

# Summarizing model. Look at the value of d. What does it mean?
summary(posterior2)

# We plot posterior distrbutions.
mcmc_areas(posterior2)

# Instead of modeling data with separate parameters, we can model them with
# only 1 theta. We use the same data as with model2
model_code3 <- "
model {
  s1 ~ dbin(theta, n1)
  s2 ~ dbin(theta, n2)

  theta ~ dbeta(a,b)
}
"

# We initialize model 3.
model3 <- jags.model(textConnection(model_code3), 
                     data=replications2,
                     n.chains = 4)

# Burnin period
update(model3, 1000)

# Samples from posterior, monitoring theta.
posterior3 <- coda.samples(model3, 
                           variable.names = c('theta'),
                           n.iter = 10000)

# Convergence diagnostic.
gelman.diag(posterior3)

# Model summary
summary(posterior3)

# Posterior plot.
mcmc_areas(posterior3)

# Is model with 2 parameters better than a model with 1 parameter.
# We draw DIC samples for model 2 and model 3.
dicM2 <- dic.samples(model2, 10000)
dicM3 <- dic.samples(model3, 10000)

# We can summarize the results. Lower DIC = better fit.
dicM2
dicM3

# However, what is really useful is a direct comparison of both values.
# We can just substract one value from the other.
dicM2 - dicM3
