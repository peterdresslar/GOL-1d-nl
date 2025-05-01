;; 1d-Life.nlogo

;; In this model, we entirely focus on the 1 dimensional model and are indifferent to the 2d mapping.
;; "Infinite" is refers to the lack of any bounding of a state array, though of course we can only compute on a finite
;; grid in NetLogo.
;; Our model updates deterministically from any starting state and lambda: note that we must have a starting state and
;; note also that many starting states are boring.

;; If we consider the model independent of any other dimensionality, we might see lambda as a frequency parameter. The rules are
;; effectively "tuned" to lambda. Changing lambda while the model is running will cause durable patterns to change,
;; and new patterns to emerge in a manner not entirely unlike the mechanism of resonance.

;; We might also consider that the "known primitives" of game of life can be described here, in one dimension, using integer
;; positions and lambda. The two setup-test procedures illustrate simple gliders that are examples of this.

;;;; HOUSEKEEPING

globals [
  erasing?     ;; 1d state of the grid, could get pretty big.
]

patches-own [
  living?         ;; indicates if the cell is living
  live-neighbors
]


;;;; INITIALIZERS

to setup-blank
  clear-all

  __change-topology wrap? wrap? ;;; control whether wrapping is on

  ask patches [ cell-death ]

  reset-ticks
end



to setup-random
  clear-all

  __change-topology wrap? wrap? ;;; control whether wrapping is on

  ask patches
    [ ifelse random-float 100.0 < initial-density
      [ cell-birth ]
      [ cell-death ] ]
  reset-ticks
end

to setup-test   ;;; just some arbitary gliders, this could be made more fun.
  setup-blank

  let glider1 patch 667 0
  ask glider1 [
      cell-birth
      ask patch-at (lambda + 1) 0 [ cell-birth ]
      ask patch-at (lambda + lambda - 1) 0 [ cell-birth ]
      ask patch-at (lambda + lambda) 0 [ cell-birth ]
      ask patch-at (lambda + lambda + 1) 0 [ cell-birth ]
  ]

  let glider11 patch 333 0
  ask glider11 [
      cell-birth
      ask patch-at (lambda + 1) 0 [ cell-birth ]
      ask patch-at (lambda + lambda - 1) 0 [ cell-birth ]
      ask patch-at (lambda + lambda) 0 [ cell-birth ]
      ask patch-at (lambda + lambda + 1) 0 [ cell-birth ]
  ]

  reset-ticks

end

to setup-alt-test ;; just flip the other test. elegance, it is not
  setup-blank

  let glider1 patch 667 0
  ask glider1 [
      cell-birth
      ask patch-at (-1 * (lambda + 1)) 0 [ cell-birth ]
      ask patch-at (-1 * (lambda + lambda - 1)) 0 [ cell-birth ]
      ask patch-at (-1 * (lambda + lambda)) 0 [ cell-birth ]
      ask patch-at (-1 * (lambda + lambda + 1)) 0 [ cell-birth ]
  ]

  let glider11 patch 333 0
  ask glider11 [
      cell-birth
      ask patch-at (-1 * (lambda + 1)) 0 [ cell-birth ]
      ask patch-at (-1 * (lambda + lambda - 1)) 0 [ cell-birth ]
      ask patch-at (-1 * (lambda + lambda)) 0 [ cell-birth ]
      ask patch-at (-1 * (lambda + lambda + 1)) 0 [ cell-birth ]
  ]
  reset-ticks

end


to draw-cells
  ifelse mouse-down? [
    if erasing? = 0 [
      set erasing? [living?] of patch mouse-xcor mouse-ycor
    ]
    ask patch mouse-xcor mouse-ycor [
      ifelse erasing? [
        cell-death
      ] [
        cell-birth
      ]
    ]
    display
  ] [
    set erasing? 0
  ]

end

to cell-birth   ;;; from the base model
  set living? true
  set pcolor fgcolor
end

to cell-death   ;;; from the base model
  set living? false
  set pcolor bgcolor
end

to go
  ask patches
    [ set live-neighbors evaluate-neighbors ]

  if log-evals? [
    ask patches with [living?] [
      output-print(word pxcor " " pycor " " live-neighbors)
    ]
  ]

  ;; Starting a new "ask patches" here ensures that all the patches
  ;; finish executing the first ask before any of them start executing
  ;; the second ask.  This keeps all the patches in synch with each other,
  ;; so the births and deaths at each generation all happen in lockstep.
  ask patches
    [ ifelse live-neighbors = 3
      [ cell-birth ]
      [ if live-neighbors != 2
        [ cell-death ] ] ]
  tick
end

to-report evaluate-neighbors
  ;; count neighbors with [living?]
  let curr-neighbors (patch-set
    ;; patch-at is east, north
    patch-at (-1 * (lambda + 1)) 0   ;; 7
    patch-at (-1 * lambda) 0        ;; 8
    patch-at (-1 * (lambda - 1 )) 0   ;; 9
    patch-at -1 0 ;; 4
    patch-at 1 0 ;; 6
    patch-at (lambda - 1) 0 ;; 1
    patch-at lambda 0 ;; 2
    patch-at (lambda + 1) 0 ;; 3
    )

  report count curr-neighbors with [living?]
end





; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
122
31
20532
42
-1
-1
2.0
1
10
1
1
1
0
1
1
1
0
10200
0
0
0
0
1
ticks
15.0

SLIDER
122
69
281
102
initial-density
initial-density
0.0
100.0
35.0
0.1
1
%
HORIZONTAL

BUTTON
11
68
113
101
NIL
setup-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
234
115
269
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
12
272
115
310
go-forever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
1959
268
2114
301
recolor
ifelse living?\n  [ set pcolor fgcolor ]\n  [ set pcolor bgcolor ]
NIL
1
T
PATCH
NIL
NIL
NIL
NIL
0

BUTTON
11
32
113
65
NIL
setup-blank
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
120
316
279
414
When this button is down,\nyou can add or remove\ncells by holding down\nthe mouse button\nand \"drawing\". 
11
0.0
0

BUTTON
11
316
114
351
NIL
draw-cells
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1959
301
2114
361
fgcolor
11.0
1
0
Color

INPUTBOX
1959
363
2114
423
bgcolor
79.0
1
0
Color

BUTTON
12
105
114
138
NIL
setup-test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1973
238
2123
266
From the original model: (with new border-color)
11
0.0
1

MONITOR
1122
121
1180
166
density
count patches with  [living?] / count patches
4
1
11

SLIDER
1059
65
1231
98
lambda
lambda
2
101
47.0
1
1
NIL
HORIZONTAL

SWITCH
11
439
112
472
log-evals?
log-evals?
1
1
-1000

BUTTON
12
142
114
176
NIL
setup-alt-test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
122
119
288
161
Tests will move quickly: try setting sim speed to \"slower.\" Get ready to scroll...
11
0.0
1

SWITCH
12
403
113
436
wrap?
wrap?
0
1
-1000

TEXTBOX
9698
174
9848
192
this space needs an XKCD
11
0.0
1

TEXTBOX
20048
51
20546
107
The \"Life\" model has, by default, 10201 cells. And so, this 1-dimensional version does also.
11
0.0
1

BUTTON
203
209
295
242
NIL
load-tape
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This program is an example of a one-dimensional cellular automaton (1D-CA or CA). This particular CA was built as a 1D conversion of the well-known and elegantly-designed "Life" NetLogo model, itself based upon Conwayʻs Game of Life. Herein, we will keep some of the comments from the base model, and designate them with a >"comment" format, like as follows:

>"A cellular automaton is a computational machine that performs actions based on certain rules.  It can be thought of as a board which is divided into cells (such as square cells of a checkerboard).  Each cell can be either "alive" or "dead."  This is called the "state" of the cell.  According to specified rules, each cell will be alive or dead at the next time step."

While the original version of Life operates on two dimensions, using the standard NetLogo cartesian coordinate system, this version has compressed the basic rules that govern Life into ones that can operate on a one-dimensional system. It turns out that the rules themselves, or, the actual predicate algebra (listed below) work precisely the same in 1, 2, or likely any N dimensions. However, the way we assess the state of the one-dimensional version in order to feed data *into* the rules differs. Specifically, GOL rules require inputs from neighboring cells to operate on any given cell, and with our altered dimensionality the definition of neighboring changes.

In another version of this model, we demonstrate a simple method of mapping from a finite two dimensional-grid to a one-dimensional array, and then we demonstrate the conversion of the neighbors into a function that uses both the side length (n) and the squared size (N) of the 2D grid to yield algebra for conversion to the 1D model. However, it can be observed in that model that the 1D model, once set up in this fashion, operates entirely independently from the two-dimensional version. In other words, it should be possible to operate the 1D version in a manner that ignores any other dimensionality.

For this implementation, we say that we operate indifferently to the 2D version of the CA. Through this indifference, our need for the mapping parameter N (the square of the grid) is lifted. However, we still need a mechanism to define "neighbors" in our rules. We do this by converting our "side length" into a simple adjustable parameter, "lambda."

Lamba works as a frequency "tuner" for the implementation, controlling the "spaced-ness" of the patterns and their operation on each other. Lambda must be set at the integer 2 or higher in order for the rules to operate as expected.

We call this model "infinite" as there is no effective limit on the state to the left or right of the model other than screen size. This is specifically distinct from the alternate version of the model where we map cells back to two dimensions: with that need comes the constraint of having specific state frames.

For contrast, this model could be set to be as "wide" as technology will allow. By default the model is set to have "wrapping" off--in this way, when patterns "read" the edge of the screen they encounter inactive, "dead" neighbors and nothing else. With wrapping on, motion will take place across the boundary from left to right or vice-versa. 

## HOW IT WORKS

>"The rules of the game are as follows.  Each cell checks the state of itself and its eight surrounding neighbors and then sets itself to either alive or dead.  If there are less than two alive neighbors, then the cell dies.  If there are more than three alive neighbors, the cell dies.  If there are 2 alive neighbors, the cell remains in the state it is in.  If there are exactly three alive neighbors, the cell becomes alive. This is done in parallel and continues forever."

In this version of the model, again, the rules are exactly the same, except that the location of the neighbors is set using lambda.

>"There are certain recurring shapes in Life, for example, the "glider" and the "blinker". The glider is composed of 5 cells which form a small arrow-headed shape, like this:

```text
   O
    O
  OOO
```

This glider will wiggle across the world, retaining its shape.  A blinker is a block of three cells (either up and down or left and right) that rotates between horizontal and vertical orientations."

In this version of the model, these patterns do still exist, and can persist and move across the world analogously to how they do in two dimensions. They may not look as apparent to the observer, but they are there.

## HOW TO USE IT

>"The INITIAL-DENSITY slider determines the initial density of cells that are alive.  SETUP-RANDOM places these cells.  GO-FOREVER runs the rule forever.  GO-ONCE runs the rule once.

If you want to draw your own pattern, use the DRAW-CELLS button and then use the mouse to "draw" and "erase" in the view."

These controls work the same in this version. Try zooming in if you are drawing cells.

Also available are the SETUP-TEST and SETUP-ALT-TEST buttons, which each set up a few simple glider patterns that should work to process across the screen. An excellent way to understand what is going on is to adjust the LAMBDA slider a few times and try clicking and executing one of these SETUP-TEST buttons after doing so.

## THINGS TO NOTICE

> "Find some objects that are alive, but motionless.

Is there a "critical density" - one at which all change and motion stops/eternal motion begins?"

## THINGS TO TRY

Here we will point out that one of the best things to try is to run this version and the base "Life" version side by side and to compare results.

## EXTENDING THE MODEL

We have extended the model already, thank you.

N-D?

## NETLOGO FEATURES

Note that the grid is setup with the Settings... button. Changes may or may not work.

## RELATED MODELS

Life Turtle-Based --- same as this, but implemented using turtles instead of patches, for a more attractive display
CA 1D Elementary --- a model that shows all 256 possible simple 1D cellular automata
CA 1D Totalistic --- a model that shows all 2,187 possible 1D 3-color totalistic cellular automata
CA 1D Rule 30 --- the basic rule 30 model
CA 1D Rule 30 Turtle --- the basic rule 30 model implemented using turtles
CA 1D Rule 90 --- the basic rule 90 model
CA 1D Rule 110 --- the basic rule 110 model
CA 1D Rule 250 --- the basic rule 250 model

## CREDITS AND REFERENCES

>" The Game of Life was invented by John Horton Conway.

See also:

Von Neumann, J. and Burks, A. W., Eds, 1966. Theory of Self-Reproducing Automata. University of Illinois Press, Champaign, IL.

"LifeLine: A Quarterly Newsletter for Enthusiasts of John Conway's Game of Life", nos. 1-11, 1971-1973.

Martin Gardner, "Mathematical Games: The fantastic combinations of John Conway's new solitaire game `life',", Scientific American, October, 1970, pp. 120-123.

Martin Gardner, "Mathematical Games: On cellular automata, self-reproduction, the Garden of Eden, and the game `life',", Scientific American, February, 1971, pp. 112-117.

Berlekamp, Conway, and Guy, Winning Ways for your Mathematical Plays, Academic Press: New York, 1982.

William Poundstone, The Recursive Universe, William Morrow: New York, 1985."

## HOW TO CITE

> "If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Life model.  http://ccl.northwestern.edu/netlogo/models/Life.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL."

And I am Peter Dresslar:

* Dresslar, P. (2025). Netlogo 1d-Life model. https://github.com/peterdresslar/GOL-1d-nl

## COPYRIGHT AND LICENSE

Copyright 1998, 2025 Uri Wilensky and Peter Dresslar

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2025 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="base" repetitions="2" runMetricsEveryStep="true">
    <setup>setup-random</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>count patches with [living?] / count patches</metric>
    <enumeratedValueSet variable="initial-density">
      <value value="33.33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wrap?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1DLifeDensityWideSweep (wrapping ON)" repetitions="50" runMetricsEveryStep="true">
    <setup>setup-random</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count patches with [living?] / count patches</metric>
    <enumeratedValueSet variable="initial-density">
      <value value="5"/>
      <value value="15"/>
      <value value="25"/>
      <value value="35"/>
      <value value="45"/>
      <value value="55"/>
      <value value="65"/>
      <value value="75"/>
      <value value="85"/>
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wrap?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1DLifeDensityWideSweep (wrapping OFF)" repetitions="50" runMetricsEveryStep="true">
    <setup>setup-random</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count patches with [living?] / count patches</metric>
    <enumeratedValueSet variable="initial-density">
      <value value="5"/>
      <value value="15"/>
      <value value="25"/>
      <value value="35"/>
      <value value="45"/>
      <value value="55"/>
      <value value="65"/>
      <value value="75"/>
      <value value="85"/>
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wrap?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
