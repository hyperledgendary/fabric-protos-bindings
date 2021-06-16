SHELL := /usr/bin/env bash -o pipefail

# This controls the location of the cache.
PROJECT := fabric-protos-bindings
# This controls the remote HTTPS git location to compare against for breaking changes in CI.
#
# Most CI providers only clone the branch under test and to a certain depth, so when
# running buf breaking in CI, it is generally preferable to compare against
# the remote repository directly.
#
# Basic authentication is available, see https://buf.build/docs/inputs#https for more details.
HTTPS_FABRIC_PROTOS := https://github.com/hyperledger/fabric-protos.git
# This controls the remote SSH git location to compare against for breaking changes in CI.
#
# CI providers will typically have an SSH key installed as part of your setup for both
# public and private repositories. Buf knows how to look for an SSH key at ~/.ssh/id_rsa
# and a known hosts file at ~/.ssh/known_hosts or /etc/ssh/known_hosts without any further
# configuration. We demo this with CircleCI.
#
# See https://buf.build/docs/inputs#ssh for more details.
SSH_FABRIC_PROTOS := ssh://git@github.com/hyperledger/fabric-protos.git
# This controls the version of buf to install and use.
BUF_VERSION := 0.37.1
# If true, Buf is installed from source instead of from releases
BUF_INSTALL_FROM_SOURCE := false

PROTOC_GEN_GO_VERSION := v1.25.0
PROTOC_GEN_GO_GRPC_VERSION := v1.1.0
TS_PROTOC_GEN_VERSION := 0.14.0
GRPC_TOOLS_VERSION := 1.10.0
GRPC_COMPILER_VERSION := tbc
GRPC_COMPILER_REPO := https://github.com/stepancheg/grpc-rust

### Everything below this line is meant to be static, i.e. only adjust the above variables. ###

UNAME_OS := $(shell uname -s)
UNAME_ARCH := $(shell uname -m)
# Buf will be cached to ~/.cache/fabric-protos-bindings.
CACHE_BASE := $(HOME)/.cache/$(PROJECT)
# This allows switching between i.e a Docker container and your local setup without overwriting.
CACHE := $(CACHE_BASE)/$(UNAME_OS)/$(UNAME_ARCH)
# The location where buf will be installed.
CACHE_BIN := $(CACHE)/bin
# Marker files are put into this directory to denote the current version of binaries that are installed.
CACHE_VERSIONS := $(CACHE)/versions

# Update the $PATH so we can use buf directly
export PATH := $(abspath $(CACHE_BIN)):$(PATH)
# Update GOBIN to point to CACHE_BIN for source installations
export GOBIN := $(abspath $(CACHE_BIN))
# This is needed to allow versions to be added to Golang modules with go get
export GO111MODULE := on

# BUF points to the marker file for the installed version.
#
# If BUF_VERSION is changed, the binary will be re-downloaded.
BUF := $(CACHE_VERSIONS)/buf/$(BUF_VERSION)
$(BUF):
	@rm -f $(CACHE_BIN)/buf
	@mkdir -p $(CACHE_BIN)
ifeq ($(BUF_INSTALL_FROM_SOURCE),true)
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); go get github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION)
	@rm -rf $(BUF_TMP)
else
	curl -sSL \
		"https://github.com/bufbuild/buf/releases/download/v$(BUF_VERSION)/buf-$(UNAME_OS)-$(UNAME_ARCH)" \
		-o "$(CACHE_BIN)/buf"
	chmod +x "$(CACHE_BIN)/buf"
endif
	@rm -rf $(dir $(BUF))
	@mkdir -p $(dir $(BUF))
	@touch $(BUF)

# PROTOC_GEN_GO points to the marker file for the installed version.
#
# If PROTOC_GEN_GO_VERSION is changed, the binary will be re-downloaded.
PROTOC_GEN_GO := $(CACHE_VERSIONS)/protoc-gen-go/$(PROTOC_GEN_GO_VERSION)
$(PROTOC_GEN_GO):
	@rm -f $(CACHE_BIN)/protoc-gen-go
	@mkdir -p $(CACHE_BIN)
	$(eval PROTOC_GEN_GO_TMP := $(shell mktemp -d))
	cd $(PROTOC_GEN_GO_TMP); go get google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	@rm -rf $(PROTOC_GEN_GO_TMP)
	@rm -rf $(dir $(PROTOC_GEN_GO))
	@mkdir -p $(dir $(PROTOC_GEN_GO))
	@touch $(PROTOC_GEN_GO)

# PROTOC_GEN_GO_GRPC points to the marker file for the installed version.
#
# If PROTOC_GEN_GO_GRPC_VERSION is changed, the binary will be re-downloaded.
PROTOC_GEN_GO_GRPC := $(CACHE_VERSIONS)/protoc-gen-go-grpc/$(PROTOC_GEN_GO_GRPC_VERSION)
$(PROTOC_GEN_GO_GRPC):
	@rm -f $(CACHE_BIN)/protoc-gen-go-grpc
	@mkdir -p $(CACHE_BIN)
	$(eval PROTOC_GEN_GO_GRPC_TMP := $(shell mktemp -d))
	cd $(PROTOC_GEN_GO_GRPC_TMP); go get google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)
	@rm -rf $(PROTOC_GEN_GO_GRPC_TMP)
	@rm -rf $(dir $(PROTOC_GEN_GO_GRPC))
	@mkdir -p $(dir $(PROTOC_GEN_GO_GRPC))
	@touch $(PROTOC_GEN_GO_GRPC)

# TS_PROTOC_GEN points to the marker file for the installed version.
#
# If TS_PROTOC_GEN_VERSION is changed, the binary will be re-downloaded.
TS_PROTOC_GEN := $(CACHE_VERSIONS)/ts-protoc-gen/$(TS_PROTOC_GEN_VERSION)
$(TS_PROTOC_GEN):
	@rm -f $(CACHE_BIN)/protoc-gen-ts
	@mkdir -p $(CACHE_BIN)
	$(eval TS_PROTOC_GEN_TMP := $(shell mktemp -d))
	cd $(TS_PROTOC_GEN_TMP); npm install --prefix $(CACHE) -g ts-protoc-gen@$(TS_PROTOC_GEN_VERSION)
	@rm -rf $(TS_PROTOC_GEN_TMP)
	@rm -rf $(dir $(TS_PROTOC_GEN))
	@mkdir -p $(dir $(TS_PROTOC_GEN))
	@touch $(TS_PROTOC_GEN)

# GRPC_TOOLS points to the marker file for the installed version.
#
# If GRPC_TOOLS_VERSION is changed, the binary will be re-downloaded.
GRPC_TOOLS := $(CACHE_VERSIONS)/grpc-tools/$(GRPC_TOOLS_VERSION)
$(GRPC_TOOLS):
	@rm -f $(CACHE_BIN)/grpc_tools_node_protoc $(CACHE_BIN)/grpc_tools_node_protoc_plugin
	@mkdir -p $(CACHE_BIN)
	$(eval GRPC_TOOLS_TMP := $(shell mktemp -d))
	cd $(GRPC_TOOLS_TMP); npm install --prefix $(CACHE) -g grpc-tools@$(GRPC_TOOLS_VERSION)
	@rm -rf $(GRPC_TOOLS_TMP)
	@rm -rf $(dir $(GRPC_TOOLS))
	@mkdir -p $(dir $(GRPC_TOOLS))
	@touch $(GRPC_TOOLS)

# GRPC_COMPILER points to the marker file for the installed version.
#
# If GRPC_COMPILER_VERSION is changed, the binary will be re-downloaded.
GRPC_COMPILER := $(CACHE_VERSIONS)/grpc-compiler/$(GRPC_COMPILER_VERSION)
$(GRPC_COMPILER):
	@rm -f $(CACHE_BIN)/protoc-gen-rust-grpc
	@mkdir -p $(CACHE_BIN)
	$(eval GRPC_COMPILER_TMP := $(shell mktemp -d))
	cd $(GRPC_COMPILER_TMP); cargo install grpc-compiler --git $(GRPC_COMPILER_REPO) --locked --root $(CACHE)
	@rm -rf $(GRPC_COMPILER_TMP)
	@rm -rf $(dir $(GRPC_COMPILER))
	@mkdir -p $(dir $(GRPC_COMPILER))
	@touch $(GRPC_COMPILER)

.DEFAULT_GOAL := local

# deps allows us to install deps without running any checks.

.PHONY: deps
deps: $(BUF) $(PROTOC_GEN_GO) $(PROTOC_GEN_GO_GRPC) $(TS_PROTOC_GEN) $(GRPC_TOOLS) $(GRPC_COMPILER)

# local is what we run when testing locally.
# This does breaking change detection against our local git repository.

.PHONY: local
local: $(BUF)
	buf lint fabric-protos
	# buf breaking --against '.git#branch=main,recurse_submodules=true'
	buf generate --template buf.gen.yaml fabric-protos

# https is what we run when testing in most CI providers.
# This does breaking change detection against our remote HTTPS git repository.

.PHONY: https
https: $(BUF)
	buf lint --config buf.yaml $(HTTPS_FABRIC_PROTOS)
	# buf breaking --against "$(HTTPS_GIT)#branch=main"
	buf generate --template buf.gen.yaml $(HTTPS_FABRIC_PROTOS)

# ssh is what we run when testing in CI providers that provide ssh public key authentication.
# This does breaking change detection against our remote HTTPS ssh repository.
# This is especially useful for private repositories.

.PHONY: ssh
ssh: $(BUF)
	buf lint --config buf.yaml $(SSH_FABRIC_PROTOS)
	# buf breaking --against "$(SSH_GIT)#branch=main"
	buf generate --template buf.gen.yaml $(SSH_FABRIC_PROTOS)

# clean deletes any files not checked in and the cache for all platforms.

.PHONY: clean
clean:
	git clean -xdf
	rm -rf $(CACHE_BASE)

# For updating this repository

.PHONY: updateversion
updateversion:
ifndef VERSION
	$(error "VERSION must be set")
else
ifeq ($(UNAME_OS),Darwin)
	sed -i '' "s/BUF_VERSION := [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/BUF_VERSION := $(VERSION)/g" Makefile
else
	sed -i "s/BUF_VERSION := [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/BUF_VERSION := $(VERSION)/g" Makefile
endif
endif
