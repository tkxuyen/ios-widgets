//
//  XFilePathHeader.m
//  bonjourFTP
//
//  Created by tran khai xuyen on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "XSegmentedControl.h"

#define kCornerRadius  3.0f

@implementation XSegmentedControl

@synthesize _items;
@synthesize _font;
@synthesize _selectedItemColor;
@synthesize _unselectedItemColor;
@synthesize _selectedSegmentIndex;

#pragma mark - Object life cycle
// ----------------------------------------------------------------------------------------------------------
// just an init function, to add segment, use the add functions below
// ----------------------------------------------------------------------------------------------------------
- (id)initWithParent: (id) parent
{
	self = [super init];
	if (self) 
    {
        _parent = parent;
        _selectedSegmentIndex = 0;
        _items = [[NSMutableArray alloc] init];
        _font = [UIFont boldSystemFontOfSize:14.0f];
        _selectedItemColor = [UIColor whiteColor];
        _unselectedItemColor = [UIColor grayColor];
	}
	return self;
}

// ----------------------------------------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_items release];
    [_font release];
    [_selectedItemColor release];
    [_unselectedItemColor release];
	
    [super dealloc];
}

#pragma mark - Custom accessors
// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)setFont:(UIFont *)aFont
{
	if (_font != aFont) 
    {
		[_font release];
		_font = [aFont retain];
		
		[self setNeedsDisplay];
	}
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)setSelectedItemColor:(UIColor *)aColor
{
	if (aColor != _selectedItemColor) 
    {
		[_selectedItemColor release];
		_selectedItemColor = [aColor retain];
		
		[self setNeedsDisplay];
	}
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)setUnselectedItemColor:(UIColor *)aColor
{
	if (aColor != _unselectedItemColor) 
    {
		[_unselectedItemColor release];
		_unselectedItemColor = [aColor retain];
		
		[self setNeedsDisplay];
	}
}

#pragma mark - Overridden UISegmentedControl methods

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
{
	for (UIView *subView in self.subviews) 
    {
		[subView removeFromSuperview];
	}
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    // TODO: support for segment custom width
	CGSize itemSize = CGSizeMake(round(rect.size.width / [_items count]), rect.size.height);

	CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextSaveGState(c);
	
	// Rect with radius, will be used to clip the entire view
	CGFloat minx = CGRectGetMinX(rect) + 1, midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
	CGFloat miny = CGRectGetMinY(rect) + 1, midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
	
	// Path are drawn starting from the middle of a pixel, in order to avoid an antialiased line
	CGContextMoveToPoint(c, minx - .5, midy - .5);
	CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
	CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
	CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, kCornerRadius);
	CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
	CGContextClosePath(c);
	
	CGContextClip(c);
	
	// Background gradient for non selected items
	CGFloat components[8] = 
    { 
		 255/255.0, 255/255.0, 255/255.0, 1.0, 
		 200/255.0, 200/255.0, 200/255.0, 1.0
	};
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
	CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
	
	for (int i = 0; i < [_items count]; i++) 
    {
		NSMutableArray* item = [_items objectAtIndex:i];
		BOOL isLeftItem  = i == 0;
		BOOL isRightItem = i == [_items count] - 1;
		
		CGRect itemBgRect = CGRectMake(i * itemSize.width, 0.0f, itemSize.width, rect.size.height);
		if (i == _selectedSegmentIndex) 
        {
			// -- Selected item --
			// Background gradient is composed of two gradients, one on the top, another rounded on the bottom
			CGContextSaveGState(c);
			CGContextClipToRect(c, itemBgRect);
			
			float factor  = 1.22f; // multiplier applied to the first color of the gradient to obtain the second
			float mfactor = 1.25f; // multiplier applied to the color of the first gradient to obtain the bottom gradient
			int red = 55, green = 111, blue = 214; // default blue color
			
			if (self.tintColor != nil) 
            {
				const CGFloat *components = CGColorGetComponents(self.tintColor.CGColor);
				size_t numberOfComponents = CGColorGetNumberOfComponents(self.tintColor.CGColor);
				
				if (numberOfComponents == 2) 
                {
					red = green = blue = components[0] * 255;
				} else if (numberOfComponents == 4) 
                {
					red   = components[0] * 255;
					green = components[1] * 255;
					blue  = components[2] * 255;
				}
			}
			// Top gradient
			CGFloat top_components[16] = 
            { 
				red / 255.0f,         green / 255.0f,         blue/255.0f          , 1.0f,
				(red*mfactor)/255.0f, (green*mfactor)/255.0f, (blue*mfactor)/255.0f, 1.0f
			};
			CGFloat top_locations[2] = 
            {
				0.0f, .75f
			};
			
			CGGradientRef top_gradient = CGGradientCreateWithColorComponents(colorSpace, top_components, top_locations, 2);
			CGContextDrawLinearGradient(c, top_gradient, itemBgRect.origin, CGPointMake(itemBgRect.origin.x, 
													itemBgRect.size.height), kCGGradientDrawsBeforeStartLocation);
			CFRelease(top_gradient);
			CGContextRestoreGState(c);
			
			// Bottom gradient
			// It's clipped in a rect with the left corners rounded if segment is the first,
			// right corners rounded if segment is the last, no rounded corners for the segments inbetween
			CGRect bottomGradientRect = CGRectMake(itemBgRect.origin.x, 
												   itemBgRect.origin.y + round(itemBgRect.size.height / 2), 
												   itemBgRect.size.width, 
												   round(itemBgRect.size.height / 2));
			
			CGFloat gradient_minx = CGRectGetMinX(bottomGradientRect) + 1;
			CGFloat gradient_midx = CGRectGetMidX(bottomGradientRect);
			CGFloat gradient_maxx = CGRectGetMaxX(bottomGradientRect);
			CGFloat gradient_miny = CGRectGetMinY(bottomGradientRect) + 1;
			CGFloat gradient_midy = CGRectGetMidY(bottomGradientRect);
			CGFloat gradient_maxy = CGRectGetMaxY(bottomGradientRect);
			
			CGContextSaveGState(c);
			if (isLeftItem) 
            {
				CGContextMoveToPoint(c, gradient_minx - .5f, gradient_midy - .5f);
			} else 
            {
				CGContextMoveToPoint(c, gradient_minx - .5f, gradient_miny - .5f);
			}
			
			CGContextAddArcToPoint(c, gradient_minx - .5f, gradient_miny - .5f, gradient_midx - .5f, gradient_miny - .5f, kCornerRadius);
			
			if (isRightItem) 
            {
				CGContextAddArcToPoint(c, gradient_maxx - .5f, gradient_miny - .5f, gradient_maxx - .5f, gradient_midy - .5f, kCornerRadius);
				CGContextAddArcToPoint(c, gradient_maxx - .5f, gradient_maxy - .5f, gradient_midx - .5f, gradient_maxy - .5f, kCornerRadius);
			} else 
            {
				CGContextAddLineToPoint(c, gradient_maxx, gradient_miny);
				CGContextAddLineToPoint(c, gradient_maxx, gradient_maxy);
			}
			if (isLeftItem) 
            {
				CGContextAddArcToPoint(c, gradient_minx - .5f, gradient_maxy - .5f, gradient_minx - .5f, gradient_midy - .5f, kCornerRadius);
			} else 
            {
				CGContextAddLineToPoint(c, gradient_minx, gradient_maxy);
			}
			CGContextClosePath(c);
			
			CGContextClip(c);
			CGFloat bottom_components[16] = 
            {
				(red*factor)        /255.0f, (green*factor)        /255.0f, (blue*factor)/255.0f,         1.0f,
				(red*factor*mfactor)/255.0f, (green*factor*mfactor)/255.0f, (blue*factor*mfactor)/255.0f, 1.0f
			};
			
			CGFloat bottom_locations[2] = 
            {
				0.0f, 1.0f
			};
			
			CGGradientRef bottom_gradient = CGGradientCreateWithColorComponents(colorSpace, bottom_components, bottom_locations, 2);
			CGContextDrawLinearGradient(c, bottom_gradient, bottomGradientRect.origin, CGPointMake(bottomGradientRect.origin.x, 
													bottomGradientRect.origin.y + bottomGradientRect.size.height), kCGGradientDrawsBeforeStartLocation);
			CFRelease(bottom_gradient);
			CGContextRestoreGState(c);

			// Inner shadow
			int blendMode = kCGBlendModeDarken;
			
			// Right and left inner shadow 
			CGContextSaveGState(c);
			CGContextSetBlendMode(c, blendMode);
			CGContextClipToRect(c, itemBgRect);
			
			CGFloat inner_shadow_components[16] = 
            {
				0.0f, 0.0f, 0.0f, isLeftItem ? 0.0f : .25f,
				0.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 0.0f, isRightItem ? 0.0f : .25f
			};
			
			CGFloat locations[4] = 
            {
				0.0f, .05f, .95f, 1.0f
			};
			CGGradientRef inner_shadow_gradient = CGGradientCreateWithColorComponents(colorSpace, inner_shadow_components, locations, 4);
			CGContextDrawLinearGradient(c, inner_shadow_gradient, itemBgRect.origin, 
										CGPointMake(itemBgRect.origin.x + itemBgRect.size.width, itemBgRect.origin.y), kCGGradientDrawsAfterEndLocation);
			CFRelease(inner_shadow_gradient);
			CGContextRestoreGState(c);
			
			// Top inner shadow 
			CGContextSaveGState(c);
			CGContextSetBlendMode(c, blendMode);
			CGContextClipToRect(c, itemBgRect);
			CGFloat top_inner_shadow_components[8] = 
            { 
				0.0f, 0.0f, 0.0f, 0.25f,
				0.0f, 0.0f, 0.0f, 0.0f
			};
			CGFloat top_inner_shadow_locations[2] = 
            {
				0.0f, .10f
			};
			CGGradientRef top_inner_shadow_gradient = CGGradientCreateWithColorComponents(colorSpace, top_inner_shadow_components, top_inner_shadow_locations, 2);
			CGContextDrawLinearGradient(c, top_inner_shadow_gradient, itemBgRect.origin, 
										CGPointMake(itemBgRect.origin.x, itemBgRect.size.height), 
										kCGGradientDrawsAfterEndLocation);
			CFRelease(top_inner_shadow_gradient);
			CGContextRestoreGState(c);
		}
		CGFloat segmentSize = 0.0f;
        for (int j = 0; j < [item count]; j ++)
        {
            id it = [item objectAtIndex: j];
            
            if ([it isKindOfClass:[UIImage class]]) 
            {
                UIImage* image = (UIImage*) it;
                segmentSize += CGImageGetWidth([image CGImage]) / [image scale];
            }  else if ([it isKindOfClass:[NSString class]]) 
            {
                NSString* string = (NSString*) it;
                CGSize stringSize = [string sizeWithFont: _font];
                segmentSize += stringSize.width;                
            }
        }
        segmentSize += ([item count] - 1) * TITLE_IMAGE_PADDING;                                        
        
        CGFloat xStartPos = round(i * itemSize.width + (itemSize.width - segmentSize) / 2);
		for (int j = 0; j < [item count]; j ++)
        {
            id it = [item objectAtIndex: j];
            CGFloat step = 0;
            
            if ([it isKindOfClass:[UIImage class]]) 
            {
                UIImage* image = (UIImage*)it;
                
                CGImageRef imageRef = [image CGImage];
                CGFloat imageScale  = [image scale];
                CGFloat imageWidth  = CGImageGetWidth(imageRef)  / imageScale;
                CGFloat imageHeight = CGImageGetHeight(imageRef) / imageScale;
			
                CGRect imageRect = CGRectMake(xStartPos, round((itemSize.height - imageHeight) / 2), imageWidth, imageHeight);
			
                if (i == _selectedSegmentIndex) 
                {
                    CGContextSaveGState(c);
                    CGContextTranslateCTM(c, 0, rect.size.height);
                    CGContextScaleCTM(c, 1.0, -1.0);  
				
                    CGContextClipToMask(c, imageRect, imageRef);
                    CGContextSetFillColorWithColor(c, [_selectedItemColor CGColor]);
				
                    CGContextFillRect(c, imageRect);
                    CGContextRestoreGState(c);
                } 
                else 
                {
                    // 1px shadow
                    CGContextSaveGState(c);
                    CGContextTranslateCTM(c, 0, itemBgRect.size.height);  
                    CGContextScaleCTM(c, 1.0, -1.0);  
				
                    CGContextClipToMask(c, CGRectOffset(imageRect, 0, -1), imageRef);
                    CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
                    CGContextFillRect(c, CGRectOffset(imageRect, 0, -1));
                    CGContextRestoreGState(c);
				
				// Image drawn as a mask
                    CGContextSaveGState(c);
                    CGContextTranslateCTM(c, 0, itemBgRect.size.height);  
                    CGContextScaleCTM(c, 1.0, -1.0);  
				
                    CGContextClipToMask(c, imageRect, imageRef);
                    CGContextSetFillColorWithColor(c, [_unselectedItemColor CGColor]);
                    CGContextFillRect(c, imageRect);
                    CGContextRestoreGState(c);
                }
                step = imageWidth;
            }
            else if ([it isKindOfClass:[NSString class]]) 
            {
                NSString* string = (NSString*) it;
                CGSize stringSize = [string sizeWithFont: _font];
                CGRect stringRect = CGRectMake(xStartPos, (itemSize.height - stringSize.height) / 2, stringSize.width, stringSize.height);
			
                if (_selectedSegmentIndex == i) 
                {
                    [[UIColor colorWithWhite:0.0f alpha:0.6f] setFill];
                    [string drawInRect:CGRectOffset(stringRect, -1.0f, -1.0f) withFont: _font];
                    [_selectedItemColor setFill];	
                    [_selectedItemColor setStroke];	
                    [string drawInRect:stringRect withFont: _font];
                } else 
                {
                    [[UIColor colorWithWhite:1.0f alpha:0.6f] setFill];
                    [string drawInRect:CGRectOffset(stringRect, 1.0f, 1.0f) withFont: _font];
                    [_unselectedItemColor setFill];
                    [string drawInRect:stringRect withFont: _font];
                }
                step = stringSize.width;
            }
            xStartPos += step;
            xStartPos += TITLE_IMAGE_PADDING;
		}
		
		// Separator
		if (i > 0 && i - 1 != _selectedSegmentIndex && i != _selectedSegmentIndex) 
        {
			CGContextSaveGState(c);
			
			CGContextMoveToPoint(c, itemBgRect.origin.x + .5, itemBgRect.origin.y);
			CGContextAddLineToPoint(c, itemBgRect.origin.x + .5, itemBgRect.size.height);
			
			CGContextSetLineWidth(c, .5f);
			CGContextSetStrokeColorWithColor(c, [UIColor colorWithWhite:120/255.0 alpha:1.0].CGColor);
			CGContextStrokePath(c);
			
			CGContextRestoreGState(c);
		}
		
	}
	CGContextRestoreGState(c);
	
	if (self.segmentedControlStyle ==  UISegmentedControlStyleBordered) {
		CGContextMoveToPoint(c, minx - .5, midy - .5);
		CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, kCornerRadius);
		CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
		CGContextClosePath(c);
		
		CGContextSetStrokeColorWithColor(c,[UIColor blackColor].CGColor);
		CGContextSetLineWidth(c, 1.0f);
		CGContextStrokePath(c);
	} else 
    {
		CGContextSaveGState(c);

		CGRect bottomHalfRect = CGRectMake(0, rect.size.height - kCornerRadius + 7, rect.size.width, kCornerRadius);
		CGContextClearRect(c, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
		CGContextClipToRect(c, bottomHalfRect);
		
		CGContextMoveToPoint(c, minx + .5, midy - .5);
		CGContextAddArcToPoint(c, minx + .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, kCornerRadius);
		CGContextAddArcToPoint(c, minx + .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
		CGContextClosePath(c);
		
		CGContextSetBlendMode(c, kCGBlendModeLighten);
		CGContextSetStrokeColorWithColor(c,[UIColor colorWithWhite:255/255.0 alpha:1.0].CGColor);
		CGContextSetLineWidth(c, .5f);
		CGContextStrokePath(c);
		
		CGContextRestoreGState(c);
		midy--, maxy--;
		CGContextMoveToPoint(c, minx - .5, midy - .5);
		CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, kCornerRadius);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, kCornerRadius);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, kCornerRadius);
		CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, kCornerRadius);
		CGContextClosePath(c);
		
		CGContextSetBlendMode(c, kCGBlendModeMultiply);
		CGContextSetStrokeColorWithColor(c,[UIColor colorWithWhite:30/255.0 alpha:.9].CGColor);
		CGContextSetLineWidth(c, .5f);
		CGContextStrokePath(c);
	}
	CFRelease(colorSpace);
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    int itemIndex = floor([_items count] * point.x / self.bounds.size.width);
    if (_selectedSegmentIndex != itemIndex)
    {
        _selectedSegmentIndex = itemIndex;
        if ([_parent respondsToSelector: @selector(segmentPicked:)])
        {
            [_parent segmentPicked: self];
        }
    }
    [self setNeedsDisplay];
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
}

// ----------------------------------------------------------------------------------------------------------
// change the title of a given segment 
// ----------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    NSMutableArray* item = [_items objectAtIndex: segment];
    if (nil != item)
    {
        for (int i = 0; i < [item count]; i ++)
        {
            id obj = [item objectAtIndex: i];
            if ([obj isKindOfClass:[NSString class]])
            {
                [item replaceObjectAtIndex: i withObject:title];
                [self setNeedsDisplay];
                break;
            }
        }
    }
}

// ----------------------------------------------------------------------------------------------------------
// change the image of a given segment
// ----------------------------------------------------------------------------------------------------------
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    NSMutableArray* item = [_items objectAtIndex: segment];
    if (nil != item)
    {
        for (int i = 0; i < [item count]; i ++)
        {
            id obj = [item objectAtIndex: i];
            if ([obj isKindOfClass:[UIImage class]])
            {
                [item replaceObjectAtIndex: i withObject:image];
                [self setNeedsDisplay];
                break;
            }
        }
    }
}

// ----------------------------------------------------------------------------------------------------------
// add segment with a text title 
// ----------------------------------------------------------------------------------------------------------
- (void)addSegmentWithTitle:(NSString *)title
{    
    NSMutableArray* item = [[NSMutableArray alloc] init];
    [item addObject: title];

    [_items addObject: item];
    [self setNeedsDisplay];
}

// ----------------------------------------------------------------------------------------------------------
// add segment with title follow by an an image
// ----------------------------------------------------------------------------------------------------------
- (void)addSegmentWithTitleAndImage: (NSString *)title : (UIImage*) image
{    
    NSMutableArray* item = [[NSMutableArray alloc] init];
    [item addObject: title];
    [item addObject: image];
    
    [_items addObject: item];
    [self setNeedsDisplay];
}

// ----------------------------------------------------------------------------------------------------------
// add segment with an image
// ----------------------------------------------------------------------------------------------------------
- (void)addSegmentWithImage:(UIImage *)image 
{
    NSMutableArray* item = [[NSMutableArray alloc] init];
    [item addObject: image];
    
    [_items addObject: item];
    [self setNeedsDisplay];
}

// ----------------------------------------------------------------------------------------------------------
// add segment with and image follows by a title
// ----------------------------------------------------------------------------------------------------------
- (void)addSegmentWithImageAndTitle:(UIImage *)image :(NSString *)title 
{
    NSMutableArray* item = [[NSMutableArray alloc] init];
    [item addObject: image];
    [item addObject: title];

    [_items addObject: item];
    [self setNeedsDisplay];
}

// ----------------------------------------------------------------------------------------------------------
// remove a segment at index
// ----------------------------------------------------------------------------------------------------------
- (void)removeSegmentAtIndex:(NSUInteger)segment 
{
    if (segment >= [_items count]) return;
    [_items removeObjectAtIndex:segment];
    [self setNeedsDisplay];
}

@end
