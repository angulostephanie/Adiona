//
//  CustomClusterRenderer.h
//  safetyApp
//
//  Created by Amy Xiong on 7/27/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

#ifndef CustomClusterRenderer_h
#define CustomClusterRenderer_h

/* Copied from GMUDefaultClusterRenderer.h"*/

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

#import "GMUClusterRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@class GMSMapView;
@class GMSMarker;
@protocol GMUClusterIconGenerator;

/**
 * Default cluster renderer which shows clusters as markers with specialized icons.
 * There is logic to decide whether to expand a cluster or not depending on the number of
 * items or the zoom level.
 * There is also some performance optimization where only clusters within the visisble
 * region are shown.
 */
@interface CustomClusterRenderer : NSObject<GMUClusterRenderer>

/**
 * Animates the clusters to achieve splitting (when zooming in) and merging
 * (when zooming out) effects:
 * - splitting large clusters into smaller ones when zooming in.
 * - merging small clusters into bigger ones when zooming out.
 *
 * NOTES: the position to animate to/from for each cluster is heuristically
 * calculated by finding the first overlapping cluster. This means that:
 * - when zooming in:
 *    if a cluster on a higher zoom level is made from multiple clusters on
 *    a lower zoom level the split will only animate the new cluster from
 *    one of them.
 * - when zooming out:
 *    if a cluster on a higher zoom level is split into multiple parts to join
 *    multiple clusters at a lower zoom level, the merge will only animate
 *    the old cluster into one of them.
 * Because of these limitations, the actual cluster sizes may not add up, for
 * example people may see 3 clusters of size 3, 4, 5 joining to make up a cluster
 * of only 8 for non-hierachical clusters. And vice versa, a cluster of 8 may
 * split into 3 clusters of size 3, 4, 5. For hierarchical clusters, the numbers
 * should add up however.
 *
 * Default to YES.
 */@property(nonatomic) BOOL animatesClusters;

// Clusters smaller than this threshold will be expanded.
@property(nonatomic) NSUInteger kGMUMinClusterSize; // defaults to 4

// At zooms above this level, clusters will be expanded.
// This is to prevent cases where items are so close to each other than they are always grouped.
@property(nonatomic) float kGMUMaxClusterZoom; // defaults to 20

// Animation duration for marker splitting/merging effects.
@property(nonatomic) double kGMUAnimationDuration;  // in seconds, defaults to 0.5

// Single marker icon
@property(strong, nonatomic) UIImage *markerIcon; //d efaults to nil (i.e. default Google Maps marker)

- (instancetype)initWithMapView:(GMSMapView *)mapView
           clusterIconGenerator:(id<GMUClusterIconGenerator>)iconGenerator;

/**
 * If returns NO, cluster items will be expanded and rendered as normal markers.
 * Subclass can override this method to provide custom logic.
 */
- (BOOL)shouldRenderAsCluster:(id<GMUCluster>)cluster atZoom:(float)zoom;

@end

NS_ASSUME_NONNULL_END


#endif /* CustomClusterRenderer_h */
