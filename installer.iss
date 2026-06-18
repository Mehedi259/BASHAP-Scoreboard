[Setup]
AppName=BASHAP Scoreboard
AppVersion=1.0.0
AppPublisher=Bashap
DefaultDirName={autopf}\BASHAP Scoreboard
DefaultGroupName=BASHAP Scoreboard
OutputDir=c:\flutterProject\bashap
OutputBaseFilename=BASHAP-Scoreboard-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\bashap.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "c:\flutterProject\bashap\build\windows\x64\runner\Release\bashap.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\flutterProject\bashap\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\flutterProject\bashap\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\BASHAP Scoreboard"; Filename: "{app}\bashap.exe"
Name: "{group}\Uninstall BASHAP Scoreboard"; Filename: "{uninstallexe}"
Name: "{commondesktop}\BASHAP Scoreboard"; Filename: "{app}\bashap.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\bashap.exe"; Description: "Launch BASHAP Scoreboard"; Flags: nowait postinstall skipifsilent
