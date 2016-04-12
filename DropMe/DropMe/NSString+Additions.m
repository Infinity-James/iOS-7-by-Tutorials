//
//  NSString+Additions.m
//  DropMe
//
//  Created by James Valaitis on 08/03/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (NSInteger)occurrenceCountForWord:(NSString *)word
{
    //  the range of this entire receiving string
    NSRange range = NSMakeRange(0, self.length);
    NSRange nonAlphaNumericRange = [word rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]];
    
    //  make sure the word is fully alphanumeric
    if (nonAlphaNumericRange.location != NSNotFound) {
        return -1;
    }
    
    //  create a regular expression for the word (which allows us to match exactly the word and not a subset of another word)
    NSString *regexPattern = [NSString stringWithFormat:@"\b%@\b", word];
    NSRegularExpression *exactWordMatchRegex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    //  find the amount of times that this word is in the string
    NSInteger occurrenceCount = [exactWordMatchRegex numberOfMatchesInString:self options:kNilOptions range:range];
    
    return occurrenceCount;
}

+ (NSInteger)ordersFilledForMaxLength:(CGFloat)availableLength withLengths:(NSArray *)lengths {
    
    //  first we check that the 'lengths' are also NSNumbers
    NSPredicate *isNumberPredicate = [NSPredicate predicateWithFormat:@"self isKindOfClass:%@", [NSNumber class]];
    if ([lengths filteredArrayUsingPredicate:isNumberPredicate].count != lengths.count) {
        return -1;
    }
    
    //  check that there are no negative lengths
    NSPredicate *containsNegativeLengthsPredicate = [NSPredicate predicateWithFormat:@"self < 0"];
    if ([lengths filteredArrayUsingPredicate:containsNegativeLengthsPredicate].count > 0) {
        return -1;
    }
    
    //  sort the lengths from smallest to biggest
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedLengths = [lengths sortedArrayUsingDescriptors:@[lowestToHighest]];
    //  now remove all lengths which are just bigger than the max length anyway
    NSPredicate *maxLengthPredicate = [NSPredicate predicateWithFormat:@"self <= %@", @(availableLength)];
    NSArray *filteredLengths = [sortedLengths filteredArrayUsingPredicate:maxLengthPredicate];
    
    NSInteger orders = 0;
    CGFloat currentLength = 0.0;
    
    //  start at the beginning and see how many lengths we can use
    for (NSNumber *length in filteredLengths) {
        currentLength += length.floatValue;
        if (currentLength < availableLength) {
            orders++;
        } else {
            break;
        }
    }
    
    return orders;
}

@end
