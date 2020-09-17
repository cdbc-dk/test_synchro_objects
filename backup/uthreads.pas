unit uthreads;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,
  bc_msgqueue,
  bc_guardian,
  bc_types;
const 
  UnitVersion = '00.14.09.2020';
    
type
  { TNamedThread }
  TNamedThread = class(TThread)
  protected
    fName: string;
    fGuardian: TGuardian;
    procedure Execute; override;
  public
    constructor Create(const aName: string;const aLock: TGuardian);
    destructor Destroy; override;
    property Name: string read fName;
    property Guard: TGuardian read fGuardian;
  end;

implementation
uses lfm_main;
{ TNamedThread }
procedure TNamedThread.Execute;
var
  Count: byte;
begin
  Count:= 0;
  fGuardian.Lock;
  try
    lfm_main.Form1.LogMsgQueue.PostMsg(-1,LM_WORKING,Count,127,' ['+Name+'] Starting...');
  finally fGuardian.UnLock; end;
  while (not Terminated) and (Count <= 127) do try
//    sleep(2);
    inc(Count);
    fGuardian.Lock;
    try
      lfm_main.Form1.LogMsgQueue.PostMsg(-1,LM_WORKING,Count,127,' ['+Name+'] processing');
    finally fGuardian.UnLock; end;
  except on E:Exception do
    break;
  end;
  lfm_main.Form1.LogMsgQueue.PostMsg(-1,LM_DONE,Count,127,' ['+Name+'] Done!');
end;

constructor TNamedThread.Create(const aName: string;const aLock: TGuardian);
begin
  inherited Create(true);
  FreeOnTerminate:= true;
  fName:= aName;
  fGuardian:= aLock; { lock available to all who put 'bc_guardian' in uses }
  Start;
end;

destructor TNamedThread.Destroy;
begin
  fGuardian:= nil; { will be free'd on program end }
  inherited Destroy;
end;

end.

