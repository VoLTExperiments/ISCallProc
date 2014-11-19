{   Copyright (c) 2014 VoLT
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
}

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
