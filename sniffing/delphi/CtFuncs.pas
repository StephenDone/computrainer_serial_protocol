unit CtFuncs;

interface

Uses
  Classes,
  CtData;

function processRxData( var rxbuf:TArray<byte>; var packet : TArray<byte> ): Boolean;


procedure CtPacketToFields( const packet:TArray<byte>; out data:TCTData );
procedure PcPacketToFields( const packet:TArray<byte>; out data:TCTData );

procedure CtFieldsToState( Const data:TCTData; var state:TCtState; var Changes:TCtStateChange );
procedure PcFieldsToState( Const data:TCTData; var state:TPcState; var Changes:TPcStateChange  );

procedure ClearCtState( out State:TCtState );
procedure ClearPcState( out State:TPcState );

function DataToButtons( Const Buttons:Byte; out SpinScan:Boolean ) : TCtButtonSet;
function calcCRC( Const value: word ): byte;

implementation

Uses SysUtils;

//------------------------------------------------------------------------------
function calcCRC( Const value: word ): byte;
begin
  result := ( $ff AND (   107
                        - (value AND $ff)
                        - (value SHR 8  )
                      )
            );
end;

//------------------------------------------------------------------------------
function processRxData( var rxbuf:TArray<byte>; var packet : TArray<byte> ): Boolean;
begin
	if Length(rxbuf) < 7
  then exit( false );

  Result := (rxbuf[6] AND $80 ) <> 0;

  if Result
  then begin
    packet := Copy( rxbuf, 0, 7 );
    delete( rxbuf, 0, 7 );
  end
  else begin
    delete( rxbuf, 0, 1 );
  end
end;

//------------------------------------------------------------------------------
procedure CtPacketToFields( const packet:TArray<byte>; out data:TCTData );
begin
	data.SpinScan[0] := ((packet[0] AND $7F) SHL 1)
                   OR ((packet[6] AND $20) SHR 5);

	data.SpinScan[1] := ((packet[1] AND $7F) SHL 1)
                   OR ((packet[6] AND $10) SHR 4);

	data.SpinScan[2] := ((packet[2] AND $7F) SHL 1)
                   OR ((packet[6] AND $08) SHR 3);

	data.Buttons     := ((packet[3] AND $7F) SHL 1)
                   OR ((packet[6] AND $04) SHR 2);

	data.mode        := ((packet[4] AND $78) SHR 3);

	data.value       := ((packet[4] AND $07) SHL 9)
                   OR ((packet[6] AND $02) SHL 8)
                   OR ((packet[5] AND $7F) SHL 1)
                   OR ((packet[6] AND $01)      );

	data.z           := ((packet[6] AND $40) SHR 6) = 1;
end;

//------------------------------------------------------------------------------
procedure PcPacketToFields( const packet:TArray<byte>; out data:TCTData );
begin
  CtPacketToFields( packet, data );
end;

//------------------------------------------------------------------------------
function DataToButtons( Const Buttons:Byte; out SpinScan:Boolean ) : TCtButtonSet;
begin
  SpinScan := (Buttons AND $40) <> 0;

  Result := [];

  if (Buttons AND $80) =  0 then Include( Result, ctbReset    );
  if (Buttons AND $20) <> 0 then Include( Result, ctbMinus    );
  if (Buttons AND $10) <> 0 then Include( Result, ctbF2       );
  if (Buttons AND $08) <> 0 then Include( Result, ctbPlus     );
  if (Buttons AND $04) <> 0 then Include( Result, ctbF3       );
  if (Buttons AND $02) <> 0 then Include( Result, ctbF1       );

end;

//------------------------------------------------------------------------------
procedure IncExc( var ButtonSet:TCtButtonSet; Const Button:TCtButton; Const Value:Boolean );
begin
  if Value
  then Include( ButtonSet, Button )
  else Exclude( ButtonSet, Button );
end;

//------------------------------------------------------------------------------
procedure ClearCtState( out State:TCtState );
begin
  FillChar( State, SizeOf(State), $00);
end;

//------------------------------------------------------------------------------
procedure ClearPcState( out State:TPcState );
begin
  FillChar( State, SizeOf(State), $00);
end;

//------------------------------------------------------------------------------
procedure CtFieldsToState( Const data:TCTData; var state:TCtState; var Changes:TCtStateChange  );

  procedure ClearStateChange( out Changes:TCtStateChange );
  begin
    FillChar( Changes, SizeOf(Changes), $00);
  end;

var
  i : integer;
  DataButtons  : TCtButtonSet;
  Pressed      : Integer;
  Changed      : Boolean;
  SpinScan     : Boolean;
begin
  ClearStateChange( Changes );

  if NOT state.Seen[data.mode] OR ( state.Values[ data.mode ] <> data.value )
  then begin
    state.Seen[data.mode] := True;
    state.Values[ data.mode ] := data.value;
    Changes.Values[ data.mode ] := True;
    Include( Changes.Fields, ctfValues );
  end;

  DataButtons := DataToButtons( data.Buttons, SpinScan );

  if SpinScan
  then begin
    state.NextSSIdx := 0;
  end
  else begin

    if State.Buttons <> DataButtons
    then begin
      Changed := False;

      if (ctbMinus in State.Buttons) XOR (ctbMinus in DataButtons)
      then begin
        IncExc( State.Buttons, ctbMinus, ctbMinus in DataButtons );
        Include( Changes.Buttons, ctbMinus );
        Changed := True;
      end;

      if (ctbPlus  in State.Buttons) XOR (ctbPlus  in DataButtons)
      then begin
        IncExc( State.Buttons, ctbPlus, ctbPlus in DataButtons );
        Include( Changes.Buttons, ctbPlus  );
        Changed := True;
      end;

      if (ctbF1    in State.Buttons) XOR (ctbF1    in DataButtons)
      then begin
        IncExc( State.Buttons, ctbF1, ctbF1 in DataButtons );
        Include( Changes.Buttons, ctbF1    );
        Changed := True;
      end;

      if (ctbF2    in State.Buttons) XOR (ctbF2    in DataButtons)
      then begin
        IncExc( State.Buttons, ctbF2, ctbF2 in DataButtons );
        Include( Changes.Buttons, ctbF2    );
        Changed := True;
      end;

      if (ctbF3    in State.Buttons) XOR (ctbF3    in DataButtons)
      then begin
        IncExc( State.Buttons, ctbF3, ctbF3 in DataButtons );
        Include( Changes.Buttons, ctbF3    );
        Changed := True;
      end;

      // The reported state of the reset button is incorrect in certain
      // circumstances, so we then have to ignore its reported state.
      Pressed := 0;

      if ctbPlus  in DataButtons then Inc( Pressed );
      if ctbMinus in DataButtons then Inc( Pressed );
      if ctbF1    in DataButtons then Inc( Pressed );
      if ctbF2    in DataButtons then Inc( Pressed );
      if ctbF3    in DataButtons then Inc( Pressed );

      case Pressed of
      1, 3, 5: // Ignore the reported state of the reset button
      else
        if (ctbReset in State.Buttons) XOR (ctbReset in DataButtons)
        then begin
          IncExc( State.Buttons, ctbReset, ctbReset in DataButtons );
          Include( Changes.Buttons, ctbReset );
          Changed := True;
        end;
      end;

      if Changed
      then Include( Changes.Fields, ctfButton );
    end;

  end;

  if state.NextSSIdx <= High( state.SpinScan ) - High(data.SpinScan)
  then begin
    for i := Low(data.SpinScan) to High(data.SpinScan)
    do begin
      if state .SpinScan[state.NextSSIdx + i] <> data.SpinScan[i]
      then begin
        state  .SpinScan[state.NextSSIdx + i] := data.SpinScan[i];
        Changes.SpinScan[state.NextSSIdx + i] := True;

        Include( Changes.Fields, ctfSpinScan );
      end;
    end;

    Inc( state.NextSSIdx, 3 );
  end;

end;

//------------------------------------------------------------------------------
procedure PcFieldsToState( Const data:TCTData; var state:TPcState; var Changes:TPcStateChange  );

  procedure ClearStateChange( out Changes:TPcStateChange );
  begin
    FillChar( Changes, SizeOf(Changes), $00);
  end;

begin
  ClearStateChange( Changes );

  if state.Mode <> data.Buttons
  then begin
    state.Mode := data.Buttons;
    Include( Changes.Fields, pcfMode );
  end;

  if NOT state.Seen[data.mode] OR ( state.Values[ data.mode ] <> data.value )
  then begin
    state.Seen[ data.Mode ] := True;
    state.Values[ data.mode ] := data.value;
    Changes.Values[ data.mode ] := True;
    Include( Changes.Fields, pcfValues );
  end;
end;

end.
