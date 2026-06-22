using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Forms;
using ConvertCommon.parts;
using ConvertCommon.dto;
using ConvertCommon.Common;
using ConvertCommon;
using System.Data;
using Fnw.IOControl.DB;
using System.Linq;


namespace NKSConverter
{
  public partial class UploadForm : Form
  {
  　 private static readonly DBCtrl db = ConvertControl.DBConnectFnw();
    public string facilityCd;

    private const string MSG_EXECUTE = "コンバート実行リクエストを送信しますか？";

    private const string MSG_STOP_JOB = "※注意！ コンバート停止リクエストを送信しますか？";

    private const string MSG_DELETE_TABLE_JOB = "※注意！ コンバートDBおよび本番DBに設定されているテーブルデータを削除します。よろしいですか？";

    private const string MSG_DELETE_CONVERRT_TABLE_JOB = "※注意！ コンバートDB設定されているテーブルデータを削除します。よろしいですか？";

    private const string MSG_UPLOAD_FILE = "ファイルをサーバーに転送します。よろしいですか？";


    private const string UPLOAD_SERV_PATH_KEY = "uploadServPath";

    private const string MULTI_PART_KEY = "uploadFiles";

        public ListBox listboxMsg;
        // Add #7997 趙 Start
        public DataRow[] facilityCdList;
        // Add #7997 趙 End
        private enum ConvertJobKind
    {
      EXECUTE,
      STOP_JOB,
      DELETE_TABLE_JOB,
      UPLOADFILE,
      DELETE_CONV_TABLE_JOB,
      EXECUTERESTART
        }

        bool IS_EXECUTERESTART = false;
    public UploadForm()
    {
            InitializeComponent();
            RegisterEvent();
            // add 2020-12-11 画面表示設定 う start
            FormShowState();
            // add 2020-12-11 画面表示設定 う end

            //add #7997 start
            DataTable dt = db.SelectTable("select FACILITY_CD from SYNC_FACILITY_CD order by ID");
            comboBoxSeriesCd.DisplayMember = "FACILITY_CD";
            comboBoxSeriesCd.ValueMember = "FACILITY_CD";
            comboBoxSeriesCd.DataSource = dt;
            //add #7997 end
        }

        private void getConvertStatus()
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestStatusUrlFormat;


            IList<BatchConvertStatusDto> batchConvertStatusDtoList = HttpControl.getBatchConvertStatus(comboBoxSeriesCd.SelectedValue.ToString(), url);
            string restartStatus = string.Empty;

            if (batchConvertStatusDtoList.ToList().Count > 0)
            {
                restartStatus = batchConvertStatusDtoList[0].status; 
            }
            if (null != restartStatus && (restartStatus.Equals("STARTED") || restartStatus.Equals("STOPPED")))
            {
                btnExecuteJob.Text = "コンバート再実行\r\nリクエスト再送信";
                IS_EXECUTERESTART = true;
            }
            else {
                btnExecuteJob.Text = "コンバート再実行\r\nリクエスト送信";
                IS_EXECUTERESTART = false;
            }
        }
        // add 2020-12-11 画面表示設定 う start
        public void FormShowState()
    {
        this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
    }
    // add 2020-12-11 画面表示設定 う end

    private void RegisterEvent()
    {
      btnChooseFile.Click += new EventHandler(BtnChooseFile_Click);
      btnExecuteJob.Click += new EventHandler(BtnExecuteJob_Click);
      btnDeleteTable.Click += new EventHandler(BtnDeleteTable_Click);
      btnDeleteConvTable.Click += new EventHandler(BtnDeleteConvTable_Click);
      btnStopJob.Click += new EventHandler(BtnStopJob_Click);
      btnUpload.Click += new EventHandler(BtnUpload_Click);
    }

    // add FNSI-差分コンバート対応 楊 start
    // #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510) mod Start
    public bool UploadFiles(string facilityCd)
    {
        // ログ出力
        ConvertBase.WriteTraceLog("ファイルをサーバーに転送します。");
        string msg = "";
        string url = makeRequestUrl(ConvertJobKind.UPLOADFILE);

        string exportFolderPath = NKSConverter.Properties.Settings.Default.DefaultExportFolderPath;
        exportFolderPath += "\\" + facilityCd;

        DirectoryInfo folder = new DirectoryInfo(exportFolderPath);

        int maxFileSize = 1024 * 1024 *
            int.Parse(NKSConverter.Properties.Settings.Default.maxFileSize);

        foreach (FileInfo file in folder.GetFiles("*.Z*"))
        {
            ConvertBase.WriteTraceLog("送信対象ファイル: " + file.Name);

            long fileLength = file.Length;
            // ファイルより、アップロードファイル判定を追加する
            if (fileLength <= maxFileSize)
            {
                // ファイル直送信
                byte[] fileBytes = File.ReadAllBytes(file.FullName);

                FilePropertyDto dto = new FilePropertyDto(
                    fileBytes,
                    file.Name,
                    "application/zip"
                );

                Dictionary<string, object> parameters = new Dictionary<string, object>();
                parameters.Add(UPLOAD_SERV_PATH_KEY,
                    CommonConfig.uploadServPathValue + "/" + facilityCd);

                parameters[MULTI_PART_KEY] = dto;

                msg = FileUploadControl.MultipartPostResquest(url, parameters);

                if ("サーバ側アプリケーションに接続できません。".Equals(msg))
                {
                    return false;
                }
            }
            else
            {
                // ファイル分割送信
                ConvertBase.WriteTraceLog("ファイルが大きいため分割送信します。");

                int partIndex = 0;
                int totalParts = (int)Math.Ceiling((double)fileLength / maxFileSize);

                using (FileStream fs = new FileStream(file.FullName, FileMode.Open, FileAccess.Read))
                {
                    byte[] buffer = new byte[maxFileSize];
                    int bytesRead;

                    while ((bytesRead = fs.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        partIndex++;

                        byte[] actualData = new byte[bytesRead];
                        Array.Copy(buffer, actualData, bytesRead);

                        string partFileName = file.Name + ".part" + partIndex.ToString("D3");

                        FilePropertyDto dto = new FilePropertyDto(
                            actualData,
                            partFileName,
                            "application/octet-stream"
                        );

                        Dictionary<string, object> parameters = new Dictionary<string, object>();

                        parameters.Add(UPLOAD_SERV_PATH_KEY,
                            CommonConfig.uploadServPathValue + "/" + facilityCd);

                        parameters["originalFileName"] = file.Name;
                        parameters["partIndex"] = partIndex;
                        parameters["totalParts"] = totalParts;
                        parameters[MULTI_PART_KEY] = dto;

                        msg = FileUploadControl.MultipartPostResquest(url, parameters);

                        if ("サーバ側アプリケーションに接続できません。".Equals(msg))
                        {
                            return false;
                        }

                        ConvertBase.WriteTraceLog(
                            $"送信完了: {partIndex}/{totalParts}");
                    }
                }
            }

            // アップロッドされたファイルを移動
            // bakフォルダ作成
            string exportBakFolderPath = exportFolderPath + string.Format(@"\bak_{0}", DateTime.Now.ToString("yyyyMMddHHmmss"));
            if (!Directory.Exists(exportBakFolderPath))
            {
                Directory.CreateDirectory(exportBakFolderPath);
            }

            // bakフォルダに移動
            File.Move(
                Path.Combine(exportFolderPath, file.Name),
                Path.Combine(exportBakFolderPath, file.Name)
            );
        }

        // 
        return true;
    }
    // #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510) mod End
    public bool ExecuteJob()
    {

        // ログ出力
        ConvertBase.WriteTraceLog("コンバート実行リクエストを送信する。");
        // リクエストURLの作成・送信

        string msg = "";
        msg = sendWebRequest(ConvertJobKind.EXECUTE);
        if (msg == null)
        {
                //ConvertBase.WriteTraceLog ("サーバに接続できませんでした。");
                ConvertBase.WriteTraceLog("サーバ側アプリケーションに接続できません。");
                return false;
            }
        else
        {
            ConvertBase.WriteTraceLog(msg);
        }
        return true;
    }

    // add FNSI-差分コンバート対応 楊 end 
    private void BtnUpload_Click(object sender, EventArgs e)
    {
      // 確認ダイアログ
      if (!showDialog(MSG_UPLOAD_FILE))
      {
        return;
      }
      else
      {
        this.txtMessage.Text = "ファイル転送中";
        // add FNSI-メッセージ表示修正 楊 start
        this.txtMessage.Refresh();
        // add FNSI-メッセージ表示修正 楊 end
        string msg = "";
        // Del #7997 趙 Start
        //string url = makeRequestUrl(ConvertJobKind.UPLOADFILE);
        // Del #7997 趙 End

        // del settingファイルより、アップロードファイル判定を追加する 楊 start
        //Dictionary<string, object> parameters = new Dictionary<string, object>();
        //// mod  FNSI-複数施設時、ファイルパス修正 楊 start
        //// parameters.Add(NKSConverter.Properties.Settings.Default.uploadServPathKey, NKSConverter.Properties.Settings.Default.uploadServPathValue);
        //parameters.Add(NKSConverter.Properties.Settings.Default.uploadServPathKey, NKSConverter.Properties.Settings.Default.uploadServPathValue + "/" + this.facilityCd);
        //// mod  FNSI-複数施設時、ファイルパス修正 楊 end
        // del settingファイルより、アップロードファイル判定を追加する 楊 end
        List<FilePropertyDto> listFiles = new List<FilePropertyDto>();
        foreach (FileCustomDto item in ltvFiles.Items)
        {
          FilePropertyDto f = new FilePropertyDto(File.ReadAllBytes(item.fullpath), item.filename, "application/zip");
          listFiles.Add(f);
        }

        // add 2020-11/19 選定されていないアップロードファイル判定を追加する  う start
        if (txtPathBrowse.Text == "")
        {
            this.txtMessage.Text = "アップロードするファイルを選択してください";
            return;
        }
        // add 2020-11/19 選定されていないアップロードファイル判定を追加する  う end

        // add 2020-11/19 ファイルサイズ判定  う start
        // mod settingファイルより、アップロードファイル判定を追加する 楊 start
        //if (listFiles[0].File.Length < 1048576)
        //{
        //    parameters[NKSConverter.Properties.Settings.Default.multipartKey] = listFiles;
        foreach (FilePropertyDto files in listFiles) {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            // Add #7997 趙 Start
            this.facilityCd = GetStr(files.FileName);
            string url = makeRequestUrl(ConvertJobKind.UPLOADFILE);
            // Add #7997 趙 End
            parameters.Add(UPLOAD_SERV_PATH_KEY, CommonConfig.uploadServPathValue + "/" + this.facilityCd);
            
            int maxFileSize = 1024 * 1024 * int.Parse(NKSConverter.Properties.Settings.Default.maxFileSize);
            // mod settingファイルより、アップロードファイル判定を追加する 楊 end
            if (files.File.Length <= maxFileSize)
            {
                parameters[MULTI_PART_KEY] = files;

                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う start
                //await System.Threading.Tasks.TaskEx.Run(() =>
                //{
                //    msg = FileUploadControl.MultipartPostResquest(url, parameters);
                //});
                this.BeginInvoke(new Action(() =>
                {
                    msg = FileUploadControl.MultipartPostResquest(url, parameters);
                    this.txtMessage.Text = msg;
                    //if ("サーバに接続できませんでした。".Equals(msg)) {
                    if ("サーバ側アプリケーションに接続できません。".Equals(msg)) {
                        this.txtMessage.Text = "FNSi側のファイルサイズ ＜ FNW側ので、ファイルにサイズ修正してください。"; ;
                    }
                }));
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う end
            }
            else
            {
                // #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510) mod Start
                //// mod settingファイルより、アップロードファイル判定を追加する 楊 start
                ////this.txtMessage.Text = "ファイルは1048576バイト以下である。";
                //this.txtMessage.Text = "ファイルは" + NKSConverter.Properties.Settings.Default.maxFileSize + "M以下である。";
                //// mod settingファイルより、アップロードファイル判定を追加する 楊 end
                                // 大ファイルは分割して送信
                this.txtMessage.Text = "ファイルが大きいため分割送信します。";
                this.txtMessage.Refresh();
    
                int partIndex = 0;
                int totalParts = (int)Math.Ceiling((double)files.File.Length / maxFileSize);
    
                using (MemoryStream ms = new MemoryStream(files.File))
                {
                    byte[] buffer = new byte[maxFileSize];
                    int bytesRead;
                    bool uploadError = false;
    
                    while ((bytesRead = ms.Read(buffer, 0, buffer.Length)) > 0 && !uploadError)
                    {
                        partIndex++;

                        byte[] actualData = new byte[bytesRead];
                        Array.Copy(buffer, actualData, bytesRead);

                        string partFileName = files.FileName + ".part" + partIndex.ToString("D3");

                        FilePropertyDto dto = new FilePropertyDto(
                            actualData,
                            partFileName,
                            "application/octet-stream"
                        );

                        parameters["originalFileName"] = files.FileName;
                        parameters["partIndex"] = partIndex;
                        parameters["totalParts"] = totalParts;
                        parameters[MULTI_PART_KEY] = dto;
                        
                        this.txtMessage.Text = $"送信中: {partIndex}/{totalParts}";
                        this.txtMessage.Refresh();
                        msg = FileUploadControl.MultipartPostResquest(url, parameters);
    
                        if ("サーバ側アプリケーションに接続できません。".Equals(msg))
                        {
                            this.txtMessage.Text = "分割アップロード中にエラーが発生しました。";
                            uploadError = true;
                            break;
                        }
                    }
                    if (!uploadError)
                    {
                        this.txtMessage.Text = $"ファイルの分割アップロードが完了しました。 ({totalParts} 部分)";
                    }
                }
                // #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510) mod End
            }
        }
        // add 2020-11/19 ファイルサイズ判定  う end
      }
    }

    private void BtnStopJob_Click(object sender, EventArgs e)
    {
      // 確認ダイアログ
      if (!showDialog(MSG_STOP_JOB, MessageBoxIcon.Warning))
      {
        return;
      }
      else
      {
        // リクエストURLの作成・送信
        this.txtMessage.Text = "リクエスト送信中";

        string msg = "";
        // Add #7997 趙 Start
        TextBox txtMessageEdit = new TextBox();
        // Add #7997 趙 End

                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う start
                //await System.Threading.Tasks.TaskEx.Run(() => {
                //  msg = sendWebRequest(ConvertJobKind.STOP_JOB);
                //});
                this.BeginInvoke(new Action(() => {
                    // Add #7997 趙 Start
                    //for (int j = 0; j < facilityCdList.Length; j++)
                    //{
                        this.facilityCd = comboBoxSeriesCd.SelectedValue.ToString();
                        // Add #7997 趙 End
                        msg = sendWebRequest(ConvertJobKind.STOP_JOB);
                        // Mod #7997 趙 Start
                        if (msg == null)
                        {
                            //this.txtMessage.Text = "サーバに接続できませんでした。";
                            txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                           // break;
                        }
                        if ("" == txtMessageEdit.Text)
                        {
                            txtMessageEdit.Text = msg;
                        }
                        else
                        {
                            txtMessageEdit.Text = txtMessageEdit.Text + Environment.NewLine + msg;
                        }
                        this.txtMessage.Text = txtMessageEdit.Text;
                        // add FNSI-メッセージ表示修正 楊 start
                        //this.txtMessage.Text = msg;
                        // add FNSI-メッセージ表示修正 楊 end
                    //}
                    // Mod #7997 趙 End
                }));
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う end

                if (msg == null)
                {
                    //this.txtMessage.Text = "サーバに接続できませんでした。";
                    txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                }
               
            }
        }

    private void BtnDeleteTable_Click(object sender, EventArgs e)
    {
            // 確認ダイアログ
            if (!showDialog("「" + comboBoxSeriesCd.SelectedValue.ToString() + "」:"+MSG_DELETE_TABLE_JOB, MessageBoxIcon.Warning))
            {
                return;
            }
            else
            {
                // リクエストURLの作成・送信
                this.txtMessage.Text = "リクエスト送信中";

                string msg = "";
                // Add #7997 趙 Start
                TextBox txtMessageEdit = new TextBox();
                // Add #7997 趙 End

                
                this.BeginInvoke(new Action(() => {
                    // Add #7997 趙 Start
                    //for (int j = 0; j < facilityCdList.Length; j++)
                    //{
                        this.facilityCd = comboBoxSeriesCd.SelectedValue.ToString();
                    // Add #7997 趙 End
                    // mod #8155 再コンバートが失敗する limingyang start
                    //msg = sendWebRequest(ConvertJobKind.DELETE_TABLE_JOB);
                    msg = sendWebRequestForDelete(CommonConfig.uploadServPathValue);
                        // mod #8155 再コンバートが失敗する limingyang end
                        // Mod #7997 趙 Start
                        if (msg == null)
                        {
                            //this.txtMessage.Text = "サーバに接続できませんでした。";
                            txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                            //break;
                        }
                        if ("" == txtMessageEdit.Text)
                        {
                            txtMessageEdit.Text = msg;
                        }
                        else
                        {
                            txtMessageEdit.Text = txtMessageEdit.Text + Environment.NewLine + msg;
                        }
                        this.txtMessage.Text = txtMessageEdit.Text;
                        // add FNSI-メッセージ表示修正 楊 start
                        //this.txtMessage.Text = msg;
                        // add FNSI-メッセージ表示修正 楊 end
                    //}
                    // Mod #7997 趙 End
                }));
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う end

                if (msg == null)
                {
                    //this.txtMessage.Text = "サーバに接続できませんでした。";
                    txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                }
            }
         
        }

        private void BtnExecuteJob_Click(object sender, EventArgs e)
        {
            //add  #10859-9 start
            if (CommonConfig.Ord_Addition.Equals("0"))
            {
                if (CommonConfig.HashValueSet.TryGetValue(comboBoxSeriesCd.SelectedValue.ToString(), out var value))
                {
                    facilityCd = $"[\"{value}\"]";
                }
                string urlOrd = NKSConverter.Properties.Settings.Default.ConvergetOrdMainFormat;
                string result = HttpControl.sendWebRequestPost(urlOrd, new Dictionary<String, String> { { "facilityCd", facilityCd } });
                if (!string.IsNullOrEmpty(result))
                {
                    if (!result.Equals("0"))
                    {
                        string sMessage = "既に透析情報がコンバートされています。" + System.Environment.NewLine + "このまま続けると、レコードが重複する可能性があります。" + System.Environment.NewLine + "実行しますか？";
                        if (MessageBox.Show(sMessage, "", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No)
                        {
                            return;
                        }

                    }
                }
            }         
            //add  #10859-9 end

            // 確認ダイアログ
            if(!showDialog(MSG_EXECUTE))
            {
                return;
            }
            else
            {
                // リクエストURLの作成・送信
                this.txtMessage.Text = "リクエスト送信中";
                // add FNSI-メッセージ表示修正 楊 start
                this.txtMessage.Refresh();
                // add FNSI-メッセージ表示修正 楊 end

                string msg = "";
                // Add #7997 趙 Start
                TextBox txtMessageEdit = new TextBox();
                // Add #7997 趙 End
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う start
                //await System.Threading.Tasks.TaskEx.Run(() => {
                //  msg = sendWebRequest(ConvertJobKind.EXECUTE);
                //});
                this.BeginInvoke(new Action(() => {
                    // Add #7997 趙 Start
                    ConvertForm f1;
                    f1 = (ConvertForm)this.Owner;
                    //for (int j = 0; j < facilityCdList.Length; j++)
                    //{
                        this.facilityCd = comboBoxSeriesCd.SelectedValue.ToString();
                    // Add #7997 趙 End
                            if (IS_EXECUTERESTART) {
                                msg = sendWebRequest(ConvertJobKind.EXECUTERESTART);
                            }
                            else {
                                msg = sendWebRequest(ConvertJobKind.EXECUTE);
                            }
                        
                        if (msg == null)
                        {
                            //this.txtMessage.Text = "サーバに接続できませんでした。";
                            txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                            // Add #7997 趙 Start
                            //break;
                            // Add #7997 趙 End
                        }
                        else //戻りデータを表示する  う
                        {
                           CommonConfig.FacilityCd = comboBoxSeriesCd.SelectedValue.ToString();
                           CommonConfig.dtSeriesCdAndFacilityCdSet.Add(comboBoxSeriesCd.SelectedValue.ToString());
                           if ("" == txtMessageEdit.Text)
                            {
                                txtMessageEdit.Text = msg;
                            }
                            else
                            {
                                txtMessageEdit.Text = txtMessageEdit.Text + Environment.NewLine + msg;
                            }
                            this.txtMessage.Text = txtMessageEdit.Text;
                            //mod #7997 進捗バー 修正　start
                            f1.ShowConvertLogStart(comboBoxSeriesCd.SelectedValue.ToString());
                            f1.ShowProgressStart(false, comboBoxSeriesCd.SelectedValue.ToString());
                            //mod 7997 進捗バー修正 end
                        }
                    //}
                }));
                // mod 2020-11-25 FNSI-仕様修正 .net framework (v3.5)から(v4.5)にアップグレードされた問題 う end

            }
        }

        private void BtnChooseFile_Click(object sender, EventArgs e)
    {
      System.IO.Stream myStream;
      openFileDialog1 = new OpenFileDialog
      {
      	// mod settingファイルより、アップロードファイル判定を追加する 楊 start
      	//Filter = "ZIP Files (*.zip)|*.zip|All files (*.zip)|*.zip",
        Filter = "ZIP Files (*.zip)|*.zip|All files (*.z*)|*.z*",
        // mod settingファイルより、アップロードファイル判定を追加する 楊 end
        FilterIndex = 2,
        RestoreDirectory = true,
        Multiselect = true
      };
      if (openFileDialog1.ShowDialog() == DialogResult.OK)
      {
        int index = 1;
        ltvFiles.Items.Clear();
        txtPathBrowse.Text = Path.GetDirectoryName(openFileDialog1.FileName);
        foreach (string file in openFileDialog1.SafeFileNames)
        {
          try
          {
            if ((myStream = openFileDialog1.OpenFile()) != null)
            {
              using (myStream)
              {
                FileCustomDto fileInfo = new FileCustomDto();
                fileInfo.filename = file;
                fileInfo.fullpath = txtPathBrowse.Text +"\\"+ fileInfo.filename;
                fileInfo.index = index;

                ltvFiles.Items.Add(fileInfo);
              }
            }
            index++;
          }
          catch (Exception ex)
          {
            MessageBox.Show("Error: Could not read file from disk. Original error: " + ex.Message);
          }
        }
      }
    }

    private bool showDialog(string msg, MessageBoxIcon icon = MessageBoxIcon.Question)
    {
      //メッセージボックスを表示する
      DialogResult result = MessageBox.Show(msg,
          "確認",
          MessageBoxButtons.YesNo,
          icon);

      //何が選択されたか調べる
      if (result == DialogResult.Yes)
      {
        //「はい」が選択された時
        return true;
      }
      else
      {
        //「いいえ」が選択された時
        return false;
      }
    }

    /// <summary>
    /// Webサーバにリクエスト送信して返答メッセージを受信して返す
    /// </summary>
    /// <param name="kind"></param>
    /// <returns></returns>
    private string sendWebRequest(ConvertJobKind kind, int retryCount = 3)
    {
      string response;
      try
      {
        //add  10333 strat
        Dictionary<string, string> parameters = new Dictionary<String, String>();
        string url = makeRequestUrl(kind, out parameters);
        response = HttpControl.sendWebRequestPost(url, parameters);
                //add  10333 end
       //string url = makeRequestUrl(kind);
       //response = HttpControl.sendWebRequest(url);
      }
      catch (Exception e)
      {
        response = e.Message;
        if (retryCount <= 0)
        {
          return response;
        } else
        {
          return sendWebRequest(kind, retryCount--);
        }
      }
      return response;
    }

    // add #8155 再コンバートが失敗する limingyang start
    private string sendWebRequestForDelete(string ip)
        {
        string response;
        try
        {
            string facilityCd = string.Empty;
            if (CommonConfig.HashValueSet.TryGetValue(this.facilityCd, out var value))
            {
                facilityCd = $"[\"{value}\"]";
            }
            //10333
            string facilityCdEncode = this.facilityCd;
            string ipAddress = ip;
            string url = NKSConverter.Properties.Settings.Default.ConvertRestDeleteTableJobUrlFormat;
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", facilityCd }, { "ip", ipAddress } };
            response = HttpControl.sendWebRequestPost(url, parameters);
            }
        catch (Exception e)
        {
            response = e.Message;
            return response;
        }
        return response;
    }
    // add #8155 再コンバートが失敗する limingyang end

    /// <summary>
    /// リクエストURLの作成
    /// </summary>
    /// <param name="kind">処理種別</param>
    /// <returns>レスポンスボディ</returns>
    private string makeRequestUrl(ConvertJobKind kind, out Dictionary<string, string> parameters)
    {
      Dictionary<string, string> part=new  Dictionary<string, string>();
            string url = "";
            string facilityCd = string.Empty;
            if (CommonConfig.HashValueSet.TryGetValue(this.facilityCd, out var value))
            {
                facilityCd = $"[\"{value}\"]";
            }
            switch (kind)
            {
                case ConvertJobKind.EXECUTE:
                    // mod  FNSI-複数施設時、ファイルパス修正 楊 start
                    string inputFilePathEncode =CommonConfig.uploadServPathValue + "/" + this.facilityCd;
                    // mod  FNSI-複数施設時、ファイルパス修正 楊 end
                    url = NKSConverter.Properties.Settings.Default.ConvertRestExecuteUrlFormat;
                    part = new Dictionary<String, String> { { "facilityCd", facilityCd }, { "inputFilePath", inputFilePathEncode } };
                    break;
                case ConvertJobKind.STOP_JOB:
                    url = NKSConverter.Properties.Settings.Default.ConvertRestStopJobUrlFormat;
                    part = new Dictionary<String, String> { { "facilityCd", facilityCd } };
                    break;
                case ConvertJobKind.DELETE_TABLE_JOB:
                    url = NKSConverter.Properties.Settings.Default.ConvertRestDeleteTableJobUrlFormat;
                    part = new Dictionary<String, String>();
                    break;
                case ConvertJobKind.DELETE_CONV_TABLE_JOB:
                    url = NKSConverter.Properties.Settings.Default.ConvertRestDeleteConvTableJobUrlFormat;
                    part = new Dictionary<String, String> { { "facilityCd", facilityCd } };
                    break;
                case ConvertJobKind.UPLOADFILE:
                    url = NKSConverter.Properties.Settings.Default.ConvertRestFileUploadUrlFormat;
                    part = new Dictionary<String, String>();
                    break;
                case ConvertJobKind.EXECUTERESTART:
                    string inputFilePathEncodeRe = CommonConfig.uploadServPathValue + "/" + this.facilityCd;
                    url = NKSConverter.Properties.Settings.Default.ConvertRestExecuteReStartUrlFormat;
                    part = new Dictionary<String, String> { { "facilityCd", facilityCd }, { "inputFilePath", inputFilePathEncodeRe } };
                    break;
            }

            parameters = part;
            return url;
    }
        private string makeRequestUrl(ConvertJobKind kind)
        {
            string url = "";
            switch (kind)
            {
                case ConvertJobKind.UPLOADFILE:
                    url = NKSConverter.Properties.Settings.Default.ConvertRestFileUploadUrlFormat;
                    url = string.Format(url,
                        CommonConfig.ConvertRestWebServerIp,
                        CommonConfig.ConvertRestWebServerPort
                        );
                    break;
            }

            return url;
        }

       

    private void BtnDeleteConvTable_Click(object sender, EventArgs e)
    {

            // 確認ダイアログ
            if (!showDialog("「" + comboBoxSeriesCd.SelectedValue.ToString() + "」:" + MSG_DELETE_CONVERRT_TABLE_JOB, MessageBoxIcon.Warning))
            {
                return;
            }
            else
            {
                // リクエストURLの作成・送信
                this.txtMessage.Text = "リクエスト送信中";
                string msg = "";
                // Add #7997 趙 Start
                TextBox txtMessageEdit = new TextBox();
                // Add #7997 趙 End
                this.BeginInvoke(new Action(() => {
                    // Add #7997 趙 Start
                    //for (int j = 0; j < facilityCdList.Length; j++)
                    //{
                        this.facilityCd = comboBoxSeriesCd.SelectedValue.ToString();
                    // Add #7997 趙 End
                    msg = sendWebRequest(ConvertJobKind.DELETE_CONV_TABLE_JOB);
                        // Mod #7997 趙 Start
                        //this.txtMessage.Text = msg;
                        if (msg == null)
                        {
                            //this.txtMessage.Text = "サーバに接続できませんでした。";
                            txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                            //break;
                        }
                        if ("" == txtMessageEdit.Text)
                        {
                            txtMessageEdit.Text = msg;
                        }
                        else
                        {
                            txtMessageEdit.Text = txtMessageEdit.Text + Environment.NewLine + msg;
                        }
                        this.txtMessage.Text = txtMessageEdit.Text;
                        // Mod #7997 趙 End
                    //}
                }));

                if (msg == null)
                {
                    //this.txtMessage.Text = "サーバに接続できませんでした。";
                    txtMessage.Text = "サーバ側アプリケーションに接続できません。";
                }
            
        }
        //ConvertForm f1 = (ConvertForm)this.Owner;
        //f1.ShowProgressStart();
    }
    // Add #7997 趙 Start
    /// <summary>
    /// 最後の_以降の内容を取得する
    /// </summary>
    /// <param name="str">取得元</param>
    /// <returns>結果</returns>
    private string GetStr(String str)
    {
        if (null == str || "" == str)
            return "";
        string[] strArrary = str.Split('-');
        if (0 == strArrary.Length)
        {
            return "";
        }
        return strArrary[0];
    }

        private void comboBoxSeriesCd_SelectedIndexChanged(object sender, EventArgs e)
        {

            getConvertStatus();
        }
        // Add #7997 趙 End
  }

}
