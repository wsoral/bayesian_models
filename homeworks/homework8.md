# Homework 8

Load the dataset `satAct.csv` to your working environment. Use:

```
sat.act <- read.csv('path/to/the/file')
# if the dataset is in your main directory use:
sat.act <- read.csv('satAct.csv')
```

The data set includes 3 different measures of ability. We are interested in 2:
ACT (a test used for college selection) and SATQ (self reported quantitive abilities).

We are interested whether we can predict ACT score on the basis of self-described abilities.

- Look at the scatterplot with fitted regression line. Decide whether you would like to use basic or robust regression model.
- Model ACT score as a function of SATQ with JAGS. Just to recall here is how you create jags.dataset

```
jags.data <- list(y=sat.act$ACT, x=sat.act$SATQ)
```

- If you decide to use robust model, be patient - it may take several minutes to fit (depending on the power of your PC).
- Describe the results: how you would interpret the intercept, slope, and sigma (remember about including measures of uncertainty such as CI)
- Write a short report (look for guides in `homework7`)
