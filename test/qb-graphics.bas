Import Sys From "lib/lang/system.bas"
Import Console From "lib/web/console.bas"
Import FS From "lib/io/fs.bas"
Import UT From "lib/test/unit-test.bas"

Dim ts: ts = Sys.TimeInMillis
Dim c As Unsigned Integer
c = _RGBA(100, 200, 255, 100)

Circle (100, 100), 50, c
UT.AssertEquals _Alpha(c), 100
UT.AssertEquals _Alpha32(c), 100

' VIEW sets a graphics view port; CLS 1 and CLS clear only that; VIEW alone ends it
Screen 12
Dim red As Unsigned Long
Line (0, 0)-(639, 479), 4, BF
red = Point(0, 0)
View (100, 100)-(300, 200)
Cls 1
View
UT.AssertEquals Point(200, 150), _RGB32(0, 0, 0)
UT.AssertEquals Point(99, 150), red
UT.AssertEquals Point(301, 150), red
UT.AssertEquals Point(200, 99), red
UT.AssertEquals Point(200, 201), red
View (10, 300)-(50, 340)
Cls
View
UT.AssertEquals Point(30, 320), _RGB32(0, 0, 0)
UT.AssertEquals Point(9, 320), red
Dim green As Unsigned Long, white As Unsigned Long
Line (600, 0)-(605, 5), 2, BF
Line (600, 10)-(605, 15), 15, BF
green = Point(602, 2)
white = Point(602, 12)
View (400, 300)-(450, 340), 2, 15
View
UT.AssertEquals Point(420, 320), green
UT.AssertEquals Point(399, 320), white
Cls
UT.AssertEquals Point(200, 150), _RGB32(0, 0, 0)
' a new SCREEN ends the view port, so CLS clears the whole screen again
View (100, 100)-(300, 200)
Screen 12
Line (0, 0)-(639, 479), 4, BF
Cls
UT.AssertEquals Point(0, 0), _RGB32(0, 0, 0)

' GET (x1, y1)-(x2, y2), array saves a rectangle; PUT (x, y), array, action draws it back
Dim saved(2000) As Integer
Dim yellow As Unsigned Long, cyan As Unsigned Long
Line (0, 0)-(639, 479), 4, BF
Line (100, 100)-(150, 150), 14, BF
yellow = Point(125, 125)
red = Point(10, 10)
Get (90, 90)-(160, 160), saved()
Line (80, 80)-(200, 200), 2, BF
UT.AssertEquals Point(125, 125), green
Put (90, 90), saved(), PSET
UT.AssertEquals Point(125, 125), yellow
UT.AssertEquals Point(95, 95), red
UT.AssertEquals Point(85, 85), green
Put (300, 300), saved(), PSET
UT.AssertEquals Point(335, 335), yellow
Put (300, 300), saved(), XOR
UT.AssertEquals Point(335, 335), _RGB32(0, 0, 0)
Put (300, 300), saved()
UT.AssertEquals Point(335, 335), yellow

' Inside a view port, coordinates are relative to its corner, drawing is clipped to it, and POINT outside
' it is -1. CLS 1 sends the text cursor home and the graphics cursor to the port's center. QB64pe gives
' the same results.
Screen 12
Dim black As Unsigned Long, lineColor As Unsigned Long, blue As Unsigned Long
black = _RGB32(0, 0, 0)
Cls 0
Locate 10, 20: Print "x";
View (100, 100)-(300, 200)
Cls 1
UT.AssertEquals Csrlin, 1
UT.AssertEquals Pos(0), 1
UT.AssertEquals Point(0), 100
UT.AssertEquals Point(1), 50
PSet (0, 0), 14
yellow = Point(0, 0)
UT.AssertTrue yellow <> black
UT.AssertEquals Point(0), 0
UT.AssertEquals Point(-1, -1), -1
UT.AssertEquals Point(250, 50), -1
Line (-50, 50)-(400, 50), 15
View
UT.AssertEquals Point(100, 100), yellow
UT.AssertEquals Point(99, 99), black
lineColor = Point(100, 150)
UT.AssertTrue lineColor <> black
UT.AssertEquals Point(300, 150), lineColor
UT.AssertEquals Point(99, 150), black
UT.AssertEquals Point(301, 150), black
Cls 0
' PAINT stops at the view port's edge
View (100, 100)-(300, 200)
Paint (10, 10), 9
View
blue = Point(100, 100)
UT.AssertTrue blue <> black
UT.AssertEquals Point(300, 200), blue
UT.AssertEquals Point(99, 100), black
UT.AssertEquals Point(301, 200), black
Cls 0
' VIEW SCREEN keeps the screen's coordinates and clips
View Screen (100, 100)-(300, 200)
PSet (150, 150), 14
PSet (50, 50), 14
View
UT.AssertEquals Point(150, 150), yellow
UT.AssertEquals Point(50, 50), black
Cls 0
' graphics GET and PUT are relative to the corner too
View (100, 100)-(300, 200)
Line (0, 0)-(9, 9), 2, BF
Get (0, 0)-(9, 9), saved()
Put (20, 0), saved(), PSet
View
UT.AssertEquals Point(120, 100), green
UT.AssertEquals Point(20, 0), black

' By default DRAW strokes its lines on the canvas, two pixels wide
Dim white As Unsigned Long, fill As Unsigned Long
Cls 0
PSet (630, 470), 15
white = Point(630, 470)
PSet (20, 30), 0
Draw "C15R10"
UT.AssertTrue Point(25, 29) <> black

' With $LINES QB, DRAW sets whole pixels, one wide, so PAINT finds its border. The pen keeps its
' fractions and POINT(0) and POINT(1) round it. N draws without moving the pen; CLS sets the scale back
' to S4; A0 turns back to no rotation. QB64pe gives the same results.
$Lines QB
Cls 0
PSet (20, 30), 0
Draw "C15R10"
UT.AssertEquals Point(30, 30), white
UT.AssertEquals Point(31, 30), black
UT.AssertEquals Point(25, 29), black
UT.AssertEquals Point(25, 31), black
PSet (20, 40), 0
Draw "S2R3"
UT.AssertEquals Point(0), 22
UT.AssertEquals Point(2), 21.5
Draw "S4"
PSet (20, 50), 0
Draw "C15NR10D5"
UT.AssertEquals Point(0), 20
UT.AssertEquals Point(1), 55
UT.AssertEquals Point(30, 50), white
Draw "S8"
Cls 0
PSet (20, 20), 0
Draw "R5"
UT.AssertEquals Point(0), 25
Draw "TA90A0R5"
UT.AssertEquals Point(0), 30
UT.AssertEquals Point(1), 20
PSet (100, 100), 0
Draw "C15R10D10L10U10BF5P9,15"
fill = Point(105, 105)
UT.AssertTrue fill <> black
UT.AssertTrue fill <> white
UT.AssertEquals Point(101, 109), fill
UT.AssertEquals Point(111, 105), black
UT.AssertEquals Point(99, 105), black
' With $LINES QB, LINE sets whole pixels too: one wide and to the last pixel, a BF box given corner to
' corner either way round, fractions rounded, a style pattern, and a B box that PAINT stays inside.
' QB64pe gives the same results.
Cls 0
Line (20, 20)-(30, 20), 15
UT.AssertEquals Point(30, 20), white
UT.AssertEquals Point(31, 20), black
UT.AssertEquals Point(25, 19), black
UT.AssertEquals Point(25, 21), black
Line (30, 30)-(20, 35), 15, BF
UT.AssertEquals Point(20, 30), white
UT.AssertEquals Point(30, 35), white
UT.AssertEquals Point(19, 32), black
UT.AssertEquals Point(31, 32), black
Line (40.4, 30.4)-(50.6, 30.4), 15
UT.AssertEquals Point(40, 30), white
UT.AssertEquals Point(51, 30), white
UT.AssertEquals Point(0), 51
Line (5, 40)-(55, 40), 15, , &HF0F0
UT.AssertEquals Point(5, 40), white
UT.AssertEquals Point(8, 40), white
UT.AssertEquals Point(9, 40), black
UT.AssertEquals Point(13, 40), white
Line (100, 100)-(120, 110), 15, B
Paint (110, 105), 9, 15
UT.AssertEquals Point(110, 105), fill
UT.AssertEquals Point(121, 105), black
UT.AssertEquals Point(110, 111), black
' With $LINES QB, CIRCLE sets whole pixels as QB64 does, so PAINT stays inside even a small circle.
' Ellipses, arcs, and a line to the center for an angle below zero; with no aspect given, the aspect
' of the screen mode. QB64pe gives the same results.
Dim circleWhite As Unsigned Long
Cls 0
Circle (100, 100), 3, 15
UT.AssertEquals Point(103, 100), white
UT.AssertEquals Point(97, 100), white
UT.AssertEquals Point(100, 103), white
UT.AssertEquals Point(100, 97), white
UT.AssertEquals Point(102, 102), white
UT.AssertEquals Point(103, 101), white
UT.AssertEquals Point(104, 100), black
UT.AssertEquals Point(100, 100), black
Paint (100, 100), 12, 15
UT.AssertTrue Point(100, 100) <> black
UT.AssertEquals Point(105, 100), black
Cls 0
Circle (100, 100), 10, 15
UT.AssertEquals Point(110, 100), white
UT.AssertEquals Point(90, 100), white
UT.AssertEquals Point(100, 110), white
UT.AssertEquals Point(100, 90), white
UT.AssertEquals Point(107, 107), white
UT.AssertEquals Point(93, 93), white
UT.AssertEquals Point(111, 100), black
UT.AssertEquals Point(109, 100), black
Cls 0
Circle (100, 100), 20, 15, , , .5
UT.AssertEquals Point(120, 100), white
UT.AssertEquals Point(80, 100), white
UT.AssertEquals Point(100, 110), white
UT.AssertEquals Point(100, 90), white
UT.AssertEquals Point(100, 111), black
Cls 0
Circle (100, 100), 20, 15, 0, 1.5707963
UT.AssertEquals Point(120, 100), white
UT.AssertEquals Point(114, 86), white
UT.AssertEquals Point(100, 80), black
UT.AssertEquals Point(80, 100), black
UT.AssertEquals Point(100, 120), black
Cls 0
Circle (100, 100), 20, 15, -.0001, -1.5707963
UT.AssertEquals Point(110, 100), white
UT.AssertEquals Point(100, 90), white
UT.AssertEquals Point(100, 100), white
UT.AssertEquals Point(90, 100), black
Screen 13
PSet (310, 190), 15
circleWhite = Point(310, 190)
Cls
Circle (100, 100), 20, 15
UT.AssertEquals Point(120, 100), circleWhite
UT.AssertEquals Point(100, 83), circleWhite
UT.AssertEquals Point(100, 117), circleWhite
UT.AssertTrue Point(100, 80) <> circleWhite
Screen 12

' a program that sets a line width (LineWidth of the Graphics 2D library) keeps the canvas strokes
$If Javascript Then
    QB.defaultLineWidth(2);
$End If
Cls 0
PSet (20, 30), 0
Draw "C15R10"
UT.AssertTrue Point(25, 29) <> black
$Lines Smooth

Console.Echo "QB Graphics - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"