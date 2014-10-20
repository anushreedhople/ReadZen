//
//  GoogleOAuth.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 9/4/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    httpMethod_GET,
    httpMethod_POST,
    httpMethod_DELETE,
    httpMethod_PUT
} HTTP_Method;


@protocol GoogleOAuthDelegate
-(void)authorizationWasSuccessful;
-(void)accessTokenWasRevoked;
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData;
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails;
-(void)errorInResponseWithBody:(NSString *)errorMessage;
@end


@interface GoogleOAuth : UIWebView <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) id<GoogleOAuthDelegate> gOAuthDelegate;

// The client ID from the Google Developers Console.
@property (nonatomic, strong) NSString *clientID;
// The client secret value from the Google Developers Console.
@property (nonatomic, strong) NSString *clientSecret;
// The redirect URI after the authorization code gets fetched. For mobile applications it is a standard value.
@property (nonatomic, strong) NSString *redirectUri;
// The authorization code that will be exchanged with the access token.
@property (nonatomic, strong) NSString *authorizationCode;
// The refresh token.
@property (nonatomic, strong) NSString *refreshToken;
// An array for storing all the scopes we want authorization for.
@property (nonatomic, strong) NSMutableArray *scopes;

// A NSURLConnection object.
@property (nonatomic, strong) NSURLConnection *urlConnection;
// The mutable data object that is used for storing incoming data in each connection.
@property (nonatomic, strong) NSMutableData *receivedData;

// The file name of the access token information.
@property (nonatomic, strong) NSString *accessTokenInfoFile;
// The file name of the refresh token.
@property (nonatomic, strong) NSString *refreshTokenFile;
// A dictionary for keeping all the access token information together.
@property (nonatomic, strong) NSMutableDictionary *accessTokenInfoDictionary;

// A flag indicating whether an access token refresh is on the way or not.
@property (nonatomic) BOOL isRefreshing;

// The parent view where the webview will be shown on.
@property (nonatomic, strong) UIView *parentView;


-(void)authorizeUserWithClienID:(NSString *)client_ID andClientSecret:(NSString *)client_Secret
                  andParentView:(UIView *)parent_View andScopes:(NSArray *)scopes;
-(void)revokeAccessToken;
-(void)logoutUser;
-(void)callAPI:(NSString *)apiURL withHttpMethod:(HTTP_Method)httpMethod
postParameterNames:(NSArray *)params postParameterValues:(NSArray *)values;

/*methods which are part of the authorization flow */
-(void)showWebviewForUserLogin;
-(void)exchangeAuthorizationCodeForAccessToken;
-(void)refreshAccessToken;

/* auxiliary methods whose role is to support the authorization flow by implementing other necessary operations in order the whole procedure properly works.*/
-(NSString *)urlEncodeString:(NSString *)stringToURLEncode;
-(void)storeAccessTokenInfo;
-(void)loadAccessTokenInfo;
-(void)loadRefreshToken;
-(BOOL)checkIfAccessTokenInfoFileExists;
-(void)removeAccessTokenInfoFile;
-(BOOL)checkIfRefreshTokenFileExists;
-(BOOL)checkIfShouldRefreshAccessToken;
-(void)makeRequest:(NSMutableURLRequest *)request;


-(void)webViewDidFinishLoad:(UIWebView *)webView;

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end

