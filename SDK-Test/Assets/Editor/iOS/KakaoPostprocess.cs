#if UNITY_IOS
using UnityEngine;
using UnityEditor.Callbacks;
using UnityEditor;
using UnityEditor.iOS.Xcode;
using System.IO;
using System;
using System.Linq;

public static class KakaoPostprocess
{
    const string KAKAO_APP_KEY = "707868";
    const string KAKAO_URL_SCHEME = "kakao048d87d3daf4310af05f2932769ca807";

    static string ProjectPath = string.Empty;
    static string PbxProjectPath = string.Empty;

    [PostProcessBuild(999)]    // ���� �� ����Ǵ� callback func
    public static void OnPostProcessBuild(BuildTarget target, string path)
    {
        // iOS �÷����� ��츸
        if (target == BuildTarget.iOS)
        {
            ProjectPath = path;
            PbxProjectPath = PBXProject.GetPBXProjectPath(path);

            PostProcessIosProject();
        }
    }

    static void PostProcessIosProject()
    {
        ModifyProject(AddLinkerFlag);

        ModifyPlist(AddKakaoAppKey);
        ModifyPlist(AddApplicationQuerySceheme);
        ModifyPlist(AddKakaoTalkUrlScheme);

        Debug.Log("KAKAO SDK setup for iOS project");
    }

    // URL Scheme ���� �߰�
    static void AddKakaoTalkUrlScheme(PlistDocument plist)
    {
        const string CFBundleURLTypes = "CFBundleURLTypes";
        const string CFBundleURLSchemes = "CFBundleURLSchemes";

        if (!plist.root.values.ContainsKey(CFBundleURLTypes))
        {
            plist.root.CreateArray(CFBundleURLTypes);
        }

        var cFBundleURLTypesElem = plist.root.values[CFBundleURLTypes] as PlistElementArray;

        var getSocialUrlSchemesArray = new PlistElementArray();
        getSocialUrlSchemesArray.AddString(KAKAO_URL_SCHEME);

        PlistElementDict getSocialSchemeElem = cFBundleURLTypesElem.AddDict();
        getSocialSchemeElem.values[CFBundleURLSchemes] = getSocialUrlSchemesArray;
    }

    // KAKAO_APP_KEY property �߰�
    static void AddKakaoAppKey(PlistDocument plist)
    {
        plist.root.SetString("KAKAO_APP_KEY", KAKAO_APP_KEY);
    }

    // LSApplicationQueriesSchemes property �߰�
    static void AddApplicationQuerySceheme(PlistDocument plist)
    {
        const string LSApplicationQueriesSchemes = "LSApplicationQueriesSchemes";

        string[] kakaoSchemes =
            {
                "kakaokompassauth",
                KAKAO_URL_SCHEME,
                "kakaolink",
                "kakaotalk-5.9.7"
            };

        PlistElementArray appsArray;
        appsArray = plist.root.values.ContainsKey(LSApplicationQueriesSchemes) ?
                (PlistElementArray)plist.root.values[LSApplicationQueriesSchemes] :
                plist.root.CreateArray(LSApplicationQueriesSchemes);
        kakaoSchemes.ToList().ForEach(appsArray.AddString);
    }

    // ���� Linker ���� �߰�
    static void AddLinkerFlag(PBXProject project)
    {
        project.ReadFromString(File.ReadAllText(PbxProjectPath));
#if UNITY_2019_3_OR_NEWER
        string buildTarget = project.GetUnityFrameworkTargetGuid();
#else
        string buildTarget = project.TargetGuidByName(PBXProject.GetUnityTargetName());
#endif
        project.AddBuildProperty(buildTarget, "OTHER_LDFLAGS", "-all_load");
    }

    #region helpers

    // ���� ���� ���� helper
    static void ModifyProject(Action<PBXProject> modifier)
    {
        try
        {
            PBXProject project = new PBXProject();
            project.ReadFromString(File.ReadAllText(PbxProjectPath));

            modifier(project);

            File.WriteAllText(PbxProjectPath, project.WriteToString());
        }
        catch (Exception e)
        {
            Debug.LogException(e);
        }
    }

    // Info.plist ���� ���� helper
    static void ModifyPlist(Action<PlistDocument> modifier)
    {
        try
        {
            var plistInfoFile = new PlistDocument();

            string infoPlistPath = Path.Combine(ProjectPath, "Info.plist");
            plistInfoFile.ReadFromString(File.ReadAllText(infoPlistPath));

            modifier(plistInfoFile);

            File.WriteAllText(infoPlistPath, plistInfoFile.WriteToString());
        }
        catch (Exception e)
        {
            Debug.LogException(e);
        }
    }

    #endregion
}
#endif
