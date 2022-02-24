#import "UnityAppController.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
//#import "SampleOAuthViewController.h"
#import <SafariServices/SafariServices.h>
//#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>
#import "KeychainItemWrapper.h"

extern UIViewController *UnityGetGLViewController();

@interface iOSPlugin

@end

@implementation iOSPlugin

//NaverThirdPartyLoginConnection *tlogin;

+(void)getUUIDView:(NSString*)title addMessage:(NSString*) message
{
    //uuid 저장하기 위해서 키 체이닝 생성 및 초기화
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];

    NSString *uuid =  [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];

    if( uuid == nil || uuid.length == 0)
    {
        //키체인에 uuid 없으면 만들어서 저장
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);

        
        // 키체인에 uuid 저장
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];

    }

    if(uuid != nil || uuid.length == 0){
        UnitySendMessage("SNSLogin", "GetUUID", [uuid UTF8String]);
    }
    else
    {
        UnitySendMessage("SNSLogin", "GetUUID", [@"Unknown" UTF8String]);
    }
}

// kakao

+(void)kakaologInView:(NSString*)title addMessage:(NSString*)message addCallBack:(NSString*)callback
{
    [[KOSession sharedSession] close];

    [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"login failed. - error: %@", error);
        }
        else {
            NSLog(@"login succeeded.");
            UnitySendMessage("iOSPluginCallBacks", [callback UTF8String], "");
        }
    }authType:(KOAuthType)KOAuthTypeTalk, nil];
}

+(void)kakaologOutView:(NSString*)title addMessage:(NSString*) message
{
    [[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"failed to logout. - error: %@", error);
        }
        else {
            NSLog(@"logout succeeded.");
        }
    }];
}

+(void)kakaounlinkView:(NSString*)title addMessage:(NSString*) message
{
    [KOSessionTask unlinkTaskWithCompletionHandler:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"unlink logout. - error: %@", error);
        }
        else {
            NSLog(@"unlink succeeded.");
        }
    }];
}

+(void)kakaotokeninfoView:(NSString*)title addMessage:(NSString*) message
{
    [KOSessionTask accessTokenInfoTaskWithCompletionHandler:^(KOAccessTokenInfo *accessTokenInfo, NSError *error) {
        if (error) {
            switch (error.code) {
                case KOErrorDeactivatedSession:
                    NSLog(@"세션이 만료된(access_token, refresh_token이 모두 만료된 경우) 상태");
                    break;
                default:
                    NSLog(@"예기치 못한 에러. 서버 에러");
                    break;
            }
        } else {
            // 성공 (토큰이 유효함)
            NSLog(@"success request - access token info:  %@", accessTokenInfo);
        }
    }];
}

+(void)kakaogetmeView:(NSString*)title addMessage:(NSString*) message
{
    [KOSessionTask userMeTaskWithCompletion:^(NSError *error, KOUserMe *me) {
        if (error) {
            NSLog(@"사용자 정보 요청 실패: %@", error);
            UnitySendMessage("SNSLogin", "KakaoGetid", "fail");
        }
        else {
            NSLog(@"사용자 아이디: %@", me.ID);

            if (me.account.profile) {

                // 프로필 조회 성공
                NSLog(@"사용자 닉네임: %@", me.account.profile.nickname);
                NSLog(@"프로필 이미지: %@", me.account.profile.profileImageURL);

                if(me.ID != nil){
                    UnitySendMessage("SNSLogin", "KakaoGetid", [me.ID UTF8String]);
                }
                else
                {
                    UnitySendMessage("SNSLogin", "KakaoGetid", [@"Unknown" UTF8String]);
                }
                
                if(me.account.profile.profileImageURL != nil){
                    UnitySendMessage("SNSLogin", "KakaoGetprofileImg", [me.account.profile.profileImageURL.absoluteString UTF8String]);
                }
                else
                {
                    UnitySendMessage("SNSLogin", "KakaoGetprofileImg", [@"Unknown" UTF8String]);
                }
                
                if(me.account.profile.nickname != nil){
                    UnitySendMessage("SNSLogin", "KakaoGetnickname", [me.account.profile.nickname UTF8String]);
                }
                else
                {
                    UnitySendMessage("SNSLogin", "KakaoGetnickname", [@"Unknown" UTF8String]);
                }
                
                if(me.account.email != nil){
                    UnitySendMessage("SNSLogin", "KakaoGetemail", [me.account.email UTF8String]);
                }
                else
                {
                    UnitySendMessage("SNSLogin", "KakaoGetemail", [@"Unknown" UTF8String]);
                }

            } else if (me.account.profileNeedsAgreement) {

                // 프로필 조회를 위해 사용자 동의가 필요한 상황
                [[KOSession sharedSession] updateScopes:@[@"profile"]
                                        completionHandler:^(NSError *error) {
                                            if (error) {
                                                if (error.code == KOErrorCancelled) {
                                                    // 동의 안함

                                                } else {
                                                    // 기타 에러
                                                }
                                            } else {
                                                // 동의함
                                                // *** userMe를 다시 요청하면 프로필 획득 가능 ***

                                            }
                                        }];
            } else {
                // 프로필 조회 불가능 (카카오계정 프로필 정보 없음)

            }
        }
    }];
}

+(void)kakaoemailView:(NSString*)title addMessage:(NSString*) message
{
    [KOSessionTask userMeTaskWithPropertyKeys:@[@"kakao_account.email",
                        @"properties.nickname"]
            completion:^(NSError *error, KOUserMe *me) {
        if (error) {
            // fail
            NSLog(@"failed request - error: %@", error);

        } else {
            // success
            NSLog(@"사용자 아이디: %@", me.ID);
            NSLog(@"사용자 이메일: %@", me.account.email);
            NSLog(@"사용자 닉네임: %@", me.account.profile.nickname);
        }
    }];
}

+(void)kakaoupdateprofileView:(NSString*)title addMessage:(NSString*) message
{
    NSDictionary *properties = @{
        @"nickname":@"vincent"
    };

    [KOSessionTask profileUpdateTaskWithProperties:properties
                                    completionHandler:^(BOOL success, NSError *error) {

        if (error) {
            NSLog(@"failed request - error: %@", error);
        }
        else {
            NSLog(@"succeeded to set my properties.");
        }
    }];
}

// naver
/*
+(void)naverlogInView:(NSString*)title addMessage:(NSString*)message addCallBack:(NSString*)callback
{
    [self requestThirdpartyLogin];
}

+ (void)requestThirdpartyLogin
{
    // NaverThirdPartyLoginConnection의 인스턴스에 서비스앱의 url scheme와 consumer key, consumer secret, 그리고 appName을 파라미터로 전달하여 3rd party OAuth 인증을 요청한다.
    
    tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    tlogin.delegate = self;
    [tlogin setConsumerKey:kConsumerKey];
    [tlogin setConsumerSecret:kConsumerSecret];
    [tlogin setAppName:kServiceAppName];
    [tlogin setServiceUrlScheme:kServiceAppUrlScheme];
    [tlogin requestThirdPartyLogin];
}

+ (void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
    NSLog(@"Naver Access Token >>> %@", tlogin.accessToken);

    if(tlogin.accessToken != nil){
        UnitySendMessage("SNSLogin", "NaverGetid", [tlogin.accessToken UTF8String]);
    }
    else
    {
        UnitySendMessage("SNSLogin", "NaverGetid", [@"Unknown" UTF8String]);
    }
}

+(void)naverlogOutView:(NSString*)title addMessage:(NSString*) message
{
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    [tlogin requestDeleteToken];
}

+(void)navergetmeView:(NSString*)title addMessage:(NSString*) message
{
    //json

    NSString *urlString = @"https://openapi.naver.com/v1/nid/me";

    [self sendRequestWithUrlString:urlString];
}

+ (void)sendRequestWithUrlString:(NSString *)urlString {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", tlogin.accessToken];

    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *decodingString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Error happened - %@", [error description]);
            } else {
                NSLog(@"recevied data - %@", decodingString);

                if(decodingString != nil){
                    UnitySendMessage("SNSLogin", "NaverGetemail", [decodingString UTF8String]);
                }
                else
                {
                    UnitySendMessage("SNSLogin", "NaverGetemail", [@"Unknown" UTF8String]);
                }

            }
        });
    }] resume];
}

+(void)naveremailView:(NSString*)title addMessage:(NSString*) message
{

}

+(void)naverupdateprofileView:(NSString*)title addMessage:(NSString*) message
{

}
*/
// test

+(void)alertView:(NSString*)title addMessage:(NSString*) message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:defaultAction];
    [UnityGetGLViewController() presentViewController:alert animated:YES completion:nil];
}

+(void)alertConfirmationView:(NSString*)title addMessage:(NSString*)message addCallBack:(NSString*)callback
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         UnitySendMessage("iOSPluginCallBacks", [callback UTF8String], "");
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [UnityGetGLViewController() presentViewController:alert animated:YES completion:nil];
}

+(void)shareView:(NSString *)message addUrl:(NSString *)url
{
    NSURL *postUrl = [NSURL URLWithString:url];
    NSArray *postItems=@[message,postUrl];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UnityGetGLViewController() presentViewController:controller animated:YES completion:nil];
    }
    //if iPad
    else {
        UIPopoverPresentationController *popOver = controller.popoverPresentationController;
        if(popOver){
            popOver.sourceView = controller.view;
            popOver.sourceRect = CGRectMake(UnityGetGLViewController().view.frame.size.width/2, UnityGetGLViewController().view.frame.size.height/4, 0, 0);
            [UnityGetGLViewController() presentViewController:controller animated:YES completion:nil];
        }
    }
}

+(int)getBatteryStatus
{
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    return [myDevice batteryState];
}

+(NSString *)getBatteryLevel
{
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    
    double batLeft = (float)[myDevice batteryLevel] * 100;
    return [NSString stringWithFormat:@"battery left: %f", batLeft];
}

// get or load integer values
+(int)iCloudGetIntValue:(NSString *)key
{
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    return [[cloudStore objectForKey:key] intValue];
}

+(BOOL)iCloudSaveIntValue:(NSString *)key setValue:(long)value
{
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setLongLong:value forKey:key];
    return [cloudStore synchronize];
}

// get or load bool values
+(BOOL)iCloudGetBoolValue:(NSString *)key
{
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    return [[cloudStore objectForKey:key] boolValue];
}

+(BOOL)iCloudSaveBoolValue:(NSString *)key setValue:(BOOL)value
{
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setBool:value forKey:key];
    return [cloudStore synchronize];
}

// get or load string values
+(NSString *)iCloudGetStringValue:(NSString *)key
{
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    return [cloudStore objectForKey:key];
}

+(BOOL)iCloudSaveStringValue:(NSString *)key setValue:(NSString *)value
{
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:value forKey:key];
    return [cloudStore synchronize];
}

@end

char* cStringCopy(const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    
    return res;
}

extern "C"
{

    void _GetUUID(const char *title, const char *message)
    {
        [iOSPlugin getUUIDView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _KakaoLogin(const char *title, const char *message, const char *callBack)
    {
        [iOSPlugin kakaologInView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]  addCallBack:[NSString stringWithUTF8String:callBack]];
    }

    void _KakaoLogout(const char *title, const char *message)
    {
        [iOSPlugin kakaologOutView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _KakaoUnlink(const char *title, const char *message)
    {
        [iOSPlugin kakaounlinkView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _KakaoTokeninfo(const char *title, const char *message)
    {
        [iOSPlugin kakaotokeninfoView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _KakaoGetme(const char *title, const char *message)
    {
        [iOSPlugin kakaogetmeView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _KakaoUpdateprofile(const char *title, const char *message)
    {
        [iOSPlugin kakaoupdateprofileView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _KakaoEmail(const char *title, const char *message)
    {
        [iOSPlugin kakaoemailView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }
/*
    void _NaverLogin(const char *title, const char *message, const char *callBack)
    {
        [iOSPlugin naverlogInView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]  addCallBack:[NSString stringWithUTF8String:callBack]];
    }

    void _NaverLogout(const char *title, const char *message)
    {
        [iOSPlugin naverlogOutView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _NaverGetme(const char *title, const char *message)
    {
        [iOSPlugin navergetmeView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _NaverUpdateprofile(const char *title, const char *message)
    {
        [iOSPlugin naverupdateprofileView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }

    void _NaverEmail(const char *title, const char *message)
    {
        [iOSPlugin naveremailView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }
*/
    void _ShowAlert(const char *title, const char *message)
    {
        [iOSPlugin alertView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]];
    }
    
    void _ShowAlertConfirmation(const char *title, const char *message, const char *callBack)
    {
        [iOSPlugin alertConfirmationView:[NSString stringWithUTF8String:title] addMessage:[NSString stringWithUTF8String:message]  addCallBack:[NSString stringWithUTF8String:callBack]];
    }
    
    void _ShareMessage(const char *message, const char *url)
    {
        [iOSPlugin shareView:[NSString stringWithUTF8String:message] addUrl:[NSString stringWithUTF8String:url]];
    }
    
    int _GetBatteryStatus()
    {
        return [iOSPlugin getBatteryStatus];
    }
    
    const char * _GetBatteryLevel()
    {
        return cStringCopy([[iOSPlugin getBatteryLevel] UTF8String]);
    }
    
    const char * _iCloudGetStringValue(const char *key)
    {
        return cStringCopy([[iOSPlugin iCloudGetStringValue:[NSString stringWithUTF8String:key]] UTF8String]);
    }
    
    bool _iCloudSaveStringValue(const char *key, const char *value)
    {
        return [iOSPlugin iCloudSaveStringValue:[NSString stringWithUTF8String:key] setValue:[NSString stringWithUTF8String:value]];
    }
    
    int _iCloudGetIntValue(const char *key)
    {
        return [iOSPlugin iCloudGetIntValue:[NSString stringWithUTF8String:key]];
    }
    
    bool _iCloudSaveIntValue(const char *key, int value)
    {
        return [iOSPlugin iCloudSaveIntValue:[NSString stringWithUTF8String:key] setValue:value];
    }
    
    bool _iCloudGetBoolValue(const char *key)
    {
        return [iOSPlugin iCloudGetBoolValue:[NSString stringWithUTF8String:key]];
    }
    
    bool _iCloudSaveBoolValue(const char *key, bool value)
    {
        return [iOSPlugin iCloudSaveBoolValue:[NSString stringWithUTF8String:key] setValue:value];
    }
}
