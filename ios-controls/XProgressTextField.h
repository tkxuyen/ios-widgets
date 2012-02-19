//
//  XProgressTextField.h
//  NotesPlus
//
//  This class subclass UITextField to add the ability to display a progress bar 
//  (Used for WebView's address textbox)
//
//  Created by tran khai xuyen on 2/18/12.
//

#import <UIKit/UIKit.h>

@interface XProgressTextField : UITextField
{
    
}

@property (nonatomic, assign) CGFloat       _progressCount;

- (void)setProgress:(CGFloat) prog;

@end