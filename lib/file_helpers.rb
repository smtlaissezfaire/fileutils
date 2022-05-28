require "facets/file/rewrite"
require "stringio"
require 'fileutils'
require 'ptools'

class FileHelpers
  class << self
    def remove_carriage_returns
      new.remove_carriage_returns
    end

    def tabs_to_spaces(path, number)
      new(path).tabs_to_spaces(number)
    end

    def clean_whitespace
      new.clean_whitespace
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

  def initialize(start_dir = default_dir)
    @start_dir = start_dir
  end

  def remove_carriage_returns
    remove_all(/\r/, "") do |file|
      puts "Removing carriage returns from #{file}"
    end
  end

  def tabs_to_spaces(spaces = 2)
    remove_all(/\t/, (" " * spaces)) do |file|
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

  def default_dir
    ARGV[0] || Dir.getwd
  end

  def remove_all(search, replace)
    files = if File.directory?(@start_dir)
      Dir.glob("#{@start_dir}/**/*")
    else
      [@start_dir]
    end

    files.each do |file|
      next if !File.file?(file)
      next if File.binary?(file) # TODO: this could be better

      yield(file)

      begin
        File.rewrite(file) do |contents|
          str = contents.dup
          str.gsub!(search, replace)
          str
        end
      rescue => e
        puts "ERROR rewriting file: #{file}"
        puts "\tError: #{e}"
      end
    end
  end
end
