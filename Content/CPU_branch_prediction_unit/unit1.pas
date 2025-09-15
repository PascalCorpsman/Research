(******************************************************************************)
(* CPU_branch_prediction_unit                                      10.08.2025 *)
(*                                                                            *)
(* Version     : 0.01                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Demo to show the CPU-branch-prediction-unit at work          *)
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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

Type

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
  private

  public

  End;

Var
  Form1: TForm1;
  Raw: Array Of byte;
  RawSorted: Array Of byte;

Implementation

{$R *.lfm}

Const
  RawSize = 10000000;

Function CalcSums(Const a: Array Of Byte): Tpoint;
Var
  i: Integer;
Begin
  result.x := 0;
  result.Y := 0;
  For i := 0 To high(a) Do Begin
    result.x := result.x + a[i];
    If a[i] < 128 Then result.y := result.y + a[i];
  End;
End;

Function CalcSums2(Const a: Array Of Byte): Tpoint;
Var
  i: Integer;
  tmp: Byte;
Begin
  result.x := 0;
  result.y := 0;
  For i := 0 To high(a) Do Begin
    result.x := result.x + a[i];
    // Reduce the 128 bit to 0/1 and multiply a[i] with it, for the <128 Sum
    // By doing this we can get rid of the "If a[i] < 128 Then"
    tmp := (Byte((Not a[i]) Shr 7)) * a[i];
    result.y := result.y + tmp;
  End;
End;

Procedure Quicksort(Var Arr: Array Of byte);
  Procedure Quick(li, re: integer);
  Var
    l, r: Integer;
    h, p: Byte;
  Begin
    If Li < Re Then Begin
      p := arr[Trunc((li + re) / 2)];
      l := Li;
      r := re;
      While l < r Do Begin
        While arr[l] < p Do
          inc(l);
        While arr[r] > p Do
          dec(r);
        If L <= R Then Begin
          h := arr[l];
          arr[l] := arr[r];
          arr[r] := h;
          inc(l);
          dec(r);
        End;
      End;
      quick(li, r);
      quick(l, re);
    End;
  End;
Begin
  Quick(0, high(arr));
End;

{ TForm1 }

Procedure TForm1.FormCreate(Sender: TObject);
Var
  i: Integer;
Begin
  // Quelle: https://www.youtube.com/watch?v=-HNpim5x-IE
  caption := 'CPU branch prediction unit test, ver 0.01 by Corpsman';
  setlength(raw, RawSize);
  setlength(RawSorted, RawSize);
  Randomize;
  For i := 0 To high(raw) Do Begin
    raw[i] := random(256);
    RawSorted[i] := raw[i];
  End;
  Quicksort(RawSorted);
End;

Procedure TForm1.Button1Click(Sender: TObject);
Var
  start: QWord;
  p: TPoint;
Begin
  start := GetTickCount64;
  p := CalcSums(raw);
  Start := GetTickCount64 - start;
  label1.caption :=
    format(
    'Unsorted' + LineEnding +
    'Time     : %d[ms]' + LineEnding +
    'Sum      : %d' + LineEnding +
    '<128 Sum : %d',
    [start, p.x, p.y]);
End;

Procedure TForm1.Button2Click(Sender: TObject);
Var
  start: QWord;
  p: TPoint;
Begin
  (*
   * The Power of BranchPrediction, reduces the execution speed by factor 2 ;)
   *)
  start := GetTickCount64;
  p := CalcSums(RawSorted);
  Start := GetTickCount64 - start;
  label2.caption :=
    format(
    'Sorted, with branch' + LineEnding +
    'Time     : %d[ms]' + LineEnding +
    'Sum      : %d' + LineEnding +
    '<128 Sum : %d',
    [start, p.x, p.y]);
End;

Procedure TForm1.Button3Click(Sender: TObject);
Var
  start: QWord;
  p: TPoint;
Begin
  start := GetTickCount64;
  p := CalcSums2(raw);
  Start := GetTickCount64 - start;
  label3.caption :=
    format(
    'Unsorted, no branch' + LineEnding +
    'Time     : %d[ms]' + LineEnding +
    'Sum      : %d' + LineEnding +
    '<128 Sum : %d',
    [start, p.x, p.y]);
End;

Procedure TForm1.Button4Click(Sender: TObject);
Var
  start: QWord;
  p: TPoint;
Begin
  start := GetTickCount64;
  p := CalcSums2(RawSorted);
  Start := GetTickCount64 - start;
  label4.caption :=
    format(
    'Sorted, no branch' + LineEnding +
    'Time     : %d[ms]' + LineEnding +
    'Sum      : %d' + LineEnding +
    '<128 Sum : %d',
    [start, p.x, p.y]);

End;

Procedure TForm1.Button5Click(Sender: TObject);
Begin
  close;
End;

End.

