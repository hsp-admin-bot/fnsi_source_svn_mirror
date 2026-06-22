using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LayoutDesignerUtilityLib;
using NKKWebAccessLib;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 Amazon S3 アクセスヘルパークラス
    /// </summary>
    public class RldAmazonS3Helper
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 接続先 URI の取得及び設定を行います。
        /// </summary>
        public string BaseUri { get; set; } = NKKWebAccess.BaseUri;

        /// <summary>
        /// 施設コードの取得及び設定を行います。
        /// </summary>
        public string FacilityCode { get; set; } = string.Empty;

        /// <summary>
        // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 姜 start
        /// アプリケーション共通設定ファイル内共通設定セクション識別子
        /// </summary>
        private const String CONFIG_COMMON_SECTION = @"Settings\CommonSection";
        public static string DownloadSourceFolder { get; private set; }
        /// <summary>
        // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 姜 end
        /// 最終エラーメッセージの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public string LastErrorMessage { get; private set; } = string.Empty;

        /// <summary>
        /// Amazon S3 バケットをファイルの保存先として使用するかどうかの取得及び設定を行います。
        /// </summary>
        public bool UseS3Bucket { get; set; } = true;

        /// <summary>
        /// 施設ごとのバケットパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public string S3Bucket { get; set; } = string.Empty;

        #endregion

        #region メンバ関数定義(公開部

        /// <summary>
        /// Amazon S3 からファイルをダウンロードします。
        /// </summary>
        /// <param name="aFileName">ダウンロードするファイル名</param>
        /// <param name="aBaseDirectory">ダウンロード先ディレクトリへのフルパス</param>
        /// <returns></returns>
        public async Task<bool> DownloadFile(long reportCode, string aFileName, string aBaseDirectory)
        {
            //if (this.UseS3Bucket)
            //    return await this.DownloadFileFromAmazonS3(aFileName, aBaseDirectory);
            //else
            //    return await this.DownloadFileFromFileStorage(aFileName, aBaseDirectory);
            return await this.DownloadFileFromAmazonS3(reportCode, aFileName, aBaseDirectory);
        }

        /// <summary>
        /// Amazon S3 へファイルをアップロードします。
        /// </summary>
        /// <param name="aFiles"></param>
        /// <returns></returns>
        public async Task<bool> UploadFile(List<string> aFiles)
        {
            if (this.UseS3Bucket)
                return await this.UploadFileToAmazonS3(aFiles);
            else
                return await this.UploadFileToFileStorage(aFiles);
        }

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// Amazon S3 へファイルをアップロードします。
        /// </summary>
        /// <param name="aFiles"></param>
        /// <returns></returns>
        public async Task<bool> UploadFileOtherFacilityCd(List<string> aFiles)
        {
            if (this.UseS3Bucket)
                return await this.UploadFileToAmazonS3OtherFacilityCd(aFiles);
            else
                return await this.UploadFileToFileStorage(aFiles);
        }
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        #endregion

        #region メンバ関数定義(非公開部)

        /// <summary>
        /// Amazon S3 からファイルをダウンロードします。
        /// </summary>
        /// <param name="aFileName">ダウンロードするファイル名</param>
        /// <param name="aBaseDirectory">ダウンロード先ディレクトリへのフルパス</param>
        /// <returns></returns>
        private async Task<bool> DownloadFileFromAmazonS3(long reportCode, string aFileName, string aBaseDirectory)
        {
            bool wRet = false;

            try
            {
                // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 姜 start
                // アプリケーション共通設定ファイル読み込み
                var wInfo = TdcLib.SystemSettingInfo.GetInstance();

                // del #11660 単体アプリの自己アップデート修正 高 start
                //if (S3Bucket.IndexOf("s3://") == -1)
                //{
                //    // 最新ファイルダウンロード先フォルダ
                //    DownloadSourceFolder = wInfo.GetSingleLineValue(CONFIG_COMMON_SECTION, "DownloadFolder", string.Empty).Trim();

                //    String pathSub = DownloadSourceFolder.Substring(0, DownloadSourceFolder.LastIndexOf("/"));
                //    this.S3Bucket = pathSub + "/" + this.S3Bucket;
                //}
                // del #11660 単体アプリの自己アップデート修正 高 end
                // add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 姜 end
                string wUri = $"{this.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_S3_DOWNLOAD}" + "/" + reportCode;

                //var wPostData = new System.Text.StringBuilder();
                //wPostData.Append("{")
                //         .AppendFormat("\"filename\": \"{0}\",", aFileName);
                //wPostData.AppendFormat("\"bucket\": \"{0}\"", this.S3Bucket);
                //wPostData.Append("}");

                var wRestRet = await NKKWebAccess.Get($"ファイルダウンロード'{aFileName}'", wUri, NKKWebAccess.SKIP_OTP);
                if (wRestRet.isLogin && wRestRet.response.IsSuccessStatusCode)
                {
                    string wJsonData = wRestRet.strContent;
                    // 受信データをバイト型配列に変換してファイルとして保存する
                    if (!string.IsNullOrEmpty(wJsonData))
                    {
                        string wFilePath = $@"{aBaseDirectory}\{aFileName}";

                        using (var wStream = System.IO.File.Create(wFilePath))
                            for (int i = 0; i < wJsonData.Length / 2; i++)
                                wStream.WriteByte(Convert.ToByte(wJsonData.Substring(i * 2, 2), 16));

                        wRet = true;
                    }
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// Amazon S3 へファイルをアップロードします。
        /// </summary>
        /// <param name="aFiles"></param>
        /// <returns></returns>
        private async Task<bool> UploadFileToAmazonS3(List<string> aFiles)
        {
            bool wRet = false;

            try
            {
                System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12;

                string wUri = $"{this.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_S3_UPLOAD}";

                using (var wContent = new System.Net.Http.MultipartFormDataContent())
                {

                    wContent.Add(new System.Net.Http.StringContent(Convert.ToBase64String(NKKWebAccess.Encoding.GetBytes(this.FacilityCode))), "facilityCd");

                    foreach (string wFilePath in aFiles)
                    {
                        var wFileContent = new System.Net.Http.StreamContent(System.IO.File.OpenRead(wFilePath));

                        // mod 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                        //wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                        //{
                        //    Name = "file",
                        //    FileName = System.IO.Path.GetFileName(wFilePath)
                        //};
                        // upd 2021-04-14 #4105:帳票レイアウトデザイナーのレイアウト作成後の保存処理不正の修正 趙 start
                        //if (SignInLib.SignIn.SignInInfo.FacilityCode.Equals(LayoutDesignerUtility.CurrentFacilityCd))
                        //{
                        //    wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                        //    {
                        //        Name = "file",
                        //        FileName = System.IO.Path.GetFileName(wFilePath)
                        //    };
                        //}
                        //else {
                        //    wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                        //    {
                        //        Name = "file",
                        //        FileName = LayoutDesignerUtility.CurrentFacilityName + "_" + System.IO.Path.GetFileName(wFilePath)
                        //    };
                        //}
                        if (!string.IsNullOrEmpty(LayoutDesignerUtility.CurrentFacilityCd)
                            && "1".Equals(SignInLib.SignIn.SignInInfo.UserType)
                            && !SignInLib.SignIn.SignInInfo.FacilityCode.Equals(LayoutDesignerUtility.CurrentFacilityCd))
                        {
                            wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                            {
                                Name = "file",
                                FileName = LayoutDesignerUtility.CurrentFacilityName + "_" + System.IO.Path.GetFileName(wFilePath)
                            };
                        }
                        else
                        {
                            wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                            {
                                Name = "file",
                                FileName = System.IO.Path.GetFileName(wFilePath)
                            };
                        }
                        // upd 2021-04-14 #4105:帳票レイアウトデザイナーのレイアウト作成後の保存処理不正の修正 趙 end
                        // mod 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

                        wContent.Add(wFileContent);
                    }

                    // CSRF用トークンをヘッダに追加
                    wContent.Headers.Add("X-XSRF-TOKEN", NKKWebAccess.GetCSRFToken(wUri));

                    // POST処理
                    var wRes = await NKKWebAccess.HttpClient.PostAsync(wUri, wContent);

                    // 結果取得
                    if (wRes.IsSuccessStatusCode)
                    {
                        // 成功
                        this.LastErrorMessage = await wRes.Content.ReadAsStringAsync();
                        wRet = true;
                    }
                    else
                    {
                        // 失敗(ファイルアップロードAPIはエラー内容の詳細を JSON で返してくれるのでログに記録しておく)
                        string wJsonData = await wRes.Content.ReadAsStringAsync();

                        var wText = new System.Text.StringBuilder() { Length = 0 };
                        wText.AppendLine("ファイルアップロード処理失敗");

                        if (!string.IsNullOrEmpty(wJsonData))
                        {
                            var wErrList = NKKWebAccess.GetJsonData(wJsonData);
                            wErrList.ToList().ForEach(
                                err => wText.AppendFormat("{0} = '{1}'{2}", err.Key, err.Value ?? "(null)", Environment.NewLine));
                        }
                        RldUtility.WriteLog(DateTime.Now, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, wText.ToString());

                        this.LastErrorMessage = wText.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// Amazon S3 へファイルをアップロードします。
        /// </summary>
        /// <param name="aFiles"></param>
        /// <returns></returns>
        private async Task<bool> UploadFileToAmazonS3OtherFacilityCd(List<string> aFiles)
        {
            bool wRet = false;

            try
            {
                System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12;

                string wUri = $"{this.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.POST_S3_UPLOAD}";

                using (var wContent = new System.Net.Http.MultipartFormDataContent())
                {

                    wContent.Add(new System.Net.Http.StringContent(Convert.ToBase64String(NKKWebAccess.Encoding.GetBytes(this.FacilityCode))), "facilityCd");

                    foreach (string wFilePath in aFiles)
                    {
                        var wFileContent = new System.Net.Http.StreamContent(System.IO.File.OpenRead(wFilePath));

                        wFileContent.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("form-data")
                        {
                            Name = "file",
                            FileName = System.IO.Path.GetFileName(wFilePath)
                        };

                        wContent.Add(wFileContent);
                    }

                    // CSRF用トークンをヘッダに追加
                    wContent.Headers.Add("X-XSRF-TOKEN", NKKWebAccess.GetCSRFToken(wUri));

                    // POST処理
                    var wRes = await NKKWebAccess.HttpClient.PostAsync(wUri, wContent);

                    // 結果取得
                    if (wRes.IsSuccessStatusCode)
                    {
                        // 成功
                        this.LastErrorMessage = await wRes.Content.ReadAsStringAsync();
                        wRet = true;
                    }
                    else
                    {
                        // 失敗(ファイルアップロードAPIはエラー内容の詳細を JSON で返してくれるのでログに記録しておく)
                        string wJsonData = await wRes.Content.ReadAsStringAsync();

                        var wText = new System.Text.StringBuilder() { Length = 0 };
                        wText.AppendLine("ファイルアップロード処理失敗");

                        if (!string.IsNullOrEmpty(wJsonData))
                        {
                            var wErrList = NKKWebAccess.GetJsonData(wJsonData);
                            wErrList.ToList().ForEach(
                                err => wText.AppendFormat("{0} = '{1}'{2}", err.Key, err.Value ?? "(null)", Environment.NewLine));
                        }
                        RldUtility.WriteLog(DateTime.Now, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR, wText.ToString());

                        this.LastErrorMessage = wText.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end

        /// <summary>
        /// ファイルストレージからファイルをダウンロードします。
        /// </summary>
        /// <param name="aFileName"></param>
        /// <param name="aBaseDirectory"></param>
        /// <returns></returns>
        private async Task<bool> DownloadFileFromFileStorage(string aFileName, string aBaseDirectory)
        {
            bool wRet = false;

            try
            {
                // ダウンロードファイルのフルパスを作成
                string wDownloadFilePath = $"{this.S3Bucket}\\{aFileName}".Replace('/', System.IO.Path.DirectorySeparatorChar);

                // ファイルがない場合はエラー
                if (!System.IO.File.Exists(wDownloadFilePath))
                {
                    this.LastErrorMessage = "ダウンロードファイルが見つかりません。";
                    return false;
                }

                using (var wSrcStream = System.IO.File.Open(wDownloadFilePath, System.IO.FileMode.Open))
                using (var wDstStream = System.IO.File.Create($@"{aBaseDirectory}\{aFileName}"))
                    await wSrcStream.CopyToAsync(wDstStream);

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// ファイルストレージへファイルをアップロードします。
        /// </summary>
        /// <param name="aFiles"></param>
        /// <returns></returns>
        private async Task<bool> UploadFileToFileStorage(List<string> aFiles)
        {
            bool wRet = false;

            try
            {
                // ディレクトリが存在しない場合は作成
                string wUploadDirPath = this.S3Bucket.Replace('/', System.IO.Path.DirectorySeparatorChar);

                if (!System.IO.Directory.Exists(wUploadDirPath))
                    System.IO.Directory.CreateDirectory(wUploadDirPath);

                foreach (var wPath in aFiles)
                {

                    // ファイルがない場合はスキップ
                    if (!System.IO.File.Exists(wPath)) continue;

                    using (var wSrcStream = System.IO.File.Open(wPath, System.IO.FileMode.Open))
                    using (var wDstStream = System.IO.File.Create($"{wUploadDirPath}\\{System.IO.Path.GetFileName(wPath)}"))
                        await wSrcStream.CopyToAsync(wDstStream);
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        #endregion
    }
}
