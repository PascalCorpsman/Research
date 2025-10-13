Unit Unit1;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  TAGraph, TASeries, EpikTimer, TAChartAxisUtils;

Type
  TInt64Array = Array Of Int64;
  TIntArray = Array Of Integer;

  TBenchmarkFunction = Function(ElementCount, Iterations: integer): double Of Object;

  TBenchmark = Record
    _Function: TBenchmarkFunction;
    LineSeries: TLineSeries;
  End;

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button6: TButton;
    Chart1: TChart;
    Ram: TLineSeries;
    L3: TLineSeries;
    L2: TLineSeries;
    L1: TLineSeries;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    EpikTimer1: TEpikTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Chart1AxisList0GetMarkText(Sender: TObject; Var AText: String;
      AMark: Double);
    Procedure Chart1AxisList1GetMarkText(Sender: TObject; Var AText: String;
      AMark: Double);
    Procedure FormClose(Sender: TObject; Var CloseAction: TCloseAction);
    Procedure FormCreate(Sender: TObject);
  private
    Sum: Int64;
    Benchmark: Array Of TBenchmarkFunction;
    Curves: Array[0..3] Of TLineSeries;
    Function V1(ElementCount, Iterations: integer): double;
    Function V2(ElementCount, Iterations: integer): double;
    Function V3(ElementCount, Iterations: integer): double;
    Function V4(ElementCount, Iterations: integer): double;
    Function V5(ElementCount, Iterations: integer): double;
    Function V6(ElementCount, Iterations: integer): double;
    Procedure ClearResults;
  public
    (*
     * Data and index are stored globally in order to not get "disturbed" memory allocations
     *)
    Best, Worst: Double;
    DataArray: TInt64Array;
    IndexArray: TIntArray;
    Procedure IterateOverDataArray(Index: integer; UsedBytes, TotalIterations: Int64);
  End;

Var
  Form1: TForm1;

Implementation

{$R *.lfm}

Uses StrUtils, math;

Procedure Shuffle(Var arr: TIntArray; Border: integer);
Var
  i, j: Int64;
  tmp: Int64;
Begin
  For i := 0 To Border - 1 Do Begin
    j := Random(Border);
    tmp := arr[i];
    arr[i] := arr[j];
    arr[j] := tmp;
  End;
End;

{ TForm1 }

Procedure TForm1.FormCreate(Sender: TObject);
//Procedure AddBenchmark(Const Ben
Var
  i: Integer;
Begin
  caption := 'Cache miss evaluator, ver 0.01 by Corpsman';
  Randomize;
  DataArray := Nil;
  IndexArray := Nil;
{$IFDEF Linux}
  // AMD Ryzen 7 7730U has 8 cores Datasheet value is
  // Cache L1: 64 KB (per core)        512
  // Cache L2: 512 KB (per core)       4096
  // Cache L3: 16 MB (shared)          16
  edit1.text := '512';
  edit2.text := '4096';
  edit3.text := '16';
  edit4.text := '8';
{$ELSE}
  // Intel® Core™ Ultra 7 Prozessor 165H
  // Cache L1: 112 KB (per core).
  // Cache L2: 2 MB (per core).
  // Cache L3: 24 MB (shared).
  edit1.text := '1792';
  edit2.text := '32768';
  edit3.text := '24';
  edit4.text := '16';
{$ENDIF}
  Button1Click(Nil);
  Curves[0] := L1;
  Curves[1] := L2;
  Curves[2] := L3;
  Curves[3] := RAM;
  (*
   * Register all Benchmark functions, modify the following lines if you want to
   * add more / your own versions ;)
   *)
  setlength(Benchmark, 6);
  Benchmark[0] := @V1;
  Benchmark[1] := @V2;
  Benchmark[2] := @V3;
  Benchmark[3] := @V4;
  Benchmark[4] := @V5;
  Benchmark[5] := @V6;

  StringGrid1.ColCount := length(Benchmark) + 1;
  ClearResults();
  For i := 1 To StringGrid1.ColCount - 1 Do Begin
    StringGrid1.Cells[i, 0] := 'V' + inttostr(i);
  End;
  StringGrid1.Cells[0, 1] := 'L1';
  StringGrid1.Cells[0, 2] := 'L2';
  StringGrid1.Cells[0, 3] := 'L3';
  StringGrid1.Cells[0, 4] := 'RAM';
End;

(*
 * V1 = Naive version:
 *      one single loop for "Iterations" over ElementCount
 *)

Function TForm1.V1(ElementCount, Iterations: integer): double;
Var
  i: Integer;
Begin
  sum := 0;
  EpikTimer1.Clear;
  EpikTimer1.Start;
  // Wiederholung über das Index-Array bis totalBytes Operationen erreicht
  For i := 0 To Iterations - 1 Do Begin
    sum := sum + DataArray[IndexArray[i Mod ElementCount]];
  End;
  result := EpikTimer1.Elapsed() * 1000;
End;

(*
 * V2 = improoved v1:
 *      same as v1 but without mod operation
 *)

Function TForm1.V2(ElementCount, Iterations: integer): double;
Var
  IndexIndex, i: Integer;
Begin
  sum := 0;
  IndexIndex := 0;
  EpikTimer1.Clear;
  EpikTimer1.Start;
  // Wiederholung über das Index-Array bis totalBytes Operationen erreicht
  For i := 0 To Iterations - 1 Do Begin
    sum := sum + DataArray[IndexArray[IndexIndex]];
    inc(IndexIndex);
    If IndexIndex = elementCount Then IndexIndex := 0;
  End;
  result := EpikTimer1.Elapsed() * 1000;
End;

(*
 * V3 = improoved v2:
 *      same as v2 but with more deterministic "branches"
 *)

Function TForm1.V3(ElementCount, Iterations: integer): double;
Var
  Cnt, i: Integer;
Begin
  sum := 0;
  Cnt := 0;
  EpikTimer1.Clear;
  EpikTimer1.Start;
  // Wiederholung über das Index-Array bis totalBytes Operationen erreicht
  While Cnt < Iterations Do Begin
    For i := 0 To ElementCount - 1 Do Begin
      sum := sum + DataArray[IndexArray[i]];
      Inc(Cnt);
      If Cnt >= Iterations Then
        Break;
    End;
  End;
  result := EpikTimer1.Elapsed() * 1000;
End;

(*
 * V4 = improoved v3:
 *      same as v3 with loop enrolling (= no branches)
 *)

Function TForm1.V4(ElementCount, Iterations: integer): double;
Var
  i, FullLoops, Remaining, j: Integer;

Begin
  Sum := 0;

  FullLoops := Iterations Div ElementCount;
  Remaining := Iterations Mod ElementCount;
  EpikTimer1.Clear;
  EpikTimer1.Start;

  For j := 1 To FullLoops Do Begin
    For i := 0 To ElementCount - 1 Do Begin
      Sum := Sum + DataArray[IndexArray[i]];
    End;
  End;

  For i := 0 To Remaining - 1 Do Begin
    Sum := Sum + DataArray[IndexArray[i]];
  End;
  sum := Sum;
  result := EpikTimer1.Elapsed() * 1000;
End;


(*
 * V5 = impooved v4:
 *      same as v4 but with no self pointer deferencing
 *)

Function TForm1.V5(ElementCount, Iterations: integer): double;
Var
  i, FullLoops, Remaining, j: Integer;
  (*
   * Instead of using the self dereferincing, store a direct pointer to
   * the memory
   *)
  localSum: Int64;
  localDataArray: TInt64Array;
  localIndexArray: TIntArray;
Begin
  localDataArray := DataArray;
  localIndexArray := IndexArray;
  localSum := 0;

  FullLoops := Iterations Div ElementCount;
  Remaining := Iterations Mod ElementCount;
  EpikTimer1.Clear;
  EpikTimer1.Start;

  For j := 1 To FullLoops Do Begin
    For i := 0 To ElementCount - 1 Do Begin
      localSum := localSum + localDataArray[localIndexArray[i]];
    End;
  End;

  For i := 0 To Remaining - 1 Do Begin
    localSum := localSum + localDataArray[localIndexArray[i]];
  End;
  sum := localSum;
  result := EpikTimer1.Elapsed() * 1000;
End;

(*
 * V6 = impooved v5:
 *      same as v5 but with inc instead of x := x +
 *)

Function TForm1.V6(ElementCount, Iterations: integer): double;
Var
  i, FullLoops, Remaining, j: Integer;
  (*
   * Instead of using the self dereferincing, store a direct pointer to
   * the memory
   *)
  localSum: Int64;
  localDataArray: TInt64Array;
  localIndexArray: TIntArray;
Begin
  localDataArray := DataArray;
  localIndexArray := IndexArray;
  localSum := 0;

  FullLoops := Iterations Div ElementCount;
  Remaining := Iterations Mod ElementCount;
  EpikTimer1.Clear;
  EpikTimer1.Start;

  For j := 1 To FullLoops Do Begin
    For i := 0 To ElementCount - 1 Do Begin
      inc(localSum, localDataArray[localIndexArray[i]]);
    End;
  End;

  For i := 0 To Remaining - 1 Do Begin
    inc(localSum, localDataArray[localIndexArray[i]]);
  End;
  sum := localSum;
  result := EpikTimer1.Elapsed() * 1000;
End;

Procedure TForm1.IterateOverDataArray(Index: integer; UsedBytes,
  TotalIterations: Int64);
Var
  ElementCount, i: Integer;
  sums: Array Of Int64;
  times: Array Of Double;
Begin
  // Prepare everything
  sums := Nil;
  times := Nil;
  setlength(sums, length(Benchmark));
  setlength(times, length(Benchmark));
  ElementCount := UsedBytes Div sizeof(int64);
  For i := 0 To ElementCount - 1 Do Begin
    (*
     * All sums are done over DataArray, if all values of
     * DataArray = 1 this is always the TotalIterations :)
     * If wanted this value can also be changes, it does not
     * make any differing due to execution time.
     *)
    If CheckBox3.Checked Then Begin
      DataArray[i] := 1;
    End
    Else Begin
      DataArray[i] := i;
    End;
    IndexArray[i] := i;
  End;
  (*
   * By shuffling the indexes which are used next we can break the
   * memory "using" prediction of the CPU -> This has the most
   * effect of all!
   *)
  If CheckBox1.Checked Then Shuffle(IndexArray, elementCount);

  For i := 0 To high(Benchmark) Do Begin
    times[i] := Benchmark[i](ElementCount, TotalIterations);
    best := min(times[i], best);
    worst := max(times[i], worst);
    sums[i] := Sum;
    StringGrid1.Cells[1 + i, index] := format('%4.2fms', [times[i]]);
    StringGrid1.AutoSizeColumns;
    Curves[Index - 1].AddXY(i + 1, ln(times[i]) / ln(10));
    Application.ProcessMessages;
  End;
  For i := 0 To high(Benchmark) - 1 Do Begin
    If sums[i] <> sums[i + 1] Then Begin
      Raise exception.create('Error, invalid sums..');
    End;
  End;
  If CheckBox2.Checked Then Begin
    StringGrid1.Cells[StringGrid1.ColCount - 1, index] := format('%d', [sums[0]]);
    StringGrid1.AutoSizeColumns;
    Application.ProcessMessages;
  End;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  // Convert Datasheet values to "per core"
  edit5.text := inttostr(strtoint(edit1.text) Div strtoint(edit4.text));
  edit6.text := inttostr(strtoint(edit2.text) Div strtoint(edit4.text));
  edit7.text := edit3.text;
End;

Procedure TForm1.Button2Click(Sender: TObject);
Var
  L1_Bytes, L2_Bytes, L3_Bytes, RAM_Bytes: Int64;
Begin
  // Run Tests
  CheckBox2.Enabled := false; // Disallow show results during calculation -> otherwise it could crash
  If CheckBox2.Checked Then Begin
    StringGrid1.ColCount := length(Benchmark) + 2;
    StringGrid1.Cells[StringGrid1.ColCount - 1, 0] := 'Sums';
  End
  Else Begin
    StringGrid1.ColCount := length(Benchmark) + 1;
  End;
  ClearResults();
  L1_Bytes := strtoint(edit5.text) * 1024; // L1_Bytes in Byte
  L2_Bytes := strtoint(edit6.text) * 1024; // L2_Bytes in Byte
  L3_Bytes := strtoint(edit7.text) * 1024 * 1024; // L3_Bytes in Byte
  RAM_Bytes := L3_Bytes * 8; // More that all caches can handle ;)
  memo1.Append('Run tests with:');
  memo1.Append(format('L1_Bytes=%d, L2_Bytes=%d, L3_Bytes=%d, RAM_Bytes=%d, Index shuffling=%s',
    [L1_Bytes, L2_Bytes, L3_Bytes, RAM_Bytes, ifthen(CheckBox1.Checked, 'on', 'off')]));
  // Preallocate RAM_Bytes for all tests
  SetLength(DataArray, RAM_Bytes);
  SetLength(IndexArray, RAM_Bytes);
  Best := high(integer);
  Worst := 0;
  // Do the tests for all categories ..
  IterateOverDataArray(1, L1_Bytes, RAM_Bytes);
  IterateOverDataArray(2, L2_Bytes, RAM_Bytes);
  IterateOverDataArray(3, L3_Bytes, RAM_Bytes);
  IterateOverDataArray(4, RAM_Bytes, RAM_Bytes);
  If best <> 0 Then Begin
    memo1.Append(format('Best run: %0.2fms, worst run: %0.2fms, worst / best: %0.2f', [best, worst, worst / best]));
  End;
  memo1.Append('done.');
  CheckBox2.Enabled := true;
End;

Procedure TForm1.ClearResults;
Var
  i, j: Integer;
Begin
  memo1.clear;
  For i := 1 To StringGrid1.ColCount - 1 Do Begin
    For j := 1 To StringGrid1.RowCount - 1 Do Begin
      StringGrid1.Cells[i, j] := '';
    End;
  End;
  For i := 0 To high(Curves) Do
    Curves[i].Clear;
End;

Procedure TForm1.Button6Click(Sender: TObject);
Begin
  Close;
End;

Procedure TForm1.Chart1AxisList0GetMarkText(Sender: TObject; Var AText: String;
  AMark: Double);
Begin
  atext := format('%0.1f', [power(10, AMark)]);
End;

Procedure TForm1.Chart1AxisList1GetMarkText(Sender: TObject; Var AText: String;
  AMark: Double);
Begin
  atext := 'V' + inttostr(round(AMark));
End;

Procedure TForm1.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
Begin
  SetLength(DataArray, 0);
  SetLength(IndexArray, 0);
End;

End.

