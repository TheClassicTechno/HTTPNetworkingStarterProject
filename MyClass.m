//
//  MyClass.m
//  urlynx
//
//  Created by juli huang on 5/27/25.
//
#import "MyClass.h"

@implementation NetworkManager

- (void)fetchDataFromURL:(NSURL *) url {
    NSURLSessionDataTask *t = [[NSURLSession sharedSession]
                               dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *resp, NSError *e) {
        if (e) {
            NSLog(@"Error: %@", e.localizedDescription);
        }
        else {
            NSHTTPURLResponse *http = (NSHTTPURLResponse *) resp;
            NSLog(@"status code: %ld" ,(long)http.statusCode);
            NSLog(@"response header: %@", http.allHeaderFields);
            
            NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if (body) {
                NSLog(@"Response body:\n%@", body);
                
            }
            else {
                NSLog(@"Cant decode body");
                
            }
        }
        CFRunLoopStop(CFRunLoopGetMain());
    }
                               
                               
    ];
    
    [t resume];
}

@end

