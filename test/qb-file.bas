Import Sys From "lib/lang/system.bas"
Import Console From "lib/web/console.bas"
Import FS From "lib/io/fs.bas"
Import UT From "lib/test/unit-test.bas"

Dim ts: ts = Sys.TimeInMillis
Dim CRLF As String: CRLF = Chr$(13) + Chr$(10)

Open "test.txt" For Output As #1
Print #1, "This is a test"; "."
Close #1
UT.AssertEquals FS.ReadText("test.txt"), "This is a test." + CRLF
Kill "test.txt"

Open "test.txt" For Output As #1
Print #1, 3;
Close #1
UT.AssertEquals FS.ReadText("test.txt"), " 3 "
Kill "test.txt"

Open "test.txt" For Output As #1
Print #1, "n="; 42;
Close #1
UT.AssertEquals FS.ReadText("test.txt"), "n= 42 "
Kill "test.txt"

' the file name and the handle of OPEN are expressions
Dim fname As String, fnum As Integer
fname = "test.txt": fnum = 2
Open fname For Output As #fnum
Print #fnum, "named by variables"
Close #fnum
UT.AssertEquals FS.ReadText("test.txt"), "named by variables" + CRLF
Kill "test.txt"

' the original form of OPEN: a mode of I, O or A, then the handle, then the file
Open "O", 1, "test.txt"
Print #1, "first"
Close #1
Open "A", #1, "test" + ".txt"
Print #1, "second"
Close #1
UT.AssertEquals FS.ReadText("test.txt"), "first" + CRLF + "second" + CRLF
Dim original As String
Open "I", 1, "test.txt"
Line Input #1, original
Close #1
UT.AssertEquals original, "first"
Kill "test.txt"

Open "test.txt" For Output As #1
Print #1, "This is the first line."
Print #1, "This is the second line."
Close #1
Dim st As String
Open "test.txt" For Input As #1
Line Input #1, st
Close #1
UT.AssertEquals st, "This is the first line."
Kill "test.txt"

' TAB and SPC in a file: TAB moves to a column (the first is 1), and to the next line when it is past it
Open "test.txt" For Output As #1
Print #1, Tab(5); "a"; Tab(8); "b"; Spc(2); "c"
Print #1, "wxyz"; Tab(3); "d"
Close #1
UT.AssertEquals FS.ReadText("test.txt"), "    a  b  c" + CRLF + "wxyz" + CRLF + "  d" + CRLF
Kill "test.txt"

' each line of a file with CRLF line endings is read in turn
Open "test.txt" For Output As #1
Print #1, "one"
Print #1, "two"
Print #1, "three"
Close #1
Dim crlfLine As String
Open "test.txt" For Input As #1
Line Input #1, crlfLine
UT.AssertEquals crlfLine, "one"
Line Input #1, crlfLine
UT.AssertEquals crlfLine, "two"
Line Input #1, crlfLine
UT.AssertEquals crlfLine, "three"
UT.AssertTrue EOF(1)
Close #1
Kill "test.txt"

Open "test.txt" For Output As #1
Print #1, ""
Print #1, "second line"
Close #1
Dim st As String
Open "test.txt" For Input As #1
Input #1, st
Print st
UT.AssertEquals st, ""
Close #1
Kill "test.txt"

' INPUT # reads one field for each variable, from where the last one stopped
Open "test.txt" For Output As #1
Print #1, "one,2, three ,"; Chr$(34); "a, b"; Chr$(34)
Print #1, "4"
Print #1, "5,6"
Print #1, "7"
Print #1, "last line"
Close #1
Dim fa As String, fb As Integer, fc As String, fd As String, fe As Single, ff As Single
Dim fg As Single, fh As Single, fl As String
Open "test.txt" For Input As #1
Input #1, fa
UT.AssertEquals fa, "one"
Input #1, fb, fc
UT.AssertEquals fb, 2
UT.AssertEquals fc, "three"
Input #1, fd
UT.AssertEquals fd, "a, b"
Input #1, fe, ff, fg
UT.AssertEquals fe, 4
UT.AssertEquals ff, 5
UT.AssertEquals fg, 6
Input #1, fh
UT.AssertEquals fh, 7
' the line ending after the last item is taken, so the next line is read whole
Line Input #1, fl
UT.AssertEquals fl, "last line"
UT.AssertTrue EOF(1)
Close #1
Kill "test.txt"

MkDir "foo"
UT.AssertTrue _DirExists("foo")
UT.AssertTrue _DirExists("foo/")
RmDir "foo"
MkDir "test/"
UT.AssertTrue _DirExists("test")
UT.AssertTrue _DirExists("test///")
RmDir "test"

Sub OpenFail: Open "../data.txt" For Input As #1: Close #1: End Sub
UT.AssertError(@OpenFail, "File not found")

' OPEN with a file name that is an expression of several words, and a variable as the file number
Dim opDir As String, opLine As String, opNum As Integer
opDir = "open-expr-"
Open opDir + "a.txt" For Output As #1
Print #1, "hello"
Close #1
Open opDir + "a" + ".txt" For Input As #1
Line Input #1, opLine
Close #1
UT.AssertEquals opLine, "hello"
opNum = 2
Open "open-expr-" + LTrim$(Str$(opNum)) + ".txt" For Output As #opNum
Print #opNum, "two"
Close #opNum
Open (opDir + "a.txt") For Input As #1
Line Input #1, opLine
Close #1
UT.AssertEquals opLine, "hello"
Open "open-expr-2.txt" For Input As #1
Line Input #1, opLine
Close #1
UT.AssertEquals opLine, "two"

' INPUT # into an integer: QBJS cuts off the fraction; $ROUNDING EVEN rounds as QB does (3.5 to 4, 2.5 to 2)
Dim inA%, inB%, inC&
Open "test.txt" For Output As #1
Print #1, "3.5,2.5,6.5"
Close #1
Open "test.txt" For Input As #1
Input #1, inA%, inB%, inC&
Close #1
UT.AssertEquals inA%, 3
UT.AssertEquals inB%, 2
UT.AssertEquals inC&, 6
$ROUNDING EVEN
Open "test.txt" For Input As #1
Input #1, inA%, inB%, inC&
Close #1
$ROUNDING UP
UT.AssertEquals inA%, 4
UT.AssertEquals inB%, 2
UT.AssertEquals inC&, 6

Console.Echo "QB File I/O - tests completed with no errors* in " + (Sys.TimeInMillis - ts) + " millisecond(s)"