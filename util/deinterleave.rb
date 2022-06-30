#!/usr/bin/ruby
# niconii is cute
def usage
  $stderr.puts "usage: deinterleave -i infile -o outfile1 outfile2 ..."
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



fd_in = File.open(infiles[0], "rb")
bufs_out = outfiles.map{|filename| Array.new(infiles[0].size() / outfiles.length())}

fd_in.each_byte.each_with_index do |x, i|
	bufs_out[i % outfiles.length()][i / outfiles.length()] = x
end

fds_out = outfiles.map{|filename| File.open(filename, "wb")}

fds_out.each_with_index do |f, i|
	f.write(bufs_out[i].pack('C*'))
	f.close()
end
fd_in.close()
