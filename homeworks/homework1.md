# Homework 1 - introduction to probability and Bayes theorem

- Read chapters 2 and 5 from DBDA by Kruschke.
- Do the following exercises after reading chapter 2 (taken from the handbook):

**a)** Suppose we have a four-sided die from a board game. On
a tetrahedral die, each face is an equilateral triangle. When you roll the die, it lands with one face down and the other three faces visible as a three-sided pyramid. The faces are numbered 1-4, with the value of the bottom face printed (as clustered dots) at the bottom edges of all three visible faces. Denote the value of the bottom face as x. Consider the following three mathematical descriptions of the probabilities of x. Model A: p(x) = 1/4. Model B: p(x) = x/10. Model C: p(x) = 12/(25x). For each model, determine the
value of p(x) for each value of x. Describe in words what kind of bias (or lack of bias) is
expressed by each model.

**b)** Suppose we have the tetrahedral die introduced in the previous exercise, along with the three candidate models of the die’s probabilities. Suppose that initially, we are not sure what to believe about the die. On the one hand, the die might be fair, with each face landing with the same probability. On the other hand, the die
might be biased, with the faces that have more dots landing down more often (because
the dots are created by embedding heavy jewels in the die, so that the sides with more
dots are more likely to land on the bottom). On yet another hand, the die might be biased such that more dots on a face make it less likely to land down (because maybe
the dots are bouncy rubber or protrude from the surface). So, initially, our beliefs about
the three models can be described as p(A) = p(B) = p(C) = 1/3. Now we roll the
die 100 times and ind these results: #1’s = 25, #2’s = 25, #3’s = 25, #4’s = 25. Do
these data change our beliefs about the models? Which model now seems most likely?
Suppose when we rolled the die 100 times we found these results: #1’s = 48, #2’s = 24, #3’s = 16, #4’s = 12. Now which model seems most likely?

Please describe and justify.

- Do the following exercise after reading chapter 5 (takien from the handbook):

Consider again the exercise from lab 1 on dating a new person. Suppose now that person may agree or disagree on a date, depending on 1 of 3 situations: s/he is in a relationship, s/he is not in relationship, or *it's complicated*:

```
P(agree | in a relationship) = 0.2

P(agree | not in a relationship) = 0.8

P(agree | it's complicated) = 0.5
```

Furthermore, suppose that prior probabilities are:

```
P(in a relationship) = 0.5

P(not in a relationship) = 0.3

P(it's complicated) = 0.2
```

Now compute, conditional probabilities (posterior) that a person is in a relationship, is not in a relationship, or that *it's complicated* given that the person agreed:

```
P(in a relationship | agree) = ?

P(not in a relationship | agree) = ?

P(it's complicated | agree) = ?
```

Please include your calculations.
