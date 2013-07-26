//
//  PanelPopupWindow.h
//  PhotoChat
//
//  Created by Umar Rashid on 25/07/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

//@class PanelPopupWindow;


@protocol PanelPopupWindowDelegate;

@interface PanelPopupWindow : UIView

//@property (weak, nonatomic) id <PanelPopupWindowDelegate> delegate;
@property (weak) id <PanelPopupWindowDelegate> delegate;
+(PanelPopupWindow*)showWindow;
+(PanelPopupWindow*)showWindowInsideView:(UIView*)view;

-(void)show;
-(void)showInView:(UIView*)v;
-(void)closePopupWindow;
+(void)setWindowMargin:(CGSize)margin;

@end

@protocol PanelPopupWindowDelegate <NSObject>
@optional
- (void) willShowPanelPopupWindow:(PanelPopupWindow*)sender;
- (void) didShowPanelPopupWindow:(PanelPopupWindow*)sender;
- (void) willClosePanelPopupWindow:(PanelPopupWindow*)sender;
- (void) didClosePanelPopupWindow:(PanelPopupWindow*)sender;
- (void) didSelectSource:(int)sourceId;
@end