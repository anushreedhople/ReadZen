
#import <Foundation/Foundation.h>

@interface UIWebView (SearchWebView)

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;


- (void)highlightButtonString:(NSString*)str withColor:(NSString *)color;
- (NSInteger)highlightString:(NSString*)str;
- (void)highlightString:(NSString*)str withColor:(NSString *)color;
- (NSString *)getHTML;
- (NSInteger)highlightAllOccurencesOfStringInBlue:(NSString*)str ;
@end