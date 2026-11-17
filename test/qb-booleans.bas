Import Sys From "lib/lang/system.bas"
Import Console From "lib/web/console.bas"
Import UT From "lib/test/unit-test.bas"

' $BOOLEANS QB makes a comparison give -1 for true and 0 for false, as in QB, instead of JavaScript's true
' and false. It applies to this whole file.
$BOOLEANS QB

Dim ts: ts = Sys.TimeInMillis

Dim bt As Integer, bf As Integer, bs As Single, bn As Integer, bx As Integer, bstr As String
bn = 3

' a comparison alone
bt = 3 > 2
UT.AssertEquals bt, -1
bf = 3 < 2
UT.AssertEquals bf, 0
bs = 3 > 2
UT.AssertEquals bs, -1
' (a statement whose arguments hold "=" reads as an assignment, so such comparisons go in a variable first)
bx = 3 = 3
UT.AssertEquals bx, -1
UT.AssertEquals 3 <> 3, 0
UT.AssertEquals "a" < "b", -1

' AND, OR and XOR of comparisons: -1 AND -1 is -1 (JavaScript's true & true is 1)
bt = 3 > 2 And 2 > 1
UT.AssertEquals bt, -1
bt = 3 > 2 Or 2 > 5
UT.AssertEquals bt, -1
bt = 3 > 2 Xor 2 > 1
UT.AssertEquals bt, 0
bt = 3 > 2 Xor 2 > 5
UT.AssertEquals bt, -1
' NOT of them, with and without parentheses
UT.AssertEquals Not (3 > 2 And 2 > 1), 0
UT.AssertEquals Not (3 > 2 Or 2 > 5), 0
UT.AssertEquals Not (3 < 2 Or 2 > 5), -1
UT.AssertEquals Not bn > 2, 0
UT.AssertEquals Not bn > 5, -1
bx = Not bn > 2 And bn > 1
UT.AssertEquals bx, 0
' a function whose result is such an AND, and NOT of it, as Civil War Strategy's navy_can_raid
UT.AssertEquals BoolBoth(5, 1), -1
UT.AssertEquals Not BoolBoth(5, 1), 0
UT.AssertEquals Not BoolBoth(0, 1), -1

' arithmetic with a comparison: QB's idiom x = x - (key = "a") moves by one
bx = 10
bstr = "a"
bx = bx - (bstr = "a")
UT.AssertEquals bx, 11
bx = bx + (bstr = "b")
UT.AssertEquals bx, 11

' a comparison as an argument, and an AND of numbers that are not comparisons
UT.AssertEquals Abs(bn > 2), 1
UT.AssertEquals 6 And 3, 2
bx = (bn And 1) = 1
UT.AssertEquals bx, -1

' a condition: -1 is true and 0 is false
If 3 > 2 And 2 > 1 Then bx = 1 Else bx = 2
UT.AssertEquals bx, 1
If Not (3 > 2 And 2 > 1) Then bx = 1 Else bx = 2
UT.AssertEquals bx, 2
bx = 0
While bx < 3 And bx > -1
    bx = bx + 1
Wend
UT.AssertEquals bx, 3

' SELECT CASE with IS and a comparison that the case clause starts with
bx = 0
Select Case bn
    Case Is < 2: bx = 1
    Case Is >= 3: bx = 2
End Select
UT.AssertEquals bx, 2
Select Case -1
    Case bn > 2: bx = 3
    Case Else: bx = 4
End Select
UT.AssertEquals bx, 3

' integer division beside a comparison
UT.AssertEquals 7 \ 2 > 2, -1
bx = 7 \ 2 = 3 And 9 \ 4 = 2
UT.AssertEquals bx, -1

' PRINT of a comparison writes -1 and 0
Open "test.txt" For Output As #1
Print #1, 3 > 2; 3 < 2
Close #1
Open "test.txt" For Input As #1
Line Input #1, bstr
Close #1
Kill "test.txt"
UT.AssertEquals bstr, "-1  0 "

Console.Echo "QB Booleans - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"

Function BoolBoth (a As Integer, b As Integer)
    BoolBoth = a >= 1 And b <> 0
End Function
