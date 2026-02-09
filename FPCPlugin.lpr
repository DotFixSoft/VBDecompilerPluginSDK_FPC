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

library FPCPlugin;

{$MODE DELPHI} { compatibility with Delphi }
{$H+}          { for AnsiString }

uses
  Interfaces,
  Forms,
  SysUtils,
  Classes,
  Windows,
  Main in 'Main.pas' {frmMain};

const
  { vlType Constants }
  GetVBProject = 1;
  SetVBProject = 2;
  GetFileName = 3;              // (v3.5+)
  IsNativeCompilation = 4;      // (v3.5+)
  ClearAllBuffers = 5;          // Required if your plugin decompiles a new language and needs to clear all structures (v3.9+)
  GetCompiler = 6;              // 1 - VB, 2 - .NET, 3 - Delphi, 4 - Unknown (v3.9+)
  IsPacked = 7;                 // 1 - Packed, 0 - Not packed (v3.9+)
  SetStackCheckBoxValue = 8;    // 0 - Unchecked, 1 - Checked (v3.9+)
  SetAnalyzerCheckBoxValue = 9; // 0 - Unchecked, 1 - Checked (v3.9+)
  GetVBFormName = 10;
  SetVBFormName = 11;
  GetVBForm = 12;
  SetVBForm = 13;
  GetVBFormCount = 14;
  GetSubMain = 20;
  SetSubMain = 21;
  GetModuleName = 30;
  SetModuleName = 31;
  GetModule = 32;
  SetModule = 33;
  GetModuleStringReferences = 34;
  SetModuleStringReferences = 35;
  GetModuleCount = 36;
  GetModuleFunctionName = 40;
  SetModuleFunctionName = 41;
  GetModuleFunctionAddress = 42;
  SetModuleFunctionAddress = 43;
  GetModuleFunction = 44;
  SetModuleFunction = 45;
  GetModuleFunctionStrRef = 46;
  SetModuleFunctionStrRef = 47;
  GetModuleFunctionCount = 48;
  GetActiveText = 50;
  SetActiveText = 51;
  GetActiveDisasmText = 52;       // (v9.4+)
  SetActiveDisasmText = 53;       // (v9.4+)
  SetActiveTextLine = 54;
  GetActiveModuleCoordinats = 55; // (v3.5+)
  GetVBDecompilerPath = 56;       // (v3.5+)
  GetModuleFunctionCode = 57;     // In "fast decompilation" mode (v3.5+)
  SetStatusBarText = 58;          // (v3.5+)
  GetFrxIconCount = 60;           // (v5.0+)
  GetFrxIconOffset = 61;          // (v5.0+)
  GetFrxIconSize = 62;            // (v5.0+)
  GetModuleFunctionDisasm = 70;   // (v9.4+)
  SetModuleFunctionDisasm = 71;   // (v9.4+) 
  UpdateAll = 100;
type
  TVBDPluginEngine = function(vlType: Integer; vlNumber: Integer; vlFnNumber: Integer; vlNewValue: Pointer): Pointer; stdcall;
  
var
  PluginEngine: TVBDPluginEngine = nil;

{
 Retrieves a value from the VB Decompiler internal structure.
 vlType     - Type of value to retrieve (e.g., FormName, SubMain, etc.)
 vlNumber   - Form or module index (0 if not applicable)
 vlFnNumber - Function index (specifically for vlType 40-47 and 57)
}
function GetValue(vlType: Integer; vlNumber: Integer = 0; vlFnNumber: Integer = 0): String;
var
  Res: Pointer;
  WRes: PWideChar;
begin
  if Assigned(PluginEngine) then begin
    Res := PluginEngine(vlType, vlNumber, vlFnNumber, nil);
    if Res <> nil then begin
      WRes := PWideChar(Res);
      Result := String(WideString(WRes)); 
    end else begin
      Result := '';
    end;
  end else begin
    Result := '';
  end;
end;

{
 Sets a value in the VB Decompiler internal structure.
 vlType     - Type of value to set (e.g., FormName, SubMain, etc.)
 vlNewValue - The new value to assign
 vlNumber   - Form or module index (0 if not applicable)
 vlFnNumber - Function index (specifically for vlType 40-47)
}
procedure SetValue(vlType: Integer; vlNewValue: String; vlNumber: Integer = 0; vlFnNumber: Integer = 0);
var
  // Ensure we use an AnsiString variable so the memory remains valid during the call
  AnsiTemp: AnsiString;
begin
  if Assigned(PluginEngine) then
  begin
    // Convert Unicode to ANSI
    AnsiTemp := AnsiString(vlNewValue);
    // Pass the pointer to the ANSI data.
    PluginEngine(vlType, vlNumber, vlFnNumber, PAnsiChar(AnsiTemp));
  end;
end;

{
 VBDecompilerPluginName function (called during VB Decompiler startup).
 VBDecompilerHWND - Handle to the main VB Decompiler window
 RichTextBoxHWND  - Handle to the code editor (RichEdit) window
 Buffer           - 100-byte buffer. Copy your plugin name here.
 Void             - Reserved parameter
}
procedure VBDecompilerPluginName(VBDecompilerHWND: Integer; RichTextBoxHWND: Integer; Buffer: PAnsiChar; Void: Integer); stdcall;
var
  S: AnsiString;
begin
  S := 'Test plugin written in Free Pascal'#0;
  Move(S[1], Buffer^, Length(S));
end;

{
 VBDecompilerPluginLoad function (Main Entry Point).
 VBDecompilerHWND - Handle to the main VB Decompiler window
 RichTextBoxHWND  - Handle to the code editor (RichEdit) window
 Buffer           - Reserved buffer
 E                - Pointer to the VB Decompiler Callback Engine
}
procedure VBDecompilerPluginLoad(VBDecompilerHWND: DWORD; RichTextBoxHWND: DWORD; Buffer: Pointer; E: Pointer); stdcall;
var
 strData: String;
begin
  PluginEngine := TVBDPluginEngine(E);
  if Assigned(PluginEngine) then begin
    // Get contents of VB project file
    strData := GetValue(GetVBProject);
    // Change some data in VB project file
    strData := strData + #13#10 + 'This text was added by the FPC plugin';
    // Set contents of VB project file
    SetValue(SetVBProject, strData);
    //Update all changed info
    SetValue(UpdateAll, '');
    // Get text from active window of VB Decompiler
    strData := GetValue(GetActiveText, 0, 0);
    //Load form
    if not Assigned(frmMain) then
      Application.CreateForm(TfrmMain, frmMain);
      
    frmMain.txtVbProject.Text := strData;
    frmMain.ShowModal;

    frmMain.Free;
    frmMain := nil;
  end;
end;

{
 VBDecompilerPluginAuthor function (used to identify the plugin author).
 VBDecompilerHWND - Handle to the main VB Decompiler window
 RichTextBoxHWND  - Handle to the code editor (RichEdit) window
 Buffer           - 100-byte buffer. Copy your name and email here.
 Void             - Reserved parameter
}
procedure VBDecompilerPluginAuthor(VBDecompilerHWND: Integer; RichTextBoxHWND: Integer; Buffer: PAnsiChar; Void: Integer); stdcall;
var
  S: AnsiString;
begin
  S := 'YourName, yourmail@somedomain.com'#0;
  Move(S[1], Buffer^, Length(S));
end;

Exports
  VBDecompilerPluginName,
  VBDecompilerPluginLoad,
  VBDecompilerPluginAuthor;

begin
  Application.Initialize;
end.

