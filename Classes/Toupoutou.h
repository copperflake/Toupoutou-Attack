//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>
#import "Platform.h"
#import "config.h"
#import "Sprite.h"

//
// Les différents états du Toupoutou sont utilisés par le système de collision
// et de déplacement. Ces états sont également utilisé pour représenter
// l'animation actuelle du Toupoutou.
//
typedef enum PoutouState {
	falling,		// Chute
	enter_falling,	// Cas particulier de la chute de début de partie
	landed,			// Au sol
	crashed,		// S'est tappé dans un nuage
	dead,			// Est mort !
	_dash			// Utilisé pour l'animation du dash uniquement
} PoutouState;

//
// La classe Toupoutou représente le personnage principal du jeu. Elle se base
// sur Sprite en lui ajoutant la gestion de la physique et des déplacements
//
@interface Toupoutou : Sprite {
	// Les différentes informations physiques pour le déplacement du Toupoutou
	CGVector	velocity;
	CGFloat		gravity;
	
	// Attributs de gestion du dash. Dashing indique si le Toupoutou est entrain
	// d'effectuer un dash. dashStart enregistre la position du Toupoutou au
	// début du dash afin de le replacer exactement au même endroit.
	BOOL		dashing;
	int			dashStart;
	
	// Limites de saut et de dash
	int			jumpCount;
	int			dashCount;
	
	// L'état actuel du Toupoutou ainsi que de son animation
	PoutouState	state;
	PoutouState	animationState;
}

@property (nonatomic)	CGVector	velocity;
@property (nonatomic)	BOOL		dashing;
@property (nonatomic)	int			jumpCount;
@property (nonatomic)	int			dashCount;
@property (nonatomic)	PoutouState	state;

// Initialise l'ensemble des tableaux de UIImage représentant les différentes
// animations
+ (void) initialize;

// Surcharge du constructeur de Sprite pour ne pas avoir à préciser l'image
- (Toupoutou*) initInView:(UIView*)parent AtLocation:(CGPoint)location;

// Calcul le déplacement du Toupoutou et les collisions avec une plateforme et
// les éléments qu'elle contient
- (void) computeDisplacementAndCollisionWith:(Platform*)platform;

// Modifie l'animation actuelle du Toupoutou
- (void) setAnimationState:(PoutouState)s;

// Fonction de gestion du saut et du dash, appelées par ToupoutouViewController
// après avoir identifié le type d'action souhaitée
- (void) jumpBegan;
- (void) jumpEnded;
- (void) dashBegan;

@end
