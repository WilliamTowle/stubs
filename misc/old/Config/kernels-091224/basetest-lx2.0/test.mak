.PHONY: default
default: none

#DIR=$(shell pwd)
#TRACE:=$(shell echo "DIR ${DIR}" 1>&2)
TRACE:=$(shell echo "HERE" 1>&2)

native:
	echo "FOO"
	echo "DIR ${DIR}"
