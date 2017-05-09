var assertType, assertTypes, isType, vault;

assertTypes = require("assertTypes");

assertType = require("assertType");

isType = require("isType");

vault = require("NativeModules").Vault;

exports.configure = function(config) {
  assertTypes(config, {
    serviceId: String
  });
  exports.get = function(key) {
    assertType(key, String);
    return vault.getItem(key, config);
  };
  exports.set = function(key, value) {
    assertType(key, String);
    assertType(value, String);
    vault.setItem(key, value, config);
  };
  exports["delete"] = function(key) {
    assertType(key, String);
    vault.deleteItem(key, config);
  };
  delete exports.configure;
};

//# sourceMappingURL=map/vault.map
