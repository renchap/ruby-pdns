%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define release %{rpm_release}%{?dist}

Summary: Ruby PDNS Pipe Backend Framework
Name: ruby-pdns
Version: %{version}
Release: %{release}
Group: System Tools
License: GPL
URL: http://www.devco.net/
Source0: %{name}-%{version}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: ruby ruby-net-geoip pdns GeoIP GeoIP-data
BuildArch: noarch
Packager: R.I.Pienaar <rip@devco.net>

%description
A framework for hosting PDNS pipe backends, allows for simple locks of code to run
without having to worry about the details of integrating into PDNS etc.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
%{__install} -d -m0755  %{buildroot}/%{ruby_sitelib}/pdns
%{__install} -d -m0755  %{buildroot}/etc/pdns/records
%{__install} -d -m0755  %{buildroot}/usr/sbin
%{__install} -d -m0755  %{buildroot}/var/log/pdns
%{__install} -m0755 pdns-pipe-runner.rb %{buildroot}/usr/sbin/pdns-pipe-runner.rb
cp -R pdns.rb %{buildroot}/%{ruby_sitelib}/
cp -R pdns/* %{buildroot}/%{ruby_sitelib}/pdns/
cp etc/pdns-ruby-backend-dist.cfg %{buildroot}/etc/pdns/pdns-ruby-backend.cfg
cp -R records/* %{buildroot}/etc/pdns/records

%clean
rm -rf %{buildroot}

%files
%{ruby_sitelib}/pdns.rb
%{ruby_sitelib}/pdns
%config(noreplace) /etc/pdns/pdns-ruby-backend.cfg
%config /etc/pdns/records
/usr/sbin/pdns-pipe-runner.rb
%defattr(0755,pdns,pdns,0755)
/var/log/pdns

%changelog
* Thu Aug 02 2009 R.I.Pienaar <rip@devco.net> - 0.1
- First release