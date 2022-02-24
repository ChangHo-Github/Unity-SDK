using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;

public class KakaoAuth : MonoBehaviour
{
    [SerializeField]
    private Text infoText;

    [DllImport("__Internal")]
    static extern void _KakaoSignIn();
    [DllImport("__Internal")]
    static extern void _KakaoSignOut();
    [DllImport("__Internal")]
    static extern void _KakaoUnlink();

    public void KakaoSignIn()
    {
        infoText.text += "KakaoSignIn\n";
#if UNITY_ANDROID
        AndroidJavaObject plugin = new AndroidJavaObject("com.unity3d.player.KakaoAuth");
        plugin.Call("KakaoSignIn");
#elif UNITY_IOS
        _KakaoSignIn();
#endif
    }

    public void KakaoSignOut()
    {
        infoText.text += "KakaoSignOut\n";
#if UNITY_ANDROID
        AndroidJavaObject plugin = new AndroidJavaObject("com.unity3d.player.KakaoAuth");
        plugin.Call("KakaoSignOut");
#elif UNITY_IOS
        _KakaoSignOut();
#endif
    }

    /* 
     * [ 사용 주의 ]
     * 카카오 계정연결을 해제하기 위해서는 로그인이 되어있어야한다.
     * 로그인 후 -> 계정연결 해제하도록 하자
     */
    public void KakaoUnlink()
    {
        infoText.text += "KakaoUnlink\n";
#if UNITY_ANDROID
        AndroidJavaObject plugin = new AndroidJavaObject("com.unity3d.player.KakaoAuth");
        plugin.Call("KakaoUnlink");
#elif UNITY_IOS
        _KakaoUnlink();
#endif
    }

    private void KakaoToken(string call)
    {
        infoText.text += $"token : {call}\n";
    }

    private void KakaoID(string call)
    {
        infoText.text += $"id : {call}\n";
    }

    private void KakaoName(string call)
    {
        infoText.text += $"name : {call}\n";
    }

    private void KakaoEmail(string call)
    {
        infoText.text += $"email : {call}\n"; 
    }

    private void KakaoProfileURL(string call)
    {
        infoText.text += $"profileURL : {call}\n";
    }

    private void KakaoPhoneNumber(string call)
    {
        infoText.text += $"phoneNumber : {call}\n";
    }

    private void KakaoEvent(string call)
    {
        infoText.text += call+ "\n";
    }

    private void KakaoError(string call)
    {
        infoText.text += call + "\n";
    }
}
