//
//  NSString+Additions.h
//  DropMe
//
//  Created by James Valaitis on 08/03/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSInteger)occurrenceCountForWord:(NSString *)word;

+ (NSInteger)ordersFilledForMaxLength:(CGFloat)availableLength withLengths:(NSArray *)lengths;

@end
