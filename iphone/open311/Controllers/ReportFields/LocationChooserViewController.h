/**
 * @copyright 2011 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BaseMapViewController.h"

@interface LocationChooserViewController : BaseMapViewController {
    
}

@property (nonatomic, retain) NSMutableDictionary *reportForm;

- (id)initWithReport:(NSMutableDictionary *)report;
- (IBAction)handleZoomButton:(id)sender;
- (void)didChooseLocation;

@end
