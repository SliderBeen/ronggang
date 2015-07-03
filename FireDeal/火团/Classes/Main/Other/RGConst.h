#ifdef DEBUG
#define RGLog(...) NSLog(__VA_ARGS__)
#else
#define RGLog(...)
#endif



#define RGColor(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define RGGlobalBg RGColor(230,230,230)

#define RGNotificationCenter [NSNotificationCenter defaultCenter]

extern NSString *const RGCityDidChangeNotification;
extern NSString *const RGSelectCityName;

extern NSString *const RGSortDidChangeNotification;
extern NSString *const RGSelectSort;

extern NSString *const RGCategoryDidChangeNotification;
extern NSString *const RGSelectCategory;
extern NSString *const RGSelectSubCategoryName;

extern NSString *const RGRegionDidChangeNotification;
extern NSString *const RGSelectRegion;
extern NSString *const RGSelectSubRegionName;

extern NSString *const RGCollectDidChangeNotification;
extern NSString *const RGIsCollectedKey;
extern NSString *const RGCollectDealKey;