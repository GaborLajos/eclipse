//
//  AppDelegate.h
//  Eclipse
//
//  Created by Gabor Lajos Mate on 2026. 11. 21..
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

