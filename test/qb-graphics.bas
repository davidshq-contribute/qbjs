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

' PAINT with no fill color fills with the foreground color, and stops at that color. QB64pe gives
' the same results.
Screen 12
Dim white As Unsigned Long, blue As Unsigned Long
Line (0, 0)-(639, 479), 1, BF
Color 15
Line (100, 100)-(150, 150), , B
white = Point(100, 100)
blue = Point(10, 10)
Paint (125, 125)
UT.AssertEquals Point(125, 125), white
UT.AssertEquals Point(160, 125), blue

Console.Echo "QB Graphics - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"