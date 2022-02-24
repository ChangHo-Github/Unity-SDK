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
     * [ ��� ���� ]
     * īī�� ���������� �����ϱ� ���ؼ��� �α����� �Ǿ��־���Ѵ�.
     * �α��� �� -> �������� �����ϵ��� ����
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
        switch(call)
        {
            case "signin":
                infoText.text += "�α��� ����\n";
                break;
            case "signout":
                infoText.text += "�α׾ƿ� ����\n";
                break;
            case "unlink":
                infoText.text += "������������ ����\n";
                break;
            default:
                infoText.text += "�˼����� �̺�Ʈ�Դϴ�.\n";
                break;
        }
    }

    private void KakaoError(string call)
    {
        switch(call)
        {
            case "signin":
                infoText.text += "�α��� ���� �߻�\n";
                break;
            case "signout":
                infoText.text += "�α׾ƿ� ���� �߻�\n";
                break;
            case "unlink":
                infoText.text += "�������� ���� ���� �߻�\n";
                break;
            case "userinfo":
                infoText.text += "����� ���� �ҷ����� ���� �߻�\n";
                break;
        }
    }
}
