(******************************************************************************)
(* Gettickcount64                                                  15.09.2025 *)
(*                                                                            *)
(* Version     : 0.01                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Demo to show Gettickcount64 behavior on Linux / Windows      *)
(*                                                                            *)
(* License     : See the file license.md, located under:                      *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(* Warranty    : There is no warranty, neither in correctness of the          *)
(*               implementation, nor anything other that could happen         *)
(*               or go wrong, use at your own risk.                           *)
(*                                                                            *)
(* Known Issues: none                                                         *)
(*                                                                            *)
(* History     : 0.01 - Initial version                                       *)
(*                                                                            *)
(******************************************************************************)
Unit Unit1;

{$MODE objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  TAGraph, TASeries, EpikTimer;

Type

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    Chart1BarSeries2: TBarSeries;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    EpikTimer1: TEpikTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Chart1AxisList0MarkToText(Var AText: String; AMark: Double);
    Procedure FormCreate(Sender: TObject);
  private
    EpikMsData, MsData: Array[0..1024] Of Integer; // Measured Data
    Procedure MsDataToChart(IgnoreZeroValues: Boolean = true);
    Procedure EpikMsDataToChart(IgnoreZeroValues: Boolean = true);
  public

  End;

Var
  Form1: TForm1;

Implementation

{$R *.lfm}

Uses LCLVersion, LCLType, math;

Var
  LoopCounter: integer = -1;
  Calibms: integer = -1;

Procedure Nop();
Begin

End;

Type

  TThreadState =
    (
    tsinitialized,
    tsworkdone
    );
  { TLoadThread }

  TLoadThread = Class(TThread)
  protected
    Procedure Execute; override;
  public
    ThreadState: TThreadState;
  End;

  (*
   * Creates CPU Load, and calculates nonesense
   *)

Function StrangeFunction(): UInt64;
Var
  Data: Array[0..16] Of integer;
  i: Integer;
Begin
  // 1. Init
  For i := 0 To 7 Do Begin
    Data[i] := i;
    Data[i + 8] := i;
  End;
  result := 0;
  // 2. Do the calculations
  For i := 0 To LoopCounter - 1 Do Begin
    result := result + Data[i Mod 8];
    Data[i Mod 8] := Data[i Mod 8 + 8] + Data[i Mod 8 + 8];
    result := result - Data[i Mod 8 + 8];
    inc(Data[i Mod 8 + 8]);
    dec(Data[i Mod 8]);
  End;
End;

{ TLoadThread }

Procedure TLoadThread.Execute;
Begin
  StrangeFunction();
  ThreadState := tsworkdone;
End;

{ TForm1 }

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  caption := 'Gettickcount evaluater, ver. 0.01 by Corpsman';
  label3.caption :=
{$IFDEF Windows}
  'Windows '
{$ELSE}
{$IFDEF Linux}
  'Linux '
{$ELSE}
  'Unknown OS '
{$ENDIF}
{$ENDIF}
  + inttostr(sizeof(Pointer) * 8) + ' Bit' + LineEnding +
    'Used Lazarus IDE ' + lcl_version + LineEnding +
    'Compiled with FPC ' + {$I %FPCVERSION%};
  Edit1.text := '100';
  label1.caption := '';
  button5.click;
  label1.caption := '';
End;

Procedure TForm1.MsDataToChart(IgnoreZeroValues: Boolean);
Var
  index, i: Integer;
Begin
  Chart1BarSeries1.Clear;
  // 1. das Höchste Element <> 0 finden
  index := 0;
  For i := high(MsData) Downto 1 Do Begin
    If MsData[i] <> 0 Then Begin
      index := i;
      break;
    End;
  End;
  // 2. Ausgeben
  For i := 0 To index Do Begin
    If (Not IgnoreZeroValues) Or (MsData[i] <> 0) Then Begin
      Chart1BarSeries1.AddXY(i, MsData[i]);
    End;
  End;
  Chart1.Invalidate;
End;

Procedure TForm1.EpikMsDataToChart(IgnoreZeroValues: Boolean);
Var
  index, i: Integer;
Begin
  // Umstellen, so dass beide Graphen nebeneinander angezeigt werden
  Chart1BarSeries1.BarWidthStyle := bwPercentMin;
  Chart1BarSeries1.BarOffsetPercent := -20;
  Chart1BarSeries1.BarWidthPercent := 40;
  Chart1BarSeries2.BarWidthStyle := bwPercentMin;
  Chart1BarSeries2.BarOffsetPercent := 20;
  Chart1BarSeries2.BarWidthPercent := 40;
  Chart1BarSeries2.Clear;
  // 1. das Höchste Element <> 0 finden
  index := 0;
  For i := high(EpikMsData) Downto 1 Do Begin
    If EpikMsData[i] <> 0 Then Begin
      index := i;
      break;
    End;
  End;
  // 2. Ausgeben
  For i := 0 To index Do Begin
    If (Not IgnoreZeroValues) Or (MsData[i] <> 0) Then Begin
      Chart1BarSeries2.AddXY(i, EpikMsData[i]);
    End;
  End;
  Chart1.Invalidate;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Var
  val: UInt64;
  r: Boolean;
  s: Single;
Begin
  (*
   * Try to adjust LoopCounter in that way, that
   * StrangeFunction will take approx 10 to 20ms to be calculated
   *)
  label1.caption := '';
  Calibms := -1;
  LoopCounter := 1250000;
  Repeat
    r := false;
    EpikTimer1.Clear;
    EpikTimer1.Start;
    val := StrangeFunction();
    EpikTimer1.Stop; // the timer is actually paused and can be restarted later
    s := EpikTimer1.Elapsed; // store the elapsed in a global
    If s < 0.010 Then Begin
      // Detect a overflow of LoopCounter
      If high(integer) Div 2 < LoopCounter Then Begin
        showmessage('Error, the CPU is to "strong", use a different "StrangeFunction"');
        LoopCounter := -1;
        exit;
      End
      Else Begin
        LoopCounter := LoopCounter * 2;
        r := true;
      End;
    End;
    If s > 0.020 Then Begin
      // Detect a underflow of LoopCounter
      If LoopCounter <= 2 Then Begin
        showmessage('Error, the CPU is to "weak", use a different "StrangeFunction"');
        LoopCounter := -1;
        exit;
      End
      Else Begin
        LoopCounter := LoopCounter Div 2;
        r := true;
      End;
    End;
  Until Not r;
  Calibms := round(s * 1000);
  label1.caption := format('%d iteration took ~%dms', [LoopCounter, Calibms]);
End;

Procedure TForm1.Button2Click(Sender: TObject);
Var
  iterations: integer;
  r: UInt64;
  epikdiff, total, start: QWord;
  oorc, i: Integer;
Begin
  If LoopCounter = -1 Then Begin // Adjust Loopcounter first
    Button1.Click;
    If LoopCounter = -1 Then exit;
  End;
  // Loop and meassure with gettickcount64
  iterations := strtointdef(edit1.text, 0);
  // Heuristic that is triggered, if evaluation takes longer than 10s
  If iterations * Calibms / 1000 > 10 Then Begin
    If id_No = Application.MessageBox(pchar(format('The tests will take aproximatly %0.1fs, are you shure you will continue?', [iterations * Calibms / 1000])), 'Question', MB_YESNO Or MB_ICONQUESTION) Then Begin
      exit;
    End;
  End;
  Button5.Click; // Clear
  oorc := 0;
  total := GetTickCount64;
  For i := 0 To iterations - 1 Do Begin
    EpikTimer1.Clear;
    start := GetTickCount64;
    EpikTimer1.Start;
    r := StrangeFunction();
    epikdiff := round(EpikTimer1.Elapsed() * 1000);
    start := GetTickCount64 - start;
    If (start <= high(MsData)) Then Begin
      inc(EpikMsData[epikdiff]);
      MsData[start] := MsData[start] + 1;
    End
    Else Begin
      oorc := oorc + 1;
    End;
    If (i > 0) And (i Mod 100 = 0) And CheckBox1.Checked Then Begin
      MsDataToChart(false);
      EpikMsDataToChart(false);
      Application.ProcessMessages;
    End;
  End;
  total := GetTickCount64 - total;
  MsDataToChart(false);
  EpikMsDataToChart(false);
  memo1.Append('Loop and meassure with gettickcount64');

  memo1.Append(format('Execution took: %0.2fs (measured)', [total / 1000]));
  memo1.Append(format('Avg. time per iteration: %0.2fms (measured)', [total / iterations]));
  total := 0;
  For i := 1 To high(MsData) Do Begin
    total := total + MsData[i] * i;
  End;
  memo1.Append(format('Avg. time per iteration: %0.2fms (calculated)', [total / iterations]));
  memo1.Append('Red = Gettickcount64, blue = EpikTimer');
  If oorc <> 0 Then Begin
    showmessage('Error, there where ' + inttostr(oorc) + ' measurements, that where not in range of 0 .. 1023ms');
  End;
End;

Procedure TForm1.Button3Click(Sender: TObject);
Var
  iterations, i: Integer;
  EpikDiff, start, total: QWord;
Begin
  //Sleep (1) test
  iterations := strtointdef(edit1.text, 0);
  // Heuristic that is triggered, if evaluation takes longer than 10s
  //If iterations * 0.001 > 10 Then Begin
  //  If id_No = Application.MessageBox(pchar(format('The tests will take aproximatly %0.1fs, are you shure you will continue?', [iterations * Calibms / 1000])), 'Question', MB_YESNO Or MB_ICONQUESTION) Then Begin
  //    exit;
  //  End;
  //End;
  Button5.Click; // Clear
  total := GetTickCount64;
  For i := 0 To iterations - 1 Do Begin
    start := GetTickCount64;
    EpikTimer1.Clear;
    EpikTimer1.Start;
    sleep(1);
    epikdiff := round(EpikTimer1.Elapsed() * 1000);
    start := GetTickCount64 - start;
    If (start <= high(MsData)) Then Begin
      MsData[start] := MsData[start] + 1;
      inc(EpikMsData[epikdiff]);
    End
    Else Begin
      //      oorc := oorc + 1;
    End;
    If (i > 0) And (i Mod 100 = 0) And CheckBox1.Checked Then Begin
      MsDataToChart(false);
      EpikMsDataToChart(false);
      Application.ProcessMessages;
    End;
  End;
  total := GetTickCount64 - total;
  MsDataToChart(false);
  EpikMsDataToChart(false);
  memo1.Append('Sleep(1) test.');
  memo1.Append(format('Execution took: %0.2fs (measured)', [total / 1000]));
  memo1.Append('Red = Gettickcount64, blue = EpikTimer');
End;

Procedure TForm1.Button4Click(Sender: TObject);
Var
  iterations, i, j: Integer;
  epikdiff, start, total: QWord;
Begin
  //Sleep (1..15) burst test
  iterations := strtointdef(edit1.text, 0);
  // Heuristic that is triggered, if evaluation takes longer than 10s
  If iterations * 0.120 > 10 Then Begin
    If id_No = Application.MessageBox(pchar(format('The tests will take aproximatly %0.1fs, are you shure you will continue?', [iterations * 0.120])), 'Question', MB_YESNO Or MB_ICONQUESTION) Then Begin
      exit;
    End;
  End;
  Button5.Click; // Clear
  total := GetTickCount64;
  For i := 0 To iterations - 1 Do Begin
    For j := 1 To 15 Do Begin
      EpikTimer1.Clear;
      start := GetTickCount64;
      EpikTimer1.Start;
      sleep(j);
      epikdiff := round(EpikTimer1.Elapsed() * 1000);
      start := GetTickCount64 - start;
      If (start <= high(MsData)) Then Begin
        inc(EpikMsData[epikdiff]);
        MsData[start] := MsData[start] + 1;
      End;
      If (i > 0) And (i Mod 100 = 0) And CheckBox1.Checked Then Begin
        MsDataToChart(false);
        EpikMsDataToChart(false);
        Application.ProcessMessages;
      End;
    End;
  End;
  total := GetTickCount64 - total;
  MsDataToChart(false);
  EpikMsDataToChart(false);
  memo1.Append('Sleep(1..15) burst test.');
  memo1.Append(format('Execution took: %0.2fs (measured)', [total / 1000]));
  memo1.Append('Red = Gettickcount64, blue = EpikTimer');
End;

Procedure TForm1.Button5Click(Sender: TObject);
Var
  i: Integer;
Begin
  // Clear
  // Series1 zurückstellen auf "alleine" anzeigen.
  Chart1BarSeries1.BarOffsetPercent := 0;
  Chart1BarSeries1.BarWidthPercent := 70;
  Chart1BarSeries1.BarWidthStyle := bwPercentMin;
  // Das Eigentliche Löschen
  Chart1BarSeries1.Clear;
  Chart1BarSeries2.Clear;
  For i := 0 To high(MsData) Do Begin
    MsData[i] := 0;
    EpikMsData[i] := 0;
  End;
  memo1.clear;
End;

Procedure TForm1.Button6Click(Sender: TObject);
Begin
  Close;
End;

Procedure TForm1.Button7Click(Sender: TObject);
Var
  epikdiff, total, diff: QWord;
Begin
  // Poll "Gettickcount64" up to 32
  button5.click; // Clear
  EpikTimer1.Clear;
  total := GetTickCount64;
  EpikTimer1.Start;
  Repeat
    epikdiff := round(EpikTimer1.Elapsed() * 1000);
    diff := GetTickCount64 - Total;
    If diff < 32 Then Begin
      inc(EpikMsData[epikdiff]);
      inc(MsData[diff]);
    End;
  Until diff >= 32;
  total := diff;
  MsDataToChart(false);
  EpikMsDataToChart(false);
  memo1.Append('Poll "Gettickcount64" up to 32');
  memo1.Append(format('Execution took: %0.2fs (measured)', [total / 1000]));
  memo1.Append('Red = Gettickcount64, blue = EpikTimer');
End;

Procedure TForm1.Button8Click(Sender: TObject);
Const
  NumOfThreads = 8; // Adjust to the number of Cores your CPU has, but at least let it be 2 !
Var
  Thrds: Array[0..NumOfThreads - 1] Of TLoadThread;
  i: Integer;
  epikdiff, total, Start: QWord;
  b1: Boolean;
  iterations, j: Integer;
Begin
  // TThread beispiel
  If LoopCounter = -1 Then Begin // Adjust Loopcounter first
    Button1.Click;
    If LoopCounter = -1 Then exit;
  End;
  Button5.Click; // Clear
  total := GetTickCount64;
  iterations := strtointdef(edit1.text, 0);
  For j := 0 To iterations - 1 Do Begin
    For i := 0 To high(Thrds) Do Begin
      Thrds[i] := TLoadThread.create(true);
      Thrds[i].ThreadState := tsinitialized;
    End;
    EpikTimer1.Clear;
    Start := GetTickCount64;
    EpikTimer1.Start;
    For i := 0 To high(Thrds) Do Begin
      Thrds[i].Start;
    End;
    b1 := true;
    While b1 Do Begin
      b1 := false;
      For i := 0 To high(Thrds) Do Begin
        If Thrds[i].ThreadState = tsinitialized Then Begin
          CheckSynchronize(0); // Check for thread to be finished ..
          // CheckSynchronize(1); // Setting this to 1, waits usually additional 16ms on Windows for the sceduler to be ready
          b1 := true;
        End;
      End;
    End;
    epikdiff := round(EpikTimer1.Elapsed() * 1000);
    Start := GetTickCount64 - start;
    MsData[start] := MsData[start] + 1;
    inc(EpikMsData[epikdiff]);
    For i := 0 To high(Thrds) Do Begin
      Thrds[i].Free;
    End;
  End;
  total := GetTickCount64 - total;
  MsDataToChart(false);
  EpikMsDataToChart(false);
  memo1.Append('TThread parallel execution');
  memo1.Append(format('Execution took: %0.2fs (measured)', [total / 1000]));
  memo1.Append('Red = Gettickcount64, blue = EpikTimer');
End;

Procedure TForm1.Chart1AxisList0MarkToText(Var AText: String; AMark: Double);
Begin
  AText := inttostr(round(max(0, AMark)));
End;

End.

