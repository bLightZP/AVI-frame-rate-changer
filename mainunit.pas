unit mainunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TMainForm = class(TForm)
    BrowseButton: TSpeedButton;
    AVIName: TEdit;
    OpenDialog: TOpenDialog;
    NewFrameRate: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    CurFrameRate: TEdit;
    Panel1: TPanel;
    ApplyButton: TSpeedButton;
    QuitButton: TSpeedButton;
    procedure AVINameEnter(Sender: TObject);
    procedure QuitButtonClick(Sender: TObject);
    procedure BrowseButtonClick(Sender: TObject);
    procedure NewFrameRateKeyPress(Sender: TObject; var Key: Char);
    procedure ApplyButtonClick(Sender: TObject);
    procedure ReadFrameRate(FileName : String);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure FRateLoad(FileName : String);
  end;


Const
  DefScale : Integer = 100000;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.AVINameEnter(Sender: TObject);
begin
  MainForm.ActiveControl := nil;
end;

procedure TMainForm.QuitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FRateLoad(FileName : String);
begin
  ReadFrameRate(FileName);
  AVIName.Text := ExtractFileName(FileName);
  AVIName.Hint := FileName;
  ApplyButton.Enabled := True;
end;

procedure TMainForm.BrowseButtonClick(Sender: TObject);
begin
  If OpenDialog.Execute = True then
  Begin
    FRateLoad(OpenDialog.FileName);
  End;
end;

procedure TMainForm.NewFrameRateKeyPress(Sender: TObject; var Key: Char);
begin
  If (Key <> #8) and (Key <> '.') then
    If (Ord(Key) < Ord('0')) or (Ord(Key) > Ord('9')) then Key := #0;
end;

procedure TMainForm.ReadFrameRate(FileName : String);
var
  F     : File;
  Scale : Integer;
  Rate  : Integer;
  S     : String;
begin
  OpenDialog.FileName := FileName;
  AssignFile(F,FileName);
  {$I-}
  Reset(F,1);
  {$I+}
  If IOResult = 0 then
  Begin
    Seek(F,128);
    BlockRead(F,Scale,4);
    BlockRead(F,Rate,4);
    CloseFile(F);
    Str((Rate / Scale):0:4,S);
    While (S[Length(S)] = '0') and (Length(S) > 1) and (S[Length(S)-1] <> '.') do
      Delete(S,Length(S),1);
    CurFrameRate.Text := S;
    NewFrameRate.Text := S;
  End
end;

procedure TMainForm.ApplyButtonClick(Sender: TObject);
var
  rRate : Real;
  iRate : Integer;
  ECode : Integer;
  F     : File;
begin
  Val(NewFrameRate.Text,rRate,ECode);
  iRate := Round(rRate*DefScale);
  AssignFile(F,OpenDialog.FileName);
  {$I-}
  Reset(F,1);
  {$I+}
  If IOResult = 0 then
  Begin
    Seek(F,128);
    BlockWrite(F,DefScale,4);
    BlockWrite(F,iRate,4);
    CloseFile(F);
    ReadFrameRate(OpenDialog.FileName);
    Messagedlg('New frame rate set.',mtInformation,[mbok],0);
  End
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  If ParamCount > 0 then FRateLoad(ParamStr(1));
end;

end.
