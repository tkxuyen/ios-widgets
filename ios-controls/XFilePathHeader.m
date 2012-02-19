//
//  XFilePathHeader.m
//  bonjourFTP
//
//  Created by tran khai xuyen on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFilePathHeader.h"

@implementation XFilePathHeader

@synthesize _rootIcon;
@synthesize _rootDir;
@synthesize _curDir;
@synthesize _dirSet;
@synthesize _notificationObject;

// ----------------------------------------------------------------------------------------------------------
// create the gradient background and the root icon
// ----------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame notifyObject:(id)sender
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _rootDir = nil;
        _curDir = nil;
        _hightlightIndex = -2;
        _notificationObject = sender;
        _dirSet = [[NSMutableArray alloc] init];

        UIImage* image = [UIImage imageNamed: @"XFilePathHeader_icon.png"];
        _rootIcon = [[UIImageView alloc] initWithImage: image];

        _rootIcon.frame = CGRectMake(4, (frame.size.height - 19) / 2, 19, 19);
        [self addSubview: _rootIcon];
    }
    return self;
}

// ----------------------------------------------------------------------------------------------------------
// custom drawing code here
// ----------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    [self drawBackground];
    [self drawArrow : CGPointMake(24, 0)];
    
    BOOL hightlightDrawn = FALSE;
    CGPoint p = CGPointMake(36, 3);
    
    if (_hightlightIndex == -1)
    {
        [self drawHightlight: CGRectMake(-12, 0, 36, self.frame.size.height)];        
        hightlightDrawn = TRUE;
    }
    for (int i = [_dirSet count] - 1; i >= 0; i --)
    {
        NSMutableDictionary* entry = [_dirSet objectAtIndex: i];
        NSString* text = [entry objectForKey: @"text"];
        
        CGSize s = [self drawText : text : FALSE : p];
        if (hightlightDrawn == FALSE && _hightlightIndex  == i)
        {
            [self drawHightlight: CGRectMake(p.x - 12, 0, s.width, self.frame.size.height)];
            [self drawText : text : TRUE : p];        
            hightlightDrawn = TRUE;
        }
        if (hightlightDrawn == FALSE && i == 0)
        {
            [self drawHightlight: CGRectMake(p.x - 12, 0, s.width, self.frame.size.height)];
            [self drawText : text : TRUE : p];
        } 
        p.x += s.width;        
    }
}

// ----------------------------------------------------------------------------------------------------------
// draw the gradient background
// ----------------------------------------------------------------------------------------------------------
- (void) drawBackground 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSaveGState(context);
    
    CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
    CGFloat components [16] = 
    {
        1, 1, 1, 1.0,           // Start color
        0.9, 0.9, 0.9, 1.0,	// Mid color
        0.88, 0.88, 0.88, 1.0,     // Mid color        
        0.78, 0.78, 0.78, 1.0      // End color
    };
    CGGradientRef gradientFill = CGGradientCreateWithColorComponents (colorSpace, components, locations, 4);
    
    // setup gradient points
    CGPoint startPoint, endPoint;
    startPoint.x = self.frame.size.width / 2;
    startPoint.y = 0;
    endPoint.x = self.frame.size.width / 2;
    endPoint.y = self.frame.size.height;    
    
    CGContextDrawLinearGradient(context, gradientFill, startPoint, endPoint, 0);
    CGContextRestoreGState(context);    

    CFRelease(gradientFill);    
    CFRelease(colorSpace);    
}

// ----------------------------------------------------------------------------------------------------------
// draw the directory hierachy separator arrow >
// ----------------------------------------------------------------------------------------------------------
- (void) drawArrow : (CGPoint) p
{
    float stepx = 8;
    float stepy = (self.frame.size.height) / 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextSaveGState(context);
    
    CGFloat comp [] = {0.6, 0.6, 0.6, 1};
    CGColorRef color = CGColorCreate(colorspace, comp);
    
    CGContextSetLineWidth(context, 1.0);

    CGContextSetStrokeColorWithColor(context, color);
    CGContextMoveToPoint(context, p.x, p.y);
    CGContextAddLineToPoint(context, p.x + stepx, p.y + stepy);
    CGContextAddLineToPoint(context, p.x, p.y + stepy * 2);
    CGContextStrokePath(context);
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

// ----------------------------------------------------------------------------------------------------------
// draw one text entry plus the arrow
// ----------------------------------------------------------------------------------------------------------
- (CGSize) drawText : (NSString*) text : (BOOL) hightlight : (CGPoint) p
{   
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGSize size = [text sizeWithFont: XFILEPATHHEADER_DEFAULT_FONT(14) forWidth: [self getMaxTabWidth] lineBreakMode: UILineBreakModeTailTruncation];
    
    if (hightlight)
    {
        CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.0f alpha: 0.6f] CGColor]);
        [text drawAtPoint: CGPointMake(p.x - 1, (self.frame.size.height - size.height) / 2 - 2) forWidth: [self getMaxTabWidth] withFont: XFILEPATHHEADER_DEFAULT_FONT(14) lineBreakMode: UILineBreakModeTailTruncation];
        
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);      
        [text drawAtPoint: CGPointMake(p.x, (self.frame.size.height - size.height) / 2 - 1) forWidth: [self getMaxTabWidth] withFont: XFILEPATHHEADER_DEFAULT_FONT(14) lineBreakMode: UILineBreakModeTailTruncation];        
    } else
    {
        CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:1.0f alpha: 0.6f] CGColor]);
        [text drawAtPoint: CGPointMake(p.x + 1, (self.frame.size.height - size.height) / 2) forWidth: [self getMaxTabWidth] withFont: XFILEPATHHEADER_DEFAULT_FONT(14) lineBreakMode: UILineBreakModeTailTruncation];
        
        CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);      
        [text drawAtPoint: CGPointMake(p.x, (self.frame.size.height - size.height) / 2 - 1) forWidth: [self getMaxTabWidth] withFont: XFILEPATHHEADER_DEFAULT_FONT(14) lineBreakMode: UILineBreakModeTailTruncation];
        
    }

    [self drawArrow : CGPointMake(p.x + size.width, 0)];
    return CGSizeMake(size.width + 12, 0);
}

// ----------------------------------------------------------------------------------------------------------
// draw one text entry background in highlight mode
// ----------------------------------------------------------------------------------------------------------
- (void) drawHightlight : (CGRect) r
{
    float stepx = 8;
    float stepy = (self.frame.size.height - 2) / 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSaveGState(context);

    CGContextMoveToPoint (context, r.origin.x, r.origin.y);
    CGContextAddLineToPoint(context, r.origin.x + r.size.width, r.origin.y); 
    CGContextAddLineToPoint(context, r.origin.x + r.size.width + stepx, r.origin.y + stepy); 
    CGContextAddLineToPoint(context, r.origin.x + r.size.width, r.origin.y + r.size.height);
    CGContextAddLineToPoint(context, r.origin.x, r.origin.y + r.size.height);
    CGContextAddLineToPoint(context, r.origin.x + stepx, r.origin.y + r.size.height - stepy);
    CGContextAddLineToPoint (context, r.origin.x, r.origin.y);
    CGContextClosePath(context);
    CGContextClip(context);

    CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
    CGFloat components [16] = 
    {
        0.75, 0.85, 0.95, 1.0,      // Start color
        0.45, 0.67, 0.91, 1.0,      // Mid color
        0.37, 0.63, 0.89, 1.0,      // Mid color        
        0.24, 0.54, 0.85, 1.0       // End color
    };
    CGGradientRef gradientFill = CGGradientCreateWithColorComponents (colorSpace, components, locations, 4);
    
    // setup gradient points
    CGPoint startPoint, endPoint;
    startPoint.x = r.origin.x + r.size.width / 2;
    startPoint.y = 0;
    endPoint.x = r.origin.x + r.size.width / 2;
    endPoint.y = self.frame.size.height;    
    
    CGContextDrawLinearGradient(context, gradientFill, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);
    
    CFRelease(gradientFill);
	CFRelease(colorSpace);    
}

// ----------------------------------------------------------------------------------------------------------
// set the root directory, the currentDirectory would be compared to this one
// to perform hierarchy browsing
// ----------------------------------------------------------------------------------------------------------
- (void) setRootDirectory:(NSString *)dir
{
    if (nil != _rootDir)
    {
        [_rootDir release];
        _rootDir = nil;
    }
    _rootDir = [[NSString alloc] initWithString: dir];
}

// ----------------------------------------------------------------------------------------------------------
// the current directory as compared to root directory
// ----------------------------------------------------------------------------------------------------------
- (void) setCurrentDirectory:(NSString *)dir
{
    if (nil != _curDir)
    {
        [_curDir release];
        _curDir = nil;
    }
    _curDir = [[NSString alloc] initWithString: dir]; 

    [_dirSet removeAllObjects];
    if ([_curDir length] > [_rootDir length])
    {
        
        NSString* name = nil;
        NSString* path = _curDir;
        float width = 0;
        do 
        {        
            name = [path lastPathComponent];
            path = [path stringByDeletingLastPathComponent];
            
            // FIXME: more graceful maximum width checking here
            CGSize size = [name sizeWithFont: XFILEPATHHEADER_DEFAULT_FONT(14) forWidth: [self getMaxTabWidth] lineBreakMode: UILineBreakModeTailTruncation];
            width += size.width + 12;
            if (width >= self.frame.size.width - 50)
            {
                NSMutableDictionary* entry = [[NSMutableDictionary alloc] init];
                [entry setObject: @"..." forKey: @"text"];
                [entry setObject: @"..." forKey: @"path"];
                
                [_dirSet addObject: entry];
                
                [entry release];
                 break;
            } else
            {
                NSMutableDictionary* entry = [[NSMutableDictionary alloc] init];
                [entry setObject: name forKey: @"text"];
                [entry setObject: [NSString stringWithFormat: @"%@/%@", path, name] forKey: @"path"];
                
                [_dirSet addObject: entry];
                [entry release];
            }
        } while ( [path length] > [_rootDir length]);
    }
    [self setNeedsDisplay];    
}

// ----------------------------------------------------------------------------------------------------------
// touch begin => highlight the entry under touch point
// ----------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // user click on root
    if (point.x < 36)
    {
        _hightlightIndex = -1;
        [self setNeedsDisplay];          
        return;
    }
    CGPoint p = CGPointMake(36, 3);
    for (int i = [_dirSet count] - 1; i >= 0; i --)
    {
        NSMutableDictionary* entry = [_dirSet objectAtIndex: i];
        NSString* text = [entry objectForKey: @"text"];
        CGSize size = [text sizeWithFont: XFILEPATHHEADER_DEFAULT_FONT(14) forWidth: [self getMaxTabWidth] lineBreakMode: UILineBreakModeTailTruncation];
        
        if (p.x < point.x && point.x < p.x + size.width)
        {
            _hightlightIndex = i;
            [self setNeedsDisplay];  
            
            break;
        } 
        p.x += size.width + 12;                
    }
}

// ----------------------------------------------------------------------------------------------------------
// limit the size (width) of each text entry
// ----------------------------------------------------------------------------------------------------------
- (int) getMaxTabWidth
{
    return self.frame.size.width / 4;
}

// ----------------------------------------------------------------------------------------------------------
// touch end => change directory to the entry under touch point
// notify parent on the change
// ----------------------------------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_hightlightIndex == -1)
    {
        if ([_notificationObject respondsToSelector:@selector(directoryChanged:)]) 
        {
            [_notificationObject directoryChanged : _rootDir]; 
        }        
    }
    if (_hightlightIndex > -1)
    {
        NSMutableDictionary* entry = [_dirSet objectAtIndex: _hightlightIndex];
        if ( ! [[entry objectForKey: @"path"] isEqualToString: @"..."])
        {
            if ([_notificationObject respondsToSelector:@selector(directoryChanged:)]) 
            {
                [_notificationObject directoryChanged : [entry objectForKey: @"path"]]; 
            }
        }
    }
    _hightlightIndex = -2;    
    [self setNeedsDisplay];    
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _hightlightIndex = -2;        
    [self setNeedsDisplay];    
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void) dealloc
{
    if (nil != _rootDir) [_rootDir release];
    if (nil != _curDir) [_curDir release];
    [_dirSet removeAllObjects];
    [_dirSet release];
    [_rootIcon release];
    
    [super release];
}

@end
