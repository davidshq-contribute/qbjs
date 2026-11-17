Import UT From "lib/test/unit-test.bas"
Import Console From "lib/web/console.bas"
Import Sys From "lib/lang/system.bas"

Dim ts: ts = Sys.TimeInMillis

UT.AssertTrue -1 EQV -1
UT.AssertFalse -1 EQV 0
UT.AssertFalse 0 EQV -1
UT.AssertTrue 0 EQV 0

count = 0: For i = 1 To 12: count = count + 1: Next i
UT.AssertEquals count, 12
count = 0: For i = 26 To 1 Step -1: count = count + 1: Next i
UT.AssertEquals count, 26
count = 0: For i = 1 To 20 Step 5: count = count + 1: Next i
UT.AssertEquals count, 4
count = 0: For i = 20 To 1 Step -10: count = count + 1: Next i
UT.AssertEquals count, 2

' constants named with a type suffix are used with the suffix
Const SUFFIX_NAME$ = "abc", SUFFIX_COUNT& = 7
UT.AssertEquals SUFFIX_NAME$, "abc"
UT.AssertEquals SUFFIX_COUNT&, 7

st = 1: count = 0: For i = 1 To 12 Step st: count = count + 1: Next i
UT.AssertEquals count, 12
st = -1: count = 0: For i = 26 To 1 Step st: count = count + 1: Next i
UT.AssertEquals count, 26
st = 5: count = 0: For i=1 To 20 Step st: count = count + 1: Next i
UT.AssertEquals count, 4
st = -10: count = 0: For i = 20 To 1 Step st: count = count + 1: Next i
UT.AssertEquals count, 2

' value literal suffixes
UT.AssertEquals 5#, 5
UT.AssertEquals 100000&, 100000
UT.AssertEquals 3.5!, 3.5
UT.AssertEquals 42%, 42

' NOT of a parenthesized comparison or number
Dim notA, notB, notCount
notA = 3: notB = 5: notCount = 0
If Not (notA > notB) Then notCount = notCount + 1
If Not (notA < notB) Then notCount = notCount + 10
UT.AssertEquals notCount, 1
UT.AssertEquals Not (notA < notB), 0
UT.AssertEquals Not (notA > notB), -1
UT.AssertEquals Not (0), -1
UT.AssertEquals Not (5), -6

' an array named with a type suffix has that type: names$(3) is a STRING array
Dim suffixNames$(3), suffixCounts%(3), suffixBig&(3)
suffixNames$(2) = "text"
UT.AssertEquals suffixNames$(2), "text"
UT.AssertEquals suffixNames$(1), ""
suffixCounts%(1) = 2.6
UT.AssertEquals suffixCounts%(1), 3

' DEF SEG, PEEK and POKE: a memory of bytes, empty at the start, values taken AND 255
Def Seg = 0
UT.AssertEquals Peek(100), 0
Poke 100, 65
UT.AssertEquals Peek(100), 65
Poke 101, 300
UT.AssertEquals Peek(101), 44
Def Seg = &H40
UT.AssertEquals Peek(100), 0
Poke 100, 7
UT.AssertEquals Peek(100), 7
Def Seg
UT.AssertEquals Peek(100), 65

' By default a procedure gets a copy of its arguments: a change to the parameter is not seen by the caller.
' ($BYREF ON, tested in qb-byref.bas, gives QB's by-reference behavior.)
Dim offA As Integer
offA = 4
OffBump offA
UT.AssertEquals offA, 4

' Rounding into an integer: QBJS rounds a half up (2.5 to 3); $ROUNDING EVEN rounds it to the even
' number as QB does (2.5 to 2, 3.5 to 4, -2.5 to -2, -3.5 to -4). CINT is always QB's.
Dim rndA%, rndB&
rndA% = 2.5
UT.AssertEquals rndA%, 3
rndA% = 3.5
UT.AssertEquals rndA%, 4
UT.AssertEquals rndHalf(2.5), 3
UT.AssertEquals CInt(2.5), 2
$ROUNDING EVEN
rndA% = 2.5
UT.AssertEquals rndA%, 2
rndA% = 3.5
UT.AssertEquals rndA%, 4
rndA% = -2.5
UT.AssertEquals rndA%, -2
rndA% = -3.5
UT.AssertEquals rndA%, -4
rndA% = 0.5
UT.AssertEquals rndA%, 0
rndA% = 2.6
UT.AssertEquals rndA%, 3
rndB& = 6.5
UT.AssertEquals rndB&, 6
UT.AssertEquals rndHalf(2.5), 2
UT.AssertEquals rndHalf(3.5), 4
UT.AssertEquals rndHalf(1.4), 1
' QB64 rounds a value for an INTEGER as a single, so 798.50001 is 798.5 and gives 798; for a LONG it
' rounds the double, which gives 799. 798.5001 is above the half for both.
Dim rndD As Double
rndD = 798.50001
rndA% = rndD
UT.AssertEquals rndA%, 798
rndB& = rndD
UT.AssertEquals rndB&, 799
rndD = 798.5001
rndA% = rndD
UT.AssertEquals rndA%, 799
$ROUNDING UP
UT.AssertEquals rndHalf(2.5), 3
rndA% = 2.5
UT.AssertEquals rndA%, 3

' DEFINT, DEFLNG, DEFSNG, DEFDBL, DEFSTR and _DEFINE give a name without a suffix its type, from the
' letters given, for the lines that follow (and for the procedures that follow)
dtx = 2.7
UT.AssertEquals dtx, 2.7
DEFINT A-C
aa = 2.7
UT.AssertEquals aa, 3
bb! = 2.7
UT.AssertEquals bb!, 2.7
DEFLNG E
ee = 5.6
UT.AssertEquals ee, 6
DEFDBL F
ff = 1.0000001
UT.AssertEquals ff, 1.0000001
DEFSTR S
ss = "hi"
UT.AssertEquals Len(ss), 2
DEFINT I-K, M
kk = 3.4
UT.AssertEquals kk, 3
mm = 3.6
UT.AssertEquals mm, 4
nn = 3.6
UT.AssertEquals nn, 3.6
_DEFINE P-Q AS INTEGER
pp = 9.9
UT.AssertEquals pp, 10
' a DEF line in a part that $IF skips does not count
$IF WEB THEN
$ELSE
    DEFINT T
$END IF
tt = 2.5
UT.AssertEquals tt, 2.5
UT.AssertEquals bAddOne(1.4), 1
UT.AssertEquals dtTwice(2.6), 5.2

' a comparison stored in an integer is -1 for true and 0 for false, so NOT of it is 0 and -1 (not -2 and -1)
Dim cmpInt As Integer, cmpLng As Long
cmpInt = 3 > 2
UT.AssertEquals cmpInt, -1
cmpInt = 3 < 2
UT.AssertEquals cmpInt, 0
cmpLng = (3 > 2)
UT.AssertEquals cmpLng, -1
UT.AssertEquals bPositive(5), -1
UT.AssertEquals bPositive(-5), 0
UT.AssertEquals Not bPositive(5), 0
UT.AssertEquals Not bPositive(-5), -1
UT.AssertTrue (Not bPositive(-5) Or bPositive(-5))

Console.Echo "QB Language - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"

Sub OffBump (n As Integer)
    n = n + 1
End Sub

Function bPositive% (n As Integer)
    bPositive = n > 0
End Function

Function rndHalf (n As Integer)
    rndHalf = n
End Function

Function bAddOne (aval)
    bAddOne = aval + 0.4
End Function

DEFSNG A-Z
Function dtTwice (q)
    dtTwice = q * 2
End Function