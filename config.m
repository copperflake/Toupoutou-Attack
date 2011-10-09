//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "config.h"

//
// Ce fichier fournis des fonctions simple qui permettent l'accès facile à
// plusieurs variables globales de "cache" pour éviter les accès excessifs aux
// API en Objective-C qui peuvent être lentes.
//
// Ces fonctions ne sont pas utilisée directement, mais au travers des macros
// de config.h
//

static int CONFIG_SCREEN_W;
static int CONFIG_SCREEN_H;
static id* CONFIG_GAME_CONTROLLER;

void config_init(id* game_controller) {
	CONFIG_GAME_CONTROLLER = game_controller;
	CONFIG_SCREEN_W = [UIScreen mainScreen].bounds.size.height;
	CONFIG_SCREEN_H = [UIScreen mainScreen].bounds.size.width;
}

inline int config_screen_w() { return CONFIG_SCREEN_W; }
inline int config_screen_h() { return CONFIG_SCREEN_H; }

inline id* config_game_controller() {
	return CONFIG_GAME_CONTROLLER;
}