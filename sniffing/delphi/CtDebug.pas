unit CtDebug;

interface

Uses
  Classes,
  CtData;

procedure DebugRawBytes( Const buf: TArray<byte>; Const Strings:TStrings );

procedure DebugCtPacketBytes( Const packet : TArray<byte>; Const Strings:TStrings );
procedure DebugPcPacketBytes( Const packet : TArray<byte>; Const Strings:TStrings );

procedure DebugCtPacket( Const Data:TCTData; Const Strings:TStrings );
procedure DebugPcPacket( Const Data:TCTData; Const Strings:TStrings );

procedure DebugCtData( Const Data:TCtData; Const Strings:TStrings );
procedure DebugPcData( Const Data:TCtData; Const Strings:TStrings );

procedure DebugCtState( Const State:TCtState; Const Strings:TStrings );
procedure DebugPcState( Const State:TPcState; Const Strings:TStrings );

procedure DebugCtStateChange( Const State:TCtState;   Const Change:TCtStateChange;
                              Const Strings:TStrings; Const Show  :TCtFieldSet );
procedure DebugPcStateChange( Const State:TPcState;   Const Change:TPcStateChange;
                              Const Strings:TStrings; Const Show  :TPcFieldSet );

function FormatSpinScanValue( Const Value:Byte ): String;
function FormatPcValue( Const i:integer; Const Value:Word ): String;

implementation

Uses
  SysUtils,
  CtFuncs;


//------------------------------------------------------------------------------
function button( Const state:boolean; Const name:string; Const Padded:Boolean=False ): string;
begin
	if state
  then
		result := ' ' + Uppercase(name)
	else begin
    if Padded
    then Result := StringOfChar( ' ', Length(name)+1 )
    else Result := '';
  end;
end;

//------------------------------------------------------------------------------
function hex2( const v:byte ): String;
begin
  result := '0x' + IntToHex(v,2);
end;

//------------------------------------------------------------------------------
function hex3( const v:word ): String;
begin
  result := '0x' + IntToHex(v,3);
end;

//------------------------------------------------------------------------------
function dec4( const v:word ): String;
begin
  result := Format( '%4.4d', [ v ] );
end;

//------------------------------------------------------------------------------
function bool( const b:boolean ): String; overload;
begin
  result := IntToStr( Ord( b ) );
end;

//------------------------------------------------------------------------------
function bool( const b:boolean; const trueval:string; const falseval:string='' ): String; overload;
begin
  if b
  then result := trueval
  else result := falseval;
end;

//------------------------------------------------------------------------------
function ba2hex( const ba:TArray<byte> ): String;
var
  b : byte;
begin
  result := '';

  for b in ba
  do result := result + IntToHex( b, 2 ) + ' ';

  result := trim( result );
end;

//------------------------------------------------------------------------------
procedure DebugRawBytes( Const buf: TArray<byte>; Const Strings:TStrings );
begin
  Strings.Add( 'Raw bytes: ' + ba2hex( buf ));
end;

//------------------------------------------------------------------------------
function CtPacketBytesToString( Const packet : TArray<byte> ): String;
begin
  Result := ba2hex( packet )
end;

//------------------------------------------------------------------------------
procedure DebugCtPacketBytes( Const packet : TArray<byte>; Const Strings:TStrings );
begin
  Strings.Add( CtPacketBytesToString( packet ));
end;

//------------------------------------------------------------------------------
function PcPacketBytesToString( Const packet : TArray<byte> ): String;
begin
  Result := ba2hex( packet );
end;

//------------------------------------------------------------------------------
procedure DebugPcPacketBytes( Const packet : TArray<byte>; Const Strings:TStrings );
begin
  Strings.Add( PcPacketBytesToString( packet ) );
end;

//------------------------------------------------------------------------------
procedure DebugCtSpinScan( Const State:TCTState; Const Strings:TStrings );
var
  i  : integer;
  s1 : string;
  s2 : string;
begin
  s1 := ''; s2 := '';

  for i := 0 to 11
  do begin
    s1 := s1 + Hex2(State.SpinScan[i]) + ' ';
    //s := s + Format( '%3d', [ Int8( State.SpinScan[i] ) ] ) + ' ';

    s2 := s2 + Hex2(State.SpinScan[i+12]) + ' ';
  end;

  Strings.Add( 'SpinScan:' );
  Strings.Add( Trim(s1) );
  Strings.Add( Trim(s2) );
  //Strings.Add( 'Next Idx: ' + IntToStr( State.NextSSIdx ) );
end;

//------------------------------------------------------------------------------
procedure DebugCtPacket( Const Data:TCTData; Const Strings:TStrings );
begin
  With Data
  do Strings.Add(
        'a:' + hex2( data.SpinScan[0] )
    + '  b:' + hex2( data.SpinScan[1] )
    + '  c:' + hex2( data.SpinScan[2] )
    + '  f:' + hex2( Buttons )
    + '  m:' + hex2( mode )
    + '  v:' + hex3( value ) + '(' + dec4( value ) +')'
    + '  z:' + bool(z)
  );
end;

//------------------------------------------------------------------------------
procedure DebugPcPacket( Const Data:TCTData; Const Strings:TStrings );
begin
  With Data
  do Strings.Add(
        'crc:' + hex2( data.SpinScan[0] )
    + '  b:' + hex2( data.SpinScan[1] )
    + '  c:' + hex2( data.SpinScan[2] )
    + '  mode:' + hex2( Buttons )
    + '  command:' + hex2( mode )
    + '  v:' + hex3( value ) + '(' + dec4( value ) +')'
    + '  z:' + bool(z)
    + '  CalcCRC:' + hex2( CalcCrc( value ) )
  );
end;

//------------------------------------------------------------------------------
function CtParamToString( Const Mode:Byte; Const Value:Word ): String;
begin
	Case Mode of
	1:   Result := '01 Speed:            ' + dec4(value);
	2:   Result := '02 Power:            ' + dec4(value);
	3:   Result := '03 Heart Rate:       ' + dec4(value AND $FF);
	6:   Result := '06 Cadence:          ' + dec4(value AND $FF);
	9:   Result := '09 Push on pressure: ' + Format( '%1.2f - ', [ (value AND $7FF)/$100 ] ) + bool( (value AND $800)=0, 'Uncalibrated', 'Calibrated' );
	11:  Result := '11 Sensors Present:  ' + hex3(value) + ' '
                 + bool(((value AND $800) SHR 11) <> 0, '  Cadence' )
                 + bool(((value AND $400) SHR 10) <> 0, '  HRM'     );
  12:  Result := '12 Message Sync:     ' + hex3(value);
  else Result :=
         Format('%2.2d Unknown Message:  12-bit: %.4d (%3.3x), 8-bit: %.3d (%2.2x)',
                           [ Mode, value,value,value AND $FF, value AND $FF ] );
	end;
end;

//------------------------------------------------------------------------------
procedure DebugCtParam( Const Mode:Byte; Const Value:Word; Const Strings:TStrings );
begin
  Strings.Add( CtParamToString( Mode, Value ) );
end;

//------------------------------------------------------------------------------
function CtButtonsToString( Const Buttons:TCtButtonSet; Const Padded:Boolean ): String;
begin
  Result := 'Buttons: [ ' +
    button( ctbReset in Buttons, 'reset', Padded )
  + button( ctbMinus in Buttons, 'minus', Padded )
  + button( ctbF2    in Buttons, 'F2'   , Padded )
  + button( ctbPlus  in Buttons, 'plus' , Padded )
  + button( ctbF3    in Buttons, 'F3'   , Padded )
  + button( ctbF1    in Buttons, 'F1'   , Padded )
  + ' ]' ;
end;

//------------------------------------------------------------------------------
procedure DebugCtButtons( Const Buttons:TCtButtonSet; Const Strings:TStrings );
begin
  Strings.Add( CtButtonsToString( Buttons, False ) );
end;

//------------------------------------------------------------------------------
procedure DebugCtData( Const Data:TCtData; Const Strings:TStrings );
var
  Buttons  : TCtButtonSet;
  SpinScan     : Boolean;
begin
  DebugCtParam( Data.Mode, Data.Value, Strings );

  Buttons := DataToButtons( data.Buttons, SpinScan );
  if SpinScan
  then Strings.Add('--- First SpinScan Record ---')
  else DebugCtButtons( Buttons, Strings );

  Strings.Add( Format('SpinScan: %s %s %s',
    [
      FormatSpinScanValue( data.SpinScan[0] ),
      FormatSpinScanValue( data.SpinScan[1] ),
      FormatSpinScanValue( data.SpinScan[2] )
    ]
  ));
end;

//------------------------------------------------------------------------------
procedure DebugCtState( Const State:TCtState; Const Strings:TStrings );
var
  i : integer;
begin
  for i := Low(State.Values) to High(State.Values)
  do if State.Seen[i]
     then DebugCtParam( i, State.Values[i], Strings );

  DebugCtButtons( State.Buttons, Strings );

  DebugCtSpinScan( State, Strings );
end;

//------------------------------------------------------------------------------
function PcParamToString( Const Param:Byte; Const Value:Word ): String;
var
  sb : Int8;
begin
  sb := (Value AND $FF);

  case Param of
  1 : Result := Format('1: Set Incline  %1.1f %%', [ sb / 10 ] );
  8 : Result := Format('8: Set Power    %4d Watts', [ value   ] );
  else
    Result := Format('%.2d:  12-bit: %.4d (%3.3x), 8-bit: %.3d / %.3d',
                     [ Param, value,value,value AND $FF, int8(value AND $FF) ] );
  end;
end;

//------------------------------------------------------------------------------
procedure DebugPcParam( Const Param:Byte; Const Value:Word; Const Strings:TStrings );
begin
  Strings.Add( PcParamToString( Param, Value ) );
end;

//------------------------------------------------------------------------------
function PcModeToString( Const Mode:Byte ): String;
begin
  Result := Format('Mode: 0x%2.2x', [ Mode ] );
end;

//------------------------------------------------------------------------------
procedure DebugPcMode( Const Mode:Byte; Const Strings:TStrings );
begin
  Strings.Add( PcModeToString( Mode ) );
end;

//------------------------------------------------------------------------------
procedure DebugPcData( Const Data:TCtData; Const Strings:TStrings );
begin
  Strings.Add( PcModeToString( data.Buttons ) + ': '
             + PcParamToString( Data.Mode, Data.Value ) );
end;

//------------------------------------------------------------------------------
procedure DebugPcState( Const State:TPcState; Const Strings:TStrings );
var
  i : integer;
begin
  Strings.Add(Format('Mode: 0x%2.2x', [ State.Mode ]));

  for i := Low(State.Values) to High(State.Values)
  do if State.Seen[i]
     then DebugPcParam( i, State.Values[i], Strings );

end;

//------------------------------------------------------------------------------
procedure DebugCtStateChange( Const State:TCtState; Const Change:TCtStateChange; Const Strings:TStrings; Const Show:TCtFieldSet );
var
  b : TCtButton;
  i : integer;
begin
  if  (ctfButton in Change.Fields)
  AND (ctfButton in Show         )
  then begin
    for b := Low(b) to High(b)
    do if b in Change.Buttons
       then if b in State.Buttons
            then Strings.Add( '  ' + CtButtonName[b] + ' Pressed'  )
            else Strings.Add( '  ' + CtButtonName[b] + ' Released' );
  end;

  if  (ctfSpinScan in Change.Fields)
  AND (ctfSpinScan in Show         )
  then begin
    for i := Low(Change.SpinScan) to High(Change.SpinScan)
    do if Change.SpinScan[i]
       then Strings.Add(Format('SpinScan[%2d]=', [ i ] ) + FormatSpinScanValue(State.SpinScan[i] ));
  end;

  if  (ctfValues in Change.Fields)
  AND (ctfValues in Show         )
  then begin
    for i := Low(Change.Values) to High(Change.Values)
    do if Change.Values[i]
       then begin
         //Strings.Add(Format('Value[%2d]=', [ i ] ) + FormatCtValue(i, State.Values[i] ));
         DebugCtParam( i, State.Values[i], Strings );
       end;
  end;
end;

//------------------------------------------------------------------------------
procedure DebugPcStateChange( Const State:TPcState; Const Change:TPcStateChange; Const Strings:TStrings; Const Show:TPcFieldSet );
var
  i : integer;
begin
  if  (pcfMode in Change.Fields)
  AND (pcfMode in Show         )
  then Strings.Add(Format( 'Mode=0x%2.2x', [ State.Mode ] ));

  if  (pcfValues in Change.Fields)
  AND (pcfValues in Show         )
  then begin
    for i := Low(Change.Values) to High(Change.Values)
    do if Change.Values[i]
       then begin
         //Strings.Add(Format('Value[%2d]=', [ i ] ) + FormatPcValue(i, State.Values[i] ));
         DebugPcParam( i, State.Values[i], Strings );
       end;
  end;
end;

//------------------------------------------------------------------------------
function FormatSpinScanValue( Const Value:Byte ): String;
begin
  Result := Format('%d', [ Int8(Value) ] )
end;

//------------------------------------------------------------------------------
function FormatPcValue( Const i:integer; Const Value:Word ): String;
begin
  Result := Format('%1:4d (0x%1:3.3x)', [ i, Value ] )
end;

end.
