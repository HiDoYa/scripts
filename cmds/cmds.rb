#!/usr/bin/env ruby

require 'bundler/setup'
require 'slop'

class String
  def green
    "\e[32m#{self}\e[0m"
  end
  def light_green; "\e[92m#{self}\e[0m" end
  def bold
    "\e[1m#{self}\e[0m"
  end
end

opts = Slop.parse do |o|
  o.string "-f", "--filepath", "dotfile path", required: true
  o.string "-m", "--mode", "mode: NONINFO, INFO", default: "NONINFO"
end

lines = File.readlines(opts[:filepath], chomp: true)
info_only = opts[:mode] == "INFO"

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
  if not info_only
    if comment && (comment.start_with? "TITLE: ")
      puts ""
      puts "%s" % [comment.delete_prefix("TITLE: ").center(55, '-').green.bold]
      next
    end
  end

  if command
    comment = prev_line[/#\s*(.*)/, 1]
    if comment
      if info_only
        if comment.start_with? "INFO"
          comment = comment.delete_prefix("INFO: ")
          puts "%-30s %s" % [command.light_green, comment]
        end
      else
        if !(comment.start_with? "HIDE")
          puts "%-30s %s" % [command.light_green, comment]
        end
      end
    end
  end

  prev_line = line
end
