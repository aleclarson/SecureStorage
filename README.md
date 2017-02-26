
# vault v1.0.0 ![experimental](https://img.shields.io/badge/stability-experimental-EC5315.svg?style=flat)

Secure, local storage for React Native.

```coffee
vault = require "vault"

vault.configure
  serviceId: "your_app_name"

vault.set "key", "string"

vault.get "key"
.then (value) ->
  console.log value # => "string"

vault.delete "key"
```
