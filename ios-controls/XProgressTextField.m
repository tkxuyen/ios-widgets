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
    
    // create the background image
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

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
    CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
    CGFloat components [16] = 
    {
        0.75, 0.85, 0.95, 1.0,      // Start color
        0.45, 0.67, 0.91, 1.0,      // Mid color
        0.37, 0.63, 0.89, 1.0,      // Mid color        
        0.24, 0.54, 0.85, 1.0       // End color
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, 4);
    
    // setup gradient points
    CGPoint startPoint, endPoint;
    startPoint.x = self.frame.size.width / 2;
    startPoint.y = 0;
    endPoint.x = self.frame.size.width / 2;
    endPoint.y = self.frame.size.height;    

	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
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
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y + 3, bounds.size.width - 20, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds 
{
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y + 3, bounds.size.width - 20, bounds.size.height);
    return inset;
}

@end