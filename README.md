# neural
Multi-layer neural network in J

Installation
------------

Download and install J at http://www.jsoftware.com

Use
---

load 'neural.ijs'
init ''
learn [number of iterations]

You can use learn to train the neural network using a training set, e.g. X in this code. After training you can use a X2 test to check how well the network performs. 


Parameters
-------------

You can change the following parameters:

L defines the architecture of the nn. The actual values represent the nodes and the number of values the number of layers.
The code has some weighted initialization to prevent exploding / vanishing weights for deep networks, but this hasn't been tested properly.

lambda: Increase lambda to reduce overfitting. 
alpha: change alpha to control learning rate.

Plot
----

plot cfl 
to see the decreasting cost

Data
----
Included data.csv is for testing if everything works only. You can use your own csv but check out the Data section in the code to properly prepare the file.


TODO
----

Future versions will include some auto-optimization functions, checks for bias and variance using cross validation sets and other improvements.

