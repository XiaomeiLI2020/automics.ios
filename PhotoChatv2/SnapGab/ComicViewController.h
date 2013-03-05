//
//  ComicViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 12/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import "ComicLoader.h"

@interface ComicViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, ComicLoaderDelegate>



@property NSString* _groupName;
//@property UITableView* comicTable;


@property (strong, nonatomic) IBOutlet UITableView *comicTableView;

@end
