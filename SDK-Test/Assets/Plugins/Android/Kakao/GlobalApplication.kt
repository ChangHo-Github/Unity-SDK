package com.unity3d.player

import android.app.Application
import com.kakao.sdk.common.KakaoSdk
import com.kakao.sdk.common.util.Utility

class GlobalApplication : Application() {

	override fun onCreate() {
        super.onCreate()
        KakaoSdk.init(this, "048d87d3daf4310af05f2932769ca807")
        
        val keyHash = Utility.getKeyHash(this)
		println("키 해쉬 : $keyHash")
    }
}