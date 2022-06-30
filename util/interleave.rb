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
simm_count = fds_in.length()
buf_out = Array.new(fds_in[0].size() * simm_count)

(0...fds_in[0].size()).each do |i|
  fds_in.each_with_index do |f,j|
		buf_out[i*simm_count + j] = f.readbyte()
	end
end

fd_out = File.open(outfiles[0], "wb")
fd_out.write(buf_out.pack('C*'))
fd_out.close()
fds_in.each {|f| f.close()}
