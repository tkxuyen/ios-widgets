//
//  CustomTableCell.h
//  A customized cell to add a Label & Button
//
//  Created by Tran Khai Xuyen on 9/21/11.
//

#import "CustomTableCell.h"

@implementation CustomTableCell

@synthesize _titleLabel;

//--------------------------------------------------------------------------------
// initWithStyle
//--------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
	{
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 0, 300, 25)];
		_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_titleLabel.numberOfLines = 1; 
		_titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
		_titleLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 14];

		[[self contentView] addSubview:_titleLabel];		
	}
    return self;
}

- (void)setTitle: (NSString*) title : (NSString*) isDirectory
{
    if ([isDirectory isEqualToString: @"true"])
    {
        self.imageView.image = [UIImage imageNamed: @"folder.png"];
    } else
    {
        self.imageView.image = [UIImage imageNamed: @"file.png"];
    }
    _titleLabel.text = title;
}

- (void)dealloc 
{
    [_titleLabel release];
    
    [super dealloc];
}

@end
