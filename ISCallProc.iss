; -- CodeDll.iss --
;
; This script shows how to call DLL functions at runtime from a [Code] section.

[Setup]
AppName=My Program
AppVersion=1.5
DefaultDirName={pf}\My Program
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\MyProg.exe
OutputDir=userdocs:Inno Setup Examples Output

[Files]
; Install our DLL to {app} so we can access it at uninstall time
; Use "Flags: dontcopy" if you don't need uninstall time access
Source: "dll.dll"; Flags: dontcopy nocompression

[Code]
const
  MB_ICONINFORMATION = $40;

//importing an ANSI Windows API function
function MessageBox(hWnd: Integer; lpText, lpCaption: string; uType: Cardinal): Integer;
external 'MessageBoxW@user32.dll stdcall';


procedure Test; external 'Test@files:dll.dll stdcall setuponly';

procedure CallMe();
begin
  MessageBox(0, 'Была вызвана процедура CallMe()', 'Тестовое сообщение', $00000000);
end;

procedure InitializeWizard();
begin     
  MessageBox(0, 'Была вызвана процедура InitializeWizard', 'Тестовое сообщение', $00000000);
end;

function NextButtonClick(CurPage: Integer): Boolean;
begin
  Log (Inttostr(CurPage));
  if CurPage = wpWelcome then begin
    Test;
    //CallMe;
  end;
  Result := True;
end;