//
//  appeclipseUITests.m
//  appeclipseUITests
//
//  Created by Gabor Lajos Mate on 2026. 11. 01..
//

#import <XCTest/XCTest.h>

#include "eclipseCommon.h"

#include <limits.h>
#include <stdlib.h>

@interface ResolveSymlinksTests : XCTestCase
@property(nonatomic, strong) NSURL *temporaryDirectory;
@end

@implementation ResolveSymlinksTests

- (void)setUp
{
  [super setUp];

  NSString *directoryName = [NSString stringWithFormat:@"resolveSymlinks-%@", NSUUID.UUID.UUIDString];
  self.temporaryDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES]
      URLByAppendingPathComponent:directoryName isDirectory:YES];

  NSError *error = nil;
  BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL:self.temporaryDirectory
      withIntermediateDirectories:YES attributes:nil error:&error];
  XCTAssertTrue(created, @"Could not create temporary directory: %@", error);
}

- (void)tearDown
{
  NSError *error = nil;
  [[NSFileManager defaultManager] removeItemAtURL:self.temporaryDirectory error:&error];
  XCTAssertNil(error, @"Could not remove temporary directory: %@", error);

  [super tearDown];
}

- (void)testNullPathReturnsNull
{
  XCTAssert(resolveSymlinks(NULL) == NULL);
}

- (void)testRegularFilePathIsReturned
{
  NSURL *fileURL = [self.temporaryDirectory URLByAppendingPathComponent:@"target.txt"];
  NSError *error = nil;
  BOOL written = [@"test" writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
  XCTAssertTrue(written, @"Could not create test file: %@", error);

  char *inputPath = (char *)fileURL.fileSystemRepresentation;
  char *resolvedPath = resolveSymlinks(inputPath);

  XCTAssertNotEqual(resolvedPath, NULL);
  if (resolvedPath != NULL) {
    XCTAssertEqualObjects([NSString stringWithUTF8String:resolvedPath], fileURL.path);
    if (resolvedPath != inputPath) {
      free(resolvedPath);
    }
  }
}

- (void)testSymbolicLinkResolvesToTarget
{
  NSURL *targetURL = [self.temporaryDirectory URLByAppendingPathComponent:@"target.txt"];
  NSError *error = nil;
  BOOL written = [@"test" writeToURL:targetURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
  XCTAssertTrue(written, @"Could not create target file: %@", error);

  NSURL *linkURL = [self.temporaryDirectory URLByAppendingPathComponent:@"link.txt"];
  BOOL linked = [[NSFileManager defaultManager] createSymbolicLinkAtURL:linkURL
      withDestinationURL:targetURL error:&error];
  XCTAssertTrue(linked, @"Could not create symbolic link: %@", error);

  char expectedPath[PATH_MAX];
  XCTAssertNotEqual(realpath(targetURL.fileSystemRepresentation, expectedPath), NULL);

  char *inputPath = (char *)linkURL.fileSystemRepresentation;
  char *resolvedPath = resolveSymlinks(inputPath);

  XCTAssertNotEqual(resolvedPath, NULL);
  if (resolvedPath != NULL) {
    XCTAssertEqualObjects([NSString stringWithUTF8String:resolvedPath],
        [NSString stringWithUTF8String:expectedPath]);
    if (resolvedPath != inputPath) {
      free(resolvedPath);
    }
  }
}

@end
