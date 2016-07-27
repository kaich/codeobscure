//
//  BMKClusterAlgorithm.h
//  IphoneMapSdkDemo
//
//  Created by wzy on 15/9/15.
//  Copyright © 2015年 Baidu. All rights reserved.
//

#ifndef BMKClusterAlgorithm_h
#define BMKClusterAlgorithm_h

#import <Foundation/Foundation.h>
#import "BMKClusterQuadtree.h"

/**
 * 点聚合算法
 */
@interface BMKClusterAlgorithm : NSObject

///所有的BMKQuadItem
@property (nonatomic, readonly) NSMutableArray *quadItems;
@property (nonatomic, readonly) BMKClusterQuadtree *quadtree;

///添加item
- (void)addItem:(BMKClusterItem*)clusterItem;

///清除items
- (void)clearItems;

/**
 *  cluster算法核心
 * @param zoom map的级别
 * @return BMKCluster数组
 */
- (NSArray*)getClusters:(CGFloat) zoomLevel;

@end

#endif /* BMKClusterAlgorithm_h */
