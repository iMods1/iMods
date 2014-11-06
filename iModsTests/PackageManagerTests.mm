//
//  PackageManagerTests.m
//  iMods
//
//  Created by Ryan Feng on 9/25/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#include <iostream>
#include "IMODownloadManager.h"
#include "libimpkg.h"
#include "zipstream.hpp"

// Functions in libimpkg.cpp
extern std::vector<std::vector<PackageDepTuple>> parseDepString(const std::string& depString);
    
@interface libimpkgTests : XCTestCase

@end

@implementation libimpkgTests

PackageCache* packageCache;

static std::string testCacheFilePath = "/tmp/imods_test_tagfile";
static std::string testIndexFilePath = "/tmp/imods_test_indexfile";

static std::string testCacheFile =
"\
Package: dummy\n\
Version: v1\n\
Description: line1\n\
 line 2\n\
 .\n\
 line 4\n\
\n\
Package: coreutils\n\
Status: install ok installed\n\
Priority: standard\n\
Section: Utilities\n\
Installed-Size: 6536\n\
Maintainer: Jay Freeman (saurik) <saurik@saurik.com>\n\
Architecture: iphoneos-arm\n\
Version: 8.12-12p\n\
Replaces: netatalk (<= 2.0.3-6)\n\
Provides: md5sum, sha1sum\n\
Depends: bash, coreutils-bin (>= 7.4-5), profile.d\n\
Pre-Depends: dpkg (>= 1.14.25-8)\n\
Description: core set of Unix shell utilities from GNU\n\
Name: Core Utilities\n\
Homepage: http://www.gnu.org/software/coreutils/\n\
\n\
Package: debianutils\n\
Essential: yes\n\
Status: install ok installed\n\
Priority: required\n\
Section: Utilities\n\
Installed-Size: 40\n\
Maintainer: Jay Freeman (saurik) <saurik@saurik.com>\n\
Architecture: iphoneos-arm\n\
Version: 3.3.3ubuntu1-1p\n\
Pre-Depends: dpkg (>= 1.14.25-8)\n\
Description: pretty much just run-parts. yep? run-parts\n\
Name: Debian Utilities\n\
\n\
Package: debianutils\n\
Essential: yes\n\
Status: install ok installed\n\
Priority: required\n\
Section: Utilities\n\
Installed-Size: 40\n\
Maintainer: Jay Freeman (saurik) <saurik@saurik.com>\n\
Architecture: iphoneos-arm\n\
Version: 13.5.3ubuntu1-1p\n\
Pre-Depends: dpkg (>= 1.14.25-8)\n\
Description: pretty much just run-parts. yep? run-parts\n\
Name: Debian Utilities\n\
\n\
# Testing packages\n\
Package: a\n\
Version: v1\n\
";

static std::string testIndexFile =
"\
Package: python\n\
Source: python-defaults\n\
Version: 2.7.8-1\n\
Installed-Size: 680\n\
Maintainer: Matthias Klose <doko@debian.org>\n\
Architecture: i386\n\
Replaces: python-dev (<< 2.6.5-2)\n\
Provides: python-ctypes, python-email, python-importlib, python-profiler, python-wsgiref\n\
Depends: python2.7 (>= 2.7.8-1~), python-minimal (= 2.7.8-1), libpython-stdlib (= 2.7.8-1)\n\
Suggests: python-doc (= 2.7.8-1), python-tk (>= 2.7.8-1~)\n\
Conflicts: python-central (<< 0.5.5)\n\
Breaks: update-manager-core (<< 0.200.5-2)\n\
Description: interactive high-level object-oriented language (default version)\n\
Multi-Arch: allowed\n\
Homepage: http://www.python.org/\n\
Description-md5: d1ea97f755d8153fe116080f2352859b\n\
Tag: devel::interpreter, devel::lang:python, implemented-in::c,\n\
implemented-in::python, interface::commandline, role::metapackage,\n\
role::program, scope::utility\n\
Section: python\n\
Priority: standard\n\
Filename: pool/main/p/python-defaults/python_2.7.8-1_i386.deb\n\
Size: 150646\n\
MD5sum: dcec247e39efe0d6f7bb0b77d9f79aa0\n\
SHA1: f78936abc6779f2f8456f0c38dbd44ddb461870c\n\
SHA256: 29dc43e79e7ef9962004fb120562e4db994a1c59a616caa680923fe3b658308a\n\
\n\
Package: python-all\n\
Source: python-defaults\n\
Version: 2.7.8-1\n\
Installed-Size: 21\n\
Maintainer: Matthias Klose <doko@debian.org>\n\
Architecture: i386\n\
Depends: python (= 2.7.8-1), python2.7 (>= 2.7.2-3)\n\
Description: package depending on all supported Python runtime versions\n\
Multi-Arch: allowed\n\
Homepage: http://www.python.org/\n\
Description-md5: 14c468e5025a2ad18b8e7e342d6f5a99\n\
Section: python\n\
Priority: optional\n\
Filename: pool/main/p/python-defaults/python-all_2.7.8-1_i386.deb\n\
Size: 986\n\
MD5sum: 38bf0f2c507e0d339fd9c1255e20acbe\n\
SHA1: 45ae613d0c8cb8bc01b40437357f626d8fe657d2\n\
SHA256: 6b5f5d0a83d335a8e85a1de933a7a253dd14c9d65b30edc91239f0566b924028\n\
\n\
# Dependency calculator testing\
# \
\n\
Package: a\n\
Version: v1\n\
Depends: \n\
\n\
Package: a\n\
Version: v2\n\
Depends: \n\
\n\
Package: b\n\
Version: v2\n\
Depends: a (>= v1)\n\
\n\
Package: b\n\
Version: v1\n\
Depends: \n\
\n\
Package: c\n\
Version: v1\n\
Depends: a (>= v1), b (>= v2)\n\
\n\
Package: d\n\
Version: v1\n\
Depends: a (>= v1), c (>= v1)\n\
\n\
Package: e\n\
Version: v1\n\
Depends: d (>= v1)\n\
";

- (void)setUp {
    [super setUp];
    std::ofstream tmpTagFile(testCacheFilePath, std::ios::out | std::ios::binary);
    tmpTagFile << testCacheFile;
    
    std::ofstream tmpIndexFile(testIndexFilePath, std::ios::out | std::ios::binary);
    zlib_stream::zip_ostream zout2(tmpIndexFile, true);
    zout2 << testIndexFile;
}

- (void)tearDown {
    // Remove tmp files
//    unlink(testCacheFilePath.c_str());
//    unlink(testIndexFilePath.c_str());
    [super tearDown];
}

- (void)testPkgCmp {
    XCTAssert(pkgVersionCmp("1.0", "1.1") < 0);
    XCTAssert(pkgVersionCmp("1.0", "1.0") == 0);
    XCTAssert(pkgVersionCmp("1.0a", "1.0b") < 0);
    XCTAssert(pkgVersionCmp("1.0a1", "1.0a2") < 0);
    XCTAssert(pkgVersionCmp("1.0a1", "1.0a~") > 0);
    XCTAssert(pkgVersionCmp("~", "") < 0);
    XCTAssert(pkgVersionCmp("~~", "a") < 0);
    XCTAssert(pkgVersionCmp("~", "~~") > 0);
    XCTAssert(pkgVersionCmp("1.0-a123", "1.0-132") > 0);
    XCTAssert(pkgVersionCmp("1.0.9", "1.1") < 0);
    XCTAssert(pkgVersionCmp("1.1.0", "1.1") > 0);
    XCTAssert(pkgVersionCmp("1234:1.0", "12345:1.1") < 0);
    XCTAssert(pkgVersionCmp("1234:1.0", "1233:1.1") > 0);
    XCTAssert(pkgVersionCmp("1233:1.0", "1233:1.1") < 0);
    XCTAssert(pkgVersionCmp("1233:1.0", "1233:1.0") == 0);
    XCTAssert(pkgVersionCmp("1233:1~", "1233:1") < 0);
    XCTAssert(pkgVersionCmp("1~", "1233:1") < 0);
    NSLog(@"%d", pkgVersionCmp("8.12-12p", "8.12"));
    XCTAssert(pkgVersionCmp("8.12-12p", "8.12") > 0);
}

- (void)testCacheFile {
    TagFile tagFile(testCacheFilePath, false);
    auto sec = tagFile.section();
    std::string value;
    sec.tag("description", value);
    std::cout << "description: " << value << std::endl;
    XCTAssert(sec.tag("package", value));
    XCTAssert(value == "dummy");
    XCTAssert(sec.tag("version", value));
    XCTAssert(value == "v1");
    XCTAssert(tagFile.nextSection());
    sec = tagFile.section();
    XCTAssert(sec.tag("package", value));
    XCTAssert(value == "coreutils");
    XCTAssert(sec.tag("version", value));
    XCTAssert(value == "8.12-12p");
    XCTAssert(tagFile.nextSection());
    sec = tagFile.section();
    XCTAssert(sec.tag("package", value));
    XCTAssert(value == "debianutils");
    XCTAssert(sec["version"] == "3.3.3ubuntu1-1p");
    XCTAssert(sec["eSsential"] == "yes"); // 'eSsential' is not a type here!
    auto coreutils = tagFile.filter({FilterCondition(std::make_pair("package", "coreutils"), FilterCondition::TAG_EQ)});
    XCTAssert(coreutils.size() == 1);
    XCTAssert(coreutils[0]["package"] == "coreutils");
    
}

- (void)testParseDepString {
    auto dep = parseDepString("coreutils (>= 8.0)");
    XCTAssert(dep.size() == 1);
    XCTAssert(dep[0].size() == 1);
    XCTAssert(dep[0][0] == std::make_tuple("coreutils", VER_GE, "8.0"));
    dep = parseDepString("coreutils | debianutils");
    XCTAssert(dep.size() == 1);
    XCTAssert(dep[0].size() == 2);
    XCTAssert(dep[0][0] == std::make_tuple("coreutils", VER_ANY, ""));
    XCTAssert(dep[0][1] == std::make_tuple("debianutils", VER_ANY, ""));
    dep = parseDepString("coreutils (>> 8.0) | coreutils (<= 5.0)");
    XCTAssert(dep.size() == 1);
    XCTAssert(dep[0].size() == 2);
    XCTAssert(dep[0][0] == std::make_tuple("coreutils", VER_GT, "8.0"));
    XCTAssert(dep[0][1] == std::make_tuple("coreutils", VER_LE, "5.0"));
    dep = parseDepString("coreutils [i386] (>> 8.0) | coreutils (<= 5.0)");
    XCTAssert(dep.size() == 1);
    XCTAssert(dep[0].size() == 2);
    XCTAssert(dep[0][0] == std::make_tuple("coreutils", VER_GT, "8.0"));
    XCTAssert(dep[0][1] == std::make_tuple("coreutils", VER_LE, "5.0"));
    dep = parseDepString("coreutils (>> 8.0) [i386] | coreutils (<= 5.0)");
    XCTAssert(dep.size() == 1);
    XCTAssert(dep[0].size() == 2);
    XCTAssert(dep[0][0] == std::make_tuple("coreutils", VER_GT, "8.0"));
    XCTAssert(dep[0][1] == std::make_tuple("coreutils", VER_LE, "5.0"));
    dep = parseDepString("coreutils (>> 8.0) | coreutils (<= 5.0), debianutils (= 3.0a)");
    XCTAssert(dep.size() == 2);
    XCTAssert(dep[0].size() == 2);
    XCTAssert(dep[0][0] == std::make_tuple("coreutils", VER_GT, "8.0"));
    XCTAssert(dep[0][1] == std::make_tuple("coreutils", VER_LE, "5.0"));
    XCTAssert(dep[1].size() == 1);
    XCTAssert(dep[1][0] == std::make_tuple("debianutils", VER_EQ, "3.0a"));
    dep = parseDepString("firmware (>= 7.0), mobilesubstrate, libactivator");
    XCTAssert(dep.size() == 3);
    XCTAssert(dep[0].size() == 1);
    XCTAssert(dep[1].size() == 1);
    XCTAssert(dep[2].size() == 1);
}

- (void)testPackage {
    TagFile tagFile(testCacheFilePath, false);
    Package coreutils("coreutils", tagFile);
    XCTAssert(coreutils.versionCount() == 1);
    XCTAssert(coreutils.checkDep(std::make_tuple("coreutils", VER_LT, "8.13")));
    XCTAssert(coreutils.checkDep(std::make_tuple("coreutils", VER_GT, "8.12")));
    auto verList = coreutils.ver_list();
    XCTAssert(verList.size() == 1);
    
    Package debianutils("debianutils", tagFile);
    XCTAssert(debianutils.versionCount() == 2);
    XCTAssert(debianutils.checkDep(std::make_tuple("debianutils", VER_LT, "20.30")));
    XCTAssert(debianutils.checkDep(std::make_tuple("debianutils", VER_GT, "8.12")));
    verList = debianutils.ver_list();
    XCTAssert(verList.size() == 2);
}

- (void)testPackageCache {
    TagFile tagFile(testCacheFilePath, false);
    PackageCache cache(tagFile);
    auto coreutils = cache.package("coreutils");
    XCTAssert(coreutils != nullptr);
    XCTAssert(coreutils->versionCount() == 1);
    XCTAssert(coreutils->checkDep(std::make_tuple("coreutils", VER_LT, "8.13")));
    XCTAssert(coreutils->checkDep(std::make_tuple("coreutils", VER_GT, "8.12")));
    auto verList = coreutils->ver_list();
    XCTAssert(verList.size() == 1);
    
    auto debianutils = cache.package("debianutils");
    XCTAssert(debianutils != nullptr);
    XCTAssert(debianutils->versionCount() == 2);
    XCTAssert(debianutils->checkDep(std::make_tuple("debianutils", VER_LT, "20.30")));
    XCTAssert(debianutils->checkDep(std::make_tuple("debianutils", VER_GT, "8.12")));
    verList = debianutils->ver_list();
    XCTAssert(verList.size() == 2);
}

- (void)testPackageIndex {
    TagFile tagFile(testIndexFilePath);
    PackageCache index(tagFile);
    auto python = index.package("python");
    XCTAssert(python != nullptr);
    XCTAssert(python->versionCount() == 1);
    XCTAssert(python->checkDep(std::make_tuple("python", VER_LT, "3.8")));
    XCTAssert(python->checkDep(std::make_tuple("python", VER_GT, "2.6")));
    auto verList = python->ver_list();
    XCTAssert(verList.size() == 1);
   
    NSString* filePath = @"/tmp/Packages.gz";
    XCTAssert(filePath != nil);
    XCTAssert([filePath length] > 0);
    TagFile indexTag([filePath UTF8String]);
    PackageCache index2(indexTag);
    for(auto pkg: index2.allPackages()) {
        std::cout << pkg.first << std::endl;
    }
}

- (void)testDependencyCalculator {
    std::vector<std::string> deps = {"e"};
    DepVector depV;
    for(auto dep:deps){
        depV.push_back(parseDepString(dep)[0][0]);
    }
    DependencySolver solver(testIndexFilePath, testCacheFilePath, depV);
    std::vector<const Version*> versions;
    DepVector brokenDeps;
    XCTAssert(solver.calcDep(versions, brokenDeps));
    XCTAssert(versions.size() > 0);
    std::cout << "Resolved deps:" << std::endl;
    for(auto ver:versions) {
        std::cout << *ver << std::endl;
    }
    XCTAssert(brokenDeps.empty());
    
    // Check updates
    auto updates = solver.getUpdates();
    XCTAssert(!updates.empty());
    XCTAssert(depTuplePackageName(updates[0]) == "a");
    std::cout << "Updates: " << std::endl;
    for(auto dep:updates){
        std::cout << dep << std::endl;
    }
    // Calculate dependencies for updates
    solver.initUnresolvedDeps(updates);
    versions.clear();
    brokenDeps.clear();
    XCTAssert(solver.calcDep(versions, brokenDeps));
    XCTAssert(!versions.empty());
    
    std::cout << "Resolved updates:" << std::endl;
    for(auto ver:versions) {
        std::cout << *ver << std::endl;
    }
    // Test using real data
    versions.clear();
    brokenDeps.clear();
    depV.clear();
    depV.push_back(parseDepString("isklikas.notesCreator")[0][0]);
    DependencySolver solver2("/tmp/Packages.gz", "/tmp/status", depV);
    bool solved = solver2.calcDep(versions, brokenDeps);
    std::cout << "Broken packages:" << std::endl;
    for(auto dep:brokenDeps) {
        std::cout << depTuplePackageName(dep) << std::endl;
    }
    XCTAssert(solved);
    XCTAssert(versions.size() > 0);
    std::cout << "Resolved deps:" << std::endl;
    for(auto ver:versions) {
        std::cout << *ver << std::endl;
    }
    XCTAssert(brokenDeps.empty());
    XCTAssert(brokenDeps.size() == 0);
    
    std::cout << "Resolved updates:" << std::endl;
    for(auto ver:versions) {
        std::cout << *ver << std::endl;
    }
}

- (void)testPerformanceExample {
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
