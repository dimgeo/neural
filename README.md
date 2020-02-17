# neural
Multi-layer neural network in J

Installation
============

Download and install J at http://www.jsoftware.com

Use
===

load 'neural.ijs'
init ''
learn [number of iterations]


Modifications
-------------

L defines the architecture of the nn. The actual values represent the nodes and the number of values the number of layers.
The code has some weighted initialization to prevent exploding / vanishing weights, but it hasn't been tested thoroughly

lambda: Change lambda to tweak regularization to reduce overfitting. 
alpha: change alpha to control learning rate


Plot
----

plot cfl 

This will show deminishing cost function error

Data
====
Included data is for testing only. You can use your own csv but check out the Data section in the code to properly prepare the file.




