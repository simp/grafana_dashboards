%define modname beakertest

Summary:   %{modname} Puppet Module
Name:      pupmod-simp-%{modname}
Version:   0.0.1
Release:   0
License:   Apache-2.0
Group:     Applications/System
Source0:    %{name}-%{version}-%{release}.tar.gz
URL:       https://github.com/simp/simp-core
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch

Requires: simp-adapter >= 0.0.1

Provides: pupmod-%{modname} = 0.0.1-0
Obsoletes: pupmod-%{modname} < 0.0.1-0
Provides: simp-%{modname} = 0.0.1-0
Obsoletes: simp-%{modname} < 0.0.1-0

Prefix: /usr/share/simp/modules

%description
garbage module for testing with Beaker

%prep

%setup -q -n pupmod-simp-%{modname}-%{version}

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}%{prefix}
rm -rf .git
rm -f *.lock
rm -rf spec/fixtures/modules
rm -rf dist
rm -rf junit
rm -rf log
curdir=`pwd`
dirname=`basename $curdir`
cp -r ../$dirname %{buildroot}%{prefix}/%{modname}

%clean
[ "%{buildroot}" != "/" ] && rm -rf "%{buildroot}"

%files
%defattr(0640,root,puppet,0750)
%{prefix}/%{modname}

%changelog
* Tue Sep 13 2016 Auto Changelog <auto@no.body> - 0.0.1-0
  - Latest release of pupmod-simp-beakertest
