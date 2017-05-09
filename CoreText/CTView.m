//
//  ANView.m
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import "CTView.h"
#import "ANMarkupParser.h"

@implementation CTView

@synthesize attString;
@synthesize frames;
@synthesize images;

/*
- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 0 翻转坐标，默认是笛卡尔坐标系
    CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
    CGContextTranslateCTM(ref, 0, self.bounds.size.height);
    CGContextScaleCTM(ref, 1.0, -1.0);
    
    // 1
    CGPathAddRect(path, NULL, self.bounds);
    
    // 2
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attString);
    
    // 3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attString.length), path, NULL);
    
    // 4
    CTFrameDraw(frame, ref);
    
    // 5
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(frame);
    
}
*/

- (void)buildFrames {
    
    // 1
    frameXOffset = 20; //1 marginX 20
    frameYOffset = 20; //  marginY 20
    
    self.pagingEnabled = YES;
    self.delegate = self;
    self.frames = [NSMutableArray array];
    
    
    // 2
//    CGMutablePathRef path = CGPathCreateMutable(); //2
    CGRect textFrame = CGRectInset(self.bounds, frameXOffset, frameYOffset); // 整个显示的范围
//    CGPathAddRect(path, NULL, textFrame );
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    
    // 3
    int textPos = 0;      // 用于记录当前开始draw的文字位置
    int columnIndex = 0;  // 总共有多少列（这里是4列。根据内容的长短，列数会不同）
    
    
    
    // 4 通过while循环来绘制文本，一列文本就用一个CTColummView
    while (textPos < [attString length]) { //4
        
        // 计算开始绘制的位置
        CGPoint colOffset = CGPointMake((columnIndex+1)*frameXOffset + columnIndex*(textFrame.size.width/2) , 20);
        
        // 每列的长宽
        CGRect colRect = CGRectMake(0, 0 , textFrame.size.width/2-10, textFrame.size.height-40);
        
        // 创建绘制路径
        CGMutablePathRef path = CGPathCreateMutable();
        // 设置路径的绘制范围
        CGPathAddRect(path, NULL, colRect);
        
        // 根据路径和Framesetter来创建一个CTFrameRef，CTFrameRef里包含了多个CTLine（即每行的文字、大小、颜色、字体、正行的长宽等数据）
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        
        
        
        // 5 绘制的文字范围
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
        
        //create an empty column view
        // 文字将绘制在CTColumnView上
        CTColumnView* content = [[CTColumnView alloc]init]; // initWithFrame: CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor whiteColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height) ;
        
        
        // 6 将CTFrameRef传给CTColumnView进行绘制
        //set the column view contents and add it as subview
        [content setCTFrame:(__bridge id)frame];  //6
        
        [self attachImagesWithFrame:frame inColumnView:content];
        
        [self.frames addObject: (__bridge id)frame];
        [self addSubview:content]; // 添加了contentView后回执行CTColumnView的drawInRect方法
        
        NSLog(@"......length:%ld-- %d\r\n--", frameRange.length, textPos);
        
        //prepare for next frame
        textPos += frameRange.length;
        
        //CFRelease(frame);
        CFRelease(path);
        
        columnIndex++;
    }
    
    // 7
    //set the total width of the scroll view
    int totalPages = (columnIndex+1) / 2; //7
    self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);
}

//CTView.m - anywhere inside the implementation
-(void)setAttString:(NSAttributedString *)string withImages:(NSArray*)imgs
{
    self.attString = string;
    self.images = imgs;
    
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id)paragraphStyle, (NSString*)kCTParagraphStyleAttributeName,
                                    nil];
    
    NSMutableAttributedString* stringCopy = [[NSMutableAttributedString alloc] initWithAttributedString:self.attString];
    [stringCopy addAttributes:attrDictionary range:NSMakeRange(0, [attString length])];
    self.attString = (NSAttributedString*)stringCopy;
}



-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(CTColumnView*)col
{
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = 0; //3
    NSDictionary* nextImage = [self.images objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while ( imgLocation < frameRange.location ) {
        imgIndex++;
        if (imgIndex>=[self.images count]) return; //quit if no images for this column
        nextImage = [self.images objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
    
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) { //7
                CGRect runBounds;
                CGFloat ascent;//height above the baseline
                CGFloat descent;//height below the baseline
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
                runBounds.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
                runBounds.origin.x = origins[lineIndex].x + self.frame.origin.x + xOffset + frameXOffset;
                runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y + frameYOffset;
                runBounds.origin.y -= descent;
                
                UIImage *img = [UIImage imageNamed: [nextImage objectForKey:@"fileName"] ];
                CGPathRef pathRef = CTFrameGetPath(f); //10
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x - frameXOffset - self.contentOffset.x, colRect.origin.y - frameYOffset - self.frame.origin.y);
                [col.images addObject: //11
                 [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds) , nil]
                 ];
                //load the next image //12
                imgIndex++;
                if (imgIndex < [self.images count]) {
                    nextImage = [self.images objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
            }
        }
        lineIndex++;
    }
}

- (void)dealloc {
    
    self.frames = nil;
    //CTView.m - inside the dealloc method
    self.images = nil;
    
}

@end
