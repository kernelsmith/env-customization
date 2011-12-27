# introspecting your ruby program:

#Print all modules, except classes
puts Module.constants.sort.select {|x| eval(x.to_s).instance_of? Module}

#Print all classes (excluding exceptions)
puts Module.constants.sort.select {|x| c = eval(x.to_s);c.is_a? Class and not c.ancestors.include? Exception}

# just classes
puts Module.constants.sort.select {|x| eval(x.to_s).instance_of? Class}

#Print all exceptions
puts Module.constants.sort.select {|x| c = eval(x.to_s);c.instance_of? Class and c.ancestors.include? Exception}

#reference your current method name
__method__

input = Rex::Ui::Text::Input::Stdio.new
# lib/rex/ui/text/input/buffer.rb

# msf exceptions
ArgumentError
ClassArgumentError
DnsTimeoutArgumentError
EOFError
EncodingError
Exception
ExpandError
FiberError
FloatDomainError
HeaderArgumentError
HeaderDuplicateID
HeaderWrongCount
HeaderWrongOpcode
HeaderWrongRecursive
IOError
IndexError
Interrupt
InvalidLength
InvalidObjectId
InvalidTag
KeyError
LoadError
LocalJumpError
MissingSourceFile
NameError
NoMemoryError
NoMethodError
NoResponseError
NotImplementedError
OutOfData
PacketArgumentError
PacketError
ParseError
QuestionArgumentError
QuestionNameError
RRArgumentError
RRDataError
RangeError
RegexpError
ResolverArgumentError
RuntimeError
ScanError
ScriptError
SecurityError
SignalException
SocketError
StandardError
StopIteration
SyntaxError
SystemCallError
SystemExit
SystemStackError
ThreadError
TimeoutError
TypeArgumentError
TypeError
ZeroDivisionError

