//
//  NBPhoneMetaData.m
//  libPhoneNumber
//
//  Created by NHN Corp. Last Edited by BAND dev team (band_dev@nhn.com)
//

#import "NBPhoneMetaData.h"
#import "NBPhoneNumberDesc.h"
#import "NBNumberFormat.h"
#import "NBPhoneNumberDefines.h"

@implementation NBPhoneMetaData

@synthesize generalDesc, fixedLine, mobile, tollFree, premiumRate, sharedCost, personalNumber, voip, pager, uan, emergency, voicemail, noInternationalDialling;
@synthesize codeID, countryCode;
@synthesize internationalPrefix, preferredInternationalPrefix, nationalPrefix, preferredExtnPrefix, nationalPrefixForParsing, nationalPrefixTransformRule, sameMobileAndFixedLinePattern, numberFormats, intlNumberFormats, mainCountryForCode, leadingDigits, leadingZeroPossible;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setNumberFormats:[[NSMutableArray alloc] init]];
        [self setIntlNumberFormats:[[NSMutableArray alloc] init]];

        self.leadingZeroPossible = NO;
        self.mainCountryForCode = NO;
    }
    
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"* codeID[%@] countryCode[%ld] generalDesc[%@] fixedLine[%@] mobile[%@] tollFree[%@] premiumRate[%@] sharedCost[%@] personalNumber[%@] voip[%@] pager[%@] uan[%@] emergency[%@] voicemail[%@] noInternationalDialling[%@] internationalPrefix[%@] preferredInternationalPrefix[%@] nationalPrefix[%@] preferredExtnPrefix[%@] nationalPrefixForParsing[%@] nationalPrefixTransformRule[%@] sameMobileAndFixedLinePattern[%@] numberFormats[%@] intlNumberFormats[%@] mainCountryForCode[%@] leadingDigits[%@] leadingZeroPossible[%@]",
             self.codeID, self.countryCode, self.generalDesc, self.fixedLine, self.mobile, self.tollFree, self.premiumRate, self.sharedCost, self.personalNumber, self.voip, self.pager, self.uan, self.emergency, self.voicemail, self.noInternationalDialling, self.internationalPrefix, self.preferredInternationalPrefix, self.nationalPrefix, self.preferredExtnPrefix, self.nationalPrefixForParsing, self.nationalPrefixTransformRule, self.sameMobileAndFixedLinePattern?@"Y":@"N", self.numberFormats, self.intlNumberFormats, self.mainCountryForCode?@"Y":@"N", self.leadingDigits, self.leadingZeroPossible?@"Y":@"N"];
}


- (void)buildData:(id)data
{
    if (data != nil && [data isKindOfClass:[NSArray class]] )
    {
        /*  1 */ self.generalDesc = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:1]];
        /*  2 */ self.fixedLine = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:2]];
        /*  3 */ self.mobile = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:3]];
        /*  4 */ self.tollFree = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:4]];
        /*  5 */ self.premiumRate = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:5]];
        /*  6 */ self.sharedCost = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:6]];
        /*  7 */ self.personalNumber = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:7]];
        /*  8 */ self.voip = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:8]];
        /* 21 */ self.pager = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:21]];
        /* 25 */ self.uan = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:25]];
        /* 27 */ self.emergency = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:27]];
        /* 28 */ self.voicemail = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:28]];
        /* 24 */ self.noInternationalDialling = [[NBPhoneNumberDesc alloc] initWithData:[data safeObjectAtIndex:24]];
        /*  9 */ self.codeID = [data safeObjectAtIndex:9];
        /* 10 */ self.countryCode = (UInt32)[[data safeObjectAtIndex:10] intValue];
        /* 11 */ self.internationalPrefix = [data safeObjectAtIndex:11];
        /* 17 */ self.preferredInternationalPrefix = [data safeObjectAtIndex:17];
        /* 12 */ self.nationalPrefix = [data safeObjectAtIndex:12];
        /* 13 */ self.preferredExtnPrefix = [data safeObjectAtIndex:13];
        /* 15 */ self.nationalPrefixForParsing = [data safeObjectAtIndex:15];
        /* 16 */ self.nationalPrefixTransformRule = [data safeObjectAtIndex:16];
        /* 18 */ self.sameMobileAndFixedLinePattern = [[data safeObjectAtIndex:18] boolValue];
        /* 19 */ self.numberFormats = [self numberFormatArrayFromData:[data safeObjectAtIndex:19]];     // NBNumberFormat array
        /* 20 */ self.intlNumberFormats = [self numberFormatArrayFromData:[data safeObjectAtIndex:20]]; // NBNumberFormat array
        /* 22 */ self.mainCountryForCode = [[data safeObjectAtIndex:22] boolValue];
        /* 23 */ self.leadingDigits = [data safeObjectAtIndex:23];
        /* 26 */ self.leadingZeroPossible = [[data safeObjectAtIndex:26] boolValue];
    }
    else
    {
        NSLog(@"nil data or wrong data type");
    }
}


- (id)initWithCoder:(NSCoder*)coder
{
    if (self = [super init])
    {
        self.generalDesc = [coder decodeObjectForKey:@"generalDesc"];
        self.fixedLine = [coder decodeObjectForKey:@"fixedLine"];
        self.mobile = [coder decodeObjectForKey:@"mobile"];
        self.tollFree = [coder decodeObjectForKey:@"tollFree"];
        self.premiumRate = [coder decodeObjectForKey:@"premiumRate"];
        self.sharedCost = [coder decodeObjectForKey:@"sharedCost"];
        self.personalNumber = [coder decodeObjectForKey:@"personalNumber"];
        self.voip = [coder decodeObjectForKey:@"voip"];
        self.pager = [coder decodeObjectForKey:@"pager"];
        self.uan = [coder decodeObjectForKey:@"uan"];
        self.emergency = [coder decodeObjectForKey:@"emergency"];
        self.voicemail = [coder decodeObjectForKey:@"voicemail"];
        self.noInternationalDialling = [coder decodeObjectForKey:@"noInternationalDialling"];
        self.codeID = [coder decodeObjectForKey:@"codeID"];
        self.countryCode = [[coder decodeObjectForKey:@"countryCode"] longValue];
        self.internationalPrefix = [coder decodeObjectForKey:@"internationalPrefix"];
        self.preferredInternationalPrefix = [coder decodeObjectForKey:@"preferredInternationalPrefix"];
        self.nationalPrefix = [coder decodeObjectForKey:@"nationalPrefix"];
        self.preferredExtnPrefix = [coder decodeObjectForKey:@"preferredExtnPrefix"];
        self.nationalPrefixForParsing = [coder decodeObjectForKey:@"nationalPrefixForParsing"];
        self.nationalPrefixTransformRule = [coder decodeObjectForKey:@"nationalPrefixTransformRule"];
        self.sameMobileAndFixedLinePattern = [[coder decodeObjectForKey:@"sameMobileAndFixedLinePattern"] boolValue];
        self.numberFormats = [coder decodeObjectForKey:@"numberFormats"];
        self.intlNumberFormats = [coder decodeObjectForKey:@"intlNumberFormats"];
        self.mainCountryForCode = [[coder decodeObjectForKey:@"mainCountryForCode"] boolValue];
        self.leadingDigits = [coder decodeObjectForKey:@"leadingDigits"];
        self.leadingZeroPossible = [[coder decodeObjectForKey:@"leadingZeroPossible"] boolValue];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:self.generalDesc forKey:@"generalDesc"];
    [coder encodeObject:self.fixedLine forKey:@"fixedLine"];
    [coder encodeObject:self.mobile forKey:@"mobile"];
    [coder encodeObject:self.tollFree forKey:@"tollFree"];
    [coder encodeObject:self.premiumRate forKey:@"premiumRate"];
    [coder encodeObject:self.sharedCost forKey:@"sharedCost"];
    [coder encodeObject:self.personalNumber forKey:@"personalNumber"];
    [coder encodeObject:self.voip forKey:@"voip"];
    [coder encodeObject:self.pager forKey:@"pager"];
    [coder encodeObject:self.uan forKey:@"uan"];
    [coder encodeObject:self.emergency forKey:@"emergency"];
    [coder encodeObject:self.voicemail forKey:@"voicemail"];
    [coder encodeObject:self.noInternationalDialling forKey:@"noInternationalDialling"];
    [coder encodeObject:self.codeID forKey:@"codeID"];
    [coder encodeObject:[NSNumber numberWithLong:self.countryCode] forKey:@"countryCode"];
    [coder encodeObject:self.internationalPrefix forKey:@"internationalPrefix"];
    [coder encodeObject:self.preferredInternationalPrefix forKey:@"preferredInternationalPrefix"];
    [coder encodeObject:self.nationalPrefix forKey:@"nationalPrefix"];
    [coder encodeObject:self.preferredExtnPrefix forKey:@"preferredExtnPrefix"];
    [coder encodeObject:self.nationalPrefixForParsing forKey:@"nationalPrefixForParsing"];
    [coder encodeObject:self.nationalPrefixTransformRule forKey:@"nationalPrefixTransformRule"];
    [coder encodeObject:[NSNumber numberWithBool:self.sameMobileAndFixedLinePattern] forKey:@"sameMobileAndFixedLinePattern"];
    [coder encodeObject:self.numberFormats forKey:@"numberFormats"];
    [coder encodeObject:self.intlNumberFormats forKey:@"intlNumberFormats"];
    [coder encodeObject:[NSNumber numberWithBool:self.mainCountryForCode] forKey:@"mainCountryForCode"];
    [coder encodeObject:self.leadingDigits forKey:@"leadingDigits"];
    [coder encodeObject:[NSNumber numberWithBool:self.leadingZeroPossible] forKey:@"leadingZeroPossible"];
}


- (NSMutableArray*)numberFormatArrayFromData:(id)data
{
    NSMutableArray *resArray = [[NSMutableArray alloc] init];
    if (data != nil && [data isKindOfClass:[NSArray class]])
    {
        for (id numFormat in data)
        {
            NBNumberFormat *newNumberFormat = [[NBNumberFormat alloc] initWithData:numFormat];
            [resArray addObject:newNumberFormat];
        }
    }
    
    return resArray;
}

/*
- (NSString*)getNormalizedNationalPrefixFormattingRule
{
    NSString *replacedFormattingRule = [self.nationalPrefixFormattingRule stringByReplacingOccurrencesOfString:@"$NP" withString:self.nationalPrefix];
    return replacedFormattingRule;
}


- (BOOL)sameMobileAndFixedLinePattern
{
    if ([self.mobile isEqual:self.fixedLine]) return YES;
    return NO;
}


- (NBPhoneNumberDesc*)inheriteValues:(NBPhoneNumberDesc*)targetDesc
{
    if (targetDesc == nil)
    {
        targetDesc = [[NBPhoneNumberDesc alloc] init];
    }
    
    if (self.generalDesc != nil)
    {
        if (targetDesc.nationalNumberPattern == nil)
        {
            if (self.generalDesc.nationalNumberPattern != nil)
                targetDesc.nationalNumberPattern = [self.generalDesc.nationalNumberPattern copy];
        }
        
        if (targetDesc.possibleNumberPattern == nil)
        {
            if (self.generalDesc.possibleNumberPattern != nil)
                targetDesc.possibleNumberPattern = [self.generalDesc.possibleNumberPattern copy];
        }
        
        if (targetDesc.exampleNumber == nil)
        {
            if (self.generalDesc.exampleNumber != nil)
                targetDesc.exampleNumber = [self.generalDesc.exampleNumber copy];
        }
    }
    
    return targetDesc;
}


- (void)updateDescriptions
{
    self.fixedLine = [[self inheriteValues:self.fixedLine] copy];
    self.mobile = [[self inheriteValues:self.mobile] copy];
    self.tollFree = [[self inheriteValues:self.tollFree] copy];
    self.premiumRate = [[self inheriteValues:self.premiumRate] copy];
    self.sharedCost = [[self inheriteValues:self.sharedCost] copy];
    self.personalNumber = [[self inheriteValues:self.personalNumber] copy];
    self.voip = [[self inheriteValues:self.voip] copy];
    self.pager = [[self inheriteValues:self.pager] copy];
    self.uan = [[self inheriteValues:self.uan] copy];
    self.emergency = [[self inheriteValues:self.emergency] copy];
    self.voicemail = [[self inheriteValues:self.voicemail] copy];
    self.noInternationalDialling = [[self inheriteValues:self.noInternationalDialling] copy];
}


- (void)setAttributes:(NSDictionary*)data
{
    NSString *attributeName = [data valueForKey:@"attributeName"];
    id attributeContent = [data valueForKey:@"nodeContent"];
    
    if ([attributeContent isKindOfClass:[NSString class]] && [attributeContent length] > 0)
        attributeContent = [NBPhoneNumberManager stringByTrimming:attributeContent];
    
    if (attributeName && [attributeName isKindOfClass:[NSString class]] && [attributeName length]  > 0 && [attributeName isEqualToString:@"id"] &&
        attributeContent && [attributeContent isKindOfClass:[NSString class]] && [attributeContent length] > 0)
    {
        [self setCodeID:attributeContent];
    }
    else if (attributeName && [attributeName isKindOfClass:[NSString class]] && [attributeName length]  > 0 && attributeContent && [attributeContent isKindOfClass:[NSString class]] && [attributeContent length] > 0)
    {
        @try {
            if ([[attributeContent lowercaseString] isEqualToString:@"true"])
            {
                [self setValue:[NSNumber numberWithBool:YES] forKey:attributeName];
            }
            else if ([[attributeContent lowercaseString] isEqualToString:@"false"])
            {
                [self setValue:[NSNumber numberWithBool:NO] forKey:attributeName];
            }
            else
            {
                [self setValue:attributeContent forKey:attributeName];
            }
        }
        @catch (NSException *ex) {
            NSLog(@"setAttributes setValue:%@ forKey:%@ error [%@]", attributeContent, attributeName, [attributeContent class]);
        }
    }
}


- (BOOL)setChilds:(id)data
{
    if (data && [data isKindOfClass:[NSDictionary class]])
    {
        NSString *nodeName = [data valueForKey:@"nodeName"];
        id nodeContent = [data valueForKey:@"nodeContent"];
        
        if ([nodeContent isKindOfClass:[NSString class]] && [nodeContent length] > 0)
            nodeContent = [NBPhoneNumberManager stringByTrimming:nodeContent];
        
        // [TYPE] PhoneNumberDesc
        if ([nodeName isEqualToString:@"generalDesc"] || [nodeName isEqualToString:@"fixedLine"] || [nodeName isEqualToString:@"mobile"] || [nodeName isEqualToString:@"shortCode"] || [nodeName isEqualToString:@"emergency"] || [nodeName isEqualToString:@"voip"] || [nodeName isEqualToString:@"voicemail"] || [nodeName isEqualToString:@"uan"] || [nodeName isEqualToString:@"premiumRate"] || [nodeName isEqualToString:@"nationalNumberPattern"] || [nodeName isEqualToString:@"sharedCost"] || [nodeName isEqualToString:@"tollFree"] || [nodeName isEqualToString:@"noInternationalDialling"] || [nodeName isEqualToString:@"personalNumber"] || [nodeName isEqualToString:@"pager"] || [nodeName isEqualToString:@"areaCodeOptional"])
        {
            [self setNumberDescData:data];
            return YES;
        }
        else if ([nodeName isEqualToString:@"availableFormats"])
        {
            [self setNumberFormatsData:data];
            return YES;
        }
        else if ([nodeName isEqualToString:@"comment"] == NO && [nodeContent isKindOfClass:[NSString class]])
        {
            [self setValue:nodeContent forKey:nodeName];
            return YES;
        }
        else if ([nodeName isEqualToString:@"comment"])
        {
            return YES;
        }
    }
    
    return NO;
}


- (void)setNumberFormatsData:(id)data
{
    NSArray *nodeChildArray = [data valueForKey:@"nodeChildArray"];
    
    for (id childNumberFormat in nodeChildArray)
    {
        NSArray *nodeChildAttributeNumberFormatArray = [childNumberFormat valueForKey:@"nodeAttributeArray"];
        NSArray *nodeChildNodeNumberFormatArray = [childNumberFormat valueForKey:@"nodeChildArray"];
        
        NSString *nodeName = [childNumberFormat valueForKey:@"nodeName"];
        
        if ([nodeName isEqualToString:@"numberFormat"])
        {
            NBNumberFormat *newNumberFormat = [[NBNumberFormat alloc] init];
            
            for (id childAttribute in nodeChildAttributeNumberFormatArray)
            {
                NSString *childNodeName = [childAttribute valueForKey:@"attributeName"];
                NSString *childNodeContent = nil;
                
                if ([childNodeName isEqualToString:@"comment"])
                {
                    continue;
                }
                
                childNodeContent = [NBPhoneNumberManager stringByTrimming:[childAttribute valueForKey:@"nodeContent"]];
                
                @try {
                    [newNumberFormat setValue:childNodeContent forKey:childNodeName];
                }
                @catch (NSException *ex) {
                    NSLog(@"nodeChildAttributeArray setValue:%@ forKey:%@ error [%@] %@", childNodeContent, childNodeName, [childNodeContent class], childAttribute);
                }
            }
            
            for (id childNode in nodeChildNodeNumberFormatArray)
            {
                NSString *childNodeName = [childNode valueForKey:@"nodeName"];
                NSString *childNodeContent = nil;
                
                if ([childNodeName isEqualToString:@"comment"])
                {
                    continue;
                }
                
                childNodeContent = [NBPhoneNumberManager stringByTrimming:[childNode valueForKey:@"nodeContent"]];
                
                @try {
                    if ([childNodeName isEqualToString:@"leadingDigits"])
                    {
                        [newNumberFormat.leadingDigitsPattern addObject:childNodeContent];
                    }
                    else
                    {
                        if ([[childNodeContent lowercaseString] isEqualToString:@"true"])
                        {
                            [newNumberFormat setValue:[NSNumber numberWithBool:YES] forKey:childNodeName];
                        }
                        else if ([[childNodeContent lowercaseString] isEqualToString:@"false"])
                        {
                            [newNumberFormat setValue:[NSNumber numberWithBool:NO] forKey:childNodeName];
                        }
                        else
                        {
                            [newNumberFormat setValue:childNodeContent forKey:childNodeName];
                        }
                    }
                }
                @catch (NSException *ex) {
                    NSLog(@"nodeChildArray setValue:%@ forKey:%@ error [%@] %@", childNodeContent, childNodeName, [childNodeContent class], childNode);
                }
            }
            [self.numberFormats addObject:newNumberFormat];
        }
        else if ([nodeName isEqualToString:@"comment"] == NO)
        {
            NSLog(@"process ========== %@", childNumberFormat);
        }
    }
}


- (void)setNumberDescData:(id)data
{
    NSString *nodeName = [data valueForKey:@"nodeName"];
    NSArray *nodeChildArray = [data valueForKey:@"nodeChildArray"];
    
    NBPhoneNumberDesc *newNumberDesc = [[NBPhoneNumberDesc alloc] init];
    
    for (id childNode in nodeChildArray)
    {
        NSString *childNodeName = [childNode valueForKey:@"nodeName"];
        NSString *childNodeContent = [NBPhoneNumberManager stringByTrimming:[childNode valueForKey:@"nodeContent"]];
        
        if ([childNodeName isEqualToString:@"comment"])
        {
            continue;
        }
        
        @try {
            if (childNodeContent && childNodeContent.length > 0)
            {
                [newNumberDesc setValue:childNodeContent forKey:childNodeName];
            }
        }
        @catch (NSException *ex) {
            NSLog(@"setNumberDesc setValue:%@ forKey:%@ error [%@]", childNodeContent, childNodeName, [childNodeContent class]);
        }
    }
    
    nodeName = [nodeName lowercaseString];
    
    if ([nodeName isEqualToString:[@"generalDesc" lowercaseString]])
        self.generalDesc = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"fixedLine" lowercaseString]])
        self.fixedLine = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"mobile" lowercaseString]])
        self.mobile = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"tollFree" lowercaseString]]) {
        [self setTollFree:newNumberDesc];
    }
    
    if ([nodeName isEqualToString:[@"premiumRate" lowercaseString]])
        self.premiumRate = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"sharedCost" lowercaseString]]) {
        self.sharedCost = newNumberDesc;
    }
    
    if ([nodeName isEqualToString:[@"personalNumber" lowercaseString]])
        self.personalNumber = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"voip" lowercaseString]])
        self.voip = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"pager" lowercaseString]])
        self.pager = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"uan" lowercaseString]])
        self.uan = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"emergency" lowercaseString]])
        self.emergency = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"voicemail" lowercaseString]])
        self.voicemail = newNumberDesc;
    
    if ([nodeName isEqualToString:[@"noInternationalDialling" lowercaseString]])
        self.noInternationalDialling = newNumberDesc;
    
    [self updateDescriptions];
}
*/

@end