using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using LayoutDesigner.Helpers;
using LayoutDesignerUtilityLib;
using Excel = Microsoft.Office.Interop.Excel;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 Excel 操作ヘルパークラス
    /// </summary>
    public class RldExcelHelper : System.IDisposable
    {
        #region メンバ定数定義

        /// <summary>
        /// シート名(レイアウト)
        /// </summary>
        private const string SHEET_NAME_LAYOUT = "レイアウト";
        /// <summary>
        /// シート名(設定)
        /// </summary>
        private const string SHEET_NAME_SETTING = "設定";
        /// <summary>
        /// シート名(パラメータ)
        /// </summary>
        private const string SHEET_NAME_PARAM = "パラメータ";
        /// <summary>
        /// シート名(グループ)
        /// </summary>
        private const string SHEET_NAME_GROUP = "グループ";
        /// <summary>
        /// シート名(更新履歴)
        /// </summary>
        private const string SHEET_NAME_HISTORY = "更新履歴";
        /// <summary>
        /// シート名(プレビュー)
        /// </summary>
        private const string SHEET_NAME_PREVIEW = "プレビュー";

        /// <summary>
        /// 最大行数(Excel 2007 未満)
        /// </summary>
        private const int SHEET_MAX_ROW_CNT_XLS = 65000;
        /// <summary>
        /// 最大行数(Excel 2007 以降)
        /// </summary>
        private const int SHEET_MAX_ROW_CNT_XLSX = 1048000;

        /// <summary>
        ///  関数
        /// </summary>
        //mod 6720 EXCEL関数で使用できないものがある 吉 start
        //private string[] FUNCTION_NAMES = {"SUM","MOD","IF","OR","AND","LEFT","RIGHT","MID","SUBSTITUTE","COUTNIF", "SUMIF","VALUE","VLOOKUP","HLOOKUP",
        //"INT","ABS","ROUNDUP","ROUNDDOWN","ROUND","VBRColor"};
        private string[] FUNCTION_NAMES = {"SUM","MOD","IF","OR","AND","LEFT","RIGHT","MID","SUBSTITUTE","COUNTIF", "SUMIF","VALUE","VLOOKUP","HLOOKUP",
            "INT","ABS","ROUNDUP","ROUNDDOWN","ROUND","VBRColor"};
        //mod 6720 EXCEL関数で使用できないものがある 吉 end
        /// <summary>
        /// 関数のデフォルトち値
        /// </summary>
        private const string FUN_MESSAGE = "#VALUE!";

        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        private List<string> doPassData = new List<string> { "Medicine", "Equip", "Llt", "Event", "ReceMemo", "DialDiff", "Equipment" };
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end

        public int printType { get; set; }
        #endregion

        #region メンバ変数定義

        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        private Dictionary<object, string> middleData = new Dictionary<object, string>();
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end 

        // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
        private const string FILE_NAME_BARCODE_1 = @"barCode_1.jpg";
        private const string FILE_NAME_BARCODE_2 = @"barCode_2.jpg";
        // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// LayoutSheetChange イベント
        /// </summary>
        public EventHandler<RldSimpleTextEventArgs> LayoutSheetChange;

        /// <summary>
        /// LayoutSheetSelectionChange イベント
        /// </summary>
        public EventHandler<RldSimpleTextEventArgs> LayoutSheetSelectionChange;

		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
        /// <summary>
        /// LayoutSheetBeforeDoubleClick イベント
        /// </summary>
        public EventHandler<RldSimpleTextEventArgs> LayoutSheetBeforeDoubleClick;
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
        #endregion

        #region 生成と破棄

        /// <summary>
        /// 帳票レイアウトデザイナ用 Excel 操作ヘルパークラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldExcelHelper()
        {
            // Excel.Application 拡張クラスのインスタンスを生成する
            this.XlApp = new ExcelApplicationEx();
            // Excel.Workbooks 拡張クラスのインスタンスを生成する
            this.XlBooks = new ExcelWorkbooksEx(this.XlApp);
        }

        // add #12476 FNW帳票取込に莫大な時間がかかることがある 高 start
        public RldExcelHelper(bool bOpen)
        {
        }
        // add #12476 FNW帳票取込に莫大な時間がかかることがある 高 end

        #region IDisposable Support

        private bool disposedValue = false; // 重複する呼び出しを検出するには

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    // TODO: マネージド状態を破棄します (マネージド オブジェクト)。

                    // ブックをクローズ
                    this.Close();

                    this.XlBooks?.Workbooks?.Close();
                    this.XlBooks?.Dispose();

                    this.XlApp?.Application?.Quit();
                    this.XlApp?.Dispose();
                }

                // TODO: アンマネージド リソース (アンマネージド オブジェクト) を解放し、下のファイナライザーをオーバーライドします。
                // TODO: 大きなフィールドを null に設定します。

                disposedValue = true;
            }
        }

        // TODO: 上の Dispose(bool disposing) にアンマネージド リソースを解放するコードが含まれる場合にのみ、ファイナライザーをオーバーライドします。
        // ~ExcelHelper() {
        //   // このコードを変更しないでください。クリーンアップ コードを上の Dispose(bool disposing) に記述します。
        //   Dispose(false);
        // }

        // このコードは、破棄可能なパターンを正しく実装できるように追加されました。
        public void Dispose()
        {
            // このコードを変更しないでください。クリーンアップ コードを上の Dispose(bool disposing) に記述します。
            Dispose(true);
            // TODO: 上のファイナライザーがオーバーライドされる場合は、次の行のコメントを解除してください。
            // GC.SuppressFinalize(this);
        }
        #endregion

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Application 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelApplicationEx XlApp { get; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbooks 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private ExcelWorkbooksEx XlBooks { get; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbook 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorkbookEx XlBook { get; private set; } = null;

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet (パラメータシート) 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorksheetEx XlSheetParam { get; private set; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet (グループシート) 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorksheetEx XlSheetGroup { get; private set; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet (設定シート) 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorksheetEx XlSheetSetting { get; private set; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet (レイアウトシート) 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorksheetEx XlSheetLayout { get; private set; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet (履歴シート) 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorksheetEx XlSheetHistory { get; private set; } = null;
        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet (プレビューシート) 拡張クラスのインスタンスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelWorksheetEx XlSheetPreview { get; private set; } = null;

        /// <summary>
        /// 操作中の Excel ブックファイルへのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public string XlBookFilePath => this.XlBook?.Workbook.FullName;

        /// <summary>
        /// Excel ブックを開いているかどうかの取得及び設定を行います。
        /// </summary>
        private bool IsXlBookOpened { get; set; } = false;

        /// <summary>
        /// Excel ブックを閉じている最中かどうかの取得及び設定を行います。
        /// </summary>
        private bool IsXlBookClosing { get; set; } = false;

        /// <summary>
        /// レイアウトシートで発生する Change 及び SelectionChange イベントを取得するかどうかの取得及び設定を行います。
        /// </summary>
        public bool IsHandleLayoutSheetEvent { get; set; } = true;

        /// <summary>
        /// 更新履歴シートの最大行数の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private int SheetHistoryMaxRowCount
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                int wRet = SHEET_MAX_ROW_CNT_XLS;
                switch (this.XlBook.Workbook.FileFormat)
                {
                    case Excel.XlFileFormat.xlOpenXMLStrictWorkbook:    // 
                    case Excel.XlFileFormat.xlOpenXMLWorkbook:          // xlWorkbookDefault 含む
                        wRet = SHEET_MAX_ROW_CNT_XLSX;
                        break;
                    default:
                        break;
                }
                return wRet;
            }
        }

        #endregion

        #region メンバ関数定義(公開部)

        /// <summary>
        /// ワークブックを開きます。
        /// </summary>
        /// <returns></returns>
        public bool Open(string aXlBookFilePath)
        {
            bool wRet = false;

            try
            {
                // 既存ファイルを開く場合
                if (System.IO.File.Exists(aXlBookFilePath))
                {
                    this.XlBook = new ExcelWorkbookEx(
                        this.XlBooks.Workbooks.Open(
                            aXlBookFilePath,        // Filename
                            Type.Missing,           // UpdateLinks 
                            Type.Missing,           // ReadOnly 
                            Type.Missing,           // Format 
                            Type.Missing,           // Password 
                            Type.Missing,           // WriteResPassword 
                            Type.Missing,           // IgnoreReadOnlyRecommended 
                            Type.Missing,           // Origin 
                            Type.Missing,           // Delimiter 
                            Type.Missing,           // Editable 
                            Type.Missing,           // Notify 
                            Type.Missing,           // Converter 
                            Type.Missing,           // AddToMru 
                            Type.Missing,           // Local 
                            Type.Missing            // CorruptLoad
                        )
                    );
                }
                // 既存ファイルがない場合で新しくファイルを作成する場合
                else
                {
                    // Workbook 拡張クラスを生成
                    this.XlBook = new ExcelWorkbookEx(this.XlBooks.Workbooks.Add(Type.Missing));

                    // Worksheets 拡張クラスを生成
                    using (var wXlSheets = new ExcelWorksheetsEx(this.XlBook))
                    {

                        // Worksheets 内に新しく作成した Worksheet を指定して Worksheet 拡張クラスを生成
                        using (var wXlSheet = new ExcelWorksheetEx(wXlSheets.Worksheets.Add(Type.Missing, Type.Missing, Type.Missing, Type.Missing)))
                        {
                            // レイアウト用シートに設定する
                            wXlSheet.Worksheet.Name = SHEET_NAME_LAYOUT;
                        }

                        int wSheetIndex = 1;

                        // レイアウト用シート以外のシートを削除する
                        while (wXlSheets.Worksheets.Count > 1)
                        {

                            using (var wXlSheet = new ExcelWorksheetEx(wXlSheets, wSheetIndex))
                            {
                                if (string.CompareOrdinal(wXlSheet.Worksheet.Name, SHEET_NAME_LAYOUT) == 0)
                                {
                                    wSheetIndex += 1;
                                }
                                else
                                {
                                    wXlSheet.Worksheet.Delete();
                                }
                            }
                        }
                    }

                    // 一旦保存する(失敗した場合は抜ける)
                    if (!this.Save(aXlBookFilePath))
                    {
                        return false;
                    }
                }

                // 保存時の互換性確認をしないように設定
                this.XlBook.Workbook.CheckCompatibility = false;

                // ワークブックの保護状態を解除
                this.XlBook.IsProtected = false;

                using (var wXlSheets = new ExcelWorksheetsEx(this.XlBook))
                {

                    bool aIsNewSheet;

                    // 公開用シートを生成
                    this.XlSheetLayout = this.GetOrCreateWorksheet(wXlSheets, SHEET_NAME_LAYOUT, out aIsNewSheet);
                    this.XlSheetSetting = this.GetOrCreateWorksheet(wXlSheets, SHEET_NAME_SETTING, out aIsNewSheet);
                    this.XlSheetParam = this.GetOrCreateWorksheet(wXlSheets, SHEET_NAME_PARAM, out aIsNewSheet);
                    this.XlSheetGroup = this.GetOrCreateWorksheet(wXlSheets, SHEET_NAME_GROUP, out aIsNewSheet);
                    this.XlSheetHistory = this.GetOrCreateWorksheet(wXlSheets, SHEET_NAME_HISTORY, out aIsNewSheet);
                    // 更新履歴シートを作成した場合は初期化しておく
                    if (aIsNewSheet)
                    {
                        using (var wXlRange = new ExcelRangeEx(this.XlSheetHistory.Worksheet.Cells))
                        {
                            wXlRange.Range.ShrinkToFit = true;
                            wXlRange.Range.NumberFormat = "@";
                        }
                    }
                }

                // 各シートの表示状態を変更
                Excel.XlSheetVisibility wVisible = Excel.XlSheetVisibility.xlSheetVeryHidden;
                if (SignInLib.SignIn.SignInInfo.IsSuperUser)
                {
                    wVisible = Excel.XlSheetVisibility.xlSheetHidden;
                }

                if (this.XlSheetGroup.Worksheet.Visible != wVisible)
                {
                    this.XlSheetGroup.Worksheet.Visible = wVisible;
                }

                if (this.XlSheetParam.Worksheet.Visible != wVisible)
                {
                    this.XlSheetParam.Worksheet.Visible = wVisible;
                }

                if (this.XlSheetSetting.Worksheet.Visible != wVisible)
                {
                    this.XlSheetSetting.Worksheet.Visible = wVisible;
                }

                if (this.XlSheetHistory.Worksheet.Visible != wVisible)
                {
                    this.XlSheetHistory.Worksheet.Visible = wVisible;
                }

                // カスタムイベントハンドラ割り当て
                this.XlBook.Workbook.BeforeClose += new Excel.WorkbookEvents_BeforeCloseEventHandler(this.XlBook_BeforeClose);
                this.XlSheetLayout.Worksheet.Change += new Excel.DocEvents_ChangeEventHandler(this.XlSheetLayout_Change);
                this.XlSheetLayout.Worksheet.SelectionChange += new Excel.DocEvents_SelectionChangeEventHandler(this.XlSheetLayout_SelectionChange);
				// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
                this.XlSheetLayout.Worksheet.BeforeDoubleClick += new Excel.DocEvents_BeforeDoubleClickEventHandler(this.XlSheetLayout_BeforeDoubleClick);
				// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end

                // オープン中フラグを On
                this.IsXlBookOpened = true;

                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                try { this.XlBook.IsProtected = true; } 
                catch { }
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                // ここまでくれば成功
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
        }

        /// <summary>
        /// ワークブックを閉じます。
        /// </summary>
        public void Close()
        {
            try
            {
                // 開いていない場合は抜ける
                if (!this.IsXlBookOpened)
                {
                    return;
                }

                this.IsXlBookClosing = true;

                // イベントハンドラ割り当て解除
                if (this.XlSheetLayout != null)
                {
                    this.XlSheetLayout.Worksheet.Change -= new Excel.DocEvents_ChangeEventHandler(this.XlSheetLayout_Change);
                    this.XlSheetLayout.Worksheet.SelectionChange -= new Excel.DocEvents_SelectionChangeEventHandler(this.XlSheetLayout_SelectionChange);
					// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
                    this.XlSheetLayout.Worksheet.BeforeDoubleClick -= new Excel.DocEvents_BeforeDoubleClickEventHandler(this.XlSheetLayout_BeforeDoubleClick);
					// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
                }

                // 各シートを破棄
                this.XlSheetGroup?.Dispose();
                this.XlSheetLayout?.Dispose();
                this.XlSheetParam?.Dispose();
                this.XlSheetSetting?.Dispose();
                this.XlSheetPreview?.Dispose();

                // add 2021-03-09 内部バグ対応 趙 start
                this.XlSheetPreview = null;
                // add 2021-03-09 内部バグ対応 趙 end

                this.XlSheetHistory?.Dispose();

                // イベントハンドラ割り当て解除
                if (this.XlBook != null)
                {
                    this.XlBook.Workbook.BeforeClose -= new Excel.WorkbookEvents_BeforeCloseEventHandler(this.XlBook_BeforeClose);

                    // 閉じる
                    this.XlBook.Workbook.Close(false, Type.Missing, Type.Missing);
                }

                // オープン中フラグを off
                this.IsXlBookOpened = false;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
            finally
            {
                this.IsXlBookClosing = false;
            }
        }

        /// <summary>
        /// ワークブックを保存します。
        /// </summary>
        /// <returns></returns>
        public bool Save()
        {
            return this.Save(this.XlBookFilePath);
        }

        /// <summary>
        /// 保存先を指定してワークブックを保存します。
        /// </summary>
        /// <returns></returns>
        public bool Save(string aXlBookFilePath)
        {
            bool wRet = false;

            try
            {
                // 警告表示を無効化
                this.XlApp.Application.DisplayAlerts = false;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                this.XlBook.IsProtected = false;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                // シートを非表示に設定
                Excel.XlSheetVisibility wVisible = Excel.XlSheetVisibility.xlSheetVeryHidden;

                if (this.XlSheetGroup != null && this.XlSheetGroup.Worksheet.Visible != wVisible)
                {
                    this.XlSheetGroup.Worksheet.Visible = wVisible;
                }

                if (this.XlSheetParam != null && this.XlSheetParam.Worksheet.Visible != wVisible)
                {
                    this.XlSheetParam.Worksheet.Visible = wVisible;
                }

                if (this.XlSheetSetting != null && this.XlSheetSetting.Worksheet.Visible != wVisible)
                {
                    this.XlSheetSetting.Worksheet.Visible = wVisible;
                }

                if (this.XlSheetHistory != null && this.XlSheetHistory.Worksheet.Visible != wVisible)
                {
                    this.XlSheetHistory.Worksheet.Visible = wVisible;
                }

                // プレビューシートは不要なので存在する場合は削除
                if (this.XlSheetPreview != null)
                {
                    // 強い非表示状態の場合は削除できないので通常の非表示状態に変更してから削除する
                    if (this.XlSheetPreview.Worksheet.Visible == Excel.XlSheetVisibility.xlSheetVeryHidden)
                    {
                        this.XlSheetPreview.Worksheet.Visible = Excel.XlSheetVisibility.xlSheetHidden;
                    }

                    this.XlSheetPreview.Worksheet.Delete();
                    this.XlSheetPreview.Dispose();
                    this.XlSheetPreview = null;
                }

                // レイアウトシートは保護
                if (this.XlSheetLayout != null)
                {
                    this.XlSheetLayout.IsProtected = true;
                }

                // ブックを保護
                // del #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                //this.XlBook.IsProtected = true;
                // del #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                // 保存先ディレクトリの存在を確認し無ければ作成する。
                // 作成に失敗した場合は抜ける。 
                if (!RldUtility.CheckAndCreateDirectory(System.IO.Path.GetDirectoryName(aXlBookFilePath)))
                {
                    return false;
                }

                try
                {
                    // add #5657 「Excel形式でダウンロードした帳票の編集ができない」について、対応する。　鄧シン start
                    foreach (Excel.Worksheet sheet in this.XlBook.Workbook.Worksheets)
                    {
                        sheet.Unprotect();
                    }
                    // add #5657 「Excel形式でダウンロードした帳票の編集ができない」について、対応する。　鄧シン end
                    // ブックを保存する
                    // del #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                    //this.XlBook.Workbook.Unprotect();
                    // del #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                    this.XlBook.Workbook.SaveAs(
                        aXlBookFilePath,
                        Excel.XlFileFormat.xlWorkbookDefault,
                        Type.Missing,
                        Type.Missing,
                        Type.Missing,
                        Type.Missing,
                        Excel.XlSaveAsAccessMode.xlNoChange,
                        Excel.XlSaveConflictResolution.xlLocalSessionChanges,
                        Type.Missing,
                        Type.Missing,
                        Type.Missing,
                        Type.Missing);
                }
                catch
                {
                    throw;
                }

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
            finally
            {
                // 警告表示を有効化
                this.XlApp.Application.DisplayAlerts = true;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                try { this.XlBook.IsProtected = true; }
                catch { }
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end
            }

            return wRet;
        }

        /// <summary>
        /// 指定されたワークシートを html ファイルに保存します。
        /// </summary>
        /// <param name="aXlSheet"></param>
        /// <param name="aHtmlFilePath"></param>
        /// <param name="aDivID"></param>
        /// <returns></returns>
        // add #6061 エクセルで設定した倍率で印刷されない 歴程 start
        //public bool PublishHtmlFile(ExcelWorksheetEx aXlSheet, string aHtmlFilePath, string aDivID)
        public bool PublishHtmlFile(ExcelWorksheetEx aXlSheet, string aHtmlFilePath, string aDivID, string saveFlg)
        // add #6061 エクセルで設定した倍率で印刷されない 歴程 end
        //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
        {
            // シートがない場合は抜ける
            if (aXlSheet == null)
            {
                return false;
            }

            bool wRet = false;

            try
            {
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                this.XlBook.IsProtected = false;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                using (var wXlWebOptions = new ExcelWebOptions(this.XlBook))
                {

                    // 現在値を記憶
                    var wBackupEncoding = wXlWebOptions.WebOptions.Encoding;

                    try
                    {

                        // UTF-8に変更
                        wXlWebOptions.WebOptions.Encoding = Microsoft.Office.Core.MsoEncoding.msoEncodingUTF8;

                        using (var wPublishObjects = new ExcelPublishObjectsEx(XlBook))
                        {
                            // add #6061 エクセルで設定した倍率で印刷されない 歴程 start
                            //int printType = 0;
                            //　add　7672　【デグレ】透析装置に表示される治療記録画像が縦長になる 吉 start
                            if (null == aXlSheet.Worksheet.PageSetup.PrintArea)
                            {
                                //// mod #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 start
                                ////long lastRow = aXlSheet.Worksheet.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Row;
                                ////long lastCol = aXlSheet.Worksheet.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Column;
                                ////string cellName = aXlSheet.Worksheet.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Address;
                                ////aXlSheet.Worksheet.PageSetup.PrintArea = "$A$1:" + cellName.Substring(0, cellName.LastIndexOf("$")+1)+ lastCol;
                                //Excel.Range range = aXlSheet.Worksheet.UsedRange;
                                //if (aXlSheet.Worksheet.PageSetup.Pages.Count > 0)
                                //{
                                //    //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
                                //    Excel.Range lastColRange = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 2, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false);
                                //    Excel.Range lastRowRange = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false);

                                //    if (lastColRange != null && lastRowRange != null)
                                //    {
                                //        long lastRow = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Row;
                                //        long lastCol = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 2, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Column;
                                //        String strRow = lastRowRange.Address;
                                //        String strCol = lastColRange.Address;
                                //        if (lastRowRange.MergeCells && lastRowRange.MergeArea != null)
                                //        {
                                //            if (lastRowRange.MergeArea.Rows.CountLarge > 1)
                                //            {
                                //                lastRow += lastRowRange.MergeArea.Rows.CountLarge - 1;
                                //            }
                                //        }
                                //        if (lastColRange.MergeCells && lastColRange.MergeArea != null)
                                //        {
                                //            if (lastColRange.MergeArea.Rows.CountLarge > 1)
                                //            {
                                //                lastCol += lastColRange.MergeArea.Rows.CountLarge - 1;
                                //            }
                                //        }

                                //        if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES &&
                                //            RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count > 0)
                                //        {
                                //            if (lastCol <= RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].X
                                //                              + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount)
                                //            {
                                //                lastCol = RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].X
                                //                              + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount - 1;
                                //            }
                                //            if (lastRow <= RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].Y
                                //                              + RldLib.CurrentLayoutData.DesignTempleteData.RowCount)
                                //            {
                                //                lastRow = RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].Y
                                //                              + RldLib.CurrentLayoutData.DesignTempleteData.RowCount - 1;
                                //            }
                                //        }
                                //        range = aXlSheet.Worksheet.Range[range.get_Address(false, false).Substring(0, 2), frmDesignChildLayoutParam.ToName((int)lastCol - 1) + lastRow];
                                //        //add #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
                                //    }
                                //    //del #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
                                //    //Excel.Range lastRange = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 2, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false);
                                //    //if (lastRange != null)
                                //    //{
                                //    //    long lastRow = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Row;
                                //    //    long lastCol = range.Cells.Find(What: "*", LookIn: -4123, LookAt: 2, SearchOrder: 1, SearchDirection: Excel.XlSearchDirection.xlPrevious, MatchCase: false).Column;
                                //    //    String str = lastRange.Address;
                                //    //    if (lastRange.MergeCells && lastRange.MergeArea != null)
                                //    //    {
                                //    //        if (lastRange.MergeArea.Columns.CountLarge > 1)
                                //    //        {
                                //    //            lastCol += lastRange.MergeArea.Columns.CountLarge - 1;
                                //    //        }
                                //    //        if (lastRange.MergeArea.Rows.CountLarge > 1)
                                //    //        {
                                //    //            lastRow += lastRange.MergeArea.Rows.CountLarge - 1;
                                //    //        }
                                //    //    }
                                //    //    // mod #7868 コンバータされた施設の透析レポートが表示できない 夏 start
                                //    //    //if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                                //    //    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES &&
                                //    //        RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count > 0)
                                //    //    // mod #7868 コンバータされた施設の透析レポートが表示できない 夏 end
                                //    //    {
                                //    //        if (lastCol <= RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].X
                                //    //                          + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount)
                                //    //        {
                                //    //            lastCol = RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].X
                                //    //                          + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount - 1;
                                //    //        }
                                //    //        if (lastRow <= RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].Y
                                //    //                          + RldLib.CurrentLayoutData.DesignTempleteData.RowCount)
                                //    //        {
                                //    //            lastRow = RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList[RldLib.CurrentLayoutData.DesignTempleteData.RepeatStartPosList.Count - 1].Y
                                //    //                          + RldLib.CurrentLayoutData.DesignTempleteData.RowCount - 1;
                                //    //        }
                                //    //    }
                                //    //    range = aXlSheet.Worksheet.Range[range.get_Address(false, false).Substring(0, 2), frmDesignChildLayoutParam.ToName((int)lastCol - 1) + lastRow];
                                //    //}
                                //    //del #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
                                //}
                                //aXlSheet.Worksheet.PageSetup.PrintArea = range.get_Address();
                                //// mod #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 end
                            }
                            //　add　7672　【デグレ】透析装置に表示される治療記録画像が縦長になる 吉 end

                            // mod #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
                            //if ("save".Equals(saveFlg) && null != aXlSheet.Worksheet.PageSetup.PrintArea)
                            if (("preview".Equals(saveFlg) || "save".Equals(saveFlg)) && null != aXlSheet.Worksheet.PageSetup.PrintArea)
                            // mod #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end
                            {
                                //// mod #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 start
                                ////Excel.Range xlsRange = aXlSheet.Worksheet.UsedRange;
                                ////int xlsColumns = xlsRange.Cells.Columns.Count;
                                ////int xlsRows = xlsRange.Cells.Rows.Count;

                                ////string printArea = aXlSheet.Worksheet.PageSetup.PrintArea;
                                ////string startCell = printArea.Substring(0, printArea.IndexOf(":"));
                                ////string endCell = printArea.Substring(printArea.IndexOf(":") + 1);

                                ////Excel.Range printRange = aXlSheet.Worksheet.get_Range(startCell, endCell);
                                ////int printColumns = printRange.Cells.Columns.Count;
                                ////int printRows = printRange.Cells.Rows.Count;

                                //bool msgFlg = false;
                                ////for (int r = 1; r <= xlsRows; r++)
                                ////{
                                ////    for (int c = 1; c <= xlsColumns; c++)
                                ////    {
                                ////        if (r < printRows && c < printColumns)
                                ////        {
                                ////            continue;
                                ////        }
                                ////        Excel.Range cell = xlsRange.Cells[r, c] as Excel.Range;
                                ////        if (cell != null && cell.Value != null && !String.IsNullOrEmpty(cell.Value.ToString()))
                                ////        {
                                ////            // mod 6023 紹介状画面の印刷ボタンを押下すると印刷失敗のメッセージが表示される  吉 start
                                ////            // if (r >= printRows || c >= printColumns)
                                ////            if (r > printRows || c > printColumns)
                                ////            // mod 6023 紹介状画面の印刷ボタンを押下すると印刷失敗のメッセージが表示される  吉 end
                                ////                {
                                ////                msgFlg = true;
                                ////            }
                                ////        }
                                ////    }
                                ////}
                                //foreach (var addr in RldLib.CurrentLayoutData.DesignParamList)
                                //{
                                //    if (RldLib.XlHelper.XlApp.Application.Intersect(aXlSheet.Worksheet.Range[addr.CellAddress],
                                //        aXlSheet.Worksheet.Range[aXlSheet.Worksheet.PageSetup.PrintArea]) is null)
                                //    {
                                //        msgFlg = true;
                                //        break;
                                //    }
                                //}
                                //// del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                                ////if (!msgFlg)
                                ////{
                                ////    Excel.Range range = aXlSheet.Worksheet.Cells.Find(What: "*",
                                ////        LookIn: Excel.XlFindLookIn.xlValues,
                                ////        LookAt: Excel.XlLookAt.xlPart,
                                ////        SearchOrder: Excel.XlSearchOrder.xlByRows,
                                ////        SearchDirection: Excel.XlSearchDirection.xlNext,
                                ////        MatchCase: false);
                                ////    if (range != null)
                                ////    {
                                ////        String cellAdds = range.Address;
                                ////        String oldCellAdds = range.Address;
                                ////        while (true)
                                ////        {
                                ////            if (RldLib.XlHelper.XlApp.Application.Intersect(aXlSheet.Worksheet.Range[cellAdds],
                                ////                aXlSheet.Worksheet.Range[aXlSheet.Worksheet.PageSetup.PrintArea]) is null)
                                ////            {
                                ////                msgFlg = true;
                                ////                break;
                                ////            }
                                ////            range = aXlSheet.Worksheet.Cells.FindNext(range);
                                ////            cellAdds = range.Address;
                                ////            if (oldCellAdds.Equals(cellAdds))
                                ////            {
                                ////                break;
                                ////            }
                                ////        }
                                ////    }
                                ////}
                                //// del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 end
                                //// mod #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 end

                                //// 印刷範囲外に内容がある場合
                                //if (msgFlg)
                                //{
                                //    LoadingHelper.CloseLoadingDialog();
                                //    DialogResult dr = MessageBox.Show("印刷範囲外に文字が入力されています。削除してから保存しますか？", "保存確認", MessageBoxButtons.YesNo);

                                //    // 「いいえ」を選択した場合、そのまま保存
                                //    if (dr == DialogResult.No)
                                //    {
                                //        printType = (int)Excel.XlSourceType.xlSourceSheet;
                                //    }
                                //    // 「はい」を選択した場合、削除してから保存
                                //    else
                                //    {
                                //        printType = (int)Excel.XlSourceType.xlSourcePrintArea;
                                //    }
                                //    LoadingHelper.ShowLoadingDialog();
                                //}
                                //else
                                //{
                                //    printType = (int)Excel.XlSourceType.xlSourcePrintArea;
                                //}
                            }
                            else
                            {
                                //printType = (int)Excel.XlSourceType.xlSourceSheet;
                            }
                            // add #6061 エクセルで設定した倍率で印刷されない 歴程 end
                            using (var wPublishObject = new ExcelPublishObjectEx(wPublishObjects.PublishObjects.Add(
                                // mod #6061 エクセルで設定した倍率で印刷されない 歴程 start
                                //Excel.XlSourceType.xlSourceSheet,
                                (Excel.XlSourceType)GlobalVariables.printType,
                                // mod #6061 エクセルで設定した倍率で印刷されない 歴程 end
                                aHtmlFilePath,
                                aXlSheet.Worksheet.Name,
                                string.Empty,
                                Excel.XlHtmlType.xlHtmlStatic,
                                aDivID,
                                string.Empty)))
                            {

                                // ドキュメント内のアイテムまたはアイテムのコレクションを web ページに保存します。
                                wPublishObject.PublishObject.Publish(true);
                                // add 2021-09-15 #6436：ブラウザプレビューで翻訳オプションが表示される 李 start
                                Stream myStream = new FileStream(aHtmlFilePath, FileMode.Open);
                                Encoding encode = Encoding.GetEncoding("UTF-8");
                                StreamReader myStreamReader = new StreamReader(myStream, encode);
                                string strhtml = myStreamReader.ReadToEnd();
                                StringBuilder sb = new StringBuilder(strhtml);
                                StringBuilder stroutput = sb.Replace(">", " lang=\"ja\" >", sb.ToString().IndexOf(">", sb.ToString().IndexOf("xmlns:x")), 1);
                                myStream.Seek(0, SeekOrigin.Begin);
                                myStream.SetLength(0);
                                StreamWriter sw = new StreamWriter(myStream, encode);
                                sw.Write(stroutput);
                                sw.Flush();
                                sw.Close();
                                myStream.Close();
                                // add 2021-09-15 #6436：ブラウザプレビューで翻訳オプションが表示される 李 end
                                // ブックが保存された時に、再発行しない
                                // ブックが保存されると、Microsoft Excel は、 Publishobjects コレクション内のいずれかのアイテムの自動再発行プロパティがTrueに設定されているかどうかを判断し、再発行します。
                                wPublishObject.PublishObject.AutoRepublish = false;

                            }
                        }

                        wRet = true;
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        // 元に戻す
                        wXlWebOptions.WebOptions.Encoding = wBackupEncoding;
                    }
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
            // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
            finally
            {
                try { this.XlBook.IsProtected = true; }
                catch { }
            }
            // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

            return wRet;
        }
        //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
        /// <summary>
        /// 指定されたセル範囲を html ファイルに保存します。
        /// </summary>
        /// <param name="aXlRange"></param>
        /// <param name="aHtmlFilePath"></param>
        /// <param name="aDivID"></param>
        /// <returns></returns>
        public bool PublishHtmlFile(ExcelWorksheetEx aXlSheet, ExcelRangeEx aXlRange, string aHtmlFilePath, string aDivID)
        {
            // シートがない場合は抜ける
            if (aXlSheet == null)
            {
                return false;
            }

            bool wRet = false;

            try
            {
                //// 指定されたセル範囲が選択されていない場合は選択する
                //if( this.XlApp.GetSelectedCell.GetAddress() != aXlRange.GetAddress() )
                //    aXlRange.Range.Select();

                using (var wXlWebOptions = new ExcelWebOptions(this.XlBook))
                {
                    // 現在値を記憶
                    var wBackupEncoding = wXlWebOptions.WebOptions.Encoding;

                    try
                    {
                        // UTF-8に変更
                        wXlWebOptions.WebOptions.Encoding = Microsoft.Office.Core.MsoEncoding.msoEncodingUTF8;

                        using (var wPublishObjects = new ExcelPublishObjectsEx(this.XlBook))
                        {

                            using (var wPublishObject = new ExcelPublishObjectEx(wPublishObjects.PublishObjects.Add(
                                Excel.XlSourceType.xlSourceRange,
                                aHtmlFilePath,
                                aXlSheet.Worksheet.Name,
                                aXlRange.Range.Address[false, false],
                                Excel.XlHtmlType.xlHtmlStatic,
                                aDivID,
                                string.Empty)))
                            {

                                wPublishObject.PublishObject.Publish(true);

                                wPublishObject.PublishObject.AutoRepublish = false;
                            }
                        }

                        wRet = true;
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        // 元に戻す
                        wXlWebOptions.WebOptions.Encoding = wBackupEncoding;
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
        /// 設定データを取得します。
        /// </summary>
        /// <returns></returns>
        public DesignSettingData GetSettingData()
        {
            var wRet = new DesignSettingData();

            // 帳票種別取得
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.SettingData.CELLADDR_REPORT_TYPE))
            {
                wRet.ReportClass = wXlRange.GetValue2() as string;
            }

            // レポートCD
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.SettingData.CELLADDR_REPORT_CODE))
            {
                wRet.ReportCode = wXlRange.GetValue2() as string;

                // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
                if (RldLib.StrRepeatMode == "")
                {
                    //　旧帳票のテンプレート繰返しモードデータを設定する。
                    RldLib.StrRepeatMode = wXlRange.Range.Value2 as string ?? string.Empty;
                }
                // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

            }

            // テンプレート繰返し有無取得
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.SettingData.CELLADDR_HAS_TEMPLETE))
            {
                wRet.HasTemplete = wXlRange.GetValue2() as string;
            }

            return wRet;
        }

        /// <summary>
        /// パラメータシート内のデータを取得します。
        /// </summary>
        /// <returns></returns>
        public System.ComponentModel.BindingList<DesignParamData> GetSheetParamDataList()
        {
            var wRet = new System.ComponentModel.BindingList<DesignParamData>();
            object[,] wGetValues = null;

            try
            {
                // パラメータシートからデータを取得
                using (var wXlRange = new ExcelRangeEx(this.XlSheetParam.Worksheet.UsedRange))
                {
                    wGetValues = wXlRange.Range.Value;
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("パラメータデータの取得中にエラーが発生しました。", ex),
                    true);
            }

            // 正常にデータを取得できた場合
            if (wGetValues != null && wGetValues.GetLength(0) > 1)
            {
                try
                {
                    // 保存対象列を取得
                    var wColumnList = DesignParamData.GetReadWriteDataList();

                    // 保存対象列とパラメータシートの列の対応を作成
                    var wDataKey = new System.Collections.Generic.Dictionary<DesignParamData.EnumDataIndex, Int32>();
                    foreach (var wKey in wColumnList)
                    {
                        string wPropName = DesignParamData.GetProperty(wKey).Name;

                        // 1行目を確認
                        for (int i = 1; i <= wGetValues.GetLength(1); i++)
                        {
                            string wValue = wGetValues[1, i] as string;
                            if (!string.IsNullOrEmpty(wValue) && string.CompareOrdinal(wValue, wPropName) == 0)
                            {
                                wDataKey.Add(wKey, i);
                                break;
                            }
                        }
                    }

                    // 2行目以降を取り込む
                    for (int wLopCnt = 2; wLopCnt <= wGetValues.GetLength(0); wLopCnt++)
                    {

                        // データパスを取得
                        string wDataPath = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataPath]] as string;
                        // 管理対象ではない場合は抜ける
                        if ((string.IsNullOrEmpty(wDataPath)) ||
                            (!string.IsNullOrEmpty(wDataPath) && !wDataPath.StartsWith(RldConst.PATH_HEADER)))
                        {
                            continue;
                        }

                        //8586 EDIT  董 START
                        string dataType = string.Empty;
                        // mod #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
                        dataType = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataType]] as string ?? string.Empty;
                        //if (wDataPath.StartsWith("##="))
                        //{
                        //    dataType = "decimal";
                        //}
                        //else
                        //{
                        //    dataType = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataType]] as string ?? string.Empty;
                        //}
                        // mod #11738 印刷情報を使った計算式があると改頁やPDF出力が失敗する 高 start
                        //8586 EDIT  董 END
                        //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
                        string paramFilterType = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.FilterType]] as string ?? string.Empty;
                        string paramFilterData = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.FilterData]] as string ?? string.Empty;
                        string paramFilterState = string.Empty;
                        if (!string.IsNullOrEmpty(paramFilterData))
                        {
                            switch (paramFilterType)
                            {
                                case RldConst.FilterType.Parameter.MEDICINE:         // 検査項目フィルタ
                                    if (string.Equals(paramFilterData, "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>"))
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                    }
                                    else
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                                    }
                                    break;
                                case RldConst.FilterType.Parameter.EQUIP:            // 検査セットフィルタ
                                    if (string.Equals(paramFilterData, "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>"))
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                    }
                                    else
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                                    }
                                    break;
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                case RldConst.FilterType.Group.CATEGORY:
                                    if (string.Equals(paramFilterData, "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>"))
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                    }
                                    else
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_PART;
                                    }
                                    string gateFilterKey = String.Format("{0} {1}", RldConst.FilterData.TAG_ITEM, RldConst.FilterData.ATT_ITEM_CODE);
                                    if (paramFilterData.Contains(gateFilterKey))
                                    {
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramFilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                                    }
                                    break;
                                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                case RldConst.FilterType.Group.INSPECTION:
                                    string gateFilterKey1 = String.Format("{0} {1}", RldConst.FilterData.TAG_ITEM, RldConst.FilterData.ATT_ITEM_CODE);
                                    if (paramFilterData.Contains(gateFilterKey1))
                                    {
                                        paramFilterData = string.Empty;
                                        paramFilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                                    }
                                    else
                                        paramFilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;
                                    break;
                                // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                case RldConst.FilterType.Group.PATEVENT:        // イベント
                                case RldConst.FilterType.Group.ADDITION:        // 加算
                                case RldConst.FilterType.Group.DIALDIFF:        // 透析困難コメント
                                case RldConst.FilterType.Group.OBSKIND:         // 観察記録種別
                                case RldConst.FilterType.Group.EXAMINE:
                                case RldConst.FilterType.Group.EXAM_SET:
                                case RldConst.FilterType.Group.WATER_SURVEY:
                                // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                                //case RldConst.FilterType.Group.INSPECTION:
                                // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                                case RldConst.FilterType.Group.WQTESTPOINT:
                                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                                // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                //case RldConst.FilterType.Group.CATEGORY:
                                // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                    paramFilterState = RldConst.ParamData.VAL_FILTER_STATE_YES;
                                    break;
                                default:
                                    break;
                            }

                        }
                        else
                        {
                            if (!string.IsNullOrEmpty(paramFilterType))
                            {
                                switch (paramFilterType)
                                {
                                    case RldConst.FilterType.Parameter.MEDICINE:         // 検査項目フィルタ
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramFilterData = "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>";
                                        break;
                                    case RldConst.FilterType.Parameter.EQUIP:            // 検査セットフィルタ
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramFilterData = "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>";
                                        break;
                                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                    case RldConst.FilterType.Group.CATEGORY:
                                        paramFilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramFilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                                        break;
                                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                    case RldConst.FilterType.Group.PATEVENT:        // イベント
                                    case RldConst.FilterType.Group.ADDITION:        // 加算
                                    case RldConst.FilterType.Group.DIALDIFF:        // 透析困難コメント
                                    case RldConst.FilterType.Group.OBSKIND:         // 観察記録種別
                                    case RldConst.FilterType.Group.EXAMINE:
                                    case RldConst.FilterType.Group.EXAM_SET:
                                    case RldConst.FilterType.Group.WATER_SURVEY:
                                    case RldConst.FilterType.Group.INSPECTION:
                                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                                    case RldConst.FilterType.Group.WQTESTPOINT:
                                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                                    // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                    //case RldConst.FilterType.Group.CATEGORY:
                                    // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                        paramFilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                        //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end

                        var wData = new DesignParamData()
                        {
                            DataPath = wDataPath,
                            DataCategory = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataCategory]] as string ?? string.Empty,
                            DataClass = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataClass]] as string ?? string.Empty,
                            DataName = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataName]] as string ?? string.Empty,
                            SqlCode = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.SqlCode]] as string ?? string.Empty,
                            DataCode = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataCode]] as string ?? string.Empty,
                            //8586 EDIT  董 START
                            DataType = dataType,//wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DataType]] as string ?? string.Empty,
                            //8586 EDIT  董 END
                            PreviewData = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.PreviewData]] as string ?? string.Empty,
                            DisplayFormat = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.DisplayFormat]] as string ?? string.Empty,
                            RepeatAddress = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.RepeatAddress]] as string ?? string.Empty,
                            CellAddress = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.CellAddress]] as string ?? string.Empty,
                            IsShrink = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.IsShrink]] as string ?? RldConst.ParamData.VAL_ISSHRINK_NONE,
                            Length = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.Length]] as string ?? string.Empty,
                            //edit #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
                            FilterData = paramFilterData,//wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.FilterData]] as string ?? string.Empty,
                            FilterType = paramFilterType,//wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.FilterType]] as string ?? string.Empty,
                            //edit #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end
                            IsNewPage = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.IsNewPage]] as string ?? RldConst.ParamData.VAL_ISNEWPAGE_FALSE,
                            LabelItem = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.LabelItem]] as string ?? string.Empty,
                            GroupName = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.GroupName]] as string ?? string.Empty,
                            //add #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
                            //edit #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
                            FilterState = paramFilterState,//wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.FilterState]] as string ?? string.Empty,
                            //edit #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end
                            //add #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
                            IsInTemplete = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.IsInTemplete]] as string ?? RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE,
                            ParticularInfo = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.ParticularInfo]] as string ?? string.Empty,
                            //mod #7844  帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 start
                            //add #6009 2022-04-20 帳票画像表示値の編集エラー 鄭 start
                            //IsImage = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.IsImage]] as string ?? string.Empty,
                            IsImage = wDataKey.ContainsKey(DesignParamData.EnumDataIndex.IsImage) ? (wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.IsImage]] as string ?? string.Empty) : string.Empty,
                            //add #6009 2022-04-20 帳票画像表示値の編集エラー 鄭 start
                            //mod #7844 帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない  2022-08-09 孟堅end                        
                        };

                        // ConvertList
                        string wXmlText = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.ConvertList]] as string ?? string.Empty;
                        if (!string.IsNullOrEmpty(wXmlText))
                        {
                            var wXmlDoc = new System.Xml.XmlDocument();
                            wXmlDoc.LoadXml(wXmlText);

                            if (DesignConvertList.TryParse(wXmlDoc.DocumentElement, out DesignConvertList wConvertList))
                            {
                                wData.ConvertList.AddRange(wConvertList);
                            }
                        }

                        if (bool.TryParse(wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.CanRepeat]] as string, out bool wCanRepeat))
                        {
                            wData.CanRepeat = wCanRepeat;
                        }

                        if (bool.TryParse(wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.IsCalcResult]] as string, out bool wIsCalcResult))
                        {
                            wData.IsCalcResult = wIsCalcResult;
                        }

                        // 条件付き書式
                        if (wDataKey.ContainsKey(DesignParamData.EnumDataIndex.FormatCondition))
                        {
                            wXmlText = wGetValues[wLopCnt, wDataKey[DesignParamData.EnumDataIndex.FormatCondition]] as string ?? string.Empty;
                            if (!string.IsNullOrEmpty(wXmlText))
                            {
                                var wXmlDoc = new System.Xml.XmlDocument();
                                wXmlDoc.LoadXml(wXmlText);

                                if (Data.FormatConditionRules.TryParse(wXmlDoc.DocumentElement, out Data.FormatConditionRules wConvertList))
                                {
                                    wData.FormatCondition.AddRange(wConvertList);
                                }
                            }

                        }

                        // add #11535 帳票の汎用バーコード出力対応 高 start
                        int iValue;
                        if (wDataKey.TryGetValue(DesignParamData.EnumDataIndex.BarCode, out iValue))
                        {
                            string sCellValue = wGetValues[wLopCnt, iValue] as string ?? string.Empty;
                            string sValue = RldLib.barCodeDic.FirstOrDefault(x => x.Value == sCellValue).Key;
                            if (sValue == null)
                                wData.BarCode = "";
                            else
                                wData.BarCode = sValue;
                        }
                        else
                        {
                            wData.BarCode = string.Empty;
                        }

                        if (wDataKey.TryGetValue(DesignParamData.EnumDataIndex.CanBarCode, out iValue))
                        {
                            if (bool.TryParse(wGetValues[wLopCnt, iValue] as string, out bool wCanBarCode))
                            {
                                wData.CanBarCode = wCanBarCode;
                            }
                        }
                        else {
                            if (wDataPath.StartsWith(RldConst.CALC_HEADER))
                            {
                                wData.CanBarCode = true;
                            }
                        }
                        // add #11535 帳票の汎用バーコード出力対応 高 end

                        // バインディングリストへ追加
                        wRet.Add(wData);
                    }
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("パラメータデータの展開中にエラーが発生しました。", ex),
                        true);
                }
            }

            return wRet;
        }

        /// <summary>
        /// グループシート内のデータを取得します。
        /// </summary>
        public System.ComponentModel.BindingList<DesignGroupData> GetSheetGroupDataList()
        {
            var wRet = new System.ComponentModel.BindingList<DesignGroupData>();
            object[,] wGetValues = null;

            try
            {
                // グループシートからデータを取得
                using (var wXlRange = new ExcelRangeEx(this.XlSheetGroup.Worksheet.UsedRange))
                {
                    wGetValues = wXlRange.GetValue2();
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("グループデータの取得中にエラーが発生しました。", ex),
                    true);
            }

            // 正常にデータを取得できた場合
            if (wGetValues != null && wGetValues.GetLength(0) > 1)
            {
                try
                {
                    // 保存対象列を取得
                    var wColumnList = DesignGroupData.GetReadWriteDataList();

                    // 保存対象列とパラメータシートの列の対応を作成
                    var wDataKey = new System.Collections.Generic.Dictionary<DesignGroupData.EnumDataIndex, Int32>();
                    foreach (var wKey in wColumnList)
                    {
                        string wPropName = DesignGroupData.GetProperty(wKey).Name;

                        // 1行目を確認
                        for (int i = 1; i <= wGetValues.GetLength(1); i++)
                        {
                            string wValue = wGetValues[1, i] as string;
                            if (!string.IsNullOrEmpty(wValue) && string.CompareOrdinal(wValue, wPropName) == 0)
                            {
                                wDataKey.Add(wKey, i);
                                break;
                            }
                        }
                    }

                    // 2行目以降を取り込む
                    for (int wLopCnt = 2; wLopCnt <= wGetValues.GetLength(0); wLopCnt++)
                    {

                        // A列(カテゴリ)を取得
                        string wCategory = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.DataCategory]] as string;
                        // 管理対象ではない場合は抜ける
                        if (string.IsNullOrEmpty(wCategory))
                        {
                            continue;
                        }
                        // add 2023-03-29 #8455 【デグレ】グループ情報がクリアされてしまう 鵬 start
                        string GroupName = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.GroupName]] as string;
                        if (string.IsNullOrEmpty(GroupName))
                        {
                            continue;
                        }
                        // mod 2023-04-07 #8417 【IES起票】【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題 鵬 start
                        string IsInTemplete = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.IsInTemplete]] as string;
                        if (wRet.Count > 0 && wRet.SingleOrDefault(ele => ele.GroupName.Equals(GroupName) && ele.IsInTemplete.Equals(IsInTemplete)) != null)
                        {
                            continue;
                        }
                        // mod 2023-04-07 #8417 鵬 end
                        // add 2023-03-29 #8455 鵬 end

                        var wData = new DesignGroupData()
                        {
                            GroupPath = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.GroupPath]] as string ?? string.Empty,
                            DataCategory = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.DataCategory]] as string ?? string.Empty,
                            DataClass = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.DataClass]] as string ?? string.Empty,
                            GroupName = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.GroupName]] as string ?? string.Empty,
                            IsNewPage = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.IsNewPage]] as string ?? RldConst.GroupData.VAL_ISNEWPAGE_FALSE,
                            FilterData = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.FilterData]] as string ?? string.Empty,
                            FilterType = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.FilterType]] as string ?? string.Empty,
                            RepeatCount = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.RepeatCount]] as string ?? string.Empty,
                            IsInTemplete = wGetValues[wLopCnt, wDataKey[DesignGroupData.EnumDataIndex.IsInTemplete]] as string ?? RldConst.GroupData.VAL_IS_IN_TEMPLETE_NONE
                        };
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                        if (wData.FilterType == RldConst.FilterType.Group.CATEGORY)
                        {
                           string gateFilterKey = String.Format("{0} {1}", RldConst.FilterData.TAG_ITEM, RldConst.FilterData.ATT_ITEM_CODE);
                            if(wData.FilterData.Contains(gateFilterKey))
                            {
                                wData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                wData.FilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                            }
                        }
                        // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end

                        // バインディングリストへ追加
                        wRet.Add(wData);
                    }
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("グループデータの展開中にエラーが発生しました。", ex),
                        true);
                }
            }

            return wRet;
        }

        /// <summary>
        /// テンプレート繰返し設定データを取得します。
        /// </summary>
        /// <returns></returns>
        public DesignTempleteData GetTempleteData()
        {
            var wRet = new DesignTempleteData();

            // テンプレート繰返し範囲
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_RANGE))
            {
                wRet.Range = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            if (!string.IsNullOrEmpty(wRet.Range))
            {
                // テンプレート繰返し開始行番号
                using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wRet.Range))
                {
                    wRet.RangeRowNo = wXlRange.Range.Row;
                    wRet.RangeColumnNo = wXlRange.Range.Column;
                }

                // 行数
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_ROWCOUNT))
                {
                    wRet.RowCount = RldLib.ConvertStrToInt32(wXlRange.Range.Value2 as string ?? string.Empty, false);
                }

                // 列数
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_COLUMNCOUNT))
                {
                    wRet.ColumnCount = RldLib.ConvertStrToInt32(wXlRange.Range.Value2 as string ?? string.Empty, false);
                }

                // 繰返し回数(縦)
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEAT_V))
                {
                    wRet.RepeatCountV = wXlRange.Range.Value2 as string ?? string.Empty;
                }

                // 繰返し回数(横)
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEAT_H))
                {
                    wRet.RepeatCountH = wXlRange.Range.Value2 as string ?? string.Empty;
                }

                // 余白(縦)
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_MARGIN_V))
                {
                    wRet.MarginV = wXlRange.Range.Value2 as string ?? string.Empty;
                }

                // 余白(横)
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_MARGIN_H))
                {
                    wRet.MarginH = wXlRange.Range.Value2 as string ?? string.Empty;
                }

                // 改ページ有無
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_ISNEWPAGE))
                {
                    wRet.IsNewPage = wXlRange.Range.Value2 as string ?? RldConst.TempleteData.VAL_ISNEWPAGE_FALSE;
                }

                // 繰返し方向
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_DIRECTION))
                {
                    wRet.DirectionData = wXlRange.Range.Value2 as string ?? string.Empty;
                }

                // 繰返しモード
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEATMODE))
                {
                    wRet.RepeatMode = wXlRange.Range.Value2 as string ?? string.Empty;
                }
                //add #8763 zhu start
                // 繰返しモード
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEATNO))
                {
                    wRet.RepeatNo = wXlRange.Range.Value2 as string ?? string.Empty;
                }
                //add #8763 zhu end
            }

            return wRet;
        }

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// 旧帳票のテンプレート繰返し設定データを取得します。
        /// </summary>
        /// <returns></returns>
        public DesignTempleteData GetTempleteFromOldReportData()
        {
            var wRet = new DesignTempleteData();
            // add #9157 FNW帳票取り込み時の不正 董昊 start
            String marginV = string.Empty;
            String marginH = string.Empty;

            String marginV1 = string.Empty;
            String marginH1 = string.Empty;

            String marginV2 = string.Empty;
            String marginH2 = string.Empty;
            // add #9157 FNW帳票取り込み時の不正 董昊 end

            // テンプレート繰返し範囲
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_RANGE))
            {
                wRet.Range = wXlRange.Range.Value2 as string ?? string.Empty;

                // mod #9890 【デグレ】FNW帳票の取込エラー donghao start
                //// add #9157 FNW帳票取り込み時の不正 董昊 start
                //marginV = wRet.Range.ToString().Split(':')[0];
                //marginH = wRet.Range.ToString().Split(':')[1];

                //marginV1 = Regex.Replace(marginV, @"[^0-9]+", "");
                //marginH1 = Regex.Replace(marginH, @"[^0-9]+", "");

                //marginV2 = Regex.Replace(marginV, @"\d", "");
                //marginH2 = Regex.Replace(marginH, @"\d", "");
                //// add #9157 FNW帳票取り込み時の不正 董昊 end

                if (!string.IsNullOrEmpty(wRet.Range))
                {
                    // add #9157 FNW帳票取り込み時の不正 董昊 start
                    // mod #10464 FNW帳票取込みで致命的なエラー 高 start
                    //marginV = wRet.Range.ToString().Split(':')[0];
                    //marginH = wRet.Range.ToString().Split(':')[1];
                    string[] address = wRet.Range.ToString().Split(':');
                    if(address.Length == 1)
                    {
                        marginV = address[0];
                        marginH = address[0];
                    }
                    else
                    {
                        marginV = address[0];
                        marginH = address[1];
                    }
                    // mod #10464 FNW帳票取込みで致命的なエラー 高 end

                    marginV1 = Regex.Replace(marginV, @"[^0-9]+", "");
                    marginH1 = Regex.Replace(marginH, @"[^0-9]+", "");

                    marginV2 = Regex.Replace(marginV, @"\d", "");
                    marginH2 = Regex.Replace(marginH, @"\d", "");
                    // add #9157 FNW帳票取り込み時の不正 董昊 end
                }
                // mod #9890 【デグレ】FNW帳票の取込エラー donghao end
            }

            if (!string.IsNullOrEmpty(wRet.Range))
            {
                // テンプレート繰返し開始行番号
                using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wRet.Range))
                {
                    wRet.RangeRowNo = wXlRange.Range.Row;
                    wRet.RangeColumnNo = wXlRange.Range.Column;
                }

                // 行数
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_ROWCOUNT))
                {
                    wRet.RowCount = (int)wXlRange.Range.Value2;

                    // add #9157 FNW帳票取り込み時の不正 董昊 start

                    // 余白(縦)
                    wRet.MarginV = (wRet.RowCount - (Int32.Parse(marginH1) - Int32.Parse(marginV1) + 1)).ToString();
                    // add #9157 FNW帳票取り込み時の不正 董昊 end

                    // add #9157 FNW帳票取り込み時の不正 董昊 start
                    wRet.SizeRowCount = Int32.Parse(marginH1) - Int32.Parse(marginV1) + 1;
                    // add #9157 FNW帳票取り込み時の不正 董昊 end
                }

                // 列数
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_COLUMNCOUNT))
                {
                    wRet.ColumnCount = (int)wXlRange.Range.Value2;

                    // add #9157 FNW帳票取り込み時の不正 董昊 start

                    int marginV3 = ToIndex(marginV2);
                    int marginH3 = ToIndex(marginH2);

                    // 余白(横)
                    wRet.MarginH = (wRet.ColumnCount - (marginH3 - marginV3 + 1)).ToString();
                    // add #9157 FNW帳票取り込み時の不正 董昊 end

                    // add #9157 FNW帳票取り込み時の不正 董昊 start
                    wRet.SizeColumnCount = marginH3 - marginV3 + 1;
                    // add #9157 FNW帳票取り込み時の不正 董昊 end
                }

                // 繰返し回数(縦)
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_REPEAT_V))
                {
                    wRet.RepeatCountV = Convert.ToString(wXlRange.Range.Value2);
                }

                // 繰返し回数(横)
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_REPEAT_H))
                {
                    wRet.RepeatCountH = Convert.ToString(wXlRange.Range.Value2);
                }

                // 改ページ有無
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_ISNEWPAGE))
                {
                    if (wXlRange.Range.Value2)
                    {
                        // 改ページ有無値 - 有り
                        wRet.IsNewPage = RldConst.TempleteData.VAL_ISNEWPAGE_TRUE;
                    }
                    else
                    {
                        // 改ページ有無値 - 無し
                        wRet.IsNewPage = RldConst.TempleteData.VAL_ISNEWPAGE_FALSE;
                    }
                }

                // 繰返し方向
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.FNW_CELLADDR_DIRECTION))
                {
                    wRet.DirectionData = wXlRange.Range.Value2 as string ?? string.Empty;
                }

                // 繰返しモード
                wRet.RepeatMode = RldLib.StrRepeatMode;
                RldLib.StrRepeatMode = string.Empty;
            }

            return wRet;
        }
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
        /// <summary>
        /// 定期日常点検・交換部品記録簿データを取得します。
        /// </summary>
        /// <returns></returns>
        public InspectionLayoutData GetDeviceData()
        {
            var wRet = new InspectionLayoutData();

            // 帳票区分
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_REPORTTYPE))
            {
                wRet.ReportType = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 用途CD
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_USECD))
            {
                wRet.UseCD = wXlRange.Range.Value2 as string ?? string.Empty;
            }

			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            ////  記録簿CD
            //using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_RECORDCD))
            //{
            //    wRet.RecordCD = wXlRange.Range.Value2 as string ?? string.Empty;
            //}

            //// 点検レイアウトCD
            //using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_LAYOUTCD))
            //{
            //    wRet.LayoutCD = wXlRange.Range.Value2 as string ?? string.Empty;
            //}

            // 型式CD
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_MACHINETYPECD))
            {
                wRet.MachineTypeCD = wXlRange.Range.Value2 as string ?? string.Empty;
            }
			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            return wRet;
        }
        // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

        // add FNSI-523 2次元帳票対応 夏 start
        /// <summary>
        /// 集計設定データを取得します。
        /// </summary>
        /// <returns></returns>
        public TotalLayoutData GetTotalData()
        {
            var wRet = new TotalLayoutData();

            // 横の集計単位
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITV))
            {
                wRet.UnitV = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 縦の集計単位
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITH))
            {
                wRet.UnitH = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // add #11011 集計内訳タブ仕様変更 高 start
            // 横の集計単位Address
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITV_ADDRESS))
            {
                wRet.UnitVAddress = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 縦の集計単位Address
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITH_ADDRESS))
            {
                wRet.UnitHAddress = wXlRange.Range.Value2 as string ?? string.Empty;
            }
            // add #11011 集計内訳タブ仕様変更 高 end

            // 集計単位日付
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITDATE))
            {
                wRet.UnitDate = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            // 出力値のない列は省略する
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_EFFECT_DATA_V))
            {
                wRet.EffectDataV = wXlRange.Range.Value2 as string ?? string.Empty;
            }
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
            // 出力値のない行は省略する
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_EFFECT_DATA_H))
            {
                wRet.EffectDataH = wXlRange.Range.Value2 as string ?? string.Empty;
            }
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

            // 表示内容
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_CONTENTS))
            {
                wRet.Contents = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 表示変換
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_CONVERSION))
            {
                wRet.Conversion = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 縦の合計
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_COUNT_H))
            {
                wRet.CountH = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 横の合計
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_COUNT_V))
            {
                wRet.CountV = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // 起点セル
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_ORIGINRANGE))
            {
                wRet.OriginRange = wXlRange.Range.Value2 as string ?? string.Empty;
            }

            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            // 表示内容種類
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_CONTENTS_TYPE))
            {
                wRet.ContentsType = wXlRange.Range.Value2 as string ?? string.Empty;
            }
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            // add  #6035 2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 start
            using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_REPORTTYPE))
            {
                wRet.ReportType = wXlRange.Range.Value2 as string ?? string.Empty;
            }
            // add #6035 2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 end
            return wRet;
        }
        // add FNSI-523 2次元帳票対応 夏 end

        /// <summary>
        /// 履歴データを取得します。
        /// </summary>
        /// <returns></returns>
        public List<DesignHistoryData> GetSheetHistoryDataList()
        {
            var wRet = new List<DesignHistoryData>();
            object[,] wGetValues = null;

            try
            {
                // 履歴シートからデータを取得
                using (var wXlRange = new ExcelRangeEx(this.XlSheetHistory.Worksheet.UsedRange))
                {
                    wGetValues = wXlRange.GetValue2();
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("更新履歴データの取得に失敗しました。", ex),
                    true);
            }

            // 正常にデータを取得できた場合
            // mod 2020-11-02 UTバグ6の修正 履歴画面表示 夏 start
            //if (wGetValues != null && wGetValues.GetLength(0) > 1)
            if (wGetValues != null && wGetValues.GetLength(0) > 0)
            // mod 2020-11-02 UTバグ6の修正 履歴画面表示 夏 end
            {
                // 1行目からを取り込む
                for (int wLopCnt = 1; wLopCnt <= wGetValues.GetLength(0); wLopCnt++)
                {

                    // 編集日時列を取得
                    // mod 2020-11-02 UTバグ6の修正 履歴画面表示 夏 start
                    //string wEditTime = wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.EditTime + 1] as String;
                    string wEditTime = "";
                    if (wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.EditTime + 1].ToString().IndexOf(":") >= 0)
                    {
                        wEditTime = wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.EditTime + 1] as String;
                    }
                    else
                    {
                        wEditTime = DateTime.FromOADate(double.Parse(wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.EditTime + 1].ToString())).ToString();
                    }
                    // mod 2020-11-02 UTバグ6の修正 履歴画面表示 夏 end
                    // データがない場合は抜ける
                    if (string.IsNullOrEmpty(wEditTime))
                    {
                        continue;
                    }

                    var wData = new DesignHistoryData()
                    {
                        // mod 2020-11-02 UTバグ6の修正 履歴画面表示 夏 start
                        //Editor = wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.Editor + 1] as string ?? string.Empty,
                        Editor = Convert.ToString(wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.Editor + 1]) ?? string.Empty,
                        // mod 2020-11-02 UTバグ6の修正 履歴画面表示 夏 start
                        EditTime = wEditTime,
                        DataName = wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.DataName + 1] as string ?? string.Empty,
                        Address = wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.Address + 1] as string ?? string.Empty,
                        Content = wGetValues[wLopCnt, (int)DesignHistoryData.EnumDataIndex.Content + 1] as string ?? string.Empty
                    };

                    // バインディングリストへ追加
                    wRet.Add(wData);
                }
            }


            return wRet;
        }

        /// <summary>
        /// 設定データをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public bool SetSettingData(DesignSettingData aData)
        {
            bool wRet = false;

            try
            {
                // 現在の設定内容を退避
                var wBackUp = this.GetSettingData();

                // 設定シートの保護を解除
                this.XlSheetSetting.IsProtected = false;

                // 範囲を初期化
                string wRangeStr = string.Format("{0}:{1}", RldConst.SettingData.CELLADDR_REPORT_TYPE, RldConst.SettingData.CELLADDR_HAS_TEMPLETE);
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, wRangeStr))
                {
                    wXlRange.Range.Clear();
                    wXlRange.Range.NumberFormat = "@";
                }

                // 帳票種別を保存
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.SettingData.CELLADDR_REPORT_TYPE))
                {
                    wXlRange.Range.Value2 = aData.ReportClass;
                }

                // レポートCDを保存
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.SettingData.CELLADDR_REPORT_CODE))
                {
                    wXlRange.Range.Value2 = aData.ReportCode;
                }

                // テンプレート繰返し有無を保存
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.SettingData.CELLADDR_HAS_TEMPLETE))
                {
                    wXlRange.Range.Value2 = aData.HasTemplete;
                }

                // ここまでエラーがなければ変更履歴データを作成して更新履歴シートへ追加
                this.AddHistory(new List<DesignHistoryData>() { this.CreateHistory(wBackUp, aData) });

                // エラーがなければOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用設定データの作成中にエラーが発生しました。", ex),
                    true);
            }
            finally
            {
                // 設定シートを保護
                this.XlSheetSetting.IsProtected = true;
            }

            return wRet;
        }

        /// <summary>
        /// パラメータシートへデータをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aParamList"></param>
        /// <returns></returns>
        public bool SetSheetParamDataList(System.ComponentModel.BindingList<DesignParamData> aParamList)
        {
            bool wRet = false;
            object[,] wSetValues = null;
            // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
            middleData = new Dictionary<object, string>();
            // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
            // セットするデータを作成する
            try
            {
                // 保存対象列をセット
                var wColumnList = DesignParamData.GetReadWriteDataList();

                // 行数/列数を取得
                int wRowCnt = aParamList.Count;
                int wColCnt = wColumnList.Count;

                // 配列生成
                wSetValues = new object[wRowCnt + 1, wColCnt];

                int wLopCnt = 0, wColIndex = -1;

                // 1行目に列名をセット
                wColumnList.ForEach(ele => wSetValues[wLopCnt, ++wColIndex] = DesignParamData.GetProperty(ele).Name);

                // 2行目以降にデータをセット
                foreach (var wData in aParamList)
                {

                    wLopCnt++; wColIndex = -1;

                    wSetValues[wLopCnt, ++wColIndex] = wData.DataPath;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataCategory;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataClass;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataName;
                    wSetValues[wLopCnt, ++wColIndex] = wData.SqlCode;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataCode;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataType;
                    wSetValues[wLopCnt, ++wColIndex] = wData.PreviewData;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DisplayFormat;
                    wSetValues[wLopCnt, ++wColIndex] = wData.ConvertList.ToXmlElementText();
                    wSetValues[wLopCnt, ++wColIndex] = Convert.ToString(wData.CanRepeat);
                    wSetValues[wLopCnt, ++wColIndex] = wData.RepeatAddress;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsShrink;
                    wSetValues[wLopCnt, ++wColIndex] = wData.Length;
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterData;
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterType;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsNewPage;
                    wSetValues[wLopCnt, ++wColIndex] = wData.LabelItem;
                    wSetValues[wLopCnt, ++wColIndex] = wData.CellAddress;
                    wSetValues[wLopCnt, ++wColIndex] = wData.GroupName;
                    //add #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterState;
                    //add #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsInTemplete;
                    wSetValues[wLopCnt, ++wColIndex] = wData.ParticularInfo;
                    wSetValues[wLopCnt, ++wColIndex] = Convert.ToString(wData.IsCalcResult);
                    // 条件付き書式ルール設定をXML文字列に変更して格納する
                    // del #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 start
                    //wSetValues[wLopCnt, ++wColIndex] = wData.FormatCondition.ToXmlElementText();
                    // del #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 end
                    // add #11535 帳票の汎用バーコード出力対応 高 start
                    wSetValues[wLopCnt, ++wColIndex] = Convert.ToString(wData.CanBarCode);
                    wSetValues[wLopCnt, ++wColIndex] = RldLib.barCodeDic[wData.BarCode];
                    // add #11535 帳票の汎用バーコード出力対応 高 end
                    // add 2021-08-30 6009画像 李 start
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsImage;
                    // add 2021-08-30 6009画像 李 end
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    if (doPassData.Contains(wData.FilterType))
                    {
                        middleData.Add(wData.GroupPath, wData.FilterData);
                    }
                    // add #10375 患者イベント(テキストエリア)の出力が不正 高 start
                    if (string.IsNullOrEmpty(wData.CellAddress) == false && string.IsNullOrEmpty(wData.RowCount) == false)
                    {
                        using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
                        {
                            wData.RowCount = Convert.ToString(wXlRange.GetStringRowCount());
                        }
                    }
                    // add #10375 患者イベント(テキストエリア)の出力が不正 高 end
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
                    wSetValues[wLopCnt, ++wColIndex] = wData.RowCount;
                    //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用パラメータデータの作成中にエラーが発生しました。", ex),
                    true);
            }

            // セットするデータが正常に作成できた場合は保存処理実行
            if (wSetValues != null)
            {
                try
                {
                    // 現在の設定内容を退避
                    var wBackUp = this.GetSheetParamDataList();

                    // 値をセットするセル範囲を決定
                    string wRangeAddr = string.Format(
                        "A1:{0}",
                        this.XlApp.ConvertR1C1ToA1(wSetValues.GetLength(0), wSetValues.GetLength(1)));

                    // パラメータシートの保護を解除
                    this.XlSheetParam.IsProtected = false;

                    // シートをクリア
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetParam.Worksheet.Cells))
                    {
                        wXlRange.Range.Clear();
                        wXlRange.Range.NumberFormat = "@";
                    }

                    // セルに代入
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetParam, wRangeAddr))
                    {
                        wXlRange.Range.Value = wSetValues;
                    }

                    // ここまでエラーがなければ変更履歴データを作成して更新履歴シートへ追加
                    this.AddHistory(this.CreateHistory(wBackUp, aParamList));

                    // エラーがなければOK
                    wRet = true;
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("パラメータデータの保存中にエラーが発生しました。", ex),
                        true);
                }
                finally
                {
                    // パラメータシートを保護
                    this.XlSheetParam.IsProtected = true;
                }
            }

            return wRet;
        }

        /// <summary>
        /// グループシートにデータをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aGroupList"></param>
        /// <returns></returns>
        public bool SetSheetGroupDataList(System.ComponentModel.BindingList<DesignGroupData> aGroupList)
        {
            bool wRet = false;
            object[,] wSetValues = null;

            // セットするデータを作成する
            try
            {
                // 保存対象列をセット
                var wColumnList = DesignGroupData.GetReadWriteDataList();

                // 行数/列数を取得
                int wRowCnt = aGroupList.Count, wColCnt = wColumnList.Count;

                // 配列生成
                wSetValues = new object[wRowCnt + 1, wColCnt];

                int wLopCnt = 0, wColIndex = -1;

                // 1行目に列名をセット
                wColumnList.ForEach(ele => wSetValues[wLopCnt, ++wColIndex] = DesignGroupData.GetProperty(ele).Name);

                // 2行目以降にデータをセット
                foreach (var wData in aGroupList)
                {

                    wLopCnt++; wColIndex = -1;

                    wSetValues[wLopCnt, ++wColIndex] = wData.GroupPath;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataCategory;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataClass;
                    wSetValues[wLopCnt, ++wColIndex] = wData.GroupName;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsNewPage;
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    //wSetValues[wLopCnt, ++wColIndex] = wData.FilterData;
                    // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                    if (wData.FilterType == RldConst.FilterType.Group.MEDICINE ||
                        wData.FilterType == RldConst.FilterType.Group.EQUIP ||
                        wData.FilterType == RldConst.FilterType.Group.CATEGORY)
                    {
                        wSetValues[wLopCnt, ++wColIndex] = wData.FilterData;
                    }
                    //if (middleData.ContainsKey(wData.GroupPath))
                    else if (middleData.ContainsKey(wData.GroupPath))
                    // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                    {
                        wSetValues[wLopCnt, ++wColIndex] = middleData[wData.GroupPath];
                    }
                    else
                    {
                        wSetValues[wLopCnt, ++wColIndex] = wData.FilterData;
                    }
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterType;
                    wSetValues[wLopCnt, ++wColIndex] = wData.RepeatCount;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsInTemplete;
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用グループデータの作成中にエラーが発生しました。", ex),
                    true);
            }

            // セットするデータが正常に作成できた場合は保存処理実行
            if (wSetValues != null)
            {
                try
                {
                    // 現在の設定内容を退避
                    var wBackUp = this.GetSheetGroupDataList();

                    // 値をセットするセル範囲を決定
                    string wRangeAddr = string.Format(
                        "A1:{0}",
                        this.XlApp.ConvertR1C1ToA1(wSetValues.GetLength(0), wSetValues.GetLength(1)));

                    // グループシートの保護を解除
                    this.XlSheetGroup.IsProtected = false;

                    // シートをクリア
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetGroup.Worksheet.Cells))
                    {
                        wXlRange.Range.Clear();
                        wXlRange.Range.NumberFormat = "@";
                    }

                    // セルに代入
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetGroup, wRangeAddr))
                    {
                        wXlRange.Range.Value = wSetValues;
                    }

                    // ここまでエラーがなければ変更履歴データを作成して更新履歴シートへ追加
                    this.AddHistory(this.CreateHistory(wBackUp, aGroupList));

                    // エラーがなければOK
                    wRet = true;
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("グループデータの保存中にエラーが発生しました。", ex),
                        true);
                }
                finally
                {
                    // グループシートを保護
                    this.XlSheetGroup.IsProtected = true;
                }
            }

            return wRet;
        }

        /// <summary>
        /// テンプレート繰返しデータをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public bool SetTempleteData(DesignTempleteData aData)
        {
            bool wRet = false;

            try
            {
                // 現在の設定内容を退避
                var wBackUp = this.GetTempleteData();

                // 設定シートの保護を解除
                this.XlSheetSetting.IsProtected = false;

                // 範囲を初期化
                string wRangeStr = string.Format("{0}:{1}", RldConst.TempleteData.CELLADDR_RANGE, RldConst.TempleteData.CELLADDR_REPEATMODE);
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, wRangeStr))
                {
                    wXlRange.Range.Clear();
                    wXlRange.Range.NumberFormat = "@";
                }

                if (aData != null)
                {
                    // 繰返し範囲
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_RANGE))
                    {
                        wXlRange.Range.Value2 = aData.Range;
                    }

                    // 行数
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_ROWCOUNT))
                    {
                        wXlRange.Range.Value2 = Convert.ToString(aData.RowCount);
                    }

                    // 列数
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_COLUMNCOUNT))
                    {
                        wXlRange.Range.Value2 = Convert.ToString(aData.ColumnCount);
                    }

                    // 繰返し回数(縦)
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEAT_V))
                    {
                        wXlRange.Range.Value2 = aData.RepeatCountV;
                    }

                    // 繰返し回数(横)
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEAT_H))
                    {
                        wXlRange.Range.Value2 = aData.RepeatCountH;
                    }

                    // 余白(縦)
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_MARGIN_V))
                    {
                        wXlRange.Range.Value2 = aData.MarginV;
                    }

                    // 余白(横)
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_MARGIN_H))
                    {
                        wXlRange.Range.Value2 = aData.MarginH;
                    }

                    // 改ページ
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_ISNEWPAGE))
                    {
                        wXlRange.Range.Value2 = aData.IsNewPage;
                    }

                    // 繰返し方向
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_DIRECTION))
                    {
                        wXlRange.Range.Value2 = aData.DirectionData;
                    }

                    // 繰返しモード
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEATMODE))
                    {
                        wXlRange.Range.Value2 = aData.RepeatMode;
                    }
                    //add #8763 zhu start
                    // 繰り返しキー
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TempleteData.CELLADDR_REPEATNO))
                    {
                        wXlRange.Range.Value2 = aData.RepeatNo;
                    }
                    //add #8763 zhu end 
                }

                // ここまでエラーがなければ変更履歴データを作成して更新履歴シートへ追加
                this.AddHistory(new List<DesignHistoryData>() { this.CreateHistory(wBackUp, aData) });

                // エラーがなければOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用テンプレート繰返しデータの作成中にエラーが発生しました。", ex),
                    true);
            }
            finally
            {
                // 設定シートを保護
                this.XlSheetSetting.IsProtected = true;
            }

            return wRet;
        }

        // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
        /// <summary>
        /// 装置データをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public bool SetDeviceData(InspectionLayoutData aData)
        {
            bool wRet = false;

            try
            {
                // 現在の設定内容を退避
                var wBackUp = this.GetDeviceData();

                // 設定シートの保護を解除
                this.XlSheetSetting.IsProtected = false;

                // 範囲を初期化
				// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //string wRangeStr = string.Format("{0}:{1}", RldConst.InspectionLayoutData.CELLADDR_REPORTTYPE, RldConst.InspectionLayoutData.CELLADDR_LAYOUTCD);
                string wRangeStr = string.Format("{0}:{1}", RldConst.InspectionLayoutData.CELLADDR_REPORTTYPE, RldConst.InspectionLayoutData.CELLADDR_MACHINETYPECD);
				// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, wRangeStr))
                {
                    wXlRange.Range.Clear();
                    wXlRange.Range.NumberFormat = "@";
                }

                if (aData != null)
                {
                    // 帳票区分
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_REPORTTYPE))
                    {
                        wXlRange.Range.Value2 = aData.ReportType;
                    }

                    // 用途CD
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_USECD))
                    {
                        wXlRange.Range.Value2 = aData.UseCD;
                    }

					// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    //// 記録簿CD
                    //using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_RECORDCD))
                    //{
                    //    wXlRange.Range.Value2 = aData.RecordCD;
                    //}

                    //// 点検レイアウトCD
                    //using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_LAYOUTCD))
                    //{
                    //    wXlRange.Range.Value2 = aData.LayoutCD;
                    //}

                    // 型式CD
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.InspectionLayoutData.CELLADDR_MACHINETYPECD))
                    {
                        wXlRange.Range.Value2 = aData.MachineTypeCD;
                    }
					// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                }
                // add UT帳票No.123 定期日常点検・交換部品記録簿の履歴データを表示不正の対応 夏 start
                // ここまでエラーがなければ変更履歴データを作成して更新履歴シートへ追加
                this.AddHistory(new List<DesignHistoryData>() { this.CreateDeviceHistory(wBackUp, aData) });
                // add UT帳票No.123 定期日常点検・交換部品記録簿の履歴データを表示不正の対応 夏 end

                // エラーがなければOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用装置データの作成中にエラーが発生しました。", ex),
                    true);
            }
            finally
            {
                // 設定シートを保護
                this.XlSheetSetting.IsProtected = true;
            }

            return wRet;
        }
        // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

        // add FNSI-523 2次元帳票対応 夏 start
        /// <summary>
        /// 集計データをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public bool SetTotalData(TotalLayoutData aData)
        {
            bool wRet = false;

            try
            {
                // 現在の設定内容を退避
                var wBackUp = this.GetTotalData();

                // 設定シートの保護を解除
                this.XlSheetSetting.IsProtected = false;

                // 範囲を初期化
                // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                //string wRangeStr = string.Format("{0}:{1}", RldConst.TotalData.CELLADDR_UNITV, RldConst.TotalData.CELLADDR_ORIGINRANGE);
                string wRangeStr = string.Format("{0}:{1}", RldConst.TotalData.CELLADDR_UNITV, RldConst.TotalData.CELLADDR_ENDPOIRANGE);
                // mod #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, wRangeStr))
                {
                    wXlRange.Range.Clear();
                    wXlRange.Range.NumberFormat = "@";
                }

                if (aData != null)
                {
                    // 横の集計単位
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITV))
                    {
                        wXlRange.Range.Value2 = aData.UnitV;
                    }

                    // 縦の集計単位
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITH))
                    {
                        wXlRange.Range.Value2 = aData.UnitH;
                    }
                    // add #11011 集計内訳タブ仕様変更 高 start
                    // 横の集計単位Address
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITV_ADDRESS))
                    {
                        wXlRange.Range.Value2 = aData.UnitVAddress;
                    }

                    // 縦の集計単位Address
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITH_ADDRESS))
                    {
                        wXlRange.Range.Value2 = aData.UnitHAddress;
                    }
                    // add #11011 集計内訳タブ仕様変更 高 end
                    // 集計単位日付
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_UNITDATE))
                    {
                        wXlRange.Range.Value2 = aData.UnitDate;
                    }

                    // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_EFFECT_DATA_V))
                    {
                        wXlRange.Range.Value2 = aData.EffectDataV;
                    }
                    // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

                    // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
                    // 出力値のない行は省略する
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_EFFECT_DATA_H))
                    {
                        wXlRange.Range.Value2 = aData.EffectDataH;
                    }
                    // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

                    // 表示内容
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_CONTENTS))
                    {
                        wXlRange.Range.Value2 = aData.Contents;
                    }

                    // 表示変換
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_CONVERSION))
                    {
                        wXlRange.Range.Value2 = aData.Conversion;
                    }

                    // 縦の合計
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_COUNT_H))
                    {
                        wXlRange.Range.Value2 = aData.CountH;
                    }

                    // 横の合計
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_COUNT_V))
                    {
                        wXlRange.Range.Value2 = aData.CountV;
                    }

                    // 起点セル
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_ORIGINRANGE))
                    {
                        wXlRange.Range.Value2 = aData.OriginRange;
                    }

                    // add #11973 日常点検一覧帳票が正常に出せない 高 start
                    // 表示内容種類
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_CONTENTS_TYPE))
                    {
                        wXlRange.Range.Value2 = aData.ContentsType;
                    }
                    // add #11973 日常点検一覧帳票が正常に出せない 高 end

                    //mod #6373  2022-04-12 判定条件の追加   鄭 　start 
                    //// add #6035　2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない 孟堅　start 
                    //using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_REPORTTYPE))
                    //{
                    //    wXlRange.Range.Value2 = aData.ReportType;
                    //}
                    if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER)
                    {
                        using (var wXlRange = new ExcelRangeEx(this.XlSheetSetting, RldConst.TotalData.CELLADDR_REPORTTYPE))
                        {
                            wXlRange.Range.Value2 = aData.ReportType;
                        }
                    }
                    //// add #6035　2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 end
                    //mod #6373  2022-04-12  判定条件の追加  鄭 　start 
                }

                // ここまでエラーがなければ変更履歴データを作成して更新履歴シートへ追加
                this.AddHistory(new List<DesignHistoryData>() { this.CreateTotalHistory(wBackUp, aData) });

                // エラーがなければOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用集計データの作成中にエラーが発生しました。", ex),
                    true);
            }
            finally
            {
                // 設定シートを保護
                this.XlSheetSetting.IsProtected = true;
            }

            return wRet;
        }
        // add FNSI-523 2次元帳票対応 夏 end

        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
        /// <summary>
        /// FNW帳票レイアウトがコンバートします。
        /// </summary>
        /// <returns></returns>
        public bool SetTotalLayoutData()
        {
            bool wRet = false;

            try
            {
                String rangeAddress = "A1:XFD1048576";

                bool checkFlag = false;

                // レイアウトシートの保護を解除
                RldLib.XlHelper.XlSheetLayout.IsProtected = false;

                // パラメータ編集データをクリア
                RldLib.CurrentLayoutData.DesignParamList.Clear();

                // グループ編集データをクリア
                // mod #8314 グループタブの表示不正 王占宇 start
                // RldLib.CurrentLayoutData.DesignGroupList.Clear();
                List<DesignGroupData> itemList = new List<DesignGroupData>();
                itemList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
                itemList.ForEach(p => RldLib.CurrentLayoutData.DesignGroupList.Remove(p));
                // mod #8314 グループタブの表示不正 王占宇 end

                // 旧帳票のパラメータ編集データをクリア
                RldLib.CurrentLayoutData.DataParamFromOldReportList.Clear();

                // 旧帳票のパラメータシート読み込み
                if (!this.GetOldSheetParamDataList())
                {
                    return false;
                }

                // 旧帳票のグループ編集データをクリア
                RldLib.CurrentLayoutData.DataGroupFromOldReportList.Clear();

                // 旧帳票のグループシート読み込み
                if (!this.GetOldSheetGroupDataList())
                {
                    return false;
                }

                // パラメータシート読み込み
                Dictionary<String, dynamic> wChangedRangeManagedCellValueList;

                var wParamFromOldReportDataList = new System.ComponentModel.BindingList<DesignParamFromOldReportData>();

                // 影響を受けるアイテムを修正する
                using (var wXlSheetCells = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, rangeAddress))
                {
                    // del #8335 FNW帳票取込みの動作に問題あり 夏 start
                    // // 変更された範囲内の管理対象セルのアドレスと値を取得
                    // wChangedRangeManagedCellValueList = wXlSheetCells.FindCellAddrValue(
                    //     RldConst.PATH_HEADER, Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
                    // del #8335 FNW帳票取込みの動作に問題あり 夏 end
                    // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                    wChangedRangeManagedCellValueList = new Dictionary<string, dynamic>();
                    foreach (var wRetData in RldLib.CurrentLayoutData.DataParamFromOldReportList)
                    {
                        wChangedRangeManagedCellValueList.Add(wRetData.CellAddress, wRetData.DataPath);
                    }
                    // add #8335 FNW帳票取込みの動作に問題あり 夏 end

                    // 変更された範囲に含まれているバインディングリストアイテムを取得
                    foreach (var wData in wChangedRangeManagedCellValueList)
                    {
                        checkFlag = false;
                        if (wData.Value.StartsWith(RldConst.CALC_HEADER))
                        {
                            // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                            foreach (var wRetData in RldLib.CurrentLayoutData.DataParamFromOldReportList)
                            {
                                if (wRetData.DataPath == wData.Value && wRetData.CellAddress == wData.Key)
                                {
                                    var wDataOldReportData = new DesignParamFromOldReportData()
                                    {
                                        DataPath = wRetData.DataPath,
                                        DisplayFormat = wRetData.DisplayFormat,
                                        CanRepeat = wRetData.CanRepeat,
                                        RepeatAddress = wRetData.RepeatAddress,
                                        Length = wRetData.Length,
                                        CellAddress = wRetData.CellAddress,
                                        IsShrink = wRetData.IsShrink,
                                        IsNewPage = wRetData.IsNewPage,
                                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                        GroupName = wRetData.GroupName,
                                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                        // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                        DataType = wRetData.DataType,
                                        FilterData = wRetData.FilterData,
                                        LabelItem = wRetData.LabelItem,
                                        // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
                                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                        FilterType = wRetData.FilterType
                                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                    };

                                    // add 2023-03-21 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                                    // テンプレート内外[外]
                                    wDataOldReportData.IsInTemplete = wRetData.IsInTemplete;
                                    // add 2023-03-21 #8335 鵬 end
                                    wParamFromOldReportDataList.Add(wDataOldReportData);
                                    break;
                                }
                            }
                            // add #8335 FNW帳票取込みの動作に問題あり 夏 end
                            continue;
                        }

                        foreach (var wDataforConvert in RldLib.CurrentLayoutData.DataItemConvertList)
                        {
                            if (wDataforConvert.DataName == wData.Value)
                            {
                                foreach (var wRetData in RldLib.CurrentLayoutData.DataParamFromOldReportList)
                                {
                                    if (wRetData.DataPath == wData.Value && wRetData.CellAddress == wData.Key)
                                    {
                                        var wDataOldReportData = new DesignParamFromOldReportData()
                                        {
                                            DataPath = wDataforConvert.NewDataName,
                                            DisplayFormat = wRetData.DisplayFormat,
                                            CanRepeat = wRetData.CanRepeat,
                                            RepeatAddress = wRetData.RepeatAddress,
                                            Length = wRetData.Length,
                                            CellAddress = wRetData.CellAddress,
                                            IsShrink = wRetData.IsShrink,
                                            IsNewPage = wRetData.IsNewPage,
                                            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                            GroupName = wRetData.GroupName,
                                            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                            DataType = wRetData.DataType,
                                            ConvertList = wRetData.ConvertList,
                                            FilterData = wRetData.FilterData,
                                            LabelItem = wRetData.LabelItem,
                                            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
                                            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                            FilterType = wRetData.FilterType
                                            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                        };

                                        // add 2023-03-21 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                                        // テンプレート内外[外]
                                        wDataOldReportData.IsInTemplete = wRetData.IsInTemplete;
                                        // add 2023-03-21 #8335 鵬 end
                                        wParamFromOldReportDataList.Add(wDataOldReportData);
                                        break;
                                    }
                                }

                                using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wData.Key))
                                {
                                    wXlRange.Range.Value2 = wDataforConvert.NewDataName;
                                    checkFlag = true;
                                    break;
                                }
                            }
                        }

                        if (!checkFlag)
                        {
                            using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wData.Key))
                            {
                                wXlRange.Range.Interior.Color = Color.FromArgb(247, 222, 222);
                            }
                        }
                    }

                    // del #8335 FNW帳票取込みの動作に問題あり 夏 start
                    // // 変更された範囲内の管理対象セルのアドレスと値を取得
                    // wChangedRangeManagedCellValueList = wXlSheetCells.FindCellAddrValue(
                    //     RldConst.PATH_HEADER, Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
                    // del #8335 FNW帳票取込みの動作に問題あり 夏 end
                    // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                    wChangedRangeManagedCellValueList = new Dictionary<string, dynamic>();

                    // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                    Dictionary<string, string> wGroupNameValueList = new Dictionary<string, string>();
                    Dictionary<string, string> wIsInTempleteValueList = new Dictionary<string, string>();
                    Dictionary<string, Boolean> wCanRepeatValueList = new Dictionary<string, Boolean>();
                    // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end

                    // add #8536 【FNW帳票の取り込み】設定がクリアされて取り込まれる 董昊 start
                    Dictionary<string, string> wRepeatAddressValulist = new Dictionary<string, string>();
                    // add #8536 【FNW帳票の取り込み】設定がクリアされて取り込まれる 董昊 end

                    // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                    Dictionary<string, string> wFifterTypeValueList = new Dictionary<string, string>();
                    // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end

                    foreach (var wRetData in wParamFromOldReportDataList)
                    {
                        wChangedRangeManagedCellValueList.Add(wRetData.CellAddress, wRetData.DataPath);
                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                        wGroupNameValueList.Add(wRetData.CellAddress, wRetData.GroupName);
                        wIsInTempleteValueList.Add(wRetData.CellAddress, wRetData.IsInTemplete);
                        wCanRepeatValueList.Add(wRetData.CellAddress, wRetData.CanRepeat);
                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 en

                        // add #8536 【FNW帳票の取り込み】設定がクリアされて取り込まれる 董昊 start
                        wRepeatAddressValulist.Add(wRetData.CellAddress, wRetData.RepeatAddress);
                        // add #8536 【FNW帳票の取り込み】設定がクリアされて取り込まれる 董昊 end

                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                        wFifterTypeValueList.Add(wRetData.CellAddress, wRetData.FilterType);
                        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                    }
                    // add #8335 FNW帳票取込みの動作に問題あり 夏 end

                    // 変更された範囲に含まれているバインディングリストアイテムを取得
                    foreach (var wData in wChangedRangeManagedCellValueList)
                    {
                        checkFlag = false;
                        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                        if (RldConst.PATH_HEADER.Equals(wData.Value))
                        {
                            continue;
                        }
                        // add #8335 FNW帳票取込みの動作に問題あり 夏 end
                        if (RldConst.CALC_HEADER.Equals(wData.Value.Substring(0, 3)))
                        {
                            // add #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 start
                            var wDesignParamData = RldLib.CurrentLayoutData.CreateDesignParamData(wData.Value, wData.Key);
                            wDesignParamData = RldLib.ApplyAdditionalInfoToParamData(wDesignParamData);
                            RldLib.CurrentLayoutData.DesignParamList.Add(wDesignParamData);
                            RldLib.CurrentLayoutData.CreateAndAddDesignGroupData(wDesignParamData);
                            // add #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 end
                            continue;
                        }

                        foreach (var wDataItem in RldLib.CurrentLayoutData.DataItemList)
                        {
                            if (wDataItem.DataPath == wData.Value)
                            {
                                var wDesignParamData = new DesignParamData()
                                {
                                    DataPath = wDataItem.DataPath,
                                    DataCategory = wDataItem.DataCategory as string ?? string.Empty,
                                    DataClass = wDataItem.DataClass as string ?? string.Empty,
                                    DataName = wDataItem.DataName as string ?? string.Empty,
                                    SqlCode = wDataItem.SqlCode as string ?? string.Empty,
                                    DataCode = wDataItem.DataCode as string ?? string.Empty,
                                    DataType = wDataItem.DataType as string ?? string.Empty,
                                    PreviewData = wDataItem.PreviewData as string ?? string.Empty,
                                    FilterData = string.Empty,
                                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                    //FilterType = wDataItem.FilterType as string ?? string.Empty,
                                    FilterType = wFifterTypeValueList[wData.Key] as string ?? string.Empty,
                                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                    LabelItem = string.Empty,
                                    CellAddress = wData.Key,
                                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                    //GroupName-wDataItem.GroupName as string ?? string.Empty,
                                    //IsInTemplete = string.Empty,
                                    GroupName = wGroupNameValueList[wData.Key] as string ?? string.Empty,
                                    IsInTemplete = wIsInTempleteValueList[wData.Key] as string ?? string.Empty,
                                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                    // add #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 start
                                    DisplayFormat = wDataItem.DisplayFormat as string ?? string.Empty,
                                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                    //CanRepeat = wDataItem.CanRepeat,
                                    CanRepeat = wCanRepeatValueList[wData.Key],
                                    // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                    ConvertList = wDataItem.ConvertList,
                                    // add #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 end
                                    ParticularInfo = wDataItem.ParticularInfo as string ?? string.Empty
                                };

                                // add #8335 FNW帳票取込みの動作に問題あり 夏 start
                                if (!String.IsNullOrEmpty(RldLib.StrOldFileName)
                                    && !String.IsNullOrEmpty(wDesignParamData.FilterType)
                                    && wDesignParamData.CanEditFilter)
                                {
                                    wDesignParamData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                                }
                                // add #8335 FNW帳票取込みの動作に問題あり 夏 end

                                // add #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 start
                                if (wDesignParamData.CanRepeat == true)
                                {
                                    // mod #8536 【FNW帳票の取り込み】設定がクリアされて取り込まれる 董昊 start
                                    //wDesignParamData.RepeatAddress = wData.Key;
                                    wDesignParamData.RepeatAddress = wRepeatAddressValulist[wData.Key];
                                    // mod #8536 【FNW帳票の取り込み】設定がクリアされて取り込まれる 董昊 end
                                }
                                // add #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 end

                                foreach (var wParamFromOldReportData in wParamFromOldReportDataList)
                                {
                                    if (wParamFromOldReportData.DataPath == wData.Value && wParamFromOldReportData.CellAddress == wData.Key)
                                    {
                                        // del #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 start
                                        //wDesignParamData.DisplayFormat = wParamFromOldReportData.DisplayFormat;
                                        //wDesignParamData.CanRepeat = wParamFromOldReportData.CanRepeat;
                                        //wDesignParamData.RepeatAddress = wParamFromOldReportData.RepeatAddress;
                                        // del #8039 （帳票種別：治療経過表）正しく表示されない 日本指摘対応 商 end
                                        //edit #8457 表示文字列長の対応 dongzhaolong start
                                        string OldLength = wParamFromOldReportData.Length;
                                        //wDesignParamData.Length = wParamFromOldReportData.Length;
                                        wDesignParamData.IsShrink = wParamFromOldReportData.IsShrink;
                                        wDesignParamData.Length = OldLength;
                                        //edit #8457 表示文字列長の対応 dongzhaolong end
                                        wDesignParamData.IsNewPage = wParamFromOldReportData.IsNewPage;

                                        // add 2023-03-21 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                                        wDesignParamData.IsInTemplete = wParamFromOldReportData.IsInTemplete;
                                        // add 2023-03-21 #8335 鵬 end
                                        break;
                                    }
                                }

                                RldLib.CurrentLayoutData.DesignParamList.Add(wDesignParamData);

                                // mod #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                var wDesignParamDataGroup = new DesignParamData(wDesignParamData);

                                //add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                foreach (var wGroupFormOldReportData in RldLib.CurrentLayoutData.DataGroupFromOldReportList)
                                {
                                    if (wDesignParamDataGroup.GroupName == wGroupFormOldReportData.GroupName)
                                    {
                                        wDesignParamDataGroup.IsNewPage = wGroupFormOldReportData.IsNewPage;
                                        wDesignParamDataGroup.FilterType = wGroupFormOldReportData.FilterType;
                                        wDesignParamDataGroup.IsInTemplete = wGroupFormOldReportData.IsInTemplete;
                                    }
                                    //mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                }
                                //add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end

                                // グループに属する場合は所属先グループが存在するか確認し、無ければ作成して追加する
                                RldLib.CurrentLayoutData.CreateAndAddDesignGroupData(wDesignParamDataGroup);
                                // mod #12050 FNW帳票コンバートで維持されない設定がある 高 end

                                //add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                foreach (var wParamFromOldReportData in wParamFromOldReportDataList)
                                {
                                    if (wParamFromOldReportData.DataPath == wData.Value && wParamFromOldReportData.CellAddress == wData.Key)
                                    {

                                        //mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 start                                   
                                        if (!wParamFromOldReportData.CanRepeat &&
                                           wParamFromOldReportData.DataType.ToLower() == RldConst.ParamData.VAL_DATATYPE_STRING &&
                                           wParamFromOldReportData.IsShrink == RldConst.ParamData.VAL_ISSHRINK_NONE)
                                        {
                                            wDesignParamData.IsNewPage = wParamFromOldReportData.IsNewPage;
                                        }
                                        else
                                        {
                                            wDesignParamData.IsNewPage = string.Empty;
                                        }
                                        //mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end

                                        //add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start 
                                        wDesignParamData.FilterType = wParamFromOldReportData.FilterType;
                                        //add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end 

                                        // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                        // ConvertList
                                        if (wParamFromOldReportData.ConvertList.Count != 0 && wDesignParamData.ConvertList.Count != 0)
                                        {
                                            foreach (var wDataNew in wDesignParamData.ConvertList)
                                            {
                                                string ItemValueNew = wDataNew.ItemValue?.Replace(" ", "").ToLower() ?? string.Empty;
                                                foreach (var wDataOld in wParamFromOldReportData.ConvertList)
                                                {
                                                    string ItemValueOld = wDataOld.ItemValue?.Replace(" ", "").ToLower() ?? string.Empty;
                                                    if(string.IsNullOrEmpty(ItemValueOld) == false && 
                                                        string.IsNullOrEmpty(ItemValueNew) == false && ItemValueOld == ItemValueNew)
                                                    {
                                                        wDataNew.DisplayValue = wDataOld.DisplayValue;
                                                        break;
                                                    }
                                                }
                                            }
                                        }

                                        // フィルタデータ
                                        switch (wParamFromOldReportData.FilterType)
                                        {
                                            case RldConst.FilterType.Group.EXAMINE:     // 検査項目
                                            case RldConst.FilterType.Group.EXAM_SET:    // 検査セット
                                                // read FilterData
                                                wDesignParamData.FilterData = convertExamItem(wParamFromOldReportData.FilterData);
                                                if (string.IsNullOrEmpty(wDesignParamData.FilterData) == false)
                                                    wDesignParamData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_RESET;
                                                break;
                                            default:
                                                break;
                                        }

                                        // ラベル項目
                                        if(string.IsNullOrEmpty(wParamFromOldReportData.LabelItem) == false)
                                        {
                                            wDesignParamData.LabelItem = convertLabelItem(wParamFromOldReportData.LabelItem);
                                        }
                                        // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

                                        break;
                                    }
                                }
                                //add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end

                                checkFlag = true;
                                break;
                            }
                        }
                        if (!checkFlag)
                        {
                            using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wData.Key))
                            {
                                wXlRange.Range.Interior.Color = Color.FromArgb(247, 222, 222);
                            }
                        }
                    }
                }
                // エラーがなければOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("旧帳票のレイアウトデータの保存中にエラーが発生しました。", ex),
                    true);
            }
            finally
            {
                // パラメータシートを保護
                this.XlSheetParam.IsProtected = true;
            }

            return wRet;
        }

        // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
        // read item of 検査項目 or 検査セット from FilterData, convert item
        // return FilterData or ""
        private string convertExamItem(string pFilterData)
        {
            string wBefore = null;
            string wAfter = null;
            string wOther = null;
            string wCode = null;

            // フィルタが未設定の場合は抜ける
            if (String.IsNullOrEmpty(pFilterData)) return "";

            var wXmlDoc = new System.Xml.XmlDocument();
            try
            {
                wXmlDoc.LoadXml(pFilterData);
            }
            catch
            {
                return "";
            }

            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM.ToUpper()));

            // read item of 検査項目 or 検査セット
            foreach (System.Xml.XmlNode wXmlChild in wChildNode)
            {
                var wAttr = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_BEFORE.ToUpper()];
                if (wAttr != null)
                    wBefore = wAttr.InnerText.Trim();
                wAttr = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_AFTER.ToUpper()];
                if (wAttr != null)
                    wAfter = wAttr.InnerText.Trim();
                wAttr = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_OTHER.ToUpper()];
                if (wAttr != null)
                    wOther = wAttr.InnerText.Trim();
                wAttr = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_CODE.ToUpper()];
                if (wAttr != null)
                    wCode = wAttr.InnerText.Trim();

                break;
            }

            // save item of 検査項目 or 検査セット
            if (wChildNode.Count > 0)
            {
                var wXmlDocSave = new System.Xml.XmlDocument();

                // ルートノードを作成
                var wXmlRootSave = wXmlDocSave.CreateElement(RldConst.FilterData.TAG_ROOT);
                var wXmlItemSave = wXmlDocSave.CreateElement(RldConst.FilterData.TAG_ITEM);

                wXmlItemSave.SetAttribute(RldConst.FilterData.ATT_ITEM_CODE, "");
                wXmlItemSave.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_BEFORE, wBefore);
                wXmlItemSave.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_AFTER, wAfter);
                wXmlItemSave.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_OTHER, wOther);
                wXmlRootSave.AppendChild(wXmlItemSave);

                // ドキュメントへ追加
                return (wXmlDocSave.AppendChild(wXmlRootSave)).OuterXml;
            }

            return "";
        }

        // read FNW ラベル項目, convert FNSi ラベル項目
        // return FilterData or ""
        private string convertLabelItem(string pLabelItem)
        {
            string wDataType = null;
            string wDataKey = "";
            string wFixString = "";

            // 未設定の場合
            if (String.IsNullOrEmpty(pLabelItem)) return "";

            var wXmlDoc = new System.Xml.XmlDocument();
            try
            {
                wXmlDoc.LoadXml(pLabelItem);
            }
            catch
            {
                return "";
            }

            // 保存用にXMLインスタンス作成
            XmlDocument docSave = new XmlDocument();

            // XMLのルートを作成
            XmlElement rootSave = docSave.CreateElement(frmEditLabelClass.XML_ROOT);
            docSave.AppendChild(rootSave);

            rootSave.AppendChild(MakeEle(docSave, "AllClass", "", ""));

            // ルートを無視して中のアイテムを取得
            XmlNodeList nodes = wXmlDoc.GetElementsByTagName(frmEditLabelClass.XML_ITEM);

            for (int i = 0; i < nodes.Count; i++)
            {
                wDataKey = "";
                wFixString = "";

                // データのタイプを取得
                XmlAttribute att = nodes[i].Attributes[frmEditLabelClass.XML_ATT_TYPE];
                if (null == att)
                {
                    continue;
                }
                // データ種別
                wDataType = att.Value;

                att = nodes[i].Attributes[frmEditLabelClass.XML_ATT_KEY];
                if (null != att)
                {
                    // データキー
                    wDataKey = convertDataKey(att.Value);
                }
                att = nodes[i].Attributes[frmEditLabelClass.XML_ATT_FIX];
                if (null != att)
                {
                    // 固定文字列
                    wFixString = att.Value;
                }

                rootSave.AppendChild(MakeEle(docSave, wDataType, wDataKey, wFixString));
            }

            rootSave.AppendChild(MakeEle(docSave, "BloodRoad", "", ""));
            rootSave.AppendChild(MakeEle(docSave, "Exam", "", ""));

            // 設定をパラメータにセットしてクローズ
            return rootSave.OuterXml;
        }

        // DataKey, FNW ---> FNSi
        private Dictionary<string, string> dicDataKey = new Dictionary<string, string>
        {
            { "PLAN_TIME", "plan_time" },
            { "COND_DW", "cond_dw" },
            { "COND_TG_WEI", "cond_tg_wei" },
            { "COND_TRE_NM", "cond_tre_nm" },
            { "COND_BLD_FL", "cond_bld_fl" },
            { "DIAL_FUNC", "function_class" },
            { "DIAL_AREA", "area" },
            { "DIAL_UFR", "ufr" },
            { "DIAL_KOA", "koa" },
            { "DIAL_MATE", "material" },
            { "DIAL_WETDRY", "wetdry" },
            { "COND_AC", "anticoagulant_name" },
            { "EQUIP_CIRCUIT", "equip_circuit" },
            { "COND_DL_FL", "cond_dl_fl" },
            { "COND_DL_AM", "cond_dl_am" },
            { "COND_DL_TEMP", "cond_dl_temp" },
            { "COND_RL_AM", "cond_rl_am" },
            { "COND_RL_SEL", "cond_rl_sel" },
            { "COND_RL_USE", "cond_rl_use" },
            { "COND_RL_TEMP", "cond_rl_temp" },
            { "COND_RL_SPD", "cond_rl_spd" },
            { "MEDI_TIMING", "medi_timing" },
            { "MEDI_PROC", "medi_proc" },
            { "NUM_UNIT", "num_unit" },
            { "COND_VA_DIR", "cond_va_dir" },
            { "COND_VA", "cond_va" },
            { "EQUIP_PNC_CLS", "equip_pnc_cls" },
            { "COND_AC_SHOT", "cond_ac_shot" },
            { "COND_AC_SPD", "cond_ac_spd" },
            { "COND_AC_DUR_TOTAL", "cond_ac_dur_total" },
            { "COND_IP_USE", "cond_ip_use" },
            { "COND_IP_START", "cond_ip_start" },
            { "COND_IP_SPD", "cond_ip_spd" },
            { "COND_IP_SHOT_ST", "cond_ip_shot_st" },
            { "COND_IP_SHOT", "cond_ip_shot" },
            { "COND_IP_OFF", "cond_ip_off" },
            { "COND_IP_OFF_TM", "cond_ip_off_tm" },
            { "COND_IP_OK", "cond_ip_ok" },
            { "COND_IP_OK_TM", "cond_ip_ok_tm" },
            { "IN_HOSPITAL_CD", "in_hospital_cd_1" },
            { "IN_HOSPITAL_CD2", "in_hospital_cd_2" }
        };

        // convert wDataKey from FNW to FNSi
        private string convertDataKey(string wDataKey)
        {
            // 未設定の場合
            if (String.IsNullOrEmpty(wDataKey)) return "";

            string sValue;
            if (dicDataKey.TryGetValue(wDataKey, out sValue))
            {
                return sValue;
            }
                
            return "";
        }

        /// <summary>
        /// 汎用情報の設定Itemタグに対応するエレメントを作成
        /// </summary>
        /// <param name="doc">登録のベースとなるXML</param>
        /// <param name="wDataType">データ種別</param>
        /// <param name="wDataKey">データキー</param>
        /// <param name="wFixString">固定文字列</param>
        /// <returns>作成したXmlElement</returns>
        private XmlElement MakeEle(XmlDocument doc, string wDataType, string wDataKey, string wFixString)
        {
            // Itemタグ作成
            XmlElement ele = doc.CreateElement(frmEditLabelClass.XML_ITEM);
            XmlAttribute att;

            // データ種別のアトリビュート登録
            att = doc.CreateAttribute(frmEditLabelClass.XML_ATT_TYPE);
            att.Value = wDataType;
            ele.Attributes.Append(att);

            // データキー情報のアトリビュート登録
            att = doc.CreateAttribute(frmEditLabelClass.XML_ATT_KEY);
            att.Value = wDataKey;
            ele.Attributes.Append(att);

            // 固定文字列のアトリビュート登録
            att = doc.CreateAttribute(frmEditLabelClass.XML_ATT_FIX);
            att.Value = wFixString;
            ele.Attributes.Append(att);

            // 作成したエレメントを返却
            return ele;
        }

        // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

    /// <summary>
    /// 旧帳票のパラメータシート内のデータを取得します。
    /// </summary>
    /// <returns></returns>
    public bool GetOldSheetParamDataList()
        {
            var wRet = false;

            object[,] wGetValues = null;

            // パラメータシートからデータを取得
            using (var wXlSheetParam = new ExcelRangeEx(this.XlSheetParam.Worksheet.UsedRange))
            {
                wGetValues = wXlSheetParam.Range.Value;

                // 正常にデータを取得できた場合
                if (wGetValues != null && wGetValues.GetLength(0) > 0)
                {
                    try
                    {
                        // 2行目以降を取り込む
                        for (int wLopCnt = 2; wLopCnt <= wGetValues.GetLength(0); wLopCnt++)
                        {
                            // データパスを取得
                            string wDataPath = wGetValues[wLopCnt, 1] as string;
                            // 管理対象ではない場合は抜ける
                            if ((string.IsNullOrEmpty(wDataPath)) ||
                                (!string.IsNullOrEmpty(wDataPath) && !wDataPath.StartsWith(RldConst.PATH_HEADER)))
                            {
                                continue;
                            }

                            // del #8335 FNW帳票取込みの動作に問題あり 夏 start
                            // if (wDataPath.StartsWith(RldConst.CALC_HEADER))
                            // {
                            //     continue;
                            // }
                            // del #8335 FNW帳票取込みの動作に問題あり 夏 end

                            // add 2023-03-21 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                            if (wDataPath.Equals(RldConst.CALC_HEADER))
                            {
                                // 内部パスを取得
                                string wDataPath_IN = wGetValues[wLopCnt, 28] as string;
                                if (string.IsNullOrEmpty(wDataPath_IN) == false)
                                {
                                    wDataPath = wDataPath_IN;
                                }
                            }
                            // add 2023-03-21 #8335 鵬 end


                            var wOldReportData = new DesignParamFromOldReportData()
                            {
                                DataPath = wDataPath,
                                DisplayFormat = wGetValues[wLopCnt, 16] as string ?? string.Empty,
                                CanRepeat = (bool)wGetValues[wLopCnt, 9],
                                RepeatAddress = wGetValues[wLopCnt, 12] as string ?? string.Empty,
                                Length = Convert.ToString(wGetValues[wLopCnt, 6]) == "0" ? string.Empty : Convert.ToString(wGetValues[wLopCnt, 6]),
                                CellAddress = wGetValues[wLopCnt, 5] as string ?? string.Empty,
                                // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                GroupName = wGetValues[wLopCnt, 13] as string ?? string.Empty,
                                IsNewPage = wGetValues[wLopCnt, 11] as string ?? string.Empty,
                                // mod #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                                // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                DataType = wGetValues[wLopCnt, 8] as string ?? string.Empty,
                                FilterData = wGetValues[wLopCnt, 24] as string ?? string.Empty,
                                LabelItem = wGetValues[wLopCnt, 34] as string ?? string.Empty,
                                // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
                                // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
                                FilterType = wGetValues[wLopCnt, 32] as string ?? string.Empty
                                // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
                            };

                            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                            // ConvertList
                            string wXmlText = wGetValues[wLopCnt, 22] as string ?? string.Empty;
                            if (!string.IsNullOrEmpty(wXmlText))
                            {
                                wXmlText = wXmlText.Replace("Conv Code=", "conv code=");
                                wXmlText = wXmlText.Replace("Item=", "item=");
                                wXmlText = wXmlText.Replace("Disp=", "disp=");
                                var wXmlDoc = new System.Xml.XmlDocument();
                                wXmlDoc.LoadXml(wXmlText);

                                if (DesignConvertList.TryParse(wXmlDoc.DocumentElement, out DesignConvertList wConvertList))
                                {
                                    wOldReportData.ConvertList.AddRange(wConvertList);
                                }
                            }
                            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end

                            // add 2023-03-31 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                            if ((bool)wGetValues[wLopCnt, 27])
                            {
                                // テンプレート内外[内]
                                wOldReportData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN;
                            }
                            else
                            {
                                if (RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
                                {
                                    // テンプレート内外[外]
                                    wOldReportData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT;
                                }
                                else
                                {
                                    // テンプレート内外[無]
                                    wOldReportData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
                                }
                            }
                            // add 2023-03-31 #8335 鵬 end

                            if ((bool)wGetValues[wLopCnt, 26])
                            {
                                // 縮小して全体を表示するかどうか - 縮小する
                                wOldReportData.IsShrink = RldConst.ParamData.VAL_ISSHRINK_DONE;
                            }
                            else
                            {
                                //edit #8457 NWの帳票を取り込んだ場合表示文字列長が表示されない。 dongzhaolong start
                                // 縮小して全体を表示するかどうか - 縮小しない
                                wOldReportData.IsShrink = RldConst.ParamData.VAL_ISSHRINK_NONE;
                                //edit #8457 NWの帳票を取り込んだ場合表示文字列長が表示されない。 dongzhaolong end
                            }

                            if ((bool)wGetValues[wLopCnt, 11])
                            {
                                // 改ページ有無値 - 有り
                                wOldReportData.IsNewPage = RldConst.ParamData.VAL_ISNEWPAGE_TRUE;
                            }
                            else
                            {
                                // 改ページ有無値 - 無し
                                wOldReportData.IsNewPage = RldConst.ParamData.VAL_ISNEWPAGE_FALSE;
                            }

                            // バインディングリストへ追加
                            RldLib.CurrentLayoutData.DataParamFromOldReportList.Add(wOldReportData);
                        }

                        // エラーがなければOK
                        wRet = true;
                    }
                    catch (Exception ex)
                    {
                        RldUtility.RecordException(
                            new System.ApplicationException("旧帳票のパラメータデータの展開中にエラーが発生しました。", ex),
                            true);
                    }
                }
            }
            return wRet;
        }

        /// <summary>
        /// 旧帳票のグループシート内のデータを取得します。
        /// </summary>
        /// <returns></returns>
        public bool GetOldSheetGroupDataList()
        {
            var wRet = false;

            object[,] wGetValues = null;

            try
            {
                // グループシートからデータを取得
                using (var wXlRange = new ExcelRangeEx(this.XlSheetGroup.Worksheet.UsedRange))
                {
                    wGetValues = wXlRange.GetValue2();
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("旧帳票のグループデータの取得中にエラーが発生しました。", ex),
                    true);
            }

            // 正常にデータを取得できた場合
            if (wGetValues != null && wGetValues.GetLength(0) > 0)
            {
                try
                {
                    // 2行目以降を取り込む
                    for (int wLopCnt = 2; wLopCnt <= wGetValues.GetLength(0); wLopCnt++)
                    {

                        // A列(カテゴリ)を取得
                        string wCategory = wGetValues[wLopCnt, 1] as string;
                        // 管理対象ではない場合は抜ける
                        if (string.IsNullOrEmpty(wCategory))
                        {
                            continue;
                        }

                        var wData = new DesignGroupFromOldReportData()
                        {
                            DataCategory = wGetValues[wLopCnt, 1] as string ?? string.Empty,
                            DataClass = wGetValues[wLopCnt, 2] as string ?? string.Empty,
                            GroupName = wGetValues[wLopCnt, 3] as string ?? string.Empty,
                            FilterData = wGetValues[wLopCnt, 5] as string ?? string.Empty,
                            // mod #12050 FNW帳票コンバートで維持されない設定がある 高 start
                            //FilterType = wGetValues[wLopCnt, 6] as string ?? string.Empty,
                            //RepeatCount = wGetValues[wLopCnt, 7] as string ?? string.Empty,
                            FilterType = wGetValues[wLopCnt, 7] as string ?? string.Empty,
                            // mod #12050 FNW帳票コンバートで維持されない設定がある 高 end
                        };

                        if ((bool)wGetValues[wLopCnt, 4])
                        {
                            // 改ページ有無値 - 有り
                            wData.IsNewPage = RldConst.GroupData.VAL_ISNEWPAGE_TRUE;
                        }
                        else
                        {
                            // 改ページ有無値 - 無し
                            wData.IsNewPage = RldConst.GroupData.VAL_ISNEWPAGE_FALSE;
                        }

                        if ((bool)wGetValues[wLopCnt, 8])
                        {
                            // テンプレート内外[内]
                            wData.IsInTemplete = RldConst.GroupData.VAL_IS_IN_TEMPLETE_IN;
                        }
                        else
                        {
                            // mod 2023-03-31 #8335 FNW帳票取込みの動作に問題あり 鵬 start
                            if (RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
                            {
                                // テンプレート内外[外]
                                wData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT;
                            }
                            else
                            {
                                // テンプレート内外[無]
                                wData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
                            }
                            // mod 2023-03-31 #8335 鵬 end
                        }

                        // add #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2022-02-08 start
                        //wData.GroupPath = LayoutDataSet.MakeGroupPath(wData.DataCategory, wData.DataClass, wData.GroupName, wData.IsInTemplete);
                        wData.GroupPath = LayoutDataSet.MakeGroupPath(wData.DataCategory, wData.DataClass, wData.GroupName, wData.IsInTemplete, "");
                        wData.FilterData = wData.FilterData.Replace("TAG", "tag").Replace("CHECK_STATE", "checkState").Replace("ITEM", "Item");
                        // add #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭 2022-02-08  end


                        // バインディングリストへ追加
                        RldLib.CurrentLayoutData.DataGroupFromOldReportList.Add(wData);
                    }

                    // エラーがなければOK
                    wRet = true;
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("旧帳票のグループデータの展開中にエラーが発生しました。", ex),
                        true);
                }
            }

            return wRet;
        }

        /// <summary>
        /// パラメータシートへデータをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aParamList"></param>
        /// <returns></returns>
        public bool SetNewSheetParamDataList(System.ComponentModel.BindingList<DesignParamData> aParamList)
        {
            bool wRet = false;
            object[,] wSetValues = null;

            // セットするデータを作成する
            try
            {
                // 保存対象列をセット
                var wColumnList = DesignParamData.GetReadWriteDataList();

                // 行数/列数を取得
                int wRowCnt = aParamList.Count;
                int wColCnt = wColumnList.Count;

                // 配列生成
                wSetValues = new object[wRowCnt + 1, wColCnt];

                int wLopCnt = 0, wColIndex = -1;

                // 1行目に列名をセット
                wColumnList.ForEach(ele => wSetValues[wLopCnt, ++wColIndex] = DesignParamData.GetProperty(ele).Name);

                // 2行目以降にデータをセット
                foreach (var wData in aParamList)
                {

                    wLopCnt++; wColIndex = -1;

                    wSetValues[wLopCnt, ++wColIndex] = wData.DataPath;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataCategory;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataClass;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataName;
                    wSetValues[wLopCnt, ++wColIndex] = wData.SqlCode;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataCode;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataType;
                    wSetValues[wLopCnt, ++wColIndex] = wData.PreviewData;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DisplayFormat;
                    wSetValues[wLopCnt, ++wColIndex] = wData.ConvertList.ToXmlElementText();
                    wSetValues[wLopCnt, ++wColIndex] = Convert.ToString(wData.CanRepeat);
                    wSetValues[wLopCnt, ++wColIndex] = wData.RepeatAddress;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsShrink;
                    wSetValues[wLopCnt, ++wColIndex] = wData.Length;
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterData;
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterType;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsNewPage;
                    wSetValues[wLopCnt, ++wColIndex] = wData.LabelItem;
                    wSetValues[wLopCnt, ++wColIndex] = wData.CellAddress;
                    wSetValues[wLopCnt, ++wColIndex] = wData.GroupName;
                    // add #11535 帳票の汎用バーコード出力対応 高 start
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterState;
                    // add #11535 帳票の汎用バーコード出力対応 高 end
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsInTemplete;
                    wSetValues[wLopCnt, ++wColIndex] = wData.ParticularInfo;
                    wSetValues[wLopCnt, ++wColIndex] = Convert.ToString(wData.IsCalcResult);

                    // 条件付き書式ルール設定をXML文字列に変更して格納する
                    // del #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 start
                    //wSetValues[wLopCnt, ++wColIndex] = wData.FormatCondition.ToXmlElementText();
                    // del #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 end
                    // add #11535 帳票の汎用バーコード出力対応 高 start
                    wSetValues[wLopCnt, ++wColIndex] = Convert.ToString(wData.CanBarCode);
                    wSetValues[wLopCnt, ++wColIndex] = wData.BarCode;
                    // add #11535 帳票の汎用バーコード出力対応 高 end

                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用パラメータデータの作成中にエラーが発生しました。", ex),
                    true);
            }

            // セットするデータが正常に作成できた場合は保存処理実行
            if (wSetValues != null)
            {
                try
                {
                    // 値をセットするセル範囲を決定
                    string wRangeAddr = string.Format(
                        "A1:{0}",
                        this.XlApp.ConvertR1C1ToA1(wSetValues.GetLength(0), wSetValues.GetLength(1)));

                    // パラメータシートの保護を解除
                    this.XlSheetParam.IsProtected = false;

                    // シートをクリア
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetParam.Worksheet.Cells))
                    {
                        wXlRange.Range.Clear();
                        wXlRange.Range.NumberFormat = "@";
                    }

                    // セルに代入
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetParam, wRangeAddr))
                    {
                        wXlRange.Range.Value = wSetValues;
                    }

                    // エラーがなければOK
                    wRet = true;
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("パラメータデータの保存中にエラーが発生しました。", ex),
                        true);
                }
                finally
                {
                    // パラメータシートを保護
                    this.XlSheetParam.IsProtected = true;
                }
            }

            return wRet;
        }

        /// <summary>
        /// グループシートにデータをセットします。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aGroupList"></param>
        /// <returns></returns>
        public bool SetNewSheetGroupDataList(System.ComponentModel.BindingList<DesignGroupData> aGroupList)
        {
            bool wRet = false;
            object[,] wSetValues = null;

            // セットするデータを作成する
            try
            {
                // 保存対象列をセット
                var wColumnList = DesignGroupData.GetReadWriteDataList();

                // 行数/列数を取得
                int wRowCnt = aGroupList.Count, wColCnt = wColumnList.Count;

                // 配列生成
                wSetValues = new object[wRowCnt + 1, wColCnt];

                int wLopCnt = 0, wColIndex = -1;

                // 1行目に列名をセット
                wColumnList.ForEach(ele => wSetValues[wLopCnt, ++wColIndex] = DesignGroupData.GetProperty(ele).Name);

                // 2行目以降にデータをセット
                foreach (var wData in aGroupList)
                {

                    wLopCnt++; wColIndex = -1;

                    wSetValues[wLopCnt, ++wColIndex] = wData.GroupPath;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataCategory;
                    wSetValues[wLopCnt, ++wColIndex] = wData.DataClass;
                    wSetValues[wLopCnt, ++wColIndex] = wData.GroupName;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsNewPage;
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterData;
                    wSetValues[wLopCnt, ++wColIndex] = wData.FilterType;
                    wSetValues[wLopCnt, ++wColIndex] = wData.RepeatCount;
                    wSetValues[wLopCnt, ++wColIndex] = wData.IsInTemplete;
                }
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("保存用グループデータの作成中にエラーが発生しました。", ex),
                    true);
            }

            // セットするデータが正常に作成できた場合は保存処理実行
            if (wSetValues != null)
            {
                try
                {
                    // 値をセットするセル範囲を決定
                    string wRangeAddr = string.Format(
                        "A1:{0}",
                        this.XlApp.ConvertR1C1ToA1(wSetValues.GetLength(0), wSetValues.GetLength(1)));

                    // グループシートの保護を解除
                    this.XlSheetGroup.IsProtected = false;

                    // シートをクリア
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetGroup.Worksheet.Cells))
                    {
                        wXlRange.Range.Clear();
                        wXlRange.Range.NumberFormat = "@";
                    }

                    // セルに代入
                    using (var wXlRange = new ExcelRangeEx(this.XlSheetGroup, wRangeAddr))
                    {
                        wXlRange.Range.Value = wSetValues;
                    }

                    // エラーがなければOK
                    wRet = true;
                }
                catch (Exception ex)
                {
                    RldUtility.RecordException(
                        new System.ApplicationException("グループデータの保存中にエラーが発生しました。", ex),
                        true);
                }
                finally
                {
                    // グループシートを保護
                    this.XlSheetGroup.IsProtected = true;
                }
            }

            return wRet;
        }
        // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end

        /// <summary>
        /// レイアウトシートを html ファイル出力用に設定します。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aDataSet"></param>
        /// <returns></returns>
        public bool SetSheetLayoutForOutputHtml(LayoutDataSet aDataSet)
        {
            bool wRet = false;

            try
            {
                // Excel アプリケーションのイベントを抑制
                this.XlApp.Application.EnableEvents = false;
                // 警告メッセージを抑制
                this.XlApp.Application.DisplayAlerts = false;

                // レイアウトシートの保護を解除
                this.XlSheetLayout.IsProtected = false;

                // パラメータリストに登録されているセルの値にアドレスをセット
                // del #11447 繰り返し要素の多い帳票で保存時に莫大な時間がかかる 高 start
                //foreach (var wData in aDataSet.DesignParamList)
                //{

                //    using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wData.CellAddress))
                //    {

                //        // テンプレート繰返し範囲内の場合はテンプレート繰返し範囲アドレスを付加
                //        string wTempleteID = string.Empty;
                //        if (wData.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN)
                //        {
                //            wTempleteID = string.Format("{0}-1{1}", aDataSet.DesignTempleteData.Range, RldConst.PATH_SPLIT);
                //        }

                //        // セットする値を決定
                //        string wSetValue = string.Format("{0}{1}{2}", RldConst.PATH_HEADER, wTempleteID, wData.CellAddress);

                //        // 単項目の場合はセルのアドレスをセット
                //        if (!wData.CanRepeat)
                //        {
                //            wXlRange.Range.Value2 = wSetValue;
                //        }

                //        // 繰返可能項目の場合はセルのアドレスに連番を付加してセット
                //        else
                //        {
                //            // 最初は "1" からスタート
                //            int wRepeatBranchNo = 1;

                //            wXlRange.Range.Value2 = string.Format("{0}-{1}", wSetValue, wRepeatBranchNo);

                //            foreach (string wAddress in DesignParamData.GetSplitAddress(wData.RepeatAddress))
                //            {
                //                // 同一セルの場合はスキップ
                //                if (wAddress == wData.CellAddress)
                //                {
                //                    continue;
                //                }

                //                using (var wXlRangeRepeat = new ExcelRangeEx(this.XlSheetLayout, wAddress))
                //                {
                //                    wXlRangeRepeat.Range.Value2 = string.Format("{0}-{1}", wSetValue, ++wRepeatBranchNo);
                //                }
                //            }
                //        }
                //    }
                //}
                // del #11447 繰り返し要素の多い帳票で保存時に莫大な時間がかかる 高 end

                // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
                // レイアウトシート内の管理対象外のセルを取得し、縮小して全体を表示に設定されている場合はフォントサイズを調整する
                this.AdjustCellFontSize(this.XlSheetLayout, false);
                // add #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end

                // テンプレート繰返しがある場合
                // mod #7868 コンバータされた施設の透析レポートが表示できない 夏 start
                //if (aDataSet.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                if (aDataSet.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES
                    && aDataSet.DesignTempleteData.RepeatStartPosList.Count > 0)
                // mod #7868 コンバータされた施設の透析レポートが表示できない 夏 end
                {
                    // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                    //{
                    // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 end
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    // add #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 start
                    string[] address = aDataSet.DesignTempleteData.Range.Split(':');
                    string sAddress = string.Empty;
                    if (address.Length > 1)
                    {
                        sAddress = address[1];
                    }
                    else
                    {
                        sAddress = address[0];
                    }
                    int firstCol = frmDesignChildLayoutParam.ToIndex(new Regex(@"[a-zA-Z]+").Match(sAddress).Value)
                                + 1
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginV);
                    int firstRow = int.Parse(new Regex(@"[0-9]+\z").Match(sAddress).Value)
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginH);
                    Excel.Range firstRange = this.XlSheetLayout.Worksheet.Range[address[0],
                                frmDesignChildLayoutParam.ToName(firstCol - 1) + firstRow.ToString()];

                    Point ePos = aDataSet.DesignTempleteData.RepeatStartPosList[aDataSet.DesignTempleteData.RepeatStartPosList.Count - 1];
                    IEnumerable<Point> points = aDataSet.DesignTempleteData.RepeatStartPosList.Cast<Point>()
                                .Where(ele => !ele.X.Equals(ePos.X) && ele.Y.Equals(ePos.Y) || ele.X.Equals(ePos.X) && ele.Y.Equals(ePos.Y));
                    String sPos_s = string.Empty;
                    String sPos_e = string.Empty;
                    int i = 0;
                    foreach (var wDstPos in points)
                    {
                        // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                        //if (i == 0)
                        if (i == 0 && int.Parse(aDataSet.DesignTempleteData.RepeatCountV) > 1)
                        // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 end
                        {
                            sPos_s = new Regex(@"[a-zA-Z]+").Match(address[0]).Value +
                                (int.Parse(new Regex(@"[0-9]+\z").Match(address[0]).Value)
                                + RldLib.CurrentLayoutData.DesignTempleteData.RowCount
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginH)).ToString();
                            sPos_e = frmDesignChildLayoutParam.ToName(wDstPos.X - 1
                                + aDataSet.DesignTempleteData.ColumnCount - 1
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginV))
                                + (wDstPos.Y + aDataSet.DesignTempleteData.RowCount - 1
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginH));
                        }
                        else
                        {
                            sPos_s = frmDesignChildLayoutParam.ToName(wDstPos.X - 1) + new Regex(@"[0-9]+\z").Match(address[0]).Value;
                            sPos_e = frmDesignChildLayoutParam.ToName(ePos.X
                                + RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount - 1
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginH) - 1)
                                + (ePos.Y
                                + RldLib.CurrentLayoutData.DesignTempleteData.RowCount - 1
                                + int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginH)).ToString();
                        }
                        i++;

                        if (i < 3)
                        {
                            using (var wDstRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Range[sPos_s, sPos_e]))
                            {
                                wDstRange.Range.UnMerge();
                                firstRange.Copy(wDstRange.Range);
                            }
                        }
                        else
                        {
                            break;
                        }
                    }
                    // add #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 end
                    // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //}
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 end
                    // del #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
                    //using (var wSrcRange = new ExcelRangeEx(this.XlSheetLayout, aDataSet.DesignTempleteData.Range))
                    //{

                    //    int wBranchNo = 2;

                    //    // add #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 start
                    //    List<String> strList = new List<string>();
                    //    foreach (var str in wSrcRange.GetValue2())
                    //    {
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 start
                    //        if ('#'.Equals(str))
                    //        {
                    //            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //            if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                    //            {
                    //                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    //                // add #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 start
                    //                strList.Add(wSrcRange.GetValue2());
                    //                // add #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 end
                    //                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //            }
                    //            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    //            break;
                    //        }
                    //        else
                    //        {
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 end
                    //            if (!string.IsNullOrEmpty(str) && str.StartsWith(RldConst.PATH_HEADER))
                    //            {
                    //                strList.Add(str);
                    //            }
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 start
                    //        }
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 end
                    //    }
                    //    // add #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 end
                    //    // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                    //    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //    //if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                    //    //{
                    //        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    //        // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                    //    foreach (var wDstPos in aDataSet.DesignTempleteData.RepeatStartPosList)
                    //    {
                    //        // del #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 start
                    //        //// add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
                    //        //CellsUnMerge(aDataSet.DesignTempleteData, this.XlSheetLayout, wDstPos);
                    //        //// add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end
                    //        //using (var wDstRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Cells[wDstPos.Y, wDstPos.X]))
                    //        //{
                    //        //    wSrcRange.Range.Copy(wDstRange.Range);
                    //        //}
                    //        // del #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 end
                    //        // mod 2021-05-09 バグ対応 趙 start
                    //        //for (int wRowNo = wDstPos.Y; wRowNo <= wDstPos.Y + aDataSet.DesignTempleteData.RowCount; wRowNo++)
                    //        //{
                    //        //    for (int wColNo = wDstPos.X; wColNo <= wDstPos.X + aDataSet.DesignTempleteData.ColumnCount; wColNo++)
                    //        // mod #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 start
                    //        //for (int wRowNo = wDstPos.Y; wRowNo < wDstPos.Y + aDataSet.DesignTempleteData.RowCount; wRowNo++)
                    //        //{
                    //        //    for (int wColNo = wDstPos.X; wColNo < wDstPos.X + aDataSet.DesignTempleteData.ColumnCount; wColNo++)
                    //        //    {
                    //        //        // mod 2021-05-09 バグ対応 趙 end

                    //        //        using (var wXlBufRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Cells[wRowNo, wColNo]))
                    //        //        {

                    //        //            string wValue = wXlBufRange.GetValue2();
                    //        //            if (!string.IsNullOrEmpty(wValue) && wValue.StartsWith(RldConst.PATH_HEADER))
                    //        //            {

                    //        //                // テンプレート繰返しの連番を変更
                    //        //                // ex. ##B2:M12-1.B8 -> ##B2:M12-2.B8, ##B2:M12-1.B12-1 -> ##B2:M12-2.B12-1
                    //        //                wValue = string.Format(
                    //        //                    "{0}{1}{2}",
                    //        //                    wValue.Substring(0, wValue.IndexOf("-") + 1),
                    //        //                    wBranchNo,
                    //        //                    wValue.Substring(wValue.IndexOf(RldConst.PATH_SPLIT)));

                    //        //                wXlBufRange.Range.Value = wValue;
                    //        //            }
                    //        //        }
                    //        //    }
                    //        //}                           
                    //        // mod #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 start
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 start
                    //        //if (strList.Count == 0)
                    //        //{
                    //        //    using (var wXlBufRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Cells[wDstPos.Y, wDstPos.X]))
                    //        //    {

                    //        //        string wValue = wXlBufRange.GetValue2();
                    //        //        if (!string.IsNullOrEmpty(wValue) && wValue.StartsWith(RldConst.PATH_HEADER))
                    //        //        {

                    //        //            // テンプレート繰返しの連番を変更
                    //        //            // ex. ##B2:M12-1.B8 -> ##B2:M12-2.B8, ##B2:M12-1.B12-1 -> ##B2:M12-2.B12-1
                    //        //            wValue = string.Format(
                    //        //                "{0}{1}{2}",
                    //        //                wValue.Substring(0, wValue.IndexOf("-") + 1),
                    //        //                wBranchNo,
                    //        //                wValue.Substring(wValue.IndexOf(RldConst.PATH_SPLIT)));

                    //        //            wXlBufRange.Range.Value = wValue;
                    //        //        }
                    //        //    }
                    //        //}
                    //        //else
                    //        //{
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 end
                    //        String str_s = frmDesignChildLayoutParam.ToName(wDstPos.X - 1) + wDstPos.Y;
                    //        String str_e = frmDesignChildLayoutParam.ToName(wDstPos.X - 1 + aDataSet.DesignTempleteData.ColumnCount - 1) + (wDstPos.Y + aDataSet.DesignTempleteData.RowCount - 1);

                    //        foreach (var wValue in strList)
                    //        {
                    //            //using (var wXlBufRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Range[str_s, str_e].Find(What: wValue,
                    //            //    LookIn: Excel.XlFindLookIn.xlValues,
                    //            //    LookAt: Excel.XlLookAt.xlWhole,
                    //            //    SearchOrder: Excel.XlSearchOrder.xlByRows,
                    //            //    SearchDirection: Excel.XlSearchDirection.xlNext,
                    //            //    MatchCase: false)))
                    //            //{

                    //            //    // テンプレート繰返しの連番を変更
                    //            //    // ex. ##B2:M12-1.B8 -> ##B2:M12-2.B8, ##B2:M12-1.B12-1 -> ##B2:M12-2.B12-1
                    //            //    wXlBufRange.Range.Value = string.Format(
                    //            //            "{0}{1}{2}",
                    //            //            wValue.Substring(0, wValue.IndexOf("-") + 1),
                    //            //            wBranchNo,
                    //            //            wValue.Substring(wValue.IndexOf(RldConst.PATH_SPLIT)));
                    //            //}
                    //            Excel.Range tmpRange = this.XlSheetLayout.Worksheet.Range[str_s, str_e].Find(What: wValue,
                    //            LookIn: Excel.XlFindLookIn.xlValues,
                    //            LookAt: Excel.XlLookAt.xlWhole,
                    //            SearchOrder: Excel.XlSearchOrder.xlByRows,
                    //            SearchDirection: Excel.XlSearchDirection.xlNext,
                    //            MatchCase: false);
                    //            if (tmpRange == null || str_s.Equals(str_e))
                    //            {
                    //                tmpRange = this.XlSheetLayout.Worksheet.Cells[wDstPos.Y, wDstPos.X];
                    //            }
                    //            // テンプレート繰返しの連番を変更
                    //            // ex. ##B2:M12-1.B8 -> ##B2:M12-2.B8, ##B2:M12-1.B12-1 -> ##B2:M12-2.B12-1
                    //            tmpRange.Value = string.Format(
                    //            "{0}{1}{2}",
                    //            wValue.Substring(0, wValue.IndexOf("-") + 1),
                    //            wBranchNo,
                    //            wValue.Substring(wValue.IndexOf(RldConst.PATH_SPLIT)));
                    //        }
                    //        // mod #7880 帳票：ラベル）正しく表示されないの保存時間の対応 夏 end
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 start
                    //        //}
                    //        // add #7868 コンバータされた施設の透析レポートが表示できない 夏 end
                    //        // mod #7880 帳票：ラベル）正しく表示されないの保存時間の２回対応 夏 end
                    //        wBranchNo++;
                    //    }
                    //    // del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 start
                    //    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //    //}
                    //    //else
                    //    //{
                    //    //    foreach (var wDstPos in aDataSet.DesignTempleteData.RepeatStartPosList)
                    //    //    {
                    //    //        CellsUnMerge(aDataSet.DesignTempleteData, this.XlSheetLayout, wDstPos);
                    //    //        using (var wDstRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Cells[wDstPos.Y, wDstPos.X]))
                    //    //        {
                    //    //            wSrcRange.Range.Copy(wDstRange.Range);
                    //    //        }

                    //    //        if (strList.Count == 0)
                    //    //        {
                    //    //            using (var wXlBufRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Cells[wDstPos.Y, wDstPos.X]))
                    //    //            {

                    //    //                string wValue = wXlBufRange.GetValue2();
                    //    //                if (!string.IsNullOrEmpty(wValue) && wValue.StartsWith(RldConst.PATH_HEADER))
                    //    //                {

                    //    //                    // テンプレート繰返しの連番を変更
                    //    //                    // ex. ##B2:M12-1.B8 -> ##B2:M12-2.B8, ##B2:M12-1.B12-1 -> ##B2:M12-2.B12-1
                    //    //                    wValue = string.Format(
                    //    //                        "{0}{1}{2}",
                    //    //                        wValue.Substring(0, wValue.IndexOf("-") + 1),
                    //    //                        wBranchNo,
                    //    //                        wValue.Substring(wValue.IndexOf(RldConst.PATH_SPLIT)));

                    //    //                    wXlBufRange.Range.Value = wValue;
                    //    //                }
                    //    //            }
                    //    //        }
                    //    //        else
                    //    //        {
                    //    //            String str_s = frmDesignChildLayoutParam.ToName(wDstPos.X - 1) + wDstPos.Y;
                    //    //            String str_e = frmDesignChildLayoutParam.ToName(wDstPos.X - 1 + aDataSet.DesignTempleteData.ColumnCount - 1) + (wDstPos.Y + aDataSet.DesignTempleteData.RowCount - 1);

                    //    //            foreach (var wValue in strList)
                    //    //            {
                    //    //                using (var wXlBufRange = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Range[str_s, str_e].Find(What: wValue,
                    //    //                    LookIn: Excel.XlFindLookIn.xlValues,
                    //    //                    LookAt: Excel.XlLookAt.xlWhole,
                    //    //                    SearchOrder: Excel.XlSearchOrder.xlByRows,
                    //    //                    SearchDirection: Excel.XlSearchDirection.xlNext,
                    //    //                    MatchCase: false)))
                    //    //                {

                    //    //                    // テンプレート繰返しの連番を変更
                    //    //                    // ex. ##B2:M12-1.B8 -> ##B2:M12-2.B8, ##B2:M12-1.B12-1 -> ##B2:M12-2.B12-1
                    //    //                    wXlBufRange.Range.Value = string.Format(
                    //    //                            "{0}{1}{2}",
                    //    //                            wValue.Substring(0, wValue.IndexOf("-") + 1),
                    //    //                            wBranchNo,
                    //    //                            wValue.Substring(wValue.IndexOf(RldConst.PATH_SPLIT)));
                    //    //                }
                    //    //            }
                    //    //        }

                    //    //        wBranchNo++;
                    //    //    }
                    //    //}
                    //// add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    //// del #7943 帳票レイアウトデザイナーが正しく動作しないの㉙ 夏 end 
                    //}
                    // del #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end
                }

                // del #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 start
                //// レイアウトシート内の管理対象外のセルを取得し、縮小して全体を表示に設定されている場合はフォントサイズを調整する
                //this.AdjustCellFontSize(this.XlSheetLayout, false);
                // del #7880 帳票：ラベル）正しく表示されないの保存時間の３回対応 夏 end

                wRet = true;
            }
            catch (Exception ex)
            {
                //add  #7844  帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 start
                if ("この操作は結合したセルには行えません。".Equals(ex.Message))
                {
                    MessageBox.Show("レイアウトデータの保存中にエラーが発生しました。" + Environment.NewLine + "集計範囲内に結合セルの数が統一していない", "致命的なエラーが発生しました");
                    RldUtility.RecordException(
                  new System.ApplicationException("レイアウトデータの保存中にエラーが発生しました。", ex),
                  false);
                }
                else
                {
                    //add  #7844　帳票（複数集計）：結合したセルに集計項目を設定すると、アップロードできない 2022-08-09 孟堅 end
                    RldUtility.RecordException(
                       new System.ApplicationException("レイアウトデータの保存中にエラーが発生しました。", ex),
                       true);
                }
            }
            finally
            {
                // レイアウトシートを保護
                this.XlSheetLayout.IsProtected = true;
                // 警告メッセージを抑制
                this.XlApp.Application.DisplayAlerts = true;
                // Excel アプリケーションのイベント抑制を解除
                this.XlApp.Application.EnableEvents = true;
            }

            return wRet;
        }

        /// <summary>
        /// レイアウトシート内のデータをクリアします。
        /// </summary>
        /// <returns></returns>
        public bool ClearSheetLayout()
        {
            bool wRet = false;

            try
            {
                Dictionary<string, dynamic> wCellAddrValueList = null;

                // 管理対象セルを取得
                using (var wXlCells = new ExcelRangeEx(this.XlSheetLayout.Worksheet.Cells))
                {
                    // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                    wCellAddrValueList = wXlCells.FindCellAddrValue(RldConst.PATH_HEADER, Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
                    // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
                }

                if (wCellAddrValueList.Count > 0)
                {
                    foreach (var wAddr in wCellAddrValueList.Keys)
                    {

                        string wValue = wCellAddrValueList[wAddr] as string ?? string.Empty;
                        if (!string.IsNullOrEmpty(wValue) && wValue.StartsWith(RldConst.PATH_HEADER))
                        {
                            using (var wXlRange = new ExcelRangeEx(this.XlSheetLayout, wAddr))
                            {
                                wXlRange.Range.Value2 = null;
                            }
                        }
                    }
                }

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("レイアウトシートのクリア中にエラーが発生しました。", ex),
                    true);
            }

            return wRet;
        }

        /// <summary>
        /// 現在のレイアウトシートの内容でプレビュー表示を行います。
        /// </summary>
        /// <param name="aDataSet"></param>
        /// <returns></returns>
        public bool PreviewLayout(LayoutDataSet aDataSet)
        {
            bool wRet = false;

            try
            {
                // Excel を非表示に設定
                this.XlApp.Application.Visible = false;

                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                this.XlBook.IsProtected = false;
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

                // プレビューシートを作成(失敗時は抜ける)
                if (!this.MakePreviewSheet(aDataSet))
                {
                    return false;
                }

                // Excel を表示
                this.XlApp.Application.Visible = true;

                // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                try
                {
                    // プレビュー表示(スレッドがブロックされる)
                    this.XlSheetPreview.Worksheet.PrintPreview();

                    // ここまでくればOK
                    wRet = true;
                }
                catch (System.Runtime.InteropServices.COMException)
                { }
                finally
                {
                    //// 再描画処理を抑制
                    //this.XlApp.Application.ScreenUpdating = false;

                    //// レイアウトシートを選択
                    //XlSheetLayout.Worksheet.Select();

                    //// プレビューシートを非表示にしておく
                    //this.XlSheetPreview.Worksheet.Visible = Excel.XlSheetVisibility.xlSheetVeryHidden;
                }
                // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("プレビュー表示中にエラーが発生しました。", ex),
                    true);
            }
            finally
            {
                // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                // 再描画処理を抑制
                this.XlApp.Application.ScreenUpdating = false;

                // レイアウトシートを選択
                XlSheetLayout.Worksheet.Select();

                // プレビューシートを非表示にしておく
                this.XlSheetPreview.Worksheet.Visible = Excel.XlSheetVisibility.xlSheetVeryHidden;
                // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

                // 再描画処理の抑制を解除
                if (!this.XlApp.Application.ScreenUpdating)
                {
                    this.XlApp.Application.ScreenUpdating = true;
                }
                // Excel が非表示状態の場合は表示する
                if (!this.XlApp.Application.Visible)
                {
                    this.XlApp.Application.Visible = true;
                }

                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                try { this.XlBook.IsProtected = true; }
                catch { }
                // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end
            }

            return wRet;
        }

        // add FNSI-計算されない。・印刷、・各種プレビューデータ 孫 start
        #region 計算機変数定義
        // 数字スタック
        static Stack<double> mData = new Stack<double>();

        // 記号スタック
        static Stack<char> sOperator = new Stack<char>();

        // inputStrからストリーム中の値を入力します。
        protected void ReadCalcData(String inputStr)
        {
            for (int i = 0; i < inputStr.Length; i++)
            {
                // 数値と小数点
                if (!IsOperator(inputStr[i]))
                {
                    string s = null;
                    while (i < inputStr.Length && !IsOperator(inputStr[i]))
                    {
                        s += inputStr[i];
                        i++;
                    }
                    i--;
                    //8559 EDIT  董 start
                    double mm = 0;
                    if (double.TryParse(s, out mm))
                    {
                        mData.Push(mm);
                    }
                    else
                    {
                        bool alreadyPush = false;
                        DesignParamDatasList designParamList = RldLib.CurrentLayoutData.DesignParamList;
                        foreach (var wData in designParamList)
                        {
                            if (wData.CellAddress == s)
                            {
                                if (double.TryParse(wData.PreviewData, out mm))
                                {
                                    mData.Push(mm);
                                    alreadyPush = true;
                                    break;
                                }
                            }
                        }

                        if (!alreadyPush)
                        {
                            mData.Push(mm);
                        }
                    }
                    //8559 EDIT  董 END
                }
                else if (IsOper(inputStr[i]))
                {
                    // + - * / 
                    if (sOperator.Count.Equals(0) || sOperator.Peek().Equals('('))
                    {
                        sOperator.Push(inputStr[i]);
                    }
                    else if (OperatorPrecedence(inputStr[i]) > OperatorPrecedence(sOperator.Peek()))
                    {
                        sOperator.Push(inputStr[i]);
                    }
                    else
                    {
                        //8586 EDIT  董 START
                        double n1 = 0, n2 = 1;
                        char s1;
                        switch (mData.Count)
                        {
                            case 2:
                                n2 = mData.Pop();
                                n1 = mData.Pop();
                                break;
                            case 1:
                                n2 = mData.Pop();
                                break;
                            default:
                                break;
                        }
                        //8586 EDIT  董 END
                        s1 = sOperator.Pop();
                        double sum = Operat(n1, n2, s1);
                        mData.Push(sum);
                        sOperator.Push(inputStr[i]);
                    }
                }
                else
                {
                    //（和）
                    if (inputStr[i].Equals('('))
                    {
                        sOperator.Push(inputStr[i]);
                    }
                    else if (inputStr[i].Equals(')'))
                    {
                        while (!sOperator.Peek().Equals('('))
                        {
                            double n1, n2;
                            char s1;
                            n2 = mData.Pop();
                            n1 = mData.Pop();
                            s1 = sOperator.Pop();
                            double sum = Operat(n1, n2, s1);
                            mData.Push(sum);
                        }
                        sOperator.Pop();
                    }
                }
            }
        }

        // 操作符か
        protected bool IsOperator(char c)
        {
            if (c.Equals('+') || c.Equals('-') || c.Equals('*') || c.Equals('/') || c.Equals('(') || c.Equals(')'))
                return true;
            return false;
        }

        // 演算子か
        protected bool IsOper(char c)
        {
            if (c.Equals('+') || c.Equals('-') || c.Equals('*') || c.Equals('/'))
                return true;
            return false;
        }

        // 操作符の優先度
        protected int OperatorPrecedence(char a)
        {
            int i = 0;
            switch (a)
            {
                case '+': i = 3; break;
                case '-': i = 3; break;
                case '*': i = 4; break;
                case '/': i = 4; break;
            }
            return i;
        }

        // 単一演算子の計算
        protected double Operat(double n1, double n2, char s1)
        {
            double sum = 0;
            // mod #7943 帳票レイアウトデザイナーが正しく動作しないの⑪対応 夏 start
            //switch (s1)
            //{
            //    case '+': sum = n1 + n2; break;
            //    case '-': sum = n1 - n2; break;
            //    case '*': sum = n1 * n2; break;
            //    case '/': sum = n1 / n2; break;
            //}
            decimal result = decimal.Zero;
            switch (s1)
            {
                case '+': result = Convert.ToDecimal(n1) + Convert.ToDecimal(n2); break;
                case '-': result = Convert.ToDecimal(n1) - Convert.ToDecimal(n2); break;
                case '*': result = Convert.ToDecimal(n1) * Convert.ToDecimal(n2); break;
                // mod #9890  【デグレ】FNW帳票の取込エラー donghao start
                //case '/': result = Convert.ToDecimal(n1) / Convert.ToDecimal(n2); break;
                case '/':
                    if (n2 == 0)
                    {
                        result = 0; break;
                    }
                    else
                    {
                        result = Convert.ToDecimal(n1) / Convert.ToDecimal(n2); break;
                    }
                    // mod #9890  【デグレ】FNW帳票の取込エラー donghao end
            }
            sum = Convert.ToDouble(decimal.Parse(result.ToString("#0.0000")));
            // mod #7943 帳票レイアウトデザイナーが正しく動作しないの⑪対応 夏 end
            return sum;
        }

        // データを計算する。
        protected double PopStack()
        {
            double sum = 0;
            while (sOperator.Count != 0)
            {
                //8586 EDIT  董 START
                double n1 = 0, n2 = 1;
                char s1;
                switch (mData.Count)
                {
                    case 2:
                        n2 = mData.Pop();
                        n1 = mData.Pop();
                        break;
                    case 1:
                        n2 = mData.Pop();
                        break;
                    default:
                        break;
                }
                //8586 EDIT  董 END
                s1 = sOperator.Pop();
                sum = Operat(n1, n2, s1);
                mData.Push(sum);
            }
            mData.Clear();
            sOperator.Clear();
            return sum;
        }

        /// <summary>
        /// プレビューデータを再計算する。
        /// </summary>
        /// <param name="dataPath">データパス</param>
        /// <param name="designParamList">パラメータ編集データ</param>
        /// <param name="dataItemList">データ項目一覧</param>
        public String ReSetCalcResult(String dataPath, DesignParamDatasList designParamList, BindingList<DesignItemListData> dataItemList)
        {
            // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
            //String newPath = String.Empty;

            //String tmpDataPath = dataPath;
            //if (dataPath.StartsWith("##="))
            //{
            //    tmpDataPath = tmpDataPath.Substring(3);
            //}

            //if (tmpDataPath.StartsWith("["))
            //{
            //    tmpDataPath = tmpDataPath.Substring(1);
            //}

            //if (tmpDataPath.EndsWith("]"))
            //{
            //    tmpDataPath = tmpDataPath.Substring(0, tmpDataPath.Length - 1);
            //}

            //String[] dataPathList = tmpDataPath.Split(']', '[');

            //for (int i = 0; i < dataPathList.Length; i++)
            //{
            //    bool designParamExists = false;

            //    foreach (var itemtData in designParamList)
            //    {
            //        if (dataPathList[i].Equals(itemtData.DataPath))
            //        {
            //            dataPathList[i] = itemtData.PreviewData;
            //            designParamExists = true;
            //            break;
            //        }
            //    }

            //    if (!designParamExists)
            //    {
            //        foreach (var itemtData in dataItemList)
            //        {
            //            if (dataPathList[i].Equals(itemtData.DataPath))
            //            {
            //                dataPathList[i] = itemtData.PreviewData;
            //                break;
            //            }
            //        }
            //    }

            //    newPath = newPath + dataPathList[i];

            //    // データがnull場合、再計算の結果にnullを設定する
            //    if (String.IsNullOrEmpty(dataPathList[i]))
            //    {
            //        //add #8559 動作に関する指摘２ 邾 start
            //        if (dataPath.StartsWith("##="))
            //        {
            //            return "0";
            //        }
            //        //add #8559 動作に関する指摘２ 邾 end
            //        return String.Empty; ;
            //    }
            //}
            //// add #8335 FNW帳票取込みの動作に問題あり 夏 start
            //Boolean CalcFlg = false;
            //for (int i = 0; i < newPath.Length; i++)
            //{
            //    // 数値と小数点
            //    if (IsOperator(newPath[i]))
            //    {
            //        CalcFlg = true;
            //        break;
            //    }
            //}
            //if (!CalcFlg)
            //{
            //    //add #8559 動作に関する指摘２ 邾 start
            //    if (dataPath.StartsWith("##="))
            //    {
            //        return "0";
            //    }
            //    //add #8559 動作に関する指摘２ 邾 end
            //    return "";
            //}
            //// add #8335 FNW帳票取込みの動作に問題あり 夏 end
            ////add 6720 EXCEL関数で使用できないものがある 吉 start
            //if (null != newPath && newPath.Contains("("))
            //{
            //    string functionName = newPath.Split('(')[0];
            //    if (FUNCTION_NAMES.Contains(functionName))
            //    {
            //        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
            //        // return FUN_MESSAGE;
            //        return "0";
            //        // add #8335 FNW帳票取込みの動作に問題あり 夏 end
            //    }
            //    else
            //    {
            //        ReadCalcData(newPath);
            //    }
            //}
            //else
            //{
            //    //add 6720 EXCEL関数で使用できないものがある 吉 end	

            //    ReadCalcData(newPath);
            //    //add 6720 EXCEL関数で使用できないものがある 吉 start    
            //}
            ////add 6720 EXCEL関数で使用できないものがある 吉 end
            //return PopStack().ToString();
            // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

            // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
            // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 strat
            bool bExeclNull = false;
            object wRes = null;

            try
            {
                wRes = RldLib.XlHelper.XlApp.Application.Evaluate(RldLib.GetSamplingFormula(dataPath, designParamList, dataItemList));
                // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 end
                do
                {
                    // exception
                    if (wRes == null)
                    {
                        bExeclNull = true;
                        break;
                    }
                    if (wRes is System.Reflection.Missing)
                    {
                        bExeclNull = true;
                        break;
                    }
                    if (wRes is Microsoft.Office.Interop.Excel.XlCVError)
                    {
                        bExeclNull = true;
                        break;
                    }

                    // check array
                    if (wRes.GetType().IsArray)
                    {
                        try
                        {
                            Array arr = (Array)wRes;
                            if (arr.Length == 0)
                            {
                                bExeclNull = true;
                                break;
                            }
                        }
                        catch
                        {
                            bExeclNull = true;
                            break;
                        }
                    }
                    bExeclNull = false;
                } while (false);
            }
            catch
            {
                // is null
                bExeclNull = true;
            }

            if (bExeclNull == true)
            {
                return "0";
            }

            return wRes?.ToString() ?? "0";
            // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
        }
        #endregion
        // add FNSI-計算されない。・印刷、・各種プレビューデータ 孫 end

        /// <summary>
        /// 現在のレイアウトシートの内容でプレビューシートを作成します。
        /// </summary>
        /// <param name="aDataSet"></param>
        /// <returns></returns>
        public bool MakePreviewSheet(LayoutDataSet aDataSet)
        {
            bool wRet = false;
            // add #8457 表示文字列長の対応 xiaosonglei start
            Dictionary<int, double> stringCutDownList = new Dictionary<int, double>();
            // add #8457 表示文字列長の対応 xiaosonglei end

            try
            {
                // プレビューシートが存在する場合は削除
                if (this.XlSheetPreview != null)
                {
                    try
                    {
                        // 警告メッセージを抑制
                        this.XlApp.Application.DisplayAlerts = false;

                        // 表示されていない場合は表示する
                        if (this.XlSheetPreview.Worksheet.Visible != Excel.XlSheetVisibility.xlSheetVisible)
                        {
                            this.XlSheetPreview.Worksheet.Visible = Excel.XlSheetVisibility.xlSheetVisible;
                        }

                        // 削除
                        this.XlSheetPreview.Worksheet.Delete();
                        this.XlSheetPreview.Dispose();
                        this.XlSheetPreview = null;
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        // 警告メッセージの抑制を解除
                        this.XlApp.Application.DisplayAlerts = true;
                    }
                }

                // プレビューシートを作成
                using (var wXlSheets = new ExcelWorksheetsEx(this.XlBook))
                {
                    // シート数を取得
                    int wSheetCount = wXlSheets.Worksheets.Count;

                    // レイアウトシートをコピーしてシートの末尾に追加
                    this.XlSheetLayout.Worksheet.Copy(After: wXlSheets.Worksheets[wSheetCount]);

                    // プレビューシートを取得
                    this.XlSheetPreview = new ExcelWorksheetEx(wXlSheets, wSheetCount + 1);
                    this.XlSheetPreview.Worksheet.Name = SHEET_NAME_PREVIEW;
                }
                // add #12798 帳票プレビューの画像がセルのサイズに合っていない 高 start
                this.EnsureExcelMeasureContext();
                // add #12798 帳票プレビューの画像がセルのサイズに合っていない 高 end

                // add FNSI-計算されない。・印刷、・各種プレビューデータ 孫 start
                // 計算式の場合、レビューデータを再計算する
                // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                //DesignParamDatasList tmpDesignParamList = new DesignParamDatasList();
                // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                foreach (var wParamTemp in aDataSet.DesignParamList)
                {
                    // 計算式場合、データを再計算する
                    if (wParamTemp.IsCalcResult)
                    {
                        wParamTemp.PreviewData = ReSetCalcResult(wParamTemp.DataPath, aDataSet.DesignParamList, aDataSet.DataItemList);
                        //add 6720 EXCEL関数で使用できないものがある 吉 start
                        if (wParamTemp.PreviewData == FUN_MESSAGE)
                        {
                            wParamTemp.DataType = "string";
                            wParamTemp.Length = wParamTemp.PreviewData.Length + "";
                        }
                        //add 6720 EXCEL関数で使用できないものがある 吉 end
                    }
                    // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                    //tmpDesignParamList.Add(wParamTemp);
                    // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                }

                // 再計算したデータを設定する
                // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                //aDataSet.DesignParamList.Clear();
                //foreach (var wParamTemp in tmpDesignParamList)
                //{
                //    aDataSet.DesignParamList.Add(wParamTemp);
                //}
                // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                // add FNSI-計算されない。・印刷、・各種プレビューデータ 孫 end

                // プレビューシートのセルにプレビューデータをセット
                foreach (var wParam in aDataSet.DesignParamList)
                {

                    var wCellList = new List<string>();

                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                    if (string.IsNullOrEmpty(wParam.PreviewData))
                    {
                        RldMsgBox.Show("プレビュー表示用データは空白にできません。", "確認してください");
                        return false;
                    }
                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

                    if (wParam.CanRepeat)
                    {
                        wCellList.AddRange(DesignParamData.GetSplitAddress(wParam.RepeatAddress));
                    }
                    else
                    {
                        wCellList.Add(wParam.CellAddress);
                    }

                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                    if(wCellList.Count > 1)
                    {
                        this.XlApp.Application.ScreenUpdating = false;
                        this.XlApp.Application.EnableEvents = false;
                        this.XlApp.Application.Calculation = Microsoft.Office.Interop.Excel.XlCalculation.xlCalculationManual;

                        int ii = 1;

                        try
                        {
                            using (var wSrcRange = new ExcelRangeEx(this.XlSheetPreview, wCellList[0]))
                            {
                                var sourceRange = wSrcRange.Range;
                                var worksheet = sourceRange.Worksheet;

                                // copy source range
                                sourceRange.Copy();

                                for (; ii < wCellList.Count; ii++)
                                {
                                    var targetRange = worksheet.Range[wCellList[ii]];

                                    // Paste Formulas and Formats
                                    targetRange.PasteSpecial(
                                        Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAll,
                                        Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone,
                                        Type.Missing,
                                        Type.Missing);

                                    System.Runtime.InteropServices.Marshal.ReleaseComObject(targetRange);
                                }
                            }
                        }
                        catch(Exception ex)
                        {
                            string errMsg = string.Format("繰り返し設定に指定されたセルと、セルの結合状態に不一致があります。設定を確認してください（項目名:{0}, セル番地:{1}）",
                                                        wParam.DataPath, wCellList[ii]);
                            RldMsgBox.Show(errMsg, "プレビュー失敗");
                            return false;
                        }
                        finally
                        {
                            this.XlApp.Application.ScreenUpdating = true;
                            this.XlApp.Application.EnableEvents = true;
                            this.XlApp.Application.Calculation = Microsoft.Office.Interop.Excel.XlCalculation.xlCalculationAutomatic;
                        }
                    }
                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

                    int i = 0;

                    foreach (var wAddress in wCellList)
                    {

                        using (var wXlRange = new ExcelRangeEx(this.XlSheetPreview, wAddress))
                        {

                            switch (wParam.DataType)
                            {
                                case RldConst.ParamData.VAL_DATATYPE_DATETIME:
                                    // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                                    //DateTime wDateValue;
                                    //if (DateTime.TryParse(wParam.PreviewData, null, System.Globalization.DateTimeStyles.NoCurrentDateDefault, out wDateValue))
                                    //{
                                    //    wXlRange.Range.Value2 = wDateValue;
                                    //}
                                    //// edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                                    //else if (Regex.Replace(wParam.PreviewData, "[時間分秒:1234567890]", "").Length == 0)
                                    //{
                                    //    wXlRange.Range.Value2 = wParam.PreviewData;
                                    //}
                                    //// edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 end
                                    //else
                                    //{
                                    //    wXlRange.Range.Value2 = string.Empty;
                                    //}
                                    wXlRange.Range.Value2 = wParam.PreviewData;
                                    // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

                                    break;

                                case RldConst.ParamData.VAL_DATATYPE_DECIMAL:
                                    decimal wDecValue;
                                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                                    if (wParam.CanBarCode && string.IsNullOrEmpty(wParam.BarCode) == false)
                                    {
                                        wXlRange.Range.Value2 = string.Empty;   // セルの内容はクリアする
                                        string fileNameBarCode;

                                        if(wParam.BarCode == "二次元バーコード")
                                        {
                                            fileNameBarCode = FILE_NAME_BARCODE_2;
                                        }
                                        else
                                        {
                                            fileNameBarCode = FILE_NAME_BARCODE_1;
                                        }

                                        // 画像ファイルがある場合はセルの大きさに合わせて挿入する
                                        string wImageFilePath1 = string.Format(@"{0}{1}{2}", RldUtility.ImageDirPath, System.IO.Path.DirectorySeparatorChar, fileNameBarCode);
                                        if (System.IO.File.Exists(wImageFilePath1))
                                        {
                                            // mod #12709 帳票プレビューで画像が表示されない 高 start
                                            //using (var wXlShapes = new ExcelShapesEx(XlSheetPreview))
                                            //using (var wXlShape = new ExcelShapeEx(wXlShapes.Shapes.AddPicture(wImageFilePath1, Microsoft.Office.Core.MsoTriState.msoFalse, Microsoft.Office.Core.MsoTriState.msoTrue, wXlRange.Range.Left + 1.0f, wXlRange.Range.Top + 1.0f, 0, 0)))
                                            //{
                                            //    wXlShape.Shape.Width = (float)wXlRange.GetWidth() - 2.0f;
                                            //    wXlShape.Shape.Height = (float)wXlRange.GetHeight() - 2.0f;
                                            //}
                                            cellAddPic(wImageFilePath1, wXlRange);
                                            // mod #12709 帳票プレビューで画像が表示されない 高 end
                                        }
                                    }
                                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                                    // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 start
                                    //else if (decimal.TryParse(wParam.PreviewData, out wDecValue))
                                    //{
                                    //    wXlRange.Range.Value2 = wDecValue;
                                    //}
                                    else
                                    {
                                        //wXlRange.Range.Value2 = string.Empty;
                                        wXlRange.Range.Value2 = wParam.PreviewData;
                                    }
                                    // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 end

                                    break;

                                case RldConst.ParamData.VAL_DATATYPE_IMAGE:
                                    wXlRange.Range.Value2 = string.Empty;   // セルの内容はクリアする

                                    // 画像ファイルがある場合はセルの大きさに合わせて挿入する
                                    string wImageFilePath = string.Format(@"{0}{1}{2}", RldUtility.ImageDirPath, System.IO.Path.DirectorySeparatorChar, wParam.PreviewData);
                                    if (System.IO.File.Exists(wImageFilePath))
                                    {
                                        // mod #12709 帳票プレビューで画像が表示されない 高 start
                                        //using (var wXlShapes = new ExcelShapesEx(XlSheetPreview))
                                        //using (var wXlShape = new ExcelShapeEx(wXlShapes.Shapes.AddPicture(wImageFilePath, Microsoft.Office.Core.MsoTriState.msoFalse, Microsoft.Office.Core.MsoTriState.msoTrue, wXlRange.Range.Left + 1.0f, wXlRange.Range.Top + 1.0f, 0, 0)))
                                        //{
                                        //    wXlShape.Shape.Width = (float)wXlRange.GetWidth() - 2.0f;
                                        //    wXlShape.Shape.Height = (float)wXlRange.GetHeight() - 2.0f;
                                        //}
                                        // 元の画像サイズを取得
                                        
                                        cellAddPic(wImageFilePath, wXlRange);
                                        // mod #12709 帳票プレビューで画像が表示されない 高 end
                                    }
                                    break;

                                case RldConst.ParamData.VAL_DATATYPE_STRING:
                                    string wStrValue = wParam.PreviewData;
                                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                                    if (wParam.CanBarCode && string.IsNullOrEmpty(wParam.BarCode) == false)
                                    {
                                        wXlRange.Range.Value2 = string.Empty;   // セルの内容はクリアする
                                        string fileNameBarCode;

                                        if (wParam.BarCode == "二次元バーコード")
                                        {
                                            fileNameBarCode = FILE_NAME_BARCODE_2;
                                        }
                                        else
                                        {
                                            fileNameBarCode = FILE_NAME_BARCODE_1;
                                        }

                                        // 画像ファイルがある場合はセルの大きさに合わせて挿入する
                                        string wImageFilePath1 = string.Format(@"{0}{1}{2}", RldUtility.ImageDirPath, System.IO.Path.DirectorySeparatorChar, fileNameBarCode);
                                        if (System.IO.File.Exists(wImageFilePath1))
                                        {
                                            // mod #12709 帳票プレビューで画像が表示されない 高 start
                                            //using (var wXlShapes = new ExcelShapesEx(XlSheetPreview))
                                            //using (var wXlShape = new ExcelShapeEx(wXlShapes.Shapes.AddPicture(wImageFilePath1, Microsoft.Office.Core.MsoTriState.msoFalse, Microsoft.Office.Core.MsoTriState.msoTrue, wXlRange.Range.Left + 1.0f, wXlRange.Range.Top + 1.0f, 0, 0)))
                                            //{
                                            //    wXlShape.Shape.Width = (float)wXlRange.GetWidth() - 2.0f;
                                            //    wXlShape.Shape.Height = (float)wXlRange.GetHeight() - 2.0f;
                                            //}
                                            cellAddPic(wImageFilePath1, wXlRange);
                                            // mod #12709 帳票プレビューで画像が表示されない 高 end
                                        }
                                        break;
                                    }

                                    int canLength = wXlRange.GetStringLength();
                                    int parmLength = RldLib.ConvertStrToInt32(wParam.Length, false);

                                    if (wParam.IsShrink != RldConst.ParamData.VAL_ISSHRINK_DONE)
                                    {
                                        if (parmLength <= 0)
                                        {
                                            Encoding shiftJis = Encoding.GetEncoding("shift-jis");
                                            byte[] bytes = shiftJis.GetBytes(wStrValue);

                                            if (bytes.Length > canLength)
                                            {
                                                int validByteLength = 0;
                                                int charCount = 0;

                                                for (int ii = 0; ii < wStrValue.Length; ii++)
                                                {
                                                    char c = wStrValue[ii];
                                                    byte[] charBytes = shiftJis.GetBytes(c.ToString());

                                                    if (validByteLength + charBytes.Length <= canLength)
                                                    {
                                                        validByteLength += charBytes.Length;
                                                        charCount++;
                                                    }
                                                    else
                                                    {
                                                        break;
                                                    }
                                                }

                                                wStrValue = wStrValue.Substring(0, charCount);
                                            }
                                        }
                                        else
                                        {
                                            int truncateLength = Math.Min(parmLength, canLength);

                                            Encoding shiftJis = Encoding.GetEncoding("shift-jis");
                                            byte[] bytes = shiftJis.GetBytes(wStrValue);

                                            if (bytes.Length > truncateLength)
                                            {
                                                int validByteLength = 0;
                                                int charCount = 0;

                                                for (int ii = 0; ii < wStrValue.Length; ii++)
                                                {
                                                    char c = wStrValue[ii];
                                                    byte[] charBytes = shiftJis.GetBytes(c.ToString());

                                                    if (validByteLength + charBytes.Length <= truncateLength)
                                                    {
                                                        validByteLength += charBytes.Length;
                                                        charCount++;
                                                    }
                                                    else
                                                    {
                                                        break;
                                                    }
                                                }

                                                wStrValue = wStrValue.Substring(0, charCount);
                                            }
                                        }
                                    }
                                    // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                                    // mod #8457 表示文字列長の対応 xiaosonglei start
                                    //if (wParam.IsShrink != RldConst.ParamData.VAL_ISSHRINK_DONE && wParam.PreviewData.Length > RldLib.ConvertStrToInt32(wParam.Length, false))
                                    //{
                                    //    wStrValue = wParam.PreviewData.Substring(0, RldLib.ConvertStrToInt32(wParam.Length, false));
                                    //}
                                    // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                                    //int allByteLength = System.Text.Encoding.GetEncoding("gb2312").GetByteCount(wStrValue);
                                    //int cutLength = RldLib.ConvertStrToInt32(wParam.Length, false);
                                    //// 格納可能な文字数('0'を1文字として計算)を取得します
                                    //int canLength = wXlRange.GetStringLength();
                                    //int lenCount = 1;
                                    //if (wParam.IsShrink != RldConst.ParamData.VAL_ISSHRINK_DONE && allByteLength > cutLength)
                                    //{
                                    //    //wStrValue = wParam.PreviewData.Substring(0, RldLib.ConvertStrToInt32(wParam.Length, false));
                                    //    //wStrValue = wParam.PreviewData.Substring(0, RldLib.ConvertStrToInt32(wParam.Length, false)) + "\n" + wParam.PreviewData.Substring(RldLib.ConvertStrToInt32(wParam.Length, false));
                                    //    //lenCount++;
                                    //    //string tempVaule = wStrValue;
                                    //    string resultValue = string.Empty;
                                    //    string cutValue = string.Empty;
                                    //    List<string> resultValueList = new List<string>();

                                    //    for (int j = 0; j < wStrValue.Length; j++)
                                    //    {
                                    //        string currentStr = wStrValue.Substring(j, 1);
                                    //        int addByteLength = System.Text.Encoding.GetEncoding("gb2312").GetByteCount(resultValue + currentStr);
                                    //        int currentByteLength = System.Text.Encoding.GetEncoding("gb2312").GetByteCount(currentStr);

                                    //        if (currentByteLength <= cutLength)
                                    //        {
                                    //            if (cutLength > canLength)
                                    //            {
                                    //                if (addByteLength > cutLength)
                                    //                {
                                    //                    resultValueList.Add(cutValue);
                                    //                    resultValue = currentStr;
                                    //                    cutValue = currentStr;
                                    //                }
                                    //                else if (addByteLength == cutLength)
                                    //                {
                                    //                    resultValueList.Add(cutValue);
                                    //                    resultValue = string.Empty;
                                    //                    cutValue = string.Empty;
                                    //                }
                                    //                else
                                    //                {
                                    //                    resultValue += currentStr;
                                    //                    if (addByteLength <= canLength)
                                    //                    {
                                    //                        cutValue += currentStr;
                                    //                    }
                                    //                }
                                    //            }
                                    //            else
                                    //            {
                                    //                if (addByteLength > cutLength)
                                    //                {
                                    //                    resultValueList.Add(resultValue);
                                    //                    resultValue = currentStr;

                                    //                }
                                    //                else if (addByteLength == cutLength)
                                    //                {
                                    //                    resultValueList.Add(resultValue + currentStr);
                                    //                    resultValue = string.Empty;
                                    //                }
                                    //                else
                                    //                {
                                    //                    resultValue += currentStr;
                                    //                }
                                    //            }
                                    //        }
                                    //    }
                                    //    if (!string.IsNullOrEmpty(resultValue))
                                    //    {
                                    //        if (cutLength > canLength)
                                    //        {
                                    //            resultValueList.Add(cutValue);
                                    //        }
                                    //        else
                                    //        {
                                    //            resultValueList.Add(resultValue);
                                    //        }

                                    //    }

                                    //    wStrValue = string.Join("\n", resultValueList.ToArray());

                                    //    lenCount = resultValueList.Count;

                                    //    if (wParam.CellAddress.Contains(":") && lenCount > 1)
                                    //    {
                                    //        string addressRowNoStr = Regex.Replace(wParam.CellAddress, @"[^\d:]*", "");
                                    //        string[] addressRowNoArr = addressRowNoStr.Split(':');
                                    //        int addressRowNoStart = RldLib.ConvertStrToInt32(addressRowNoArr[0], false);
                                    //        int addressRowNoEnd = RldLib.ConvertStrToInt32(addressRowNoArr[1], false);
                                    //        int addressRowCount = addressRowNoEnd - addressRowNoStart + 1;
                                    //        if (addressRowCount <= 0)
                                    //        {
                                    //            addressRowCount = 1;
                                    //        }
                                    //        double oneRowHeight = wXlRange.Range.Height / addressRowCount;
                                    //        double changeRowHeight = oneRowHeight / addressRowCount * lenCount;
                                    //        for (int j = addressRowNoStart; j <= addressRowNoEnd; j++)
                                    //        {
                                    //            using (var changeHeightRowXlRange = new ExcelRangeEx(this.XlSheetPreview, "A" + j))
                                    //            {
                                    //                if (stringCutDownList.ContainsKey(j))
                                    //                {
                                    //                    if (stringCutDownList[j] <= changeRowHeight)
                                    //                    {
                                    //                        changeHeightRowXlRange.Range.RowHeight = changeRowHeight;
                                    //                        stringCutDownList[j] = changeRowHeight;
                                    //                    }
                                    //                }
                                    //                else
                                    //                {
                                    //                    changeHeightRowXlRange.Range.RowHeight = changeRowHeight;
                                    //                    stringCutDownList[j] = changeRowHeight;
                                    //                }
                                    //            }

                                    //        }
                                    //        //wXlRange.Range.RowHeight = changeRowHeight;
                                    //    }
                                    //}
                                    // mod #8457 表示文字列長の対応 xiaosonglei end
                                    // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

                                    // mod #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
                                    //wXlRange.Range.Value2 = wStrValue + (wParam.CellAddress == wAddress ? string.Empty : (++i).ToString("00"));
                                    wXlRange.Range.Value2 = "\'" + wStrValue + (wParam.CellAddress == wAddress ? string.Empty : (++i).ToString("00"));
                                    // mod #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end
                                    break;

                                default:
                                    break;
                            }
                        }
                    }
                }

                // テンプレート繰返し範囲をコピーする
                if (aDataSet.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                {
                    using (var wSrcRange = new ExcelRangeEx(this.XlSheetPreview, aDataSet.DesignTempleteData.Range))
                    {
                        // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                        //foreach (var wDstPos in aDataSet.DesignTempleteData.RepeatStartPosList)
                        //{
                        //    // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
                        //    CellsUnMerge(aDataSet.DesignTempleteData, this.XlSheetPreview, wDstPos);
                        //    // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end
                        //    using (var wDstRange = new ExcelRangeEx(this.XlSheetPreview.Worksheet.Cells[wDstPos.Y, wDstPos.X]))
                        //    {
                        //        wSrcRange.Range.Copy(wDstRange.Range);
                        //    }
                        //}
                        var app = this.XlApp.Application;
                        bool originalScreenUpdating = app.ScreenUpdating;
                        bool originalEnableEvents = app.EnableEvents;
                        var originalCalculation = app.Calculation;

                        try
                        {
                            // close execl event
                            app.ScreenUpdating = false;
                            app.EnableEvents = false;
                            app.Calculation = Microsoft.Office.Interop.Excel.XlCalculation.xlCalculationManual;

                            foreach (var wDstPos in aDataSet.DesignTempleteData.RepeatStartPosList)
                            {
                                CellsUnMerge(aDataSet.DesignTempleteData, this.XlSheetPreview, wDstPos);
                            }

                            var sourceRange = wSrcRange.Range;

                            // copy source range
                            sourceRange.Copy();

                            foreach (var wDstPos in aDataSet.DesignTempleteData.RepeatStartPosList)
                            {
                                var targetRange = this.XlSheetPreview.Worksheet.Cells[wDstPos.Y, wDstPos.X];
                                targetRange.PasteSpecial(
                                        Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAll,
                                        Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone,
                                        Type.Missing,
                                        Type.Missing);

                                System.Runtime.InteropServices.Marshal.ReleaseComObject(targetRange);
                            }
                        }
                        finally
                        {
                            // restore execl setting
                            app.ScreenUpdating = originalScreenUpdating;
                            app.EnableEvents = originalEnableEvents;
                            app.Calculation = originalCalculation;
                        }
                        // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                    }
                }

                // フォントサイズを調整
                this.AdjustCellFontSize(this.XlSheetPreview, true);

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(
                    new System.ApplicationException("プレビュー表示用データの作成中にエラーが発生しました。", ex),
                    true);
            }

            return wRet;
        }

        // add #12709 帳票プレビューで画像が表示されない 高 start
        // mod #12798 帳票プレビューの画像がセルのサイズに合っていない 高 start
        //private void cellAddPic(string wImageFilePath, ExcelRangeEx wXlRange)
        //{
        //    float cellLeft = (float)wXlRange.Range.Left;
        //    float cellTop = (float)wXlRange.Range.Top;
        //    float cellWidth = (float)wXlRange.GetWidth();
        //    float cellHeight = (float)wXlRange.GetHeight();
        //    int hAlign = GetHorizontalAlignment(wXlRange.Range);
        //    int vAlign = GetVerticalAlignment(wXlRange.Range);

        //    float margin = 1.0f;
        //    float availableWidth = cellWidth - margin * 2;
        //    float availableHeight = cellHeight - margin * 2;

        //    using (var wXlShapes = new ExcelShapesEx(XlSheetPreview))
        //    {
        //        // Insert at original size first; Excel converts image DPI to points correctly
        //        using (var wXlShape = new ExcelShapeEx(wXlShapes.Shapes.AddPicture(
        //                wImageFilePath,
        //                Microsoft.Office.Core.MsoTriState.msoFalse,
        //                Microsoft.Office.Core.MsoTriState.msoTrue,
        //                cellLeft + margin,
        //                cellTop + margin,
        //                0,
        //                0)))
        //        {
        //            float originalWidth = (float)wXlShape.Shape.Width;
        //            float originalHeight = (float)wXlShape.Shape.Height;

        //            if (originalWidth <= 0 || originalHeight <= 0)
        //                return;

        //            float widthRatio = availableWidth / originalWidth;
        //            float heightRatio = availableHeight / originalHeight;
        //            float scale = Math.Min(widthRatio, heightRatio);

        //            float finalWidth = originalWidth * scale;
        //            float finalHeight = originalHeight * scale;

        //            float offsetX = CalculateHorizontalOffset(availableWidth, finalWidth, hAlign);
        //            float offsetY = CalculateVerticalOffset(availableHeight, finalHeight, vAlign);

        //            wXlShape.Shape.LockAspectRatio = Microsoft.Office.Core.MsoTriState.msoFalse;
        //            wXlShape.Shape.Width = finalWidth;
        //            wXlShape.Shape.Height = finalHeight;
        //            wXlShape.Shape.Left = cellLeft + margin + offsetX;
        //            wXlShape.Shape.Top = cellTop + margin + offsetY;
        //        }
        //    }
        //}
        private void EnsureExcelMeasureContext()
        {
            try
            {
                var app = this.XlApp.Application;
                app.ScreenUpdating = true;

                this.XlSheetPreview?.Worksheet?.Activate();

                Excel.Window activeWindow = app.ActiveWindow;
                if (activeWindow != null)
                {
                    activeWindow.Zoom = 100;
                    activeWindow.WindowState = Excel.XlWindowState.xlNormal;

                    var primaryArea = Screen.PrimaryScreen.WorkingArea;
                    activeWindow.Left = primaryArea.Left + 220d;
                    activeWindow.Top = primaryArea.Top + 60d;
                }
            }
            catch
            {
            }
        }

        private void cellAddPic(string wImageFilePath, ExcelRangeEx wXlRange)
        {
            float cellWidth = (float)wXlRange.GetWidth();
            float cellHeight = (float)wXlRange.GetHeight();
            if (cellWidth <= 0f || cellHeight <= 0f)
                return;

            Excel.Range positionRange = wXlRange.GetMeasureArea();
            float cellLeft = (float)positionRange.Left;
            float cellTop = (float)positionRange.Top;

            int hAlign = GetHorizontalAlignment(wXlRange.Range);
            int vAlign = GetVerticalAlignment(wXlRange.Range);
            const float margin = 1.0f;
            float availableWidth = cellWidth - margin * 2;
            float availableHeight = cellHeight - margin * 2;
            if (availableWidth <= 0f || availableHeight <= 0f)
                return;

            float finalWidth, finalHeight;
            using (var img = System.Drawing.Image.FromFile(wImageFilePath))
            {
                if (img.Width <= 0 || img.Height <= 0) return;

                float imgAspect = (float)img.Width / img.Height;
                float cellAspect = availableWidth / availableHeight;
                if (cellAspect > imgAspect)
                {
                    finalHeight = availableHeight;
                    finalWidth = availableHeight * imgAspect;
                }
                else
                {
                    finalWidth = availableWidth;
                    finalHeight = availableWidth / imgAspect;
                }
            }

            if (finalWidth <= 0f || finalHeight <= 0f)
                return;

            float offsetX = CalculateHorizontalOffset(availableWidth, finalWidth, hAlign);
            float offsetY = CalculateVerticalOffset(availableHeight, finalHeight, vAlign);
            float shapeLeft = cellLeft + margin + offsetX;
            float shapeTop = cellTop + margin + offsetY;

            using (var wXlShapes = new ExcelShapesEx(XlSheetPreview))
            using (var wXlShape = new ExcelShapeEx(wXlShapes.Shapes.AddPicture(
                    wImageFilePath,
                    Microsoft.Office.Core.MsoTriState.msoFalse,
                    Microsoft.Office.Core.MsoTriState.msoTrue,
                    shapeLeft,
                    shapeTop,
                    finalWidth,
                    finalHeight)))
            {
                wXlShape.Shape.LockAspectRatio = Microsoft.Office.Core.MsoTriState.msoTrue;
            }
        }
        // mod #12798 帳票プレビューの画像がセルのサイズに合っていない 高 end

        // Calculate horizontal offset
        private float CalculateHorizontalOffset(float availableWidth, float finalWidth, int hAlign)
        {
            switch (hAlign)
            {
                case 1: // Center
                    return (availableWidth - finalWidth) / 2;
                case 2: // Right align
                    return availableWidth - finalWidth;
                default: // Left align (0)
                    return 0;
            }
        }

        // Calculate vertical offset
        private float CalculateVerticalOffset(float availableHeight, float finalHeight, int vAlign)
        {
            switch (vAlign)
            {
                case 1: // Center
                    return (availableHeight - finalHeight) / 2;
                case 2: // Bottom align
                    return availableHeight - finalHeight;
                default: // Top align (0)
                    return 0;
            }
        }

        // Get horizontal alignment (return int value)
        private int GetHorizontalAlignment(Excel.Range cell)
        {
            int hAlign = (int)cell.HorizontalAlignment;

            // XlHAlign enum int values:
            // xlHAlignLeft = -4131
            // xlHAlignCenter = -4108
            // xlHAlignRight = -4152
            // xlHAlignGeneral = 1

            if (hAlign == -4108)  // xlHAlignCenter
                return 1; // Center
            else if (hAlign == -4152)  // xlHAlignRight
                return 2; // Right align
            else
                return 0; // Left align (default)
        }

        // Get vertical alignment (return int value)
        private int GetVerticalAlignment(Excel.Range cell)
        {
            int vAlign = (int)cell.VerticalAlignment;

            // XlVAlign enum int values:
            // xlVAlignTop = -4160
            // xlVAlignCenter = -4108
            // xlVAlignBottom = -4107

            if (vAlign == -4108)  // xlVAlignCenter
                return 1; // Center
            else if (vAlign == -4107)  // xlVAlignBottom
                return 2; // Bottom align
            else
                return 0; // Top align (default)
        }
        // add #12709 帳票プレビューで画像が表示されない 高 end

        #endregion

        #region メンバ関数定義
        // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
        /// <summary>
        /// CellsUnMerge セル結合を解除する。
        /// </summary>
        /// <param name="templeteData"></param>
        /// <param name="excel"></param>
        /// </param>
        protected virtual void CellsUnMerge(DesignTempleteData templeteData, ExcelWorksheetEx excel, System.Drawing.Point wDstPos)
        {
            String str_s = frmDesignChildLayoutParam.ToName(wDstPos.X - 1) + wDstPos.Y;
            String str_e = frmDesignChildLayoutParam.ToName(wDstPos.X - 1 + templeteData.ColumnCount - 1) + (wDstPos.Y + templeteData.RowCount - 1);
            excel.Worksheet.Range[str_s, str_e].UnMerge();
        }
        // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

        /// <summary>
        /// LayoutSheetChange イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void OnLayoutSheetChange(RldSimpleTextEventArgs e)
        {
            if (this.LayoutSheetChange != null)
            {
                foreach (var wDelegate in this.LayoutSheetChange.GetInvocationList())
                {
                    wDelegate.DynamicInvoke(this, e);
                }
            }
        }

        /// <summary>
        /// LayoutSheetSelectionChange イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void OnLayoutSheetSelectionChange(RldSimpleTextEventArgs e)
        {
            if (this.LayoutSheetSelectionChange != null)
            {
                foreach (var wDelegate in this.LayoutSheetSelectionChange.GetInvocationList())
                {
                    wDelegate.DynamicInvoke(this, e);
                }
            }
        }

		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
        /// LayoutSheetBeforeDoubleClick イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void OnLayoutSheetBeforeDoubleClick(RldSimpleTextEventArgs e)
        {
            if (this.LayoutSheetBeforeDoubleClick != null)
            {
                foreach (var wDelegate in this.LayoutSheetBeforeDoubleClick.GetInvocationList())
                {
                    wDelegate.DynamicInvoke(this, e);
                }
            }
        }
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end

        /// <summary>
        /// 指定されたシート名のワークシートが存在しない場合は、新しく作成して取得します。
        /// </summary>
        /// <param name="aXlSheets"></param>
        /// <param name="aSheetName"></param>
        public ExcelWorksheetEx GetOrCreateWorksheet(ExcelWorksheetsEx aXlSheets, string aSheetName, out bool aIsNewSheet)
        {
            aIsNewSheet = false;

            if (!aXlSheets.IsExists(aSheetName))
            {
                using (var wXlSheet = new ExcelWorksheetEx(aXlSheets.Worksheets.Add(Type.Missing, Type.Missing, Type.Missing, Type.Missing)))
                {
                    wXlSheet.Worksheet.Name = aSheetName;
                }

                aIsNewSheet = true;
            }

            return new ExcelWorksheetEx(aXlSheets, aSheetName);
        }

        /// <summary>
        /// 指定したシート内で使用されているセルの中で、セルが縮小して全体を表示を指定されている場合に、該当セルのフォントサイズを最適化します。
        /// </summary>
        /// <param name="aXlSheet"></param>
        /// <param name="aIsExecForManagedCell"></param>
        private void AdjustCellFontSize(ExcelWorksheetEx aXlSheet, bool aIsExecForManagedCell)
        {
            Dictionary<string, dynamic> wCellAddrValueList;

            // 管理対象外のセルを取得し、縮小して全体を表示に設定されている場合はフォントサイズを調整する
            using (var wXlRange = new ExcelRangeEx(aXlSheet.Worksheet.UsedRange))
            {
                // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                wCellAddrValueList = wXlRange.FindCellAddrValue("*", Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
                // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
            }

            foreach (var wKeyValue in wCellAddrValueList)
            {

                string wCellAddr = wKeyValue.Key, wCellValue = Convert.ToString(wKeyValue.Value);

                // 管理対象セルは変更しない場合で、セルの値が ## から始まっている場合はスキップ
                if (!aIsExecForManagedCell && wCellValue.StartsWith(RldConst.PATH_HEADER))
                {
                    continue;
                }

                using (var wXlRange = new ExcelRangeEx(aXlSheet, wCellAddr))
                {
                    // add 縮小表示をnullとする修正 陳 start
                    if (!Convert.IsDBNull(wXlRange.Range.ShrinkToFit))
                    {
                        if (wXlRange.Range.ShrinkToFit)
                        {
                            wXlRange.Range.Font.Size = wXlRange.GetStringFontSize(wCellValue);
                        }
                    }
                    // add 縮小表示をnullとする修正 陳 end
                }
            }
        }

        // add UT帳票No.123 定期日常点検・交換部品記録簿の履歴データを表示不正の対応 夏 start
        /// <summary>
        /// 設定データの変更内容から変更履歴データを作成します。
        /// </summary>
        /// <param name="aBefore"></param>
        /// <param name="aAfter"></param>
        /// <returns></returns>
        private DesignHistoryData CreateDeviceHistory(InspectionLayoutData aBefore, InspectionLayoutData aAfter)
        {
            var wContent = new System.Text.StringBuilder() { Length = 0 };

            if (aBefore.ReportType != aAfter.ReportType)
            {
                wContent.AppendLine("帳票区分:" + aBefore.ReportType + " ⇒ " + aAfter.ReportType);
            }

            if (aBefore.UseCD != aAfter.UseCD)
            {
                wContent.AppendLine("用途:" + aBefore.UseCD + " ⇒ " + aAfter.UseCD);
            }

			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //if (aBefore.RecordCD != aAfter.RecordCD)
            //{
            //    wContent.AppendLine("記録簿:" + aBefore.RecordCD + " ⇒ " + aAfter.RecordCD);
            //}

            //if (aBefore.LayoutCD != aAfter.LayoutCD)
            //{
            //    wContent.AppendLine("点検レイアウト:" + aBefore.LayoutCD + " ⇒ " + aAfter.LayoutCD);
            //}

            if (aBefore.MachineTypeCD != aAfter.MachineTypeCD)
            {
                wContent.AppendLine("型式:" + aBefore.MachineTypeCD + " ⇒ " + aAfter.MachineTypeCD);
            }
			// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

            // 変更がない場合は抜ける
            if (wContent.Length <= 0)
            {
                return null;
            }

            // 変更履歴データを作成
            return new DesignHistoryData()
            {
                Editor = SignInLib.SignIn.SignInInfo.LoginID,
                EditTime = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"),
                DataName = "定期日常点検・交換部品記録簿設定",
                Address = string.Empty,
                Content = wContent.ToString()
            };
        }
        // add UT帳票No.123 定期日常点検・交換部品記録簿の履歴データを表示不正の対応 夏 end

        // add FNSI-523 2次元帳票対応 夏 start
        /// <summary>
        /// 設定データの変更内容から変更履歴データを作成します。
        /// </summary>
        /// <param name="aBefore"></param>
        /// <param name="aAfter"></param>
        /// <returns></returns>
        private DesignHistoryData CreateTotalHistory(TotalLayoutData aBefore, TotalLayoutData aAfter)
        {
            var wContent = new System.Text.StringBuilder() { Length = 0 };

            if (aBefore.UnitV != aAfter.UnitV)
            {
                wContent.AppendLine("横の集計単位:" + aBefore.UnitV + " ⇒ " + aAfter.UnitV);
            }

            if (aBefore.UnitH != aAfter.UnitH)
            {
                wContent.AppendLine("縦の集計単位:" + aBefore.UnitH + " ⇒ " + aAfter.UnitH);
            }

            if (aBefore.UnitDate != aAfter.UnitDate)
            {
                wContent.AppendLine("集計単位日付:" + aBefore.UnitDate + " ⇒ " + aAfter.UnitDate);
            }

            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            if (aBefore.EffectDataV != aAfter.EffectDataV)
            {
                wContent.AppendLine("出力値のない列は省略する設定:" + aBefore.EffectDataV + " ⇒ " + aAfter.EffectDataV);
            }
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
            if (aBefore.EffectDataH != aAfter.EffectDataH)
            {
                wContent.AppendLine("出力値のない行は省略する設定:" + aBefore.EffectDataH + " ⇒ " + aAfter.EffectDataH);
            }
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

            if (aBefore.Contents != aAfter.Contents)
            {
                wContent.AppendLine("表示内容:" + aBefore.Contents + " ⇒ " + aAfter.Contents);
            }

            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            if (aBefore.ContentsType != aAfter.ContentsType)
            {
                wContent.AppendLine("表示内容種類:" + aBefore.ContentsType + " ⇒ " + aAfter.ContentsType);
            }
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            if (aBefore.Conversion != aAfter.Conversion)
            {
                wContent.AppendLine("表示変換:" + aBefore.Conversion + " ⇒ " + aAfter.Conversion);
            }

            if (aBefore.CountH != aAfter.CountH)
            {
                wContent.AppendLine("縦の合計:" + aBefore.CountH + " ⇒ " + aAfter.CountH);
            }

            if (aBefore.CountV != aAfter.CountV)
            {
                wContent.AppendLine("横の合計:" + aBefore.CountV + " ⇒ " + aAfter.CountV);
            }

            if (aBefore.OriginRange != aAfter.OriginRange)
            {
                wContent.AppendLine("起点セル:" + aBefore.OriginRange + " ⇒ " + aAfter.OriginRange);
            }

            // 変更がない場合は抜ける
            if (wContent.Length <= 0)
            {
                return null;
            }

            // 変更履歴データを作成
            return new DesignHistoryData()
            {
                Editor = SignInLib.SignIn.SignInInfo.LoginID,
                EditTime = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"),
                DataName = "集計設定",
                Address = string.Empty,
                Content = wContent.ToString()
            };
        }
        // add FNSI-523 2次元帳票対応 夏 end

        /// <summary>
        /// 設定データの変更内容から変更履歴データを作成します。
        /// </summary>
        /// <param name="aBefore"></param>
        /// <param name="aAfter"></param>
        /// <returns></returns>
        private DesignHistoryData CreateHistory(DesignSettingData aBefore, DesignSettingData aAfter)
        {
            var wContent = new System.Text.StringBuilder() { Length = 0 };

            if (aBefore.HasTemplete != aAfter.HasTemplete)
            {
                wContent.AppendLine("テンプレート:" + aBefore.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_NO ? "無し" : "有り" + " ⇒ " + aAfter.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_NO ? "無し" : "有り");
            }

            // 変更がない場合は抜ける
            if (wContent.Length <= 0)
            {
                return null;
            }

            // 変更履歴データを作成
            return new DesignHistoryData()
            {
                Editor = SignInLib.SignIn.SignInInfo.LoginID,
                EditTime = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"),
                DataName = "帳票設定",
                Address = string.Empty,
                Content = wContent.ToString()
            };
        }

        /// <summary>
        /// パラメータ編集データの変更内容から変更履歴データを作成します。
        /// </summary>
        /// <param name="aBefore"></param>
        /// <param name="aAfter"></param>
        /// <returns></returns>
        private List<DesignHistoryData> CreateHistory(System.ComponentModel.BindingList<DesignParamData> aBefore, System.ComponentModel.BindingList<DesignParamData> aAfter)
        {
            var wRet = new List<DesignHistoryData>();

            var wNowDate = DateTime.Now;

            // 変更後のデータを基準として変更内容を取得
            foreach (var wAfterData in aAfter)
            {

                var wFindRes = aBefore.Where(ele => ele.CellAddress == wAfterData.CellAddress).ToList();

                var wContent = new System.Text.StringBuilder() { Length = 0 };

                // 同一データの場合
                if (wFindRes != null && wFindRes.Count == 1)
                {
                    if (wAfterData.Length != wFindRes[0].Length)
                    {
                        wContent.AppendLine("表示文字数:" + wFindRes[0].Length + " ⇒ " + wAfterData.Length);
                    }

                    if (wAfterData.IsNewPage != wFindRes[0].IsNewPage)
                    {
                        wContent.AppendLine("改頁:" + wFindRes[0].IsNewPage == RldConst.ParamData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない" + " ⇒ " + wAfterData.IsNewPage == RldConst.ParamData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない");
                    }

                    if (wAfterData.RepeatAddress != wFindRes[0].RepeatAddress)
                    {
                        wContent.AppendLine("繰返場所:" + wFindRes[0].RepeatAddress + " ⇒ " + wAfterData.RepeatAddress);
                    }

                    if (wAfterData.GroupName != wFindRes[0].GroupName)
                    {
                        wContent.AppendLine("グループ名:" + wFindRes[0].GroupName + " ⇒ " + wAfterData.GroupName);
                    }

                    if (wAfterData.PreviewData != wFindRes[0].PreviewData)
                    {
                        wContent.AppendLine("プレビューデータ:" + wFindRes[0].PreviewData + " ⇒ " + wAfterData.PreviewData);
                    }

                    if (wAfterData.DisplayFormat != wFindRes[0].DisplayFormat)
                    {
                        wContent.AppendLine("書式:" + wFindRes[0].DisplayFormat + " ⇒ " + wAfterData.DisplayFormat);
                    }

                    if (wAfterData.ConvertList.ToXmlElementText() != wFindRes[0].ConvertList.ToXmlElementText())
                    {
                        wContent.AppendLine("データ変換:" + wFindRes[0].ConvertList.ToXmlElementText() + " ⇒ " + wAfterData.ConvertList.ToXmlElementText());
                    }

                    if (wAfterData.FilterData != wFindRes[0].FilterData)
                    {
                        wContent.AppendLine("抽出条件:" + wFindRes[0].FilterData + " ⇒ " + wAfterData.FilterData);
                    }

                    if (wAfterData.IsShrink != wFindRes[0].IsShrink)
                    {
                        wContent.AppendLine("縮小設定:" + wFindRes[0].IsShrink == RldConst.ParamData.VAL_ISSHRINK_DONE ? "縮小表示" : "縮小しない" + " ⇒ " + wAfterData.IsShrink == RldConst.ParamData.VAL_ISSHRINK_DONE ? "縮小表示" : "縮小しない");
                    }

                    if (wAfterData.IsInTemplete != wFindRes[0].IsInTemplete)
                    {
                        wContent.AppendLine("テンプレート内外:" + wFindRes[0].IsInTemplete + " ⇒ " + wAfterData.IsInTemplete);
                    }
                    // ラベル
                    // TODO:

                    // 変更前データから削除しておく
                    aBefore.Remove(wFindRes[0]);

                    // 変更データがないためスキップ
                    if (wContent.Length == 0)
                    {
                        continue;
                    }

                    wContent.Insert(0, "設定変更\r\n");
                }
                // 新規追加データの場合
                else
                {
                    wContent.AppendLine("新規追加");
                    if (RldLib.ConvertStrToInt32(wAfterData.Length, false) != 0)
                    {
                        wContent.AppendLine("表示文字数:" + wAfterData.Length);
                    }

                    wContent.AppendLine("改頁:" + wAfterData.IsNewPage == RldConst.ParamData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない");
                    if (!string.IsNullOrEmpty(wAfterData.RepeatAddress))
                    {
                        wContent.AppendLine("繰返場所:" + wAfterData.RepeatAddress);
                    }

                    if (!string.IsNullOrEmpty(wAfterData.GroupName))
                    {
                        wContent.AppendLine("グループ名:" + wAfterData.GroupName);
                    }

                    wContent.AppendLine("プレビューデータ:" + wAfterData.PreviewData);
                    if (!string.IsNullOrEmpty(wAfterData.DisplayFormat))
                    {
                        wContent.AppendLine("書式:" + wAfterData.DisplayFormat);
                    }

                    if (!string.IsNullOrEmpty(wAfterData.ConvertList.ToXmlElementText()))
                    {
                        wContent.AppendLine("データ変換:" + wAfterData.ConvertList.ToXmlElementText());
                    }

                    if (!string.IsNullOrEmpty(wAfterData.FilterData))
                    {
                        wContent.AppendLine("抽出条件:" + wAfterData.FilterData);
                    }

                    wContent.AppendLine("縮小設定:" + wAfterData.IsShrink == RldConst.ParamData.VAL_ISSHRINK_DONE ? "縮小表示" : "縮小しない");
                    wContent.AppendLine("テンプレート内外:" + wAfterData.IsInTemplete);
                    // ラベル
                    // TODO:
                }

                // 戻り値へ追加
                wRet.Add(new DesignHistoryData()
                {
                    Editor = SignInLib.SignIn.SignInInfo.LoginID,
                    EditTime = wNowDate.ToString("yyyy/MM/dd HH:mm:ss"),
                    DataName = wAfterData.DataPath,
                    Address = wAfterData.CellAddress,
                    Content = wContent.ToString()
                });
            }

            // 変更前データで残った分を削除された履歴として追加
            foreach (var wBeforeData in aBefore)
            {
                wRet.Add(new DesignHistoryData()
                {
                    Editor = SignInLib.SignIn.SignInInfo.LoginID,
                    EditTime = wNowDate.ToString("yyyy/MM/dd HH:mm:ss"),
                    DataName = wBeforeData.DataPath,
                    Address = wBeforeData.CellAddress,
                    Content = "削除"
                });
            }

            return wRet;
        }

        /// <summary>
        /// グループ編集データの変更内容から変更履歴データを作成します。
        /// </summary>
        /// <param name="aBefore"></param>
        /// <param name="aAfter"></param>
        /// <returns></returns>
        private List<DesignHistoryData> CreateHistory(System.ComponentModel.BindingList<DesignGroupData> aBefore, System.ComponentModel.BindingList<DesignGroupData> aAfter)
        {
            var wRet = new List<DesignHistoryData>();

            var wNowDate = DateTime.Now;

            // 変更後のデータを基準として変更内容を取得
            foreach (var wAfterData in aAfter)
            {

                var wFindRes = aBefore.Where(ele => ele.GroupPath == wAfterData.GroupPath).ToList();

                var wContent = new System.Text.StringBuilder() { Length = 0 };

                // 同一データの場合
                if (wFindRes != null && wFindRes.Count == 1)
                {
                    // 改頁
                    if (wAfterData.IsNewPage != wFindRes[0].IsNewPage)
                    {
                        wContent.Append("改頁:" + wFindRes[0].IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない" + " ⇒ " + wAfterData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない");
                    }
                    // フィルタ
                    if (wAfterData.FilterData != wFindRes[0].FilterData)
                    {
                        wContent.AppendLine("抽出条件:" + wFindRes[0].FilterData + " ⇒ " + wAfterData.FilterData);
                    }

                    // 変更前データから削除しておく
                    aBefore.Remove(wFindRes[0]);
                }
                // 新規追加データの場合
                else
                {
                    // 改頁
                    wContent.AppendLine("改頁:" + wAfterData.IsNewPage == RldConst.GroupData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない");
                    // フィルタ
                    if (!string.IsNullOrEmpty(wAfterData.FilterData))
                    {
                        wContent.AppendLine("抽出条件:" + wAfterData.FilterData);
                    }
                }

                // 変更データがないためスキップ
                if (wContent.Length == 0)
                {
                    continue;
                }

                // 戻り値へ追加
                wRet.Add(new DesignHistoryData()
                {
                    Editor = SignInLib.SignIn.SignInInfo.LoginID,
                    EditTime = wNowDate.ToString("yyyy/MM/dd HH:mm:ss"),
                    DataName = wAfterData.GroupPath,
                    Address = "グループ",
                    Content = wContent.ToString()
                });
            }

            // 変更前データで残った分を削除された履歴として追加
            foreach (var wBeforeData in aBefore)
            {
                wRet.Add(new DesignHistoryData()
                {
                    Editor = SignInLib.SignIn.SignInInfo.LoginID,
                    EditTime = wNowDate.ToString("yyyy/MM/dd HH:mm:ss"),
                    DataName = wBeforeData.GroupPath,
                    Address = "グループ",
                    Content = "削除"
                });
            }

            return wRet;
        }

        /// <summary>
        /// テンプレート繰返しデータの変更内容から変更履歴データを作成します。
        /// </summary>
        /// <param name="aBefore"></param>
        /// <param name="aAfter"></param>
        /// <returns></returns>
        private DesignHistoryData CreateHistory(DesignTempleteData aBefore, DesignTempleteData aAfter)
        {
            var wContent = new System.Text.StringBuilder() { Length = 0 };

            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
            if (aAfter == null)
            {
                aAfter = new DesignTempleteData();
            }
            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
            if (string.IsNullOrEmpty(aBefore.Range) != string.IsNullOrEmpty(aAfter.Range))
            {
                wContent.AppendLine("設定:" + (string.IsNullOrEmpty(aBefore.Range) ? "無効" : "有効") + " ⇒ " + (string.IsNullOrEmpty(aAfter.Range) ? "無効" : "有効"));
            }

            // 無効になっていない場合
            if (!string.IsNullOrEmpty(aAfter.Range))
            {
                if (aBefore.Range != aAfter.Range)
                {
                    wContent.AppendLine("範囲:" + (string.IsNullOrEmpty(aBefore.Range) ? "未設定" : aBefore.Range) + " ⇒ " + aAfter.Range);
                }

                if (aBefore.MarginH != aAfter.MarginH)
                {
                    wContent.AppendLine("横余白:" + aBefore.MarginH + " ⇒ " + aAfter.MarginH);
                }

                if (aBefore.RepeatCountH != aAfter.RepeatCountH)
                {
                    wContent.AppendLine("横回数:" + aBefore.RepeatCountH + " ⇒ " + aAfter.RepeatCountH);
                }

                if (aBefore.MarginV != aAfter.MarginV)
                {
                    wContent.AppendLine("縦余白:" + aBefore.MarginV + " ⇒ " + aAfter.MarginV);
                }

                if (aBefore.RepeatCountV != aAfter.RepeatCountV)
                {
                    wContent.AppendLine("縦回数:" + aBefore.RepeatCountV + " ⇒ " + aAfter.RepeatCountV);
                }

                if (aBefore.IsNewPage != aAfter.IsNewPage)
                {
                    wContent.AppendLine("改頁:" + aBefore.IsNewPage == RldConst.TempleteData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない" + " ⇒ " + aAfter.IsNewPage == RldConst.TempleteData.VAL_ISNEWPAGE_TRUE ? "改頁する" : "改頁しない");
                }

                if (aBefore.DirectionData != aAfter.DirectionData)
                {
                    wContent.AppendLine("繰返方向:" + (string.IsNullOrEmpty(aBefore.DirectionData) ? "未設定" : aBefore.DirectionData) + " ⇒ " + aBefore.DirectionData);
                }
            }

            // 変更がない場合は抜ける
            if (wContent.Length <= 0)
            {
                return null;
            }

            // 変更履歴データを作成
            return new DesignHistoryData()
            {
                Editor = SignInLib.SignIn.SignInInfo.LoginID,
                EditTime = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"),
                DataName = "テンプレート設定",
                Address = string.Empty,
                Content = wContent.ToString()
            };
        }

        /// <summary>
        /// 変更履歴データを変更履歴シートへ追加します。
        /// ファイルの保存は行いません。
        /// </summary>
        /// <param name="aList"></param>
        private void AddHistory(List<DesignHistoryData> aList)
        {
            //return;

            // 追加する履歴がない場合は抜ける
            if (aList == null || aList.Count <= 0)
            {
                return;
            }

            int wMaxRowCount = this.SheetHistoryMaxRowCount;
            int wStartRowNo = 1;

            // 編集日時列の範囲を取得
            string wEditTimeColRange;
            using (var wXlRangeTop = new ExcelRangeEx(this.XlSheetHistory, 1, (int)DesignHistoryData.EnumDataIndex.EditTime + 1))
            using (var wXlRangeBottom = new ExcelRangeEx(this.XlSheetHistory, wMaxRowCount, (int)DesignHistoryData.EnumDataIndex.EditTime + 1))
            {
                wEditTimeColRange = $"{wXlRangeTop.Range.Address[false, false]}:{wXlRangeBottom.Range.Address[false, false]}";
            }

            // 編集日時列の範囲の値を取得
            using (var wXlRange = new ExcelRangeEx(this.XlSheetHistory, wEditTimeColRange))
            {
                object[,] wData = wXlRange.Range.Value;

                // 空白を探す
                for (int i = 1; i <= wMaxRowCount; i++)
                {
                    if (string.IsNullOrEmpty(wData[i, 1] as string))
                    {
                        wStartRowNo = i;
                        break;
                    }
                }
            }

            // 追加開始行番号を取得
            int wRowNo = wStartRowNo - 1;

            // 最大行数を超える場合は追記するデータ件数分の古いデータを削除する
            if (wRowNo + aList.Count > wMaxRowCount)
            {
                using (var wXlRows = new ExcelRangeEx(this.XlSheetHistory, $"1:{aList.Count}"))
                {
                    wXlRows.Range.Delete(Excel.XlDeleteShiftDirection.xlShiftUp);
                }
            }

            // 追記処理開始
            foreach (var wElement in aList)
            {

                // null 時はスキップ
                if (wElement == null)
                {
                    continue;
                }
                // 変更内容がない場合はスキップ
                if (string.IsNullOrEmpty(wElement.Content))
                {
                    continue;
                }

                // 追加先の行番号を更新
                wRowNo++;

                string wAddress;
                using (var wXlRangeLeft = new ExcelRangeEx(this.XlSheetHistory, wRowNo, (int)DesignHistoryData.EnumDataIndex.Editor + 1))
                using (var wXlRangeRight = new ExcelRangeEx(this.XlSheetHistory, wRowNo, (int)DesignHistoryData.EnumDataIndex.Content + 1))
                {
                    wAddress = $"{wXlRangeLeft.Range.Address[false, false]}:{wXlRangeRight.Range.Address[false, false]}";
                }

                using (var wXlRange = new ExcelRangeEx(this.XlSheetHistory, wAddress))
                {

                    object[,] wData = wXlRange.Range.Value;

                    wData[1, (int)DesignHistoryData.EnumDataIndex.Editor + 1] = wElement.Editor;
                    wData[1, (int)DesignHistoryData.EnumDataIndex.EditTime + 1] = wElement.EditTime;
                    wData[1, (int)DesignHistoryData.EnumDataIndex.DataName + 1] = wElement.DataName;
                    wData[1, (int)DesignHistoryData.EnumDataIndex.Address + 1] = wElement.Address;
                    wData[1, (int)DesignHistoryData.EnumDataIndex.Content + 1] = wElement.Content;

                    wXlRange.Range.Value = wData;
                }
            }
        }

        #endregion

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// ブック の BeforeClose イベント
        /// </summary>
        /// <param name="Cancel"></param>
        private void XlBook_BeforeClose(ref bool Cancel)
        {

            try
            {

                // 閉じている最中以外は閉じれないようにする
                if (!this.IsXlBookClosing)
                {
                    Cancel = true;
                }

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
            }

        }

        /// <summary>
        /// ［レイアウト］シートのセルがユーザーまたは外部リンクにより変更されたときに呼び出します
        /// </summary>
        /// <param name="Target"></param>
        private void XlSheetLayout_Change(Excel.Range Target)
        {

            try
            {

                if (!this.IsHandleLayoutSheetEvent)
                {
                    return;
                }

                string wAddress = Target.Address[false, false];

                // mod #8475 【レポートレイアウトデザイナ】エクセルにドラッグされた項目の問題 xiaosonglei start
                this.OnLayoutSheetChange(new RldSimpleTextEventArgs(wAddress));
                // List<DesignParamData> paramDataCheckList = RldLib.CurrentLayoutData.DesignParamList.ToList();
                // List<string> paramAddressList = new List<string>();
                // for (int i = 0; i < paramDataCheckList.Count; i++)
                // {
                //     paramAddressList.Add(paramDataCheckList[i].CellAddress.Split(':')[0]);
                // }
                // 
                // foreach (Excel.Range cell in Target.Cells)
                // {
                //     string address = cell.Address[false, false];
                //     if (paramAddressList.Contains(address))
                //     {
                //         this.OnLayoutSheetChange(new RldSimpleTextEventArgs(address));
                //     }
                // }
                // mod #8475 【レポートレイアウトデザイナ】エクセルにドラッグされた項目の問題 xiaosonglei end

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
            }

        }

        /// <summary>
        /// ［レイアウト］シートで選択範囲を変更したときに呼び出します
        /// </summary>
        /// <param name="Target"></param>
        private void XlSheetLayout_SelectionChange(Excel.Range Target)
        {

            try
            {

                if (!this.IsHandleLayoutSheetEvent)
                {
                    return;
                }

                string wAddress = Target.Address[false, false];

                this.OnLayoutSheetSelectionChange(new RldSimpleTextEventArgs(wAddress));

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
            }

        }

		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
        /// <summary>
        /// ［レイアウト］シートで選択範囲を変更したときに呼び出します
        /// </summary>
        /// <param name="Target"></param>
        private void XlSheetLayout_BeforeDoubleClick(Excel.Range Target, ref bool Cancel)
        {

            try
            {

                if (!this.IsHandleLayoutSheetEvent)
                {
                    return;
                }

                string wAddress = Target.Address[false, false];

                this.OnLayoutSheetBeforeDoubleClick(new RldSimpleTextEventArgs(wAddress));

            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, true);
            }

        }

        /// <summary>
        /// 清空剪切板
        /// </summary>
        /// <returns></returns>
        public void ClearClipboard()
        {
            // mod #10230 コピーした内容がリセットされる 高 start
            // if (System.Windows.Forms.Clipboard.ContainsAudio() || System.Windows.Forms.Clipboard.ContainsFileDropList() || System.Windows.Forms.Clipboard.ContainsImage() || System.Windows.Forms.Clipboard.ContainsText() || System.Windows.Forms.Clipboard.ContainsData(DataFormats.Html))
            if (System.Windows.Forms.Clipboard.ContainsAudio() || System.Windows.Forms.Clipboard.ContainsFileDropList() || System.Windows.Forms.Clipboard.ContainsImage() || System.Windows.Forms.Clipboard.ContainsData(DataFormats.Html))
            // mod #10230 コピーした内容がリセットされる 高 end
                System.Windows.Forms.Clipboard.Clear();
        }
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end

        private static int ToIndex(string columnName)
        {
            if (!Regex.IsMatch(columnName.ToUpper(), @"[A-Z]+")) { throw new Exception("invalid parameter"); }

            int index = 0;
            char[] chars = columnName.ToUpper().ToCharArray();
            for (int i = 0; i < chars.Length; i++)
            {
                index += ((int)chars[i] - (int)'A' + 1) * (int)Math.Pow(26, chars.Length - i - 1);
            }
            return index - 1;
        }
        // add #9157 FNW帳票取り込み時の不正 董昊 end

        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
        // check param format is fnis
        public bool checkFnsiParam()
        {
            bool bRet = false;
            object[,] wGetValues = null;

            try
            {
                // パラメータシートからデータを取得
                using (var wXlRange = new ExcelRangeEx(this.XlSheetParam.Worksheet.UsedRange))
                {
                    wGetValues = wXlRange.Range.Value;
                }

                if(wGetValues == null || wGetValues.GetLength(0) < 1)
                    return bRet;

                // 保存対象列を取得
                var wColumnList = DesignParamData.GetReadWriteDataList();

                // 保存対象列とパラメータシートの列の対応を作成
                var wDataKey = new System.Collections.Generic.Dictionary<DesignParamData.EnumDataIndex, Int32>();
                foreach (var wKey in wColumnList)
                {
                    string wPropName = DesignParamData.GetProperty(wKey).Name;

                    // 1行目を確認
                    for (int i = 1; i <= wGetValues.GetLength(1); i++)
                    {
                        string wValue = wGetValues[1, i] as string;
                        if (!string.IsNullOrEmpty(wValue) && string.CompareOrdinal(wValue, wPropName) == 0)
                        {
                            wDataKey.Add(wKey, i);
                            break;
                        }
                    }
                }

                // head contains: データパス, クラス, 配置場所
                if (wDataKey.ContainsKey(DesignParamData.EnumDataIndex.DataPath)
                    && wDataKey.ContainsKey(DesignParamData.EnumDataIndex.DataClass)
                    && wDataKey.ContainsKey(DesignParamData.EnumDataIndex.CellAddress))
                {
                    return true;
                }

                return bRet;
             }
            catch (Exception ex)
            {
            }

            return bRet;
        }
        // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end

        // add #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 start
        // check param format is FNW帳票
        public bool checkFnwParam()
        {
            bool bRet = false;
            object[,] wGetValues = null;

            try
            {
                // パラメータシートからデータを取得
                using (var wXlRange = new ExcelRangeEx(this.XlSheetParam.Worksheet.UsedRange))
                {
                    wGetValues = wXlRange.Range.Value;
                }

                if (wGetValues == null || wGetValues.GetLength(0) < 1)
                    return bRet;

                // 保存対象列とパラメータシートの列の対応を作成
                List<String> wDataTitle = new List<string>();

                // 1行目を確認
                for (int i = 1; i <= wGetValues.GetLength(1); i++)
                {
                    string wValue = wGetValues[1, i] as string;
                    if (!string.IsNullOrEmpty(wValue))
                    {
                        wDataTitle.Add(wValue);
                    }
                }

                // head contains: カテゴリ, クラス, データ格納場所
                if (wDataTitle.Count > 0)
                {
                    if (wDataTitle.Contains("カテゴリ")
                        && wDataTitle.Contains("クラス")
                        && wDataTitle.Contains("データ格納場所"))
                    {
                        return true;
                    }
                }

                return bRet;
            }
            catch (Exception ex)
            {
            }

            return bRet;
        }
        // add #10476 取り込み機能で「FNW帳票」かどうかをチェックする 高 end
        #endregion

    }
}
