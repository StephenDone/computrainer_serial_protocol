program Sniffer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FormMain},
  CtFuncs in 'CtFuncs.pas',
  CtData in 'CtData.pas',
  CtDebug in 'CtDebug.pas',
  CtSniffer in 'CtSniffer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
