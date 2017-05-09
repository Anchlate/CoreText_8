//
//  CTColumnView.h
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTColumnView : UIView {
    id ctFrame;
    
}

//as an ivar
//NSMutableArray* images;

//as a property
@property (retain, nonatomic) NSMutableArray* images;


- (void)setCTFrame:(id)f;

@end
