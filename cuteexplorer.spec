Name: cuteexplorer
Version: 1.1
Release: 0
Summary: <summary>
License: GPL
Group: Applications
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-root

BuildRequires: qt-devel

%description

%prep
%setup -n %{name}-%{version}

%build
qmake || qmake-qt4
make

%install
%{__rm} -rf %{buildroot}
%{__make} INSTALL_ROOT=%{buildroot} install

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/pixmaps/%{name}.png


