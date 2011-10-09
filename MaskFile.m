//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "MaskFile.h"

#import <stdio.h>	// Merci C !
#import <math.h>

// Ce tableau mémorise tous les masques chargés
static NSMutableDictionary *MASK_CACHE;

@implementation MaskFile

@synthesize mask;

//
// Initialisation du cache de masques
//
+ (void) initialize {
	MASK_CACHE = [[NSMutableDictionary alloc] init];
}

//
// Constructeur de la classe masque. Il vérifie premièrement l'absence du
// masque souhaité dans le masque et s'occupe ensuite de son chargement.
//
- (MaskFile*) initWithMask:(NSString*)maskName {	
	NSString *maskPath = [[NSBundle mainBundle] pathForResource:maskName ofType:@"mask"];

	// Utilisation du cache de masques
	MaskFile* cached_mask;
	if((cached_mask = [MASK_CACHE valueForKey:maskPath]) != nil) {
		mask = cached_mask.mask;
		return self;
	}
	
	// Simple et rapide: une erreur dans le chargement d'un mask crash l'app.
	// C'est peut être moche, mais ça ne devrait pas arriver... Cette macro
	// s'apparente à la macro assert() dont elle copie le principe de
	// fonctionnement. À la différence qu'assert() est désactivée lors de la
	// compilation en mode Release, ce n'est pas le cas de cette macro.
#define CHECK(e) ((e)?:abort())
	
	//
	// Note sur la suite de cette fonction:
	//
	// Parfois, il est plus simple de se rabattre sur le C que de batailler
	// des semaines avec l'Obj-C et les frameworks d'Apple ! La lecture de
	// données binaires avec NSData ne semblait pas être quelque chose de
	// simple à réaliser dans notre cas. L'implémentation ci-dessous utilise
	// donc les fonctions de la libc pour lire le fichier. Plus clair selon
	// nous, cette méthode nous a permis de ne pas perdre de temps sur un
	// détail technique.
	//
	
	const char* path  = [maskPath cStringUsingEncoding:NSASCIIStringEncoding];
	
	FILE* fp = fopen(path, "r");
	
	CHECK(fp);
	
	// Vérification de la signature du MASK
	int signature;
	fread(&signature, 4, 1, fp);
	
	CHECK(signature == 1263747405); // "MASK" en ASCII, lu en tant que int
	
	mask = malloc(sizeof(MASK));
	
	// Largeur x Hauteur
	fread(&(mask->width), 4, 1, fp);
	fread(&(mask->height), 4, 1, fp);
	
	// Longueur de MASK
	int start = ftell(fp);
	fseek(fp, 0, SEEK_END);			// Déplace le curseur à la fin du fichier
	int length = ftell(fp)-start;
	fseek(fp, start, SEEK_SET);		// Replace le curseur au début du masque
	
	// On s'assure que la longueur effective corresponde avec la valeur théorique
	CHECK(ceil(mask->width*mask->height/8)+1 == length);
	
	// Lecture
	mask->data = malloc(length);
	fread(mask->data, 1, length-1, fp);
	mask->data[length] = '\0'; // La chaine est terminée proprement !

	// Enregistrement du masque dans le cache
	[MASK_CACHE setValue:self forKey:maskPath];
	
	fclose(fp);
	
	//
	// Note sur la gestion mémoire:
	//
	// Les deux allocations mémoire effectuées par cette méthode (malloc()) ne
	// sont jamais liberées. Cependant, en pratique cette fonction n'est appelée
	// qu'une fois pour chaque masque. En outre, ces masques sont conservés tout
	// au long du jeu. Libérer l'espace mémoire alloué n'aurait de sens qu'à
	// l'arrêt de l'application. Et dans ce cas, iOS se charge déjà de désalouer
	// automatiquement l'ensemble de la mémoire utilisée par notre application.
	//
	// Il n'y a donc pas de free() correspondant, ailleurs dans le programme.
	//
	
	return self;
	
#undef CHECK
}

//
// Vérifie l'opacité du masque à un point donné
//
- (BOOL) pixelOpaqueAt:(CGPoint)coords {
	int x = (int)coords.x;
	int y = (int)coords.y;
	
	// On s'assure de la cohérence des coordonnées fournies. Des coordonnées
	// hors des limites du masque rendent le calcul du byte incorrect et
	// provoque des résultats erronés. Si le point est hors du masque, par 
	// définition, le pixel n'est pas opaque.
	if(x < 0) return NO;
	if(y < 0) return NO;
	if(x > mask->width) return NO;
	if(y > mask->height) return NO;
	
	// Chaque pixel du masque est numéroté de gauche à droite puis de haut en
	// bas. Cela permet de le représenter sur une seule dimension au lieu de
	// deux. La connaissance de la largeur du masque est nécessaire pour ce
	// calcul.
	int pixel = (y*mask->width)+x;
	
	int byte = pixel/8;		// Détermination du byte qui contiendra ce pixel
	int offset = pixel%8;	// Et la position du bit dans le byte
	
	// Le ET booléen va vérifier la valeur du bit correspondant au pixel. Le
	// résultat de cette opération est une puissance de deux si le masque est
	// opaque (donc le bit sur 1) ou 0 si le masque est transparent. Cette
	// valeur peut donc être utilisée pour effectuer un test logique.
	return (mask->data[byte] & (1 << offset)) ? YES : NO;
}

@end
