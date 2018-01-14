//
//  DPKGTask.h
//  DPKGTSOH
//
//  Created by Yannis on 8/20/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "xpc.h"

@interface DPKGTask : NSObject

-(id)dpkgTaskWithArguments:(NSArray *)args;
-(BOOL)lockDpkg;
-(BOOL)unlockDpkg;
-(NSString *)controlFile;

@end
