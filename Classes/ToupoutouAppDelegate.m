//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "ToupoutouAppDelegate.h"
#import "ToupoutouViewController.h"

//
// Ce fichier a été créé automatiquement par XCode et n'a été que peu modifié.
// Il n'est donc pas d'un grand intérêt concernant notre travail.
//

@implementation ToupoutouAppDelegate

@synthesize window, viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end
