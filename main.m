//
//  main.m
//  urlynx
//
//  Created by juli huang on 5/27/25.
//

#import <Foundation/Foundation.h>
#import "MyClass.h"


int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSLog(@"Run HTTP req with NetworkManager...");
        
        NetworkManager *m=[[NetworkManager alloc] init];
        
        NSURL* u = [NSURL URLWithString: @"https://www.apple.com"];
        [m fetchDataFromURL:u];
        
        CFRunLoopRun();
    }
    return 0;
}
