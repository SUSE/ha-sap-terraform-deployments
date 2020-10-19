#
# spec file for package blue-horizon
# this code base is under development
#
# Copyright (c) 2020 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugzilla.suse.com/
#

Name:      blue-horizon
Version:   1.3.0
Release:   0
License:   GPL-3.0
Summary:   Web server interface for terraforming in a public cloud
URL:       http://www.github.com/suse-enceladus/blue-horizon
Source0:   %{name}-%{version}.tar.bz2
# requirements generated via `rake gems:rpmspec:requires`
BuildRequires:  ruby-macros >= 5
BuildRequires: %{rubygem bundler}
BuildRequires:  %{ruby}
BuildRequires:  %{rubygem actioncable}
BuildRequires:  %{rubygem actionmailer}
BuildRequires:  %{rubygem actionpack}
BuildRequires:  %{rubygem actionview}
BuildRequires:  %{rubygem active_link_to}
BuildRequires:  %{rubygem activejob}
BuildRequires:  %{rubygem activemodel}
BuildRequires:  %{rubygem activerecord}
BuildRequires:  %{rubygem activesupport}
BuildRequires:  %{rubygem addressable}
BuildRequires:  %{rubygem arel}
BuildRequires:  %{rubygem builder}
BuildRequires:  %{rubygem cloud-instancetype:1.1}
BuildRequires:  %{rubygem concurrent-ruby}
BuildRequires:  %{rubygem crass}
BuildRequires:  %{rubygem erubi}
BuildRequires:  %{rubygem erubis}
BuildRequires:  %{rubygem globalid}
BuildRequires:  %{rubygem haml}
BuildRequires:  %{rubygem haml-rails}
BuildRequires:  %{rubygem hamster}
BuildRequires:  %{rubygem html2haml}
BuildRequires:  %{rubygem i18n}
BuildRequires:  %{rubygem jbuilder}
BuildRequires:  %{rubygem lino}
BuildRequires:  %{rubygem loofah}
BuildRequires:  %{rubygem mail}
BuildRequires:  %{rubygem method_source}
BuildRequires:  %{rubygem mini_mime}
BuildRequires:  %{rubygem mini_portile2}
BuildRequires:  %{rubygem minitest}
BuildRequires:  %{rubygem nio4r}
BuildRequires:  %{rubygem nokogiri}
BuildRequires:  %{rubygem open4}
BuildRequires:  %{rubygem public_suffix:4.0}
BuildRequires:  %{rubygem puma}
BuildRequires:  %{rubygem rack}
BuildRequires:  %{rubygem rack-test}
BuildRequires:  %{rubygem rails:5.1}
BuildRequires:  %{rubygem rails-dom-testing}
BuildRequires:  %{rubygem rails-html-sanitizer}
BuildRequires:  %{rubygem railties}
BuildRequires:  %{rubygem rake}
BuildRequires:  %{rubygem redcarpet}
BuildRequires:  %{rubygem ruby-terraform}
BuildRequires:  %{rubygem ruby_parser}
BuildRequires:  %{rubygem rubyzip}
BuildRequires:  %{rubygem sexp_processor}
BuildRequires:  %{rubygem sprockets}
BuildRequires:  %{rubygem sprockets-rails}
BuildRequires:  %{rubygem sqlite3}
BuildRequires:  %{rubygem temple}
BuildRequires:  %{rubygem thor}
BuildRequires:  %{rubygem thread_safe}
BuildRequires:  %{rubygem tilt}
BuildRequires:  %{rubygem tzinfo}
BuildRequires:  %{rubygem websocket-driver}
BuildRequires:  %{rubygem websocket-extensions}
Requires:  %{ruby}
Requires: %{rubygem bundler}
Requires:  %{rubygem actioncable}
Requires:  %{rubygem actionmailer}
Requires:  %{rubygem actionpack}
Requires:  %{rubygem actionview}
Requires:  %{rubygem active_link_to}
Requires:  %{rubygem activejob}
Requires:  %{rubygem activemodel}
Requires:  %{rubygem activerecord}
Requires:  %{rubygem activesupport}
Requires:  %{rubygem addressable}
Requires:  %{rubygem arel}
Requires:  %{rubygem builder}
Requires:  %{rubygem cloud-instancetype:1.1}
Requires:  %{rubygem concurrent-ruby}
Requires:  %{rubygem crass}
Requires:  %{rubygem erubi}
Requires:  %{rubygem erubis}
Requires:  %{rubygem globalid}
Requires:  %{rubygem haml}
Requires:  %{rubygem haml-rails}
Requires:  %{rubygem hamster}
Requires:  %{rubygem html2haml}
Requires:  %{rubygem i18n}
Requires:  %{rubygem jbuilder}
Requires:  %{rubygem lino}
Requires:  %{rubygem loofah}
Requires:  %{rubygem mail}
Requires:  %{rubygem method_source}
Requires:  %{rubygem mini_mime}
Requires:  %{rubygem mini_portile2}
Requires:  %{rubygem minitest}
Requires:  %{rubygem nio4r}
Requires:  %{rubygem nokogiri}
Requires:  %{rubygem open4}
Requires:  %{rubygem public_suffix:4.0}
Requires:  %{rubygem puma}
Requires:  %{rubygem rack}
Requires:  %{rubygem rack-test}
Requires:  %{rubygem rails:5.1}
Requires:  %{rubygem rails-dom-testing}
Requires:  %{rubygem rails-html-sanitizer}
Requires:  %{rubygem railties}
Requires:  %{rubygem rake}
Requires:  %{rubygem redcarpet}
Requires:  %{rubygem ruby-terraform}
Requires:  %{rubygem ruby_parser}
Requires:  %{rubygem rubyzip}
Requires:  %{rubygem sexp_processor}
Requires:  %{rubygem sprockets}
Requires:  %{rubygem sprockets-rails}
Requires:  %{rubygem sqlite3}
Requires:  %{rubygem temple}
Requires:  %{rubygem thor}
Requires:  %{rubygem thread_safe}
Requires:  %{rubygem tilt}
Requires:  %{rubygem tzinfo}
Requires:  %{rubygem websocket-driver}
Requires:  %{rubygem websocket-extensions}
# end generated requirements
Requires: terraform = 0.13.4

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch

%description
A customizable web interface for setting variables and executing a predefined
terraform script in a supported cloud service provider (CSP) environment.

%prep
%setup

%build
bundle lock --local

%install
install -m 0755 -d %{buildroot}/srv/www/%{name}
cp -r app bin config db lib public config.ru Gemfile* Rakefile %{buildroot}/srv/www/%{name}/

%files
%defattr(-,root,root,-)
%doc README.md LICENSE
/srv/www/%{name}

%changelog
