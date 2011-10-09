//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "config.h"
#import "ToupoutouViewController.h"
#import "Toupoutou.h"
#import	"Platform.h"
#import	"Sprite.h"
#import "MaskFile.h"
#import "DCSoundServices.h"
#import "ToupoutouAnimation.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

// Sert à configurer les UILabel créés programmatiquement (copie des propriétés
// du label du score).
#define CONFIG_LABEL(label) \
	label.highlightedTextColor = scoreLabel.highlightedTextColor;\
	label.highlighted = scoreLabel.highlighted;\
	label.textColor = scoreLabel.textColor;\
	label.shadowColor = scoreLabel.shadowColor;\
	label.shadowOffset = scoreLabel.shadowOffset\

@implementation ToupoutouViewController

@synthesize gameView, speed, runScore, pitiCombo, gameState;

//
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//
- (void) viewDidLoad {
    [super viewDidLoad];
	
	// Création du dégradé de fond
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = CGRectMake(gameView.frame.origin.x, gameView.frame.origin.y, gameView.frame.size.height, gameView.frame.size.width);
		// Coordonées Largeur / Hauteur inversées, les CALayers n'étant pas
		// affectés par l'orientation.
	gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.0 green:(230.0/255.0) blue:1.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:1.0 green:(200.0/255.0) blue:1.0 alpha:1.0] CGColor], nil];
	[gameView.layer insertSublayer:gradient atIndex:0];
	
	// -------------------------------------------------------------------------

	// Initialise le cache des paramètres de configuration (voir config.h)
	config_init(self);
	
	// Quelques initialisations
	gameState = menu;
	lockInterface = NO;
	speed = HYPERBOLIC_SPEED(0);
	
	// Création du conteneur d'objets de la scène
	sceneSprites = [[NSMutableSet alloc] init];
	
#if ENABLE_BACKGRND_MUSIC
	MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
	if([musicPlayer playbackState] != MPMusicPlaybackStatePlaying) {
		// Configuration de la musique de fond
		bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@BACKGROUND_MUSIC ofType:@"mp3"]] error:nil];	
		bgPlayer.numberOfLoops = -1; // Boucle infinie
		[bgPlayer play];
	}
#endif
	
	// -------------------------------------------------------------------------
	
	// Placement des nuages de fond
	background_cur = [self randomBackgroundCloud];
	[background_cur moveTo:CGPointMake(0, BACKGROUND_Y)];
	
	background_next = [self randomBackgroundCloud];
	[background_next placeNextTo:background_cur Spacing:BACKGROUND_SPC Autolink:YES];
	
	background_next2 = [self randomBackgroundCloud];
	[background_next2 placeNextTo:background_next Spacing:BACKGROUND_SPC Autolink:YES];
	// Les nuages ne sont volontairement pas ajoutés dans le conteneur d'objets 
	// pour éviter la modification de leurs coordonnées Y. Cet effet augmente
	// l'impression de distance.
	
	// Création manuelle des premières plateformes pour être sûr que ce soit
	// des platefomes plates. La première est en fait créée hors de l'écran,
	// mais cela est nécessaire pour le moteur de jeu.
	platform_prev = [[Platform alloc] initWithDefaultCloudInView:gameView];
	[platform_prev moveTo:CGPointMake(PLATFORM_1ST_X-DIST_FORMULE-platform_prev.frame.size.width,PLATFORM_1ST_Y)];
	[sceneSprites addObject:platform_prev];
	
	platform_cur = [[Platform alloc] initWithDefaultCloudInView:gameView];
	[platform_cur placeNextTo:platform_prev Spacing:DIST_FORMULE Autolink:YES];
	
	// La deuxiè troisième plateforme (deuxième à l'écran) est en revanche aléatoire
	platform_next = [[Platform alloc] initWithRandomCloudInView:gameView];
	[platform_next placeNextTo:platform_cur Spacing:DIST_FORMULE Autolink:YES];
	
	// -------------------------------------------------------------------------
	// Initialisation de l'interface et masquage des éléments dans le menu.
	
	scoreLabel.alpha = 0;
	
	// Cette macro évite un code lourd et répétitif...
#define MAKE_LIFE(n) life##n = [[Sprite alloc] initWithFile:@"poutou_head.png" InView:self.view AtLocation:CGPointMake(LIFE_X+(LIFE_W+LIFE_SPACE)*(n-1),LIFE_Y)];\
[life##n scaleTo:CGSizeMake(LIFE_W, LIFE_H)]; life##n.alpha = 0.0

	// Création des trois indicateurs de vie
	MAKE_LIFE(1);
	MAKE_LIFE(2);
	MAKE_LIFE(3);
	
#undef MAKE_LIFE

	// Création de la PowerBar indiquant l'énergie restante au Toupoutou	
	power = [[UIProgressView alloc] initWithFrame:CGRectMake(LIFE_X, LIFE_Y+LIFE_H+LIFE_SPACE, -LIFE_SPACE+(LIFE_W+LIFE_SPACE)*3, 10)];
	power.progressViewStyle = UIProgressViewStyleBar;
	power.alpha = 0;
	power.transform = CGAffineTransformMakeScale(1, 0.75);
	[self.view addSubview:power];
	
	// On s'assure que les labels créés depuis InterfaceBuilder respecte le 
	// style du label du score
	CONFIG_LABEL(run1Label);
	CONFIG_LABEL(run2Label);
	CONFIG_LABEL(run3Label);
	CONFIG_LABEL(totalLabel);
	
	// -------------------------------------------------------------------------
	
	// Affichage de la vue du menu par dessus celle du jeu
	[self.view insertSubview:menuView aboveSubview:gameView];
	menuView.center = CGPointMake(SCREEN_W/2, SCREEN_H/2);
	
	// Initialisation du timer qui va provoquer les "frames" du jeu
	[NSTimer scheduledTimerWithTimeInterval:(1.0/TOUPOUTOU_FPS) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

//
// Effectue la transition du menu / tableau de score vers le jeu au lancement
// de la partie
//
- (void) startGame {
	// Masquage du menu et des scores
	[menuView fadeOut];
	[scoreView fadeOut];
	
	// Réinitialisation de la partie avec les paramètres initiaux
	run = 0;
	runScore = 0;
	scores[0] = scores[1] = scores[2] = 0;
	lives = 3;
	speed = HYPERBOLIC_SPEED(0);
	pitiCombo = 1;
	dashTutorial = DASH_TUTORIAL_COUNT;
	jumpTutorial = JUMP_TUTORIAL_COUNT;
	gameState = starting;
	
	[self updateLives];
	[self updatePower];
	
	// Animation de transition "fluide" entre le menu et le jeu
	[UIView beginAnimations:@"startGameAnimation" context:nil];
	[UIView setAnimationDuration:2];
	
	scoreLabel.alpha = 1;							// Score
	life1.alpha = life2.alpha = life3.alpha = 1;	// Indicateurs de vie
	power.alpha = 0.5;								// Barre d'énergie
	
	[UIView commitAnimations];
	
	// On s'assure de la position relative des Sprites entre-eux
	[gameView insertSubview:platform_cur aboveSubview:power];
	[gameView insertSubview:platform_next belowSubview:platform_cur];
	
	// Aucun Toupoutou n'est initialisé par cette méthode. Cela se fera
	// automatiquement une fois l'animation de transition terminée.
}

//
// Effectue la transition du jeu au tableau de score
//
- (void) stopGame {
	// Bloque l'interface pour éviter un clic involontaire qui relancerait le
	// jeu tout de suite après l'affichage des scores. L'interface sera
	// débloquée 2 secondes après.
	lockInterface = YES;
	
	// On enregistre le changement d'état
	gameState = menu;
	runScore = 0;		// Ralentit le défilement des nuages derrière le score
	
	// Affichage de la vue du tableau de scores
	[self.view insertSubview:scoreView aboveSubview:gameView];
	scoreView.alpha = 0;
	scoreView.center = CGPointMake(SCREEN_W/2, SCREEN_H/2);
	
// Sans cette macro, les lignes étaient relativement longues...
#define SINT(n) ((int)scores[n])
	
	// Modification des labels de la vue pour afficher les valeurs correctes
	run1Label.text = [NSString stringWithFormat:@"%d", SINT(0)];
	run2Label.text = [NSString stringWithFormat:@"%d", SINT(1)];
	run3Label.text = [NSString stringWithFormat:@"%d", SINT(2)];
	totalLabel.text = [NSString stringWithFormat:@"%d", SINT(0)+SINT(1)+SINT(2)];
	
#undef SINT
	
	// Animation de transition "fluide" entre le jeu et les scores
	[UIView beginAnimations:@"endGameAnimation" context:nil];
	[UIView setAnimationDuration:2];
	
	scoreLabel.alpha = 0;
	life1.alpha = life2.alpha = life3.alpha = 0;
	power.alpha = 0;
	
	scoreView.alpha = 1;
	
	[UIView commitAnimations];
	
	// Dans 2 secondes, l'interface sera déverouillée
	[self performSelector:@selector(unlockInterface) withObject:self afterDelay:2.0];
}

//
// Débloque l'interface, quelques secondes après l'affichage des scores
//
- (void) unlockInterface {
	lockInterface = NO;
}

//
// Fonction appelée périodiquement chargée de gérer les frames du jeu
//
- (void) onTimer {
	// Ces instructions ne sont pas nécessaire dans le menu
	if(gameState != menu && gameState != starting) {
		
		// Si les conditions sont optimales à la réappartition d'un Toupoutou,
		// on l'effectue.
		if(gameState == can_spawn && (platform_cur.origin.x >= PLATFORM_1ST_X-16 && platform_cur.origin.x <= PLATFORM_1ST_X+16)) {
			[self spawnToupoutou];
			gameState = playing;
			speed = HYPERBOLIC_SPEED(0);
		}
		
		// ---- SCORE ----
		// On ne met à jour le score qu'une frame sur trois. Evite le changement trop rapide
		// des chiffres désagréable à l'oeil
		static int score_lock = 0;
		if(--score_lock < 1) {
			if(gameState == playing) {
				// Pas de score entre la mort et la réapparition du Toupoutou
				runScore += speed;
			}
			
			// La taille du texte dépend du score et de la taille de l'écran.
			scoreLabel.font = [UIFont fontWithName:@"American Typewriter" size:(18.0+((runScore/2000)))*((SCREEN_H+320)/640)];
			
#if DEV_SCORE_DISPLAY_SPEED   // Affiche la vitesse à la place du score (dev)
			scoreLabel.text = [NSString stringWithFormat:@"%f",(speed)];
#else
			scoreLabel.text = [NSString stringWithFormat:@"%d",((int)runScore)];
#endif
			
			score_lock = 3;
		}
	}
	
	// Accélération du jeu
	speed = HYPERBOLIC_SPEED(runScore);
	
	// ---- PLATEFORME ----
	// La première plateforme est déplacée, les autres lui étant liées, tous les
	// nuages sont déplacés en même temps.
	[platform_prev moveAlong:CGVectorMake(-speed,0)];
	
	// De même pour les nuages de fond, à 1/3 de la vitesse (impression de distance)
	[background_cur moveAlong:CGVectorMake((-speed/3),0)];
	
	if(gameState != menu && gameState != starting) {
		// Le Dash nécessite un mouvement supplémentaire des plateformes
		if(toupoutou.dashing)
			[platform_prev moveAlong:CGVectorMake(-((DASH_AMPLITUDE+toupoutou.velocity.x)/2),0)];
		
		// Lorsque le Piti entre sur l'écran, un son est joué et un mini-tutoriel
		// est affiché. Ceci peut s'appliquer aussi bien à la plateforme actuelle
		// qu'à la suivante (surtout sur iPad). Cette macro évite des duplications
		// de code.
#define CHECK_PITI(pltfrm) \
		if(pltfrm.piti && !pltfrm.piti->soundPlayed && abs(pltfrm.piti->sprite.origin.x-SCREEN_W) < 20) {\
			if(pltfrm.piti->sprite.origin.y+pltfrm.piti->sprite.frame.size.height < 10 ||\
			   pltfrm.piti->sprite.origin.y > SCREEN_H-10) { \
				[platform_cur releasePiti];\
			} else {\
				[self displayTutorial:dash];\
				[DCSoundServices playSoundWithName:[NSString stringWithFormat:@"piti%d", (arc4random()%3)] type:@"wav"];\
				pltfrm.piti->soundPlayed = YES;\
			}\
		}
		
		CHECK_PITI(platform_cur);
		CHECK_PITI(platform_next);
		
#undef CHECK_PITI
	}
	
	// Si la plateforme actuelle sort de l'écran, on la supprime. On défini la prochaine comme
	// "actuelle", et on crée une plateforme supplémentaire.
	if(platform_cur.origin.x+platform_cur.frame.size.width < 0) {
		// Si le joueur a raté le Piti, le combo est réinitialisé
		if(platform_cur.piti && !platform_cur.piti->dashed)
			pitiCombo = 1;
		
		// Suppression de la plateforme précédente
		[sceneSprites removeObject:platform_prev];
		[platform_prev removeFromSuperview];
		[platform_prev release];
	
		// La plateforme actuelle devient la précédente
		platform_prev = platform_cur;
		[sceneSprites addObject:platform_prev];	// Seul la première des trois
												// plateformes est dans sceneSprites.
		
		// La plateforme suivante devient l'actuelle utilisée pour les calculs
		platform_cur = platform_next;
		
		// On crée la plateforme suivante ...
		if(gameState == cam_slide || gameState == can_spawn) {
			// Si l'animation de réaparition est en cours, il ne peut apparaitre
			// que des plateformes plates.
			platform_next = [[Platform alloc] initWithDefaultCloudInView:gameView];
		} else {
			// Sinon c'est une plateforme aléatoire.
			platform_next = [[Platform alloc] initWithRandomCloudInView:gameView];
		}
		
		// ... et on la place.
		[platform_next placeNextTo:platform_cur Spacing:DIST_FORMULE Autolink:YES];
	}
	
	// De façon analogue, on remplace les nuages de fond
	if(background_cur.origin.x+background_cur.image.size.width < 0) {
		[background_cur removeFromSuperview];
		[background_cur release];
		
		background_cur = background_next;
		background_next = background_next2;
		
		background_next2 = [self randomBackgroundCloud];
		[background_next2 placeNextTo:background_next Spacing:BACKGROUND_SPC Autolink:YES];
		
		// La position 0 est occupée par le dégardé en fond
		[gameView insertSubview:background_next2 atIndex:1];
	}
	
	// ---- ENGINE ----
	// Calcul du déplacement et des collisions, si l'animation de réapparition
	// n'est pas en cours.
	if(gameState == playing || gameState == cam_lock) {
		[toupoutou computeDisplacementAndCollisionWith:platform_cur];
		
		// Si la plateforme se retrouve plus haut que deux fois la hauteur de
		// l'écran, le Toupoutou est tombé trop bas.
		if((platform_cur.origin.y+platform_cur.frame.size.height) < -(SCREEN_H/2)) {
			pitiCombo = 1; // Remise à 0 du combos des Pitis
			gameState = cam_lock;
		}
	}
	
	// ---- CAMERA ----
	// La caméra se bloque lorsque le Toupoutou tombe dans le vide
	if(gameState == cam_lock) {
		// On attend que le Toupoutou sorte effectivement de l'écran...
		if(toupoutou.origin.y > SCREEN_H) {
			// Suppression du Toupoutou pour éviter de le voir réapparaitre
			toupoutou.alpha = 0;
			
			// Perte d'une vie
			lives--;
			[self updateLives];
			
			// Le score du run actuel est sauvegardé
			scores[(run++)] = runScore;
			runScore = 0;	
			
			if(lives <= 0) {
				// Si le joueur n'a plus de vie, le jeu s'arrête
				[self stopGame];
			} else {
				// Sinon, on peut débuter l'annimation de réapparition
				gameState = cam_up;
			}
		}
	} else {
		// Cette partie de la condition représente tous les autres états de la
		// caméra, lorsque celle-ci est en mouvement.
		
		// Variable qui permettra de déplacer de représenter le mouvement de la
		// caméra de façon uniforme entre chaque état.
		CGFloat delta = 0;
		
		// Gestion des états de l'animation de réapparition
		switch (gameState) {
			// Animation de début de partie
			case starting:
				delta = 7; // Déplacement constant
				
				// Dès que les plateformes qui servent d'arrière-plan au menu ne sont
				// plus visibles, on lance le code de réapparition du Toupoutou comme
				// c'est le cas après une chute.
				if(platform_cur.origin.y > SCREEN_H && platform_next.origin.y > SCREEN_H)
					gameState = cam_up;
				
				break;
				
			// La caméra est téléportée sous les nuages
			case cam_up:
				delta = -((platform_cur.origin.y+platform_cur.frame.size.height+50));
				
				// Réinitialisation de la vitesse
				speed = HYPERBOLIC_SPEED(0);
				
				// Tous les pitis sont effacés
				[platform_prev releasePiti];
				[platform_cur releasePiti];
				[platform_next releasePiti];
				
				// Suppression des prochaines plateforme et remplacement par une 
				// plateforme plate. À nouveau, cette macro évite des répétitions
				// du code.
#define RESET_PLTFRM(pltfrm,prev_pltfrm) \
				[pltfrm removeFromSuperview];\
				[pltfrm release];\
				pltfrm = [[Platform alloc] initWithDefaultCloudInView:gameView];\
				[pltfrm placeNextTo:prev_pltfrm Spacing:DIST_FORMULE Autolink:YES]
				
				RESET_PLTFRM(platform_cur, platform_prev);
				RESET_PLTFRM(platform_next, platform_cur);
				
				// On peut maintenant effectuer le slide vers le haut.
				gameState = cam_slide;
				
				break;
				
			// Lent défilement de la caméra vers le haut jusqu'à ce qu'elle
			// soit à la bonne hauteur pour la réapparition.
			case cam_slide:
				delta = 7;
				
				if(platform_cur.origin.y+platform_cur.enterAnchor.y >= (PLATFORM_1ST_Y)) {
					// On informe le reste du programme que le Toupoutou peut
					// réapparaitre
					gameState = can_spawn;
				}
				
				break;
				
			// En attendant la réapparition effectif du toupoutou (ou pendant le
			// menu), on s'assure de suivre les points d'ancrage des prochaines
			// plateformes
			case can_spawn: 
			case menu:
				delta = (PLATFORM_1ST_Y)-(platform_cur.origin.y+platform_cur.enterAnchor.y);
				if(delta < 0.01 && delta > -0.01) delta = 0;
				delta /= 15;
				
				break;
				
			// Pas d'animation, suivi standard (méthode bornée)
			default:
				if(toupoutou.origin.y < CAMERA_TOP) {
					delta = CAMERA_TOP-toupoutou.origin.y;
				} else if(toupoutou.origin.y > CAMERA_BOTTOM) {
					delta = CAMERA_BOTTOM-toupoutou.origin.y;
				}
		}
		
		// Mis à part lors de la chute du début de partie, la caméra doit suivre
		// le Toupoutou. L'effet de déplacement de caméra est fait en déplacant
		// tous les objets de la scène, d'où le conteneur...
		if(toupoutou.state != enter_falling) {
			NSEnumerator *enumerator = [sceneSprites objectEnumerator];
			Sprite* sprite;
			
			while((sprite = (Sprite*)[enumerator nextObject])) {
				[sprite moveAlong:CGVectorMake(0,delta)];
			}
		}
	}
}

//
// Fait apparaître un nouveau Toupoutou en haut de l'écran
//
- (void) spawnToupoutou {
	if(toupoutou != nil) {
		// On s'assure premièrement de supprimer l'ancien Toupoutou
		[sceneSprites removeObject:toupoutou];
		[toupoutou removeFromSuperview];
		[toupoutou release];
	}
	
	toupoutou = [[Toupoutou alloc] initInView:gameView AtLocation:CGPointMake(TOUPOUTOU_X, -100)];
	[sceneSprites addObject:toupoutou];
	
	// Il faut placer le Toupoutou sous la plateforme actuelle sans quoi
	// il aurait les pieds devant.
	[gameView insertSubview:toupoutou belowSubview:platform_cur];
}

//
// Synchronise l'indicateur de vie avec la variable lives
//
- (void) updateLives {
	// Animation pour un changement fluide
	[UIView beginAnimations:@"animateLives" context:nil];
	[UIView setAnimationDuration:0.5];
	
	life1.alpha = (lives >= 1) ? 1 : 0.2;
	life2.alpha = (lives >= 2) ? 1 : 0.2;
	life3.alpha = (lives >= 3) ? 1 : 0.2;
	
	[UIView commitAnimations];
}

//
// Synchronise l'indicateur d'énergie avec les compteurs du Toupoutou
//
- (void) updatePower {
	// Le dash, rajoutant un saut, représente une part plus importante du total
	// des limites. Cela permet de ne pas voir la barre d'énergie "remonter" ou
	// rester immobile quand on dash.
	power.progress = (float)(JUMP_LIMIT+DASH_LIMIT*2-toupoutou.jumpCount-toupoutou.dashCount*2)/(JUMP_LIMIT+DASH_LIMIT*2);
}

//
// Crée un score animé lors du dash dans les bonus
//
- (void) animateScore:(CGFloat)animateScore Location:(CGPoint)location {
	// On comptabilise le score
	runScore += animateScore;
	
	// Création dynamique d'un UILabel
	UILabel *aScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(location.x, location.y, 500, 50)];
	aScoreLabel.backgroundColor = [UIColor clearColor];
	
	// Définition des propriétés relatives au score animé
	aScoreLabel.text = [NSString stringWithFormat:@"%d",((int)animateScore)];
	aScoreLabel.font = [UIFont fontWithName:@"American Typewriter" size:36];
	aScoreLabel.transform = CGAffineTransformMakeScale(0.6,0.6);
	
	// Copie des propriétés (couleur, ombre, éclairage) du score principal
	CONFIG_LABEL(aScoreLabel);
	
	// Affichage
	[gameView addSubview:aScoreLabel];
	[aScoreLabel release];	// addSubview fait un retain
	
	// Animation
	[UIView beginAnimations:@"animateScore" context:nil];
	[UIView setAnimationDuration:1];
	
	// L'objet doit être retiré à la fin de l'animation
	[UIView setAnimationDelegate:aScoreLabel];
	[UIView setAnimationDidStopSelector:@selector(fadeOut)];
	
	// Etat final de l'animation
	aScoreLabel.transform = CGAffineTransformMakeScale(1,1);
	aScoreLabel.alpha = 0;
	aScoreLabel.center = CGPointMake(aScoreLabel.center.x+200, aScoreLabel.center.y);
	
	[UIView commitAnimations];
}

//
// Affiche un marqueur dans le coin de l'écran ainsi qu'un message pour faire
// comprendre au joueur débutant l'action à effectuer.
//
- (void) displayTutorial:(Tutorial)tutorial; {
	// On s'assure qu'il soit encore nécessaire d'afficher les indications
	if(tutorial == dash) {
		if(dashTutorial <= 0) return;
		dashTutorial--;
	} else {
		if(jumpTutorial <= 0) return;
		jumpTutorial--;
	}
	
	// -------------------------------------------------------------------------
	// TEXTE
	
	//  Création dynamique du label qui affichera l'action à effectuer
	UILabel *tutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
	tutorialLabel.backgroundColor = [UIColor clearColor];
	
	if(tutorial == dash)
		tutorialLabel.text = @"DASH !";
	else
		tutorialLabel.text = @"JUMP !";
	
	tutorialLabel.font = [UIFont fontWithName:@"American Typewriter" size:50];
	tutorialLabel.textAlignment = UITextAlignmentCenter;
	
	tutorialLabel.transform = CGAffineTransformMakeScale(0.6,0.6);
	
	// Les propriétés du texte sont copiées du score.
	CONFIG_LABEL(tutorialLabel);
	
	// Le texte n'est pas tout de suite opaque
	tutorialLabel.alpha = 0.25;
	
	// Affichage
	[gameView addSubview:tutorialLabel];
	[tutorialLabel release];	// addSubview fait un retain
	
	// Animation d'apparition du texte
	[UIView beginAnimations:@"animateTutorial" context:nil];
	[UIView setAnimationDuration:0.5];
	
	// FadeOut tout de suite après l'apparition
	[UIView setAnimationDelegate:tutorialLabel];
	[UIView setAnimationDidStopSelector:@selector(fadeOut)];
	
	tutorialLabel.transform = CGAffineTransformMakeScale(1,1);
	tutorialLabel.alpha = 0.6;
	
	[UIView commitAnimations];
	
	// -------------------------------------------------------------------------
	// CERCLES
	
	// Indicateur de Dash
	
#define CIRCLE_R		100		/* Rayon du cercle de l'indicateur */
#define CIRCLE_OFFSET	10		/* Décalage par rapport aux bords de l'écran */
	
	CircleView *circle ;
	if(tutorial == dash)
		circle = [[CircleView alloc] initWithFrame:CGRectMake(SCREEN_W-CIRCLE_R-CIRCLE_OFFSET, SCREEN_H-CIRCLE_R-CIRCLE_OFFSET, CIRCLE_R, CIRCLE_R)];
	else
		circle = [[CircleView alloc] initWithFrame:CGRectMake(CIRCLE_OFFSET, SCREEN_H-CIRCLE_R-CIRCLE_OFFSET, CIRCLE_R, CIRCLE_R)];
	
#undef CIRCLE_R
#undef CIRCLE_OFFSET
	
	// Configuration du cercle
	circle.color = [scoreLabel.textColor CGColor];
	circle.alpha = 0.25;
	circle.transform = CGAffineTransformMakeScale(0.1,0.1);
	circle.lineWidth = 7;
	
	// Affichage
	[gameView addSubview:circle];
	[circle release];
	
	// Animation d'agrandissement du cercle
	[UIView beginAnimations:@"animateTutorial2" context:nil];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationRepeatCount:3];	// 3 fois de suite
	
	// Après les trois animations, le cercle est fadeOut
	[UIView setAnimationDelegate:circle];
	[UIView setAnimationDidStopSelector:@selector(fadeOut)];
	
	circle.transform = CGAffineTransformMakeScale(1,1);
	
	[UIView commitAnimations];
}

//
// Fonction appelée par l'objet Toupoutou lorsque le Piti de la plateforme 
// actuelle est dashé.
//
- (void) pitiDashed {
	// Raccourci pour accéder au Sprite qui représente le Piti
#define PITI platform_cur.piti->sprite
	
	// On compte le bonus de score apporté par le dash
	[self animateScore:200*(GAME_CONTROLLER.pitiCombo++) Location:toupoutou.center];
	
	//
	// L'animation est divisée en deux partie, la première utilise directement
	// CoreAnimation car la méthode indirecte ([UIView beginAnimations]) ne 
	// permet d'effectuer une rotation sur 360° facilement. Elle s'occupe aussi
	// du scale du Piti.
	//
	// La deuxième partie s'occupe du déplacement et de la variation de l'alpha,
	// plus simple à exprimer avec [UIView beginAnimations].
	//
	
	// -------------------------------------------------------------------------
	// Rotation et Scale
	
	// Création de la matrice de transformation
	CATransform3D transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
	transform = CATransform3DScale(transform, 0.8, 0.8, 1);
	
	// Initialisation de l'animation proprement dite
	CABasicAnimation* animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D:transform];
	
	animation.duration = 0.25;
	animation.cumulative = YES;
	animation.repeatCount = 10; 
	
	// Application de la première animation
	[PITI.layer addAnimation:animation forKey:@"pitisDeath1"];
	
	// -------------------------------------------------------------------------
	// Déplacement et Alpha
	
	[UIView beginAnimations:@"pitisDeath2" context:nil];
	[UIView setAnimationDuration:1.8];
	
	PITI.center = CGPointMake(PITI.center.x+(2500), PITI.center.y+(-1500));
	PITI.alpha = 0;
	
	[UIView commitAnimations];
	
#undef PITI
}

//
// Fabirque un nuage de fond de façon aléatoire
//
-(Sprite*) randomBackgroundCloud {
	NSString *cloudName = [NSString stringWithFormat:@"bg%i.png", arc4random()%2];
	
	Sprite* cloud = [[Sprite alloc] initWithFile:cloudName InView:gameView AtLocation:CGPointMake(0,0)];;
	cloud.alpha = BACKGROUND_ALPHA;
	
	return cloud;
}

// ---- EVENTS ----
//
// Le joueur pose le doigt
//
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// Si l'interface est vérouillée, aucune action n'est effectuée
	if(lockInterface) return;
	
	// Si le jeu est sur le menu, la partie se lance
	if(gameState == menu) {
		[self startGame];
		return;
	}
	
	// Sinon si une animation de réaparition est en cours, aucune action n'est
	// effectuée.
	if(gameState != playing) return;
	
	//
	// On regarde sur quelle moitié de l'écran l'event a été produit
	//  _________ _________
	// |@@@   (SCORE)      |
	// |---      |         |
	// |         |         |
	// |  JUMP ! |  DASH ! |
	// |         |         |
	// |_________|_________|
	//
	// |<-----SCREEN_W---->|
	// |<------->|
	//  SCREEN_W/2
	//
	
	// L'event est identifié et signalé au Toupoutou qui se chargera de
	// réagir correctement
	if([[touches anyObject] locationInView:gameView].x < (SCREEN_W/2))
		[toupoutou jumpBegan];
	else
		[toupoutou dashBegan];
}

//
// Le joueur lève le doigt
//
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// Pas de touch si le jeu n'est pas en cours ou si l'interface est bloquée.
	if(lockInterface || gameState != playing) return;
	
	// Le long-saut a pris fin, on le signale au Toupoutou
	[toupoutou jumpEnded];
}

//
// Appelé par le framework d'Apple, cette fonction force l'orientation paysage.
//
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Retourne vrai si l'orientation est une des deux orientations horizontales
	// possibles.
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

//
// Destructeur du controlleur
//
- (void) viewDidUnload {
	[toupoutou removeFromSuperview];
	[toupoutou release];
	
	[platform_prev removeFromSuperview];
	[platform_prev release];
	[platform_cur removeFromSuperview];
	[platform_cur release];
	[platform_next removeFromSuperview];
	[platform_next release];
	
	[background_cur removeFromSuperview];
	[background_cur release];
	[background_next removeFromSuperview];
	[background_next release];
	[background_next2 removeFromSuperview];
	[background_next2 release];
	
	[sceneSprites release];
	
	[life1 removeFromSuperview];
	[life1 release];
	[life2 removeFromSuperview];
	[life2 release];
	[life3 removeFromSuperview];
	[life3 release];
	
	[power removeFromSuperview];
	[power release];
	
#if ENABLE_BACKGRND_MUSIC
	[bgPlayer release];
#endif
	
	[super viewDidUnload];
}

@end

#undef CONFIG_LABEL
