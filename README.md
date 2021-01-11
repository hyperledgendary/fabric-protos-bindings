# fabric-gateway-protos

**Note:** This repository uses submodules (sorry). Use `git clone --recursive` to clone.

To lint protos:

```
buf lint
```

To generate fabric-gateway Rust stubs (requires [protobuf-codegen crate](https://crates.io/crates/protobuf-codegen))

```
buf generate --path fabric-gateway/protos/gateway.proto \
             --path fabric-protos/common/common.proto \
             --path fabric-protos/common/policies.proto \
             --path fabric-protos/msp/msp_principal.proto \
             --path fabric-protos/peer/chaincode.proto \
             --path fabric-protos/peer/proposal.proto \
             --path fabric-protos/peer/proposal_response.proto
```
