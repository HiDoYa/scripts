#!/usr/bin/ruby

class String
  def green; "\e[32m#{self}\e[0m" end
end

lines = Array.new
for file in ARGV
  currentfile = File.open(file)
  lines += currentfile.readlines.map(&:chomp)
  currentfile.close
end

prevline = ''
for line in lines
  command = ''
  comment = ''
  
  if line.start_with? "alias"
    /^alias\s*(.*?)=.*$/ =~ line
    command = $1

    /#\s*(.*)/ =~ prevline
    comment = $1
  end

  if line.start_with? "function"
    /^function\s*([a-zA-Z0-9_-]*)\(?\)?.*\{?.*/ =~ line
    command = $1

    /#\s*(.*)/ =~ prevline
    comment = $1
  end

  if (command.length > 0) && !(comment.start_with? "HIDE")
    puts "%-25s %s" % [command.green, comment]
  end

  prevline = line
end

