//
//  Toupoutou Attack !
//  Bastien Clément, Sacha Bron, TM 2010, Gymnase du Bugnon - Site de Sévelin
//

#import "CircleView.h"

@implementation CircleView

@synthesize lineWidth, color;

//
// Initialise la CircleView
//
- (CircleView*) initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		lineWidth = 2;
		color = [[UIColor blackColor] CGColor];
	}
	return self;
}

//
// DrawRect dessine un cercle...
// Appelée automatiquement par le framework d'Apple
//
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(ctx, color);
	CGContextSetLineWidth(ctx, lineWidth);
	CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2-lineWidth, 0, M_PI*2, 0);
	CGContextStrokePath(ctx);
}

@end
