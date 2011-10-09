//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "Platform.h"
#import "config.h"
#import "ToupoutouViewController.h"
#import "DCSoundServices.h"

// L'ensemble des nuages à disposition
static CloudModel*	clouds;
// Le nombre de nuage disponibles
static         int	clouds_count = 9;
// Les images qui composent l'animation du Piti
static    NSArray*	PITI_ANIM;

@implementation Platform

@synthesize cloud, piti, jumpTutorialDisplayed;

//
// Initialisation des variables ci-dessus
//
+ (void) forceInitialize {
	// Animation du Piti
	PITI_ANIM = [[NSArray alloc] initWithObjects:
				 [UIImage imageNamed:@"piti_1.png"],
				 [UIImage imageNamed:@"piti_2.png"],
				 [UIImage imageNamed:@"piti_3.png"],
				 [UIImage imageNamed:@"piti_4.png"],
				 [UIImage imageNamed:@"piti_5.png"],
				 [UIImage imageNamed:@"piti_6.png"],
				 [UIImage imageNamed:@"piti_7.png"],
				 [UIImage imageNamed:@"piti_8.png"],
				 [UIImage imageNamed:@"piti_9.png"], nil];
	
	// Allocation du tableau des nuages
	clouds = malloc(sizeof(CloudModel)*clouds_count);

	// Initialisation de tous les nuages
	clouds[0].imageName = @"cloud1.png";
	clouds[0].mask = [[MaskFile alloc] initWithMask:@"cloud1"];
	clouds[0].enterAnchor = CGPointMake(1,15);
	clouds[0].exitAnchor = CGPointMake(446,15);
	clouds[0].piti_count = 1;
	clouds[0].piti_anchors = malloc(sizeof(CGPoint)*clouds[0].piti_count);
		clouds[0].piti_anchors[0] = CGPointMake(390,15);
	
	clouds[1].imageName = @"cloud2.png";
	clouds[1].mask = [[MaskFile alloc] initWithMask:@"cloud2"];
	clouds[1].enterAnchor = CGPointMake(20,110);
	clouds[1].exitAnchor = CGPointMake(426,10);
	clouds[1].piti_count = 2;
	clouds[1].piti_anchors = malloc(sizeof(CGPoint)*clouds[1].piti_count);
		clouds[1].piti_anchors[0] = CGPointMake(400,10);
		clouds[1].piti_anchors[1] = CGPointMake(50,110);
	
	clouds[2].imageName = @"cloud3.png";
	clouds[2].mask = [[MaskFile alloc] initWithMask:@"cloud3"];
	clouds[2].enterAnchor = CGPointMake(13,40);
	clouds[2].exitAnchor = CGPointMake(931,160);
	clouds[2].piti_count = 3;
	clouds[2].piti_anchors = malloc(sizeof(CGPoint)*clouds[2].piti_count);
		clouds[2].piti_anchors[0] = CGPointMake(140,10);
		clouds[2].piti_anchors[1] = CGPointMake(800,190);
		clouds[2].piti_anchors[2] = CGPointMake(700,25);
	
	clouds[3].imageName = @"cloud4.png";
	clouds[3].mask = [[MaskFile alloc] initWithMask:@"cloud4"];
	clouds[3].enterAnchor = CGPointMake(14,260);
	clouds[3].exitAnchor = CGPointMake(603,193);
	clouds[3].piti_count = 3;
	clouds[3].piti_anchors = malloc(sizeof(CGPoint)*clouds[3].piti_count);
		clouds[3].piti_anchors[0] = CGPointMake(530,200);
		clouds[3].piti_anchors[1] = CGPointMake(185,280);
		clouds[3].piti_anchors[2] = CGPointMake(215,15);
	
	clouds[4].imageName = @"cloud5.png";
	clouds[4].mask = [[MaskFile alloc] initWithMask:@"cloud5"];
	clouds[4].enterAnchor = CGPointMake(9,343);
	clouds[4].exitAnchor = CGPointMake(1205,240);
	clouds[4].piti_count = 3;
	clouds[4].piti_anchors = malloc(sizeof(CGPoint)*clouds[4].piti_count);
		clouds[4].piti_anchors[0] = CGPointMake(305,270);
		clouds[4].piti_anchors[1] = CGPointMake(1155,240);
		clouds[4].piti_anchors[2] = CGPointMake(435,10);
	
	clouds[5].imageName = @"cloud6.png";
	clouds[5].mask = [[MaskFile alloc] initWithMask:@"cloud6"];
	clouds[5].enterAnchor = CGPointMake(10,113);
	clouds[5].exitAnchor = CGPointMake(706,97);
	clouds[5].piti_count = 1;
	clouds[5].piti_anchors = malloc(sizeof(CGPoint)*clouds[5].piti_count);
		clouds[5].piti_anchors[0] = CGPointMake(430,6);
	
	clouds[6].imageName = @"cloud7.png";
	clouds[6].mask = [[MaskFile alloc] initWithMask:@"cloud7"];
	clouds[6].enterAnchor = CGPointMake(20,452);
	clouds[6].exitAnchor = CGPointMake(1260,430);
	clouds[6].piti_count = 1;
	clouds[6].piti_anchors = malloc(sizeof(CGPoint)*clouds[6].piti_count);
		clouds[6].piti_anchors[0] = CGPointMake(1180,420);
	
	clouds[7].imageName = @"cloud8.png";
	clouds[7].mask = [[MaskFile alloc] initWithMask:@"cloud8"];
	clouds[7].enterAnchor = CGPointMake(50,390);
	clouds[7].exitAnchor = CGPointMake(1550,430);
	clouds[7].piti_count = 3;
	clouds[7].piti_anchors = malloc(sizeof(CGPoint)*clouds[7].piti_count);
		clouds[7].piti_anchors[0] = CGPointMake(520,270);
		clouds[7].piti_anchors[1] = CGPointMake(800,270);
		clouds[7].piti_anchors[2] = CGPointMake(1610,180);
	
	clouds[8].imageName = @"cloud9.png";
	clouds[8].mask = [[MaskFile alloc] initWithMask:@"cloud9"];
	clouds[8].enterAnchor = CGPointMake(60,480);
	clouds[8].exitAnchor = CGPointMake(1600,440);
	clouds[8].piti_count = 4;
	clouds[8].piti_anchors = malloc(sizeof(CGPoint)*clouds[8].piti_count);
		clouds[8].piti_anchors[0] = CGPointMake(710,300);
		clouds[8].piti_anchors[1] = CGPointMake(1080,405);
		clouds[8].piti_anchors[2] = CGPointMake(1510,444);
		clouds[8].piti_anchors[3] = CGPointMake(1470,70);
	
	//
	// Note sur la gestion mémoire:
	//
	// Les allocations mémoire effectuées par cette méthode (malloc()) ne sont 
	// jamais liberées. Cependant, en pratique cette fonction n'est appelée
	// qu'une fois à chaque lancement. En outre, ces variables sont conservés 
	// tout au long du jeu. Libérer l'espace mémoire alloué n'aurait de sens 
	// qu'à l'arrêt de l'application. Et dans ce cas, iOS se charge déjà de
	// désalouer automatiquement l'ensemble de la mémoire utilisée par notre 
	// application.
	//
	// Il n'y a donc pas de free() correspondant, ailleurs dans le programme.
	//
}

//
// Crée une instance en fonction d'un modèle de nuage donné
//
- (Platform*) initWithCloud:(CloudModel*)cloud_model InView:(UIView*)parent {
	[super initWithFile:cloud_model->imageName InView:parent AtLocation:CGPointMake(0,0)];
	
	// Initialisation
	cloud = cloud_model;
	self.alpha = PLATFORM_ALPHA;
	jumpTutorialDisplayed = NO;
	
	// Initialisation du Piti, si la plateforme doit en avoir un
	if(cloud_model->piti_count > 0 && (PITI_CAN_SPAWN(GAME_CONTROLLER.runScore) || GAME_CONTROLLER.gameState == menu)) {
		piti = malloc(sizeof(Piti));
		
		// On sélectionne un point de pop aléatoire parmis les disponibles
		CGPoint piti_anchor = cloud_model->piti_anchors[(arc4random()%(cloud_model->piti_count))];
		
		// Création du Sprite du Piti
		piti->sprite = [[Sprite alloc] initWithFile:@"piti_1.png" InView:nil AtLocation:CGPointMake(self.origin.x+piti_anchor.x,self.origin.y+piti_anchor.y)];
		[self.superview insertSubview:piti->sprite belowSubview:self];
		
		// Le piti est décalé pour que le point de pop soit placé entre ses deux pieds
		[piti->sprite moveAlong:CGVectorMake(-piti->sprite.image.size.width/2,-piti->sprite.image.size.height)];
		
		// Déplacement lié à celui de la plateforme
		[piti->sprite linkWith:self];
		
		// Animation
		piti->sprite.animationImages = PITI_ANIM;
		piti->sprite.animationDuration = 0.35;
		[piti->sprite startAnimating];
		
		piti->soundPlayed = NO;
		piti->dashed = NO;
	} else {
		// if(platform.piti && ...) -> if(NULL && ...) -> FALSE
		piti = NULL;
	}
	
	return self;
}

//
// Constructeur "façade" se chargeant d'appeler le vrai constructeur avec un nuage
// aléatoire.
//
- (Platform*) initWithRandomCloudInView:(UIView*)parent {
	static int last_platform = 1; // La variable statique n'est pas réinitialisée entre les appels
	int platform;
	
	// On cherche une plateforme aléatoire qui n'est pas celle que l'on a générée
	// la dernière fois. Cette boucle ne devrait faire qu'un nombre très faible
	// d'itération.
	do {
		platform = (arc4random()%clouds_count);
	} while (platform == last_platform);
	last_platform = platform;
	
	// On transmet le CloudModel sélectionné au "vrai" contructeur
	return [self initWithCloud:&clouds[platform] InView:parent];
}

//
// De même que le contructeur aléatoire, sauf que celui-ci ne fabriquera que
// la plateforme 0.
//
- (Platform*) initWithDefaultCloudInView:(UIView*)parent {
	return [self initWithCloud:&clouds[0] InView:parent];
}

// Interface au CloudModel
- (MaskFile*) mask { return cloud->mask; }
- (CGPoint) enterAnchor { return cloud->enterAnchor; }
- (CGPoint) exitAnchor { return cloud->exitAnchor; }

//
// Aligne la plateforme à côté d'une autre, les lies entre-elles, selon les
// points d'entrée et de sortie définis. (Surcharge de Sprite)
//
- (void) placeNextTo:(Platform *)sprite Spacing:(int)spacing Autolink:(BOOL)autolink {
	[self moveTo:CGPointMake(sprite.origin.x+sprite.frame.size.width+spacing,
							 (sprite.origin.y+sprite.cloud->exitAnchor.y-cloud->enterAnchor.y))];
	if(autolink)
		[self linkWith:sprite];
}

//
// Permet la suppression anticipée du Piti de la plateforme
//
- (void) releasePiti {
	// Puisque c'est un pointeur C et non un objet Obj-C, des précautions
	// doivent être prises.
	if(piti) {			
		[piti->sprite removeFromSuperview];
		[piti->sprite release];
		free(piti);
		piti = NULL;
	}
}

- (void) dealloc {
	[self releasePiti];
	[super dealloc];
}

@end
