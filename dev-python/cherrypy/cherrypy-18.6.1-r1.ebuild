# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..11} pypy3 )

inherit distutils-r1

MY_PN="CherryPy"
MY_P=${MY_PN}-${PV}
DESCRIPTION="CherryPy is a pythonic, object-oriented HTTP framework"
HOMEPAGE="
	https://cherrypy.dev/
	https://github.com/cherrypy/cherrypy/
	https://pypi.org/project/CherryPy/
"
SRC_URI="mirror://pypi/${MY_PN::1}/${MY_PN}/${MY_P}.tar.gz"
S=${WORKDIR}/${MY_P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~x86"
IUSE="ssl test"

RDEPEND="
	>=dev-python/cheroot-8.2.1[${PYTHON_USEDEP}]
	>=dev-python/portend-2.1.1[${PYTHON_USEDEP}]
	dev-python/more-itertools[${PYTHON_USEDEP}]
	dev-python/zc-lockfile[${PYTHON_USEDEP}]
	dev-python/jaraco-collections[${PYTHON_USEDEP}]
	ssl? (
		dev-python/pyopenssl[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	dev-python/setuptools_scm[${PYTHON_USEDEP}]
	test? (
		dev-python/routes[${PYTHON_USEDEP}]
		dev-python/simplejson[${PYTHON_USEDEP}]
		dev-python/objgraph[${PYTHON_USEDEP}]
		dev-python/path-py[${PYTHON_USEDEP}]
		dev-python/requests-toolbelt[${PYTHON_USEDEP}]
		dev-python/pytest-services[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

python_prepare_all() {
	local PATCHES=(
		# https://github.com/cherrypy/cherrypy/pull/1946
		"${FILESDIR}"/${P}-close-files.patch
		"${FILESDIR}"/${P}-py311.patch
	)

	sed -r -e '/(pytest-sugar|pytest-cov)/ d' \
		-i setup.py || die

	sed -r -e 's:--cov-report[[:space:]]+[[:graph:]]+::g' \
		-e 's:--cov[[:graph:]]+::g' \
		-e 's:--doctest[[:graph:]]+::g' \
		-i pytest.ini || die

	distutils-r1_python_prepare_all
}

python_test() {
	local EPYTEST_DESELECT=()
	[[ ${EPYTHON} == python3.11 ]] && EPYTEST_DESELECT+=(
		# broken by changes in traceback output
		cherrypy/test/test_request_obj.py::RequestObjectTests::testErrorHandling
		cherrypy/test/test_tools.py::ToolTests::testHookErrors
	)

	epytest
}
