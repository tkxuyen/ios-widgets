//
//  XProgressTextField.m
//  NotesPlus
//
//  This class subclass UITextField to add the ability to display a progress bar 
//  (Used for WebView's address textbox)
//
//  Created by tran khai xuyen on 2/18/12.
//

#import "XProgressTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation XProgressTextField

@synthesize _progressCount;

//--------------------------------------------------------------------------------
// set the progressbar's progress, draw a round-rect bar to indicate progress
//--------------------------------------------------------------------------------
- (void)setProgress:(CGFloat) prog
{
    if (prog < 0.0 || prog > 1.0 ) return;
    
    _progressCount = prog;
    
    CGFloat radius = self.layer.cornerRadius;    
    CGRect rect = self.bounds;
    CGRect progressRect = CGRectZero;
    CGSize progressSize = CGSizeMake(_progressCount * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    progressRect.size = progressSize;
    progressRect = CGRectInset(progressRect, 1, 1);
    UIColor* progressColor = [UIColor colorWithRed: 181.0f/255.0f green: 213.0f/255.0f blue: 255.0f alpha: 1];
    
    // create the background image
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // clear the whole rounded-rect background first
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);

    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor); 
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);    
    CGContextFillPath(context);
    
    // draw the rounded-rect progress bar
    minx = CGRectGetMinX(progressRect);
    midx = CGRectGetMidX(progressRect);
    maxx = CGRectGetMaxX(progressRect);
    miny = CGRectGetMinY(progressRect);
    midy = CGRectGetMidY(progressRect);
    maxy = CGRectGetMaxY(progressRect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);    
        
    // draw the rounded-rect progress bar
	CGContextClip(context);
	// background gradient, the Safari style
	CGFloat components[12] = 
    { 
        191.0f/255.0f, 231.0f/255.0f, 255.0f/255.0f, 1.0f, 
        112.0f/255.0f, 202.0f/255.0f, 238.0f/255.0f, 1.0f,
        191.0f/255.0f, 231.0f/255.0f, 255.0f/255.0f, 1.0f, 
	};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();    
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 3);
	CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, progressRect.size.height), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [super setBackground:image];
}

//--------------------------------------------------------------------------------
// use our custom background instead
//--------------------------------------------------------------------------------
- (void)setBackground:(UIImage *)background 
{
}

- (UIImage *)background
{
    return nil;
}

//--------------------------------------------------------------------------------
// set the text left and right margin so that text won't overlap with the rounded
// corner and the clearButton and refreshButton on the right
//--------------------------------------------------------------------------------
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds 
{
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
    return inset;
}

@end