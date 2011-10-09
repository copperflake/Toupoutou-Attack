//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "config.h"
#import "Toupoutou.h"
#import	"ToupoutouViewController.h"
#import "DCSoundServices.h"

#import <QuartzCore/QuartzCore.h>

// Raccourcis pour accéder aux méthodes utiles du controller
#define CONTROLLER_SPEED ([GAME_CONTROLLER speed])
#define CONTROLLER_SCORE(scr) [GAME_CONTROLLER animateScore:scr Location:self.center]

// Fonction de convertion de coordonnées
#define CONVERT_POINT(n,a,b) CGPoint n = CGPointMake(_CONV_PT(a,x),_CONV_PT(b,y))
#define _CONV_PT(p,w) (self.origin.w+p-platform.origin.w)

#define SET_ANIMATION_STATE(state) [self setAnimationState:state]

// Tableaux d'image pour l'animation du Toupoutou
static NSArray* SPRITES_RUNNING;
static NSArray* SPRITES_FALLING;

@implementation Toupoutou

@synthesize velocity, state, dashing, jumpCount, dashCount;

//
// Initialisation des tableaux d'images pour l'animation du Toupoutou
//
+ (void) initialize {
	// Course sur les nuages
	SPRITES_RUNNING = [[NSArray alloc] initWithObjects:
					   [UIImage imageNamed:@"poutou_running_0.png"],
					   [UIImage imageNamed:@"poutou_running_1.png"],
					   [UIImage imageNamed:@"poutou_running_2.png"],
					   [UIImage imageNamed:@"poutou_running_3.png"],
					   [UIImage imageNamed:@"poutou_running_4.png"],
					   [UIImage imageNamed:@"poutou_running_5.png"],
					   [UIImage imageNamed:@"poutou_running_6.png"], nil];
	
	// Der Untergang
	SPRITES_FALLING = [[NSArray alloc] initWithObjects:
					   [UIImage imageNamed:@"poutou_falling_0.png"],
					   [UIImage imageNamed:@"poutou_falling_1.png"],
					   [UIImage imageNamed:@"poutou_falling_2.png"],
					   [UIImage imageNamed:@"poutou_falling_3.png"],
					   [UIImage imageNamed:@"poutou_falling_4.png"],
					   [UIImage imageNamed:@"poutou_falling_5.png"],
					   [UIImage imageNamed:@"poutou_falling_6.png"], nil];
}

//
// Initialisation du Toupoutou et affichage sur l'écran
//
- (Toupoutou*) initInView:(UIView*)parent AtLocation:(CGPoint)location {
	[super initWithFile:@"poutou_dashing.png" InView:parent AtLocation:location];
	[self scaleTo:CGSizeMake(TOUPOUTOU_WIDTH, TOUPOUTOU_HEIGHT)];
	
	// Initialisation des propriétés
	velocity = CGVectorMake(0,0);
	gravity = STD_GRAVITY;
	
	state = enter_falling;
	dashing = NO;
	
	jumpCount = 0;
	dashCount = 0;
	
	// Le toupoutou commence par tomber.
	SET_ANIMATION_STATE(enter_falling);
	
	return self;
}

//
// Calcule le déplacement du Toupoutou sur les plateformes et gère les collisions
//
- (void) computeDisplacementAndCollisionWith:(Platform*)platform {
	// Le buffering permet de différer la modification effective du placement
	// des Sprites tout en "simulant" un déplacement effectif pour les
	// calculs. Voir Sprite.m pour plus de détail.
	[self startBuffering];
	
	// Calcul physique simple de la chute.
	if(velocity.x <= 0) {
		velocity.y = gravity*(1.0/TOUPOUTOU_FPS)+velocity.y;
		[self moveAlong:CGVectorMake(0,velocity.y)];
	}
	
	// Gestion du déplacement du dash !
	if(dashing) {
		// L'implémentation du Dash nécessite l'utilisation de "center" qui ne
		// peut pas être bufferisé. On arrête donc la bufferisation.
		[self commitBuffering];
		
		// Cette variable sert accessoirement de traceur dans la progression
		// de l'animation du Dash.
		velocity.x--;
		
		if(velocity.x <= 0 && self.center.x <= dashStart) {
			// Si le Toupoutou est revenu à sa position initiale
			velocity.x = 0;
			dashing = NO;
			
			// On s'assure qu'il soit bien placé !
			self.center = CGPointMake(dashStart, self.center.y);
		} else {
			if(velocity.x < 0) {
				// Retour linéaire à l'inverse du dash en avant
				[self moveAlong:CGVectorMake(-DASH_AMPLITUDE/DASH_LNEAR_DIV,0)];
				SET_ANIMATION_STATE(landed);
			} else {
				[self moveAlong:CGVectorMake(velocity.x,0)];
			}
		}
		
		// On reprend le buffering !
		[self startBuffering];
	}
	
	// Vérification de la collision frontale
	CONVERT_POINT(front,TOUPOUTOU_FRONT_X,TOUPOUTOU_FRONT_Y);
	
	// Le pauvre Toupoutou s'est tapé le nez... ='(
	if([platform.mask pixelOpaqueAt:front] && state != dead) {
		state = crashed;
	}
	
	CONVERT_POINT(rleg,TOUPOUTOU_RLEG_X,TOUPOUTOU_RLEG_Y);
	
	if(!platform.jumpTutorialDisplayed && abs(platform.exitAnchor.x-rleg.x) < 200) {
		platform.jumpTutorialDisplayed = YES;
		[GAME_CONTROLLER displayTutorial:jump];
	}	
	
	// Vérification de la collision du pied droit
	if(state != crashed && state != dead) {
		if([platform.mask pixelOpaqueAt:rleg]) {
			jumpCount = 0;
			dashCount = 0;
			[GAME_CONTROLLER updatePower];
			
			if(state != landed) {
				state = landed;
				SET_ANIMATION_STATE(landed);
				gravity = STD_GRAVITY;
			}
			
			// Recherche du premier point hors du masque
			CGFloat yy = rleg.y-1;
			while([platform.mask pixelOpaqueAt:CGPointMake(rleg.x, yy)]) yy--;
			
			CGFloat delta = yy-rleg.y;
			
			rleg.y = rleg.y+delta;
			[self moveAlong:CGVectorMake(0, delta)];
			
			// Modification de l'accélération quand le Toupoutou est "au sol"
			velocity.y = 2;
		} else if(state != enter_falling && state != falling) {
			state = falling;
		}
	}
	
	// Mêmes calculs de coordonnées pour le pied gauche
	CONVERT_POINT(lleg,TOUPOUTOU_LLEG_X,TOUPOUTOU_LLEG_Y);
	
	// Si le toupoutou s'est écrasé, mais qu'il entièrement est sorti du nuage,
	// on considère qu'il tombe à nouveau. Ce qui rend possible le saut.
	if (state == crashed &&
		state != dead && 
		![platform.mask pixelOpaqueAt:rleg] &&
		![platform.mask pixelOpaqueAt:lleg] &&
		![platform.mask pixelOpaqueAt:front]) {
		state = falling;
	}
	
	if(state == landed && state != dead) { // Pas de calculs de rotation quand le toupoutou n'est pas au sol.
						  // On garde une trace de l'ancien angle de rotation pour pouvoir
						  // comparer les différences entre les appels de la fonction.
		static CGFloat old_angle = 0;
		CGFloat r_angle = 0;
		
		if(rleg.x < platform.exitAnchor.x) { // Pas de calcul de rotation après être sorti de la plateforme
			if([platform.mask pixelOpaqueAt:lleg]) {
				// Recherche le premier angle auquel la jambe n'est plus dans le masque,
				// dans le sens de la montre (descente)
				while([platform.mask pixelOpaqueAt:MATRIX_ROTATE(lleg,rleg,r_angle)] && r_angle <= M_PI/4) r_angle += 0.02;
			} else {
				// Recherche le premier angle auquel la jambe n'est plus dans le masque,
				// dans le sens inverse de la montre (montée)
				while(![platform.mask pixelOpaqueAt:MATRIX_ROTATE(lleg,rleg,r_angle)] && r_angle >= -M_PI/4) r_angle -= 0.02;
			}
		}
		
		// On vérifie la différence avec l'ancien angle, on "annule" une trop petite
		// rotation pour éviter que le Toupoutou sautille.
		CGFloat angle_delta = old_angle-r_angle;
		
		if(angle_delta < 0) angle_delta *= -1;
		if(angle_delta < 0.04) r_angle = old_angle;
		
		old_angle = r_angle;
		
		self.angle = r_angle;
	} else if((state == crashed || ((state == falling) && (jumpCount > 0 || rleg.x > platform.exitAnchor.x))) && state != dead) {
		CGFloat r_angle = atan(velocity.y/CONTROLLER_SPEED)/2.5-0.2;
		self.angle = r_angle;
	}
	
	// Validation et application des déplacements
	[self commitBuffering];
	
	// Calcul les coordonées du point "front", mais par rapport à l'écran et pas
	// par rapport à la plateforme
	CGPoint globalFront = [GAME_CONTROLLER.gameView convertPoint:front fromView:platform];
	
	// Si la plateforme a un piti et qu'il n'a pas encore été dashé et qu'il
	// est heurté par le Toupoutou
	if(platform.piti && !platform.piti->dashed && CGRectContainsPoint(platform.piti->sprite.frame, globalFront)) {
		// Si le Toupoutou dash, le Piti meurt, sinon c'est le Toupoutou.
		if(dashing) {
			[GAME_CONTROLLER pitiDashed];		
		} else {
			// Animation de la mort du Toupoutou
			state = dead;
			SET_ANIMATION_STATE(dead);
			
			velocity.y = -10;
			gravity *= 1.5;
			
			CATransform3D transform = CATransform3DMakeRotation(M_PI*0.9, 0, 0, 1);
			
			CABasicAnimation* animation;
			animation = [CABasicAnimation animationWithKeyPath:@"transform"];
			animation.toValue = [NSValue valueWithCATransform3D:transform];
			
			animation.duration = 0.4;
			animation.cumulative = YES;
			animation.repeatCount = 10; 
			
			// Application de l'animation
			[self.layer addAnimation:animation forKey:@"poutouDeath"];
		}
		
		// On sauvergarde le fait que la collision avec ce Piti a été traitée.
		platform.piti->dashed = YES;
	}
}

//
// Modifie l'animation actuelle du Toupoutou
//
- (void) setAnimationState:(PoutouState)s {
	// Évite les changements inutiles
	if(animationState == s) return;
	animationState = s;
	
	[self stopAnimating];
	
	switch(s) {
		case _dash:
			// L'image du dash est l'image par défaut du Toupoutou, on évite
			// simplement de relancer l'animation avec return.
			return;
			
		case dead:
			self.image = [UIImage imageNamed:@"poutou_dead.png"];
			return;
			
		case enter_falling:
		case falling:
			self.animationImages = SPRITES_FALLING;
			self.animationDuration = 0.21;
			break;
			
		default:
			self.animationImages = SPRITES_RUNNING;
			self.animationDuration = 0.35;
			break;
	}
	
	[self startAnimating];
}

// ---- EVENTS ----
//
// Débute le saut
// (sans blaaaaaaagues....)
//
- (void) jumpBegan {
	if(velocity.x > 0 || state == dead) return; // Pas de saut pendant un dash
	if(state != crashed && state != enter_falling && jumpCount < JUMP_LIMIT) {
		state = falling;
		SET_ANIMATION_STATE(falling);
		gravity = JUMP_GRAVITY;
		velocity.y = JUMP_VELOCITY;
		jumpCount++;
		[GAME_CONTROLLER updatePower];
	}
}

//
// Fin du saut
// (vous vous en doutiez non ?)
//
- (void) jumpEnded {
	//if(velocity.x > 0) return;
	gravity = STD_GRAVITY;
}

//
// Début du dash
// (encore une fonction au nom super original...)
//
- (void) dashBegan {
	if(dashing || state == dead) return;
	// dasher dans les nuages peut être nécessaire pour certains Pitis
	if(/*state != crashed &&*/ state != enter_falling && dashCount < DASH_LIMIT) {
		[DCSoundServices playSoundWithName:@"dash" type:@"wav"];
		SET_ANIMATION_STATE(_dash);
		dashing = YES;
		velocity = CGVectorMake(DASH_AMPLITUDE, 0);
		dashStart = self.center.x;
		// Le dash fait gagner un saut
		if(jumpCount >= 1)
			jumpCount--;
		dashCount++;
		gravity = STD_GRAVITY;
		[GAME_CONTROLLER updatePower];
	}
}

@end

#undef CONTROLLER
#undef CONTROLLER_SPEED
#undef CONTROLLER_SCORE

#undef CONVERT_POINT
#undef _CONV_PT
