unit SMTPClient;


interface

uses
  Windows, Winsock, SysUtils, Classes, ScktComp, SMTPMess,ComCtrls;

type
  TSMTPClient     = class;
  TIdentification = (atNone, atLogin);

  TSMTPClient = class(TComponent)
  private
    Sock: TSocket;
    function ResolveIP(ASMTPAddress: string): string;
    function Authentification(AMess: TSMTPMess): boolean;
    function Send_Shipper(AMess: TSMTPMess): boolean;
    function Send_TypeRecipients(AMess: TSMTPMess;
      TypeRecipients: TStringList): boolean;

    { Private declarations }
  protected
    Fidentification: TIdentification;
    FPassword: string;
    FUSerName: string;
    FPort:     cardinal;
    FSMTPAddress: string;
    Function StringToEnCode64String(Source:string):string;
    { Protected declarations }
  public
    function Connect: boolean;
    function Disconnect: boolean;
    function Connected: boolean;
    function Error: string;
    function ReceivedString(AString: string): boolean;
    function SendString(AString: string): boolean;
    function SendMessage(AMess: TSMTPMess): boolean;
    Function Quit:Boolean;
    Function Noop:Boolean;
    Function VRFY(AUser:String;Var Address: String):Boolean;
    Function RSET:Boolean;
    Constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    property Identification: TIdentification Read FIdentification
      Write FIdentification default atNone;
    property Password: string Read FPassword Write FPassword;
    property UserName: string Read FUserName Write FUserName;
    property port: cardinal Read FPort Write Fport default 25;
    property SMTPAddress: string Read FSMTPAddress Write FSMTPAddress;
    { Published declarations }
  end;

var
  State: integer = 1;
  WSAData: TWSAData;
  SockAddrIn: TSockAddrIn;
  Mess: TStringList;
  Answer:String;

const
  CRLF = #13#10;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Sdk', [TSMTPClient]);
end;

Function TSMTPClient.StringToEnCode64String(Source:string):string;
Var
S1: TMemoryStream;
Begin
S1:=TMemoryStream.create;
s1.write(Source[1],length(Source));
s1.position:=0;
Result:=Base64Encode(s1);
s1.Free;
End;

constructor TSMTPClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Mess := TStringList.Create;
  WSAStartUp(257, WSAData);
  state := 0;
end;

destructor TSMTPClient.Destroy;
begin
  Mess.Free;
  WinSock.closesocket(Sock);
  WSACleanup();
  state := 0;
  inherited Destroy;
end;

function TSMTPClient.ResolveIP(ASMTPAddress: string): string;
type
  TAPInAddr = array [0..100] of PInAddr;
  PAPInAddr = ^TAPInAddr;
var
  Index:   integer;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  PInAddr: PAPInAddr;
begin
  Result := '';
  WSAStartUp($101, WSAData);
  try
    HostEnt := GetHostByName(PChar(ASMTPAddress));
    if HostEnt <> nil then
    begin
      PInAddr := PAPInAddr(HostEnt^.h_addr_list);
      Index   := 0;
      while PInAddr^[Index] <> nil do
      begin
        Result := (inet_ntoa(PInAddr^[Index]^));
        Inc(Index);
      end;
    end;
  except
  end;
  WSACleanUp();
end;

function TSMTPClient.Connect: boolean;
begin
  State  := 0;
  Result := False;
  sock   := Winsock.Socket(AF_INET, SOCK_STREAM, 0);
  if sock <> winsock.INVALID_SOCKET then
  begin
    with SockAddrIn do
    begin
      sin_family := AF_INET;
      sin_port   := htons(Fport);
      sin_addr.S_addr := inet_addr(PChar(ResolveIP(FSMTPAddress)));
    end;
    if Winsock.Connect(sock, SockAddrIn, SizeOf(SockAddrIn)) <> Socket_Error then
    begin
      State  := 1;
      Result := True;
    end;
  end;
end;

function TSMTPClient.Disconnect: boolean;
begin
  Result := False;
  if winSock.closesocket(Sock) <> Winsock.SOCKET_ERROR then
  begin
    State  := 0;
    Result := True;
  end;
end;

function TSMTPClient.Connected: boolean;
begin
  if State = 1 then
    Result := True
  else
    Result := False;
end;

function TSMTPClient.ReceivedString(AString: string): boolean;
var
  StringReceived: array [0..2048] of char;
begin
  ZeroMemory(@StringReceived[0], SizeOf(StringReceived));
  winsock.Recv(Sock, StringReceived, SizeOf(StringReceived), 0);//=Winsock.SOCKET_ERROR) Or
  if (Copy(StringReceived, 1, 3) <> Astring) then
    Result := False
  else
    Begin
    Result := True;
    Answer:=StringReceived;
    Delete(Answer,Pos(AString,Answer),length(AString));
    End;
end;

function TSMTPClient.SendString(AString: string): boolean;
begin
  if winsock.Send(Sock, AString[1], Length(AString), 0) = winsock.SOCKET_ERROR then
    Result := False
  else
    Result := True;
end;

function TSMTPClient.Error: string;
begin
  case winsock.WSAGetLastError of
    10004: Result := 'Interrupted function call.';
    10013: Result := 'Refused permission.';
    10014: Result := 'Bad address.';
    10022: Result := 'Invalid Arguments.';
    10024: Result := 'Too many open files.';
    10035: Result := 'Resource temporarily unavailable.';
    10036: Result := 'peration in progress.';
    10037: Result := 'Operation already in progress.';
    10038: Result := 'Socket operation or no-socket.';
    10039: Result := 'Destination address required.';
    10040: Result := 'Too long message .';
    10041: Result := 'Protocol wrong type for socket.';
    10042: Result := 'Bad protocol option.';
    10043: Result := 'Protocol not supported.';
    10044: Result := 'Socket type not supported.';
    10045: Result := 'Operation not supported.';
    10046: Result := 'Protocol family not supported.';
    10047: Result := 'Address family not supported by protocol family.';
    10048: Result := 'Address already in use.';
    10049: Result := 'Cannot assign requested address.';
    10050: Result := 'Network is down.';
    10051: Result := 'Network is unreachable.';
    10052: Result := 'Network dropped connection on reset.';
    10053: Result := 'Software caused connection abort.';
    10054: Result := 'Connection reset by peer.';
    10055: Result := 'No buffer space available.';
    10056: Result := 'Socket is already connected.';
    10057: Result := 'Socket is not connected.';
    10058: Result := 'Cannot send after socket shutdown.';
    10060: Result := 'Connection timed out.';
    10061: Result := 'Connection refused.';
    10064: Result := 'Host is down.';
    10065: Result := 'No route to host.';
    10067: Result := 'Too many processes.';
    10091: Result := 'Network subsystem is unavailable.';
    10092: Result := 'WINSOCK.DLL version out of range.';
    10093: Result := 'Successful WSAStartup not yet performed.';
    10094: Result := 'Graceful shutdown in progress.';
    11001: Result := 'Host not found.';
    11002: Result := 'Non-authoritative host not found.';
    11003: Result := 'This is a non-recoverable error.';
    11004: Result := 'Valid name, no data record of requested type.';
  end;
end;

function TSMTPClient.Authentification(AMess: TSMTPMess): boolean;
begin
  Result := False;
  if not ReceivedString('220') then
    Result := False;
  if Fidentification = atNone then
  begin
    SendString('HELO MAIL' + CRLF);
    if ReceivedString('250') then
      Result := True
    else
      Result := False;
  end;
  if Fidentification = atLogin then
  begin
    SendString('EHLO MAIL' + CRLF);
    if ReceivedString('250') then
    begin
      SendString('AUTH LOGIN' + CRLF);
      if ReceivedString('334') then
        SendString(StringToEnCode64String(FUSerName) + CRLF);
      if ReceivedString('334') then
        SendString(StringToEnCode64String(FPassword) + CRLF);
      if ReceivedString('235') then
        Result := True;
    end;
  end;
end;

function TSMTPClient.Send_Shipper(AMess: TSMTPMess): boolean;
begin
  Result := False;
  SendString('MAIL FROM:<' + AMess.ShipperAddress + '>' + CRLF);
  if ReceivedString('250') then
    Result := True;
end;

function TSMTPClient.Send_TypeRecipients(AMess: TSMTPMess;
  TypeRecipients: TStringList): boolean;
var
  Index: cardinal;
begin
  Result := True;
  if (TypeRecipients.Count - 1) < 0 then
    Exit;
  for Index := 0 to (TypeRecipients.Count - 1) do
  begin
    SendString('RCPT To: <' + TypeRecipients.Strings[Index] + '>' + CRLF);
    if not (ReceivedString('250')) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TSMTPClient.SendMessage(AMess: TSMTPMess): boolean;
var
  Index: cardinal;
begin
  Result := False;
  if State = 0 then
    Exit;
  AMess.Written(Mess);
  if not (Authentification(AMess)) then
    Exit;
  if not Send_Shipper(AMess) then
    Exit;
  if not Send_TypeRecipients(AMess, AMess.RecipientsAddresses) then
    Exit;
  if not Send_TypeRecipients(AMess, AMess.CCList) then
    Exit;
  if not Send_TypeRecipients(AMess, AMess.BCCList) then
    Exit;
  SendString('DATA' + CRLF);
  if not ReceivedString('354') then
    Exit;
  for Index := 0 to (Mess.Count - 1) do
    SendString(Mess.Strings[Index]);
  SendString('.' + CRLF);
  if not ReceivedString('250') then
    Exit;
  SendString('QUIT' + CRLF);
  Result := True;
end;

Function TSMTPClient.Quit:Boolean;
Begin
Result:=False;
If (Connected) And (SendString('QUIT' + CRLF)) AND (ReceivedString('221'))
then Result:=True;
End;

Function TSMTPClient.Noop:Boolean;
Begin
Result:=False;
If (Connected) And (SendString('NOOP' + CRLF)) AND (ReceivedString('250'))
then Result:=True;
End;

Function TSMTPClient.VRFY(AUser:String;Var Address: String):Boolean;
Begin
Result:=False;
If (Connected) And (SendString('VRFY '+AUser + CRLF)) AND (ReceivedString('250'))
then
  Begin
  Result:=True;
  Address:=Answer;
  End;
End;

Function TSMTPClient.RSET:Boolean;
Begin
Result:=False;
If (Connected) And (SendString('RSET' + CRLF)) AND (ReceivedString('250'))
then Result:=True;
End;

end.
