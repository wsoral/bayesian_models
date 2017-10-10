# Lab 2 - working sheet

# 1. Formulating prior beliefs

# What is a percent of your peers that have a pet (dog, cat, mouse, etc.)?
# Assign weights (any positive value or 0) to each of the values below, 
# so that the higher the weight the largest is your belief in a value

w_5_perc = ??
w_15_perc = ??
w_25_perc = ??
w_35_perc = ??
w_45_perc = ??
w_55_perc = ??
w_65_perc = ??
w_75_perc = ??
w_85_perc = ??
w_95_perc = ??

# Here we collect all the weights into one single vector
(w_vector = c(w_5_perc, w_15_perc, w_25_perc, w_35_perc, w_45_perc, 
            w_55_perc, w_65_perc, w_75_perc, w_85_perc, w_95_perc))

# We normalize the weights so that their sum will be 1 (like probability)
(prior = w_vector / sum(w_vector))

# We plot the obtained probabilities
perc_values = seq(0.05, 0.95, by=0.1)
plot(perc_values, prior, type='h', lwd=2,
     xlab='Percent of peers having a pet',
     ylab='Degree of belief',
     main='Prior',
     col='green2',
     ylim=c(0, max(prior)+0.1))


# 2. Understanding likelihood

# Given 12 successes and 8 failures, which is more likely, p = 0.3 or p = 0.6?

# Adjust values below before running tests
p_value_to_test = 0.1
successes = 10
failures = 10

# Run to obtain value proportionate to likelihood
(p_value_to_test^successes)*((1-p_value_to_test)^failures)

# Run to obtain value proportionate to log-likelihood
log((p_value_to_test^successes)*((1-p_value_to_test)^failures))


# 3. Making observations and calculating likelihood distribution

# Enter values collected from inclass survey
having_pet = ??
not_having_pet = ??

# We are making calculations of likelihood and plot the values
total = having_pet + not_having_pet
(likelihood = dbinom(having_pet, total, perc_values))
plot(perc_values, likelihood, type='h', lwd=2,
     xlab='Percent of having a pet',
     ylab='How much it is supported by data?',
     main='Likelihood',
     col='blue2')

# 4. Joining prior with likelihood

# We multiply values of prior by respective values of likelihood to obtain unnormalized posterior
(posterior_un = prior * likelihood)

# We are normalizing posterior by dividing each value by the sum of all values
(posterior_no = posterior_un / sum(posterior_un))

# We are plotting posterior values
plot(perc_values, posterior_no, type='h', lwd=2,
     xlab='Percent of having a pet',
     ylab='Degree of belief',
     main='Posterior',
     col='red2')

# We are comparing prior and posterior values - some R magic tricks (don't worry about them)

plot(perc_values, prior, type='h', lwd=2,
     xlab='Percent of peers having a pet',
     ylab='Degree of belief',
     main='Prior vs. posterior',
     col='green2', 
     ylim=c(0, max(posterior_no) + 0.1))

for (i in 1:10) {
  lines(c(perc_values[i]+0.01,perc_values[i]+0.01) , c(0, posterior_no[i]), lwd=2, col='red2')
}
legend('topright', c('Prior','Posterior'), lty=c(1,1), lwd=c(2,2), col=c('green2', 'red2'))

# 5. Finding beta distribution

# We have to download, install (at home do this only once, unless you have reinstalled R)
install.packages('LearnBayes')
# We how to run newly installed package (at home do this every time you want to use the package)
library(LearnBayes)


# Assess the median proportion of your peers who have watched the new Blade Runner movie
# I.e. you are 50% percent sure that it is not higher that x
x50 = ??
quantile1 = list(p=.5, x=x50)


# Assess the 90th percentile of proportion of your peers who have watched the new Blade Runner movie
# I.e. you are 90% percent sure that it is not higher that x
x90 = ??
quantile2 = list(p=.9, x=x90)

# Now we use function beta.select to find appropriate values of hyperparameters a and b
(betaHP = beta.select(quantile1, quantile2))


# 6. Calculating beta posterior

# Fill the number of those who have watched Blade Runner 2049
s = ??
# Fill the number of those who haven't watched Blade Runner 2049
f = ??

# Move hyperparameters of beta prior distribution to separate variables
a = betaHP[1]
b = betaHP[2]


# We can plot all three distributions
curve(dbeta(x, a+s, b+f), from=0, to=1, xlab='p', ylab='Density', lty=1, lwd=4, col='red2')
curve(dbeta(x, s+1, f+1), add=TRUE, lty=2, lwd=4, col='blue2')
curve(dbeta(x, a, b), add=TRUE,  lty=3, lwd=4, col='green2')
legend('topright', c('Prior', 'Likelihood', 'Posterior'), lty=c(3,2,1), lwd=c(3,3,3), col=c('green2','blue2','red2'))


# We can calculate CREDIBLE INTERVALS to summarize our results

values = round(qbeta(c(0.025, 0.25, 0.50, 0.75, 0.975), shape1 = a+s, shape2 = b+f), 2)
values = matrix(values, ncol=5)
colnames(values) = c('2.5%', '25%', '50%', '75%', '97.5%')
values

# We can also use formulas to find mean and variance of posterior distribution

(m_beta = (a+s)/((a+s) + (b+f)))
(v_beta = m*(1-m)/((a+s)+(b+f)+1))
(sd_beta = sqrt(v_beta))
