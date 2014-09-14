{$i xpc}{$mode delphiunicode}
unit upykvm;
interface uses
  xpc, classes, sysutils,
  PythonEngine,
  kvm, cw, kbd, lined, keyboard;

  procedure initkvm; cdecl;
  procedure PyInit_kvm; cdecl;

type
  TPythonKvmIO = class(TPythonInputOutput)
    procedure SendData(const data : AnsiString); override;
    procedure SendUniData(const Data : UnicodeString ); override;
    function  ReceiveData : AnsiString; override;
    function  ReceiveUniData : UnicodeString; override;
  end;


implementation

var
  gEng : TPythonEngine;
  gMod : TPythonModule;

function NoneRef: PPyObject; cdecl;
  begin result := gEng.Py_None; gEng.Py_IncRef(result)
  end;
function TrueRef: PPyObject; cdecl;
  begin result := PPyObject(gEng.Py_True); gEng.Py_IncRef(result)
  end;
function FalseRef: PPyObject; cdecl;
  begin result := PPyObject(gEng.Py_False); gEng.Py_IncRef(result)
  end;

function PyClrScr( self, args : PPyObject ) : PPyObject; cdecl;
  begin kvm.ClrScr; result := NoneRef;
  end;

function PyClrEol( self, args : PPyObject ) : PPyObject; cdecl;
  begin kvm.ClrEol; result := NoneRef;
  end;

function PyNewLine( self, args : PPyObject ) : PPyObject; cdecl;
  begin kvm.NewLine; result := NoneRef;
  end;

function PyEmit( self, args : PPyObject ) : PPyObject; cdecl;
  var a:PAnsiChar;
  begin
    if gEng.PyArg_ParseTuple(args, 's:emit', @a) <> 0 then kvm.emit(a);
    result := NoneRef;
  end;

function PyCWrite( self, args : PPyObject ) : PPyObject; cdecl;
  var a:PAnsiChar;
  begin
    with gEng do begin
      // TODO: if PyTuple_Size(args) <> 1 then throw python Exception
      if PyArg_ParseTuple(args, 's:cwrite', @a) <> 0 then cw.cwrite(a);
      result := NoneRef;
    end;
  end;

function PyGotoXY( self, args : PPyObject ) : PPyObject; cdecl;
  var x, y: integer;
  begin
    with gEng do begin
      // TODO: if PyTuple_Size(args) <> 1 then throw python Exception
      if PyArg_ParseTuple(args, 'ii:gotoXY', @x,@y) <> 0 then
	kvm.GotoXY(x,y);
      result := NoneRef;
    end;
  end;

function PyPushSub( self, args : PPyObject ) : PPyObject; cdecl;
  var x,y,w,h:integer;
  begin with gEng do
    begin
      if PyArg_ParseTuple(args, 'iiii:pushSub', @x,@y,@w,@h) <> 0 then
	kvm.PushSub(x,y,w,h);
      result := NoneRef;
    end;
  end;

function PyPopTerm( self, args : PPyObject ) : PPyObject; cdecl;
  begin
    with gEng do begin
      kvm.PopTerm; result := NoneRef;
    end;
  end;

function PyFg( self, args : PPyObject ) : PPyObject; cdecl;
  var i:integer; //a:PAnsiChar;
  begin with gEng do
    begin
      //if PyArg_ParseTuple(args, 's:Fg', @a) <> 0 then kvm.fg(a[1]) else
      if PyArg_ParseTuple(args, 'i:Fg', @i) <> 0 then kvm.fg(i);
      result := NoneRef;
    end;
  end;

function PyBg( self, args : PPyObject ) : PPyObject; cdecl;
  var i:integer; //a:PAnsiChar;
  begin with gEng do
    begin
      //if PyArg_ParseTuple(args, 's:Bg', @a) <> 0 then kvm.fg(a[1]) else
      if PyArg_ParseTuple(args, 'i:Bg', @i) <> 0 then kvm.Bg(i);
      result := NoneRef;
    end;
  end;


function PyInitKeyboard( self, args : PPyObject ) : PPyObject; cdecl;
  begin keyboard.initkeyboard; result := NoneRef;
  end;

function PyDoneKeyboard( self, args : PPyObject ) : PPyObject; cdecl;
  begin keyboard.donekeyboard; result := NoneRef;
  end;

function PyKeyPressed( self, args : PPyObject ) : PPyObject; cdecl;
  begin with gEng do
    if kbd.keypressed then result := TrueRef
    else result := FalseRef;
  end;

function PyReadKey( self, args : PPyObject ) : PPyObject; cdecl;
  var c:char;
  begin with gEng do
    begin
      c := u2a(kbd.readkey)[1]; result := Py_BuildValue('s',@c);
    end
  end;

function PyGetLine( self, args : PPyObject ) : PPyObject; cdecl;
  var pa:PAnsiChar; si:TStr='';
  begin with gEng do
    begin
      if PyArg_ParseTuple(args, 's:getline', @pa) <> 0 then begin
	lined.prompt(TStr(pa), si);
	result := PyString_FromString(PAnsiChar(u2a(si)));
      end;
    end
  end;


procedure TPythonKvmIO.SendData(const data : AnsiString);
  begin write(data);
  end;
procedure TPythonKvmIO.SendUniData(const Data : UnicodeString );
  begin write(data);
  end;
function  TPythonKvmIO.ReceiveData : AnsiString;
  begin readln(result);
  end;
function  TPythonKvmIO.ReceiveUniData : UnicodeString;
  begin readln(result);
  end;

procedure initkvm; cdecl;
  begin
    try gEng := GetPythonEngine
    except
      on Exception do begin
	gEng := TPythonEngine.Create(Nil);
	gEng.AutoFinalize := false;
	gEng.Initialize;
	gEng.IO := TPythonKvmIO.Create(gEng);
      end
    end;

    gMod := TPythonModule.Create(Nil);
    gMod.Engine := gEng;
    gMod.ModuleName := 'kvm';
    gMod.AddMethod('clrScr', @PyClrScr, 'Clear the screen');
    gMod.AddMethod('clrEol', @PyClrEol, 'Clear to end of line');
    gMod.AddMethod('newLine', @PyNewLine, 'Move to next line');
    gMod.AddMethod('emit', @PyEmit, 'Emit a string');
    gMod.AddMethod('cwrite', @PyCWrite, 'colorwrite');
    gMod.AddMethod('gotoXY', @PyGotoXY, 'move cursor to x,y coordinates');
    gMod.AddMethod('pushSub', @PyPushSub, 'push a (x,y,w,h) subterminal');
    gMod.AddMethod('popTerm', @PyPopTerm, 'pop subterminal off stack');
    gMod.AddMethod('fg', @PyFg, 'set foreground');
    gMod.AddMethod('bg', @PyBg, 'set background');
    gMod.AddMethod('keyPressed', @PyKeyPressed, 'is keypressed?');
    gMod.AddMethod('readKey', @PyReadKey, 'get a character from the keyboard');

    gMod.AddMethod('getLine', @PyGetLine, 'read a line of text, interactively');
    gMod.AddMethod('initKeyboard', @PyInitKeyboard, 'initialize keyboard driver');
    gMod.AddMethod('doneKeyboard', @PyDoneKeyboard, 'finalize keyboard driver');

    gMod.DocString.text := 'Python KVM module';
    gMod.Initialize;

  end;

{-- python 3.x version --}
procedure PyInit_kvm; cdecl;
  begin initkvm
  end;

initialization
  keyboard.donekeyboard;
finalization
  gEng.free;
  gMod.free;
end.
