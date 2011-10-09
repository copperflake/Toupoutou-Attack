//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "Sprite.h"
#import <QuartzCore/CALayer.h>

// -----------------------------------------------------------------------------
// Partie privée
// -----------------------------------------------------------------------------

// Ces fonctions permettent de rediriger les accès à la propriété
// UIView.center pour l'implémentation des buffers de déplacement.
@interface Sprite (private)

- (CGPoint) _getCenter;
- (void) _setCenter:(CGPoint)c; 

@end

@implementation Sprite (private)

- (CGPoint) _getCenter {
	if(isBuffering)
		return bufferedCenter;
	else
		return self.center;
}

- (void) _setCenter:(CGPoint)c {
	if(isBuffering)
		bufferedCenter = c;
	else
		self.center = c;
}

@end

// -----------------------------------------------------------------------------
// Partie publique
// -----------------------------------------------------------------------------

@implementation Sprite

@synthesize angle, linkedSprites;

//
// Crée un nouveau Sprite en chargeant l'image spécifiée et en la plaçant dans
// la vue donnée.
//
- (Sprite*) initWithFile:(NSString*)path InView:(UIView*)parent AtLocation:(CGPoint)location {
	UIImage* sprite_image = [UIImage imageNamed:path];
	
	[super initWithFrame:CGRectMake(location.x, location.y, sprite_image.size.width, sprite_image.size.height)];
	self.image = sprite_image;

	[parent addSubview:self];
	
	// Initialisation
	isBuffering = NO;
	angle = 0;
	
	linkedSprites = [[NSMutableSet alloc] init];
	
	return self;
}

//
// Donne l'origine du sprite ("leCoinsEnHautAGauche") en se basant sur le centre.
//
- (CGPoint) origin {
	CGPoint sprite_center = [self _getCenter];
	return CGPointMake(sprite_center.x-(self.frame.size.width/2), sprite_center.y-(self.frame.size.height/2));
}

//
// Transforme l'assignation de l'origine en déplacement du centre
//
- (void) setOrigin:(CGPoint)origin {
	[self _setCenter:CGPointMake(origin.x+(self.frame.size.width/2), origin.y+(self.frame.size.height/2))];
}

//
// SYSTEME DE TEMPORISATION
//
// Cette méthode active la temporisation des déplacements. Ces derniers sont
// pris en compte et modifie une variable propre à l'objet mais ne sont pas
// répercutés sur les objets Cocoa Touch. Cela permet de simuler un déplacement
// sans l'exécuter réellement, et donc optimiser l'exécution en limitant les
// phase de "dessin" sur l'écran.
//
- (void) startBuffering {
	// La temporisation est déjà activée
	if(isBuffering) return;
	
	isBuffering = YES;
	bufferedCenter = self.center;
}

//
// Synchronise le placement effectif du Sprite avec les valeurs en local.
// Applique les déplacements temporisés.
//
- (void) commitBuffering {
	// La temporisation n'est pas activée, il n'y a rien à effectuer
	if(!isBuffering) return;
	
	isBuffering = NO;
	self.center = bufferedCenter;
	self.transform = CGAffineTransformMakeRotation(angle);
}

//
// Déplace l'origine du Sprite
//
// Version absolue
- (void) moveTo:(CGPoint)point {
	[self moveAlong:CGVectorMake(point.x-self.origin.x, point.y-self.origin.y)];
}

// Version relative
- (void) moveAlong:(CGVector)vector {
	CGPoint sprite_center = [self _getCenter];
	sprite_center.x += vector.x;
	sprite_center.y += vector.y;
	[self _setCenter:sprite_center];
	
	// Déplacement des objets liés
	NSEnumerator *enumerator = [linkedSprites objectEnumerator];
	Sprite* sprite;
	
	while((sprite = (Sprite*)[enumerator nextObject])) {
		[sprite moveAlong:CGVectorMake(vector.x, vector.y)];
	}
}

//
// Effectue une rotation du Sprite autour de son centre
//
// Permet Sprite.angle = PI/2;
- (void) setAngle:(CGFloat)a { [self rotateAt:a]; }

// Version absolue
- (void) rotateAt:(CGFloat)a {
	angle = (angle+a)/2;
	if(!isBuffering)
		self.transform = CGAffineTransformMakeRotation(angle);
}

// Version relative
- (void) rotateOf:(CGFloat)a { [self rotateAt:angle+a]; }

//
// Cette fonction Scale le Sprite
// Quel scoop !
//
- (void) scaleTo:(CGSize)size {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

//
// Lie deux Sprites ensembles, de telle manière que déplacer le premier,
// déplace le second.
//
- (void) linkWith:(Sprite*)sprite {
	// /!\ Cette fonction ne doit jamais être utilisée pour lier dans les deux
	// sens deux objets. Un objet lié à un autre ne doit jamais avoir cet
	// objet lié à lui-même. L'appel en cascade du déplacement provoquerait
	// alors une boucle infinie.
	[sprite.linkedSprites addObject:self];
}

//
// Place deux Sprites l'un à côté de l'autre, en les alignant verticalement
// sur le haut du Sprite de référence et en les écartant de "spacing".
// Optionnelement, les deux Sprites peuvent automatiquement être liés ensemble.
//
- (void) placeNextTo:(Sprite*)sprite Spacing:(int)spacing Autolink:(BOOL)autolink {
	[self moveTo:CGPointMake(sprite.origin.x+sprite.frame.size.width+spacing, sprite.origin.y)];
	if(autolink)
		[self linkWith:sprite];
}

- (void) dealloc {
	[linkedSprites release];
	[super dealloc];
}

@end
