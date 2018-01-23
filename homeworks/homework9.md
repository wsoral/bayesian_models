# Homework 9

In this homework you will analyze data collected by your teacher ;-).

An online experiment was conducted to check how behavioral helplessness training (BHT) affects
a very basic perception of relation between one's action and it's outcomes.
Quite novel findings suggest that experienced times of one's own action and it's sensory consequences
are attracted together - this is known as intentional binding and it is a mechanism
which is probably responsible for the sense of agency and selfefficacy.

Take a look at this short article where intentional binding was measured in similar manner as in the current study:
<a href="https://s3.amazonaws.com/academia.edu.documents/34952342/Effort.pdf?AWSAccessKeyId=AKIAIWOWYYGZ2Y53UL3A&Expires=1516109489&Signature=92Sw6xLEATOTNCcCvseyoq4Oa5Q%3D&response-content-disposition=inline%3B%20filename%3DPower_to_the_will_How_exerting_physical.pdf">link require having a free account on academia.edu</a>

In the study, intentional binding effects were measured among participants after BHT of different lengths
(3 conditions: 1. no BHT vs. 2. short - 2 trials - BHT vs. 3. long - 6 trials - BHT).

Different literature reviews suggest that control deprivation instigated by the BHT may lead both to decrease and/or increase in the sense of agency.
To know more about BHT check this article (specifically Study 2):
<a href="https://s3.amazonaws.com/academia.edu.documents/39661525/Limits_of_control_The_effects_of_uncontr20151103-15959-nsl5zg.pdf?AWSAccessKeyId=AKIAIWOWYYGZ2Y53UL3A&Expires=1516109661&Signature=TV6KDdq902W6EDpFbd7qm%2Bvthyk%3D&response-content-disposition=inline%3B%20filename%3DLimits_of_control_the_effects_of_uncontr.pdf">link require having a free account on academia.edu</a>

*Check how the scores of intentional binding differ between 3 experimental conditions. Higher scores
are interpreted as more sense of agency (more bias), while scores near 0 are interpreted as less sense of agency (more accurate perception).*

In order to load data into RStudio run this command:

```
homework <- read.csv('https://raw.githubusercontent.com/wsoral/bayesian_models/master/homeworks/homework9.csv')
```

Perform Bayesian ANOVA, and check the differences in the scores of intentional
binding between conditions. Use as many contrasts as you feel are necessary to understand
the data.

Write a short report describing the result of your analyses.

1. Report should be no longer than 2 pages (12 points, Times New Roman, single spaced). Longer reports will not be graded (SERIOUSLY)!
2. Include: a) Short introduction and description of the study; b) Convergence diagnostics; c) Summary of the results and short interpretation; d) One plot of the results (this can be a boxplot or density plot of the group differences).
The plot should have high quality (at least 300 dpi) - plots with lower quality will result in lower grade.  

3. Try to be as concise as possible, but include all the necessary information.
