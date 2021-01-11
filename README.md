# fabric-gateway-protos

**Note:** This repository uses submodules (sorry). Use `git clone --recursive` to clone.

To lint protos:

```
buf lint
```

To generate fabric-gateway Rust stubs (requires [protobuf-codegen crate](https://crates.io/crates/protobuf-codegen))

```
buf generate --path fabric-gateway/protos/gateway.proto
```
