//
//  AppDelegate.h
//  appeclipse
//
//  Created by Gabor Lajos Mate on 2026. 11. 01..
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

