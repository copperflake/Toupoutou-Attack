//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <Foundation/Foundation.h>
#import "config.h"

//
// La classe Sprite représente une image affichée sur l'écran et fourni des
// méthodes simplifiant leur manipulation.
//
@interface Sprite : UIImageView {
	// Une liste de Sprites liés qui seront déplacés avec celui-ci
	NSMutableSet	*linkedSprites;
	
	// La fonction de temporisation permet d'éviter la mise à jour de
	// l'affichage de multiples fois lorsque le Toupoutou est déplacé
	// plusieurs fois successivement.
	// Plus de détails dans "Sprite.m"
	BOOL			isBuffering;
	
	// Valeurs temporisées
	CGPoint			bufferedCenter;
	CGFloat			angle;
}

@property(nonatomic, readonly)	NSMutableSet	*linkedSprites;
@property(nonatomic)			CGPoint			origin;
@property(nonatomic)			CGFloat			angle;

// Initialise le Sprite avec une image et le place dans une vue
- (Sprite*) initWithFile:(NSString*)path InView:(UIView*)parent AtLocation:(CGPoint)location;

// Accesseurs particuliers pour la propriété "origin"
- (CGPoint) origin;
- (void) setOrigin:(CGPoint)origin;

// Contrôle de la temporisation de sortie
- (void) startBuffering;
- (void) commitBuffering;

// Transformation: déplacement, rotation, scale. Absolue / relative.
- (void) moveTo:(CGPoint)point;
- (void) moveAlong:(CGVector)vector;

- (void) setAngle:(CGFloat)a;		// Permet Sprite.angle = ...
- (void) rotateAt:(CGFloat)angle;
- (void) rotateOf:(CGFloat)angle;

- (void) scaleTo:(CGSize)size;

// Lie ensemble deux Sprites pour déplacer en même temps plusieurs Sprites
- (void) linkWith:(Sprite*)sprite;

// Place un Sprite à côté d'un autre, prenant en compte un espacement et
// en liant les deux Sprites ensemble
- (void) placeNextTo:(Sprite*)sprite Spacing:(int)spacing Autolink:(BOOL)autolink;

- (void) dealloc;

@end
