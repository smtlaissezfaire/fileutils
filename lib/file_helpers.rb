require "facets/file/rewrite"
require "stringio"
require 'fileutils'

class FileHelpers
  class << self
    def remove_carriage_returns(start_dir = Dir.getwd)
      new(start_dir).remove_carriage_returns
    end

    def remove_hard_tabs(start_dir = Dir.getwd)
      new(start_dir).remove_hard_tabs
    end

    def clean_whitespace(start_dir = Dir.getwd)
      new(start_dir).clean_whitespace
    end

    def rename_files(old_name, new_name, dry_run = false)
      files = Dir.glob("**/**")

      files.each do |file|
        file = File.expand_path(file)

        old_name_regex = Regexp.new(old_name)

        if file =~ old_name_regex
          new_filename = file.gsub(old_name_regex) { new_name }
          puts "* Replacing old file:\n  #{file} =>\n  #{new_filename}"

          unless dry_run
            FileUtils.mv(file, new_filename)
          end

          return rename_files(old_name, new_name, dry_run)
        end
      end
    end
  end

  def initialize(start_dir = Dir.getwd)
    @start_dir = start_dir
  end

  def remove_carriage_returns
    remove_all(/\r/, "") do |file|
      puts "Removing carriage returns from #{file}"
    end
  end

  def remove_hard_tabs
    remove_all(/\t/, "  ") do |file|
      puts "Removing hard tabs from #{file}"
    end
  end

  def clean_whitespace
    files = Dir.glob("#{@start_dir}/**/*")

    files.each do |file|
      if File.file?(file)

        contents = File.read(file)

        File.open(file, "w") do |f|
          new_str = ""

          StringIO.new(contents).readlines.each do |line|
            new_str << line.rstrip + "\n"
          end

          f << new_str
        end
      end
    end
  end

private

  def remove_all(search, replace)
    files = Dir.glob("#{@start_dir}/**/*")

    files.each do |file|
      if File.file?(file)

        yield(file)

        File.rewrite(file) do |contents|
          str = contents.dup
          str.gsub!(search, replace)
          str
        end
      end
    end
  end
end
