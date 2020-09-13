unit bc_event;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils;
const
  UnitVersion = '00.09.09.2020';

type
  TbcEvent = class
  private
    fEvent: PRTLEvent;
  protected

  public

  end;

(*
function  RTLEventCreate :PRTLEvent;
procedure RTLeventdestroy(state:pRTLEvent);
procedure RTLeventSetEvent(state:pRTLEvent);
procedure RTLeventResetEvent(state:pRTLEvent);
procedure RTLeventWaitFor(state:pRTLEvent);
procedure RTLeventWaitFor(state:pRTLEvent;timeout : longint);
*)

implementation

end.    
