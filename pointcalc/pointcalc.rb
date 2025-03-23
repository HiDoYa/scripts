#!/usr/bin/env ruby

require 'bundler/setup'
require 'date'
require 'slop'
require 'business'
require 'yaml'

opts = Slop.parse do |o|
  o.string "-s", "--start", "start date", required: true
  o.integer "-p", "--points", "points", required: true
  o.float "-m", "--multiplier", "multiplier", default: 2.0
  o.string "-f", "--holiday-file", "holiday file", default: "holidays.yaml"
end

yaml_file = YAML.load_file(opts[:holiday_file])
holidays = yaml_file[:holidays]

calendar = Business::Calendar.new(
  holidays: holidays,
)

points = opts[:points]
multiplier = opts[:multiplier]
points_with_padding = points * multiplier
days = points_with_padding / 2
days_int = days.ceil

start_date = Date.parse(opts[:start])
end_date = calendar.add_business_days(start_date, days_int).strftime("%A, %B %d %Y")
puts end_date
