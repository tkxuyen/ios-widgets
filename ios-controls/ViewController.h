//
//  ViewController.h
//  bonjourFTP
//
//  Created by tran khai xuyen on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XSegmentedControl.h"
#import "XFilePathHeader.h"
#import "CustomTableCell.h"
#import "XProgressTextField.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    XSegmentedControl*      _segment;
    XFilePathHeader*        _filepathHeader;
    XProgressTextField*     _progressTextField;
    UIWebView*              _webView;
    UITableView*            _fileTableView;    
        
    NSString*               _currentDirectory;
    NSMutableArray*         _fileList;
    
    int                     _currentIndex;
}

- (void) segmentPicked:(id)sender;
- (void) loadCurrentDirectory;
- (void) reloadData: (BOOL) dirChanged : (BOOL) goUp;
- (void) directoryChanged : (NSString*) dir;

@property (nonatomic, retain) XFilePathHeader*  _filepathHeader;
@property (nonatomic, retain) XProgressTextField*  _progressTextField;
@property (retain, nonatomic) XSegmentedControl*_segment;
@property (retain, nonatomic) UIWebView*_webView;

@property (nonatomic, retain) UITableView*      _fileTableView;
@property (nonatomic, retain) NSMutableArray*   _fileList;
@property (nonatomic, retain) NSString*         _currentDirectory;

@end
