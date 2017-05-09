
#import <Foundation/Foundation.h>
#import <Security/Security.h>

#import "RCTVault.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTUtils.h"

@implementation RCTVault

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

// Messages from the comments in <Security/SecBase.h>
NSString *messageForError(NSError *error)
{
  switch (error.code) {
    case errSecUnimplemented:
      return @"Function or operation not implemented.";

    case errSecIO:
      return @"I/O error.";

    case errSecOpWr:
      return @"File already open with with write permission.";

    case errSecParam:
      return @"One or more parameters passed to a function where not valid.";

    case errSecAllocate:
      return @"Failed to allocate memory.";

    case errSecUserCanceled:
      return @"User canceled the operation.";

    case errSecBadReq:
      return @"Bad parameter or invalid state for operation.";

    case errSecNotAvailable:
      return @"No keychain is available. You may need to restart your computer.";

    case errSecDuplicateItem:
      return @"The specified item already exists in the keychain.";

    case errSecItemNotFound:
      return @"The specified item could not be found in the keychain.";

    case errSecInteractionNotAllowed:
      return @"User interaction is not allowed.";

    case errSecDecode:
      return @"Unable to decode the provided data.";

    case errSecAuthFailed:
      return @"The user name or passphrase you entered is not correct.";

    default:
      return error.localizedDescription;
  }
}

RCT_EXPORT_METHOD(getItem:(NSString *)key
                   config:(NSDictionary *)config
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject)
{
  NSString *serviceId = [RCTConvert NSString:config[@"serviceId"]];

  // Create dictionary of search parameters
  NSDictionary *query = @{
    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
    (__bridge id)kSecAttrService: serviceId,
    (__bridge id)kSecAttrAccount: key,
    (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
    (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
  };

  // Look up server in the keychain
  NSDictionary *found;
  CFTypeRef foundTypeRef;
  OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef) query, (CFTypeRef*)&foundTypeRef);

  if (osStatus != noErr && osStatus != errSecItemNotFound) {
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:osStatus userInfo:nil];
    reject(@"no_events", @"There were no events", error);
  }

  found = (__bridge NSDictionary*)(foundTypeRef);
  if (!found) {
    resolve(nil);
  } else {
    NSString *value = [[NSString alloc] initWithData:[found objectForKey:(__bridge id)(kSecValueData)] encoding:NSUTF8StringEncoding];
    resolve(value);
  }
}

RCT_EXPORT_METHOD(setItem:(NSString *)key
                    value:(NSString *)value
                   config:(NSDictionary *)config)
{
  NSString *serviceId = [RCTConvert NSString:config[@"serviceId"]];
  NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *query = @{
    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
    (__bridge id)kSecAttrService: serviceId,
    (__bridge id)kSecValueData: valueData,
    (__bridge id)kSecAttrAccount: key,
  };

  OSStatus osStatus = SecItemDelete((__bridge CFDictionaryRef) query);
  osStatus = SecItemAdd((__bridge CFDictionaryRef) query, nil);
}

RCT_EXPORT_METHOD(deleteItem:(NSString *)key
                      config:(NSDictionary *)config)
{
  NSString *serviceId = [RCTConvert NSString:config[@"serviceId"]];

  // Create dictionary of search parameters
  NSDictionary *query = @{
    (__bridge id)kSecClass: (__bridge id)(kSecClassGenericPassword),
    (__bridge id)kSecAttrService: serviceId,
    (__bridge id)kSecAttrAccount: key,
    (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
    (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
  };

  // Remove any old values from the keychain
  OSStatus osStatus = SecItemDelete((__bridge CFDictionaryRef) query);
}

@end
