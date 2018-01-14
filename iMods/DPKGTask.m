//
//  DPKGTask.m
//  DPKGTSOH
//
//  Created by Yannis on 8/20/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import "DPKGTask.h"
#import "NSTask.h"

@implementation DPKGTask

-(id)dpkgTaskWithArguments:(NSArray *)args {
    NSTask *task = [[NSTask alloc] init];
   [task setLaunchPath: @"/usr/bin/imodsinstall"];
   [task setArguments: args];

   NSPipe *pipe = [NSPipe pipe];
   [task setStandardOutput: pipe];

   NSFileHandle *file = [pipe fileHandleForReading];

   [task launch];

   NSData *data = [file readDataToEndOfFile];

   NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
   return output;
}

-(BOOL)lockDpkg {
    NSTask *task = [[NSTask alloc] init];
   [task setLaunchPath: @"/usr/bin/imodsinstall"];
   [task setArguments: [[NSArray alloc] initWithObjects: @"lock", nil]];

   NSPipe *pipe = [NSPipe pipe];
   [task setStandardOutput: pipe];

   NSFileHandle *file = [pipe fileHandleForReading];

   [task launch];

   NSData *data = [file readDataToEndOfFile];

   NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
   if ([output isEqualToString:@"YES"]) {
    return YES;
   } else {
    return NO;
   }
}

-(BOOL)unlockDpkg {
    NSTask *task = [[NSTask alloc] init];
   [task setLaunchPath: @"/usr/bin/imodsinstall"];
   [task setArguments: [[NSArray alloc] initWithObjects: @"unlock", nil]];

   NSPipe *pipe = [NSPipe pipe];
   [task setStandardOutput: pipe];

   NSFileHandle *file = [pipe fileHandleForReading];

   [task launch];

   NSData *data = [file readDataToEndOfFile];

   NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
   if ([output isEqualToString:@"YES"]) {
    return YES;
   } else {
    return NO;
   }
}

/*-(id)dpkgTaskWithArguments:(NSArray *)args {
    NSString *arguments = @"cmd|dpkg ";
    for (NSString *arg in args) {
        arguments = [arguments stringByAppendingString:arg];
        if ([args indexOfObject:arg] != args.count-1) {
            arguments = [arguments stringByAppendingString:@" "];
        }
    }
    const char *cmdArgs = [arguments UTF8String];
    xpc_connection_t connection = xpc_connection_create_mach_service("isklikas.respringPending", NULL, 0);
    xpc_connection_set_event_handler(connection, ^(xpc_object_t some_object) { });
    xpc_connection_resume(connection);
    
    xpc_object_t object = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(object, "message", cmdArgs);
    NSLog(@"Sending object: %s\n", xpc_copy_description(object));
    
    xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, object);
    NSLog(@"Received reply object: %s\n\n", xpc_copy_description(reply));
    const char *message = xpc_dictionary_get_string(reply, "message");
    NSString *returned = @"";
    if (message != NULL) {
        returned = [NSString stringWithUTF8String:message];
    } else {
        returned = @"";
    }
    return returned;
}

-(BOOL)lockDpkg {
    NSString *arguments = @"tsk|lock";
    const char *cmdArgs = [arguments UTF8String];
    xpc_connection_t connection = xpc_connection_create_mach_service("isklikas.respringPending", NULL, 0);
    xpc_connection_set_event_handler(connection, ^(xpc_object_t some_object) { });
    xpc_connection_resume(connection);
    
    xpc_object_t object = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(object, "message", cmdArgs);
    NSLog(@"Sending object: %s\n", xpc_copy_description(object));
    
    xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, object);
    NSLog(@"Received reply object: %s\n\n", xpc_copy_description(reply));
    BOOL success = xpc_dictionary_get_bool(reply, "lockStatus");
    return success;
    
}

-(BOOL)unlockDpkg {
    NSString *arguments = @"tsk|unlock";
    const char *cmdArgs = [arguments UTF8String];
    xpc_connection_t connection = xpc_connection_create_mach_service("isklikas.respringPending", NULL, 0);
    xpc_connection_set_event_handler(connection, ^(xpc_object_t some_object) { });
    xpc_connection_resume(connection);
    
    xpc_object_t object = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(object, "message", cmdArgs);
    NSLog(@"Sending object: %s\n", xpc_copy_description(object));
    
    xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, object);
    NSLog(@"Received reply object: %s\n\n", xpc_copy_description(reply));
    BOOL success = xpc_dictionary_get_bool(reply, "unlockStatus");
    return success;
    
}

-(NSString *)controlFile {
    NSString *arguments = @"tsk|cntrl";
    const char *cmdArgs = [arguments UTF8String];
    xpc_connection_t connection = xpc_connection_create_mach_service("isklikas.respringPending", NULL, 0);
    xpc_connection_set_event_handler(connection, ^(xpc_object_t some_object) { });
    xpc_connection_resume(connection);
    
    xpc_object_t object = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(object, "message", cmdArgs);
    NSLog(@"Sending object: %s\n", xpc_copy_description(object));
    
    xpc_object_t reply = xpc_connection_send_message_with_reply_sync(connection, object);
    NSLog(@"Received reply object: %s\n\n", xpc_copy_description(reply));
    const char *message = xpc_dictionary_get_string(reply, "message");
    NSString *returned = @"";
    if (message != NULL) {
        returned = [NSString stringWithUTF8String:message];
    }
    return returned;
}*/

@end
