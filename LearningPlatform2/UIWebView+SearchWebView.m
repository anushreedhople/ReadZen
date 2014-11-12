@implementation UIWebView (SearchWebView)

- (NSInteger)highlightOccurencesOfAllStrings:(NSString*)str {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightOccurrencesOfAllStrings('%@');",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    return [[self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"] intValue];
}

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@');",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    return [[self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"] intValue];
}


- (NSInteger)highlightAllOccurencesOfStringInBlue:(NSString*)str {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfStringBlue('%@');",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    //    NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
    return [[self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"] intValue];
}




- (void)removeAllHighlights {
    NSLog(@"Remove all highlights is called------");
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

- (void)highlightString:(NSString*)str {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"stylizeHighlightedString('%@');",@"yellow"];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    //    NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
}


- (void)highlightButtonString:(NSString*)str withColor:(NSString *)color{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"stylizeButtonString('%@');",color];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    //    NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
}



- (void)highlightString:(NSString*)str withColor:(NSString *)color {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"stylizeHighlightedString('%@');",color];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    //    NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
}





- (NSString *)getHTML {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"getSelectionHTML()"];
    return [self stringByEvaluatingJavaScriptFromString:startSearch];
    
}



@end