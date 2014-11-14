{  *************************************************************************  }
{                                                                             }
{  This Source Code Form is subject to the terms of the Mozilla Public        }
{  License, v. 2.0. If a copy of the MPL was not distributed with this file,  }
{  You can obtain one at http://mozilla.org/MPL/2.0/.                         }
{                                                                             }
{  Copyright (c) 2014, VoLT                                                   }
{                                                                             }
{  *************************************************************************  }

library ISCallProc;


uses
    System.SysUtils
  , System.Classes
  , Winapi.Windows
  , DDetours
  ;

type
  // InitializeWizard 004E4498
  // CodeRunner       0050A09C
  TScriptRunner = class
    procedure RunProcedureHooked(const Name: AnsiString; const Parameters: array of Const; const MustExist: Boolean);
  end;

  TRunProcedure = procedure(const Name: AnsiString; const Parameters: array of Const; const MustExist: Boolean) of object;

var
  TrampolineRunProcedure: TRunProcedure;
  
procedure TScriptRunner.RunProcedureHooked(const Name: AnsiString; const Parameters: array of Const; const MustExist: Boolean);
begin    
  if Assigned(TrampolineRunProcedure) and Assigned(Self) then
  begin
    TMethod(TrampolineRunProcedure).Data := Pointer(Self);
    TMethod(TrampolineRunProcedure).Code := @TrampolineRunProcedure;
     
    TrampolineRunProcedure(Name, Parameters, MustExist);
  end;  
end;

procedure DllMain(Reason: Integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        // Inno Setup Compiler 5.5.5 (u) (build 121002)
        @TrampolineRunProcedure := InterceptCreate(Pointer($004F8FD8), @TScriptRunner.RunProcedureHooked);
      end;
    DLL_PROCESS_DETACH:
      begin
        InterceptRemove(@TrampolineRunProcedure);
      end;
  end;
end;

procedure Test; stdcall;
begin
  TrampolineRunProcedure('CallMe', [''], False);
end;

exports
   Test;

begin
   DllProc := @DllMain;
   DllProc(DLL_PROCESS_ATTACH);
end.
