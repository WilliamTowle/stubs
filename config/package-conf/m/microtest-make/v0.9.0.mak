#!/usr/bin/make
# microtest-make v0.9.0		STUBS (c) and GPLv2 1999-2012
# last modified			2012-06-03

include package.cfg

PACKAGE_CONFIGURED= SOMEFILE-FOO
PACKAGE_BUILT= SOMEFILE-BAR
PACKAGE_INSTALLED= SOMEFILE-BAZ

${PACKAGE_CONFIGURED}:
	echo 'cd-to-source && execute-configure'

${PACKAGE_BUILT}: ${PACKAGE_CONFIGURED}
	echo 'cd-to-source && run-make'

${PACKAGE_INSTALLED}: ${PACKAGE_BUILT}
	echo 'cd-to-source && run-make-install-rule'

.PHONY: NTI
NTI: ${PACKAGE_INSTALLED}
