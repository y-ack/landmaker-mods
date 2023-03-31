#!/usr/bin/ruby
# niconii is cute
def usage
  $stderr.puts "usage: deinterleave [-w width] -i infile -o outfile1 outfile2 ..."
  exit 1
end

state = "-i"
args = {}
ARGV.each do |arg|
  case arg
  when "-i", "-o", "-w"
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
w = args["-w"] ? Integer(args["-w"][0]) : 1

fd_in = File.open(infiles[0], "rb")
bufs_out = outfiles.map{|filename| Array.new(infiles[0].size() / outfiles.length())}


fd_in.each_byte.each_with_index do |x, i|
	bufs_out[(i / w) % outfiles.length()][w * (i / outfiles.length() / w) + (i % w)] = x
end

fds_out = outfiles.map{|filename| File.open(filename, "wb")}

fds_out.each_with_index do |f, i|
	f.write(bufs_out[i].pack('C*'))
	f.close()
end
fd_in.close()
