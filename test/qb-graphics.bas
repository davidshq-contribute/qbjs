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

' LOCATE rounds a row or column that is not a whole number, a half to the even number. QB64pe gives
' the same results.
Locate 5, 20.5
UT.AssertEquals Pos(0), 20
Locate 5, 21.5
UT.AssertEquals Pos(0), 22
Locate 5, 20.4
UT.AssertEquals Pos(0), 20
Locate 5, 20.6
UT.AssertEquals Pos(0), 21
Locate 6.5, 3
UT.AssertEquals Csrlin, 6
Locate 7.5, 3
UT.AssertEquals Csrlin, 8
Locate 1, 1

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
' a change of SCREEN mode ends the view port, so CLS clears the whole screen again
View (100, 100)-(300, 200)
Screen 13
Screen 12
Line (0, 0)-(639, 479), 4, BF
Cls
UT.AssertEquals Point(0, 0), _RGB32(0, 0, 0)
' SCREEN with the mode already in use changes nothing: the pixels, both cursors, the color and the view
' port stay. QB64pe gives the same results.
Line (0, 0)-(639, 479), 4, BF
Locate 5, 5: Print "x";
PSet (100, 100), 14
Color 2
Screen 12
UT.AssertEquals Point(300, 300), red
UT.AssertEquals Point(0), 100
UT.AssertEquals Point(1), 100
UT.AssertEquals Csrlin, 5
UT.AssertEquals Pos(0), 6
PSet (110, 110)
UT.AssertEquals Point(110, 110), green
View (100, 100)-(300, 200)
Screen 12
Cls
View
UT.AssertEquals Point(50, 50), red
UT.AssertEquals Point(200, 150), _RGB32(0, 0, 0)
Color 15

' A negative color wraps around: into the palette in SCREEN 12, where -1 is 15 and -2 is 14, and to a
' 32-bit color in a 32-bit image, where -1 is opaque white. QB64pe gives the same results.
Dim c15 As Unsigned Long, c14 As Unsigned Long, img32 As Long
Cls 0
PSet (0, 0), 15
c15 = Point(0, 0)
PSet (1, 0), 14
c14 = Point(1, 0)
Line (10, 10)-(20, 20), -1, BF
Line (30, 10)-(40, 20), -2, BF
UT.AssertEquals Point(15, 15), c15
UT.AssertEquals Point(35, 15), c14
img32 = _NewImage(40, 40, 32)
_Dest img32
_Source img32
Line (10, 10)-(20, 20), -1, BF
UT.AssertEquals Point(15, 15), _RGBA32(255, 255, 255, 255)
_Dest 0
_Source 0
_FreeImage img32
Cls 0

' PRINT starts an item on the next line when it does not fit on the rest of this one. A number counts
' with its spaces. An item that fits exactly stays, TAB is not moved, and an item longer than a whole
' line is split. QB64pe gives the same results.
Cls
Locate 1, 78: Print 11;
UT.AssertEquals Csrlin, 2
UT.AssertEquals Pos(0), 5
Locate 3, 77: Print 1;
UT.AssertEquals Csrlin, 3
UT.AssertEquals Pos(0), 80
Print "xy";
UT.AssertEquals Csrlin, 4
UT.AssertEquals Pos(0), 3
Locate 6, 75: Print "abc"; "defg";
UT.AssertEquals Csrlin, 7
UT.AssertEquals Pos(0), 5
Locate 8, 75: Print "abc"; Tab(79); "z";
UT.AssertEquals Csrlin, 8
UT.AssertEquals Pos(0), 80
Locate 10, 1: Print String$(85, "q");
UT.AssertEquals Csrlin, 11
UT.AssertEquals Pos(0), 6
Cls
' A tab character in PRINT moves to the next tab stop; the stops are 8 columns apart. It blanks the
' columns it passes. With no stop left on the line, it starts the next line. QB64pe gives the same
' results.
Dim tabX As Integer, tabY As Integer, tabInk As Integer
Print "abc" + Chr$(9) + "d";
UT.AssertEquals Pos(0), 10
Locate 2, 1: Print "abcdefgh" + Chr$(9) + "d";
UT.AssertEquals Pos(0), 18
Locate 3, 1: Print String$(39, "x");
Print Chr$(9) + Chr$(9) + Chr$(9) + Chr$(9) + "ESC";
UT.AssertEquals Csrlin, 3
UT.AssertEquals Pos(0), 68
Locate 4, 74: Print "a" + Chr$(9) + "b";
UT.AssertEquals Csrlin, 5
UT.AssertEquals Pos(0), 2
Locate 7, 1: Print String$(30, "x");
Locate 7, 1: Print "ab" + Chr$(9) + "c";
UT.AssertEquals Pos(0), 10
' columns 3 to 7; QBJS's font can reach one pixel into the cell before a character
tabInk = 0
For tabY = 96 To 111
    For tabX = 16 To 55
        If Point(tabX, tabY) <> Point(639, 479) Then tabInk = tabInk + 1
    Next tabX
Next tabY
UT.AssertEquals tabInk, 0
Cls

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


' PAINT spreads over pixels of the fill color too, so painting an area again covers what was drawn on
' it since. QB64pe gives the same results.
Cls 0
Line (10, 10)-(200, 200), 10, B
Paint (100, 100), 2, 10
Line (50, 50)-(80, 80), 4, B
Line (120, 120)-(150, 150), 0, BF
PSet (20, 20), 14
Paint (100, 100), 2, 10
UT.AssertEquals Point(50, 50), green
UT.AssertEquals Point(65, 65), green
UT.AssertEquals Point(130, 130), green
UT.AssertEquals Point(20, 20), green
UT.AssertEquals Point(5, 5), black
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