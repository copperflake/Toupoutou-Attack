//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>
#import "config.h"
#import "Sprite.h"
#import "MaskFile.h"

//
// Définit un modèle de nuage qui sera utilisé pour fabriquer les instances de
// la classe Platform.
//
typedef struct CloudModel {
	NSString 	*imageName;
	MaskFile 	*mask;
	CGPoint		enterAnchor;
	CGPoint 	exitAnchor;
	int			piti_count;
	CGPoint		*piti_anchors;
} CloudModel;

//
// Une structure qui englobe toutes les informations utiles sur le Piti
//
typedef struct Piti {
	Sprite* sprite;
	BOOL	soundPlayed;
	BOOL	dashed;
} Piti;

//
// La classe Platform étend Sprite pour y ajouter la gestion des masques de
// collisions et des Pitis. Elle est composée des structures CloudModel et
// Piti qui définissent quel nuage représente cette plateforme et les
// informations sur l'éventuel Piti de la plateforme.
//
@interface Platform : Sprite {
	CloudModel	*cloud;
	Piti		*piti;	// L'utilisation d'un pointeur est particulièrement moche
						// mais elle permet de contourner sans trop de difficultés
						// les limitations des accesseurs Obj-C:
						// pltfrm.piti.soundPlayed = YES <-> pltfrm.piti->soundPlayed = YES
						//	          ^- illégal --^                    ^- possible --^
	
	// Garde une trace de l'affichage du tutoriel de saut
	// (voir ToupoutouViewController)
	BOOL		jumpTutorialDisplayed;
}

@property (nonatomic, readonly)	CloudModel 	*cloud;
@property (nonatomic, readonly)	Piti 		*piti;
@property (nonatomic) 			BOOL		jumpTutorialDisplayed;

// La fonction d'initilisation pré-charge toutes les plateformes et masques
// associés. Cela évite ces calculs au moment du jeu, ainsi que les lags
// que cela entraine.
+ (void) forceInitialize;

// Contructeur de la classe qui se sert d'un modèle de nuage (CloudModel) et
// de la vue qui le contient pour s'initialiser.
- (Platform*) initWithCloud:(CloudModel*)cloud_model InView:(UIView*)parent;

// Deux constructeurs se chargeant de choisir eux-même le modèle de nuage
// utilisé, respectivement un modèle aléatoire et le nuage plat.
- (Platform*) initWithRandomCloudInView:(UIView*)parent;
- (Platform*) initWithDefaultCloudInView:(UIView*)parent;

// Ces fonctions émulent l'ancien comportement de la classe Platform qui
// contenait directement le masque et les coordonnées d'entrée et sortie.
// À présent, ces informations sont à l'intérieur du CloudModel.
- (MaskFile*) mask;
- (CGPoint) enterAnchor;
- (CGPoint) exitAnchor;

// Version surchargée de la fonction de Sprite, qui prend en compte les points
// d'entrée et de sortie des plateformes.
- (void) placeNextTo:(Platform *)sprite Spacing:(int)spacing Autolink:(BOOL)autolink;

// Permet la suppression manuelle du Piti, si cette fonciton n'est pas appelée,
// le Piti est supprimé automatiquement avec la plateforme.
- (void) releasePiti;

- (void) dealloc;

@end
