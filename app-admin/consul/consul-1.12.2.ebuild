# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit go-module systemd

DESCRIPTION="A tool for service discovery, monitoring and configuration"
HOMEPAGE="https://www.consul.io"
GIT_COMMIT="19041f202c952a25c5d612a3664e1bdac3c91129"

SRC_URI="https://github.com/hashicorp/consul/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://dev.gentoo.org/~zmedico/dist/consul-1.12.0-deps.tar.xz"

LICENSE="MPL-2.0 Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT"
RESTRICT+=" test"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-go/gox"
COMMON_DEPEND="
	acct-group/consul
	acct-user/consul"
	DEPEND="${COMMON_DEPEND}"
	RDEPEND="${COMMON_DEPEND}"

src_compile() {
	# The dev target sets causes build.sh to set appropriate XC_OS
	# and XC_ARCH, and skips generation of an unused zip file,
	# avoiding a dependency on app-arch/zip.
	GIT_DESCRIBE="v${PV}" \
	GIT_DIRTY="" \
	GIT_COMMIT="${GIT_COMMIT}" \
	emake dev-build
}

src_install() {
	dobin bin/consul

	keepdir /etc/consul.d
	insinto /etc/consul.d
	doins "${FILESDIR}/"*.json.example

	keepdir /var/log/consul
	fowners consul:consul /var/log/consul

	newinitd "${FILESDIR}/consul.initd" "${PN}"
	newconfd "${FILESDIR}/consul.confd" "${PN}"
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotated" "${PN}"
	systemd_dounit "${FILESDIR}/consul.service"
}
