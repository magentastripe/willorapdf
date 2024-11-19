require 'erb'
require 'fileutils'

class Willora
  VERSION = "0.0.0a"
  DEFAULT_TITLE = "My Cool Book"
  DEFAULT_AUTHOR = "Allen Smithee"
  DEFAULT_PUBLISHER = "Made-Up Press"

  attr_reader :errormsg

  def initialize(**opts)
    @opts = opts
    @errormsg = nil
  end

  def main!
    puts "WilloraPDF v#{VERSION}"

    rv = 0

    case @opts[:command]
    when :new
      rv = self.new_project
    else
      @errormsg = "unknown command: #{@opts[:command].inspect}"
      rv = 1
    end

    return rv
  end

  def new_project
    # Make sure the WilloraPDF base files seem OK.
    _willorabase = @opts[:willorabase]
    _projectfiles = File.join(_willorabase, "project-files")
    _templatedir = File.join(_willorabase, "templates")

    #epubassetsdir = File.join(_willorabase, "epub-assets")
    fontsdir = File.join(_willorabase, "fonts")
    libdir = File.join(_projectfiles, "lib")
    mkdir = File.join(_willorabase, "mk")
    scriptdir = File.join(_willorabase, "script")
    themedir = File.join(_willorabase, "themes")

    alldirs = [fontsdir, libdir, mkdir, themedir, scriptdir]

    alldirs.each do |dir|
      if not File.directory?(dir)
        @errormsg = "cannot find required directory, WilloraPDF installation broken? (#{dir})"
        return 1
      end
    end

    if !@opts[:destination]
      @errormsg = "Destination directory is required"
      return 1
    end

    # Fill in some gaps before we continue.
    if !@opts[:nickname]
      @errormsg = "New project requires a nickname"
      return 1
    end

    if @opts[:nickname].split(/\s+/).length > 1
      @errormsg = "Nickname cannot have any spaces"
      return 1
    end

    realdestbase = File.join(@opts[:destination], @opts[:nickname])

    if File.exist?(realdestbase)
      @errormsg = "Directory already exists: #{realdestbase.inspect}"
      return 1
    end

    @opts[:title] = DEFAULT_TITLE if !@opts[:title]
    @opts[:author] = DEFAULT_AUTHOR if !@opts[:author]
    @opts[:publisher] = DEFAULT_PUBLISHER if !@opts[:publisher]

    # Create the new project directory and copy the files over.
    FileUtils.mkdir_p(realdestbase, :verbose => true)

    alldirs << File.join(_willorabase, "Gemfile")

    alldirs.each do |dir|
      basename = File.basename(dir)
      realdest = File.join(realdestbase, basename)
      puts "#{basename} => #{realdest}"
      FileUtils.copy_entry(dir, realdest)
    end

    # Fill it up with some new templatized files.
    templates = {
      "Makefile.erb" => "",

      "acknowledgments.adoc.erb" => "adoc",
      "backmatter.adoc.erb" => "adoc",
      "biography.adoc.erb" => "adoc",
      "CHAP01.adoc.erb" => "adoc",
      "dedication.adoc.erb" => "adoc",
      "frontmatter-template.adoc.erb" => "adoc",
      "part01.adoc.erb" => "adoc",
    }

    templates.each do |template, destname|
      destdir = File.join(realdestbase, destname)
      if not File.directory?(destdir)
        FileUtils.mkdir_p(destdir, :verbose => true)
      end
      templatefile = File.join(_templatedir, template)
      result = ERB.new(File.read(templatefile)).result(binding)

      # This file gets installed *with* the .erb extension.
      if template == "frontmatter-template.adoc.erb"
        newfile = File.join(destdir, template)
      else
        newfile = File.join(destdir, File.basename(template, ".erb"))
      end

      puts "GENERATE #{newfile}"
      File.open(newfile, "w") do |fp|
        fp.puts(result)
      end
    end

    # Leftovers.
    converter_class_orig = File.join(libdir, "willora_pdf_converter.rb")
    converter_class_new = File.join(realdestbase, "lib", "this_pdf_converter.rb")
    puts "#{converter_class_orig} => #{converter_class_new}"
    FileUtils.copy_entry(converter_class_orig, converter_class_new)

    puts "New project #{@opts[:nickname].inspect} is ready: #{realdestbase}"
    return 0
  end
end
