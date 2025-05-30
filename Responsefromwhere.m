//  MyClass.m
//  urlynx
//
//  Created by juli huang on 5/27/25.
//

#import "MyClass.h"

@implementation NetworkManager

- (void)fetchDataFromURL:(NSURL *)url {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithURL:url
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@" Error: %@", error.localizedDescription);
        } else {
            NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
            NSDictionary<NSString *, NSString *> *headers = (NSDictionary<NSString *, NSString *> *)http.allHeaderFields;

            NSLog(@" Status code: %ld", (long)http.statusCode);
            NSLog(@" Headers: %@", headers);

            NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (body) {
                NSLog(@" Response body:\n%@", body);
            } else {
                NSLog(@" Failed to decode response body")
            }

            // Check cache-related headers
            NSString *ageHeader = headers[@"Age"];
            NSString *xCacheHeader = headers[@"X-Cache"];
            NSString *cfCacheStatus = headers[@"CF-Cache-Status"];
            NSString *viaHeader = headers[@"Via"];

            BOOL fromCache = NO;

            if (ageHeader || xCacheHeader || cfCacheStatus || viaHeader) {
                fromCache = YES;
            }

            if (fromCache) {
                NSLog(@" Response likely retrieved from cache.");
            } else {
                NSLog(@" Response retrieved from network.");
            }
        }

        CFRunLoopStop(CFRunLoopGetMain());
    }];

    [task resume];
}

@end
