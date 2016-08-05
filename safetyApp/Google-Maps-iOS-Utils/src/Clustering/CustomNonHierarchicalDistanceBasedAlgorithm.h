//
//  CustomNonHierarchicalDistanceBasedAlgorithm.h
//  safetyApp
//
//  Created by Amy Xiong on 7/26/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

#ifndef CustomNonHierarchicalDistanceBasedAlgorithm_h
#define CustomNonHierarchicalDistanceBasedAlgorithm_h

/* Copied from "GMUNonHierarchicalDistanceBasedAlgorithm.h"*/

#import <Foundation/Foundation.h>

#import "GMUClusterAlgorithm.h"

/**
 * A simple clustering algorithm with O(nlog n) performance. Resulting clusters are not
 * hierarchical.
 * High level algorithm:
 * 1. Iterate over items in the order they were added (candidate clusters).
 * 2. Create a cluster with the center of the item.
 * 3. Add all items that are within a certain distance to the cluster.
 * 4. Move any items out of an existing cluster if they are closer to another cluster.
 * 5. Remove those items from the list of candidate clusters.
 * Clusters have the center of the first element (not the centroid of the items within it).
 */
@interface CustomNonHierarchicalDistanceBasedAlgorithm : NSObject<GMUClusterAlgorithm>

@property(nonatomic) NSUInteger kGMUClusterDistancePoints; // default 100
@property(nonatomic) double kGMUMapPointWidth;  // MapPoint is in a [-1,1]x[-1,1] space, default 2.0

@end


#endif /* CustomNonHierarchicalDistanceBasedAlgorithm_h */
