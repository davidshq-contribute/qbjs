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

Console.Echo "QB Graphics - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"