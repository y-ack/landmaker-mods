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
fds_out = outfiles.map{|filename| File.open(filename, "wb")}

fd_in.each_byte.each_with_index do |x, i|
	fds_out[i % outfiles.length()].write(x.chr)
end

fd_in.close()
fds_out.each {|f| f.close()}
