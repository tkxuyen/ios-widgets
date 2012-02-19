//
//  XSegmentedControl.m
//  bonjourFTP
//
//  Created by tran khai xuyen on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#define TITLE_IMAGE_PADDING 5

@interface XSegmentedControl : UISegmentedControl 
{
	NSMutableArray *_items;
	
    id _parent;
    int _selectedSegmentIndex;
	UIFont  *_font;
	UIColor *_selectedItemColor;
	UIColor *_unselectedItemColor;
}

- (id)initWithParent: (id) parent;
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (void)addSegmentWithTitle:(NSString *)title;
- (void)addSegmentWithTitleAndImage: (NSString *)title : (UIImage*) image;
- (void)addSegmentWithImage:(UIImage *)image;
- (void)addSegmentWithImageAndTitle:(UIImage *)image :(NSString *)title;
- (void)removeSegmentAtIndex:(NSUInteger)segment;

@property (nonatomic, retain) NSMutableArray*   _items;
@property (nonatomic, assign) int               _selectedSegmentIndex;
@property (nonatomic, retain) UIFont*           _font;
@property (nonatomic, retain) UIColor*          _selectedItemColor;
@property (nonatomic, retain) UIColor*          _unselectedItemColor;

@end
