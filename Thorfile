require 'rubygems'
require 'rubygems/specification'
require 'thor/tasks'

GEM = "wesabe-mhat"
GEM_VERSION = "0.0.2"
AUTHOR = "Brian Donovan"
EMAIL = "brian@wesabe.com"
HOMEPAGE = "https://www.wesabe.com/page/api"
SUMMARY = "Wraps communication with the Wesabe API"
PROJECT = "wesabe"

SPEC = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.rubyforge_project = PROJECT
  s.add_dependency("hpricot", ">= 0.6")
    
  s.require_path = 'lib'
  # s.bindir = "bin"
  # s.executables = %w( wesabe )
  s.files = %w(LICENSE README.markdown Rakefile) + Dir.glob("{bin,lib,specs}/**/*")
end

class Default < Thor
  # Set up standard Thortasks
  spec_task(Dir["spec/**/*_spec.rb"])
  install_task SPEC

  # Spec task for CI
  spec_task(Dir["spec/**/*_spec.rb"], :name => "cruise", :verbose => "true", :color => false)
  
  desc "make_spec", "make a gemspec file"
  def make_spec
    File.open("#{GEM}.gemspec", "w") do |file|
      file.puts SPEC.to_ruby
    end
  end
  
  desc "doc", "Generates the documentation for this project"
  method_options :open => :boolean
  def doc(options={})
    `yardoc 'lib/**/*.rb' 2>/dev/null`
    `open doc/index.html 2>/dev/null` if options[:open]
  end
  
  desc "release", "Performs all the steps necessary for a release"
  def release
    doc; spec; package
  end
end

class Wesabe < Thor
  desc "update_pem", "Downloads and installs an updated PEM file (requires openssl)"
  def update_pem
    require 'fileutils'
    
    # get the certificate
    certs = `echo QUIT | openssl s_client -showcerts -connect www.wesabe.com:443 2>/dev/null`
    pem = certs[/-----BEGIN CERTIFICATE-----(?:.|\n)+?-----END CERTIFICATE-----/, 0]
    
    # write it to our pem file
    dir  = File.expand_path("~/.wesabe")
    path = File.join(dir, "cacert.pem")
    FileUtils.mkdir_p(dir)
    File.open(path, 'w') do |file|
      file.puts pem
    end
    puts "Wrote PEM file to #{path}"
  end
end
