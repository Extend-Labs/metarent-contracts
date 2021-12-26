# Metarent Contracts

Contract source code.

## DEV

Prepare the truffle rpc service.
```
truffle develop
```

When launch the console, type:
```
compile -all
migrate --reset
TFToken.deployed().then((instance) => { tft = instance } )
```