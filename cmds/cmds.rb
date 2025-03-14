#!ruby

class String
  def green
    "\e[32m#{self}\e[0m"
  end
  def light_green; "\e[92m#{self}\e[0m" end
  def bold
    "\e[1m#{self}\e[0m"
  end
end

lines = ARGV.flat_map { |file| File.readlines(file, chomp: true) }

prev_line = ''
lines.each do |line|
  command = nil
  comment = nil
  
  case line
  when /^alias\s*(.*?)=.*$/
    command = Regexp.last_match(1)
  when /^function\s*([a-zA-Z0-9_-]*)\(?\)?.*/
    command = Regexp.last_match(1)
  end

  comment = line[/#\s*(.*)/, 1]
  if comment && (comment.start_with? "TITLE: ")
    puts ""
    puts "%s" % [comment.delete_prefix("TITLE: ").center(55, '-').green.bold]
    next
  end

  if command
    comment = prev_line[/#\s*(.*)/, 1]
    if comment && !(comment.start_with? "HIDE")
      puts "%-30s %s" % [command.light_green, comment]
    end
  end

  prev_line = line
end
