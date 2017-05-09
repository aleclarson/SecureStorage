
assertTypes = require "assertTypes"
assertType = require "assertType"
isType = require "isType"

vault = require("NativeModules").Vault

exports.configure = (config) ->

  assertTypes config,
    serviceId: String

  exports.get = (key) ->
    assertType key, String
    return vault.getItem key, config

  exports.set = (key, value) ->
    assertType key, String
    assertType value, String
    vault.setItem key, value, config
    return

  exports.delete = (key) ->
    assertType key, String
    vault.removeItem key, config
    return

  delete exports.configure
  return
