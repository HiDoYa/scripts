#!/usr/bin/env ruby

require 'diffy'

Diffy::Diff.default_format = :color

def dwrite(fname, output)
  puts "Currently processing #{fname}"
  existing = File.read(fname)
  diff = Diffy::Diff.new(existing, output, :context => 3)

  diff_found = true
  if diff.diff == ""
    puts "No diff found for file #{fname}"
    diff_found = false
  else
    puts diff
  end

  if diff_found
    puts "Do you want to replace with new contents (y/n)"
    replace_file = false
    loop do
      user_input = gets.downcase.strip
      if user_input == "y"
        replace_file = true
        break
      elsif user_input == "n"
        break
      else
        puts "Please answer in y/n: "
        continue
      end
    end
  end

  if replace_file
    puts "Writing to file #{fname}"
    File.write(fname, output)
  end
end


fname = "formula.txt"
output = `brew leaves`
dwrite(fname, output)

puts "\n-----\n\n"

fname = "casks.txt"
output = `brew list --cask`
dwrite(fname, output)