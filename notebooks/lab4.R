## Lab 4 - working with R

## 1. A brief look at RStudio

## 2. Getting help

# Write function name preceded by ? to view help page for the function
?lm

# Write topic name preceded by ?? to search for functions
??regression

# If top name consists of more than one word, use ``
??`factor analysis`

# Most functions have examples, that will help you understand how they work
example(lm)

# Using tab completion and quick lookup
# Move cursor to the line below and hit TAB key
fa

## 3. Using packages

# Before the first use a new package has to be installed (i.e. downloaded and copied into library directory)

# We will install package called psych - useful tool for psychometrics
install.packages('psych')
# We will also install package haven - for importing SPSS data files
install.packages('haven')
# Finally we will install ggplot2 package - for nicer plots
install.packages('ggplot2')

# If you want to use a function of a package, the package has to be first loaded
library(haven)

# Alternatively you can precede the name of the function by package name and :: sign
psych::alpha()

## 4. Importing data
# R can import from a wide variety of sources. Because of SPSS popularity among psychologists we will work with SPSS data files

# You can use haven::read_sav to import SPSS data files, you can enter the path to a file (TAB completion should help)
haven::read_sas(file = "path/to/a/file")

# or use interactive browser
haven::read_sav(file = file.choose())

# with RStudio it is even simples
# go to File -> Import Dataset -> From SPSS...

## 5. First look at the data

# You can print specific variable from the dataset by using $ operator.
# Move cursor to the line below enter the name of one of the variables or hit TAB to select (with arrow from the list)
movie_data$EA2

# You can also select the variable by the index of its column
movie_data[,2]

# Or you can select more than one variable by specfing range of columns (e.g. 2:5 = columns 2, 3, 4, 5)
movie_data[,2:5]

# We know that variable Film is categorical variable. To help in further analyses we will change it to factor type
# Read the command below from right to left.
# a. we pick Film variable from movie_data dataset
# b. we use as_factor function on the variable
# c. we save (<- sign) the resulting new variable into the old one
movie_data$Film <- as_factor(movie_data$Film)

# Check how the variable changed in View
  
# Ensure that you have loaded the psych package
library(psych)

# Basic descriptive statistics 
describe(movie_data)

# Basic descriptive statistics by moview
describeBy(movie_data[,2:5], group = movie_data$Film)

# Zero-order correlations
corr.test(movie_data[,2:5])

# 6. Graphical inspection is always faster
library(ggplot2)

# x - put here the name of the variable plotted on x-axis
# y - put here the name of the variable plotted on y-axis
# data - put here the name of the dataset
# geom - put here the name of the drawing function (use ??geom to print all drawing functions in ggplot2)

# Drawing a simple histogram
qplot(x=EA2, data=movie_data, geom='histogram')

# Drawing a boxplot
qplot(x=Film, y=EA2, data=movie_data, geom = 'boxplot')

# Drawing a scatterplot
qplot(x=EA2, y=TA2, data=movie_data, geom = 'point')

# Drawing a scatterplot with fitted loess line
qplot(x=EA2, y=TA2, data=movie_data, geom = c('point', 'smooth'))

# Drawing a scatterplot with fitted linear regression line
qplot(x=EA2, y=TA2, data=movie_data, geom = c('point', 'smooth'), method='lm')

# You can change label names easily, see below example

qplot(x=EA2, y=TA2, data=movie_data, geom = c('point', 'smooth'), method='lm',
      xlab = "Energetic arousal",
      ylab = "Tense arousal",
      main = "Scatterplot of variables")

# You can do a lot more with ggplot2. Below I have divided data by film (facets argument),
# I have added some additional descriptions, and changed the look of the plot a little
qplot(x=EA2, y=TA2, data=movie_data,facets = ~Film, geom = c('point', 'smooth'), method='lm',
      xlab = "Energetic arousal",
      ylab = "Tense arousal",
      main = "Scatterplot of variables")+
  labs(subtitle="with fitted regression lines", caption="for course Bayesian Models in Psychology")+
  theme_bw()

# You can save the plot by using Export button, or by using function for saving ggplot2 plots
ggsave(filename = 'nicePlot.tiff', device = 'tiff', width = 8, height = 6, dpi = 300)

# There is a plenty of tutorial showing how to plot with ggplot2. Just google ggplo2 tutorial

# 7. Simple (frequentist) statistical procedures

# You can run ANOVA models with aov; there are however some complexities when group size are not equal
# Use afex package if you want to run on data from psychological experiments

# We run ANOVA model and save it into model1 variable
model1 <- aov(EA2 ~ Film, data=movie_data)

# We print the summary of the model
summary(model1)

# W can print post-hocs, e.g. Tukey HSD
TukeyHSD(model1)

# or some other corrections
pairwise.t.test(x=movie_data$EA2, g=movie_data$Film)


# You can run simple or multiple regression with lm
model2 <- lm(EA2 ~ TA2 + PA2 + NA2, data=movie_data)

sqrt(car::vif(model2))

# and print model summary
summary(model2)

# or plot some simple regression diagnostics
plot(model2)


# 8. Bayesian statistical procedures - for those who want to dive into Bayesian statistics quickly
# MCMCpack is a package that allows to fit both basic and advanced Bayesian models
# we will present the logic behind the analyses later

# We will install and load MCMCpack
install.packages('MCMCpack')
library(MCMCpack)

# We fit bayesian regression, note how similar it is to non-bayesian way
# Here we use uninformative priors (be sure to always check how the priors are set by default)
posterior1 <- MCMCregress(EA2 ~ TA2 + PA2 + NA2, data=movie_data)

# We can print the summary statistics
summary(posterior1)
# Compare with frequentist results

# and plot the distributions
plot(posterior1, trace = FALSE)



# Here we put prior on beta coefficient (intercept + 3 predictors)
# We put a mean of zero on each beta coefficient - b0
# We put very small precision (large variance) on prior for intercept
# We put large precision (low variance) on prior for predictors

# Beside substantive reasons putting such large precision on prior for predictors
# can be used as a more conservative test of their importance
# It can also solve problems with multicollinearity
posterior2 <- MCMCregress(EA2 ~ TA2 + PA2 + NA2, data=movie_data,
                          b0=c(0, 0, 0, 0), B0 = c(0, 100, 100, 100))


summary(posterior2)

plot(posterior2, trace = FALSE)
