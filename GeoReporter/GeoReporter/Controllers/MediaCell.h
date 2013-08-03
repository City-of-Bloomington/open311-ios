//
//  MediaCell.h
//  GeoReporter
//
//  Created by Marius Constantinescu on 8/3/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *header;

@end
