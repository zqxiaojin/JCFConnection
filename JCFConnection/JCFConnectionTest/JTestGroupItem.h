//
//  JTestGroupItem.h
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTestGroupItem : NSObject

@property (nonatomic,assign)int index;
@property (nonatomic,strong)NSString* title;
@property (nonatomic,assign)Class  itemClass;

@end
