// demo illustrating how to use python for delphi
// from plain fpc, without lazarus or anything.

{$mode delphi}
program simplefpcdemo;
uses PythonEngine, dynlibs;

var eng : TPythonEngine; path : string;
begin
  eng := TPythonEngine.Create(Nil);
  eng.loaddll;
  if eng.ishandlevalid then
    begin
      writeln(' evens: ', eng.EvalStringAsStr('[x*2 for x in range(10)]'));
      eng.ExecString('print "powers:", [x**2 for x in range(10)]');
    end
  else writeln('invalid library handle!', GetLoadErrorStr);
end.
{ --- output -----

    evens: [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
   powers: [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

  ---------------- }
