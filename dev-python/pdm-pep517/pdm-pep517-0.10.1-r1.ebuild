# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{8..10} pypy3 )
inherit distutils-r1

DESCRIPTION="A PEP 517 backend for PDM that supports PEP 621 metadata"
HOMEPAGE="
	https://pypi.org/project/pdm-pep517/
	https://github.com/pdm-project/pdm-pep517/
"
SRC_URI="
	https://github.com/pdm-project/pdm-pep517/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/cerberus-1.3.4[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
	>=dev-python/toml-0.10.2[${PYTHON_USEDEP}]
"
BDEPEND="
	${RDEPEND}
	test? (
		dev-vcs/git
	)
"
# setuptools are used to build C extensions
RDEPEND+="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

src_prepare() {
	rm -r pdm/pep517/_vendor || die
	find -name '*.py' -exec sed \
		-e 's:from pdm\.pep517\._vendor\.:from :' \
		-e 's:from pdm\.pep517\._vendor ::' \
		-i {} + || die
	distutils-r1_src_prepare
}

src_test() {
	git config --global user.email "test@example.com" || die
	git config --global user.name "Test User" || die
	distutils-r1_src_test
}

python_test() {
	local EPYTEST_DESELECT=()
	if [[ ${EPYTHON} == pypy3 ]]; then
		EPYTEST_DESELECT+=(
			tests/test_wheel.py::test_override_tags_in_wheel_filename
		)
	fi
	epytest
}
