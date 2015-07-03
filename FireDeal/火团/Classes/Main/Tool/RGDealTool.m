//
//  RGDealTool.m
//  火团
//
//  Created by qianfeng on 15/6/30.
//  Copyright (c) 2015年 ronggang. All rights reserved.
//

#import "RGDealTool.h"
#import "FMDB.h"
#import "RGDeal.h"

@implementation RGDealTool

static FMDatabase *_db;

+ (void)initialize
{
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"deal.sqlite"];
    _db = [FMDatabase databaseWithPath:file];
    if (![_db open]) {
        return;
    }
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collect_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL);"];
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_recent_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL);"];
}


+ (NSArray *)collectDeals:(int)page;
{
    int size = 20;
    int pos = (page - 1) * size;
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect_deal ORDER BY id DESC LIMIT %d, %d;",pos, size];
    
    NSMutableArray *resultArr = [NSMutableArray array];
    while ([set next]) {
        NSData *dealData = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"deal"]];
        [resultArr addObject:dealData];
    }
    return resultArr;
}

+ (int)collectDealsCount
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS deal_count FROM t_collect_deal"];
    [set next];
    return [set intForColumn:@"deal_count"];
}

+ (void)addCollectDeal:(RGDeal *)deal
{
    NSData *dealData = [NSKeyedArchiver archivedDataWithRootObject:deal];
    [_db executeUpdateWithFormat:@"INSERT INTO t_collect_deal(deal, deal_id) VALUES(%@, %@);", dealData,deal.deal_id];
}

+ (void)removeCollectDeal:(RGDeal *)deal
{
    [_db executeUpdateWithFormat:@"DELETE FROM t_collect_deal WHERE deal_id = %@;", deal.deal_id];
}

+ (BOOL)isCollected:(RGDeal *)deal
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect_deal WHERE deal_id = %@;", deal.deal_id];

    return [set next];
    
//    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS deal_count FROM t_collect_deal WHERE deal_id = %@;", deal.deal_id];
//    [set next];
//    return [set intForColumn:@"deal_count"] == 1;
}

@end
