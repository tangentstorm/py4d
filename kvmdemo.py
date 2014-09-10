import kvm
kvm.bg(5)
kvm.clrScr()
kvm.pushSub(10,10,30,5)
kvm.bg(233)
kvm.clrScr()
kvm.initKeyboard();
kvm.clrScr()
kvm.cwrite('what is your name?|_')
name=kvm.getLine("> ")
kvm.newLine()
kvm.emit("hello, %s\n" % name)
kvm.cwrite('|r(|R(|Y( |Wpress a key|w! |Y)|R)|r)|w|_')
kvm.readKey()
kvm.newLine()
kvm.cwrite('|r(|R(|Y( |Wscrolling subterm|w! |Y)|R)|r)|w|_')
kvm.doneKeyboard()
kvm.popTerm()
kvm.bg(0)
kvm.gotoXY(0,17)
kvm.emit('goodbye.\n')



