//
//  ViewController.m
//  bonjourFTP
//
//  Created by tran khai xuyen on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "UIWebDocumentView.h"
#import "WebView.h"

@implementation ViewController

@synthesize _fileList, _currentDirectory, _fileTableView;
@synthesize _segment;
@synthesize _filepathHeader;
@synthesize _progressTextField;
@synthesize _webView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // copy test_data from bundle to Documents folder for testing
    NSError* error = nil; 
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSString* dataFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test_data"];
    NSString* docFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];    
    NSArray*files = [fileMgr contentsOfDirectoryAtPath: dataFolder error:nil];
    for (NSString *file in files)
    {
        [fileMgr copyItemAtPath:[dataFolder stringByAppendingPathComponent:file] toPath: [docFolder stringByAppendingPathComponent:file] error:&error];
    }

    self.view.backgroundColor = [UIColor colorWithRed: 0.9 green: 0.9 blue: 0.9 alpha: 1];

    _currentIndex = 0;
    _fileList = [[NSMutableArray alloc] init];

    // create the segmented control
	_segment = [[XSegmentedControl alloc] initWithParent: self];
    _segment.frame = CGRectMake(5, 450, 310, 26);
	_segment.segmentedControlStyle = UISegmentedControlStylePlain;
	_segment.selectedSegmentIndex = 0;
	_segment.tintColor = [UIColor colorWithRed: 0.2 green: 0.5 blue: 0.8 alpha: 1];
	_segment._selectedItemColor   = [UIColor whiteColor];
	_segment._unselectedItemColor = [UIColor darkGrayColor];
    [_segment addSegmentWithImageAndTitle: [UIImage imageNamed: @"files.png"] : @"Files"];
    [_segment addSegmentWithImageAndTitle: [UIImage imageNamed: @"logs.png"] : @"Web"];

    [_segment addTarget:self action:@selector(segmentPicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];

    _filepathHeader = [[XFilePathHeader alloc] initWithFrame: CGRectMake(0, 0, 320, 28) notifyObject:self ];
    [[self view] addSubview: _filepathHeader];

    _progressTextField = [[XProgressTextField alloc] initWithFrame: CGRectMake(5, 5, 310, 24)];
    _progressTextField.hidden = TRUE;
    _progressTextField.borderStyle = UITextBorderStyleNone;
    _progressTextField.textColor = [UIColor blackColor];
    _progressTextField.backgroundColor = [UIColor clearColor];
    _progressTextField.layer.cornerRadius = 10.0f;
    _progressTextField.placeholder = @"http://blog.tkxuyen.com";
    _progressTextField.delegate = self;
    _progressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _progressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _progressTextField.font = [UIFont systemFontOfSize:14.0];
    [_progressTextField setProgress: 0.0f];
    [[self view] addSubview: _progressTextField];

  	_fileTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 28, 320, 412) ]; 
	_fileTableView.dataSource = self;
	_fileTableView.delegate = self; 
	[[self view] addSubview: _fileTableView];

    _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 34, 320, 412) ]; 
    _webView.hidden = TRUE;
    [[self view] addSubview: _webView];
    
    WebView *coreWebView = [[_webView _documentView] webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressEstimateChanged:) name:@"WebProgressEstimateChangedNotification" object:coreWebView];
    
    // the inital path, set to the "Documents" folder of the app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _currentDirectory = [[NSString alloc] initWithString: [paths objectAtIndex:0]]; 
    [self loadCurrentDirectory];
    [_filepathHeader setRootDirectory: _currentDirectory];    
}

//------------------------------------------------------------------------------------------
// handle estimated-progress notification from UIWebView's WebKit object
//------------------------------------------------------------------------------------------
- (void)progressEstimateChanged:(NSNotification*)theNotification 
{
    float progress = [[theNotification object] estimatedProgress];
    [_progressTextField setProgress: progress];
    
    // if progress = 1 (finished), set it back to 0
    if (progress == 1.0f)
    {
        [_progressTextField setProgress: 0.0f]; 
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_progressTextField resignFirstResponder];
    NSString* urlString = _progressTextField.text;
    NSURL * url = [NSURL URLWithString: urlString];
    
    // only add a default "http://" if the protocol part is missing
    if (![[url scheme] length])
    {
        NSString* fullUrl = [@"http://" stringByAppendingString:urlString];
        [_progressTextField setText: fullUrl];
        url = [NSURL URLWithString: fullUrl];
    }    
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    [_webView stopLoading];
    [_webView loadRequest:request];
    return YES;
}

- (void) segmentPicked:(id)sender
{
    _currentIndex = [sender _selectedSegmentIndex];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);            

	switch (_currentIndex)
    {
        case 0:
            [_filepathHeader setRootDirectory: [paths objectAtIndex:0]];            
            [_filepathHeader setCurrentDirectory: _currentDirectory];  
            [self reloadData: FALSE : FALSE];
            break;
        case 1:
            [_filepathHeader setRootDirectory: @"/"];
            [_filepathHeader setCurrentDirectory: @"/Web"];
            break;
    }
    _filepathHeader.hidden = _currentIndex != 0;
    _fileTableView.hidden = _currentIndex != 0;
    _progressTextField.hidden = _currentIndex == 0;
    _webView.hidden = _currentIndex == 0;    
}

// ----------------------------------------------------------------------------------------------------------
// parse the current directory contents and fill in the _fileList array
// ----------------------------------------------------------------------------------------------------------
- (void) loadCurrentDirectory
{        
    [_fileList removeAllObjects];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath: _currentDirectory];
    
    // add every other sub items
    for (NSString *filename in fileEnumerator) 
    {
        NSMutableDictionary* entry = [[NSMutableDictionary alloc] init];
        
        [entry setObject: filename forKey: @"name"];
        [entry setObject: @"false" forKey: @"dir"];
        if ([[[fileEnumerator fileAttributes] fileType] isEqualToString:NSFileTypeDirectory])
		{
            [entry setObject: @"true" forKey: @"dir"];
            [fileEnumerator skipDescendents];
		}        
        [_fileList addObject: entry];
        [entry release];
    }
    [manager release];
    [_fileTableView reloadData];
}

// ----------------------------------------------------------------------------------------------------------
// perform a little animation to show the "directory switching"
// ----------------------------------------------------------------------------------------------------------
- (void) reloadData: (BOOL) dirChanged : (BOOL) goUp
{
    CGRect frame = _fileTableView.frame;
    int distance = (TRUE == goUp) ? frame.size.width : -frame.size.width;
    
    if (dirChanged)
    {
        [UIView animateWithDuration:0.5 animations:^
         {
             [_fileTableView setFrame: CGRectMake(distance, 28, frame.size.width, frame.size.height)];
         } completion:^(BOOL finished)
         {   
             [_fileTableView setFrame: CGRectMake(0, 28, frame.size.width, frame.size.height)];
             [self loadCurrentDirectory];
         }];	
    } else
    {
        [self loadCurrentDirectory];
    }
}


// ----------------------------------------------------------------------------------------------------------
// delegate function from XFilePathHeader to handle directory changed
// ----------------------------------------------------------------------------------------------------------
- (void) directoryChanged : (NSString*) dir
{
    if (_currentIndex >= 1)
    {
        switch (_currentIndex)
        {
            case 1:
                [_filepathHeader setRootDirectory: @"/"];
                [_filepathHeader setCurrentDirectory: @"/Logs"];
                break;
            case 2:
                [_filepathHeader setRootDirectory: @"/"];
                [_filepathHeader setCurrentDirectory: @"/Configs"];
                break;
        }
        return;
    }
    if ( ! [_currentDirectory isEqualToString: dir])
    {
        [_currentDirectory release];
        _currentDirectory = [[NSString alloc] initWithString: dir]; 
        
        [_filepathHeader setCurrentDirectory: _currentDirectory];                
        [self reloadData: TRUE: TRUE];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

// ----------------------------------------------------------------------------------------------------------
// when the device is rotated, relayout the controls...
// ----------------------------------------------------------------------------------------------------------
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        _progressTextField.frame = CGRectMake(5, 5, 470, 24);
        _webView.frame = CGRectMake(0, 34, 480, 252);
        _filepathHeader.frame = CGRectMake(0, 0, 480, 28);
        _fileTableView.frame = CGRectMake(0, 28, 480, 252);
        _segment.frame = CGRectMake(5, 287, 470, 26);
        [_filepathHeader setCurrentDirectory: _currentDirectory];
        [_filepathHeader setNeedsDisplay];
        [_segment setNeedsDisplay];
    }
    else
    {
        _progressTextField.frame = CGRectMake(5, 5, 310, 24);
        _webView.frame = CGRectMake(0, 34, 320, 412);        
        _filepathHeader.frame = CGRectMake(0, 0, 320, 28);
        _fileTableView.frame = CGRectMake(0, 28, 320, 412);
        _segment.frame = CGRectMake(5, 447, 310, 28);        
        [_filepathHeader setCurrentDirectory: _currentDirectory];
        [_filepathHeader setNeedsDisplay];
        [_segment setNeedsDisplay];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

// ----------------------------------------------------------------------------------------------------------
// The file & folder list UITableView delegate functions
// ----------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 25;
}

// ----------------------------------------------------------------------------------------------------------
// the number of line in TableView = our data set size (_documentList)
// ----------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [_fileList count];
}

// ----------------------------------------------------------------------------------------------------------
//  create a table cell 
// ----------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    int idx = [indexPath row];    
    static NSString *CellIdentifier = @"Cell";		
    UITableViewCell* cell = nil;

    cell = [[CustomTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    CustomTableCell* cell1 = (CustomTableCell*) cell;
    NSMutableDictionary* file = [_fileList objectAtIndex: idx];        
    [cell1 setTitle: [file objectForKey: @"name"] : [file objectForKey: @"dir"]];

    return cell;
}

// ----------------------------------------------------------------------------------------------------------
//  some item selected, check if this a a directory (".." or someother thing)
//  if is a directory => perform "cd" to the new folder
// ----------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (_currentIndex != 0) return;
    
	CustomTableCell *cell = (CustomTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSString* title = cell._titleLabel.text;
    
    NSMutableDictionary* file = [_fileList objectAtIndex: [indexPath row]];
    if ( [[file objectForKey: @"dir"] isEqualToString: @"true"])
    {            
        NSString* tmpStr = _currentDirectory;            
        _currentDirectory = [[NSString alloc] initWithFormat: @"%@/%@", _currentDirectory, title];
        [tmpStr release];
        
        [_filepathHeader setCurrentDirectory: _currentDirectory];
        [self reloadData : TRUE : FALSE];
    }    
}

// ----------------------------------------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------------------------------------
- (void)dealloc 
{
    [_fileList removeAllObjects];
    [_fileList release];
    [_currentDirectory release];
    [_fileTableView release];
    [_segment release];
    [_filepathHeader release];
    
    [super dealloc];
}

@end
