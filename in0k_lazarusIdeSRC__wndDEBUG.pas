unit in0k_lazarusIdeSRC__wndDEBUG;
//
//

{$mode objfpc}{$H+}
interface
{.$define _DEBUG_} //< САМОдеБАГ

uses Classes, SysUtils, Controls, StdCtrls, ActnList, Forms, windows, Types,
     IDEOptionsIntf,
     IDEWindowIntf, MenuIntf,       //< да ... необходимо использовать IdeINTf
     BaseIDEIntf, LazConfigStorage; //< для настроек

procedure SetUpInIDE(const pkgClassNAME:string);
procedure ShowWindow;

procedure in0k_lazarusIdeSRC_DEBUG(const msgText:string); inline;

procedure DEBUG(const msgTYPE,msgTEXT:string); inline;
procedure DEBUG(const         msgTEXT:string); inline;

//------------------------------------------------------------------------------

type pMethod=^tMethod;

function inttostr(const v:integer):string; inline;
function addr2str(const p:pointer):string; inline;
function addr2txt(const p:pointer):string; inline;
function mthd2txt(const p:pMethod):string; inline;
function bool2Str(const b:boolean):string; inline;
function bool2Str(const b:boolean; const str4True,str4False:string): string; inline;

//function  Assigned2OK(const p:pointer):string;
//         Assgn2OK(const p:pointer):string;


implementation

{%region --- _tWndDBG_manager_ ------------------------------------ /fold}

const
  _c_wndName_textStart_='WndDBG__';
  _c_caption_textStart_='[debugLOG] ';

type
_tWndDBG_manager_=class
  {$region --- _WndDBG_ --- работа с окном ------------------------ /fold}
  protected
    function  _WndDBG_clc_wndName_:string; inline;
    function  _WndDBG_clc_Caption_:string; inline;
  protected
    procedure _WndDBG_crt_btnCLEAR_(const FormDBG:tForm);
    procedure _WndDBG_crt_btnSAVE_ (const FormDBG:tForm);
    procedure _WndDBG_crt_logMEMO_ (const FormDBG:tForm);
    procedure _WndDBG_crt_chbStayOnTOP_  (const FormDBG:tForm);
    procedure _WndDBG_crt_chbFreeOnCLOSE_(const FormDBG:tForm);
    procedure _WndDBG_crt_CONTROLS_;
    procedure _WndDBG_crt_;
  protected //<--- получение указателей на контролы
    function  _WndDBG_btnCLEAR_      :tButton;
    function  _WndDBG_btnSAVE_       :tButton;
    function  _WndDBG_logMEMO_       :tMemo;
    function  _WndDBG_chbStayOnTOP_  :TCheckBox;
    function  _WndDBG_chbFreeOnCLOSE_:TCheckBox;
  protected //<--- события контролов
    procedure _WndDBG_chbFreeOnCLOSE_onClick_({%H-}Sender:TObject);
    procedure _WndDBG_chbStayOnTOP_onClick_  ({%H-}Sender:TObject);
    procedure _WndDBG_btnCLEAR_onClick_      ({%H-}Sender:TObject);
  protected //<--- события ФОРМЫ
    procedure _WndDBG_onShow_   ({%H-}Sender:TObject);
    procedure _WndDBG_onClose_  ({%H-}Sender:TObject; var CloseAction:TCloseAction);
    procedure _WndDBG_onDestroy_({%H-}Sender:TObject);
  protected
    procedure _WndDBG_visualControls_event_ON_;
    procedure _WndDBG_visualControls_event_OF_;
  protected
    procedure _WndDBG_settings_SAVE_;
    procedure _WndDBG_settings_LOAD_;
  protected
    function  _WndDBG_lstString_:string;
    procedure _WndDBG_AddString_(const TextMSG:string);
  {$endregion --- _WndDBG_ --- }
  protected
   _wndDBG_:TForm;  // сама форма которой мы управляем
   _pkgDBG_:string; // название компонента !!! на основе него строится имя _WndDBG_
    procedure _doShowWindow_({%H-}Sender:TObject); //< это для меню
  public
    procedure MessageDBG(const MSG:string);
    procedure ShowWndDBG;
  public
    constructor Create(const pkgClassName:string);
    destructor DESTROY; override;
  end;

var // !!!SINGLETON!!!
_WndDBG_manager_:_tWndDBG_manager_;

//==============================================================================

constructor _tWndDBG_manager_.Create(const pkgClassName:string);
begin
   _wndDBG_:=NIL;
   _pkgDBG_:=pkgClassName;
end;

destructor _tWndDBG_manager_.DESTROY;
begin
    if Assigned(_wndDBG_) then _wndDBG_.FREE;
end;

//------------------------------------------------------------------------------
{$region --- _WndDBG_ --- работа с окном -------------------------- /fold}

const _c_text_Line_='---------------------------------------------------------------------------------';

const _c_text_welcome_=
'   ВНИМАНИЕ !!!'+LineEnding+
'   Чем БОЛЬШЕ строк в этом окне, тем тормазнутее работает IDE Lazarus.';

//------------------------------------------------------------------------------

function _tWndDBG_manager_._WndDBG_clc_wndName_:string;
begin
    result:=_c_wndName_textStart_+_pkgDBG_;
end;

function _tWndDBG_manager_._WndDBG_clc_Caption_:string;
begin
    result:=_c_caption_textStart_+_pkgDBG_;
end;

//------------------------------------------------------------- события ОКНА ---

procedure _tWndDBG_manager_._WndDBG_onShow_(Sender: TObject);
begin
    // втавляем строку разделитель
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

// вот блин ... и тока ради этого приходится все тут городить
procedure _tWndDBG_manager_._WndDBG_onDestroy_(Sender: TObject);
begin
   _wndDBG_:=nil;
end;

//-------------------------------------------------------- события КОНТРОЛОВ ---

procedure _tWndDBG_manager_._WndDBG_chbFreeOnCLOSE_onClick_(Sender: TObject);
begin
    {$ifdef _DEBUG_}DEBUG('selfDEBUG','_WndDBG_chbFreeOnCLOSE_onClick_');{$endIf}
   _WndDBG_settings_SAVE_;
end;

procedure _tWndDBG_manager_._WndDBG_chbStayOnTOP_onClick_(Sender: TObject);
begin
    {$ifdef _DEBUG_}DEBUG('selfDEBUG','_WndDBG_chbStayOnTOP_onClick_');{$endIf}
    if _WndDBG_chbStayOnTOP_.Checked
    then _wndDBG_.FormStyle:=fsStayOnTop
    else _wndDBG_.FormStyle:=fsNormal;
   _WndDBG_settings_SAVE_;
end;

procedure _tWndDBG_manager_._WndDBG_btnCLEAR_onClick_(Sender:TObject);
begin
    {$ifdef _DEBUG_}DEBUG('selfDEBUG','_WndDBG_btnCLEAR_onClick_');{$endIf}
    if Assigned(_wndDBG_) then begin
        _WndDBG_logMEMO_.Clear;
    end;
end;

//---------------------------------------------- влючение/отключение СОБЫТИЙ ---

procedure _tWndDBG_manager_._WndDBG_visualControls_event_ON_;
begin
    {$ifdef _DEBUG_}DEBUG('selfDEBUG._WndDBG_visualControls_event_ON_','StART');{$endIf}
    //---
   _WndDBG_chbFreeOnCLOSE_.OnClick:=@_WndDBG_chbFreeOnCLOSE_onClick_;
   _WndDBG_chbStayOnTOP_  .OnClick:=@_WndDBG_chbStayOnTOP_onClick_;
   _WndDBG_btnCLEAR_      .OnClick:=@_WndDBG_btnCLEAR_onClick_;
   _WndDBG_btnSAVE_       .OnClick:=nil;
    //---
   _wndDBG_.OnDestroy:=@_WndDBG_onDestroy_;
   _wndDBG_.OnClose  :=@_WndDBG_onClose_;
   _wndDBG_.OnShow   :=@_WndDBG_onShow_;
    //---
    {$ifdef _DEBUG_}DEBUG('selfDEBUG._WndDBG_visualControls_event_ON_','EnD');{$endIf}
end;

procedure _tWndDBG_manager_._WndDBG_visualControls_event_OF_;
begin
    {$ifdef _DEBUG_}DEBUG('selfDEBUG._WndDBG_visualControls_event_OF_','StART');{$endIf}
    //---
   _WndDBG_chbFreeOnCLOSE_.OnClick:=nil;
   _WndDBG_chbStayOnTOP_  .OnClick:=nil;
   _WndDBG_btnCLEAR_      .OnClick:=nil;
   _WndDBG_btnSAVE_       .OnClick:=nil;
    //---
   _wndDBG_.OnDestroy:=nil;
   _wndDBG_.OnClose  :=nil;
   _wndDBG_.OnShow   :=nil;
    //---
    {$ifdef _DEBUG_}DEBUG('selfDEBUG._WndDBG_visualControls_event_OF_','EnD');{$endIf}
end;

//----------------------------------------------------------- создание формы ---

{%region --- создание САМИХ визуальных компонентов ---------------- /fold}

const
 _cWndDBG_btnCLEAR_text_ = 'Clear';
 _cWndDBG_btnCLEAR_hint_ = 'Clear';

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
        Caption :=_cWndDBG_btnCLEAR_text_;
        Hint    :=_cWndDBG_btnCLEAR_hint_;
        ShowHint:=true;
        //---
        //OnClick:=@_WndDBG_btnCLEAR_onClick_;
    end;
end;

//------------------------------------------------------------------------------

const
 _cWndDBG_btnSAVE_text_ = 'Save';
 _cWndDBG_btnSAVE_hint_ = 'Save';

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
        Caption :=_cWndDBG_btnSAVE_text_;
        Hint    :=_cWndDBG_btnSAVE_hint_;
        ShowHint:=true;
    end;
end;

//------------------------------------------------------------------------------

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
        ScrollBars:=ssAutoBoth;
        WordWrap:=FALSE;
        Anchors:=[akLeft,akTop,akRight,akBottom];
        //------
        Text:=_c_text_Line_+LineEnding+_c_text_welcome_+LineEnding+_c_text_Line_;
        Hint:=_c_text_welcome_;
        ShowHint:=true;
        //---
        font.Name:='Consolas';//IDEEditorOptions.  .EditorFont;
        font.Size:=8;
        //font.IsMonoSpace;
    end;
end;

//------------------------------------------------------------------------------

const
 _cWndDBG_chbStayOnTop_text_ = 'Stay on TOP';
 _cWndDBG_chbStayOnTop_hint_ = 'Stay on TOP';

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
        Caption :=_cWndDBG_chbStayOnTop_text_;
        Hint    :=_cWndDBG_chbStayOnTop_hint_;
        ShowHint:=true;
        //------
    end;
end;

//------------------------------------------------------------------------------

const
 _cWndDBG_chbFreeOnCLOSE_text_ = 'FREE on Close';
 _cWndDBG_chbFreeOnCLOSE_hint_ = 'FREE on Close';

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

        Caption :=_cWndDBG_chbFreeOnCLOSE_text_;
        Hint    :=_cWndDBG_chbFreeOnCLOSE_hint_;
        ShowHint:=true;
    end;
end;

{%endregion}

procedure _tWndDBG_manager_._WndDBG_crt_CONTROLS_;
begin // !!! ОЧЕРЕДНОСТЬ создания ВАЖНА (см. получение указателей)
   _WndDBG_crt_btnCLEAR_      (_wndDBG_);
   _WndDBG_crt_btnSAVE_       (_wndDBG_);
   _WndDBG_crt_logMEMO_       (_wndDBG_);
   _WndDBG_crt_chbStayOnTOP_  (_wndDBG_);
   _WndDBG_crt_chbFreeOnCLOSE_(_wndDBG_);
end;

procedure _tWndDBG_manager_._WndDBG_crt_;
begin
   _wndDBG_:=TForm.Create(Application);
   _wndDBG_.Hide;
    //---
   _wndDBG_.BorderIcons:=[biSystemMenu];
   _wndDBG_.Name   :=_WndDBG_clc_wndName_; //< ОБЯЗАТЕЛЬНО
   _wndDBG_.Caption:=_WndDBG_clc_Caption_;
    //---
   _WndDBG_crt_CONTROLS_;
   _WndDBG_settings_LOAD_;
   _WndDBG_visualControls_event_ON_;
end;

//---------------------------- получение указателей на визуальные компоненты ---

function _tWndDBG_manager_._WndDBG_btnCLEAR_:tButton;
begin
   result:=tButton(_wndDBG_.Controls[0]);
end;

function _tWndDBG_manager_._WndDBG_btnSAVE_:tButton;
begin
   result:=tButton(_wndDBG_.Controls[1]);
end;

function _tWndDBG_manager_._WndDBG_logMEMO_:tMemo;
begin
   result:=TMemo(_wndDBG_.Controls[2]);
end;

function _tWndDBG_manager_._WndDBG_chbStayOnTOP_:TCheckBox;
begin
   result:=TCheckBox(_wndDBG_.Controls[3]);
end;

function _tWndDBG_manager_._WndDBG_chbFreeOnCLOSE_:TCheckBox;
begin
   result:=TCheckBox(_wndDBG_.Controls[4]);
end;

//-------------------------------------- загрузка/сохранение настроек окошка ---

const _c_settings_EXT_='.xml';
      _c_settings_NAME_StayOnTOP_='StayOnTOP';
      _c_settings_NAME_FreeCLOSE_='FreeOnCLOSE';

procedure _tWndDBG_manager_._WndDBG_settings_Save_;
var Config: TConfigStorage;
begin
   _WndDBG_visualControls_event_OF_;
    {$ifdef _DEBUG_}DEBUG('selfDEBUG.saveSettings','START');{$endIf}
    try Config:=GetIDEConfigStorage(_wndDBG_.Name+_c_settings_EXT_,false);
        {$ifdef _DEBUG_}
        if Assigned(Config)
        then DEBUG('selfDEBUG.saveSettings','Config isLOAD "'+_wndDBG_.Name+_c_settings_EXT_+'"')
        else DEBUG('selfDEBUG.saveSettings','Config UNload "'+_wndDBG_.Name+_c_settings_EXT_+'"');
        {$endIf}
        try // --- галочки
            Config.SetDeleteValue(_c_settings_NAME_StayOnTOP_,_WndDBG_chbStayOnTOP_.Checked,false);
            Config.SetDeleteValue(_c_settings_NAME_FreeCLOSE_,_WndDBG_chbFreeOnCLOSE_.Checked,false);
            // --- размер
            Config.SetDeleteValue('',_wndDBG_.BoundsRect,Rect(0,0,0,0));
            // ---
            Config.WriteToDisk;
        finally Config.Free; end;
        {$ifdef _DEBUG_}DEBUG('selfDEBUG.saveSettings','END');{$endIf}
    except {жестоко как-то, мож по изящнее надо?}
        {$ifdef _DEBUG_}DEBUG('selfDEBUG.saveSettings','FAIL 00');{$endIf}
    end;
   _WndDBG_visualControls_event_ON_;
end;

procedure _tWndDBG_manager_._WndDBG_settings_LOAD_;
var Config: TConfigStorage;
    r:trect;
begin
   _WndDBG_visualControls_event_OF_;
    {$ifdef _DEBUG_}DEBUG('selfDEBUG.loadSettings','START');{$endIf}
    try Config:=GetIDEConfigStorage(_wndDBG_.Name+_c_settings_EXT_,true);
        {$ifdef _DEBUG_}
        if Assigned(Config)
        then DEBUG('selfDEBUG.loadSettings','Config isLOAD "'+_wndDBG_.Name+_c_settings_EXT_+'"')
        else DEBUG('selfDEBUG.loadSettings','Config UNload "'+_wndDBG_.Name+_c_settings_EXT_+'"');
        {$endIf}
        try // --- галочки
           _WndDBG_chbStayOnTOP_.Checked:=Config.GetValue(_c_settings_NAME_StayOnTOP_,false);
           _WndDBG_chbFreeOnCLOSE_.Checked:=Config.GetValue(_c_settings_NAME_FreeCLOSE_,false);
            // --- размер
            Config.GetValue('',r,_wndDBG_.BoundsRect);
           _wndDBG_.BoundsRect:=r;
            // мож тут проверку какйю ??? // if screen.DesktopRect.Left:=;
        finally Config.Free; end;
        {$ifdef _DEBUG_}DEBUG('selfDEBUG.loadSettings','END');{$endIf}
    except {жестоко как-то, мож по изящнее надо?}
        {$ifdef _DEBUG_}DEBUG('selfDEBUG.loadSettings','FAIL 00');{$endIf}
    end;
   _WndDBG_visualControls_event_ON_;
end;

//--------------------------------------------------------- добавление строк ---

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
        Repaint; //< это ВСМЕСТО `Application.ProcessMessages` из `_tWndDBG_manager_.MessageDBG`
    end;
end;

{$endregion --- _WndDBG_ ---}
//------------------------------------------------------------------------------

procedure _tWndDBG_manager_._doShowWindow_(Sender:TObject);
begin
    if not Assigned(_wndDBG_) then begin
        if _pkgDBG_<>'' then begin
           _WndDBG_crt_;
        end;
    end;
    if Assigned(_wndDBG_) then begin
       _wndDBG_.Show;
       _wndDBG_.BringToFront;
    end;
end;

procedure _tWndDBG_manager_.ShowWndDBG;
begin
   _doShowWindow_(nil);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
  _cDateTimeFormat_='hh:mm:ss`zzz';
  _cSpaceCharacter_=' ';

procedure _tWndDBG_manager_.MessageDBG(const MSG:string);
var tmp:string;
begin
    DateTimeToString(tmp,_cDateTimeFormat_,now);
    if Assigned(_wndDBG_) then _WndDBG_AddString_(tmp+_cSpaceCharacter_+MSG);
    //Application.ProcessMessages; <--- НЕЛЬЗЯ !!!
end;

{%endregion}
//------------------------------------------------------------------------------

procedure SetUpInIDE(const pkgClassNAME:string);
begin
    if not Assigned(_WndDBG_manager_) then begin
        // создаем МЕНЕДЖЕР окна
       _WndDBG_manager_:=_tWndDBG_manager_.Create(pkgClassNAME);
        // создаем пункт меню для него
        RegisterIDEMenuCommand(itmViewIDEInternalsWindows, _WndDBG_manager_._WndDBG_clc_Caption_,_WndDBG_manager_._WndDBG_clc_Caption_,@_WndDBG_manager_._doShowWindow_,nil);
    end;
end;

{procedure LazarusIDE_CLEAR;
begin
    if Assigned(_WndDBG_manager_) then begin
       _WndDBG_manager_.FREE;
       _WndDBG_manager_:=nil;
    end;
end;}

procedure ShowWindow;
begin
    if Assigned(_WndDBG_manager_) then begin
        _WndDBG_manager_.ShowWndDBG;
    end;
end;


//------------------------------------------------------------------------------

procedure in0k_lazarusIdeSRC_DEBUG(const msgText:string);
begin
    if Assigned(_WndDBG_manager_) then _WndDBG_manager_.MessageDBG(msgTEXT);
end;

procedure DEBUG(const msgTEXT:string);
begin
    in0k_lazarusIdeSRC_DEBUG(msgTEXT);
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

//------------------------------------------------------------------------------

function bool2Str(const b:boolean; const str4True,str4False:string):string;
begin
    result:=SysUtils.BoolToStr(B, str4True,str4False);
end;

function bool2Str(const b:boolean):string;
begin
    result:=BoolToStr(B,'true','false');
end;

function Assigned2OK(const p:pointer):string;
begin
    if Assigned(P)
    then result:='ok'
    else result:='ER';
    result:=_c_bOPN_+result+_c_bCLS_;
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
finalization
 if Assigned(_WndDBG_manager_) then begin
  _WndDBG_manager_.FREE;
  _WndDBG_manager_:=nil;
 end;
end.

