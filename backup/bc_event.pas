unit bc_event;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils;
const
  UnitVersion = '00.14.09.2020';

type

  { * * * TbcEvent * * * }
  TbcEvent = class
  private
    fEvent: PRTLEvent;
  protected
    fTimeOut: longint;
  public
    constructor Create; overload;
    constructor Create(const aTimeout: longint); overload;
    destructor Destroy; override;
    procedure SetEvent;
    procedure ResetEvent;
    procedure WaitFor; overload;
    procedure WaitFor(aTimeout: longint); overload;
  end;

(*
function  RTLEventCreate :PRTLEvent; *
procedure RTLeventdestroy(state:pRTLEvent);  *
procedure RTLeventSetEvent(state:pRTLEvent); *
procedure RTLeventResetEvent(state:pRTLEvent); *
procedure RTLeventWaitFor(state:pRTLEvent);
procedure RTLeventWaitFor(state:pRTLEvent;timeout : longint);
*)

implementation

{ * * * TbcEvent * * * }
constructor TbcEvent.Create;
begin
  fEvent:= RTLEventCreate; { create new event }
end;

constructor TbcEvent.Create(const aTimeout: longint);
begin
  fTimeOut:= aTimeout; { in milliseconds }
  fEvent:= RTLEventCreate; { create new event with timeout }
end;

destructor TbcEvent.Destroy;
begin
  RTLeventdestroy(fEvent); { destroy event }
  inherited Destroy;
end;

procedure TbcEvent.SetEvent;
begin
  RTLeventSetEvent(fEvent); { signal event }
end;

procedure TbcEvent.ResetEvent;
begin
  RTLeventResetEvent(fEvent); { unsignal / clear event }
end;

procedure TbcEvent.WaitFor;
begin
  RTLeventWaitFor(fEvent); { wait for the event to be signaled }
end;

procedure TbcEvent.WaitFor(aTimeout: longint);
begin
  RTLeventWaitFor(fEvent,fTimeOut); { wait for the event to be signaled or timeout }
end;

end.
