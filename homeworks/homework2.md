# Homework 2 - infering binomial probability

- Read chapters 4 and 6 from DBDA by Kruschke. Chapter 6 is crucial for doing this assignment. Chapter 4 will increase your understanding of probability distributions.
- This assingment is just a consolidation of exercises that we did during lab 2. 
- Think about a research question of your choice, that you could answer by using beta-binomial model, e.g. how many of your peers engage in a physical activity regularly?
- Try to formulate prior beliefs about the topic and find a distribution that fits your beliefs. Do it manually (lines 9-25 of lab2 notebook) or by using beta distribution (lines 100-117 of lab2 notebook).
- After formulating prior distribution do a short survey - ask at least 10 of your peers the question you choose. Note the responses.
- Calculate posterior probability resulting from your prior beliefs and observed data (lines 56-74 in case of manually assigned priors or lines 122-150 in case of using beta priors)
- Plot both prior and posterior probabilities (lines 85-95 in case of manually assigned priors or lines 133-136 in case of using beta priors) and describe how your beliefs were changed by collecting data.

R hints 1: Don't panic. You can easily do this assignment without any R knowledge. Just read the comment in the lab2.R file and recall steps taken during last lab. Do one step at a time, run the code and see if it works. If not go back, check syntax, and retry. If you encounter any error, it is probably caused by some mispelled commands.
R hints 2: When plotting your results you can change axis labels and plot title by changing values of xlab, ylab, and main parameters.
R hints 3: When you plot your results in RStudio you can easily save your plot by clicking 'Export' at the top of the plotting window. Then
you can save your plot as pdf, as an image (png, jpeg, etc.), or just copy the plot to clipboard and then paste it into your word processor.
