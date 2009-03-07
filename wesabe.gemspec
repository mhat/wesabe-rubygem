Gem::Specification.new do |s|
  s.name = %q{wesabe-mhat}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Knopp", "Brian Donovan"]
  s.date = %q{2009-03-06}
  s.description = %q{mhat's fork of Wesabe-Rubygems}
  s.email = ["matt.knopp@gmail.com", "brian@wesabe.com"]
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.files = ["LICENSE", "README.markdown", "Rakefile", "bin/console", "lib/cacert.pem", "lib/wesabe", "lib/wesabe/account.rb", "lib/wesabe/base_model.rb", "lib/wesabe/credential.rb", "lib/wesabe/currency.rb", "lib/wesabe/financial_institution.rb", "lib/wesabe/job.rb", "lib/wesabe/request.rb", "lib/wesabe/target.rb", "lib/wesabe/upload.rb", "lib/wesabe/util.rb", "lib/wesabe.rb"]
  s.has_rdoc = true
  s.homepage = %q{https://www.wesabe.com/page/api}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wesabe}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Wraps communication with the Wesabe API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.6"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.6"])
  end
end
