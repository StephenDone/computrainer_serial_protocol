unit CtSniffer;

interface

Uses
//  SysUtils,
  Classes,

  ComPort,

  CtData,
  CtFuncs;

Type
  TRawBytesEvent    = procedure( Const buf:TArray<byte> ) of object;
  TRawPacketEvent   = procedure( Const buf:TArray<byte> ) of object;
  TPacketEvent      = procedure( Const data:TCtData     ) of object;

  TCtStateChangeEvent = procedure( Const state:TCtState; Const StateChange : TCtStateChange ) of object;
  TPcStateChangeEvent = procedure( Const state:TPcState; Const StateChange : TPcStateChange ) of object;

  TCtSniffer = Class( TComponent )
  private
    ComPortCt: TComPort;
    ComPortPC: TComPort;

    RxBufCt : TArray<byte>;
    RxBufPc : TArray<byte>;

    CtState     : TCtState;
    PcState     : TPcState;

    FOnCtRawBytes   : TRawBytesEvent;
    FOnCtRawPacket  : TRawPacketEvent;
    FOnCtPacket     : TPacketEvent;
    FOnCtStateChange: TCtStateChangeEvent;

    FOnPcRawBytes   : TRawBytesEvent;
    FOnPcRawPacket  : TRawPacketEvent;
    FOnPcPacket     : TPacketEvent;
    FOnPcStateChange: TPcStateChangeEvent;

    procedure ComPortCtRxChar(Sender: TObject);
    procedure ComPortPCRxChar(Sender: TObject);

    procedure DoCtRawBytes   ( Const buf:TArray<byte> );
    procedure DoCtRawPacket  ( Const buf:TArray<byte> );
    procedure DoCtPacket     ( Const data:TCtData     );
    procedure DoCtStateChange( Const state:TCtState; Const StateChange: TCtStateChange );

    procedure DoPcRawBytes   ( Const buf:TArray<byte> );
    procedure DoPcRawPacket  ( Const buf:TArray<byte> );
    procedure DoPcPacket     ( Const data:TCtData     );
    procedure DoPcStateChange( Const state:TPcState; Const StateChange: TPcStateChange );
  public

    constructor Create(AOwner: TComponent); override;
    procedure Open();
    procedure Close();

    procedure ClearState();

    property OnCtRawBytes    :TRawBytesEvent      read FOnCtRawBytes    write FOnCtRawBytes;
    property OnCtRawPacket   :TRawPacketEvent     read FOnCtRawPacket   write FOnCtRawPacket;
    property OnCtPacket      :TPacketEvent        read FOnCtPacket      write FOnCtPacket;
    property OnCtStateChange :TCtStateChangeEvent read FOnCtStateChange write FOnCtStateChange;

    property OnPcRawBytes    :TRawBytesEvent      read FOnPcRawBytes    write FOnPcRawBytes;
    property OnPcRawPacket   :TRawPacketEvent     read FOnPcRawPacket   write FOnPcRawPacket;
    property OnPcPacket      :TPacketEvent        read FOnPcPacket      write FOnPcPacket;
    property OnPcStateChange :TPcStateChangeEvent read FOnPcStateChange write FOnPcStateChange;
  End;

implementation

{ TCtSniffer }

//------------------------------------------------------------------------------
constructor TCtSniffer.Create(AOwner: TComponent);
begin
  inherited;

  ComPortCt := TComPort.Create( Self );
  With ComPortCt
  do begin
    BaudRate   := br2400;
    DataBits   := db8;
    DeviceName := 'COM7';
    Parity     := paNone;
    StopBits   := sb1;
    OnRxChar   := ComPortCtRxChar;
  end;

  ComPortPC := TComPort.Create( Self );
  With ComPortPc
  do begin
    BaudRate   := br2400;
    DataBits   := db8;
    DeviceName := 'COM8';
    Parity     := paNone;
    StopBits   := sb1;
    OnRxChar   := ComPortPcRxChar;
  end;

end;

//------------------------------------------------------------------------------
procedure TCtSniffer.DoCtRawBytes(const buf: TArray<byte>);
begin
  if Assigned( FOnCtRawBytes ) then FOnCtRawBytes( buf );
end;
procedure TCtSniffer.DoPcRawBytes(const buf: TArray<byte>);
begin
  if Assigned( FOnPcRawBytes ) then FOnPcRawBytes( buf );
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.DoCtRawPacket(const buf: TArray<byte>);
begin
  if Assigned( FOnCtRawPacket ) then FOnCtRawPacket( buf );
end;
procedure TCtSniffer.DoPcRawPacket(const buf: TArray<byte>);
begin
  if Assigned( FOnPcRawPacket ) then FOnPcRawPacket( buf );
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.DoCtPacket(const data: TCtData);
begin
  if Assigned( FOnCtPacket ) then FOnCtPacket( data );
end;
procedure TCtSniffer.DoPcPacket(const data: TCtData);
begin
  if Assigned( FOnPcPacket ) then FOnPcPacket( data );
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.DoCtStateChange(const state: TCtState; Const StateChange: TCtStateChange);
begin
  if Assigned( FOnCtStateChange ) then FOnCtStateChange( state, StateChange );
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.DoPcStateChange(const state: TPcState; Const StateChange: TPcStateChange);
begin
  if Assigned( FOnPcStateChange ) then FOnPcStateChange( state, StateChange );
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.Close;
begin
  ComPortCt.Close;
  ComPortPc.Close;
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.Open;
begin
  ComPortCt.Open;
  ComPortPc.Open;
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.ClearState;
begin
  ClearCtState( CtState );
  ClearPcState( PcState );
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.ComPortCtRxChar(Sender: TObject);
var
  buf         : TArray<byte>;
  packet      : TArray<byte>;
  data        : TCTData;
  StateChange : TCtStateChange;
begin
  buf :=  ComPortCt.ReadBytes;

  DoCtRawBytes( buf );

  RxBufCt := RxBufCt + buf;

  if processRxData( RxBufCt, packet )
  then begin
    DoCtRawPacket( packet );

    CtPacketToFields( packet,  data );

    DoCtPacket( data );

    CtFieldsToState( data, CtState, StateChange );

    DoCtStateChange( CtState, StateChange );
  end;
end;

//------------------------------------------------------------------------------
procedure TCtSniffer.ComPortPCRxChar(Sender: TObject);
var
  buf         : TArray<byte>;
  packet      : TArray<byte>;
  data        : TCTData;
  StateChange : TPcStateChange;
begin
  buf :=  ComPortPC.ReadBytes;

  DoPcRawBytes( buf );

  RxBufPc := RxBufPc + buf;

  if processRxData( RxBufPc, packet )
  then begin
    DoPcRawPacket( packet );

    PcPacketToFields( packet,  data );

    DoPcPacket( data );

    PcFieldsToState( data, PcState, StateChange );

    DoPcStateChange( PcState, StateChange );
  end;
end;

end.
