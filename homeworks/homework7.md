# Homework 6

Open `lab9.R` file and load `power.csv` dataset (run lines 8 and 9).
If you encounter problems make sure that `readr` package is installed (if not, install it).
Also make sure that the path to the file is correct.
Run lines 12 and 15 and then lines 74 to 92. This should prepare data for analysis.

Optional: you can also run other lines to learn about Bayes Factor.

The dataset is a part of an experiment, where participants where reminded that
they have no control over the political life in Poland (2 - powerlessness).
In control (1 - baseline) condition they just completed the scales.
DV was endorsement of Jewish conspiracy theory (jc_mean).
Hypothesis was that feelings of powerlessness will increase endorsement of Jewish conspiracy theory.

Run the robust comparison of means from lab8 (model that begins at line 108) and write a short report.

1. Report should be no longer than 2 pages (12 points, Times New Roman, single spaced). Longer reports will not be graded (SERIOUSLY)!
2. Include:

a) Short introduction and description of the study

b) Convergence diagnostics

c) Summary of the results and short interpretation

d) One plot of the results (this can be a boxplot or density plot of the group differences).
The plot should have high quality (at least 300 dpi) - plots with lower quality will result in lower grade.  

3. Try to be as concise as possible.

4. You can use R notebooks, but save them as a PDF, do not include the code.
To swich off code printing include the following chuk at top of the notebook.

```
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)
```
```
