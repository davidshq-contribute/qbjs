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

Console.Echo "QB Language - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"