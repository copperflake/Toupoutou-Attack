//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>

//
// Ce fichier a été créé automatiquement par XCode et n'a été que peu modifié.
// Il n'est donc pas d'un grand intérêt concernant notre travail.
//

// L'AppDelegate contient normalement le code principal de l'application tandis
// que le contrôleur se contente de  gérer la vue (donc l'interface). Pour
// des raisons de simplicité cependant, l'ensemble du jeu est programmé dans
// le contrôleur. Cette classe n'a donc pas un rôle très intéressant.

@class ToupoutouViewController;

@interface ToupoutouAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ToupoutouViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ToupoutouViewController *viewController;

@end
