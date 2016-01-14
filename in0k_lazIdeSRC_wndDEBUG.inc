
interface

uses Forms, sysutils,
     in0k_lazIdeSRC_wndDEBUG,
     IDEWindowIntf, MenuIntf; //< да ... необходимо использовать IdeINTf

procedure IdeLazarus_SetUP(const pkgClassNAME:string);
procedure IdeLazarus_CLEAR;

procedure DEBUG(const         msgTEXT:string);
procedure DEBUG(const msgTYPE,msgTEXT:string);


type pMethod=^tMethod;

function  addr2str(const p:pointer):string; inline;
function  addr2txt(const p:pointer):string; inline;
function  mthd2txt(const p:pMethod):string; inline;

implementation

var _WndDBG_:TWnd_DEBUG;

//------------------------------------------------------------------------------

const
  _cWndDBG_caption_='[eventLOG] ';

procedure _WndDBG_SHOW_;
begin
    if Assigned(_WndDBG_) then _WndDBG_.Show;
end;

procedure _WndDBG_SHOW_onClick_(Sender: TObject);
begin
    _WndDBG_SHOW_;
end;

//------------------------------------------------------------------------------

procedure IdeLazarus_SetUP(const pkgClassNAME:string);
begin
    if not Assigned(_WndDBG_) then begin
        // создаем САМО окно
       _WndDBG_:=TWnd_DEBUG.Create(Application, pkgClassNAME,_cWndDBG_caption_+pkgClassNAME);
        // создаем пункт меню для него
        RegisterIDEMenuCommand(itmViewIDEInternalsWindows, _cWndDBG_caption_+pkgClassNAME,_cWndDBG_caption_+pkgClassNAME,nil,@_WndDBG_SHOW_onClick_);
    end;
end;

procedure IdeLazarus_CLEAR;
begin
   _WndDBG_.FREE;
end;

//------------------------------------------------------------------------------

procedure DEBUG(const msgTEXT:string);
begin
    if Assigned(_WndDBG_) then _WndDBG_.Message(msgTEXT);
end;

const
  _c_bOPN_='[';
  _c_bCLS_=']';
  _c_PRBL_=' '; //< ^-) изменить имя

procedure DEBUG(const msgTYPE,msgTEXT:string);
begin
    if msgTYPE<>''
    then DEBUG(_c_bOPN_+msgTYPE+_c_bCLS_+_c_PRBL_+msgTEXT)
    else DEBUG(                                   msgTEXT);
end;

{%region --- Pointer to TEXT -------------------------------------- /fold}

function addr2str(const p:pointer):string;
begin
    result:=IntToHex({%H-}PtrUint(p),sizeOf(PtrUint)*2);
end;

const _c_addr2txt_SMB_='$';
const _c_addr2txt_DVT_=':';

function addr2txt(const p:pointer):string;
begin
    result:=_c_addr2txt_SMB_+addr2str(p);
end;

function mthd2txt(const p:pMethod):string;
begin
    result:=_c_addr2txt_SMB_+addr2str(p^.Code)+_c_addr2txt_DVT_+addr2str(p^.Data)
end;

{%endregion}


(*


procedure DEBUG(const msgTEXT:string);
begin
    if Assigned(_WndDBG_) then _WndDBG_.Message(msgTEXT);
end;


procedure RegisterInIdeLAZARUS;
procedure DEBUG_window_SHOW;

procedure DEBUG(const msgTYPE,msgTEXT:string);
procedure DEBUG(const         msgTEXT:string);

function  addr2str(const p:pointer):string; inline;
function  addr2txt(const p:pointer):string; inline;
function  mthd2txt(const p:pMethod):string; inline;



{$ifNdef ASSERTIONS}
procedure Assert(const B:boolean; const T:string);
{$endIf}
implementation
{$ifNdef ASSERTIONS}
procedure Assert(const B:boolean; const T:string);
begin
    if not B then MessageDlg('ExtIDEM ASSERT',T,mtWarning,[mbOK],0);
end;
{$endIf}

const _c_WndDBG_Caption_='[eventLog] lazExt_ExtIDEM';

//==============================================================================

{%region --- for IDE lazarus -------------------------------------- /fold}

procedure _onClickIdeMenuItem_(Sender: TObject);
begin
    DEBUG_window_SHOW;
end;

procedure RegisterInIdeLAZARUS;
begin
end;

{%endregion}



//==============================================================================

{$R *.lfm}

procedure TextIDEM_wnd_DEBUG.FormClose(Sender:TObject; var CloseAction:TCloseAction);
begin
    CloseAction:=caFree;
   _WndDBG_:=NIL;
end;

procedure TextIDEM_wnd_DEBUG.FormCreate(Sender: TObject);
begin
    Caption  :=_c_WndDBG_Caption_;
    FormStyle:=fsStayOnTop;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TextIDEM_wnd_DEBUG.a_ClearExecute(Sender: TObject);
begin
    memo1.Clear;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TextIDEM_wnd_DEBUG.a_StayOnTopExecute(Sender: TObject);
begin
    if self.FormStyle=fsStayOnTop then self.FormStyle:=fsNormal
    else self.FormStyle:=fsStayOnTop;
end;

procedure TextIDEM_wnd_DEBUG.a_StayOnTopUpdate(Sender: TObject);
begin // ????
    tAction(Sender).Checked:=(self.FormStyle=fsStayOnTop);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*)

 {
procedure TextIDEM_wnd_DEBUG.Message(const TextMSG:string);
var tmp:string;
begin
    DateTimeToString(tmp,'hh:mm:ss`zzz',now);
    with memo1 do begin
        Lines.Insert(0,tmp+_c_PRBL_+TextMSG);
        SelLength:=0;
        SelStart :=0;
    end;
end;

procedure TextIDEM_wnd_DEBUG.Message(const msgTYPE,msgTEXT:string);
begin
    if msgTYPE<>''
    then Message(_c_bOPN_+msgTYPE+_c_bCLS_+_c_PRBL_+msgTEXT)
    else Message(                                   msgTEXT);
end;  }

initialization
_wndDBG_:=nil;

