# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit autotools flag-o-matic java-pkg-opt-2 python-single-r1 qmake-utils

DESCRIPTION="Open Source Graph Visualization Software"
HOMEPAGE="https://www.graphviz.org/ https://gitlab.com/graphviz/graphviz/"
# unfortunately upstream uses an "artifact" store for the pre-generated
# tarball now, which makes predictable URLs impossible.
SRC_URI="https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${PV}/${P}.tar.xz"

LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x64-solaris"
IUSE="+cairo devil doc examples gtk2 gts guile java lasi lefty nls pdf perl postscript python qt5 ruby svg tcl webp X"

REQUIRED_USE="
	!cairo? ( !X !gtk2 !postscript !lasi )
	pdf? ( cairo )
	python? ( ${PYTHON_REQUIRED_USE} )"

# Requires ksh, tests against installed package, missing files and directory
RESTRICT="test"

RDEPEND="
	>=dev-libs/expat-2
	>=dev-libs/glib-2.11.1:2
	dev-libs/libltdl:0
	>=media-libs/fontconfig-2.3.95
	>=media-libs/freetype-2.1.10
	>=media-libs/gd-2.0.34:=[fontconfig,jpeg,png,truetype,zlib]
	>=media-libs/libpng-1.2:0=
	sys-libs/zlib
	virtual/jpeg:0
	virtual/libiconv
	cairo? (
		>=x11-libs/cairo-1.1.10[svg]
		>=x11-libs/pango-1.12
	)
	devil? ( media-libs/devil[png,jpeg] )
	gtk2? (
		x11-libs/gdk-pixbuf:2
		x11-libs/gtk+:2
	)
	gts? ( sci-libs/gts )
	guile? ( dev-scheme/guile )
	java? ( >=virtual/jre-1.8:* )
	lasi? ( media-libs/lasi )
	lefty? (
		x11-libs/libXaw
		x11-libs/libXmu
	)
	pdf? ( app-text/poppler )
	perl? ( dev-lang/perl:= )
	postscript? ( app-text/ghostscript-gpl )
	python? ( ${PYTHON_DEPS} )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtprintsupport:5
		dev-qt/qtwidgets:5
	)
	ruby? ( dev-lang/ruby:* )
	svg? ( gnome-base/librsvg )
	tcl? ( >=dev-lang/tcl-8.3:0= )
	webp? ( media-libs/libwebp:= )
	X? ( x11-libs/libX11 )"
DEPEND="${RDEPEND}
	lefty? ( x11-base/xorg-proto )
	X? ( x11-base/xorg-proto )"
BDEPEND="
	sys-devel/flex
	sys-devel/libtool
	virtual/pkgconfig
	doc? (
		app-text/ghostscript-gpl
		sys-apps/groff
	)
	guile? (
		dev-lang/swig
		dev-scheme/guile
	)
	java? (
		dev-lang/swig
		>=virtual/jdk-1.8:*
	)
	nls? ( >=sys-devel/gettext-0.14.5 )
	perl? ( dev-lang/swig )
	python? ( dev-lang/swig )
	ruby? ( dev-lang/swig )
	tcl? ( dev-lang/swig )"

# Dependency description / Maintainer-Info:

# Rendering is done via the following plugins (/plugins):
# - core, dot_layout, neato_layout, gd , dot
#   the ones which are always compiled in, depend on zlib, gd
# - gtk
#   Directly depends on gtk-2.
#   needs 'pangocairo' enabled in graphviz configuration
#   gtk-2 depends on pango, cairo and libX11 directly.
# - gdk-pixbuf
#   Directly depends on gtk-2 and gdk-pixbuf.
# - glitz
#   Disabled, no particular reason
#   needs 'pangocairo' enabled in graphviz configuration
# - ming
#   flash plugin via -Tswf requires media-libs/ming-0.4. Disabled as it's
#   incomplete.
# - cairo/pango:
#   Needs pango for text layout, uses cairo methods to draw stuff
# - xlib:
#   needs cairo+pango,
#   can make use of gnomeui and inotify support (??? unsure),
#   needs libXaw for UI
#   UI also links directly against libX11, libXmu, and libXt
#   and uses libXpm if available so we make sure it always is

# There can be swig-generated bindings for the following languages (/tclpkg/gv):
# - c-sharp (disabled)
# - scheme (enabled via guile) ... no longer broken on ~x86
# - go (disabled)
# - io (disabled)
# - java (enabled via java) *2
# - lua (enabled via lua)
# - ocaml (enabled via ocaml)
# - perl (enabled via perl) *1
# - php (enabled via php) *2
# - python (enabled via python) *1
# - ruby (enabled via ruby) *1
# - tcl (enabled via tcl)
# *1 = The ${P}-bindings.patch takes care that those bindings are installed to the right location
# *2 = Those bindings don't build because the paths for the headers/libs aren't
#      detected correctly and/or the options passed to swig are wrong (-php instead of -php4/5)

# There are several other tools in /tclpkg:
# gdtclft, tcldot, tclhandle, tclpathplan, tclstubs ; enabled with: --with-tcl
# tkspline, tkstubs ; enabled with: --with-tk

# And the commands (/cmd):
# - dot, dotty, gvedit, gvpr, lefty, lneato, smyrna, tools/* :)
#   sci-libs/gts can be used for some of these
# - lefty:
#   needs Xaw and X to build
# - gvedit (via 'qt5'):
#   based on ./configure it needs qt-core and qt-gui only
# - smyrna : experimental opengl front-end (via 'smyrna')
#   currently disabled -- it segfaults a lot
#   needs x11-libs/gtkglext, gnome-base/libglade, media-libs/freeglut
#   sci-libs/gts, x11-libs/gtk.  Also needs 'gtk','glade','glut','gts' and 'png'
#   with flags enabled at configure time

pkg_setup() {
	use python && python-single-r1_pkg_setup

	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	default

	# ToDo: Do the same thing for examples and/or
	#       write a patch for a configuration-option
	#       and send it to upstream
	# note - the longer sed expression removes multi-line assignments that are extended via '\'
	if ! use doc ; then
		find . -iname Makefile.am \
			| xargs sed -i -e '/^\(html\|pdf\)_DATA.*\\[[:space:]]*$/{:m;N;s/\\\n//;tm;d}' \
				-e '/^\(html\|pdf\)_DATA/d' || die
	fi

	# Nuke the dead symlinks for the bindings
	sed -i -e '/$(pkgluadir)/d' tclpkg/gv/Makefile.am || die

	# replace the whitespace with tabs
	sed -i -e 's:  :\t:g' doc/info/Makefile.am || die

	# use correct version of qmake. bug #567236
	sed -i -e "/AC_CHECK_PROGS(QMAKE/a AC_SUBST(QMAKE,$(qt5_get_bindir)/qmake)" configure.ac || die

	use java && append-cppflags $(java-pkg_get-jni-cflags)

	eautoreconf
}

src_configure() {
	local myconf=(
		# Speeds up the libltdl configure
		--cache-file="${S}"/config.cache
		--enable-ltdl
		$(use_with cairo pangocairo)
		$(use_with devil)
		$(use_with gtk2 gdk)
		$(use_with gtk2 gdk-pixbuf)
		$(use_with gtk2)
		$(use_with gts)
		$(use_with qt5 qt)
		$(use_with lasi)
		$(use_with pdf poppler)
		$(use_with postscript ghostscript)
		$(use_with svg rsvg)
		$(use_with webp)
		$(use_with X x)
		$(use_enable lefty)
		--with-digcola
		--with-fontconfig
		--with-freetype2
		--with-ipsepcola
		--with-libgd
		--with-sfdp
		--without-ming
		# new/experimental features, to be tested, disable for now
		--without-glitz
		--without-ipsepcola
		--without-smyrna
		--without-visio
		# Bindings:
		$(use_enable guile)
		$(use_enable java)
		$(use_enable perl)
		$(use_enable python python3)
		$(use_enable ruby)
		$(use_enable tcl)
		--disable-go
		--disable-io
		--disable-lua
		--disable-ocaml
		--disable-php
		--disable-python
		--disable-r
		--disable-sharp
		# libtool file collision, bug #276609
		--without-included-ltdl
		--disable-ltdl-install
	)
	econf "${myconf[@]}"
}

src_install() {
	sed -i -e "s:htmldir:htmlinfodir:g" doc/info/Makefile || die

	emake DESTDIR="${D}" \
		txtdir="${EPREFIX}"/usr/share/doc/${PF} \
		htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		htmlinfodir="${EPREFIX}"/usr/share/doc/${PF}/html/info \
		pdfdir="${EPREFIX}"/usr/share/doc/${PF}/pdf \
		pkgconfigdir="${EPREFIX}"/usr/$(get_libdir)/pkgconfig \
		install

	if ! use examples; then
		rm -rf "${ED}"/usr/share/graphviz/demo || die
	fi

	find "${ED}" -name '*.la' -delete || die

	einstalldocs

	use python && python_optimize \
		"${D}"$(python_get_sitedir) \
		"${ED}"/usr/$(get_libdir)/graphviz/python3
}

pkg_postinst() {
	# This actually works if --enable-ltdl is passed
	# to configure
	dot -c || die
}

pkg_postrm() {
	# Remove cruft, bug #547344
	rm -rf "${EROOT}"/usr/$(get_libdir)/graphviz/config{,6} || die
}
