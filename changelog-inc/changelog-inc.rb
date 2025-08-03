#!/usr/bin/env ruby

# Installation:
#   Copy to /usr/local/bin, chmod +x, and remove the .rb suffix

require 'date'

def detect_and_format_date(date_str)
  formats = {
    /^\d{4}-\d{2}-\d{2}$/ => "%Y-%m-%d", # 2024-11-06
    /^\d{2}-\d{2}-\d{4}$/ => "%d-%m-%Y", # 06-11-2024
    /^\d{2}\/\d{2}\/\d{4}$/ => "%d/%m/%Y", # 06/11/2024
    /^\d{4}\/\d{2}\/\d{2}$/ => "%Y/%m/%d", # 2024/11/06
  }
  format = formats.find { |regex, _| date_str.match?(regex) }
  if format
    detected_format = format[1]
    current_date = Date.today.strftime(detected_format)
    return current_date
  end

  raise "Date format not recognized #{date_str}"
end

if ARGV.length != 1
  puts "Usage: changelog-inc 1.0.3"
  exit
end

if not File.file?("CHANGELOG.md")
  puts "CHANGELOG.md not found in current directory"
  exit
end

version = ARGV[0]
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

new_record = [
  "## [#{prefix}#{version}] - #{current_date}\n",
  "### Added\n",
  "### Changed\n",
  "### Removed\n\n",
]

index = changelog.find_index(latest_entry)
changelog.insert(index, new_record)

f = File.new("CHANGELOG.md", "w")
f.write(changelog.join())
f.close
