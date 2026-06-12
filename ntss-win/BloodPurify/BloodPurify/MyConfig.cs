using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace NKK.BloodPurify
{
    static public class MyConfig
    {
        static private readonly string ConfigFile = "BloodPurify.config";
        static private readonly string RootNodeName = "Settings";
        static private readonly string ConfigFilePath = AppCmn.GetExeDir(true) + ConfigFile;
        static private TdcLib.SystemSettingInfo Ssi = null;

        /// <summary>
        /// 本クラスの各種機能を使用する前に呼び出す必要があるメソッド(※コンストラクタ的)
        /// </summary>
        static public void Init()
        {
            if (null == Ssi)
            {
                Ssi = TdcLib.SystemSettingInfo.GetInstance();

                if (false == Ssi.Load(ConfigFilePath))
                {
                    // 読めなかったら内部的にXMLを自前作成
                    Ssi.FileName = ConfigFilePath;
                    Ssi.Document.LoadXml("<" + RootNodeName + "></" + RootNodeName + ">");
                }

                // 設定のプロパティを読みだし、自身に再セットすることで「現在存在しない設定はデフォルト値」で書き込まれる
                BaseUri = BaseUri;
                FacilityHash = FacilityHash;
                DataDir = DataDir;
                DataPickupIntervalMinutes = DataPickupIntervalMinutes;
                DataUploadIntervalMinutes = DataUploadIntervalMinutes;
                JudgeDialEndSeconds = JudgeDialEndSeconds;
                DataPickupAtCare = DataPickupAtCare;
                DownloadSourceFolder = DownloadSourceFolder;
                // add オンプレでの自己アップデートに対応 孫 start
                DownloadSourceFileName = DownloadSourceFileName;
                // add オンプレでの自己アップデートに対応 孫 end
				ClientCertificateSearchValue1 = ClientCertificateSearchValue1;
				ClientCertificateSearchValue2 = ClientCertificateSearchValue2;
            }
        }

        /// <summary>
        /// プロパティのgetterやsetterの中で自身のプロパティ名を取得
        /// </summary>
        /// <returns></returns>
        static private string GetOwnPropertyName()
        {
            StackTrace callStackTrace = new StackTrace();
            StackFrame propertyFrame = callStackTrace.GetFrame(1);
            string properyAccessorName = propertyFrame.GetMethod().Name;
            return properyAccessorName.Replace("get_", "").Replace("set_", "");
        }

        static public string BaseUri
        {
            set
            {
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach start
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value.Trim(' ', '/'));
                Ssi.Save();
                // mod 2022-04-22 #6860 最後のスラッシュを除く Thach end
            }

            get => Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "");
        }

        static public string FacilityHash
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value);
                Ssi.Save();
            }

            get => Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "");
        }

        static public string DataDir
        {
            set
            {
                // 文字列先頭が「実行ファイルの存在するフォルダパス」だった場合は「.\」と相対パスに置換して保存
                if (value.StartsWith(AppCmn.GetExeDir(true)))
                {
                    value = value.Replace(AppCmn.GetExeDir(true), @".\");
                }

                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value);
                Ssi.Save();
            }

            get => Path.GetFullPath(Ssi.GetValue(RootNodeName, GetOwnPropertyName(), @".\BloodPurifyData"));
        }

        static public int DataPickupIntervalMinutes
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value.ToString());
                Ssi.Save();
            }

            get => int.Parse(Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "15"));
        }

        static public int DataUploadIntervalMinutes
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value.ToString());
                Ssi.Save();
            }

            get => int.Parse(Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "1"));
        }

        static public int JudgeDialEndSeconds
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value.ToString());
                Ssi.Save();
            }

            get => int.Parse(Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "30"));
        }

        static public bool DataPickupAtCare
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value.ToString());
                Ssi.Save();
            }

            get => bool.Parse(Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "True"));
        }

        /// <summary>
        /// 最新ファイル取得先フォルダ
        /// </summary>
        public static string DownloadSourceFolder
        {

            set
            {
                // del #11660 単体アプリの自己アップデート修正 高 start
                //Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value);
                //Ssi.Save();
                // del #11660 単体アプリの自己アップデート修正 高 end
            }

            // mod #11660 単体アプリの自己アップデート修正 高 start
            //get => Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "");
            get => "";
            // mod #11660 単体アプリの自己アップデート修正 高 end
        }
        /// <summary>
        /// クライアント証明書検索キー値1
        /// </summary>
        static public string ClientCertificateSearchValue1
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value);
                Ssi.Save();
            }

            get => Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "");
        }

        /// <summary>
        /// クライアント証明書検索キー値2
        /// </summary>
        static public string ClientCertificateSearchValue2
        {
            set
            {
                Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value);
                Ssi.Save();
            }

            get => Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "");
        }

        /// <summary>
        /// 施設ハッシュを設定ファイルに保存(※SignInLib.frmSignIn.ShowSignInDialogに渡す用)
        /// </summary>
        /// <param argNoUseFacilityCode="施設コード(本アプリでは保存しないので未使用)"></param>
        /// <param argFacilityHash="施設ハッシュ"></param>
        /// <returns></returns>
        static public bool SaveFacilityHash(string argNoUseFacilityCode, string argFacilityHash)
        {
            FacilityHash = argFacilityHash;
            return true;
        }
		// add オンプレでの自己アップデートに対応 孫 start
        /// <summary>
        /// 最新ファイル取得先ファイル名
        /// </summary>
        public static string DownloadSourceFileName
        {

            set
            {
                // 指定ノードへ設定値を書き込む
                // del #11660 単体アプリの自己アップデート修正 高 start
                //Ssi.SetValue(RootNodeName, GetOwnPropertyName(), value);

                //// XMLファイルへ保存する
                //Ssi.Save();
                // del #11660 単体アプリの自己アップデート修正 高 end
            }

            // mod #11660 単体アプリの自己アップデート修正 高 start
            //get => Ssi.GetValue(RootNodeName, GetOwnPropertyName(), "BloodPurify.zip");
            get => "";
            // mod #11660 単体アプリの自己アップデート修正 高 end

        }
        // add オンプレでの自己アップデートに対応 孫 end
    }
}

