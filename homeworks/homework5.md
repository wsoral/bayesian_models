# Homework 5

In this homework you will perform a very simple Bayesian analysis in R. Later, we will
cover the logic behind Bayesian multiple regression. This homework is just to make
you feel more comfortable with running your own code in R.

1. If you are working with your own computer install R and RStudio (unless you have installed it already).
2. Install package `haven`.
3. Download file *satisf.sav* and load it to R.
4. Install package `MCMCpack` and load it.
5. Create model with MCMCregress function, when you regress variable *overall* on variables: *price*, *numitems*, *org*, *service*, and *quality*. Go to help page and examples if you are not sure how to do this.
6. Install package `bayesplot`.
7. Plot the saved model with mcmc_areas function. Include posterior of all predictor, i.e. include argument: `pars = c('price', 'numitems', 'org', 'service', 'quality')`. Check examples from lab notebooks if you are not sure how to do this.
8. In your homework include:
**a)** your code;
**b)** output from summary function;
**c)** plot with posterior distributions;
**d)** a short description interpretation of the analysis (because in this example all predictors have almost identical variances you can compare importance of each and infer which aspect is the most important predictor of the customer satisfaction)

9. **Optional (additional points)** Instead of using raw R script, you can use R Notebooks - see tutorial [here](http://rmarkdown.rstudio.com/r_notebooks.html). R Notebooks are perfect tool for writing fast reports with reproducible analyses.
