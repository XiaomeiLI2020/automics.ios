//
//  PanelViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "PanelViewController.h"
#import "PhotoTableViewCell.h"
#import "CameraViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"

@interface PanelViewController ()

@end

@implementation PanelViewController

//@synthesize photoTableView;
@synthesize photoTableView;

NSString* _groupname;
int _numImages;

- (IBAction)closePressed:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateNumImages
{

    //NSURLRequestReloadIgnoringLocalCacheData does not seem to work for 3G
    NSString* urlString = [NSString stringWithFormat:
                           @"http://www.automics.net/automics/userfiles/%@/last.txt?%d",_groupname,arc4random()];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(!requestError) _numImages = [[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] intValue];
    /*
    NSLog(@"updateNumeImages. _numImages is %i", _numImages);
    NSLog(@"updateNumbers. self.photoTableView numberOfSections is %i", [self.photoTableView numberOfSections]);
    NSLog(@"upDateNumbers. self.photoTableView numberOfRowsInSection:0 is %i", [self.photoTableView numberOfRowsInSection:0]);
    */
    if(_numImages>0) {
        [self.photoTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewScrollPositionBottom];
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(_numImages - 1) inSection:0];
        if(//[self.photoTableView numberOfSections] >0) //&&//
           [self.photoTableView numberOfRowsInSection:0]>0 )
        {
            [self.photoTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        }

    }//end if(_numImages>0)

}//end updateNumImages

BOOL _bubblesAdded = NO;
-(void)removeAllBubbles
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            [subview removeFromSuperview];
        }
    }
    _bubblesAdded = NO;
}

-(void)addBubblesForRow:(int)row
{
    
    if(_bubblesAdded) return;
    
    _bubblesAdded = YES;
    
    NSString* urlBubbleString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupname,row + 1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlBubbleString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        
        for(NSDictionary* bubble in jsonObject)
        {
         
            NSString* category = [bubble objectForKey:@"c"];
            if([category isEqualToString:@"bubble"])
            {
                CGRect xywh = CGRectMake([[bubble objectForKey:@"x"] floatValue],
                                         [[bubble objectForKey:@"y"] floatValue],0,0);
                // [[bubble objectForKey:@"w"] floatValue],
                // [[bubble objectForKey:@"h"] floatValue]);
                NSString* text = [bubble objectForKey:@"t"];
                int styleId = [[bubble objectForKey:@"s"] intValue];
                
                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                sbv.userInteractionEnabled = NO;
                sbv.alpha = 0.0f;
                [self.view addSubview:sbv];
                [UIView transitionWithView:self.view
                                  duration:0.25
                                   options:UIViewAnimationOptionLayoutSubviews
                                animations:^ { sbv.alpha = 1.0f; }
                                completion:nil];
            }//end if category
            
        }//end for
    }//end if response
    
}



BOOL _resourcesAdded = NO;
-(void)removeAllResources
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[ResourceView class]])
        {
            [subview removeFromSuperview];
        }
    }
    _resourcesAdded = NO;
}

-(void)addResourcesForRow:(int)row
{
    
    if(_resourcesAdded) return;
    
    _resourcesAdded = YES;
    
    NSString* urlResourceString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupname,row + 1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlResourceString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        
        for(NSDictionary* resource in jsonObject)
        {
            
            NSString* category = [resource objectForKey:@"c"];
            if([category isEqualToString:@"resource"])
            {
                /*
                CGRect xywh = CGRectMake([[resource objectForKey:@"x"] floatValue],
                                         [[resource objectForKey:@"y"] floatValue],0,0);
               */
                CGRect xywh = CGRectMake([[resource objectForKey:@"x"] floatValue],
                                         [[resource objectForKey:@"y"] floatValue],
                                         [[resource objectForKey:@"w"] floatValue],
                                         [[resource objectForKey:@"h"] floatValue]);
                // [[bubble objectForKey:@"w"] floatValue],
                // [[bubble objectForKey:@"h"] floatValue]);
                 
               
 
                int styleId = [[resource objectForKey:@"s"] intValue];
                
                ResourceView* sbv = [[ResourceView alloc] initWithFrame:xywh andStyle:styleId];
                //NSLog(@"sbv.frame.origin = (%f, %f)", sbv.frame.origin.x, sbv.frame.origin.y);
                //NSLog(@"sbv.frame.size = (%f, %f)", sbv.frame.size.width, sbv.frame.size.height);
                sbv.userInteractionEnabled = NO;
                sbv.alpha = 0.0f;
                [self.view addSubview:sbv];
                [UIView transitionWithView:self.view
                                  duration:0.25
                                   options:UIViewAnimationOptionLayoutSubviews
                                animations:^ { sbv.alpha = 1.0f; }
                                completion:nil];
            }//end if category
        }//end for
    }//end if
    
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeAllBubbles];
    [self removeAllResources];
}

-(void)alignRowInPhotoTableView
{
    //NSLog(@"alignRowInPhotoTableView. _numImages is %i", _numImages);
    if(_numImages>0) {
        //Constrain vertical row position and add bubbles and resources
        CGFloat pos = (CGFloat)self.photoTableView.contentOffset.y / 440.0f;
        int row = round(pos);
        if( row == _numImages) row--;
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];

        if(//[self.photoTableView numberOfSections]>0 &&
           [self.photoTableView numberOfRowsInSection:0]>0 )
        {
          [self.photoTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];  
        }
        //[self.photoTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //if(_numImages!=row) [self addBubblesForRow:row]; //Don't load images for placeholder (hack1)
        [self addBubblesForRow:row];
        [self addResourcesForRow:row];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self alignRowInPhotoTableView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self alignRowInPhotoTableView];
}

-(void)newImageNotification
{
    [self removeAllBubbles];
    [self removeAllResources];
    [self updateNumImages];
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _groupname = [prefs objectForKey:@"groupname"];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeAllBubbles];
    [self removeAllResources];
    [self updateNumImages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_numImages>0) {
        
        /*
        NSLog(@"viewdidappear. _numImages is %i", _numImages);
        NSLog(@"viewDidAppear. self.photoTableView numberOfSections is %i", [self.photoTableView numberOfSections]);
        NSLog(@"viewDidAppear. self.photoTableView numberOfRowsInSection:0 is %i", [self.photoTableView numberOfRowsInSection:0]);
        */
         
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(_numImages - 1) inSection:0];
        if([self.photoTableView numberOfSections] >0 && [self.photoTableView numberOfRowsInSection:0]>0 )
        {
        [self.photoTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        [self addBubblesForRow:_numImages - 1];
        [self addResourcesForRow:_numImages - 1];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    

    if([[segue identifier] isEqualToString:@"startEditView"]){
        CameraViewController *ebvc = (CameraViewController *)[segue destinationViewController];
        PhotoTableViewCell *cell = (PhotoTableViewCell*)sender;
        NSIndexPath *indexPath = [self.photoTableView indexPathForCell:cell];
        NSString* urlString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.jpg",_groupname,indexPath.row + 1];
        ebvc.url = [NSURL URLWithString:urlString];
        
        for (UIView *subview in self.view.subviews)
        {
            //Add Speech Bubbles
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = YES;
                new_sbv.alpha = 0;
                [ebvc.view addSubview:new_sbv];
            }
            
            //Add Resources
            if([subview isMemberOfClass:[ResourceView class]])
            {
                ResourceView* sbv =(ResourceView*)subview;

                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = YES;
                new_sbv.alpha = 0;
                [ebvc.view addSubview:new_sbv];
            }
        }
        
        ebvc.startWithCamera = NO;
    }
    /*
    if([[segue identifier] isEqualToString:@"startEditViewAndPressSnap"]){
        EditBubblesViewController *ebvc = (EditBubblesViewController *)[segue destinationViewController];
        ebvc.startWithCamera = YES;
        
        ebvc.url = [[NSBundle mainBundle] URLForResource: @"placeholder-542x542" withExtension:@"png"];
    }
    */
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _numImages+1; //Add extra image so table view lines up (hack1)
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"PhotoCell";
    
    if(indexPath.row == _numImages) //Add extra image so table view lines up (hack1)
    {
        PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        if (cell == nil)
        {
            cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        }
        
        //cell.photoImageView.image = [UIImage imageNamed:@"placeholder-542x542.png"];
        
        [cell.photoImageView setImageWithURL:[[NSBundle mainBundle] URLForResource: @"placeholder-542x542" withExtension:@"png"]
                            placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        
        cell.userInteractionEnabled = NO;
        return cell;
    }
   
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSString* urlImageString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/thumbs/%d.jpg",_groupname,indexPath.row + 1];
    
    [cell.photoImageView setImageWithURL:[NSURL URLWithString:urlImageString]
                        placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row==_numImages?20:440;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
