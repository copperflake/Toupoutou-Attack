//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

//
// DCSoundServices.h
// "An Objective-C wrapper for AudioServicesPlaySystemSound", par Danilo Campos
//
// http://blog.danilocampos.com/2009/12/14/an-objective-c-wrapper-for-audioservicesplaysystemsound/
// Consulté pour la dernière fois le 22 novembre 2010.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

//
// La classe de base écrite par Danilo Campos a été étendue pour gérer
// l'ensemble des sons de Toupoutou Attack, notamment la musique de fond.
//

@interface DCSoundServices : NSObject {
	
}

+ (void) playSoundWithName:(NSString *)fileName type:(NSString *)fileExtension;
+ (void) vibrateDevice;

@end
