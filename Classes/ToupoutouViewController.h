//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Toupoutou.h"
#import "Platform.h"
#import "CircleView.h"

//
// Liste des états du jeu
//
// Ces états sont utilisés principalement pour contrôler le mouvement de la
// caméra et l'animation de réapparition du Toupoutou.
//
typedef enum GameState {
//   /<------------<--------------\
//   |                            ^
/* START=> */ playing,   // ---\  |  - Le jeu fonctionne normalement (partie en cours)
//                             |  |
/*  /----- */ cam_lock,  // <--/  |  - La caméra se bloque et attend la disparition du Toupoutou
//  |                             |
/*  \----> */ cam_up,    // ---\  |  - La caméra se téléporte sous les plateformes
//                             |  |
/*  /----- */ cam_slide, // <--/  |  - Lent défilement vers le haut jusqu'à la bonne hauteur
//  |                             |
/*  \----> */ can_spawn, // ------/  - Le Toupoutou peut apparaître

	// Ces deux états supplémentaires sont utilisés pour gérer l'animation du
	// menu de début et l'écran des score. Cette utilisation se base sur les
	// mouvements déjà implémentés avec l'animation de réapparition.
	
	menu,		// - Le jeu est sur le menu
	starting	// - Animation de début de partie
	
} GameState;

//
// Sert à définir quel type de tutorial in-game est affiché par la fonction
// displayTutorial.
//
typedef enum Tutorial {
	dash,
	jump
} Tutorial;

//
// ToupoutouViewController est une classe "imposée" par le framework d'Apple.
//
// C'est l'élément logiciel qui sera responsable du diriger le jeu en prenant
// en compte les actions de l'utilisateur et en réagissant de façon adéquate.
//
// Il constitue l'élément central du jeu puisqu'il contient tous les calculs,
// mis à par ceux de collisions qui sont déplacés dans la classe Toupoutou.
//
@interface ToupoutouViewController : UIViewController {
	// L'utilisation de gameView permet de placer tous les éléments graphiques
	// du jeu à l'intérieur d'une même vue. De cette façon il est facile de les
	// positionner à l'écran par rapport à menuView et scoreView.
	IBOutlet UIView	*gameView, *menuView, *scoreView;
	
	// Le toupoutou
	Toupoutou		*toupoutou;
	
	// Les plateformes et images de fond dont le fonctionnement est semblable
	Platform		*platform_prev, *platform_cur, *platform_next;
	Sprite			*background_cur, *background_next, *background_next2;
	NSMutableSet	*sceneSprites;
	
	// Les éléments de l'interface: vies, énergie
	Sprite			*life1, *life2, *life3;
	int				lives;
	UIProgressView	*power;
	
	// Les propriétés de la partie en cours
	CGFloat			speed;
	CGFloat			runScore, scores[3];
	int				run;
	int				pitiCombo;
	
	// Label créés dans Interface Builder
	IBOutlet UILabel *scoreLabel, *run1Label, *run2Label, *run3Label, *totalLabel;
	
	// Ces deux compteurs servent à garder une trace des indicateurs affichés en
	// début de partie pour indiquer le saut et le dash.
	int				dashTutorial, jumpTutorial;
	
	// gameState sauvegarde l'état actuel du jeu, principalement utilisé pour
	// les menus et les fonctions de caméra
	GameState		gameState;
	BOOL			lockInterface;	// Désactive l'interface le temps des transitions

#if ENABLE_BACKGRND_MUSIC
	AVAudioPlayer	*bgPlayer;
#endif	

}

@property (nonatomic, readonly)	UIView  	*gameView;
@property (nonatomic, readonly)	CGFloat		speed;
@property (nonatomic, readonly)	CGFloat		runScore;
@property (nonatomic) 			int			pitiCombo;
@property (nonatomic, readonly) GameState	gameState;

// Cette méthode est automatiquement appelée au lancement de l'application
- (void) viewDidLoad;

// viewDidLoad effectue uniquement les initialisations les plus basiques qui
// sont utiles à l'affichage du menu. La fonction startGame se chargera de
// faire la transition entre le menu et la partie à proprement parler.
// stopGame lance l'affichage des scores
- (void) startGame;
- (void) stopGame;
- (void) unlockInterface;

// Fonction principal du jeu, elle est appelée sur la base d'un timer et se
// charge de la génération de chaque image du jeu.
- (void) onTimer;

// Supprime le Toupoutou actuel et en initialise un nouveau.
- (void) spawnToupoutou;

// Ces deux méthodes servent à synchroniser les indicateurs visuels de
// l'interface avec les valeurs des variables du ToupoutouViewController.
// Séparer ces fonction de la méthode principal évite la duplication de code et
// simplifie la gestion de ces indicateurs.
- (void) updateLives;
- (void) updatePower;

// Gère l'animation des scores "bonus" tel que celui accordé lors du dash
// d'un Piti. location défini le point de départ de l'animation.
- (void) animateScore:(CGFloat)animateScore Location:(CGPoint)location;

// Gestion des mini-tutoriels sous la forme d'animations visuelles pendant
// la partie.
- (void) displayTutorial:(Tutorial)tutorial;

// Fonction appelée par le moteur de collisions de la classe Toupoutou pour
// signaler que le Piti de la plateforme actuelle a été "dashé"
- (void) pitiDashed;

// Fabrique un nuage de fond aléatoire. Un comportement identique est disponible
// pour les plateformes dans la classe Platform, cependant les nuages de fond
// étant de simples Sprites, cette fonction a été implémentée ici.
- (Sprite*) randomBackgroundCloud;

// Gestion des actions du joueur à l'écran
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

// Appelé par le framework d'Apple, cette fonction force l'orientation paysage.
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void) viewDidUnload;

@end

