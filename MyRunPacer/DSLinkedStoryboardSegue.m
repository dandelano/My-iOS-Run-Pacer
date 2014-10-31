//
//  DSLinkedStoryboardSegue.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/27/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSLinkedStoryboardSegue.h"

@implementation DSLinkedStoryboardSegue

+ (UIViewController *)sceneNamed:(NSString *)identifier
{
    NSArray *info = [identifier componentsSeparatedByString:@"@"];
    
    NSString *storyboard_name = info[1];
    NSString *scene_name = info[0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboard_name
                                                         bundle:nil];
    UIViewController *scene = nil;
    
    if (scene_name.length == 0) {
        scene = [storyboard instantiateInitialViewController];
    }
    else {
        scene = [storyboard instantiateViewControllerWithIdentifier:scene_name];
    }
    
    return scene;
}

- (id)initWithIdentifier:(NSString *)identifier
                  source:(UIViewController *)source
             destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier
                              source:source
                         destination:[DSLinkedStoryboardSegue sceneNamed:identifier]];
}

- (void)perform
{
    UIViewController *source = (UIViewController *)self.sourceViewController;
    [source.navigationController pushViewController:self.destinationViewController
                                           animated:YES];
}


@end
