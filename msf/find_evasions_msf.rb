
# grep -r -l register_evasion_options *
f = 'lib/msf/core/exploit/dcerpc.rb
lib/msf/core/exploit/http/client.rb
lib/msf/core/exploit/http/server.rb
lib/msf/core/exploit/smb.rb
lib/msf/core/exploit/sunrpc.rb
lib/msf/core/exploit/tcp.rb
lib/msf/core/module.rb'

files = f.split('\n')

files.each do |file|
	begin
		File.foreach(file) do |line|
			puts file
			looking = false
			done = false
			break if done
			looking = true if line =~ /register_evasion_options/
			if looking
				puts line if line = /^[\s]*Opt/
			end
			done = true if looking and line =~ /^[\s]*\]/
		end
	rescue Exception
		puts "couldn't open #{file}"
	end
end