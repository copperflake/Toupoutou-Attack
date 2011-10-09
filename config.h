//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

//
// ATTENTION !
//
// Certains paramètres définis ici sont à la base de l'équilibre du jeu !
// Modifier ces valeurs est succeptibles de rendre le jeu injouable.
//

#ifndef	TOUPOUTOU_H
#define TOUPOUTOU_H

#define TOUPOUTOU_FPS	50.0
#define TOUPOUTOU_X		20

#define DIST_FORMULE	((20*speed)+250)
#define STD_GRAVITY		27

#define JUMP_GRAVITY	12
#define	JUMP_VELOCITY	-10
#define JUMP_LIMIT		2

#define DASH_LIMIT		2
#define DASH_AMPLITUDE	12
#define DASH_LNEAR_DIV	3

#define DASH_TUTORIAL_COUNT		2
#define JUMP_TUTORIAL_COUNT		1

// Vitesse hyperbolique
#define HYPERBOLIC_SPEED(x) (-((20*10)/((x/700)+13))+22)
	// L'utilisation d'un grapher est recommandé pour y comprendre quelque chose.

#define PLATFORM_1ST_X	100
#define	PLATFORM_1ST_Y	((SCREEN_H/2)+20)
#define PLATFORM_ALPHA	0.9

#define BACKGROUND_Y		((SCREEN_H/2)-110)
#define BACKGROUND_ALPHA	0.5
#define BACKGROUND_SPC		50

#define BACKGROUND_MUSIC "Rick"

// Sizes
// Ces constantes utilise de façon transparente des variables globales
// afin de limiter les appels à [UIScreen ...].bounds.size.(height|width)
#define SCREEN_W	(config_screen_w())
#define SCREEN_H	(config_screen_h())

#define IS_IPAD		(SCREEN_H > 320)

// Vies
#define LIFE_X		((IS_IPAD)?45:5)
#define LIFE_Y		((IS_IPAD)?45:5)
#define LIFE_SPACE	((IS_IPAD)?10:5)
#define LIFE_W		25
#define LIFE_H		40

// Camera
#define CAMERA_TOP		((SCREEN_H/2)-130)
#define CAMERA_BOTTOM	((SCREEN_H/2)-50)

// Définition des points de collision
#define TOUPOUTOU_LLEG_X	12
#define TOUPOUTOU_LLEG_Y	80
#define TOUPOUTOU_RLEG_X	31
#define TOUPOUTOU_RLEG_Y	80
#define TOUPOUTOU_FRONT_X	43
#define TOUPOUTOU_FRONT_Y	50
#define TOUPOUTOU_HEAD_X	38
#define TOUPOUTOU_HEAD_Y	23

#define TOUPOUTOU_WIDTH		43
#define TOUPOUTOU_HEIGHT	80

#define PITI_WIDTH	50
#define PITI_HEIGHT	50
#define PITI_CAN_SPAWN(x)	( x > 1000 && (arc4random()%100) < (-10000/((((float)x)/50)+130))+100 )
	// Un grapher est toujours conseillé...

// Options
#define ENABLE_BACKGRND_MUSIC	1	// La musique du jeu ne vaut pas iTunes/l'iPod en arrière-plan !

// Dev
#define DEV_SCORE_DISPLAY_SPEED 0

// ----------------------------------------------------------------------------

// Accès global facile à l'instance de ToupoutouViewController
#define GAME_CONTROLLER ((ToupoutouViewController*)config_game_controller())

#define CGVector 			CGPoint
#define CGVectorMake 		CGPointMake

// Merci à notre tuteur de nous avoir donné cette formule bien pratique ^^
#define MATRIX_ROTATE(p,c,a) (CGPointMake((c.x+cos(a)*(p.x-c.x)-sin(a)*(p.y-c.y)),\
(c.y+sin(a)*(p.x-c.x)-cos(a)*(p.y-c.y))))

// ----------------------------------------------------------------------------

//
// Fonction de cache
//
void config_init();

int config_screen_w();
int config_screen_h();
id* config_game_controller();

#endif