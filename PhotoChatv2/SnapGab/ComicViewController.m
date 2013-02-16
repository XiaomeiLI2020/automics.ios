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

@interface ComicViewController ()

@end

@implementation ComicViewController

@synthesize panelScrollView;
//@synthesize panelImage;
@synthesize thumbnailScrollView;
//@synthesize thumbnailImage;
@synthesize wasEdited;
@synthesize addImage;

@synthesize _groupName;
@synthesize currentPage;
@synthesize imagePicker;
@synthesize newMedia;
@synthesize comicTable;
@synthesize comicList;

UILabel *clickLabel;

int _numComics;
int currentComic;
CGFloat yPos = 50.0;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _groupName = [prefs objectForKey:@"groupname"];
        //_groupname = @"d1";
        //NSLog(@"groupname is %@", _groupname);
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
    CGFloat xPos = 10.0;
    int page = 0;
    if(_numComics>0) {

            //comicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, 360)];
            comicList = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, 320, 460)];
        
            NSUInteger i;
            for (i=1; i <=_numComics; i++)
            {
                
                //NSString* urlComicString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/comics/%d.bub",_groupName, i];
                
                NSString* buttonTitle = [NSString stringWithFormat:@"Comic%d", i];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [button setTitle:buttonTitle forState:UIControlStateNormal];
                button.frame = CGRectMake((page*320)+xPos, yPos, 70.0, 30.0);
                button.tag = i;
                [button addTarget:self action:@selector(viewComicDetails:) forControlEvents:UIControlEventTouchDown];
                
                [comicList addSubview:button];
                if(yPos<=380)
                    yPos+=50.0;
                else
                {
                    yPos = 40.0;
                    page++;
                }
            }//end for
        
            comicList.pagingEnabled = YES;
            //CGFloat pos = (CGFloat)_numComics/8;
            //int page = round(ceilf(pos));
            
            [comicList setContentSize:CGSizeMake((page+1)*320, 420)];

            [self.view addSubview:comicList];

        
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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self updateNumComics];
    //self.panelScrollView.delegate=self;

}

- (void)viewComicDetails:(id)sender
{
    UIButton *clicked = (UIButton *) sender;
    currentComic = clicked.tag;
    //NSLog(@"button.tag=%d",clicked.tag);//Here you know which button has pressed
    [self performSegueWithIdentifier: @"comicDetails" sender:self];


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


@end
