unit lfm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  bc_event,
  bc_guardian,
  bc_semaphore,
  bc_msgqueue,        // provides app wide messagequeue
  bc_synchro_objects,
  uthreads;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnThreadOne: TButton;
    gbxAction: TGroupBox;
    gbxLog: TGroupBox;
    Memo1: TMemo;
    ProgressBar1: TProgressBar;
    procedure btnThreadOneClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fGuardian: TGuardian;
    fLogMsgQueue: TbcMessageQueue;
    fNamedThread1: TNamedThread;
    fNamedThread2: TNamedThread;
    fNamedThread3: TNamedThread;
    fNTArray: array[0..19] of TNamedThread;
  public
    procedure OnDataInQueue(Sender: TObject);
    procedure HandleAsyncCall(Data: ptrint);
    property LogMsgQueue: TbcMessageQueue read fLogMsgQueue;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnThreadOneClick(Sender: TObject);
var
  B: byte;
  ThName: string;
begin
  LogMsgQueue.PostMsg(-1,LM_CREATE,-1,-1,'Starting NamedThreads...');
(*
  fNamedThread1:= TNamedThread.Create('NamedByteThread1',bc_guardian.Guardian);
  fNamedThread2:= TNamedThread.Create('NamedByteThread2',bc_guardian.Guardian);
  fNamedThread3:= TNamedThread.Create('NamedByteThread3',bc_guardian.Guardian);
*)
  for B:= 0 to 19 do begin
    ThName:= 'NamedByteThread '+inttostr(B);
    fNTArray[B]:= TNamedThread.Create(ThName,bc_guardian.Guardian);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  fGuardian:= bc_guardian.Guardian;
  fLogMsgQueue:= TbcMessageQueue.Create;
  fLogMsgQueue.OnDataInQueue:= @OnDataInQueue;
  LogMsgQueue.PostMsg(-1,LM_CREATE,-1,-1,'Hello...');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  LogMsgQueue.PostMsg(-1,LM_CREATE,-1,-1,'Bye...');
  fGuardian:= nil; { global, will be free'd on program end }
end;

procedure TForm1.OnDataInQueue(Sender: TObject);
begin { runs in a separate thread, beware! }
  Application.QueueAsyncCall(@HandleAsyncCall,ptrint(Sender));
end;

procedure TForm1.HandleAsyncCall(Data: ptrint);
var
  Msg: TbcMessage;
begin
  while not fLogMsgQueue.IsEmpty do begin
    fGuardian.Lock;
    try
      Msg:= fLogMsgQueue.DeQueue;
    finally fGuardian.UnLock; end;
    Memo1.Lines.Add(MsgToStr(Msg.Msg)+' '+Msg.WParam.ToString+Msg.LParam.ToString+' '+Msg.SParam);
    ProgressBar1.Max:= Msg.LParam;
    ProgressBar1.Position:= Msg.WParam;
{
    case Msg.Msg of
      LM_LOGMSG: begin
                   Memo1.Lines.Add(MsgToStr(LM_LOGMSG)+' '+Msg.WParam.ToString+Msg.LParam.ToString+' '+Msg.SParam);
                 end;
    end;
}
    FreeAndNil(Msg); { user is responsible for free'ing the message }
    Application.ProcessMessages;
  end;
end;

end.

