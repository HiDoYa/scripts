#!/usr/bin/ruby

# Installation:
#   Copy to /usr/local/bin, chmod +x, and remove the .rb suffix
#   sudo cp changelog-inc.rb /usr/local/bin/changelog-inc

require 'date'

def detect_and_format_date(date_str)
  formats = {
    /^\d{4}-\d{2}-\d{2}$/ => "%Y-%m-%d",   # 2024-11-28
    /^\d{4}\/\d{2}\/\d{2}$/ => "%Y/%m/%d", # 2024/11/28
    /^\d{2}-\d{2}-\d{4}$/ => "%m-%d-%Y",   # 11-28-2024
    /^\d{2}\/\d{2}\/\d{4}$/ => "%m/%d/%Y", # 11/28/2024
    /^\d{2}-\d{2}-\d{4}$/ => "%d-%m-%Y",   # 28-11-2024
    /^\d{2}\/\d{2}\/\d{4}$/ => "%d/%m/%Y", # 28/11/2024
  }
  format = formats.find { |regex, _| date_str.match?(regex) }
  if format
    detected_format = format[1]
    current_date = Date.today.strftime(detected_format)
    return current_date
  end

  raise "Date format not recognized #{date_str}"
end

if (ARGV.length != 1) and (ARGV.length != 2)
  puts "Usage: changelog-inc 1.0.3"
  puts "Usage: changelog-inc 1.0.3 \"Some change\""
  exit 1
end

if not File.file?("CHANGELOG.md")
  puts "CHANGELOG.md not found in current directory"
  exit 1
end

version = ARGV[0]
version.delete("v")
quick_change_comment = ARGV.length == 2 ? ARGV[1].strip : nil
changelog = File.readlines("CHANGELOG.md")

def find_version_prefix(changelog, latest_entry)
  latest_version = /.*\[(.*)\].*/.match(latest_entry)[1]
  puts "Last version: #{latest_version}"
  latest_version.include?("v") ? "v" : ""
end


latest_entry = changelog.find { |line| line.include? "##" }
date = latest_entry.split("-", 2).map(&:strip)[1]
current_date = detect_and_format_date(date)
prefix = find_version_prefix(changelog, latest_entry)

if quick_change_comment != nil
  new_record = [
    "## [#{prefix}#{version}] - #{current_date}\n",
    "### Changed\n",
    "- #{quick_change_comment}\n\n",
  ]
else
  new_record = [
    "## [#{prefix}#{version}] - #{current_date}\n",
    "### Added\n",
    "### Changed\n\n",
  ]
end

index = changelog.find_index(latest_entry)
changelog.insert(index, new_record)

f = File.new("CHANGELOG.md", "w")
f.write(changelog.join())
f.close
