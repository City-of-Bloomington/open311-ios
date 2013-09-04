//
//  NBPhoneNumberUtil.h
//  Band
//
//  Created by NHN Corp. Last Edited by BAND dev team (band_dev@nhn.com)
//

#import <Foundation/Foundation.h>
#import "NBPhoneNumberDefines.h"

@class NBPhoneMetaData, NBPhoneNumber;

@interface NBPhoneNumberUtil : NSObject

+ (NBPhoneNumberUtil*)sharedInstance;
+ (NBPhoneNumberUtil*)sharedInstanceForTest;

// regular expressions
- (NSArray*)matchesByRegex:(NSString*)sourceString regex:(NSString*)pattern;
- (NSArray*)matchedStringByRegex:(NSString*)sourceString regex:(NSString*)pattern;
- (NSString*)replaceStringByRegex:(NSString*)sourceString regex:(NSString*)pattern withTemplate:(NSString*)templateString;
- (int)stringPositionByRegex:(NSString*)sourceString regex:(NSString*)pattern;


+ (NSString*)stringByTrimming:(NSString*)aString;

//- (NSString*)numbersOnly:(NSString*)phoneNumber;
- (NSArray*)regionCodeFromCountryCode:(UInt32)countryCodeNumber;
- (NSString*)countryCodeFromRegionCode:(NSString*)regionCode;


// libPhoneNumber Util functions
- (NSString*)convertAlphaCharactersInNumber:(NSString*)number;

- (NSString*)normalizePhoneNumber:(NSString*)phoneNumber;
- (NSString*)normalizeDigitsOnly:(NSString*)number;

- (BOOL)isNumberGeographical:(NBPhoneNumber*)phoneNumber;

- (NSString*)extractPossibleNumber:(NSString*)phoneNumber;
- (UInt32)extractCountryCode:(NSString*)fullNumber nationalNumber:(NSString**)nationalNumber;

- (NSString*)getNddPrefixForRegion:(NSString*)regionCode stripNonDigits:(BOOL)stripNonDigits;
- (NSString*)getNationalSignificantNumber:(NBPhoneNumber*)phoneNumber;

- (NBEPhoneNumberType)getNumberType:(NBPhoneNumber*)phoneNumber;

- (UInt32)getCountryCodeForRegion:(NSString*)regionCode;

- (NSString*)getRegionCodeForCountryCode:(UInt32)countryCallingCode;
- (NSArray*)getRegionCodesForCountryCode:(UInt32)countryCallingCode;
- (NSString*)getRegionCodeForNumber:(NBPhoneNumber*)phoneNumber;

- (NBPhoneNumber*)getExampleNumber:(NSString*)regionCode error:(NSError**)error;
- (NBPhoneNumber*)getExampleNumberForType:(NSString*)regionCode type:(NBEPhoneNumberType)type error:(NSError**)error;
- (NBPhoneNumber*)getExampleNumberForNonGeoEntity:(UInt32)countryCallingCode error:(NSError**)error;

- (NBPhoneMetaData*)getMetadataForNonGeographicalRegion:(UInt32)countryCallingCode;
- (NBPhoneMetaData*)getMetadataForRegion:(NSString*)regionCode;

- (BOOL)canBeInternationallyDialled:(NBPhoneNumber*)number error:(NSError**)error;

- (BOOL)truncateTooLongNumber:(NBPhoneNumber*)number error:(NSError**)error;

- (BOOL)isValidNumber:(NBPhoneNumber*)number;
- (BOOL)isViablePhoneNumber:(NSString*)phoneNumber;
- (BOOL)isAlphaNumber:(NSString*)number;
- (BOOL)isValidNumberForRegion:(NBPhoneNumber*)number regionCode:(NSString*)regionCode;
- (BOOL)isNANPACountry:(NSString*)regionCode;
- (BOOL)isLeadingZeroPossible:(UInt32)countryCallingCode;

- (NBEValidationResult)isPossibleNumberWithReason:(NBPhoneNumber*)number error:(NSError**)error;

- (BOOL)isPossibleNumber:(NBPhoneNumber*)number error:(NSError**)error;
- (BOOL)isPossibleNumberString:(NSString*)number regionDialingFrom:(NSString*)regionDialingFrom error:(NSError**)error;

- (NBEMatchType)isNumberMatch:(id)firstNumberIn second:(id)secondNumberIn error:(NSError**)error;

- (int)getLengthOfGeographicalAreaCode:(NBPhoneNumber*)phoneNumber error:(NSError**)error;
- (int)getLengthOfNationalDestinationCode:(NBPhoneNumber*)phoneNumber error:(NSError**)error;

- (BOOL)maybeStripNationalPrefixAndCarrierCode:(NSString**)numberStr metadata:(NBPhoneMetaData*)metadata carrierCode:(NSString**)carrierCode error:(NSError**)error;
- (NBECountryCodeSource)maybeStripInternationalPrefixAndNormalize:(NSString**)numberStr possibleIddPrefix:(NSString*)possibleIddPrefix error:(NSError**)error;
- (UInt32)maybeExtractCountryCode:(NSString*)number metadata:(NBPhoneMetaData*)defaultRegionMetadata
                   nationalNumber:(NSString**)nationalNumber keepRawInput:(BOOL)keepRawInput phoneNumber:(NBPhoneNumber**)phoneNumber error:(NSError**)error;

- (NBPhoneNumber*)parse:(NSString*)numberToParse defaultRegion:(NSString*)defaultRegion error:(NSError**)error;
- (NBPhoneNumber*)parseAndKeepRawInput:(NSString*)numberToParse defaultRegion:(NSString*)defaultRegion error:(NSError**)error;
- (NBPhoneNumber*)parseWithPhoneCarrierRegion:(NSString*)numberToParse error:(NSError**)error;

- (NSString*)format:(NBPhoneNumber*)phoneNumber numberFormat:(NBEPhoneNumberFormat)numberFormat error:(NSError**)error;
- (NSString*)formatByPattern:(NBPhoneNumber*)number numberFormat:(NBEPhoneNumberFormat)numberFormat userDefinedFormats:(NSArray*)userDefinedFormats error:(NSError**)error;
- (NSString*)formatNumberForMobileDialing:(NBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom withFormatting:(BOOL)withFormatting error:(NSError**)error;
- (NSString*)formatOutOfCountryCallingNumber:(NBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom error:(NSError**)error;
- (NSString*)formatOutOfCountryKeepingAlphaChars:(NBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom error:(NSError**)error;
- (NSString*)formatNationalNumberWithCarrierCode:(NBPhoneNumber*)number carrierCode:(NSString*)carrierCode error:(NSError**)error;
- (NSString*)formatInOriginalFormat:(NBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom error:(NSError**)error;
- (NSString*)formatNationalNumberWithPreferredCarrierCode:(NBPhoneNumber*)number fallbackCarrierCode:(NSString*)fallbackCarrierCode error:(NSError**)error;

- (BOOL)formattingRuleHasFirstGroupOnly:(NSString*)nationalPrefixFormattingRule;

@property (nonatomic, strong, readonly) NSString *VALID_PUNCTUATION;
@property (nonatomic, strong, readonly) NSString *VALID_DIGITS_STRING;
@property (nonatomic, strong, readonly) NSString *PLUS_CHARS_;
@property (nonatomic, strong, readonly) NSString *REGION_CODE_FOR_NON_GEO_ENTITY;
@property (nonatomic, strong, readonly) NSDictionary *DIGIT_MAPPINGS;

@end
