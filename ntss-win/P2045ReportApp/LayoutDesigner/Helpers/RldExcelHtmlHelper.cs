using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 HTML ドキュメント操作ヘルパークラス
    /// </summary>
    internal sealed class RldExcelHtmlHelper
    {
        #region 生成と破棄

        /// <summary>
        /// Excel 操作ヘルパークラスとパラメータ編集データリストを指定して、帳票レイアウトデザイナ用 HTML ドキュメント操作ヘルパークラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlsHelper"></param>
        /// <param name="aParamList"></param>
        public RldExcelHtmlHelper(RldExcelHelper aXlHelper, LayoutDataSet aLayoutDataSet)
        {
            XlHelper = aXlHelper;
            DataSet = aLayoutDataSet;

            var wInfo = new System.IO.FileInfo(aXlHelper.XlBookFilePath);

            // 作業用ファイルのフルパスを作成
            WorkingXlsFilePath =
                string.Format(@"{0}\{1}_html{2}", wInfo.DirectoryName, wInfo.Name.Replace(wInfo.Extension, string.Empty), wInfo.Extension);

            // テンプレート繰返しがあるかどうか確認
            HasTemplete = DataSet.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES ? true : false;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 開いている HTML ファイルへのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public string HtmlFilePath { get; private set; } = string.Empty;

        /// <summary>
        /// 最終エラー情報の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public string LastErrorMessage { get; private set; } = string.Empty;

        /// <summary>
        /// Excel 操作ヘルパークラスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private RldExcelHelper XlHelper { get; } = null;

        /// <summary>
        /// レイアウトデータセットの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private LayoutDataSet DataSet { get; } = null;

        /// <summary>
        /// 開いている HtmlDocument の取得及び設定を行います。
        /// </summary>
        private System.Windows.Forms.HtmlDocument HtmlDocument { get; set; } = null;

        /// <summary>
        /// オープン中かどうかの取得及び設定を行います。
        /// </summary>
        private bool IsOpened { get; set; } = false;

        /// <summary>
        /// テンプレート繰返しが含まれているかどうかの取得及び設定を行います。
        /// </summary>
        private bool HasTemplete { get; } = false;

        /// <summary>
        /// 割り当て済みのIDを保持するリストの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private List<string> AssignedList { get; } = new List<string>();

        /// <summary>
        /// 作業用 Excel ファイルのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private string WorkingXlsFilePath { get; }
        /// <summary>
        /// 作業用 テンプレート繰返し用 html ファイルのフルパスの取得及び設定を行います。
        /// </summary>
        private string WorkingTmplHtmlFilePath { get; set; } = string.Empty;

        #endregion

        #region メンバ関数定義(公開部)

        /// <summary>
        /// 保存先ファイルパスを指定して HTML ファイルを作成します。
        /// </summary>
        /// <param name="aHtmlFilePath">HTMLファイル名</param>
        /// <returns>HTMLファイルの作成に成功した場合 True。失敗した場合 False。</returns>
        public bool Create(string aHtmlFilePath)
        {
            bool wRet = false;

            System.Windows.Forms.HtmlDocument wMainDocument = null;

            try
            {
                // 作業用 Excel ファイルを作成する
                if (!XlHelper.Save(WorkingXlsFilePath))
                {
                    SetLastError("作業用 Excel ファイルの作成に失敗しました。");
                    return false;
                }

                // html ファイル出力用に加工する(テンプレート繰返しがある場合はテンプレート繰返し分も加工する)
                if (!XlHelper.SetSheetLayoutForOutputHtml(RldLib.CurrentLayoutData))
                {
                    SetLastError("作業用 Excel ファイルの編集に失敗しました。");
                    return false;
                }

                // html ファイル保存先ディレクトリ確認し無ければ作成
                if (!RldUtility.CheckAndCreateDirectory(System.IO.Path.GetDirectoryName(aHtmlFilePath)))
                {
                    SetLastError("HTML ファイルの保存先ディレクトリの作成に失敗しました。");
                    return false;
                }

                DateTime wNow = DateTime.Now;

                string wDivID = string.Format(
                    "{0}_{1:yyyyMMddHHmmss}", System.IO.Path.GetFileNameWithoutExtension(aHtmlFilePath), DateTime.Now);

                // レイアウトシートから html ファイルを作成
                // add #6061 エクセルで設定した倍率で印刷されない 歴程 start
                //if (!XlHelper.PublishHtmlFile(XlHelper.XlSheetLayout, aHtmlFilePath, wDivID))
                if (!XlHelper.PublishHtmlFile(XlHelper.XlSheetLayout, aHtmlFilePath, wDivID, "save"))
                // add #6061 エクセルで設定した倍率で印刷されない 歴程 end
                {
                    SetLastError("HTML ファイルの作成に失敗しました。");
                    return false;
                }

                // 作業用 Excel ファイルを閉じる
                XlHelper.Close();

                // 作業用ファイルを削除する
                _ = RldUtility.DeleteFileIfExists(WorkingXlsFilePath);

                // html ファイルを開く
                if (!OpenInner(aHtmlFilePath, ref wMainDocument))
                {
                    SetLastError("HTML ファイルのオープンに失敗しました。");
                    return false;
                }

                // html ファイルへ ID を割付
                if (!ExecAssignID(ref wMainDocument))
                {
                    SetLastError("HTML ファイルの編集に失敗しました。");
                    return false;
                }

                // オープン中のファイルとする
                HtmlDocument = wMainDocument;
                HtmlFilePath = aHtmlFilePath;
                IsOpened = true;

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// 指定された HTML ファイルを開きます。
        /// </summary>
        /// <param name="aHtmlFilePath"></param>
        /// <returns></returns>
        public bool Open(string aHtmlFilePath)
        {
            bool wRet = false;

            try
            {
                System.Windows.Forms.HtmlDocument wDocument = null;

                wRet = OpenInner(aHtmlFilePath, ref wDocument);
                if (wRet)
                {
                    HtmlDocument = wDocument;
                    HtmlFilePath = aHtmlFilePath;

                    IsOpened = true;
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// HTML ファイルを閉じます。
        /// </summary>
        public void Close()
        {
            try
            {
                if (IsOpened)
                {
                    HtmlDocument = null;
                    HtmlFilePath = string.Empty;

                    IsOpened = false;
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }

        /// <summary>
        /// HTML ファイルを保存します。
        /// </summary>
        /// <returns></returns>
        public bool Save()
        {
            return Save(HtmlFilePath);
        }

        /// <summary>
        /// 保存先ファイル名を指定して HTML ファイルを保存します。
        /// </summary>
        /// <param name="aHtmlFilePath"></param>
        /// <returns></returns>
        public bool Save(string aHtmlFilePath)
        {
            bool wRet = false;
            var pictures = new List<string>();

            try
            {
                // upd 2021-06-15 #4891："Bitmap"の文字がプレビューの上に表示される 趙 start
                System.IO.StreamReader sr = new System.IO.StreamReader(aHtmlFilePath);
                var htmlText = sr.ReadToEnd();
                if (htmlText.Contains("img"))
                {
                    string text = "<![if !vml]>";
                    int index = 0;
                    int count = 0;
                    int startindex, endindex;
                    while ((index=htmlText.IndexOf(text,index))!=-1)
                    {
                        count++;
                        startindex = index + 12;
                        endindex = htmlText.IndexOf("<![endif]>", index);
                        pictures.Add(htmlText.Substring(startindex, endindex - startindex));
                        index = index + text.Length;
                    }
                }
                sr.Dispose();
                sr.Close();
                // upd 2021-06-15 #4891："Bitmap"の文字がプレビューの上に表示される 趙 end


                // 保存先ディレクトリの存在を確認し無ければ作成
                RldUtility.CheckAndCreateDirectory(System.IO.Path.GetDirectoryName(aHtmlFilePath));

                System.Text.StringBuilder wWriteText = null;

                foreach (System.Windows.Forms.HtmlElement wElement in HtmlDocument.GetElementsByTagName("HTML"))
                {
                    wWriteText = new System.Text.StringBuilder(wElement.OuterHtml);
                }

                // 余計なシングルクォーテーションを削除する
                AssignedList.ForEach(wAssignedID => wWriteText.Replace(string.Format("'{0}'", wAssignedID), wAssignedID));

                IEnumerable<System.Windows.Forms.HtmlElement> wList = HtmlDocument.GetElementsByTagName("STYLE").Cast<System.Windows.Forms.HtmlElement>();
                foreach (System.Windows.Forms.HtmlElement wElement in wList)
                {
                    // htmlのSTYLEタグに格納するCSS
                    var styles = new List<string>();
                    foreach (DesignParamData item in this.DataSet.DesignParamList)
                    {
                        for (int i = 0; i < item.FormatCondition.Count; i++)
                        {
                            string cssClass = "fc" + item.CellAddress.Replace(":", "").ToLower() + i.ToString();
                            //item.FormatCondition[i] = (item.FormatCondition[i].comparisonOperator, item.FormatCondition[i].value, item.FormatCondition[i].font, cssClass);
                            item.FormatCondition[i].CssClass = cssClass;

                            // 改行 + タブ区切りの文字列を生成する
                            string cssDetail = "." + cssClass;
                            cssDetail += $"\r\n\t{{color:#{($"{item.FormatCondition[i].Color.ToArgb():X}".Substring(2))};";
                            cssDetail += $"\r\n\tfont-family:\"{item.FormatCondition[i].Font.Name}\", monospace;";
                            cssDetail += $"\r\n\tfont-size:{item.FormatCondition[i].Font.Size.ToString("0.0")}pt;";

                            // Bold
                            cssDetail += "\r\n\tfont-weight:";
                            if (item.FormatCondition[i].Font.Bold)
                            {
                                // Boldならばfont-weight:700;
                                cssDetail += "700";
                            }
                            else
                            {
                                // Boldでないならばfont-weight:400;
                                cssDetail += "400";
                            }
                            cssDetail += ";";

                            // Italic
                            cssDetail += "\r\n\tfont-style:";
                            if (item.FormatCondition[i].Font.Italic)
                            {
                                // Italic ならば font-style:italic;
                                cssDetail += "italic";
                            }
                            else
                            {
                                // Italic でないならば font-style:italic;
                                cssDetail += "normal";
                            }
                            cssDetail += ";";

                            // Underline
                            cssDetail += "\r\n\ttext-decoration:";
                            if (item.FormatCondition[i].Font.Underline)
                            {
                                // Underline ならば text-decoration:underline;
                                cssDetail += "underline";
                            }
                            else
                            {
                                // Underline でないならば  text-decoration:none;
                                cssDetail += "none";
                            }
                            cssDetail += ";";

                            // 背景色
                            cssDetail += $"\r\n\tbackground-color:#{($"{item.FormatCondition[i].BackColor.ToArgb():X}".Substring(2))};";
                            cssDetail += "}";

                            styles.Add(cssDetail);

                        }

                    }
                    string css = string.Join("\r\n", styles);

                    // InnerHtmlプロパティを取得すると実際にはない\r\nが先頭に付加されるので取り除く
                    string oldValue = wElement.InnerHtml.Substring(2);

                    // "harset:128;\r\n\tmso-char-type:katakana;}\r\n-->" 末尾の"\r\n"と"-->"の間に条件付き書式のCSSを挿入する
                    wWriteText.Replace(oldValue, oldValue.Insert(oldValue.Length - 3, css + "\r\n"));

                }

                // upd 2021-06-15 #4891："Bitmap"の文字がプレビューの上に表示される 趙 start

                if (wWriteText.ToString().Contains("src"))
                {
                    string text = "</v:shape>";
                    string bitmap = "Bitmap";
                    string result = string.Empty;
                    int index = 0;
                    int count = 0;
                    int startindex = 0;
                    if (wWriteText.ToString().Contains(bitmap))
                    // mod #11794 新規で作成した帳票ファイルが保存できないことがある。 高 start
                    {
                        result = System.Text.RegularExpressions.Regex.Replace(wWriteText.ToString(), bitmap, "");
                        wWriteText.Clear();
                        wWriteText.Append(result);
                    }
                    // mod #11794 新規で作成した帳票ファイルが保存できないことがある。 高 end

                    while ((index = wWriteText.ToString().IndexOf(text, index)) != -1)
                    {
                        startindex = wWriteText.ToString().IndexOf(text, index);
                        wWriteText.Insert(startindex, pictures[count].ToString());
                        index = index + text.Length + pictures[count].Length;
                        count++;
                        // mod  2021-09-02 #6370:判定条件を変更する 鄭 start
                        //if (pictures.Count == 1)
                        //    break;
                        if (pictures.Count == 1 || count == pictures.Count)
                            break;
                        // mod  2021-09-02 #6370:判定条件を変更する 鄭 end


                    }
                }

                // upd 2021-06-15 #4891："Bitmap"の文字がプレビューの上に表示される 趙 end

                // add 2021-09-15 #6436：ブラウザプレビューで翻訳オプションが表示される 李 start
                if (wWriteText.ToString().Contains("lang=ja") == false)
                {
                    wWriteText = wWriteText.Replace(">", " lang=\"ja\" >", wWriteText.ToString().IndexOf(">", wWriteText.ToString().IndexOf("xmlns:x")), 1);
                }
                else
                {
                    wWriteText = wWriteText.Replace("lang=ja", " lang=\"ja\"");
                }   
                // add 2021-09-15 #6436：ブラウザプレビューで翻訳オプションが表示される 李 end

                // upd 2021-06-02 #4891："Bitmap"の文字がプレビューの上に表示される 趙 start
                // HtmlDocument を書き出す
                using (var wStream = new System.IO.StreamWriter(aHtmlFilePath, false, new System.Text.UTF8Encoding(false)))
                {
                    wStream.Write(wWriteText);
                    wStream.Flush();
                }
                // upd 2021-06-02 #4891："Bitmap"の文字がプレビューの上に表示される 趙 end
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義(非公開部)

        /// <summary>
        /// 指定された html ファイルを開いて HtmlDocument を取得します。
        /// </summary>
        /// <param name="aHtmlFilePath">HTMLファイル名</param>
        /// <param name="aDocument">読み込んだHTML文書を格納するHtmlDocumentインスタンス</param>
        /// <returns></returns>
        private bool OpenInner(string aHtmlFilePath, ref System.Windows.Forms.HtmlDocument aDocument)
        {
            bool wRet = false;

            try
            {
                // WebBrowser コンポーネントを使用して HtmlDocument を取得する
                aDocument = GetHtmlDocument(aHtmlFilePath);
                // 正常に取得できた場合はOK
                if (aDocument != null)
                {
                    wRet = true;
                }
            }
            catch
            {
                throw;
            }

            return wRet;
        }

        /// <summary>
        /// 最終エラー情報をセットします。
        /// </summary>
        /// <param name="aText"></param>
        private void SetLastError(string aText) => LastErrorMessage = aText;

        // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
        private class tb_Element
        {
            public String ID { get; set; }
            public int Value { get; set; }
            public int oldValue { get; set; }
        }
        // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end

        /// <summary>
        /// 帳票レイアウトデザイナ管理対象要素にIDを割り当てます。
        /// </summary>
        /// <param name="aHtmlDoc">HtmlDocument</param>
        /// <returns></returns>
        private bool ExecAssignID(ref System.Windows.Forms.HtmlDocument aHtmlDoc)
        {
            bool wRet = false;

            AssignedList.Clear();

            try
            {

                // 検索対象を取得(TDタグ)
                IEnumerable<System.Windows.Forms.HtmlElement> wList = aHtmlDoc.GetElementsByTagName("TD")
                                    .Cast<System.Windows.Forms.HtmlElement>()
                                    .Where(ele => !string.IsNullOrEmpty(ele.InnerText) &&
                                           ele.InnerText.StartsWith(RldConst.PATH_HEADER));
                // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
                int wBranchNo = 0;
                List<tb_Element> strList = new List<tb_Element>();
                // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end
                // 先頭の ## を削除してIDにセット
                foreach (System.Windows.Forms.HtmlElement wElement in wList)
                {
                    // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES
                    && RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count > 0
                    && wElement.InnerText.Contains(RldLib.CurrentLayoutData.DesignTempleteData.Range))
                    {
                        
                        if ("N".Equals(RldLib.CurrentLayoutData.DesignTempleteData.DirectionData))
                        {

                            if (strList.Count == 0)
                            {
                                wBranchNo++;
                                strList.Add(new tb_Element { ID = wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT) + 1), Value = wBranchNo, oldValue = 0 });
                            }
                            else
                            {
                                var model = strList.Where(c => c.ID.Equals(wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT) + 1))).FirstOrDefault();
                                if (model != null)
                                {
                                    if (model.Value == ((int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH) -1) * 
                                        int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV)) + 1 + model.oldValue)
                                    {
                                        model.oldValue++;
                                        wBranchNo = model.oldValue + 1;
                                    }
                                    else
                                    {
                                        wBranchNo = model.Value + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV);
                                    }
                                    
                                    model.Value = wBranchNo;
                                }
                                else
                                {
                                    wBranchNo = 1;
                                    strList.Add(new tb_Element { ID = wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT) + 1), Value = wBranchNo = 1, oldValue = 0 });
                                }
                            }
                        }
                        else
                        {
                            if (strList.Count == 0)
                            {
                                wBranchNo++;
                                strList.Add(new tb_Element { ID = wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT) + 1), Value = wBranchNo });
                            }
                            else
                            {
                                var model = strList.Where(c => c.ID.Equals(wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT) + 1))).FirstOrDefault();
                                if (model != null)
                                {
                                    wBranchNo = model.Value;
                                    wBranchNo++;
                                    model.Value = wBranchNo;
                                }
                                else
                                {
                                    wBranchNo = 1;
                                    strList.Add(new tb_Element { ID = wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT) + 1), Value = wBranchNo });
                                }
                            }                            
                        }
                        wElement.InnerText = string.Format(
                                                "{0}{1}{2}",
                                                wElement.InnerText.Substring(0, wElement.InnerText.IndexOf("-") + 1),
                                                wBranchNo,
                                                wElement.InnerText.Substring(wElement.InnerText.IndexOf(RldConst.PATH_SPLIT)));
                    }
                    // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end

                    wElement.Id = "\"" + wElement.InnerText.Remove(0, RldConst.PATH_HEADER.Length) + "\"";
                    wElement.InnerText = string.Empty;

                    AssignedList.Add(wElement.Id);
                }

                wRet = true;
            }
            catch
            {
                throw;
            }

            return wRet;
        }

        /// <summary>
        /// 指定されたファイルを HtmlDocument クラスとして取得します。
        /// </summary>
        /// <param name="aFilePath"></param>
        /// <returns></returns>
        private System.Windows.Forms.HtmlDocument GetHtmlDocument(string aFilePath)
        {
            System.Windows.Forms.HtmlDocument wRet = null;

            try
            {

                // WebBrowser コンポーネントを使用して HtmlDocument を取得する
                using (var wStream = new System.IO.StreamReader(aFilePath, System.Text.Encoding.UTF8))
                using (var wWebBrowser = new System.Windows.Forms.WebBrowser())
                {

                    string wText = wStream.ReadToEnd();

                    wWebBrowser.ScriptErrorsSuppressed = true;
                    wWebBrowser.DocumentText = wText;
                    wWebBrowser.Document.OpenNew(true);
                    wWebBrowser.Document.Write(wText);
                    wWebBrowser.Refresh();

                    wRet = wWebBrowser.Document;
                }
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
