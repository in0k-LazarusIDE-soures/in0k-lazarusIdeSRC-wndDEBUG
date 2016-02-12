unit in0k_lazIdeSRC_wndDEBUG;

{$mode objfpc}{$H+}
interface

uses Classes, SysUtils, Controls, StdCtrls, ActnList, Forms,
     BaseIDEIntf, LazConfigStorage; //< для настроек

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
    procedure a_ClearExecute(Sender: TObject);
    procedure a_FreeOnCloseExecute(Sender: TObject);
    procedure a_StayOnTopExecute(Sender: TObject);
    procedure FormClose(Sender:TObject; var CloseAction:TCloseAction);
    procedure FormCreate(Sender:TObject);
    procedure FormShow(Sender:TObject);
  protected
    function  lstString:string; inline;
    procedure AddString(const TextMSG:string); inline;
  protected
    procedure _settings_Save_;
    procedure _settings_Load_;
  public
    constructor {%H-}Create(TheOwner:TComponent; const pkgClassNAME, newCaption:string);
  public
    procedure Message(const TextMSG:string);
  end;

implementation

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
   _settings_Load_;
    Memo1.Text:=_c_welcome_text_;
end;

//------------------------------------------------------------------------------

procedure TWnd_DEBUG.FormShow(Sender: TObject);
begin
    if (memo1.Lines.Count>0)and(lstString<>_c_text_Line_)
    then AddString(_c_text_Line_)
end;

procedure TWnd_DEBUG.FormClose(Sender:TObject; var CloseAction:TCloseAction);
begin
   _settings_Save_;
    inherited;
    if CheckBox2.Checked
    then CloseAction:=caFree
    else CloseAction:=caHide;
end;

//------------------------------------------------------------------------------

procedure TWnd_DEBUG.a_ClearExecute(Sender: TObject);
begin
    memo1.Clear;
end;

procedure TWnd_DEBUG.a_FreeOnCloseExecute(Sender: TObject);
begin
   _settings_Save_;
end;

procedure TWnd_DEBUG.a_StayOnTopExecute(Sender: TObject);
begin
    if CheckBox1.Checked
    then self.FormStyle:=fsStayOnTop
    else self.FormStyle:=fsNormal;
   _settings_Save_;
end;

//------------------------------------------------------------------------------

// последняя вставленная строка (парная с `AddString`)
function TWnd_DEBUG.lstString:string;
begin
    result:='';
    with memo1 do begin
        if Lines.Count>0 then begin
            Result:=Lines.Strings[0];
        end;
    end;
end;

// добавить строку (парная с `lstString`)
procedure TWnd_DEBUG.AddString(const TextMSG:string);
begin
    with memo1 do begin
        Lines.BeginUpdate;
            Lines.Insert(0,TextMSG);
            SelLength:=0;
            SelStart :=0;
        Lines.EndUpdate;
    end;
end;

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

//--- про настройки окошка -----------------------------------------------------

const _c_settings_EXT_='.xml';
      _c_settings_NAME_StayOnTOP_='StayOnTOP';
      _c_settings_NAME_FreeCLOSE_='FreeOnCLOSE';

procedure TWnd_DEBUG._settings_Save_;
var Config: TConfigStorage;
begin
    try Config:=GetIDEConfigStorage(self.Name+_c_settings_EXT_,false);
        try // --- галочки
            Config.SetDeleteValue(_c_settings_NAME_StayOnTOP_,CheckBox1.Checked,false);
            Config.SetDeleteValue(_c_settings_NAME_FreeCLOSE_,CheckBox2.Checked,false);
            // --- размер
            Config.SetDeleteValue('',self.BoundsRect,Rect(0,0,0,0));
        finally Config.Free; end;
    except {жестоко как-то, мож по изящнее надо?} end;
end;

procedure TWnd_DEBUG._settings_Load_;
var Config: TConfigStorage;
    r:trect;
begin
    try Config:=GetIDEConfigStorage(self.Name+_c_settings_EXT_,true);
        try // --- галочки
            CheckBox1.Checked:=Config.GetValue(_c_settings_NAME_StayOnTOP_,true);
            CheckBox2.Checked:=Config.GetValue(_c_settings_NAME_FreeCLOSE_,false);
            // --- размер
            Config.GetValue('',r,self.BoundsRect);
            self.BoundsRect:=r;
            // мож тут проверку какйю ???
            // if screen.DesktopRect.Left:=;
        finally Config.Free; end;
    except {жестоко как-то, мож по изящнее надо?} end;
end;

end.

