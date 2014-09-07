CORE=PythonForDelphi/Components/Sources/Core
rm *.o *.so *.ppu
fpc -Mdelphi -fPIC -gl -B -dPYTHON27 -Fu$CORE -Fi$CORE _pykvm.pas \
&& mv lib_pykvm.so kvm.so \
&& python -ic 'import kvm; kvm.cwrite("|_|Bhello|g, |Bworld|g!|w|_|_")'

