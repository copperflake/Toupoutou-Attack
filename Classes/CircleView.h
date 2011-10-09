//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

//
// CircleView est une extension de UIView qui ne fait que dessiner un cercle
// dans l'espace qu'elle occupe. Cette fonction est utilisée pour les mini-
// tutoriels en jeu.
//
@interface CircleView : UIView {
	CGFloat		lineWidth;	// Largeur du trait
	CGColorRef	color;		// Couleur du trait
}

@property(nonatomic) CGFloat	lineWidth;
@property(nonatomic) CGColorRef	color;

// Fonction de dessin
- (void) drawRect:(CGRect)rect;

@end
