# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "jquery-cookie-rails"
  s.version = "1.3.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Scott Lewis"]
  s.date = "2013-09-24"
  s.description = "This gem provides jquery-cookie assets for your Rails 3 application."
  s.email = "ryan@rynet.us"
  s.homepage = "http://github.com/RyanScottLewis/jquery-cookie-rails"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Use jquery-cookie with Rails 3"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, ["< 5.0", ">= 3.2.0"])
      s.add_development_dependency(%q<rails>, ["~> 3.2"])
      s.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_development_dependency(%q<uglifier>, ["~> 1.3"])
      s.add_development_dependency(%q<sass>, ["~> 3.2"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<fancy_logger>, ["~> 0.1"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.13"])
      s.add_development_dependency(%q<fuubar>, ["~> 1.1"])
    else
      s.add_dependency(%q<railties>, ["< 5.0", ">= 3.2.0"])
      s.add_dependency(%q<rails>, ["~> 3.2"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_dependency(%q<uglifier>, ["~> 1.3"])
      s.add_dependency(%q<sass>, ["~> 3.2"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<fancy_logger>, ["~> 0.1"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.13"])
      s.add_dependency(%q<fuubar>, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<railties>, ["< 5.0", ">= 3.2.0"])
    s.add_dependency(%q<rails>, ["~> 3.2"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3"])
    s.add_dependency(%q<uglifier>, ["~> 1.3"])
    s.add_dependency(%q<sass>, ["~> 3.2"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<fancy_logger>, ["~> 0.1"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.13"])
    s.add_dependency(%q<fuubar>, ["~> 1.1"])
  end
end
