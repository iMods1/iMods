//
//  zlibTests.m
//  zlib
//
//  Created by Ryan Feng on 10/28/14.
//  Copyright (c) 2014 Wunderkinds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "zip_stream_test.hpp"

@interface zlibTests : XCTestCase

@end

@implementation zlibTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testZipStream{
    XCTAssert(zlib_stream::test_buffer_to_buffer());
    XCTAssert(zlib_stream::test_wbuffer_to_wbuffer());
	XCTAssert(zlib_stream::test_string_string());
	XCTAssert(zlib_stream::test_wstring_wstring());
	XCTAssert(zlib_stream::test_file_file(false));
	XCTAssert(zlib_stream::test_file_file(true));
	XCTAssert(zlib_stream::test_crc());
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
