//
//  ANMarkupParser.h
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface ANMarkupParser : NSObject

@property(strong,nonatomic) NSString* font;
@property(strong,nonatomic) UIColor* color;
@property(strong,nonatomic) UIColor* strokeColor;
@property(assign,readwrite) float strokeWidth;
@property(strong,nonatomic) NSMutableArray* images;

-(NSAttributedString*)attrStringFromMark:(NSString*)mark;

@end
