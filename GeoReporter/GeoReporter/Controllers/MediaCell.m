//
//  MediaCell.m
//  GeoReporter
//
//  Created by Marius Constantinescu on 8/3/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "MediaCell.h"

@implementation MediaCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
       
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITapGestureRecognizerSelector

- (void) deleteImage:(UITapGestureRecognizer *) sender
{
    self.image.image = [UIImage imageNamed:@"camera.png"];
    self.closeImage.hidden = YES;
    self.header.text = @"Add image";
}

- (void)setCloseImage:(UIImageView *)closeImage
{
    _closeImage = closeImage;
    self.closeImage.userInteractionEnabled = YES;
    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImage:)];
    [self.closeImage addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = YES;
}
@end
