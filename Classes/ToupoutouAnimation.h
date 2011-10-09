//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import <UIKit/UIKit.h>

//
// ToupoutouAnimation est une extension de la classe UIView destiné à ajouter
// un support généralisé de l'animation "fadeOut". Utilisé premièrement pour
// les mini-tutoriels, cette fonction a permis d'animer très simplement tout
// retrait d'une vue de sa supervue.
//
@interface UIView (ToupoutouAnimation)

// À la fin de l'animation d'une seconde, pendant laquelle l'alpha de la vue
// est progressivement diminué, la vue est automatiquement retirée de son
// conteneur.
- (void) fadeOut;

@end
