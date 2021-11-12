#!/usr/local/opt/ruby/bin/ruby
#
require 'fileutils'

def parse_args
    # Default vals
    copy = false
    prefix = "copy"

    # Check for flags
    args = ARGV
    args.each_with_index do |cur_arg, index|
        if cur_arg == "-c"
            copy = true
        elsif cur_arg.start_with? "--prefix="
            temp = cur_arg.dup
            temp.slice! "--prefix="
            prefix = temp
        else
            args = args[index..-1]
            break
        end
    end

    # Gets files and dst location
    src_files = args[0..-2]
    dst_loc = args[-1]

    return copy, prefix, src_files, dst_loc
end

def get_new_fname (base_fname, prefix, count)
    split_file = base_fname.split(".")
    split_file.insert(-2, "#{prefix}-#{count}")
    split_file.join(".")
end

copy, prefix, src_files, dst_loc = parse_args()

# If file exists in dst location, try making a new name and try again
# This should keep the extension
for file in src_files
    src_fname = file
    dst_fname = File.basename(file)
    base_fname = File.basename(file)
    count = 0

    while true
        full_fname = File.join(dst_loc, dst_fname)

        if File.exist? full_fname
            # Get new file name
            dst_fname = get_new_fname(base_fname, prefix, count)
            count += 1
        else
            if copy
                FileUtils.cp(src_fname, full_fname)
                puts "Copying file to #{full_fname}"
            else
                File.rename(src_fname, full_fname)
                puts "Moving file to #{full_fname}"
            end
            break
        end

        if count == 1000
            puts "Reached limit 1000, failed to move #{base_fname}"
            break
        end
    end
end
