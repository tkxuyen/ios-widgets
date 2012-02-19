//
//  CustomTableCell.h
//  A customized cell to add a Label & Button
//
//  Created by Tran Khai Xuyen on 9/21/11.
//

#import <UIKit/UIKit.h>

@interface CustomTableCell : UITableViewCell 
{
	UILabel*			_titleLabel;
}

@property (nonatomic, retain) UILabel*				_titleLabel;

- (void)setTitle: (NSString*) title : (NSString*) isDirectory;

@end
