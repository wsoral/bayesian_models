# Lab 6 - Markov Chain Monte Carlo (MCMC) 

## 1. What is Markov Chain?

## Suppose there are people in 2 rooms: 20 people in room 1, and 80 people in room 2
## Lets call this 2-room state state2 at initial time, t=1
state2 <- c(20, 80)

## Now, people can change rooms. 
## Within some period of time (say 1 hour):
## 80% of people in room 1 will go to room 2, and 20% will stay in room 1
## 70% of people in room 2 will go to room 1, and 30% will stay in room 2
## We can code this transitions with a matrix
K2 <- matrix(c(0.2, 0.8, 
               0.7, 0.3), 
             ncol=2, byrow=TRUE)

## In this matrix rows indicate source room (i.e. first row = room 1; second row = room 2)
## Columns indicate target room (e.g. first column = room 1)
K2

## To obtain frequency of people in 2 rooms after 1 hour, we have to do:
## room1 = 20 * 0.2 + 80 * 0.7 = 4 + 56 = 60
## room2 = 20 * 0.8 + 80 * 0.3 = 16 + 24 = 40
## We can do this conveniently with matrix multiplication
state2 %*% K2

## Lets trace number of people in room 1 by saving the frequency to a vector room1
## First we will save initial state (first element of state2)
room1 <- state2[1]

## Now lets update the state with K2 and save the result as additional element of room1 vector
## We repeat the process 20 times
for(i in 1:20){
  ## We calculate the state after 1 hour and save it to the same variable
  state2 <- state2 %*% K2
  ## We add frequency of people in room 1 at the current state (state2[1]) to our trace (room1)
  room1 <- c(room1, state2[1])
}

## Lets plot trace of changes of number of people in room 1
plot(room1, type = 'l', lwd=2, col='red', xlab='Iterations')

## The last obtained value is:
round(room1[21])

## Here is a cool thing: Try changing the inital proportion to something else than (20, 80), but let the total number sum to 1
## Go back to line 7, change the values (run the line). Then run lines: 30, 34, 42, and 45.

## The next example is just to show you, that this also applies to situations with more states: say 3 rooms

## Imagine you go to a store with 3 departments: food, clothing, and home. 
## Initially all customers (250 in total) start in food dept.
store3 <- c(250, 0, 0)

## After fixed amount of time 50% of them moves to clothing, 30% goes to home, and 20% stays at food dept.
## If there were any people in clothing dept., after fixed amount of time 30% would move to food, 60% would move to home, and 10% would stay in clothing dept.
## Finally, if there were in home dept., after fixed amount of time 40% would move to food, 20% would move to clothing, and 40% would stay in home dept
## See the matrix below, and verify. The trick is here that we keep the transition kernel (the matrix) fixed the whole time
## More importantly, the number in any state depends only on the nearest previous state.
K3 <- matrix(c(0.2, 0.5, 0.3, 
               0.3, 0.1, 0.6, 
               0.4, 0.2, 0.4), 
             ncol=3, byrow=TRUE)

## We store initial frequencies in all departments
food <- store3[1]
cloth <- store3[2]
home <- store3[3]

## Next we update with the same method, but this time we store changes in frequencies among all depts.
for(i in 1:20){
  store3 <- store3 %*% K3
  food <- c(food, store3[1])
  cloth <- c(cloth, store3[2])
  home <- c(home, store3[3])
}

## Lets plot the obtained results
plot(food, type = 'l', lwd=2, col='red', ylim=c(0,250))
lines(cloth, col='blue', lwd=2)
lines(home, col='green', lwd=2)
legend('topright', c('food','clothing','home'), lwd=2, col=c('red','blue','green'))

## What if the store owner changes the arrangement: so that initially people start in clothing dept.?
## Change line 54 appropriately, and then, run lines: 67 to 69, 72, 80 to 83.

## This can have some practical consequences. Knowing people's shopping habits: 
## how long they spend in each department, what is the order of visits during shopping trip,
## can allow us (or store owners) to predict occupancy at different depts., without counting of people at each dept.,
## if we assume that Markov chain process applies

## 2. Metropolis-Hastings algorithm
## This is how properties of Markov process can be applied to run Markov Chain Monte Carlo simulations.
## I.e. to draw a large sample of only weakly correlated values.
## The example is just slightly adopted version from Kruschke DBDA.

## Imagine you are a captain of a pirate ship. YaRrr! You are about to plunder a chain of 7 islands.
## Here is the problem: You don't know how many gold is stored on each of the islands, 
## Moreover, you cannot stay too long on one of the island, because of the Royal Navy.
## Because plundering is time and cost consuming, you want to find a way to do it more efficiently.
## Suppose the the 'true' distribution of gold is:
pop_isl <- c(0, 1000, 3000, 5000, 7000, 9000, 11000, 13000, 0)
names(pop_isl) <- c('sea',paste0('isl.',1:7),'sea')
barplot(pop_isl)

## You don't know the true distribution, but you know the amount of gold on the current island. You can also send scouts the the nearest island.

## Here is what you could do. Imagine you start at island 4 (in the middle). Because we are surrounded by sea (from west and east) the vector position is 5.
position <- 5

## We will trace our position in a captain's log (vector called trace). We first save our initial position.
trace <- position

## Then here is a way how to move through island efficiently.

## First lets run a loop to repeat the same algorithm 5000 times. 
for(i in 1:5000){
  ## First you flip a coin and choose either east or west direction
  flip <- sample(c('west','east'), 1)
  
  ## If you the flip of a coin indicates east...
  if(flip == 'east'){
    ## You set your proposal direction to the current position + 1
    new_island <- position + 1
  ## If the flip of a coin indicates west...
  } else if(flip == 'west') {
    ## You set your proposal direction to the current position + 1
    new_island <- position - 1
  }
  ## You send your scouts to the proposal island.
  ## If the amount of gold on the proposal island is greater than on the current island...
  if(pop_isl[new_island] > pop_isl[position]) {
    ## You immediately set your sails and sail to the proposal island.
    position <- new_island
  ## If the amount of gold on the proposal island is lesser than on the current island...
  } else if(pop_isl[new_island] < pop_isl[position]) {
    ## You are still interested in it, but first you look at the proportion of the gold on the proposal island to the current island.
    proportion <- pop_isl[new_island]/pop_isl[position]
    ## The greater the proportion the more likely is that you will decide to move. 
    ## To make the decision you spin the steering wheel, and see where it stop (a value from 0 to 1).
    random_draw <- runif(1)
    ## If the random draw is less than the proportion...
    if(random_draw < proportion) {
      ## you sail to the proposal island
      position <- new_island
    }
  }
  ## If all of this fail, you decide to stay on an island for a one more day.
  ## In your captain's log you note position on each day.
  trace <- c(trace, position)
}

## Lets plot the intial 100 days, to see the trace more clearly...
plot(trace[1:100]-1, type='l', xlab='Iterations', ylab='Our position')

## Now, lets plot the entire trace...
plot(trace-1, type='l', xlab='Iterations', ylab='Our position')


## Lets look at the history of places we visited...
prop.table(table(trace-1))
## And compare it the proportion of gold on each island
pop_isl[2:8]/sum(pop_isl[2:8])

## This is how famous Metropolis-Hastings algorithm works, i.e. it draws a proposal samples conditional on the current value.
## And then moves to the proposal values with some probability (from 0 to 1).
## Hence, it traces the entire posterior distribution. We can use the trace to summarize the required statistics (mean, std., CI).

## 3. Practical MCMC and questions of convergence

## Recall Markov process and the fact the it required some time to move the stationary value (when the proportions did not change).
## In MCMC language we say that the chain found (converged to) stationary distribution.
## The alogrithm used in modern MCMC tool are almost often guaranteed to converge to stationary distribution.
## When they do MCMC samples can be treated as drawn from the true (posterior) distribution.
## The problem is that we usually don't know when the chain converged, or even whether it has reached convergence state.
## Almost for sure, first draws have not reached convergence. They are usually disregarded (a burnin phase).
## E.g. we drop first 1000 draws.

## How then we test convergence state? We can use tools that actually test against convergence.

library(MCMCpack)
library(bayesplot)

## Looking at trace plot
model <- MCMCregress(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt,
                     burnin = 0, mcmc=100)
mcmc_trace(model)

## Geweke statistic (values more than 2 indicate lack of convergence)
geweke.diag(model)

## Heidelberg and Welch statistic
heidel.diag(model)

## Gelman R statistic
## To use Gelman statistic we need more than 1 chain, usually 2 or 4.
## Here we run 4 identical models. 
## Because R uses pseudo-random number generators, we need to set different seed, for each of them.
## Otherwise we would end with exactly the same simulated values.
## We decrease number of mcmc draws to 20 for explanatory reasons.
modelA <- MCMCregress(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt,
                      seed=1111, burnin = 0, mcmc=20)
modelB <- MCMCregress(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt,
                      seed=2222, burnin = 0, mcmc=20)
modelC <- MCMCregress(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt,
                      seed=3333, burnin = 0, mcmc=20)
modelD <- MCMCregress(bwt ~ age + lwt + as.factor(race) + smoke + ptl + ht + ui + ftv, data=birthwt,
                      seed=4444, burnin = 0, mcmc=20)

## We collect all the models into a single mcmc object.
models <- mcmc.list(modelA, modelB, modelC, modelD)

## R values more than 1.1 indicate lack of convergence.
gelman.diag(models)


## Now try to change burnin and mcmc to some other values. You can also delete both parameters to set the values to the default.

## Now if you find all the values of Gelman R hat statistic below 1.1, you can assume that the chains have converged.
## See traceplots (here we display only one parameters. due to computational diffulty)
mcmc_trace(models, pars=c('age'))

## You can plot the posterior resulting from all chains
mcmc_dens(models)

## Or posteriors from different chains
mcmc_dens_overlay(models)

## You can also summarize value
summary(models)


## A small note about autocorrelation.
## With MCMC we did not draw independent samples. They were correlated. 
## Because of this correlation the 'true' sample size is lower than the nominal sample size.
## With high autocorrelation we may need to increse the nominal sample size to have sufficient level of precision.
## In MCMC jargon we say that with high auto-correlation, the mixing of the chain is slow
## I.e. the chain traverses parameters space slowly.
mcmc_acf(models, pars='age')

## To check the effective sample size for each parameter use.
effectiveSize(models)
## Compare it to your nominal size. As a rule of thumb to obtain 95% credible intervals you should have at least 1000 draws.

