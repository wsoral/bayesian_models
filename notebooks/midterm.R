# Load the objects below - the data and the model code.
J <- 8
y <- c(8,  8, -3,  7, -1,  1, 18, 12)
se <- c(15, 10, 16, 11,  9, 11, 10, 18)

jags.data <- list(J=J, y=y, se=se)


jags.code <- "
model {
  for (i in 1:J) {
    y[i] ~ dnorm(theta[i], prec[i])
    theta[i] ~ dnorm(mu, tauInv)
    prec[i] <- 1/pow(se[i], 2)
  }
  mu ~ dnorm(0, 0.04)
  tau ~ dt(0, 0.04, 1)T(0,)
  tauInv <- 1/pow(tau, 2)
}
"

# Run JAGS simulations with 4 chains, 500 burnin samples, and 5000 saved samples of parameters: mu and tau.
# Use functions: jags.model, update, and coda.samples. Remember to load rjags package first.

# Diagnose convergence with the following functions: geweke.diag, heidel.diag, gelman.diag, mcmc_trace (package bayesplot)

# Check autocorrelations and effective sample size 
# with functions: mcmc_acf_bar (package bayesplot) and effectiveSize

# Send your code to me, before the end of the midterm. 
# Failure to do so will result in no points for the assignment.
