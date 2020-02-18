NB. ==========================================================
NB.
NB.			L-size neural network  
NB. 
NB. ==========================================================
NB. Dimitri Georganas, Biodys BV http://www.biodys.com
NB. ==========================================================

NB. Usage:
NB. 	 load 'neural.ijs'
NB. 	 init ''
NB. 	 learn 1000
NB. 

NB. ==========================================================
NB.			Libraries 
NB. ==========================================================

NB.load 'jmf'
NB.load 'files dir'
NB.load 'data/sqlite'
NB.load 'web/gethttp'
NB.load 'convert/json'
load 'plot'
NB.load 'types/datetime'
load 'tables/csv'

NB.
NB. ==========================================================
NB.			Functions
NB. ==========================================================

u=: (,":)
exp =: (^1)&^
log=: (^1)&^.
tanh=: 7&o.
NB. sigmoid=: 3 : '% (>: ^(-y))'
sigmoid=: %@: (>: @:( ^@:-)) 
rando=:  (<:@+:@?) 
relu=:  >.&0
abs =: + ` - @. (< & 0)
mean=. (+/ % #) 
var=: (+/@(*:@(] - +/ % #)) % #)"1
sdev=:  %:@var"1
deepfix=: *%:@%@#@|:
sumsquare=:  +/@:( +/ @: *:)



NB. ==========================================================
NB.			Data
NB. ==========================================================

NB. TODO cleanup
NB. Use a csv file with X in the first columns and Y in the last column

data=: readcsv 'data.csv'       NB. Assumes vertical feature columns with last column output data x1,x2,x3...y
X=: |: ".  > }. data  	        NB. get rid of the headers and convert into number matrix with horizontally stacked features
Y=: _1{ X               	NB. Y becomes the last row of X
X=: _1}. X              	NB. Remove last row from X keeping only features
Y=: Y> 0.6	           	NB. Set Y labels to 1 when Y>0.8  
Y=: (1, #Y) $, Y        	NB. Convert Y[n] to Y[1 n]


NB. ==========================================================
NB.			Normalization
NB. ==========================================================


mx=: mean"1 X 
sx=: sdev X
X =: (X - mx) % *: sx
m=: 1 { $Y
A0=: X


NB. ==========================================================
NB.			(Hyper) parameters
NB. ==========================================================

NB. Currently only RMSprop optimizatoin is implemented by default in backprop

L=: 3 3 2 1			NB. Architecture, e.g. list of layers and nodes
alpha =: 0.002 			NB. learning rate
decay=: 1.0001                  NB. not used atm
lambda =: 0 			NB. regularization parameter
beta1=: 0.9                     NB. weighted average parameter for momentum  
beta2=: 0.999                   NB. weighted average parameter for rmsprop  

NB. TODO
NB. momentum
NB. mini-batch
NB. etc.

NB. ==========================================================
NB.			Initialize parameters
NB. ==========================================================

NB. Below code dynamically initializes a weight matrix for each layer with random data depending on L, e.g.:
NB. ┌───────────────────────────────┬─────────────────────────────┬──────────────────┐
NB. │_0.0531496   0.38665   0.372245│0.541879 _0.0219465 _0.190633│_0.35982 _0.411843│
NB. │  0.287865 _0.122215   0.461582│0.565735   0.515806 _0.384957│                  │
NB. │ _0.272987  0.392819 _0.0110026│                             │                  │
NB. └───────────────────────────────┴─────────────────────────────┴──────────────────┘

init=: 3 : 0
i=. 1}. i. #L
j=.  i. (#L)-1
index=. i,.j
Wparams=:  deepfix each rando each 0 $ ~ each <"1 index { L
bparams=:    0   $ ~  each      # each Wparams
l=.1


NB. Momentum, RMSprop initialization

while. l < #L-1 do.
('VdW' u l) =: > 0= each (l-1){Wparams
('Vdb' u l) =: > 0= each (l-1){bparams
('SdW' u l) =: > 0= each (l-1){Wparams
('Sdb' u l) =: > 0= each (l-1){bparams


l=. >:l
end.



Wparams
)

NB. ===========================================================
NB.			Forward propagation
NB. ===========================================================

forwardprop =: monad define
l=.1
A0=.y
maxL=. #L
while. l <: (maxL-1) do.
        ('Zca' u l)=: ] ('Z' u l)=:  (]('bca' u l)=: >(l-1){bparams) +  (]('Wca' u l)=:   >(l-1){Wparams) +/ . * ".('A' u (l-1)) 
	 
	('Aca' u l)=:  ] ('A' u l)=:  relu`sigmoid @. (l=maxL-1)  ".('Z' u l) 
    	l=.l+1
end.

)

NB. ==========================================================
NB.			Cost function
NB. ==========================================================

costfunction =: monad define
AL=.y
cf=: - m % ~ +/ |: ( Y*log AL)      +  (1-Y) *    log (1-AL)
L2=. (2*m) %~ lambda * +/ > sumsquare each Wparams
cf=: cf+L2
)

NB. ==========================================================
NB.			Backward propagation
NB. ==========================================================

backwardprop =: monad define
maxL=. #L
l=. maxL-1

('dZ' u l )  =: m % ~ (". 'A' u l ) - Y
while. l > 0 do.

NB. ==========================================================
NB.			basic backprop
NB. ==========================================================

('dW' u l )  =:   ((". 'dZ' u l ) +/ . * (|: ". 'A' u (l-1) ) ) + (m % ~ lambda * > (l-1) {Wparams)
('db' u l )  =:  +/"1 (". 'dZ' u l )

NB. ==========================================================
NB.			momentum optimzation
NB. ==========================================================

NB. ('VdW' u l ) =:   ((1-beta1) * (". 'dW' u l)) + beta1 * (". 'VdW' u l)
NB.  ('Vdb' u l ) =:  ((1-beta1) * (". 'db' u l)) + beta1 * (". 'Vdb' u l)

NB. ==========================================================
NB.			RMSprop optimization
NB. ==========================================================

('SdW' u l ) =:  ((1-beta2) * (*: ". 'dW' u l)) + beta2 * (". 'SdW' u l)
('Sdb' u l ) =: ((1-beta2) * (*: ". 'db' u l)) + beta2 * (". 'Sdb' u l)

NB. ==========================================================
NB.			update w/ rmsprop
NB. ==========================================================

Wparams=: (<((>(l-1){ Wparams) -((% %: ". 'SdW' u l)  * alpha * ". 'dW' u l))) (l-1) } Wparams
bparams=: (<((>(l-1){ bparams) -((% %: ". 'Sdb' u l) * alpha *  ". 'db' u l))) (l-1) } bparams

NB. ==========================================================
NB.			update w/ momentum
NB. ==========================================================

NB. Wparams=: (<((>(l-1){ Wparams) -(alpha * ". 'VdW' u l))) (l-1) } Wparams
NB. bparams=: (<((>(l-1){ bparams) -(alpha *  ". 'Vdb' u l))) (l-1) } bparams

NB. ==========================================================
NB.			update basic
NB. ==========================================================
NB. Wparams=: (<((>(l-1){ Wparams) -(alpha * ". 'dW' u l))) (l-1) } Wparams
NB. bparams=: (<((>(l-1){ bparams) -(alpha *  ". 'db' u l))) (l-1) } bparams

l=. <: l

if. l > 0 do. 
    ('dZ' u l )  =: ((|: ". 'Wca' u (l+1)) +/ . *  (". 'dZ' u (l+1))) * 0<: (". 'Zca' u l)  
end.

end.
)

NB. ==========================================================
NB.			Grad check
NB. ==========================================================

NB. TODO

checkbackprop=: 3 : 0
vec=: tmp  {~  I. ( =&0@=&0) ] tmp =. ><,>,"0 each Wparams
)

NB. ==========================================================
NB.			Learn
NB. ==========================================================


learn =: monad define
counter=.y
maxL=.#L-1
cfl=:0
while. counter > 0 do.
counter =. <: counter
forwardprop X
costfunction ". ('A' u maxL-1) 
cfl=: cfl,cf
backwardprop '' 
smoutput cf
end.
)

