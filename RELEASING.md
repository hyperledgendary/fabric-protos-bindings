# Release process

Releasing new Hyperledgendary versions of fabric-protos for Golang, Node.js and Rust (TBC) is currently a manual process.

## Generate the proto bindings

Run the build to generate code from the [Hyperledger Fabric proto definitions](https://github.com/hyperledger/fabric-protos), e.g.

```
make ssh
```

## Publish fabric-ledger-protos-go

Update the [fabric-protos-go](https://github.com/hyperledgendary/fabric-protos-go) repository with the latest generated code

## Publish fabric-ledger-protos-node

Publish a new version of the [fabric-protos node module](https://www.npmjs.com/package/@hyperledgendary/fabric-protos) by following the instructions for [Creating and publishing scoped public packages](https://docs.npmjs.com/creating-and-publishing-scoped-public-packages), e.g.

```
npm publish --access public
```

## Publish fabric-ledger-protos-rust

TBC
