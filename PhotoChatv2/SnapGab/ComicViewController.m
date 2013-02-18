//
//  ComicViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 12/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicViewController.h"
#import "ComicEditViewController.h"
#import "ComicDetailsViewController.h"
#import "ComicTableCell.h"

@interface ComicViewController ()

@end

@implementation ComicViewController

@synthesize _groupName;
@synthesize comicTableView;
UILabel *clickLabel;


int _numComics;
int currentComic;
CGFloat yPos = 50.0;
CGFloat xPos = 10.0;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _groupName = [prefs objectForKey:@"groupname"];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newImageNotification)
                                                     name:@"newImageNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newImageNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)updateNumComics
{
        NSLog(@"updateNumComics");
    //NSURLRequestReloadIgnoringLocalCacheData does not seem to work for 3G
    NSString* urlString = [NSString stringWithFormat:
                           @"http://www.automics.net/automics/userfiles/%@/lastcomic.txt?%d",_groupName,arc4random()];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(!requestError) _numComics = [[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] intValue];
    
    //NSLog(@"updateImages. urlString is %@", urlString);
    //NSLog(@"updateImages. _numComics is %i", _numComics);
    
    yPos= 40.0;

    int page = 0;
    //NSLog(@"_numComics%i", _numComics);
    
    if(_numComics>0)
    {
        
        [self.comicTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewScrollPositionBottom];
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(_numComics - 1) inSection:0];
        
        if(([self.comicTableView numberOfSections] >0) &&
           [self.comicTableView numberOfRowsInSection:0]>0 )
        {
            [self.comicTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
                  }//end if(_numComics>0)
    else
    {
        clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 50, 320, 320)];
        clickLabel.textColor = [UIColor whiteColor];
        clickLabel.backgroundColor = [UIColor blackColor];
        //clickLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
        [self.view addSubview:clickLabel];
        clickLabel.text = [NSString stringWithFormat: @"Click + to add a comic."];

    }
}//end updateNumImages

- (void)viewDidLoad
{
    NSLog(@"viewWDidLoad.");
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    [self updateNumComics];
    if(_numComics>0) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(_numComics - 1) inSection:0];
        
        if(//[self.comicTableView numberOfSections] >0 &&
           [self.comicTableView numberOfRowsInSection:0]>0 )
        {
            [self.comicTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }

    comicTableView.dataSource = self;
    comicTableView.delegate = self;

}

- (void)viewComicDetails:(id)sender
{
    UIButton *clicked = (UIButton *) sender;
    currentComic = clicked.tag;
    [self performSegueWithIdentifier: @"comicDetails" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // If You have only one(1) section, return 1, otherwise you must handle sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _numComics;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"ComicCell";
    
    ComicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ComicTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [[cell contentView] setBackgroundColor:[UIColor blueColor]];
        [[cell backgroundView] setBackgroundColor:[UIColor blueColor]];
    }
    
    NSString* buttonTitle = [NSString stringWithFormat:@"Comic%d", indexPath.row+1];
    
    cell.comicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cell.comicButton setTitle:buttonTitle forState:UIControlStateNormal];
    cell.comicButton.frame = CGRectMake(10.0, 10.0, 70.0, 20.0);
    cell.comicButton.tag = indexPath.row+1;
    [cell.comicButton addTarget:self action:@selector(viewComicDetails:) forControlEvents:UIControlEventTouchDown];
    //[cell.contentView addSubview:cell.comicButton];
    [cell addSubview:cell.comicButton];
       
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
    //return indexPath.row==_numComics?20:440;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"editComic"])
    {
        ComicEditViewController *cpvc = (ComicEditViewController *)[segue destinationViewController];
        cpvc.comicId = currentComic;
    }
    
    if([[segue identifier] isEqualToString:@"comicDetails"])
    {
        ComicDetailsViewController *cpvc = (ComicDetailsViewController *)[segue destinationViewController];
        cpvc.comicId = currentComic;
    }
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
 */

@end
