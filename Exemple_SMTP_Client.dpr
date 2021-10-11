program Exemple_SMTP_Client;

uses
  Forms,
  UMain in 'UMain.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
