//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>
#import "Platform.h"

//
// Ce fichier a été créé automatiquement par XCode et n'a été que peu modifié.
// Il n'est donc pas d'un grand intérêt concernant notre travail.
//

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Afin de s'assurer que les plateformes soient chargées immédiatement
	// au lancement de l'application et non plus tard, l'appel à la fonction
	// +initialize qui est en principe automatique a été déplacé ici.
	[Platform forceInitialize];
	
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
