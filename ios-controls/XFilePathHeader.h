//
//  XFilePathHeader.h
//  bonjourFTP
//
//  Created by tran khai xuyen on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define XFILEPATHHEADER_DEFAULT_FONT(s) [UIFont fontWithName: @"Helvetica" size: s]

@interface XFilePathHeader : UIView
{
    UIImageView*    _rootIcon;
    id				_notificationObject;

    int             _hightlightIndex;
    NSString*       _rootDir;
    NSString*       _curDir;
    NSMutableArray* _dirSet;

}

- (id) initWithFrame:(CGRect)frame notifyObject:(id)sender;
- (void) setRootDirectory : (NSString*) dir;
- (void) setCurrentDirectory : (NSString*) dir;
- (int) getMaxTabWidth;
- (void) drawBackground;
- (void) drawArrow : (CGPoint) p;
- (CGSize) drawText : (NSString*) text : (BOOL) hightlight : (CGPoint) p;
- (void) drawHightlight : (CGRect) r;

@property (nonatomic, retain) UIImageView*  _rootIcon;
@property (nonatomic, retain) NSString*     _rootDir;
@property (nonatomic, retain) NSString*     _curDir;
@property (nonatomic, retain) NSMutableArray*  _dirSet;
@property (readwrite, retain) id _notificationObject;

@end
