#import <KakaoOpenSDK/KakaoOpenSDK.h>

extern "C" {
    void _KakaoSignIn()
    {
        // Close old session
        if ( ! [[KOSession sharedSession] isOpen] ) {
            NSLog(@"in isOpen condition");
            [[KOSession sharedSession] close];
            NSLog(@"Old session closed");
        }

        // session open with completion handler
        [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"login failed. - error: %@", error);
            }
            else {
                NSLog(@"login succeeded.");
            }
            
            // get user info
            [KOSessionTask userMeTaskWithCompletion:^(NSError *error, KOUserMe *me) {
                if (error){
                    NSLog(@"get user info failed. - error: %@", error);
                } else {
                    NSLog(@"get user info. - user info: %@", me);
                    
                    if(me.ID != nil)
                    {
                        UnitySendMessage("GameManager", "KakaoID", [me.ID UTF8String]);
                    }
                }
            }];
        }];
    }

    void _KakaoSignOut{
        
    }
}
