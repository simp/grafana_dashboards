Summary: Grafana dashboards developed for SIMP
Name: simp-grafana-dashboards
Version: 1.0.0
Release: 0
License: Apache-2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Buildarch: noarch

Prefix: %{_var}/lib/grafana/dashboards

Requires: grafana >= 3.0.0 
Requires: grafana < 4.0.0 

%description
Dashboards developed with SIMP in mind, but may be useful for other grafana
users.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{prefix}
# Need to set ownership
install -p -m 640 -D src/*.json %{buildroot}%{prefix}

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,grafana,grafana,-)
%config %{prefix}

%post
/bin/pkill -HUP grafana

%postun
# Post uninstall stuff

%changelog
* Wed Nov 15 2016 Ralph Wright <ralph.wright@onyxpoint.com> - 1.0.0-0
  - Updated existing dashboards
  - Added auditd, yum, and selinux dashboards
  - Added consistent default search times
  - Ensured all datasources are set to default
* Mon Sep 12 2016 Ralph Wright <ralph.wright@onyxpoint.com> - 0.9.1
  - Initial Grafana dashboards
