//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

//
// DCSoundServices.m
// "An Objective-C wrapper for AudioServicesPlaySystemSound", par Danilo Campos
//
// http://blog.danilocampos.com/2009/12/14/an-objective-c-wrapper-for-audioservicesplaysystemsound/
// Consulté pour la dernière fois le 22 novembre 2010.
//

#import "DCSoundServices.h"

@implementation DCSoundServices

//
// Lecture d'un son court (dans notre cas des .wav)
//
+ (void) playSoundWithName:(NSString *)fileName type:(NSString *)fileExtension {
	CFStringRef cfFileName = (CFStringRef) fileName;
	CFStringRef cfFileExtension = (CFStringRef) fileExtension;
	
	CFBundleRef mainBundle;
	mainBundle = CFBundleGetMainBundle ();
	
	CFURLRef soundURLRef  = CFBundleCopyResourceURL (mainBundle, cfFileName, cfFileExtension, NULL);
	
	SystemSoundID soundID;
	
	AudioServicesCreateSystemSoundID (soundURLRef, &soundID);
	
	AudioServicesPlaySystemSound (soundID);
	
	CFRelease(soundURLRef);
}

//
// Pas utilisée dans le cas de Toupoutou Attack.
//
+ (void) vibrateDevice {
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end