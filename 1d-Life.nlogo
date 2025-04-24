;; I've wound up rather re-writing the model due to the 2D -> 1D -> 2D processing.


;; fundamentally: 1D GOL takes the 2D finite domain and maps it to a 1D tape.
;; Assuming a 2D finite domain bounded by sides n and n, the 1D tape length is of course n*n,
;; which we will call N.

;; we should specific that we (arbitrarily) perform the mapping of the 1D state to the 2D state
;; in the order of left to right, top to bottom.




;; for convenience, letʻs use "keypad" style coordinates when referring to the 2D neighbors.
;; the neighbors are:
;; 7 8 9
;; 4 5 6
;; 1 2 3
;; where 5 is actually the prior state.

;; Let `s` be the index (0 to N-1) of the cell being processed for the current time step `t`.
;; N = n*n is the total number of cells (grid-size * grid-size).
;; We use two state lists: `S` (current state, corresponds to `one-d-state`) and `S_prev` (previous state, corresponds to `prev-one-d-state`).
;; The state for cell `s` at time `t`, `s[t]`, is calculated based on values from `s[t-1]`.

;; To calculate s[t], we need the state of cell `s` at time `t-1` (s[t-1]) and the states of its 8 neighbors at time `t-1` (Neighbors(t-1)).
;; s[t-1] is simply the value at index `s` in the previous state list:
;; s[t-1] = S_prev[s_idx] (equates to s-N)

;; The indices for the 8 neighbors in S_prev, relative to `s`, are calculated using the grid-side dimension `n` and the grid-size `N`
;; and wrapped using modulo `N`.
;; We use `(index + N) mod N` to handle potential negative results (off tape low or high) correctly.
;; Keypad indices map to S_prev indices as follows:
;; 7: (s - n - 1 + N) mod N
;; 8: (s - n + N) mod N
;; 9: (s - n + 1 + N) mod N
;; 4: (s - 1 + N) mod N
;; 6: (s + 1 + N) mod N
;; 1: (s + n - 1 + N) mod N
;; 2: (s + n + N) mod N
;; 3: (s + n + 1 + N) mod N

;; Neighbors(t-1) is the sum of the values in S_prev at these 8 neighbor indices.
;; Neighbors(t-1) = (item ((s-n-1+N) mod N) S_prev) + (item ((s-n+N) mod N) S_prev) + ... + (item ((s+n+1+N) mod N) S_prev)

;; and then adopting the rules of Conway's Game of Life:
;; s[t] = 1 if (s[t-1] = 1 and Neighbors(t-1) is 2 or 3) or (s[t-1] = 0 and Neighbors(t-1) = 3)
;; s[t] = 0 otherwise.


;;;; HOUSEKEEPING

globals [
  erasing?        ;; from the base model. used to toggle erasing mode--not sure if we can keep this.
  grid-side       ;; how to make this work with GRAPHICS-WINDOW?
  grid-squared    ;; grid-side * grid-side
  current-state     ;; 1d state of the grid, could get pretty big.
  previous-state    ;; 1d state of the grid, could get pretty big.
  current-1d-position     ;; current place in the tape
  current-density   ;; for reporting, will be taken from state
]

patches-own [
  living?         ;; indicates if the cell is living
  is-1d-cell      ;; PDD: Is this patch part of the 1d grid?
  is-border-cell  ;; PDD: Is this patch a border cell?
  mapping   ;; should not need it!
]


;;;; INITIALIZERS

to setup-blank
  clear-all

  set grid-side 101  ;; n
  set grid-squared (grid-side * grid-side) ;; N
  ask patches [ cell-death ]

  setup-border

  ;; here we will convert the base model procedure to our terms; initalize the 1d state and then
  ;; update 2d based on 1d statae

  set current-state []
  set previous-state []

  set current-state (n-values grid-squared [0])
  set previous-state (n-values grid-squared [0])

  set current-1d-position grid-squared

  map-patches

  update-1d-patches
  update-2d-patches

  ;; set current density by summing current-state and dividing by grid-squared
  set current-density (sum current-state / grid-squared)

  reset-ticks
end



to setup-random
  clear-all

  set grid-side 101  ;; n
  set grid-squared (grid-side * grid-side) ;; N

  ask patches [ cell-death ]

  setup-border

  ;; here we will convert the base model procedure to our terms; initalize the 1d state and then
  ;; update 2d based on 1d statae

  set current-state []
  set previous-state []

  set current-state n-values grid-squared [
    ifelse-value (random-float 100.0 < initial-density) [ 1 ] [ 0 ]
  ]
  set previous-state (n-values grid-squared [0])

  set current-1d-position grid-squared

  output-print current-state
  ;; output-print previous-state

  map-patches

  update-1d-patches
  update-2d-patches

  ;; set current density by summing current-state and dividing by grid-squared
  set current-density (sum current-state / grid-squared)

  reset-ticks
end

to setup-test   ;;; just some arbitary gliders, this could be made more fun.
  setup-blank
  let glider1 floor(grid-squared / 2)
  let glider2 glider1 + grid-side + 1
  let glider3 glider1 + grid-side + grid-side - 1
  let glider4 glider1 + grid-side + grid-side
  let glider5 glider1 + grid-side + grid-side + 1
  ;; "parity" bits
  let glider6 grid-squared - 2
  let glider7 2

  let glider11 glider1 - 1234
  let glider12 glider11 + grid-side + 1
  let glider13 glider11 + grid-side + grid-side - 1
  let glider14 glider11 + grid-side + grid-side
  let glider15 glider11 + grid-side + grid-side + 1

  let glider-coords (list glider1 glider2 glider3 glider4 glider5 glider6 glider7 glider11 glider12 glider13 glider14 glider15)


  ;; update the current-state using glider-list as indices to set to 1
  foreach glider-coords [ idx ->
    output-print idx
    set current-state replace-item idx current-state 1
  ]
  output-print current-state
  update-1d-patches
  update-2d-patches

end

to setup-border
  ask patches [
    set is-1d-cell false
    set is-border-cell false
  ]
  ask patches with [ pycor = max-pycor ] [
    set is-1d-cell true
  ]
  ask patches with [ pycor = max-pycor - 1 ] [
    set is-border-cell true
    cell-border
  ]
end

to map-patches
  ;; -50, 50: current state pos[0]
  ;; 50, 50: current state pos [grid-side]
  ;; 0, 0: current state pos [(grid-side * grid-side / 2) + (grid-side / 2) + 1]
  ;; -50, -50: current state pos [(grid-side * grid-side) - grid-side]
  ;; 50, -50: current state pos [(grid-side * grid-side) - 1]
  let body-top max-pycor - 2
  let half-grid floor (grid-side / 2)
  ask patches with [not is-border-cell and not is-1d-cell] [
    let row body-top - pycor
    let col pxcor + half-grid
    set mapping row * grid-side + col
  ]
end

to draw-cells  ;; From the old model, actually an input-setup function.
  ifelse mouse-down? [
    let p patch mouse-xcor mouse-ycor
    if [not is-1d-cell and not is-border-cell] of p [
      if erasing? = 0 [
        set erasing? [living?] of p
      ]
      ask p [
        ifelse erasing? [
          cell-death
        ] [
          cell-birth
        ]
        ;; ... now we have to map BACK to 1d
        let idx mapping
        set current-state replace-item idx current-state (ifelse-value living? [1] [0])
      ]
    ]
    display
  ] [
    set erasing? 0
  ]
end

to update-1d-patches
  ;; very different from the base model since
  ;; in that model, the patch status is the acutal state.

  ;; here, we use current-state and the current-1d-position to update the 1D display
  ;; we should display the most recent grid-side of the 1D state based on the current-1d-position

  let bookmark (max list (current-1d-position - grid-side) 0)

  let state-view sublist current-state bookmark current-1d-position
  ;; we need to work entirely with the max pycor row

  ;; for our pxcor values, we need to start on the negative side of the axis and work to the positive side.
  ;; the negative side is -1 * (floor(grid-side / 2)

  let i -1 * (floor grid-side / 2)
  foreach state-view [ state ->
    ifelse ( state = 1 ) [
      ask patch i max-pycor [ cell-birth ]
    ] [
      ask patch i max-pycor [ cell-death ]
    ]
    set i (i + 1)

  ]
end

to update-2d-patches
  ask patches with [not is-border-cell and not is-1d-cell] [
    ifelse (item mapping current-state) = 1  ;; mapping is from patch to 1d state
      [ cell-birth ]
      [ cell-death ]
  ]
  display
end

to cell-birth   ;;; from the base model
  set living? true
  set pcolor fgcolor
end

to cell-death   ;;; from the base model
  set living? false
  set pcolor bgcolor
end

to cell-border ;;; not from anywhere
  set living? false
  set pcolor border-color
end

to go
  ;; Process the next step in the 1D representation
  ;; process-1d-step
  ;; itʻs a cosmetic issue, but we want the 1d row to scroll "forward" (left to right)
  ;; as we process each 1d cell.

  set previous-state current-state
  set current-state []
  set current-1d-position 0

  while [ current-1d-position < grid-squared ] [
    let state-pos evaluate
    set current-state (lput state-pos current-state)
    set current-1d-position (current-1d-position + 1)
    if update-1d? [ update-1d-patches ]   ;;; can toggle off for speed
  ]

  update-2d-patches

  ;; set current density by summing current-state and dividing by grid-squared
  set current-density (sum current-state / grid-squared)
  tick
end

to-report evaluate
  let prev-neighbors
    (item ((current-1d-position - grid-side - 1 + grid-squared) mod grid-squared) previous-state) +    ;; 7
    (item ((current-1d-position - grid-side + grid-squared) mod grid-squared) previous-state) +        ;; 8
    (item ((current-1d-position - grid-side + 1 + grid-squared) mod grid-squared) previous-state) +    ;; 9
    (item ((current-1d-position - 1 + grid-squared) mod grid-squared) previous-state) +                ;; 4
    (item ((current-1d-position + 1 + grid-squared) mod grid-squared) previous-state) +                ;; 6
    (item ((current-1d-position + grid-side - 1 + grid-squared) mod grid-squared) previous-state) +    ;; 1
    (item ((current-1d-position + grid-side + grid-squared) mod grid-squared) previous-state) +        ;; 2
    (item ((current-1d-position + grid-side + 1 + grid-squared) mod grid-squared) previous-state)      ;; 3
  let prev-self item current-1d-position previous-state                                                ;; 5

  ;; now apply the rules of GOL -- totally the same here as in 2D, just finding neighbors is different
  ifelse (prev-self = 1)
  [
    ifelse (prev-neighbors = 2 or prev-neighbors = 3)
      [ report 1 ] ;; Survive
      [ report 0 ] ;; Die (loneliness or overcrowding)
  ]
  [
    ifelse (prev-neighbors = 3)
      [ report 1 ] ;; Born
      [ report 0 ] ;; Stay dead
  ]
end




; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
285
10
697
431
-1
-1
4.0
1
10
1
1
1
0
1
1
1
-50
50
-50
52
0
0
1
ticks
15.0

SLIDER
117
69
276
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
11
141
114
176
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
179
115
217
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
179
215
275
248
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

MONITOR
713
66
816
111
current density
count patches with\n  [living?]\n/ count patches
2
1
11

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
713
128
872
226
When this button is down,\nyou can add or remove\ncells by holding down\nthe mouse button\nand \"drawing\". \nUnpredictable if used while running.
11
0.0
0

BUTTON
712
230
815
265
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
120
248
275
308
fgcolor
11.0
1
0
Color

INPUTBOX
120
310
275
370
bgcolor
79.0
1
0
Color

INPUTBOX
120
371
275
431
border-color
96.0
1
0
Color

BUTTON
11
104
113
137
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

SWITCH
356
441
484
474
update-1d?
update-1d?
0
1
-1000

TEXTBOX
488
442
637
484
Faster when off; but, you know: way less cool.
11
124.0
1

TEXTBOX
700
10
850
28
<--processing in 1D
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This program is an example of a two-dimensional cellular automaton.  This particular cellular automaton is called The Game of Life.

A cellular automaton is a computational machine that performs actions based on certain rules.  It can be thought of as a board which is divided into cells (such as square cells of a checkerboard).  Each cell can be either "alive" or "dead."  This is called the "state" of the cell.  According to specified rules, each cell will be alive or dead at the next time step.

## HOW IT WORKS

The rules of the game are as follows.  Each cell checks the state of itself and its eight surrounding neighbors and then sets itself to either alive or dead.  If there are less than two alive neighbors, then the cell dies.  If there are more than three alive neighbors, the cell dies.  If there are 2 alive neighbors, the cell remains in the state it is in.  If there are exactly three alive neighbors, the cell becomes alive. This is done in parallel and continues forever.

There are certain recurring shapes in Life, for example, the "glider" and the "blinker". The glider is composed of 5 cells which form a small arrow-headed shape, like this:

```text
   O
    O
  OOO
```

This glider will wiggle across the world, retaining its shape.  A blinker is a block of three cells (either up and down or left and right) that rotates between horizontal and vertical orientations.

## HOW TO USE IT

The INITIAL-DENSITY slider determines the initial density of cells that are alive.  SETUP-RANDOM places these cells.  GO-FOREVER runs the rule forever.  GO-ONCE runs the rule once.

If you want to draw your own pattern, use the DRAW-CELLS button and then use the mouse to "draw" and "erase" in the view.

## THINGS TO NOTICE

Find some objects that are alive, but motionless.

Is there a "critical density" - one at which all change and motion stops/eternal motion begins?

## THINGS TO TRY

Are there any recurring shapes other than gliders and blinkers?

Build some objects that don't die (using DRAW-CELLS)

How much life can the board hold and still remain motionless and unchanging? (use DRAW-CELLS)

The glider gun is a large conglomeration of cells that repeatedly spits out gliders.  Find a "glider gun" (very, very difficult!).

## EXTENDING THE MODEL

Give some different rules to life and see what happens.

Experiment with using neighbors4 instead of neighbors (see below).

## NETLOGO FEATURES

The neighbors primitive returns the agentset of the patches to the north, south, east, west, northeast, northwest, southeast, and southwest.  So `count neighbors with [living?]` counts how many of those eight patches have the `living?` patch variable set to true.

`neighbors4` is like `neighbors` but only uses the patches to the north, south, east, and west.  Some cellular automata, like this one, are defined using the 8-neighbors rule, others the 4-neighbors.

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

The Game of Life was invented by John Horton Conway.

See also:

Von Neumann, J. and Burks, A. W., Eds, 1966. Theory of Self-Reproducing Automata. University of Illinois Press, Champaign, IL.

"LifeLine: A Quarterly Newsletter for Enthusiasts of John Conway's Game of Life", nos. 1-11, 1971-1973.

Martin Gardner, "Mathematical Games: The fantastic combinations of John Conway's new solitaire game `life',", Scientific American, October, 1970, pp. 120-123.

Martin Gardner, "Mathematical Games: On cellular automata, self-reproduction, the Garden of Eden, and the game `life',", Scientific American, February, 1971, pp. 112-117.

Berlekamp, Conway, and Guy, Winning Ways for your Mathematical Plays, Academic Press: New York, 1982.

William Poundstone, The Recursive Universe, William Morrow: New York, 1985.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Life model.  http://ccl.northwestern.edu/netlogo/models/Life.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
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
