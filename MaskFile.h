//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <Foundation/Foundation.h>

//
// Cette structure représente le masque à proprement dit. En revanche pour des
// raisons de lisibilité et d'uniformité, il est englobé dans la classe MaskFile
// qui gère sa création, son remplissage et sa lecture.
//
typedef struct MASK {
	int width;	// La largeur et la hauteur sont extraites de l'en-tête du
	int height;	// fichier masque et servent au calcul de position des bytes.
	char* data;	// Les données binaires extraites du fichier
} MASK;

//
// L'objet-interface à la structure C "MASK". Elle contient entre autre le code
// d'initialisation et de lecture
//
@interface MaskFile : NSObject {
	MASK 	*mask;
}

@property (nonatomic, readonly)	MASK *mask;

// Utilisée pour initialiser le cache des masques (décrit plus en détail dans
// le fichier d'implémentation MaskFile.m)
+ (void) initialize;

- (MaskFile*) initWithMask:(NSString*)maskName;

- (BOOL) pixelOpaqueAt:(CGPoint)coords;

@end
