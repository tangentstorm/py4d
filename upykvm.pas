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
  begin
    with gEng do begin
      // TODO: if PyTuple_Size(args) <> 0 then throw python Exception
      kvm.ClrScr;
      result := GetPythonEngine.Py_None;
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
    gMod.AddMethod('cwrite', @PyCWrite, 'colorwrite');
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
