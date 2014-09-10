{$mode delphiunicode}
unit upykvm;
interface uses
  xpc, classes, sysutils,
  PythonEngine,
  kvm, cw;

  procedure initkvm; cdecl;
  procedure PyInit_kvm; cdecl;

implementation

var
  gEng : TPythonEngine;
  gMod : TPythonModule;


function PyClrScr( self, args : PPyObject ) : PPyObject; cdecl;
  begin kvm.ClrScr; result := gEng.Py_None;
  end;

function PyClrEol( self, args : PPyObject ) : PPyObject; cdecl;
  begin kvm.ClrEol; result := gEng.Py_None;
  end;

function PyNewLine( self, args : PPyObject ) : PPyObject; cdecl;
  begin kvm.NewLine; result := gEng.Py_None;
  end;

function PyEmit( self, args : PPyObject ) : PPyObject; cdecl;
  var a:PAnsiChar;
  begin with gEng do
    begin
      if PyArg_ParseTuple(args, 's:emit', @a) <> 0 then kvm.emit(a);
      result := Py_None;
    end;
  end;

function PyCWrite( self, args : PPyObject ) : PPyObject; cdecl;
  var a:PAnsiChar;
  begin
    with gEng do begin
      // TODO: if PyTuple_Size(args) <> 1 then throw python Exception
      if PyArg_ParseTuple(args, 's:cwrite', @a) <> 0 then cw.cwrite(a);
      result := Py_None;
    end;
  end;

function PyGotoXY( self, args : PPyObject ) : PPyObject; cdecl;
  var x, y: integer;
  begin
    with gEng do begin
      // TODO: if PyTuple_Size(args) <> 1 then throw python Exception
      if PyArg_ParseTuple(args, 'ii:gotoXY', @x,@y) <> 0 then
	kvm.GotoXY(x,y);
      result := Py_None;
    end;
  end;

function PyPushSub( self, args : PPyObject ) : PPyObject; cdecl;
  var x,y,w,h:integer;
  begin with gEng do
    begin
      if PyArg_ParseTuple(args, 'iiii:pushSub', @x,@y,@w,@h) <> 0 then
	kvm.PushSub(x,y,w,h);
      result := Py_None;
    end;
  end;

function PyPopTerm( self, args : PPyObject ) : PPyObject; cdecl;
  begin
    with gEng do begin
      kvm.PopTerm; result := Py_None;
    end;
  end;

function PyFg( self, args : PPyObject ) : PPyObject; cdecl;
  var i:integer; //a:PAnsiChar;
  begin with gEng do
    begin
      //if PyArg_ParseTuple(args, 's:Fg', @a) <> 0 then kvm.fg(a[1]) else
      if PyArg_ParseTuple(args, 'i:Fg', @i) <> 0 then kvm.fg(i);
      result := Py_None;
    end;
  end;

function PyBg( self, args : PPyObject ) : PPyObject; cdecl;
  var i:integer; //a:PAnsiChar;
  begin with gEng do
    begin
      //if PyArg_ParseTuple(args, 's:Bg', @a) <> 0 then kvm.fg(a[1]) else
      if PyArg_ParseTuple(args, 'i:Bg', @i) <> 0 then kvm.Bg(i);
      result := Py_None;
    end;
  end;


procedure initkvm; cdecl;
  begin
    try gEng := GetPythonEngine
    except
      on Exception do begin
	gEng := TPythonEngine.Create(Nil);
	gEng.AutoFinalize := false;
	gEng.Initialize;
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

    gMod.DocString.text := 'Python KVM module';
    gMod.Initialize;

  end;

{-- python 3.x version --}
procedure PyInit_kvm; cdecl;
  begin initkvm
  end;

initialization
finalization
  gEng.free;
  gMod.free;
end.
