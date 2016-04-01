{$mode objfpc}{$H+}
interface

uses Forms, sysutils,
     in0k_lazIdeSRC_wndDEBUG,
     IDEWindowIntf, MenuIntf; //< да ... необходимо использовать IdeINTf

procedure LazarusIDE_SetUP (const pkgClassNAME:string);
procedure LazarusIDE_CLEAR;

procedure in0k_lazIde_DEBUG(const         msgTEXT:string);
procedure in0k_lazIde_DEBUG(const msgTYPE,msgTEXT:string);

procedure DEBUG(const         msgTEXT:string);
procedure DEBUG(const msgTYPE,msgTEXT:string);


type pMethod=^tMethod;

function  addr2str(const p:pointer):string; inline;
function  addr2txt(const p:pointer):string; inline;
function  mthd2txt(const p:pMethod):string; inline;

function  inttostr(const v:integer):string; inline;


implementation

{%region --- _tWndDBG_manager_ -- /fold}

const _c_caption_text_='[eventLOG]';

type
_tWndDBG_manager_=class
  protected
   _WndDBG_:TWnd_DEBUG;
   _pkgName_:string;
    procedure _WndDBG_onDestroy_(Sender: TObject);
  public
    function  wndCaption:string;
    procedure MessageDBG(const MSG:string);
    procedure ShowWindow;
    procedure onClick_ShowWindow(Sender: TObject); //< это для меню
  public
    constructor Create(const pkgClassName:string);
    destructor DESTROY; override;
  end;

constructor _tWndDBG_manager_.Create(const pkgClassName:string);
begin
   _WndDBG_:=NIL;
   _pkgName_:=pkgClassName;
end;

destructor _tWndDBG_manager_.DESTROY;
begin
    if Assigned(_WndDBG_) then _WndDBG_.FREE;
end;

//------------------------------------------------------------------------------

// вот блин ... и тока ради этого приходится все тут городить
procedure _tWndDBG_manager_._WndDBG_onDestroy_(Sender: TObject);
begin
   _WndDBG_:=nil;
end;

//------------------------------------------------------------------------------

function _tWndDBG_manager_.wndCaption:string;
begin
    result:=_c_caption_text_+' '+_pkgName_;
end;

//------------------------------------------------------------------------------

procedure _tWndDBG_manager_.ShowWindow;
begin
    if not Assigned(_WndDBG_) then begin
        if _pkgName_<>'' then begin
           _WndDBG_:=TWnd_DEBUG.Create(Application,_pkgName_,wndCaption);
            //и тока ради этого приходится все тут городить
           _WndDBG_.OnDestroy:=@_WndDBG_onDestroy_;
        end;
    end;
    if Assigned(_WndDBG_) then begin
       _WndDBG_.Show;
       _WndDBG_.BringToFront;
    end;
end;

procedure _tWndDBG_manager_.onClick_ShowWindow(Sender: TObject);
begin
    ShowWindow;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure _tWndDBG_manager_.MessageDBG(const MSG:string);
begin
    if Assigned(_WndDBG_) and (_WndDBG_.Visible) then _WndDBG_.Message(MSG);
end;

{%endregion}

var _WndDBG_manager_:_tWndDBG_manager_;

//------------------------------------------------------------------------------

procedure LazarusIDE_SetUP(const pkgClassNAME:string);
begin
    if not Assigned(_WndDBG_manager_) then begin
        // создаем САМО окно
       _WndDBG_manager_:=_tWndDBG_manager_.Create(pkgClassNAME);
        // создаем пункт меню для него
        RegisterIDEMenuCommand(itmViewIDEInternalsWindows, _WndDBG_manager_.wndCaption,_WndDBG_manager_.wndCaption,@_WndDBG_manager_.onClick_ShowWindow,nil);
    end;
end;

procedure LazarusIDE_CLEAR;
begin
   _WndDBG_manager_.FREE;
end;

//------------------------------------------------------------------------------

procedure DEBUG(const msgTEXT:string);
begin
    in0k_lazIde_DEBUG(msgTEXT);
end;

procedure DEBUG(const msgTYPE,msgTEXT:string);
begin
    in0k_lazIde_DEBUG(msgTYPE,msgTEXT);
end;

//------------------------------------------------------------------------------

procedure in0k_lazIde_DEBUG(const msgTEXT:string);
begin
    if Assigned(_WndDBG_manager_) then _WndDBG_manager_.MessageDBG(msgTEXT);
end;

const
  _c_bOPN_='[';
  _c_bCLS_=']';
  _c_PRBL_=' '; //< ^-) изменить имя

procedure in0k_lazIde_DEBUG(const msgTYPE,msgTEXT:string);
begin
    if msgTYPE<>''
    then in0k_lazIde_DEBUG(_c_bOPN_+msgTYPE+_c_bCLS_+_c_PRBL_+msgTEXT)
    else in0k_lazIde_DEBUG(                                   msgTEXT);
end;

function inttostr(const v:integer):string; inline;
begin
    result:=sysutils.IntToStr(v);
end;

{%region --- Pointer to TEXT -------------------------------------- /fold}

const _c_addr2txt_SMB_='$';
const _c_addr2txt_DVT_=':';

function addr2str(const p:pointer):string;
begin
    result:=IntToHex({%H-}PtrUint(p),sizeOf(PtrUint)*2);
end;

function addr2txt(const p:pointer):string;
begin
    result:=_c_addr2txt_SMB_+addr2str(p);
end;

function mthd2txt(const p:pMethod):string;
begin
    result:=_c_addr2txt_SMB_+addr2str(p^.Code)+_c_addr2txt_DVT_+addr2str(p^.Data)
end;

{%endregion}

initialization
_WndDBG_manager_:=nil;

