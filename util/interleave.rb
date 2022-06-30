#!/usr/bin/ruby
def usage
  $stderr.puts "usage: interleave -i infile1 infile2 ... -o outfile"
  exit 1
end

state = "-i"
args = {}
ARGV.each do |arg|
  case arg
  when "-i", "-o"
    state = arg
  else
    usage if arg.start_with?("-")
    args[state] ||= []
    args[state] << arg
  end
end

usage unless args.key?("-i") and args.key?("-o")

infiles = args["-i"]
outfiles = args["-o"]


fds_in = infiles.map{|filename| File.open(filename, "rb")}
fd_out = File.open(outfiles[0], "wb")

(0...fds_in[0].size()).each do |i|
  fds_in.each do |f|
		fd_out.write(f.readbyte().chr)
	end
end

fd_out.close()
fds_in.each {|f| f.close()}
