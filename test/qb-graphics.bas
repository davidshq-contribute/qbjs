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
' a program that sets a line width (LineWidth of the Graphics 2D library) keeps the canvas strokes
$If Javascript Then
    QB.defaultLineWidth(2);
$End If
Cls 0
PSet (20, 30), 0
Draw "C15R10"
UT.AssertTrue Point(25, 29) <> black
$Lines Smooth

' A new line on either of the last two rows moves the rows above the last one up, and leaves the
' cursor on the row before the last. The last row does not move. QB64pe gives the same results.
Screen 12
Color 15, 0
Cls 0
Locate 5, 1: Print "m";
Locate 30, 3: Print "z";
Locate 28, 1: Print "a"
UT.AssertEquals Csrlin, 29
UT.AssertEquals RowText(5), 1
Print "b"
UT.AssertEquals Csrlin, 29
UT.AssertEquals Pos(0), 1
UT.AssertEquals RowText(4), 1
UT.AssertEquals RowText(5), 0
UT.AssertEquals RowText(27), 1
UT.AssertEquals RowText(28), 1
UT.AssertEquals RowText(29), 0
UT.AssertEquals RowText(30), 1
Locate 30, 1: Print "c"
UT.AssertEquals Csrlin, 29
UT.AssertEquals RowText(3), 1
UT.AssertEquals RowText(4), 0
UT.AssertEquals RowText(26), 1
UT.AssertEquals RowText(27), 1
UT.AssertEquals RowText(28), 0
UT.AssertEquals RowText(30), 1
Cls 0

Console.Echo "QB Graphics - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"

' 1 when the text row of SCREEN 12 holds a pixel that is not the background, in its first 5 columns
Function RowText (row As Integer)
    Dim x As Integer, y As Integer
    RowText = 0
    For y = (row - 1) * 16 To row * 16 - 1
        For x = 0 To 39
            If Point(x, y) <> Point(639, 479) Then RowText = 1
        Next x
    Next y
End Function