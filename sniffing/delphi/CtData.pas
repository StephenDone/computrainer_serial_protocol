unit CtData;

interface

Type
  TCtMsgDef = Record
    Name   : String;
    IsByte : Boolean;
  end;

Const
  CtMsgTypes : Array[0..15] of TCtMsgDef = (
    ( Name:''                 ; IsByte:False ),
    ( Name:'Speed'            ; IsByte:False ),
    ( Name:'Power'            ; IsByte:False ),
    ( Name:'Heart Rate'       ; IsByte:True  ),
    ( Name:''                 ; IsByte:False ),
    ( Name:''                 ; IsByte:False ),
    ( Name:'Cadence'          ; IsByte:True  ),
    ( Name:''                 ; IsByte:False ),
    ( Name:''                 ; IsByte:False ),
    ( Name:'Push On Pressure' ; IsByte:False ),
    ( Name:''                 ; IsByte:False ),
    ( Name:'Sensors Present'  ; IsByte:False ),
    ( Name:'Message Sync'     ; IsByte:False ),
    ( Name:''                 ; IsByte:False ),
    ( Name:''                 ; IsByte:False ),
    ( Name:''                 ; IsByte:False )
  );

Type
  TCTData = record
    SpinScan : Array[0..2] of byte;
    //crc      : byte;
    z        : boolean;
    Mode     : byte;
    Buttons  : byte;
    Value    : word;
  end;

Type
  TCtButton = ( ctbReset, ctbF1, ctbF2, ctbF3, ctbPlus, ctbMinus );

Const
  CtButtonName : Array[TCtButton] of String = (
    'Reset', 'F1', 'F2', 'F3', 'Plus', 'Minus'
  );

Type
  TCtButtonSet = Set of TCtButton;

  TCtSensor    = ( ctsCadence, ctsHeartRate );
  TCtSensorSet = Set of TCtSensor;

  TSeenParams = Array[0..15] of Boolean;

  TCtState = Record
    SpinScan   : Array[0..23] of Byte;
    NextSSIdx  : Byte;

    Buttons    : TCtButtonSet;

    Values     : Array[0..15] of Word;
    Seen       : TSeenParams;
  end;

  TPcState = Record
    Mode    : Byte;
    Values  : Array[0..15] of Word;
    Seen    : TSeenParams;
  end;

  TCtField = ( ctfButton, ctfSpinScan, ctfValues );
  TCtFieldSet = Set of TCtField;

  TCtStateChange = Record
    Fields   : TCtFieldSet;
    Buttons  : TCtButtonSet;
    Values   : Array[0..15] of Boolean;
    SpinScan : Array[0..23] of Boolean;
  end;

  TPcField = ( pcfMode, pcfValues );
  TPcFieldSet = Set of TPcField;

  TPcStateChange = Record
    Fields : TPcFieldSet;
    Values : Array[0..15] of Boolean;
  end;

implementation

end.
