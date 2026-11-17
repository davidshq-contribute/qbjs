Import Sys From "lib/lang/system.bas"
Import Console From "lib/web/console.bas"
Import UT From "lib/test/unit-test.bas"

' $BYREF ON passes a variable, an array element or a TYPE member to a procedure by reference, as QB does,
' done as copy in and copy out. It applies to the procedures of this file and the calls to them.
$BYREF ON

Dim ts: ts = Sys.TimeInMillis

Type BrPt
    x As Integer
    y As Integer
End Type

Dim a As Integer, arr(5) As Integer, p As BrPt, s As String, i As Integer, z As Integer, r As Integer

' a variable, an array element and a TYPE member, as a statement and with CALL
a = 1
BrBump a
UT.AssertEquals a, 2
arr(2) = 5
BrBump arr(2)
UT.AssertEquals arr(2), 6
p.x = 7
BrBump p.x
UT.AssertEquals p.x, 8
Call BrBump(a)
UT.AssertEquals a, 3
s = "ab"
BrAddStr s
UT.AssertEquals s, "abx"

' a variable of another type is passed as a copy, as QB64 does: a SINGLE to an INTEGER parameter
Dim sg As Single
sg = 2.7
BrBump sg
UT.AssertEquals sg, 2.7

' an argument in its own parentheses, an expression and a constant are passed by value
BrBump (a)
UT.AssertEquals a, 3
BrBump a + 0
UT.AssertEquals a, 3
BrBump 5
UT.AssertEquals a, 3

' a FUNCTION in an expression
r = BrTriple(a)
UT.AssertEquals a, 9
UT.AssertEquals r, 9
UT.AssertTrue BrTriple(arr(2)) > 0
UT.AssertEquals arr(2), 18
UT.AssertEquals BrFour(a) + BrFour(a), 8
UT.AssertEquals a, 11

' the element is chosen before the call: BrBumpIdx changes i, and the value still goes to arr(1)
i = 1
arr(1) = 10
BrBumpIdx i, arr(i)
UT.AssertEquals i, 2
UT.AssertEquals arr(1), 11
UT.AssertEquals arr(2), 18

' EXIT SUB and EXIT FUNCTION give the value back too
BrEarly a
UT.AssertEquals a, 200

' a variable that is first used as an argument
BrSetNew z
UT.AssertEquals z, 42

Console.Echo "QB By reference - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"

Sub BrBump (n As Integer)
    n = n + 1
End Sub

Sub BrBumpIdx (k As Integer, v As Integer)
    k = 2
    v = v + 1
End Sub

Sub BrAddStr (t As String)
    t = t + "x"
End Sub

Sub BrEarly (n As Integer)
    n = 200
    If n > 100 Then Exit Sub
    n = 999
End Sub

Sub BrSetNew (n As Integer)
    n = 42
End Sub

Function BrTriple (n As Integer)
    n = n * 3
    BrTriple = n
End Function

Function BrFour (n As Integer)
    n = n + 1
    BrFour = 4
    If n > 0 Then Exit Function
    BrFour = 5
End Function
