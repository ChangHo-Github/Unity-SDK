using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;
using AOT;

public class KakaoiOSAuth : MonoBehaviour
{
#if UNITY_IOS
    public void SendLoginKakaoIOS()
    {
        Debug.Log("@kakao - login bridge function called");
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
            _sendKakaoLogin();
        }
    }

    [DllImport("__Internal")]
    static extern void _sendKakaoLogin();

#endif
}
