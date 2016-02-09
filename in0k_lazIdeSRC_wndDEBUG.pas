unit in0k_lazIdeSRC_wndDEBUG;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils,
     Controls, StdCtrls, ActnList,
     Forms,
     LCLProc, BaseIDEIntf, LazConfigStorage,
     IDEWindowIntf; //< да ... необходимо использовать IdeINTf

TYPE

  { TWnd_DEBUG }

  TWnd_DEBUG = class(TForm)
    a_StayOnTop: TAction;
    a_Clear: TAction;
    a_Save: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Memo1: TMemo;
    procedure a_ClearExecute(Sender: TObject);
    procedure a_StayOnTopExecute(Sender: TObject);
    procedure a_StayOnTopUpdate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
    function  lstString:string; inline;
    procedure AddString(const TextMSG:string); inline;
  protected
    procedure _settings_Save_;
    procedure _settings_Load_;
  public
    constructor {%H-}Create(TheOwner:TComponent; const pkgClassNAME,pkgNAME:string);
  public
    procedure Message(const TextMSG:string);
  end;


implementation

{$R *.lfm}

const _c_text_Line_='---------------------------------------------------------------------------------';

constructor TWnd_DEBUG.Create(TheOwner:TComponent; const pkgClassNAME,pkgNAME:string);
begin
    inherited Create(TheOwner);
    self.Name:=self.ClassName+'_'+pkgClassNAME;
    self.Caption  :=pkgNAME;
end;

procedure TWnd_DEBUG.FormCreate(Sender: TObject);
begin
    FormStyle:=fsStayOnTop;
    Memo1.Clear;
end;

procedure TWnd_DEBUG.FormShow(Sender: TObject);
begin
   _settings_Load_;
    if (memo1.Lines.Count>0)and(lstString<>_c_text_Line_)
    then AddString(_c_text_Line_)
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TWnd_DEBUG.a_ClearExecute(Sender: TObject);
begin
    memo1.Clear;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TWnd_DEBUG.a_StayOnTopExecute(Sender: TObject);
begin
    if self.FormStyle=fsStayOnTop then self.FormStyle:=fsNormal
    else self.FormStyle:=fsStayOnTop;
end;

procedure TWnd_DEBUG.a_StayOnTopUpdate(Sender: TObject);
begin // ????
    tAction(Sender).Checked:=(self.FormStyle=fsStayOnTop);
end;

procedure TWnd_DEBUG.FormClose(Sender:TObject; var CloseAction:TCloseAction);
begin
    inherited;
    CloseAction:=caHide;
   _settings_Save_;
end;


//------------------------------------------------------------------------------

function TWnd_DEBUG.lstString:string;
begin
    result:='';
    with memo1 do begin
        if Lines.Count>0 then begin
            Result:=Lines.Strings[0];
        end;
    end;
end;

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


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

const _c_settings_EXT_='.xml';
      _c_settings_NAME_StayOnTOP_='StayOnTOP';

procedure TWnd_DEBUG._settings_Save_;
var Config: TConfigStorage;
begin
    try
        Config:=GetIDEConfigStorage(self.Name+_c_settings_EXT_,false);
        try
            // --- галочка
            Config.SetDeleteValue(_c_settings_NAME_StayOnTOP_,CheckBox1.Checked,false);
            // --- размер
            Config.SetDeleteValue('',self.BoundsRect,Rect(0,0,0,0));
        finally
          Config.Free;
        end;
    except
    end;
end;

procedure TWnd_DEBUG._settings_Load_;
var Config: TConfigStorage;
    r:trect;
begin
    try
        Config:=GetIDEConfigStorage(self.Name+_c_settings_EXT_,true);
        try
            // --- галочка
            Config.GetValue(_c_settings_NAME_StayOnTOP_,CheckBox1.Checked);
            // --- размер
            Config.GetValue('',r,self.BoundsRect);
            self.BoundsRect:=r;
            // мож тут проверку какйю ???
            // if screen.DesktopRect.Left:=;
        finally
          Config.Free;
        end;
    except end;
end;

end.

