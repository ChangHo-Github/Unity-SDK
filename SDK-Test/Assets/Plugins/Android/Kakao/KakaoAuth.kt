package com.unity3d.player

import com.kakao.sdk.auth.model.OAuthToken
import com.kakao.sdk.user.UserApiClient
import com.unity3d.player.UnityPlayer

class KakaoAuth {

    fun KakaoSignIn() {
        val callback: (OAuthToken?, Throwable?) -> Unit = { token, error ->
            if (error != null) {
                UnityPlayer.UnitySendMessage("GameManager", "KakaoError", "signin fail")
            } else if (token != null) {
                UnityPlayer.UnitySendMessage("GameManager", "KakaoToken", "${token.accessToken}")
                KakaoUserInfo()
            }
        }

        // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
        if (UserApiClient.instance.isKakaoTalkLoginAvailable(UnityPlayer.currentActivity)) {
            UserApiClient.instance.loginWithKakaoTalk(
                UnityPlayer.currentActivity,
                callback = callback
            )
        } else {
            UserApiClient.instance.loginWithKakaoAccount(
                UnityPlayer.currentActivity,
                callback = callback
            )
        }
    }

    fun KakaoSignOut() {
        UserApiClient.instance.logout { error ->
            if (error != null) {
                UnityPlayer.UnitySendMessage("GameManager", "KakaoError", "signout fail")
            } else {
                UnityPlayer.UnitySendMessage("GameManager", "KakaoEvent", "signout Success")
            }
        }
    }

    fun KakaoUnlink() {
        UserApiClient.instance.unlink { error ->
            if (error != null) {
               UnityPlayer.UnitySendMessage("GameManager", "KakaoError", "unlink fail") 
            } else {
               UnityPlayer.UnitySendMessage("GameManager", "KakaoEvent", "unlink Success") 
            }
        }
    }


    fun KakaoUserInfo(){
        UserApiClient.instance.me { user, error ->
            if (error != null) {
                UnityPlayer.UnitySendMessage("GameManager", "KakaoError", "userinfo load fail")
            }
            else if (user != null) {				
                UnityPlayer.UnitySendMessage("GameManager", "KakaoID", "${user.id}")
                UnityPlayer.UnitySendMessage("GameManager", "KakaoName", "${user.kakaoAccount?.profile?.nickname}")
				UnityPlayer.UnitySendMessage("GameManager", "KakaoEmail", "${user.kakaoAccount?.email}")
                UnityPlayer.UnitySendMessage("GameManager", "KakaoProfileURL", "${user.kakaoAccount?.profile?.thumbnailImageUrl}")
				UnityPlayer.UnitySendMessage("GameManager", "KakaoPhoneNumber", "${user.kakaoAccount?.phoneNumber}")
            }
        }
    }
}