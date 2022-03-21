using Firebase.Auth;
using Google;
using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

public struct Result
{
    public string result;
    public string token;
}

public class GoogleAuth : MonoBehaviour
{
    private Result result;
    private string token;

    [SerializeField]
    private Text debug;

    void Start()
    {
        GoogleSignIn.Configuration = new GoogleSignInConfiguration
        {
            UseGameSignIn = false,
            RequestIdToken = true,
            // Copy this value from the google-service.json file.
            // oauth_client with type == 3
            WebClientId = "164116676290-gfvtvp8eoe343cghp49to6piqdudg4ug.apps.googleusercontent.com"
        };
    }

    public void SignIn()
    {
        debug.text += "로그인 시작 \n";

        Task<GoogleSignInUser> signIn = GoogleSignIn.DefaultInstance.SignIn();

        TaskCompletionSource<FirebaseUser> signInCompleted = new TaskCompletionSource<FirebaseUser>();
        signIn.ContinueWith(task => {
            if (task.IsCanceled)
            {
                debug.text += "로그인 취소 \n";
                signInCompleted.SetCanceled();
            }
            else if (task.IsFaulted)
            {
                debug.text += "로그인 에러"+ task.Exception +"\n";
                signInCompleted.SetException(task.Exception);
            }
            else
            {
                debug.text += "파이어베이스 등록 \n";
                debug.text += task.Result.IdToken + "\n";
                token = task.Result.IdToken;

                StartCoroutine(Action());

                //FirebaseAuth auth = FirebaseAuth.DefaultInstance;

                //Credential credential = GoogleAuthProvider.GetCredential(((Task<GoogleSignInUser>)task).Result.IdToken, null);
                //auth.SignInWithCredentialAsync(credential).ContinueWith(authTask => {
                //    if (authTask.IsCanceled)
                //    {
                //        signInCompleted.SetCanceled();
                //    }
                //    else if (authTask.IsFaulted)
                //    {
                //        signInCompleted.SetException(authTask.Exception);
                //    }
                //    else
                //    {
                //        signInCompleted.SetResult(((Task<FirebaseUser>)authTask).Result);

                //        token = task.Result.UserId;
                //        debug.text += task.Result.UserId + "\n";
                        

                //    }
                //});
            }
        });
    }

    IEnumerator Action()
    {
        debug.text += "Server call back" + "\n";

        string url = "https://auth.awesomeserver.kr/auth/oauth2?token=" + token;
        using (UnityWebRequest request = UnityWebRequest.Get(url))
        {
            yield return request.SendWebRequest();

            if (request.result != UnityWebRequest.Result.Success)
            {

            }
            else
            {
                result = JsonConvert.DeserializeObject<Result>(request.downloadHandler.text);
                debug.text += result.result + "\n";
            }
        }
    }
}
