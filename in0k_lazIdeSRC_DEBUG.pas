unit in0k_lazIdeSRC_DEBUG;
{$mode objfpc}{$H+}
interface

uses Classes, SysUtils, Controls, StdCtrls, ActnList, Forms, windows, Types,
     IDEWindowIntf, MenuIntf,       //< да ... необходимо использовать IdeINTf
     BaseIDEIntf, LazConfigStorage; //< для настроек


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

{%region --- _tWndDBG_window_ -- /fold}


const
 cRes_chbFreeOnClose_text  = 'FREE on Close';
 cRes_chbFreeOnClose_hint  = 'FREE on Close';

 cRes_chbStayOnTop_text    = 'Stay on TOP';
 cRes_chbStayOnTop_hint    = 'Stay on TOP';

 cRes_btnCLEAR_text        = 'Clear';
 cRes_btnCLEAR_hint        = 'clear';

 cRes_btnSAVE_text         = 'Save';
 cRes_btnSAVE_hint         = 'Save';

 cRes_logMEMO_hint         = 'a';

(*

TYPE

  TWnd_DEBUG = class(TForm)
    a_FreeOnClose: TAction;
    a_StayOnTop: TAction;
    a_Clear: TAction;
    a_Save: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Memo1: TMemo;
    procedure FormCreate          ({%H-}Sender:TObject);
    procedure FormShow            ({%H-}Sender:TObject);
    procedure FormClose           ({%H-}Sender:TObject; var CloseAction:TCloseAction);
    procedure a_ClearExecute      ({%H-}Sender: TObject);
    procedure a_FreeOnCloseExecute({%H-}Sender: TObject);
    procedure a_StayOnTopExecute  ({%H-}Sender: TObject);
  protected
    function  lstString:string; inline;
    procedure AddString(const TextMSG:string); inline;
  public
    constructor {%H-}Create(TheOwner:TComponent; const pkgClassNAME, newCaption:string);
  public
    procedure Message(const TextMSG:string);
  end;

{$R *.lfm}

const _c_text_Line_='---------------------------------------------------------------------------------';

const _c_welcome_text_=
'   ВНИМАНИЕ !!!'+LineEnding+
'   Чем БОЛЬШЕ строк в этом окне, тем тормазнутее работает IDE Lazarus.'+LineEnding+
   _c_text_Line_;

constructor TWnd_DEBUG.Create(TheOwner:TComponent; const pkgClassNAME,newCaption:string);
begin
    inherited Create(TheOwner);
    self.Name   := self.ClassName +'_'+pkgClassNAME; //< ОБЯЗАТЕЛЬНО
    self.Caption:= newCaption;
end;

procedure TWnd_DEBUG.FormCreate(Sender: TObject);
begin
    Memo1.Text:=_c_welcome_text_;
end;

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------



//------------------------------------------------------------------------------


//------------------------------------------------------------------------------

const
  _cDateTimeFormat_='hh:mm:ss`zzz';
  _cSpaceCharacter_=' ';

procedure TWnd_DEBUG.Message(const TextMSG:string);
var tmp:string;
begin
    if self.Visible then begin
        DateTimeToString(tmp,_cDateTimeFormat_,now);
        AddString(tmp+_cSpaceCharacter_+TextMSG);
    end;
end;


*)

{%endregion}


{%region --- _tWndDBG_manager_ -- /fold}

const _c_caption_text_='[eventLOG]';

type
_tWndDBG_manager_=class
  protected
   _WndDBG_:TForm;
   _pkgName_:string;
  protected
    procedure _WndDBG_crt_btnCLEAR_(const FormDBG:tForm);
    procedure _WndDBG_crt_btnSAVE_ (const FormDBG:tForm);
    procedure _WndDBG_crt_logMEMO_ (const FormDBG:tForm);
    procedure _WndDBG_crt_chbStayOnTOP_  (const FormDBG:tForm);
    procedure _WndDBG_crt_chbFreeOnCLOSE_(const FormDBG:tForm);
    procedure _WndDBG_crt_CONTROLS_;
    procedure _WndDBG_crt_;
  protected
    function  _WndDBG_btnCLEAR_      :tButton;
    function  _WndDBG_btnSAVE_       :tButton;
    function  _WndDBG_logMEMO_       :tMemo;
    function  _WndDBG_chbStayOnTOP_  :TCheckBox;
    function  _WndDBG_chbFreeOnCLOSE_:TCheckBox;
  protected
    procedure _WndDBG_btnCLEAR_onClick_(Sender: TObject);
    procedure _WndDBG_chbStayOnTOP_onClick_(Sender: TObject);
    procedure _WndDBG_chbFreeOnCLOSE_onClick_(Sender: TObject);
  protected
    procedure _WndDBG_settings_SAVE_;
    procedure _WndDBG_settings_LOAD_;
  protected
    procedure _WndDBG_onShow_ (Sender: TObject);
    procedure _WndDBG_onClose_(Sender:TObject; var CloseAction:TCloseAction);
    procedure _WndDBG_onDestroy_({%H-}Sender:TObject);
  protected
    function  _WndDBG_lstString_:string;
    procedure _WndDBG_AddString_(const TextMSG:string);
  public
    function  wndCaption:string;
    procedure MessageDBG(const MSG:string);
    procedure ShowWindow;
    procedure onClick_ShowWindow({%H-}Sender:TObject); //< это для меню
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


const _c_text_Line_='---------------------------------------------------------------------------------';

const _c_welcome_text_=
'   ВНИМАНИЕ !!!'+LineEnding+
'   Чем БОЛЬШЕ строк в этом окне, тем тормазнутее работает IDE Lazarus.'+LineEnding+
   _c_text_Line_;


procedure _tWndDBG_manager_._WndDBG_crt_btnCLEAR_(const FormDBG:tForm);
begin
    with TButton.Create(FormDBG) do begin
        Parent:=FormDBG;
        Anchors:=[];
        //---
        with AnchorSide[akLeft] do begin
            Control:=FormDBG;
            Side   :=asrLeft;
        end;
        with AnchorSide[akTop] do begin
            Control:=FormDBG;
            Side   :=asrTop;
        end;
        //---
        Anchors:=[akLeft,akTop];
        //-------
        Caption :=cRes_btnCLEAR_text;
        Hint    :=cRes_btnCLEAR_hint;
        ShowHint:=true;
        //---
        OnClick:=@_WndDBG_btnCLEAR_onClick_;
    end;
end;

procedure _tWndDBG_manager_._WndDBG_crt_btnSAVE_(const FormDBG:tForm);
begin
    with TButton.Create(FormDBG) do begin
        Parent:=FormDBG;
        Anchors:=[];
        //---
        with AnchorSide[akLeft] do begin
            Control:=_WndDBG_btnCLEAR_;
            Side   := asrRight;
        end;
        with AnchorSide[akTop] do begin
            Control:=FormDBG;
            Side   :=asrTop;
        end;
        //---
        Anchors:=[akLeft,akTop];
        //-------
        Caption :=cRes_btnSAVE_text;
        Hint    :=cRes_btnSAVE_hint;
        ShowHint:=true;
    end;
end;

procedure _tWndDBG_manager_._WndDBG_crt_logMEMO_(const FormDBG:tForm);
begin
    with TMemo.Create(FormDBG) do begin
        Parent:=FormDBG;
        Anchors:=[];
        //---
        with AnchorSide[akLeft] do begin
            Control:=FormDBG;
            Side   :=asrLeft;
        end;
        with AnchorSide[akTop] do begin
            Control:=_WndDBG_btnCLEAR_;
            Side   := asrBottom;
        end;
        with AnchorSide[akRight] do begin
            Control:=FormDBG;
            Side   :=asrRight;
        end;
        with AnchorSide[akBottom] do begin
            Control:= FormDBG;
            Side   := asrBottom;
        end;
        //---
        Anchors:=[akLeft,akTop,akRight,akBottom];

        //------
        //Caption :=cRes_chbStayOnTop_text;
        Hint    :=cRes_logMEMO_hint;
        ShowHint:=true;

        OnClick :=@_WndDBG_chbFreeOnCLOSE_onClick_;

    end;
end;

procedure _tWndDBG_manager_._WndDBG_crt_chbStayOnTOP_(const FormDBG:tForm);
begin
    with TCheckBox.Create(FormDBG) do begin
        Parent:=FormDBG;
        Anchors:=[];
        //---
        with AnchorSide[akLeft] do begin
            Control:=_WndDBG_btnSAVE_;
            Side   := asrRight;
        end;
        BorderSpacing.Left:=4*GetSystemMetrics(SM_CXBORDER);
        //---
        with AnchorSide[akTop] do begin
            Control:=_WndDBG_btnCLEAR_;
            Side   :=asrCenter;
        end;
        //---
        Anchors:=[akLeft,akTop];
        //------
        Caption :=cRes_chbStayOnTop_text;
        Hint    :=cRes_chbStayOnTop_hint;
        ShowHint:=true;
        //------
        OnClick :=@_WndDBG_chbStayOnTOP_onClick_;
    end;
end;

procedure _tWndDBG_manager_._WndDBG_crt_chbFreeOnCLOSE_(const FormDBG:tForm);
begin
    with TCheckBox.Create(FormDBG) do begin
        Parent:=FormDBG;
        Anchors:=[];
        //---
        with AnchorSide[akTop] do begin
            Control:=_WndDBG_chbStayOnTOP_;
            Side   := asrTop;
        end;
        with AnchorSide[akRight] do begin
            Control:=FormDBG;
            Side   :=asrRight;
        end;
        BorderSpacing.Right:=4*GetSystemMetrics(SM_CXBORDER);
        //---
        Anchors:=[akTop,akRight];

        Alignment:=taLeftJustify;

        Caption :=cRes_chbFreeOnClose_text;
        Hint    :=cRes_chbFreeOnClose_hint;
        ShowHint:=true;
    end;
end;

//---

procedure _tWndDBG_manager_._WndDBG_crt_;
begin
   _WndDBG_:=TForm.Create(Application);
   _WndDBG_.BorderStyle     :=bsSizeToolWin;
   _WndDBG_.Name:='WndDEBUG__'+_pkgName_; //< ОБЯЗАТЕЛЬНО
   _WndDBG_.Caption:= wndCaption;
    //---
   _WndDBG_.OnShow   :=@_WndDBG_onShow_;
   _WndDBG_.OnClose  :=@_WndDBG_onClose_;
   _WndDBG_.OnDestroy:=@_WndDBG_onDestroy_;
    //---
   _WndDBG_crt_CONTROLS_;
   _WndDBG_settings_LOAD_;
end;

procedure _tWndDBG_manager_._WndDBG_crt_CONTROLS_;
begin
   _WndDBG_crt_btnCLEAR_      (_WndDBG_);
   _WndDBG_crt_btnSAVE_       (_WndDBG_);
   _WndDBG_crt_logMEMO_       (_WndDBG_);
   _WndDBG_crt_chbStayOnTOP_  (_WndDBG_);
   _WndDBG_crt_chbFreeOnCLOSE_(_WndDBG_);
end;

//------------------------------------------------------------------------------

function _tWndDBG_manager_._WndDBG_btnCLEAR_:tButton;
begin
   result:=tButton(_WndDBG_.Controls[0]);
end;

function _tWndDBG_manager_._WndDBG_btnSAVE_:tButton;
begin
   result:=tButton(_WndDBG_.Controls[1]);
end;

function _tWndDBG_manager_._WndDBG_logMEMO_:tMemo;
begin
   result:=TMemo(_WndDBG_.Controls[2]);
end;

function _tWndDBG_manager_._WndDBG_chbStayOnTOP_:TCheckBox;
begin
   result:=TCheckBox(_WndDBG_.Controls[3]);
end;

function _tWndDBG_manager_._WndDBG_chbFreeOnCLOSE_:TCheckBox;
begin
   result:=TCheckBox(_WndDBG_.Controls[4]);
end;

//------------------------------------------------------------------------------

procedure _tWndDBG_manager_._WndDBG_btnCLEAR_onClick_(Sender:TObject);
begin
    if Assigned(_WndDBG_) then begin
        _WndDBG_logMEMO_.Clear;
    end;
end;

procedure _tWndDBG_manager_._WndDBG_chbFreeOnCLOSE_onClick_(Sender: TObject);
begin
   _WndDBG_settings_SAVE_;
end;

procedure _tWndDBG_manager_._WndDBG_chbStayOnTOP_onClick_(Sender: TObject);
begin
    if _WndDBG_chbStayOnTOP_.Checked
    then _WndDBG_.FormStyle:=fsStayOnTop
    else _WndDBG_.FormStyle:=fsNormal;
   _WndDBG_settings_SAVE_;
end;

//--- про настройки окошка -----------------------------------------------------

const _c_settings_EXT_='.xml';
      _c_settings_NAME_StayOnTOP_='StayOnTOP';
      _c_settings_NAME_FreeCLOSE_='FreeOnCLOSE';

procedure _tWndDBG_manager_._WndDBG_settings_Save_;
var Config: TConfigStorage;
begin
    try Config:=GetIDEConfigStorage(_WndDBG_.Name+_c_settings_EXT_,false);
        try // --- галочки
            Config.SetDeleteValue(_c_settings_NAME_StayOnTOP_,_WndDBG_chbStayOnTOP_.Checked,false);
            Config.SetDeleteValue(_c_settings_NAME_FreeCLOSE_,_WndDBG_chbFreeOnCLOSE_.Checked,false);
            // --- размер
            Config.SetDeleteValue('',_WndDBG_.BoundsRect,Rect(0,0,0,0));
        finally Config.Free; end;
    except {жестоко как-то, мож по изящнее надо?} end;
end;

procedure _tWndDBG_manager_._WndDBG_settings_LOAD_;
var Config: TConfigStorage;
    r:trect;
begin
    try Config:=GetIDEConfigStorage(_WndDBG_.Name+_c_settings_EXT_,true);
        try // --- галочки
           _WndDBG_chbStayOnTOP_.Checked:=Config.GetValue(_c_settings_NAME_StayOnTOP_,true);
           _WndDBG_chbFreeOnCLOSE_.Checked:=Config.GetValue(_c_settings_NAME_FreeCLOSE_,false);
            // --- размер
            Config.GetValue('',r,_WndDBG_.BoundsRect);
           _WndDBG_.BoundsRect:=r;
            // мож тут проверку какйю ???
            // if screen.DesktopRect.Left:=;
        finally Config.Free; end;
    except {жестоко как-то, мож по изящнее надо?} end;
end;


//------------------------------------------------------------------------------

// последняя вставленная строка (парная с `AddString`)
function _tWndDBG_manager_._WndDBG_lstString_:string;
begin
    result:='';
    with _WndDBG_logMEMO_ do begin
        if Lines.Count>0 then begin
            Result:=Lines.Strings[0];
        end;
    end;
end;

// добавить строку (парная с `lstString`)
procedure _tWndDBG_manager_._WndDBG_AddString_(const TextMSG:string);
begin
    with _WndDBG_logMEMO_ do begin
        Lines.BeginUpdate;
            Lines.Insert(0,TextMSG);
            SelLength:=0;
            SelStart :=0;
        Lines.EndUpdate;
    end;
end;

//------------------------------------------------------------------------------


procedure _tWndDBG_manager_._WndDBG_onShow_(Sender: TObject);
begin
    if (_WndDBG_logMEMO_.Lines.Count>0)and(_WndDBG_lstString_<>_c_text_Line_)
    then _WndDBG_AddString_(_c_text_Line_)
end;

procedure _tWndDBG_manager_._WndDBG_onClose_(Sender:TObject; var CloseAction:TCloseAction);
begin
   _WndDBG_settings_SAVE_;
    inherited;
    if _WndDBG_chbFreeOnCLOSE_.Checked
    then CloseAction:=caFree
    else CloseAction:=caHide;
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
           _WndDBG_crt_;
        end;
    end;
    if Assigned(_WndDBG_) then begin
       _WndDBG_.Show;
       _WndDBG_.BringToFront;
    end;
end;

procedure _tWndDBG_manager_.onClick_ShowWindow(Sender:TObject);
begin
    ShowWindow;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure _tWndDBG_manager_.MessageDBG(const MSG:string);
begin
    //if Assigned(_WndDBG_) and (_WndDBG_.Visible) then _WndDBG_.Message(MSG);
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
   {_WndDBG_manager_.FREE;}
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
    //if Assigned(_WndDBG_manager_) then _WndDBG_manager_.MessageDBG(msgTEXT);
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
//_WndDBG_manager_:=nil;

end.

