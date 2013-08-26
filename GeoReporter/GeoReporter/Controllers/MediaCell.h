//
//  MediaCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 8/3/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MEDIA_CELL_HEIGHT 60

@interface MediaCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIImageView *closeImage;

@end
