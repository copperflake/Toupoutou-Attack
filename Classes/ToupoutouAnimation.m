//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "ToupoutouAnimation.h"

@implementation UIView (ToupoutouAnimation)

//
// Effectue un fondu de sortie d'une vue et la supprime
//
- (void) fadeOut {
    [UIView beginAnimations:@"fadeOut" context:nil];
	[UIView setAnimationDuration:1];
	
	// L'objet est retiré à la fin de l'animation
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	
	self.alpha = 0;
	
	[UIView commitAnimations];
}

@end
