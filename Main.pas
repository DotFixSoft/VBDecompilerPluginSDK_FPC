{
    VB Decompiler Plugin SDK (Free Pascal Version)
    Copyright (c) 2001-2026 Sergey Chubchenko (DotFix Software). All rights reserved.

    Website: https://www.vb-decompiler.org
    Support: admin@vb-decompiler.org

    Description:
        Main library entry point for Free Pascal (Lazarus).
    
    License:
        Permission is hereby granted to use, modify, and distribute this file 
        for the purpose of creating plugins for VB Decompiler.
}

unit Main;

{$MODE DELPHI}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrmMain = class(TForm)
    txtVbProject: TMemo;
    cmdClose: TButton;
    procedure cmdCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

procedure TfrmMain.cmdCloseClick(Sender: TObject);
begin
  MessageBox(Handle, 'The plugin worked correctly', 'FPC Plugin', MB_OK or MB_ICONINFORMATION);
  Close;
end;

end.
