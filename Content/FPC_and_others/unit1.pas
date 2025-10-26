(******************************************************************************)
(* FPC_and_others                                                  24.10.2025 *)
(*                                                                            *)
(* Version     : 0.01                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Demo application to show how to Integrate c code into a      *)
(*               FreePascal application                                       *)
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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uCWrapper;

Type

  { TForm1 }

  TForm1 = Class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RadioGroup1: TRadioGroup;
    Procedure Button10Click(Sender: TObject);
    Procedure Button11Click(Sender: TObject);
    Procedure Button12Click(Sender: TObject);
    Procedure Button13Click(Sender: TObject);
    Procedure Button14Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    Procedure Button5Click(Sender: TObject);
    Procedure Button6Click(Sender: TObject);
    Procedure Button7Click(Sender: TObject);
    Procedure Button8Click(Sender: TObject);
    Procedure Button9Click(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var CloseAction: TCloseAction);
    Procedure FormCreate(Sender: TObject);
  private
    DummyClassInstance: DummyClass;
  public

  End;

Var
  Form1: TForm1;

Implementation

{$R *.lfm}

Uses ctypes;

{ TForm1 }

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  caption := 'FPC and others ver. 0.01 by Corpsman';
  edit1.text := '1';
  edit2.text := '2';
  edit3.text := '1,2,3,4';
  edit4.text := '1';
  edit5.text := '2';
  edit6.text := '3';
  edit7.text := '4';
  edit8.text := '21';
  DummyClassInstance := Nil;
End;

Procedure TForm1.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
Begin
  Button8.Click;
  UnLoadLib;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
  print_HelloWorld();
End;

Procedure TForm1.Button10Click(Sender: TObject);
Begin
  If Not assigned(DummyClassInstance) Then Button7.Click;
  print_a_from_Dummy_class(DummyClassInstance);
End;

Procedure TForm1.Button11Click(Sender: TObject);
Begin
  print_HelloWorld_from_a();
End;

Procedure TForm1.Button12Click(Sender: TObject);
Begin
  print_HelloWorld_from_lib1();
End;

Procedure TForm1.Button13Click(Sender: TObject);
Begin
  If Not assigned(print_HelloWorld_from_lib2) Then LoadLib;
  print_HelloWorld_from_lib2();
End;

Procedure TForm1.Button14Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm1.Button2Click(Sender: TObject);
Var
  a, b: integer;
Begin
  a := strtointdef(edit1.text, 0);
  b := strtointdef(edit2.text, 0);
  print_a_plus_b(a, b);
End;

Procedure TForm1.Button3Click(Sender: TObject);
Var
  a, b, res: Integer;
Begin
  a := strtointdef(edit1.text, 0);
  b := strtointdef(edit2.text, 0);
  res := calc_a_plus_b(a, b);
  showmessage(inttostr(res));
End;

Procedure TForm1.Button4Click(Sender: TObject);
Var
  a: TStringArray;
  b: Array Of cuint8;
  s: String;
  i: Integer;
Begin
  s := Edit3.Text;
  a := s.Split(',');
  b := Nil;
  setlength(b, length(a));
  For i := 0 To high(a) Do Begin
    b[i] := strtointdef(a[i], 0);
  End;
  plott_array(b, length(b));
End;

Procedure TForm1.Button5Click(Sender: TObject);
  Function IndexToElement(index: integer): MyEnum_t;
  Begin
    result := eA;
    Case index Of
      1: result := eB;
      2: result := eC;
      3: result := eD;
    End;
  End;
Var
  r: MyStruct_t;
  e: MyEnum_t;
Begin
  r.a := strtointdef(edit4.text, 0);
  r.b := strtointdef(edit5.text, 0);
  r.c := strtointdef(edit6.text, 0);
  r.d := strtointdef(edit7.text, 0);
  e := IndexToElement(RadioGroup1.ItemIndex);
  print_struct_element(r, e);
End;

Procedure TForm1.Button6Click(Sender: TObject);
Begin
  call_c();
End;

Procedure TForm1.Button7Click(Sender: TObject);
Begin
  If assigned(DummyClassInstance) Then Button8.Click;
  DummyClassInstance := create_Dummy_class();
End;

Procedure TForm1.Button8Click(Sender: TObject);
Begin
  If assigned(DummyClassInstance) Then destroy_Dummy_class(DummyClassInstance);
  DummyClassInstance := Nil;
End;

Procedure TForm1.Button9Click(Sender: TObject);
Begin
  If Not assigned(DummyClassInstance) Then Button7.Click;
  call_B_from_Dummy_class(DummyClassInstance, strtointdef(edit8.text, 0));
End;

End.

