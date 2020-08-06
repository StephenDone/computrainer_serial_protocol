unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ComPort, Vcl.ExtCtrls,

  CtData,
  CtFuncs,
  CtSniffer, Vcl.ComCtrls;

type
  TFormMain = class(TForm)
    Panel3: TPanel;
    grpDebug: TGroupBox;
    chkDebugRaw: TCheckBox;
    chkDebugRawPackets: TCheckBox;
    chkDebugFields: TCheckBox;
    chkDebugState: TCheckBox;
    chkDebugStateChanges: TCheckBox;
    grpPort: TGroupBox;
    Close: TButton;
    btnOpen: TButton;
    btnClearDebug: TButton;
    chkDebugSpinscanValues: TCheckBox;
    chkDebugParamValues: TCheckBox;
    chkDebugButtonValues: TCheckBox;
    btnClearState: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    memoCtData: TMemo;
    memoPcData: TMemo;
    Panel5: TPanel;
    memoPcState: TMemo;
    memoCtState: TMemo;
    Panel4: TPanel;
    memoPcStateChange: TMemo;
    memoCtStateChange: TMemo;
    Splitter2: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnClearDebugClick(Sender: TObject);
    procedure Panel6Resize(Sender: TObject);
    procedure chkDebugSpinscanValuesClick(Sender: TObject);
    procedure chkDebugParamValuesClick(Sender: TObject);
    procedure chkDebugButtonValuesClick(Sender: TObject);
    procedure btnClearStateClick(Sender: TObject);
    procedure PageControl1Resize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CtSniffer : TCtSniffer;

    ShowCtStateFields : TCtFieldSet;
    ShowPcStateFields : TPcFieldSet;

    procedure SnifferCtRawBytes    ( Const buf:TArray<byte> );
    procedure SnifferCtRawPacket   ( Const buf:TArray<byte> );
    procedure SnifferCtPacket      ( Const data:TCtData     );
    procedure SnifferCtStateChange ( Const state:TCtState; Const StateChange : TCtStateChange );

    procedure SnifferPcRawBytes    ( Const buf:TArray<byte> );
    procedure SnifferPcRawPacket   ( Const buf:TArray<byte> );
    procedure SnifferPcPacket      ( Const data:TCtData     );
    procedure SnifferPcStateChange ( Const state:TPcState; Const StateChange : TPcStateChange );
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

Uses CtDebug;

//------------------------------------------------------------------------------
procedure TFormMain.FormCreate(Sender: TObject);

  procedure DebugCrc( Const Value:Word );
  begin
    with MemoPcStateChange.Lines
    do begin
      Add( Format( 'CRC(0x%2.2x)=0x%2.2x', [ Value, CalcCRC(Value) ] ));
    end;
  end;

begin
  CtSniffer := TCtSniffer.Create( Self );
  with CtSniffer
  do begin
    OnCtRawBytes    := SnifferCtRawBytes    ;
    OnCtRawPacket   := SnifferCtRawPacket   ;
    OnCtPacket      := SnifferCtPacket      ;
    OnCtStateChange := SnifferCtStateChange ;
    OnPcRawBytes    := SnifferPcRawBytes    ;
    OnPcRawPacket   := SnifferPcRawPacket   ;
    OnPcPacket      := SnifferPcPacket      ;
    OnPcStateChange := SnifferPcStateChange ;
  end;

  ShowCtStateFields := [];
  ShowPcStateFields := [ pcfMode ];

  chkDebugSpinscanValues.Checked := False;
  chkDebugParamValues   .Checked := True;
  chkDebugButtonValues  .Checked := True;

  CtSniffer.Open;

//  DebugCRC( $00 );
end;

//------------------------------------------------------------------------------
procedure TFormMain.btnOpenClick(Sender: TObject);
begin
  CtSniffer.Open;
end;

//------------------------------------------------------------------------------
procedure TFormMain.btnClearStateClick(Sender: TObject);
begin
  CtSniffer.ClearState;
end;

//------------------------------------------------------------------------------
procedure TFormMain.btnCloseClick(Sender: TObject);
begin
  CtSniffer.Close;
end;

//------------------------------------------------------------------------------
procedure TFormMain.chkDebugButtonValuesClick(Sender: TObject);
begin
  if (Sender as TCheckbox).Checked
  then Include( ShowCtStateFields, ctfButton )
  else Exclude( ShowCtStateFields, ctfButton );
end;

//------------------------------------------------------------------------------
procedure TFormMain.chkDebugParamValuesClick(Sender: TObject);
begin
  if (Sender as TCheckbox).Checked
  then begin
    Include( ShowCtStateFields, ctfValues );
    Include( ShowPcStateFields, pcfValues );
  end
  else begin
    Exclude( ShowCtStateFields, ctfValues );
    Exclude( ShowPcStateFields, pcfValues );
  end;
end;

//------------------------------------------------------------------------------
procedure TFormMain.chkDebugSpinscanValuesClick(Sender: TObject);
begin
  if (Sender as TCheckbox).Checked
  then Include( ShowCtStateFields, ctfSpinScan )
  else Exclude( ShowCtStateFields, ctfSpinScan );
end;

//------------------------------------------------------------------------------
procedure TFormMain.btnClearDebugClick(Sender: TObject);
begin
  memoCtState      .Clear;
  memoCtData       .Clear;
  memoCtStateChange.Clear;
  memoPcState      .Clear;
  memoPcData       .Clear;
  memoPcStateChange.Clear;
end;

//------------------------------------------------------------------------------
procedure TFormMain.PageControl1Resize(Sender: TObject);
var
  w : integer;
begin
  w := (Sender as TControl).ClientWidth div 2;

  memoPcData       .Width := w;
//  memoPcState      .Width := w;
//  memoPcStateChange.Width := w;
end;

//------------------------------------------------------------------------------
procedure TFormMain.Panel6Resize(Sender: TObject);
begin
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferCtRawBytes(const buf: TArray<byte>);
begin
  if chkDebugRaw.Checked
  then DebugRawBytes( buf, MemoCtData.Lines );
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferCtRawPacket(const buf: TArray<byte>);
begin
  if chkDebugRawPackets.checked
  then DebugCtPacketBytes( buf, MemoCtData.Lines );
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferCtPacket(const data: TCtData);
begin
  if chkDebugFields.checked
  then begin
    DebugCtPacket( data, MemoCtData.Lines );
    DebugCtData  ( data, MemoCtData.Lines );
  end;
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferCtStateChange(const state: TCtState;
                                      const StateChange: TCtStateChange);
begin
  if chkDebugState.Checked
  AND (StateChange.Fields <> [])
  then begin
    MemoCtState.Clear;
    debugCtState( State, MemoCtState.Lines );
  end;

  if chkDebugStateChanges.Checked
  then begin
    debugCtStateChange( State, StateChange, MemoCtStateChange.Lines, ShowCtStateFields );
  end;
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferPcRawBytes(const buf: TArray<byte>);
begin
  if chkDebugRaw.Checked
  then DebugRawBytes( buf, MemoPcData.Lines );
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferPcRawPacket(const buf: TArray<byte>);
begin
  if chkDebugRawPackets.checked
  then DebugPcPacketBytes( buf, MemoPcData.Lines );
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferPcPacket(const data: TCtData);
begin
  if chkDebugFields.checked
  then begin
    debugPcPacket( data, MemoPcData.Lines );
    DebugPcData  ( data, MemoPcData.Lines );
  end;
end;

//------------------------------------------------------------------------------
procedure TFormMain.SnifferPcStateChange(const state: TPcState;
                                      const StateChange: TPcStateChange);
begin
  if chkDebugState.Checked
  AND ( StateChange.Fields <> [] )
  then begin
    MemoPcState.Clear;
    debugPcState( State, MemoPcState.Lines );
  end;

  if chkDebugStateChanges.Checked
  then begin
    DebugPcStateChange( State, StateChange, MemoPcStateChange.Lines, ShowPcStateFields );
  end;
end;

end.
