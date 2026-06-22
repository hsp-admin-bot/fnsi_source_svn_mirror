using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
// add #8394(1) 動作に関する指摘 luantian start
using System.Globalization;
// add #8394(1) 動作に関する指摘 luantian end
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;

using Excel = Microsoft.Office.Interop.Excel;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
//
using System.Collections;
namespace LayoutDesigner
{
    /// <summary>
    /// デザイナーウィンドウ内パラメータ編集画面
    /// </summary>
    public partial class frmDesignChildLayoutParam : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldDesignRecvOnlyColleague, IRldDesignSendOnlyColleague
    {
        #region メンバ構造体定義

        //ADD #8394 NG2 董 START
        public static Boolean isSkip = false;
        //ADD #8394 NG2 董 END

        /// <summary>
        /// 変更セルデータ
        /// </summary>
        private struct ChangedCell
        {
            #region 生成と破棄

            /// <summary>
            /// 変更セルデータの新しいインスタンスを初期化します。
            /// </summary>
            /// <param name="aCellAddress"></param>
            /// <param name="aDataPath"></param>
            /// <param name="aIsRemove"></param>
            public ChangedCell(String aCellAddress, String aDataPath, Boolean aIsRemove)
            {
                this.CellAddress = aCellAddress;
                this.DataPath = aDataPath;
                this.IsRemove = aIsRemove;
            }

            #endregion

            #region メンバプロパティ定義

            /// <summary>
            /// セル位置の取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public String CellAddress { get; private set; }

            /// <summary>
            /// セル内に格納されているデータパスの取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public String DataPath { get; private set; }

            /// <summary>
            /// セルの内容が削除されたかどうかの取得を行います。
            /// 値の取得のみ可能です。
            /// </summary>
            public Boolean IsRemove { get; private set; }

            #endregion
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// パラメータ編集用データグリッドビューヘルパークラス
        /// </summary>
        private RldDataGridViewParamDataEditHelper m_ParamGridEditHelper = null;

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        #endregion

        // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
        List<DesignParamData> dPdList = new List<DesignParamData>();
        // add 2020-10-29 FNSI-改修 637バグの修正 夏 end

        #region 生成と破棄

        /// <summary>
        /// デザイナーウィンドウ内パラメータ編集画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildLayoutParam()
        {
            InitializeComponent();

            // スプリットコンテナの最小サイズを設定
            this.splParameter.Panel1MinSize = this.dgvParamList.ColumnHeadersHeight;
            this.splParameter.Panel2MinSize = this.dgvParamDetail.ColumnHeadersHeight;

            // パラメータ一覧用データグリッドビューヘルパークラスを生成
            this.m_ParamGridEditHelper = new RldDataGridViewParamDataEditHelper(this.dgvParamList);
            this.m_ParamGridEditHelper.NotifyInfo += (s, e) => this.SendNotifyInfo(e);

            // パラメータリストデータの変更受信
            RldLib.CurrentLayoutData.DesignParamList.ListChanged += new ListChangedEventHandler(this.DesignParamList_ListChanged);
            //add 9137 zhu start
            this.dgvParamDetail.CellClick += DgvParamDetail_CellClick;
            //add 9137 zhu end

            // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
            RldLib.CurrentLayoutData.DesignParamList.RequestRefreshParamUI += RefreshButtonColumns;
            // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        }

        //add 9137 zhu start
        private void DgvParamDetail_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            isCellEndEdit = true;
            olddgvParamListindex = dgvParamList.CurrentRow.Index;
        }
        //add 9137 zhu end
        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// パラメータリスト表示用グリッド及びExcelのアクティブセルの変更中フラグ
        /// </summary>
        private Boolean IsSelectionChanging { get; set; } = false;

        /// <summary>
        /// パラメータリスト表示用グリッドの RowEnter イベント内の処理を行わないかどうかフラグ
        /// </summary>
        private bool IsCancelRowEnter { get; set; } = false;

        /// <summary>
        /// パラメータリスト表示用グリッドの変更内容を元に戻している最中かどうかフラグ
        /// </summary>
        private Boolean IsRollbacking { get; set; } = false;

        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        /// <summary>
        /// ProcessAtomicAddresses 実行中フラグ（ListChanged との Excel COM 再入を防ぐ）
        /// </summary>
        private static Boolean IsSyncingAtomicAddresses { get; set; } = false;
        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode)
            {
                return;
            }

            // 画面をクリア
            this.DataClear(true);
            // スプリットコンテナの分割ラインを移動(限界まで移動させれば最小サイズで止まる)
            this.splParameter.SplitterDistance = this.splParameter.Height;

            // レイアウトシートのセル編集完了イベントの受信を開始
            RldLib.XlHelper.LayoutSheetChange += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_Change);
            // レイアウトシートの選択位置変更イベントの受信を開始
            RldLib.XlHelper.LayoutSheetSelectionChange += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_SelectionChange);
        }

        /// <summary>
        /// Form.Shown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            // 画面にデータを読み込む
            this.DataRead();
            // add #8394(3,4) 動作に関する指摘 luantian start
            if (this.dgvParamList.RowCount > 0)
            {
                this.dgvParamList[0, 0].Selected = true;
            }
            // add #8394(3,4) 動作に関する指摘 luantian start
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">(未使用)</param>
        private void DataClear(Boolean aIsKeyClear)
        {
            if (aIsKeyClear)
            {
                this.m_ParamGridEditHelper.Clear();
            }

            // mod #12475 FNW帳票取込すると検査日が表示されない 高 start
            try
            {
                this.dgvParamDetail.RowCount = 0;
            }
            catch (Exception) { }
            // mod #12475 FNW帳票取込すると検査日が表示されない 高 end
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            try
            {
                // 表示データをセット
                // mod #8394(3,4) 動作に関する指摘 luantian start
                //this.m_ParamGridEditHelper.SetData(RldLib.CurrentLayoutData.DesignParamList);
                this.IsCancelRowEnter = true;
                this.m_ParamGridEditHelper.SetData(RldLib.CurrentLayoutData.DesignParamList);
                this.IsCancelRowEnter = false;
                // mod #8394(3,4) 動作に関する指摘 luantian start

                // 1行目を選択しておく
                // del #8394(3,4) 動作に関する指摘 luantian start
                //if (this.dgvParamList.RowCount > 0)
                //{
                //    this.dgvParamList[0, 0].Selected = true;
                //}
                // del #8394(3,4) 動作に関する指摘 luantian end

            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        // mod 2023-03-24 #8335 FNW帳票取込みの動作に問題あり 鵬 start
        #region " データの更新 "
        /// <summary>
        /// 指定された Excel のセル範囲のデータでバインディングリストを更新します。
        /// </summary>
        /// <param name="aRangeAddress">更新するセル範囲</param>
        private void UpdateBindingList(String aRangeAddress)
        {
            const String MSG_HEADER = "パラメータデータ用バインディングリストの更新";

            // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
            String TopLeftNorm(String addr)
            {
                if (String.IsNullOrEmpty(addr))
                {
                    return String.Empty;
                }
                return addr.Split(':')[0].Replace("$", String.Empty).ToUpperInvariant();
            }

            Boolean AddrKeyEquals(String a, String b)
            {
                return String.Equals(TopLeftNorm(a), TopLeftNorm(b), StringComparison.Ordinal);
            }

            void FixRepeatAddressAfterCellMove(DesignParamData wData)
            {
                if (wData != null && !String.IsNullOrEmpty(wData.RepeatAddress) && !wData.RepeatAddress.StartsWith(wData.CellAddress))
                {
                    wData.RepeatAddress = wData.CellAddress;
                }
            }

            Boolean TryParseColumnLettersToZeroBasedIndex(String letters, out Int32 col)
            {
                return TryToIndex(letters, out col);
            }

            Boolean TryParseCellTopLeft(String addr, out Int32 row, out Int32 col)
            {
                row = 0;
                col = 0;
                if (String.IsNullOrEmpty(addr))
                {
                    return false;
                }
                String first = TopLeftNorm(addr);
                Match m = Regex.Match(first, @"^([A-Z]+)(\d+)$", RegexOptions.CultureInvariant);
                if (!m.Success)
                {
                    return false;
                }
                if (!TryParseColumnLettersToZeroBasedIndex(m.Groups[1].Value, out col))
                {
                    return false;
                }
                if (!Int32.TryParse(m.Groups[2].Value, NumberStyles.None, CultureInfo.InvariantCulture, out row))
                {
                    col = 0;
                    return false;
                }
                return true;
            }

            Int64 AddrSortKey(String addr)
            {
                if (!TryParseCellTopLeft(addr, out Int32 r, out Int32 c))
                {
                    return 0;
                }
                return ((Int64)r << 32) | (UInt32)c;
            }

            /// <summary>
            /// 設計データの DataPath（XML 等で \" が入る）と Excel から取得したセル文字列（" のみ）の差を吸収し、リマップ照合用キーを揃える。
            /// </summary>
            String NormalizePathKeyForRemap(String path)
            {
                if (String.IsNullOrEmpty(path))
                {
                    return String.Empty;
                }
                String t = path.Trim();
                t = t.Replace("\\\"", "\"");
                return t;
            }

            Boolean TryNormalizeSingleCellEndpoint(String raw, out String cellAddr)
            {
                cellAddr = TopLeftNorm(raw?.Trim().Replace("$", String.Empty) ?? String.Empty);
                return Regex.IsMatch(cellAddr, @"^[A-Z]+\d+$", RegexOptions.CultureInvariant);
            }

            Boolean TryParseSimpleCellReferencePath(String path, out String referencedCell)
            {
                referencedCell = null;
                if (String.IsNullOrEmpty(path))
                {
                    return false;
                }
                String norm = NormalizePathKeyForRemap(path);
                if (!norm.StartsWith(RldConst.CALC_HEADER, StringComparison.Ordinal))
                {
                    return false;
                }
                String rest = norm.Substring(RldConst.CALC_HEADER.Length).Trim();
                Match m = Regex.Match(rest, @"^([A-Z]+\d+)$", RegexOptions.CultureInvariant);
                if (!m.Success)
                {
                    return false;
                }
                referencedCell = m.Groups[1].Value;
                return true;
            }

            String GetExcelPathFromScanDict(Dictionary<String, dynamic> excelCellValues, String addr)
            {
                if (excelCellValues == null || String.IsNullOrEmpty(addr))
                {
                    return null;
                }
                if (excelCellValues.TryGetValue(addr, out dynamic direct) && direct is string directStr)
                {
                    return NormalizePathKeyForRemap(directStr);
                }
                if (addr.IndexOf(':') < 0)
                {
                    String addrNorm = TopLeftNorm(addr);
                    foreach (KeyValuePair<String, dynamic> kv in excelCellValues)
                    {
                        if (kv.Value is string ks
                            && String.Equals(TopLeftNorm(kv.Key), addrNorm, StringComparison.OrdinalIgnoreCase))
                        {
                            return NormalizePathKeyForRemap(ks);
                        }
                    }
                }
                return null;
            }

            Boolean IsCutSourceParamAtExcel(DesignParamData p, Dictionary<String, dynamic> excelCellValues)
            {
                if (p == null || String.IsNullOrWhiteSpace(p.CellAddress) || String.IsNullOrEmpty(p.DataPath))
                {
                    return false;
                }
                String excelAt = GetExcelPathFromScanDict(excelCellValues, p.CellAddress);
                if (String.IsNullOrEmpty(excelAt))
                {
                    return true;
                }
                return !String.Equals(excelAt, NormalizePathKeyForRemap(p.DataPath), StringComparison.Ordinal);
            }

            /// <summary>
            /// 単一セルの Change ヒント（D6 や D8 など）から切り取りドラッグの移動元・先を推定する。
            /// </summary>
            Boolean TryInferCutDragSourceAndDest(
                String hint,
                IEnumerable<DesignParamData> paramSnapshot,
                Dictionary<String, dynamic> excelCellValues,
                out String sourceAddr,
                out String destAddr)
            {
                sourceAddr = null;
                destAddr = null;
                if (String.IsNullOrWhiteSpace(hint) || paramSnapshot == null || excelCellValues == null || excelCellValues.Count == 0)
                {
                    return false;
                }
                if (!TryNormalizeSingleCellEndpoint(hint.Trim().Split(':')[0], out String hintCell))
                {
                    return false;
                }

                var pathToExcelAddrs = new Dictionary<String, List<String>>(StringComparer.Ordinal);
                foreach (KeyValuePair<String, dynamic> kv in excelCellValues)
                {
                    if (!(kv.Value is string cv))
                    {
                        continue;
                    }
                    if (String.IsNullOrEmpty(cv) || !cv.StartsWith(RldConst.PATH_HEADER, StringComparison.Ordinal)
                        || cv.Equals(RldConst.PATH_HEADER) || cv.Equals(RldConst.CALC_HEADER))
                    {
                        continue;
                    }
                    String pathNorm = NormalizePathKeyForRemap(cv);
                    if (!pathToExcelAddrs.TryGetValue(pathNorm, out List<String> addrList))
                    {
                        addrList = new List<String>();
                        pathToExcelAddrs[pathNorm] = addrList;
                    }
                    addrList.Add(kv.Key);
                }

                DesignParamData FindParamAt(String addr)
                {
                    foreach (DesignParamData p in paramSnapshot)
                    {
                        if (AddrKeyEquals(p.CellAddress, addr))
                        {
                            return p;
                        }
                    }
                    return null;
                }

                String excelAtHint = GetExcelPathFromScanDict(excelCellValues, hintCell);
                DesignParamData paramAtHint = FindParamAt(hintCell);

                if (String.IsNullOrEmpty(excelAtHint) || (paramAtHint != null && IsCutSourceParamAtExcel(paramAtHint, excelCellValues)))
                {
                    DesignParamData owner = paramAtHint;
                    if (owner == null)
                    {
                        foreach (DesignParamData p in paramSnapshot)
                        {
                            if (!IsCutSourceParamAtExcel(p, excelCellValues) || String.IsNullOrEmpty(p.DataPath))
                            {
                                continue;
                            }
                            if (!pathToExcelAddrs.TryGetValue(NormalizePathKeyForRemap(p.DataPath), out List<String> addrs))
                            {
                                continue;
                            }
                            if (addrs.Any(a => !AddrKeyEquals(a, p.CellAddress)))
                            {
                                owner = p;
                                break;
                            }
                        }
                    }
                    if (owner != null && !String.IsNullOrEmpty(owner.DataPath)
                        && pathToExcelAddrs.TryGetValue(NormalizePathKeyForRemap(owner.DataPath), out List<String> destCandidates))
                    {
                        String dest = destCandidates
                            .Where(a => !AddrKeyEquals(a, hintCell))
                            .OrderBy(a => AddrSortKey(a))
                            .FirstOrDefault();
                        if (!String.IsNullOrEmpty(dest))
                        {
                            sourceAddr = hintCell;
                            destAddr = TopLeftNorm(dest);
                            return true;
                        }
                    }
                }

                if (!String.IsNullOrEmpty(excelAtHint))
                {
                    foreach (DesignParamData p in paramSnapshot)
                    {
                        if (String.IsNullOrEmpty(p.DataPath))
                        {
                            continue;
                        }
                        if (!String.Equals(NormalizePathKeyForRemap(p.DataPath), excelAtHint, StringComparison.Ordinal))
                        {
                            continue;
                        }
                        if (AddrKeyEquals(p.CellAddress, hintCell))
                        {
                            continue;
                        }
                        if (IsCutSourceParamAtExcel(p, excelCellValues))
                        {
                            sourceAddr = TopLeftNorm(p.CellAddress);
                            destAddr = hintCell;
                            return true;
                        }
                    }
                }

                return false;
            }

            String ReadLayoutSheetCellPath(String cellAddr)
            {
                if (String.IsNullOrEmpty(cellAddr))
                {
                    return null;
                }
                try
                {
                    Object wVal = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellAddr].Value2;
                    if (wVal == null || wVal == DBNull.Value)
                    {
                        return null;
                    }
                    String s = Convert.ToString(wVal, CultureInfo.InvariantCulture)?.Trim();
                    if (String.IsNullOrEmpty(s) || !s.StartsWith(RldConst.PATH_HEADER, StringComparison.Ordinal))
                    {
                        return null;
                    }
                    return NormalizePathKeyForRemap(s);
                }
                catch
                {
                    return null;
                }
            }

            void RestoreExcelSimpleCellRefsPointingTo(String referencedCellNorm)
            {
                if (String.IsNullOrEmpty(referencedCellNorm))
                {
                    return;
                }
                String restorePath = RldConst.CALC_HEADER + referencedCellNorm;
                Boolean wPrevHandleLayoutEvent = RldLib.XlHelper.IsHandleLayoutSheetEvent;
                RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
                try
                {
                    foreach (DesignParamData p in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        if (String.IsNullOrWhiteSpace(p.CellAddress))
                        {
                            continue;
                        }
                        if (!TryParseSimpleCellReferencePath(p.DataPath, out String refCell))
                        {
                            continue;
                        }
                        if (!String.Equals(refCell, referencedCellNorm, StringComparison.OrdinalIgnoreCase))
                        {
                            continue;
                        }
                        if (AddrKeyEquals(p.CellAddress, referencedCellNorm))
                        {
                            continue;
                        }
                        String excelPath = ReadLayoutSheetCellPath(p.CellAddress);
                        if (String.Equals(excelPath, restorePath, StringComparison.Ordinal))
                        {
                            continue;
                        }
#if DEBUG
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture,
                        //    "[RemapDesignParam] restore cell-ref {0} at {1} excelWas={2}",
                        //    restorePath, p.CellAddress, excelPath ?? "(empty)"));
#endif
                        try
                        {
                            RldLib.XlHelper.XlSheetLayout.Worksheet.Range[p.CellAddress].Value2 = restorePath;
                        }
                        catch (Exception ex)
                        {
#if DEBUG
                            Console.WriteLine(String.Format(CultureInfo.InvariantCulture,
                                "[RemapDesignParam] restore failed at {0}: {1}", p.CellAddress, ex.Message));
#endif
                        }
                    }
                }
                finally
                {
                    RldLib.XlHelper.IsHandleLayoutSheetEvent = wPrevHandleLayoutEvent;
                }
            }

            Boolean IsRowOnlyRangeHint(String hint)
            {
                if (String.IsNullOrWhiteSpace(hint))
                {
                    return false;
                }
                String[] p = hint.Trim().Split(':');
                if (p.Length != 2)
                {
                    return false;
                }
                return Regex.IsMatch(p[0].Trim(), @"^\d+$") && Regex.IsMatch(p[1].Trim(), @"^\d+$");
            }

            /// <summary>
            /// 列の挿入・削除など、範囲が列番号のみのとき（例: B:D, $B:$E）。行番号を含む A1 形式は false。
            /// Excel の変更範囲が 1 列まるごと（B1:B1048576）のときも true。
            /// </summary>
            Boolean IsColumnOnlyRangeHint(String hint)
            {
                if (String.IsNullOrWhiteSpace(hint))
                {
                    return false;
                }
                String t = hint.Trim();
                Int32 bang = t.LastIndexOf('!');
                if (bang >= 0)
                {
                    t = t.Substring(bang + 1);
                }
                String[] p = t.Split(':');
                if (p.Length != 2)
                {
                    return false;
                }
                String a = p[0].Trim().Replace("$", String.Empty);
                String b = p[1].Trim().Replace("$", String.Empty);
                if (a.Length == 0 || b.Length == 0)
                {
                    return false;
                }
                if (Regex.IsMatch(a, @"^[A-Za-z]+$") && Regex.IsMatch(b, @"^[A-Za-z]+$"))
                {
                    return true;
                }
                // Target が B1:B1048576 のように返る場合（列ラベル + 行番号）
                Match ma = Regex.Match(a, @"^([A-Za-z]+)(\d+)$");
                Match mb = Regex.Match(b, @"^([A-Za-z]+)(\d+)$");
                if (ma.Success && mb.Success
                    && String.Equals(ma.Groups[1].Value, mb.Groups[1].Value, StringComparison.OrdinalIgnoreCase))
                {
                    Int32 ra = Int32.Parse(ma.Groups[2].Value, CultureInfo.InvariantCulture);
                    Int32 rb = Int32.Parse(mb.Groups[2].Value, CultureInfo.InvariantCulture);
                    Int32 minR = Math.Min(ra, rb);
                    Int32 maxR = Math.Max(ra, rb);
                    if (minR == 1 && maxR >= 1048570)
                    {
                        return true;
                    }
                }
                return false;
            }

            Boolean IsSingleCellDragLikeHint(String hint)
            {
                if (String.IsNullOrWhiteSpace(hint) || IsRowOnlyRangeHint(hint) || IsColumnOnlyRangeHint(hint))
                {
                    return false;
                }
                String t = hint.Trim();
                String[] p = t.Split(':');
                if (p.Length == 1)
                {
                    return Regex.IsMatch(TopLeftNorm(p[0]), @"^[A-Z]+\d+$");
                }
                if (p.Length == 2 && AddrKeyEquals(p[0], p[1]))
                {
                    return Regex.IsMatch(TopLeftNorm(p[0]), @"^[A-Z]+\d+$");
                }
                return false;
            }

            const Int32 MAX_STRIP_HINT_CELL_COUNT = 512;
            const Int32 MAX_SMALL_AXIS_ALIGNED_RECT_HINT_CELLS = 64;
            Boolean IsStripAlignedTwoCornerHint(String hint)
            {
                if (String.IsNullOrWhiteSpace(hint) || IsRowOnlyRangeHint(hint) || IsColumnOnlyRangeHint(hint) || IsSingleCellDragLikeHint(hint))
                {
                    return false;
                }
                String[] p = hint.Trim().Split(':');
                if (p.Length != 2 || AddrKeyEquals(p[0], p[1]))
                {
                    return false;
                }
                if (!TryParseCellTopLeft(p[0].Trim(), out Int32 r0, out Int32 c0))
                {
                    return false;
                }
                if (!TryParseCellTopLeft(p[1].Trim(), out Int32 r1, out Int32 c1))
                {
                    return false;
                }
                Int32 rowSpan = Math.Abs(r0 - r1) + 1;
                Int32 colSpan = Math.Abs(c0 - c1) + 1;
                Int32 cellCount = rowSpan * colSpan;
                if (cellCount > MAX_STRIP_HINT_CELL_COUNT)
                {
                    return false;
                }
                if (r0 == r1 || c0 == c1)
                {
                    return true;
                }
                return cellCount <= MAX_SMALL_AXIS_ALIGNED_RECT_HINT_CELLS;
            }

            var remapOrphanDeletes = new List<(DesignParamData Param, String OriginalAddress)>();
            var remapEvictedDeletes = new List<DesignParamData>();

            void RemapDesignParamCellAddressesToMatchExcel(List<DesignParamData> paramSnapshot, Dictionary<String, dynamic> excelCellValues, Boolean useKeepAddressFirstForDuplicatePath, Boolean useBulkAxisSortedIndexPairing, Boolean useStripIdentityThenSortedRemainder, String layoutChangeHint)
            {
                if (paramSnapshot == null || paramSnapshot.Count == 0 || excelCellValues == null || excelCellValues.Count == 0)
                {
                    return;
                }

                var newCells = new List<KeyValuePair<String, String>>();
                foreach (var kv in excelCellValues)
                {
                    String cv = Convert.ToString(kv.Value, CultureInfo.InvariantCulture)?.Trim() ?? String.Empty;

                    if (String.IsNullOrEmpty(cv) || !cv.StartsWith(RldConst.PATH_HEADER)
                        || cv.Equals(RldConst.PATH_HEADER) || cv.Equals(RldConst.CALC_HEADER))
                    {
                        continue;
                    }
                    newCells.Add(new KeyValuePair<String, String>(kv.Key, cv));
                }

                List<String> DedupeExcelKeysSameCell(IEnumerable<String> keys)
                {
                    List<String> materialized = keys.OrderBy(AddrSortKey).ToList();
                    if (materialized.Count <= 1)
                    {
                        return materialized;
                    }
                    var byTopLeft = materialized.GroupBy(k => TopLeftNorm(k), StringComparer.Ordinal);
                    if (byTopLeft.All(g => g.Count() == 1))
                    {
                        return materialized;
                    }
                    var deduped = new List<String>();
                    foreach (var g in byTopLeft)
                    {
                        deduped.Add(g.OrderByDescending(x => (x != null && x.IndexOf(':') >= 0) ? 1 : 0)
                            .ThenByDescending(x => x == null ? 0 : x.Length)
                            .ThenBy(x => x, StringComparer.Ordinal)
                            .First());
                    }
                    return deduped.OrderBy(AddrSortKey).ToList();
                }

                Dictionary<String, List<String>> newByPath = newCells
                    .GroupBy(p => NormalizePathKeyForRemap(p.Value))
                    .ToDictionary(g => g.Key, g => DedupeExcelKeysSameCell(g.Select(x => x.Key)));

                const Int32 MAX_REMAP_CONFLICT_NEST = 8;
                Int32 remapConflictNestDepth = 0;

#if DEBUG
                //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] newByPath groups={0} bulkAxis={1} keepFirst={2} strip={3}", newByPath.Count, useBulkAxisSortedIndexPairing, useKeepAddressFirstForDuplicatePath, useStripIdentityThenSortedRemainder));
                //foreach (KeyValuePair<String, List<String>> wKv in newByPath.OrderBy(x => x.Key, StringComparer.Ordinal))
                //{
                //    String wPreview = wKv.Key == null ? String.Empty : (wKv.Key.Length <= 120 ? wKv.Key : wKv.Key.Substring(0, 120) + "…");
                //    Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] excelKeyNorm addrs={0} len={1} preview={2}", wKv.Value.Count, wKv.Key == null ? 0 : wKv.Key.Length, wPreview));
                //}
#endif

                Boolean PathExistsInExcel(DesignParamData p)
                {
                    if (p == null || String.IsNullOrEmpty(p.DataPath))
                    {
                        return false;
                    }
                    return newByPath.ContainsKey(NormalizePathKeyForRemap(p.DataPath));
                }

                foreach (DesignParamData orphanParam in paramSnapshot.ToList())
                {
                    if (!PathExistsInExcel(orphanParam) && !String.IsNullOrEmpty(orphanParam.CellAddress))
                    {
                        remapOrphanDeletes.Add((orphanParam, orphanParam.CellAddress));
                        paramSnapshot.Remove(orphanParam);
                    }
                }
                TryApplySingleCellDragRemap(layoutChangeHint);
                TryApplyStripAlignedDragRemap(layoutChangeHint);

                Boolean CellAddressOwnedByOther(DesignParamData owner, String candidateAddr)
                {
                    if (String.IsNullOrEmpty(candidateAddr) || owner == null)
                    {
                        return true;
                    }
                    foreach (DesignParamData p in paramSnapshot)
                    {
                        if (ReferenceEquals(p, owner))
                        {
                            continue;
                        }
                        // 結合セル D7:E8 と単一 D7 は AddrKeyEquals で同一扱いになるが、Excel 側のキーと一致させるには文字列完全一致が必要
                        if (String.Equals(p.CellAddress, candidateAddr, StringComparison.Ordinal))
                        {
                            // 行削除などで Excel から消えたパスは占有とみなさない
                            if (!PathExistsInExcel(p))
                            {
                                continue;
                            }
                            return true;
                        }
                    }
                    return false;
                }

                DesignParamData FindParamByExactCellAddress(String addr, DesignParamData exclude)
                {
                    if (String.IsNullOrEmpty(addr))
                    {
                        return null;
                    }
                    foreach (DesignParamData p in paramSnapshot)
                    {
                        if (ReferenceEquals(p, exclude))
                        {
                            continue;
                        }
                        if (String.Equals(p.CellAddress, addr, StringComparison.Ordinal))
                        {
                            return p;
                        }
                    }
                    return null;
                }

                String GetExcelPathAtAddress(String addr)
                {
                    if (String.IsNullOrEmpty(addr))
                    {
                        return null;
                    }
                    foreach (KeyValuePair<String, dynamic> kv in excelCellValues)
                    {
                        if (String.Equals(kv.Key, addr, StringComparison.Ordinal))
                        {
                            return NormalizePathKeyForRemap(Convert.ToString(kv.Value, CultureInfo.InvariantCulture));
                        }
                    }
                    // 結合セル H6:I6 は完全一致のみ。TopLeft のみの照合は単一セル用（H6 と H6:I6 の取り違え防止）
                    if (addr.IndexOf(':') < 0)
                    {
                        String addrNorm = TopLeftNorm(addr);
                        foreach (KeyValuePair<String, dynamic> kv in excelCellValues)
                        {
                            if (String.Equals(TopLeftNorm(kv.Key), addrNorm, StringComparison.OrdinalIgnoreCase))
                            {
                                return NormalizePathKeyForRemap(Convert.ToString(kv.Value, CultureInfo.InvariantCulture));
                            }
                        }
                    }
                    return null;
                }

                Int64 CellManhattanDistance(String addrA, String addrB)
                {
                    if (!TryParseCellTopLeft(addrA, out Int32 rA, out Int32 cA) || !TryParseCellTopLeft(addrB, out Int32 rB, out Int32 cB))
                    {
                        return Int64.MaxValue;
                    }
                    return Math.Abs(rA - rB) + Math.Abs(cA - cB);
                }

                Boolean IsLikelyCutMoveSource(DesignParamData p)
                {
                    if (p == null || String.IsNullOrWhiteSpace(p.CellAddress) || String.IsNullOrEmpty(p.DataPath))
                    {
                        return false;
                    }
                    String excelAt = GetExcelPathAtAddress(p.CellAddress);
                    if (String.IsNullOrEmpty(excelAt))
                    {
                        return true;
                    }
                    return !String.Equals(excelAt, NormalizePathKeyForRemap(p.DataPath), StringComparison.Ordinal);
                }

                DesignParamData FindIncomingParamForExcelAtDest(String destAddr, String destExcelPath)
                {
                    if (IsSingleCellDragLikeHint(layoutChangeHint))
                    {
                        DesignParamData cutSource = null;
                        Int64 cutSourceDist = -1;
                        foreach (DesignParamData p in paramSnapshot)
                        {
                            if (String.IsNullOrWhiteSpace(p.CellAddress) || String.Equals(p.CellAddress, destAddr, StringComparison.Ordinal))
                            {
                                continue;
                            }
                            if (!IsLikelyCutMoveSource(p))
                            {
                                continue;
                            }
                            Int64 d = CellManhattanDistance(p.CellAddress, destAddr);
                            if (d > cutSourceDist)
                            {
                                cutSourceDist = d;
                                cutSource = p;
                            }
                        }
                        if (cutSource != null)
                        {
                            return cutSource;
                        }
                    }

                    DesignParamData incoming = null;
                    Int64 bestDist = Int64.MaxValue;
                    foreach (DesignParamData p in paramSnapshot)
                    {
                        if (String.IsNullOrWhiteSpace(p.CellAddress))
                        {
                            continue;
                        }
                        if (!String.Equals(NormalizePathKeyForRemap(p.DataPath), destExcelPath, StringComparison.Ordinal))
                        {
                            continue;
                        }
                        if (String.Equals(p.CellAddress, destAddr, StringComparison.Ordinal))
                        {
                            continue;
                        }
                        Int64 d = CellManhattanDistance(p.CellAddress, destAddr);
                        if (d < bestDist)
                        {
                            bestDist = d;
                            incoming = p;
                        }
                    }
                    return incoming;
                }

                void TryApplyDragRemapToDest(String destAddr)
                {
                    if (String.IsNullOrEmpty(destAddr))
                    {
                        return;
                    }
                    String destExcelPath = GetExcelPathAtAddress(destAddr);
                    if (String.IsNullOrEmpty(destExcelPath))
                    {
                        return;
                    }
                    DesignParamData incoming = FindIncomingParamForExcelAtDest(destAddr, destExcelPath);
                    if (incoming == null || String.IsNullOrWhiteSpace(incoming.CellAddress))
                    {
                        return;
                    }
                    // コピー（元セルに同じ DataPath が残る）のときはパラメータを移動しない（H9→H5 コピーで H9 は据え置き、H5 は update で追加）
                    String excelAtIncomingOld = GetExcelPathAtAddress(incoming.CellAddress);
                    if (!String.IsNullOrEmpty(excelAtIncomingOld)
                        && String.Equals(excelAtIncomingOld, NormalizePathKeyForRemap(incoming.DataPath), StringComparison.Ordinal))
                    {
                        Boolean wIsCutDragToDest = IsSingleCellDragLikeHint(layoutChangeHint)
                            && TryInferCutDragSourceAndDest(layoutChangeHint, paramSnapshot, excelCellValues, out String dragSrc, out String dragDest)
                            && String.Equals(TopLeftNorm(dragDest), TopLeftNorm(destAddr), StringComparison.OrdinalIgnoreCase);
                        if (!wIsCutDragToDest)
                        {
#if DEBUG
                            //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] dragRemap skip copy-like source unchanged at {0}", incoming.CellAddress));
#endif
                            return;
                        }
                    }
#if DEBUG
                    //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] dragRemap dest={0} incomingOld={1}", destAddr, incoming.CellAddress));
#endif
                    if (FindParamByExactCellAddress(destAddr, incoming) != null)
                    {
                        TryResolveSwapForBlockedMove(incoming, destAddr);
                    }
                    else
                    {
                        TrySetCellAddressUnique(incoming, destAddr);
                    }
                }

                void TryApplySingleCellDragRemap(String hint)
                {
                    if (!useKeepAddressFirstForDuplicatePath || !IsSingleCellDragLikeHint(hint))
                    {
                        return;
                    }
                    if (TryInferCutDragSourceAndDest(hint, paramSnapshot, excelCellValues, out String inferredSrc, out String inferredDest))
                    {
                        DesignParamData incomingByInfer = FindParamByExactCellAddress(inferredSrc, null);
                        if (incomingByInfer != null)
                        {
                            DesignParamData blockerAtDest = FindParamByExactCellAddress(inferredDest, incomingByInfer);
                            if (blockerAtDest != null)
                            {
                                TryResolveSwapForBlockedMove(incomingByInfer, inferredDest);
                            }
                            else
                            {
                                TrySetCellAddressUnique(incomingByInfer, inferredDest);
                            }
                            return;
                        }
                    }
                    String dest = TopLeftNorm(hint.Trim().Split(':')[0]);
                    TryApplyDragRemapToDest(dest);
                }

                void TryApplyStripAlignedDragRemap(String hint)
                {
                    if (!useStripIdentityThenSortedRemainder || String.IsNullOrWhiteSpace(hint))
                    {
                        return;
                    }
                    String t = hint.Trim();
                    if (IsStripAlignedTwoCornerHint(t))
                    {
                        TryApplyDragRemapToDest(t);
                        return;
                    }
                    String[] parts = t.Split(':');
                    if (parts.Length == 4)
                    {
                        // 例: H5:I5:H6:I6（2 つの結合範囲）→ ドロップ先 H6:I6
                        String destMerge = parts[2] + ":" + parts[3];
                        if (IsStripAlignedTwoCornerHint(destMerge))
                        {
                            TryApplyDragRemapToDest(destMerge);
                        }
                    }
                }

                Boolean TryResolveSwapForBlockedMove(DesignParamData owner, String newAddr)
                {
                    if ((!useKeepAddressFirstForDuplicatePath && !useStripIdentityThenSortedRemainder && !useBulkAxisSortedIndexPairing)
                        || owner == null || String.IsNullOrEmpty(newAddr))
                    {
                        return false;
                    }
                    String ownerOld = owner.CellAddress;
                    if (String.IsNullOrEmpty(ownerOld) || String.Equals(ownerOld, newAddr, StringComparison.Ordinal))
                    {
                        return false;
                    }
                    DesignParamData blocker = FindParamByExactCellAddress(newAddr, owner);
                    if (blocker == null)
                    {
                        return false;
                    }
                    if (String.Equals(NormalizePathKeyForRemap(owner.DataPath), NormalizePathKeyForRemap(blocker.DataPath), StringComparison.Ordinal))
                    {
                        return false;
                    }
                    String excelAtNew = GetExcelPathAtAddress(newAddr);
                    if (String.IsNullOrEmpty(excelAtNew))
                    {
                        return false;
                    }
                    if (!String.Equals(excelAtNew, NormalizePathKeyForRemap(owner.DataPath), StringComparison.Ordinal))
                    {
                        return false;
                    }
                    String excelAtOwnerOld = GetExcelPathAtAddress(ownerOld);
                    String blockerPathNorm = NormalizePathKeyForRemap(blocker.DataPath);
                    Boolean ownerOldHasBlockerPath = !String.IsNullOrEmpty(excelAtOwnerOld)
                        && String.Equals(excelAtOwnerOld, blockerPathNorm, StringComparison.Ordinal);
                    Boolean ownerOldEmpty = String.IsNullOrEmpty(excelAtOwnerOld);
                    if (!ownerOldHasBlockerPath && !ownerOldEmpty)
                    {
#if DEBUG
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] swap skip thirdPartyAtOld old={0} excelOld={1}", ownerOld, excelAtOwnerOld));
#endif
                        return false;
                    }
                    if (ownerOldEmpty)
                    {
                        // cut-overwrite は単一セル切り取りドラッグ（D6→D8 等）専用。行・列の切り取り挿入では従来の入れ替えを維持
                        if (!IsSingleCellDragLikeHint(layoutChangeHint))
                        {
                            owner.CellAddress = newAddr;
                            blocker.CellAddress = ownerOld;
                            FixRepeatAddressAfterCellMove(owner);
                            FixRepeatAddressAfterCellMove(blocker);
                            return true;
                        }
                        // 切り取りで移動元が空: 入れ替えではなく上書き。占有していた blocker は削除（同一路径が他セルに残る場合はそちらを維持）
#if DEBUG
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture,
                        //    "[RemapDesignParam] cut-overwrite {0}->{1} evict {2} path={3}",
                        //    ownerOld, newAddr, blocker.CellAddress, blocker.DataPath));
#endif
                        owner.CellAddress = newAddr;
                        FixRepeatAddressAfterCellMove(owner);
                        if (!remapEvictedDeletes.Contains(blocker))
                        {
                            remapEvictedDeletes.Add(blocker);
                        }
                        paramSnapshot.Remove(blocker);
                        return true;
                    }
#if DEBUG
                    //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] swap {0}->{1} with {2}->{3} (excelOldEmpty={4})", ownerOld, newAddr, blocker.CellAddress, ownerOld, ownerOldEmpty));
#endif
                    owner.CellAddress = newAddr;
                    blocker.CellAddress = ownerOld;
                    FixRepeatAddressAfterCellMove(owner);
                    FixRepeatAddressAfterCellMove(blocker);
                    return true;
                }

                String FindExcelAddressForPathExcluding(String pathNorm, String excludeAddrA, String excludeAddrB)
                {
                    if (String.IsNullOrEmpty(pathNorm))
                    {
                        return null;
                    }
                    var matches = new List<String>();
                    foreach (KeyValuePair<String, dynamic> kv in excelCellValues)
                    {
                        if (!String.Equals(NormalizePathKeyForRemap(Convert.ToString(kv.Value, CultureInfo.InvariantCulture)), pathNorm, StringComparison.Ordinal))
                        {
                            continue;
                        }
                        matches.Add(kv.Key);
                    }
                    foreach (String a in matches.OrderBy(AddrSortKey))
                    {
                        if (String.IsNullOrEmpty(excludeAddrA) || !String.Equals(a, excludeAddrA, StringComparison.Ordinal))
                        {
                            if (String.IsNullOrEmpty(excludeAddrB) || !String.Equals(a, excludeAddrB, StringComparison.Ordinal))
                            {
                                return a;
                            }
                        }
                    }
                    return null;
                }

                /// <summary>
                /// 行の切り取り貼り付けなどで、貼り付け先に別パラメータが残っているとき占有者を Excel 上の正しいセルへ退避してから移動する。
                /// </summary>
                Boolean TryResolveBulkCutPasteBlockedMove(DesignParamData owner, String newAddr)
                {
                    if (!useBulkAxisSortedIndexPairing || owner == null || String.IsNullOrEmpty(newAddr))
                    {
                        return false;
                    }
                    String ownerOld = owner.CellAddress;
                    if (String.IsNullOrEmpty(ownerOld) || String.Equals(ownerOld, newAddr, StringComparison.Ordinal))
                    {
                        return false;
                    }
                    DesignParamData blocker = FindParamByExactCellAddress(newAddr, owner);
                    if (blocker == null)
                    {
                        return false;
                    }
                    String ownerPathNorm = NormalizePathKeyForRemap(owner.DataPath);
                    String excelAtNew = GetExcelPathAtAddress(newAddr);
                    if (String.IsNullOrEmpty(excelAtNew) || !String.Equals(excelAtNew, ownerPathNorm, StringComparison.Ordinal))
                    {
                        return false;
                    }
                    String excelAtOwnerOld = GetExcelPathAtAddress(ownerOld);
                    Boolean ownerCutSource = String.IsNullOrEmpty(excelAtOwnerOld)
                        || !String.Equals(excelAtOwnerOld, ownerPathNorm, StringComparison.Ordinal);
                    if (!ownerCutSource)
                    {
                        return false;
                    }
                    String blockerPathNorm = NormalizePathKeyForRemap(blocker.DataPath);
                    String relocate = FindExcelAddressForPathExcluding(blockerPathNorm, newAddr, ownerOld);
                    String blockerFrom = blocker.CellAddress;
                    Boolean evicted = false;
                    if (!String.IsNullOrEmpty(relocate) && !CellAddressOwnedByOther(blocker, relocate))
                    {
                        blocker.CellAddress = relocate;
                        FixRepeatAddressAfterCellMove(blocker);
                        evicted = true;
                    }
                    else if (String.IsNullOrEmpty(excelAtOwnerOld) && !CellAddressOwnedByOther(blocker, ownerOld))
                    {
                        relocate = ownerOld;
                        blocker.CellAddress = ownerOld;
                        FixRepeatAddressAfterCellMove(blocker);
                        evicted = true;
                    }
                    if (!evicted)
                    {
                        return false;
                    }
                    if (CellAddressOwnedByOther(owner, newAddr))
                    {
                        return false;
                    }
#if DEBUG
                    //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] bulkCutPaste {0}->{1} evict {2}->{3}", ownerOld, newAddr, blockerFrom, relocate));
#endif
                    owner.CellAddress = newAddr;
                    FixRepeatAddressAfterCellMove(owner);
                    return true;
                }

                /// <summary>
                /// 行・列の切り取り挿入などで複数パラメータが同時に循環移動するとき、
                /// 入れ替え条件（旧セルに第三者の Excel 値）を満たさず TrySetCellAddressUnique が全失敗するのを防ぐ。
                /// </summary>
                void ApplyBulkGlobalCellAddressMoves(IEnumerable<(DesignParamData param, String newAddr, Int64 oldKey)> orderedAssignments)
                {
                    if (orderedAssignments == null)
                    {
                        return;
                    }
                    List<(DesignParamData param, String newAddr)> pending = orderedAssignments
                        .Where(a => a.param != null && !String.IsNullOrEmpty(a.newAddr)
                            && !String.Equals(a.param.CellAddress, a.newAddr, StringComparison.Ordinal))
                        .Select(a => (a.param, a.newAddr))
                        .ToList();
                    if (pending.Count == 0)
                    {
                        return;
                    }
                    if (pending.Count == 1)
                    {
                        TrySetCellAddressUnique(pending[0].param, pending[0].newAddr);
                        return;
                    }
                    Boolean anyBlocked = pending.Any(a => CellAddressOwnedByOther(a.param, a.newAddr));
                    if (!anyBlocked)
                    {
                        foreach (var a in pending)
                        {
                            a.param.CellAddress = a.newAddr;
                            FixRepeatAddressAfterCellMove(a.param);
                        }
                        return;
                    }
                    var occupied = new HashSet<String>(StringComparer.Ordinal);
                    foreach (DesignParamData p in paramSnapshot)
                    {
                        if (!String.IsNullOrEmpty(p.CellAddress))
                        {
                            occupied.Add(p.CellAddress);
                        }
                    }
                    var staging = new List<(DesignParamData param, String finalAddr, String tempAddr)>();
                    Int32 stageSerial = 0;
                    foreach (var a in pending)
                    {
                        String tempAddr;
                        do
                        {
                            tempAddr = String.Format(CultureInfo.InvariantCulture, "XFD{0}", 1048576 - stageSerial);
                            stageSerial++;
                        } while (occupied.Contains(tempAddr));
                        occupied.Add(tempAddr);
                        if (!String.IsNullOrEmpty(a.param.CellAddress))
                        {
                            occupied.Remove(a.param.CellAddress);
                        }
                        staging.Add((a.param, a.newAddr, tempAddr));
                    }
#if DEBUG
                    //Console.WriteLine(String.Format(CultureInfo.InvariantCulture,
                    //    "[RemapDesignParam] bulkGlobalStage moves={0}", staging.Count));
#endif
                    foreach (var s in staging)
                    {
                        s.param.CellAddress = s.tempAddr;
                    }
                    foreach (var s in staging)
                    {
                        s.param.CellAddress = s.finalAddr;
                        FixRepeatAddressAfterCellMove(s.param);
                    }
                }

                Boolean TrySetCellAddressUnique(DesignParamData owner, String newAddr)
                {
                    if (owner == null || String.IsNullOrEmpty(newAddr))
                    {
                        return false;
                    }
                    if (String.Equals(owner.CellAddress, newAddr, StringComparison.Ordinal))
                    {
                        FixRepeatAddressAfterCellMove(owner);
                        return true;
                    }
                    if (!CellAddressOwnedByOther(owner, newAddr))
                    {
                        owner.CellAddress = newAddr;
                        FixRepeatAddressAfterCellMove(owner);
                        return true;
                    }
                    if (remapConflictNestDepth >= MAX_REMAP_CONFLICT_NEST)
                    {
#if DEBUG
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] TrySetCellAddressUnique nest limit: newAddr={0} ownerOldAddr={1}", newAddr, owner.CellAddress));
#endif
                        return false;
                    }
                    remapConflictNestDepth++;
                    try
                    {
                        if (TryResolveSwapForBlockedMove(owner, newAddr))
                        {
                            return true;
                        }
                        if (TryResolveBulkCutPasteBlockedMove(owner, newAddr))
                        {
                            return true;
                        }
#if DEBUG
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] TrySetCellAddressUnique blocked: newAddr={0} ownerOldAddr={1}", newAddr, owner.CellAddress));
#endif
                        return false;
                    }
                    finally
                    {
                        remapConflictNestDepth--;
                    }
                }

                var remapWorkList = new List<(List<DesignParamData> olds, List<String> newAddrs)>();
                foreach (IGrouping<String, DesignParamData> pathGroup in paramSnapshot.GroupBy(p => p.DataPath))
                {
                    String pathKeyNorm = NormalizePathKeyForRemap(pathGroup.Key);
                    if (!newByPath.TryGetValue(pathKeyNorm, out List<String> newAddrs))
                    {
#if DEBUG
                        //String wRawPreview = pathGroup.Key == null ? String.Empty : (pathGroup.Key.Length <= 120 ? pathGroup.Key : pathGroup.Key.Substring(0, 120) + "…");
                        //String wNormPreview = pathKeyNorm == null ? String.Empty : (pathKeyNorm.Length <= 120 ? pathKeyNorm : pathKeyNorm.Substring(0, 120) + "…");
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] SKIP no excel key: olds={0} rawLen={1} normLen={2} rawPreview={3} normPreview={4}", pathGroup.Count(), pathGroup.Key == null ? 0 : pathGroup.Key.Length, pathKeyNorm == null ? 0 : pathKeyNorm.Length, wRawPreview, wNormPreview));
#endif
                        continue;
                    }

                    List<DesignParamData> olds = pathGroup.OrderBy(p => AddrSortKey(p.CellAddress)).ToList();
                    if (olds.Count == 0)
                    {
                        continue;
                    }

                    remapWorkList.Add((olds, newAddrs));
                }

                if (useBulkAxisSortedIndexPairing)
                {
                    List<(List<DesignParamData> olds, List<String> newAddrs)> matchedBulk = remapWorkList
                        .Where(w => w.olds.Count == w.newAddrs.Count && w.olds.Count > 0)
                        .ToList();
                    if (matchedBulk.Count > 0)
                    {
                        // 行挿入（下へずれる）: 大きい旧アドレスから先に適用 / 行削除（上へずれる）: 小さい旧アドレスから先に適用
                        Boolean bulkShiftDown = matchedBulk.Any(w => AddrSortKey(w.newAddrs[0]) > AddrSortKey(w.olds[0].CellAddress));
                        Boolean bulkShiftUp = matchedBulk.Any(w => AddrSortKey(w.newAddrs[0]) < AddrSortKey(w.olds[0].CellAddress));
                        Boolean reverseBulkGlobal = bulkShiftDown && !bulkShiftUp;
                        var globalAssignments = new List<(DesignParamData param, String newAddr, Int64 oldKey)>();
                        foreach ((List<DesignParamData> olds, List<String> newAddrs) w in matchedBulk)
                        {
                            for (Int32 i = 0; i < w.olds.Count; i++)
                            {
                                globalAssignments.Add((w.olds[i], w.newAddrs[i], AddrSortKey(w.olds[i].CellAddress)));
                            }
                        }
#if DEBUG
                        //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] bulkGlobalApply reverse={0} assignments={1} pathGroups={2}", reverseBulkGlobal, globalAssignments.Count, matchedBulk.Count));
#endif
                        IEnumerable<(DesignParamData param, String newAddr, Int64 oldKey)> orderedAssignments = reverseBulkGlobal
                            ? globalAssignments.OrderByDescending(x => x.oldKey)
                            : globalAssignments.OrderBy(x => x.oldKey);
                        ApplyBulkGlobalCellAddressMoves(orderedAssignments);
                    }
                }

                foreach ((List<DesignParamData> olds, List<String> newAddrs) in remapWorkList)
                {
#if DEBUG
                    //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] pathGroup: olds={0} news={1} bulkAxis={2}", olds.Count, newAddrs.Count, useBulkAxisSortedIndexPairing));
#endif

                    void RemapSortedPairOnly(List<DesignParamData> unmappedList, List<String> freeNewsAddresses)
                    {
                        if (unmappedList == null || unmappedList.Count == 0)
                        {
                            return;
                        }
                        List<DesignParamData> um = unmappedList.OrderBy(p => AddrSortKey(p.CellAddress)).ToList();
                        List<String> ns = freeNewsAddresses.OrderBy(a => AddrSortKey(a)).ToList();
                        Int32 n = Math.Min(um.Count, ns.Count);
                        Boolean reverseApply = false;
                        if (n > 0)
                        {
                            Int64 oldKey0 = AddrSortKey(um[0].CellAddress);
                            Int64 newKey0 = AddrSortKey(ns[0]);
                            if (newKey0 > oldKey0)
                            {
                                reverseApply = true;
                            }
                        }
                        if (reverseApply)
                        {
                            for (Int32 i = n - 1; i >= 0; i--)
                            {
                                TrySetCellAddressUnique(um[i], ns[i]);
                            }
                        }
                        else
                        {
                            for (Int32 i = 0; i < n; i++)
                            {
                                TrySetCellAddressUnique(um[i], ns[i]);
                            }
                        }
                    }

                    void RemapStripIdentityFirstThenSortedRemainder()
                    {
                        var newsPool = new List<String>(newAddrs);
                        var unmappedOlds = new List<DesignParamData>();
                        foreach (DesignParamData param in olds)
                        {
                            Int32 keepIdx = -1;
                            for (Int32 i = 0; i < newsPool.Count; i++)
                            {
                                if (String.Equals(newsPool[i], param.CellAddress, StringComparison.Ordinal))
                                {
                                    keepIdx = i;
                                    break;
                                }
                            }
                            if (keepIdx >= 0)
                            {
                                String canonical = newsPool[keepIdx];
                                if (TrySetCellAddressUnique(param, canonical))
                                {
                                    newsPool.RemoveAt(keepIdx);
                                }
                            }
                            else
                            {
                                unmappedOlds.Add(param);
                            }
                        }
                        RemapSortedPairOnly(unmappedOlds, newsPool);
                    }

                    void RemapGreedyManhattan(List<DesignParamData> oldsToMap, List<String> newsPool)
                    {
                        foreach (DesignParamData param in oldsToMap.OrderBy(p => AddrSortKey(p.CellAddress)))
                        {
                            if (!TryParseCellTopLeft(param.CellAddress, out Int32 or, out Int32 oc))
                            {
                                continue;
                            }
                            Int32 bestI = -1;
                            Int32 bestD = Int32.MaxValue;
                            for (Int32 i = 0; i < newsPool.Count; i++)
                            {
                                if (!TryParseCellTopLeft(newsPool[i], out Int32 nr, out Int32 nc))
                                {
                                    continue;
                                }
                                Int32 d = Math.Abs(or - nr) + Math.Abs(oc - nc);
                                if (d < bestD)
                                {
                                    bestD = d;
                                    bestI = i;
                                }
                            }
                            if (bestI >= 0)
                            {
                                String newAddr = newsPool[bestI];
                                if (TrySetCellAddressUnique(param, newAddr))
                                {
                                    newsPool.RemoveAt(bestI);
                                }
                            }
                        }
                    }

                    if (useBulkAxisSortedIndexPairing)
                    {
                        if (olds.Count != newAddrs.Count)
                        {
#if DEBUG
                            //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] SKIP bulkAxis: olds={0} news={1}", olds.Count, newAddrs.Count));
#endif
                        }
                        continue;
                    }

                    if (olds.Count == 1 && newAddrs.Count == 1)
                    {
                        TrySetCellAddressUnique(olds[0], newAddrs[0]);
                        continue;
                    }

                    if (newAddrs.Count == 0)
                    {
                        continue;
                    }

                    if (useStripIdentityThenSortedRemainder)
                    {
                        if (olds.Count < newAddrs.Count)
                        {
                            // コピーで Excel 上の同一路径セルが増えただけ：既存パラメータは現アドレスのまま（identity のみ）
                            var newsPoolCopy = new List<String>(newAddrs);
                            foreach (DesignParamData param in olds)
                            {
                                Int32 keepIdx = -1;
                                for (Int32 i = 0; i < newsPoolCopy.Count; i++)
                                {
                                    if (String.Equals(newsPoolCopy[i], param.CellAddress, StringComparison.Ordinal))
                                    {
                                        keepIdx = i;
                                        break;
                                    }
                                }
                                if (keepIdx >= 0)
                                {
                                    newsPoolCopy.RemoveAt(keepIdx);
                                }
                            }
#if DEBUG
                            //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[RemapDesignParam] strip copy-like olds={0} news={1} freeNewAddrs={2}", olds.Count, newAddrs.Count, newsPoolCopy.Count));
#endif
                        }
                        else
                        {
                            RemapStripIdentityFirstThenSortedRemainder();
                        }
                    }
                    else if (useKeepAddressFirstForDuplicatePath)
                    {
                        var newsPool = new List<String>(newAddrs);
                        var unmappedOlds = new List<DesignParamData>();
                        foreach (DesignParamData param in olds)
                        {
                            Int32 keepIdx = -1;
                            for (Int32 i = 0; i < newsPool.Count; i++)
                            {
                                if (String.Equals(newsPool[i], param.CellAddress, StringComparison.Ordinal))
                                {
                                    keepIdx = i;
                                    break;
                                }
                            }
                            if (keepIdx >= 0)
                            {
                                String canonical = newsPool[keepIdx];
                                if (TrySetCellAddressUnique(param, canonical))
                                {
                                    newsPool.RemoveAt(keepIdx);
                                }
                            }
                            else
                            {
                                unmappedOlds.Add(param);
                            }
                        }
                        if (unmappedOlds.Count > 0)
                        {
                            RemapSortedPairOnly(unmappedOlds, newsPool);
                        }
                    }
                    else
                    {
                        var newsRemaining = new List<String>(newAddrs);
                        RemapGreedyManhattan(olds, newsRemaining);
                    }
                }
            }
            // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

            try
            {
                RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}開始", MSG_HEADER));

                if (this.dgvParamList.IsDisposed)
                {
                    return;
                }

                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                String wRemapLayoutChangeHint = aRangeAddress;
                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                #region " Range変更範囲の確認 "
                //Range変更範囲の確認
                string[] address = aRangeAddress.Split(':');
                string[] tempAddress = null;
                if (RldConst.SettingData.VAL_HAS_TEMPLETE_YES.Equals(RldLib.CurrentLayoutData.DesignSettingData.HasTemplete))
                {
                    //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
                    if (null != RldLib.CurrentLayoutData.DesignTempleteData && RldLib.CurrentLayoutData.DesignTempleteData.Range != "")
                    //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
                    {
                        tempAddress = RldLib.CurrentLayoutData.DesignTempleteData.Range.Split(':');
                    }
                }

                if (address.Length > 1)
                {
                    // add #8559 動作に関する指摘２ 邾 end
                    if (address[0] == address[1])
                    {
                        address[0] = "1";
                        address[1] = "1";
                    }
                    // add #8559 動作に関する指摘２ 邾 end
                    byte[] array = new byte[1];
                    array = System.Text.Encoding.ASCII.GetBytes(address[0]);
                    if (array[0] >= 65 && array[array.Length - 1] >= 65)
                    {
                        // mod 2023-04-12 #8417 鵬 start
                        //aRangeAddress = address[0] + ":" + "XFD";
                        aRangeAddress = "A:" + "XFD";
                        // mod 2023-04-12 #8417 鵬 end
                    }
                    else
                    {
                        if (array[0] >= 65)
                        {
                            aRangeAddress = "A1:XFD1048576";
                        }
                        else
                        {
                            // mod 2023-04-12 #8417 鵬 start
                            //aRangeAddress = address[0] + ":" + "1048576";
                            aRangeAddress = "1:" + "1048576";
                            // mod 2023-04-12 #8417 鵬 end
                        }
                    }
                }
                else
                {
                    aRangeAddress = "A1:XFD1048576";
                }
                #endregion

                Dictionary<String, dynamic> wChangedRangeManagedCellValueList;
                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                Boolean wSingleCellRemapHint = IsSingleCellDragLikeHint(wRemapLayoutChangeHint);
                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                var wUpdateList = new Dictionary<String, String>();     // Key:セルアドレス / Value:セル値
                var wDeleteList = new Dictionary<String, String>();     // Key:セルアドレス / Value:セル値
                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                var wRestoreExcelCellRefs = new Dictionary<String, String>(StringComparer.Ordinal); // Key:セルアドレス / Value:設計上の DataPath
                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end
                //#add #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる dongzhaolong start
                bool showRepeatMsg = false;
                //#add #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる dongzhaolong end
                dPdList.Clear();
                #region " 影響を受けるアイテムを追加する "
                // 影響を受けるアイテムを追加する
                // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                Excel.Range rng = RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange;
                String UsedAddress = "";
                if (rng != null)
                {
                    UsedAddress = rng.Address[false, false];
                }
                else
                {
                    UsedAddress = aRangeAddress;
                }
                using (var wXlSheetCells = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, UsedAddress))
                {
                    // 変更された範囲内の管理対象セルのアドレスと値を取得
                    wChangedRangeManagedCellValueList = wXlSheetCells.FindCellAddrValue(RldConst.PATH_HEADER, Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
                    // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end

                    List<DesignParamData> ParamList_temp = RldLib.CurrentLayoutData.DesignParamList.ToList();

                    // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                    Boolean wRowOnlyRemapHint = IsRowOnlyRangeHint(wRemapLayoutChangeHint);
                    Boolean wColumnOnlyRemapHint = IsColumnOnlyRangeHint(wRemapLayoutChangeHint);
                    Boolean wBulkAxisRemapHint = wRowOnlyRemapHint || wColumnOnlyRemapHint;
                    Boolean wStripAlignedRemapHint = IsStripAlignedTwoCornerHint(wRemapLayoutChangeHint);
                    RemapDesignParamCellAddressesToMatchExcel(ParamList_temp, wChangedRangeManagedCellValueList, wSingleCellRemapHint, wBulkAxisRemapHint, wStripAlignedRemapHint && !wRowOnlyRemapHint && !wColumnOnlyRemapHint, wRemapLayoutChangeHint);

                    foreach ((DesignParamData orphanParam, String originalAddress) in remapOrphanDeletes)
                    {
                        if (!wDeleteList.ContainsKey(originalAddress))
                        {
                            wDeleteList.Add(originalAddress, orphanParam.DataPath);
                        }
                    }

                    Boolean ShouldPreserveCellRefPathAgainstExcelAutoAdjust(
                        String paramDataPath, String excelCellValue, String paramCellAddress, String dragHint)
                    {
                        if (!TryParseSimpleCellReferencePath(paramDataPath, out String paramRef)
                            || !TryParseSimpleCellReferencePath(excelCellValue, out String excelRef))
                        {
                            return false;
                        }
                        if (String.Equals(paramRef, excelRef, StringComparison.OrdinalIgnoreCase))
                        {
                            return false;
                        }
                        if (TryInferCutDragSourceAndDest(dragHint, ParamList_temp, wChangedRangeManagedCellValueList, out String dragSrc, out String dragDest))
                        {
                            if (String.Equals(paramCellAddress, dragSrc, StringComparison.OrdinalIgnoreCase)
                                || String.Equals(paramCellAddress, dragDest, StringComparison.OrdinalIgnoreCase))
                            {
                                return false;
                            }
                            return String.Equals(paramRef, dragSrc, StringComparison.OrdinalIgnoreCase)
                                && String.Equals(excelRef, dragDest, StringComparison.OrdinalIgnoreCase);
                        }
                        return false;
                    }

                    Boolean ExcelCellMatchesParam(DesignParamData param)
                    {
                        if (param == null || String.IsNullOrWhiteSpace(param.CellAddress) || String.IsNullOrEmpty(param.DataPath))
                        {
                            return false;
                        }
                        String pathNorm = NormalizePathKeyForRemap(param.DataPath);
                        foreach (KeyValuePair<String, dynamic> kv in wChangedRangeManagedCellValueList)
                        {
                            if (!AddrKeyEquals(kv.Key, param.CellAddress))
                            {
                                continue;
                            }
                            if (!(kv.Value is string cellValue))
                            {
                                continue;
                            }
                            if (String.IsNullOrEmpty(cellValue) || !cellValue.StartsWith(RldConst.PATH_HEADER, StringComparison.Ordinal)
                                || cellValue.Equals(RldConst.PATH_HEADER) || cellValue.Equals(RldConst.CALC_HEADER))
                            {
                                continue;
                            }
                            if (String.Equals(NormalizePathKeyForRemap(cellValue), pathNorm, StringComparison.Ordinal))
                            {
                                return true;
                            }
                        }
                        return false;
                    }

                    var excelPathNorms = new HashSet<String>(StringComparer.Ordinal);
                    foreach (KeyValuePair<String, dynamic> wExcelKv in wChangedRangeManagedCellValueList)
                    {
                        if (!(wExcelKv.Value is string wExcelCv))
                        {
                            continue;
                        }
                        if (String.IsNullOrEmpty(wExcelCv) || !wExcelCv.StartsWith(RldConst.PATH_HEADER)
                            || wExcelCv.Equals(RldConst.PATH_HEADER) || wExcelCv.Equals(RldConst.CALC_HEADER))
                        {
                            continue;
                        }
                        excelPathNorms.Add(NormalizePathKeyForRemap(wExcelCv));
                    }
                    // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                    // mod #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                    foreach (string key in wChangedRangeManagedCellValueList.Keys)
                    {
                        //edit #9647 【デグレ】セルからデータ項目を消してもパラメータリストから消えない dongzhaolong start
                        //string cellValue = wChangedRangeManagedCellValueList[key];
                        string cellValue;
                        if (wChangedRangeManagedCellValueList[key] is string)
                        {
                            cellValue = wChangedRangeManagedCellValueList[key];
                        }
                        else
                        {
                            continue;
                        }
                        //edit #9647 【デグレ】セルからデータ項目を消してもパラメータリストから消えない dongzhaolong end

                        if (string.IsNullOrEmpty(cellValue) == false && cellValue.StartsWith(RldConst.PATH_HEADER)
                            && cellValue.Equals(RldConst.PATH_HEADER) == false && cellValue.Equals(RldConst.CALC_HEADER) == false)
                        {
                            bool keyIsExist = false;
                            for (int i = 0; i < ParamList_temp.Count; i++)
                            {
                                //位置合わせ
                                if (AddrKeyEquals(ParamList_temp[i].CellAddress, key))
                                {
                                    //if (cellValue.Equals(ParamList_temp[i].DataPath) == false)
                                    if (String.Equals(NormalizePathKeyForRemap(cellValue), NormalizePathKeyForRemap(ParamList_temp[i].DataPath), StringComparison.Ordinal) == false)
                                    {
                                        if (ShouldPreserveCellRefPathAgainstExcelAutoAdjust(
                                            ParamList_temp[i].DataPath, cellValue, key, wRemapLayoutChangeHint))
                                        {
                                            String wRestoreKey = ParamList_temp[i].CellAddress;
                                            if (!wRestoreExcelCellRefs.ContainsKey(wRestoreKey))
                                            {
                                                wRestoreExcelCellRefs.Add(wRestoreKey, ParamList_temp[i].DataPath);
                                            }
                                        }
                                        else
                                        {
                                            //存在&変更
                                            wUpdateList.Add(key, cellValue);
                                            dPdList.Add(ParamList_temp[i]);
                                        }
                                    }
                                    keyIsExist = true;
                                    break;
                                }
                            }
                            //存在しない
                            if (keyIsExist == false)
                            {
                                //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong start
                                if (!wUpdateList.ContainsKey(key))
                                {
                                    wUpdateList.Add(key, cellValue);
                                }
                                //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong end
                            }
                        }
                    }
                    for (int i = 0; i < ParamList_temp.Count; i++)
                    {
                        if (remapOrphanDeletes.Any(o => ReferenceEquals(o.Param, ParamList_temp[i]))
                            || remapEvictedDeletes.Any(p => ReferenceEquals(p, ParamList_temp[i])))
                        {
                            continue;
                        }

                        String paramPathNorm = NormalizePathKeyForRemap(ParamList_temp[i].DataPath);
                        if (!String.IsNullOrEmpty(paramPathNorm) && !excelPathNorms.Contains(paramPathNorm))
                        {
                            if (!String.IsNullOrEmpty(ParamList_temp[i].CellAddress)
                                && !wDeleteList.ContainsKey(ParamList_temp[i].CellAddress))
                            {
                                wDeleteList.Add(ParamList_temp[i].CellAddress, ParamList_temp[i].DataPath);
                            }
                            continue;
                        }

                        bool keyIsExist = false;
                        foreach (string key in wChangedRangeManagedCellValueList.Keys)
                        {
                            //位置合わせ
                            if (AddrKeyEquals(ParamList_temp[i].CellAddress, key))
                            {
                                string cellValue = wChangedRangeManagedCellValueList[key];
                                if ((string.IsNullOrEmpty(cellValue) == false && cellValue.StartsWith(RldConst.PATH_HEADER)
                                    && cellValue.Equals(RldConst.PATH_HEADER) == false && cellValue.Equals(RldConst.CALC_HEADER) == false))
                                {
                                    if (String.Equals(NormalizePathKeyForRemap(cellValue), paramPathNorm, StringComparison.Ordinal))
                                    {
                                        keyIsExist = true;
                                    }
                                }
                                break;
                            }
                        }
                        //存在しない
                        if (keyIsExist == false && !ExcelCellMatchesParam(ParamList_temp[i]))
                        {
                            //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong start
                            if (!String.IsNullOrEmpty(ParamList_temp[i].CellAddress)
                                && !wDeleteList.ContainsKey(ParamList_temp[i].CellAddress))
                            {
                                wDeleteList.Add(ParamList_temp[i].CellAddress, ParamList_temp[i].DataPath);
                            }
                            //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong end
                        }
                    }
                    // mod #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                    //#add #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる dongzhaolong start
                    int repeatCount = 0;
                    if (wUpdateList.Count > 0)
                    {
                        foreach (var item in ParamList_temp)
                        {
                            if (showRepeatMsg == false)
                            {
                                foreach (var updateItem in wUpdateList)
                                {
                                    if (updateItem.Value == item.DataPath && int.TryParse(item.RepeatCount, out repeatCount) && repeatCount > 1)
                                    {
                                        // 繰り返し設定の警告は、現在操作中の4画面上に通常表示する。
                                        MessageBox.Show(this, "この編集によって「繰り返し」設定が初期化されるデータ項目があります。設定を再確認してください。", "繰り返し数が初期化される", MessageBoxButtons.OK, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button1);
                                        showRepeatMsg = true;
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                    //#add #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる dongzhaolong end
                }

                #endregion

                // mod #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                // 変更内容を適用
                RldLib.CurrentLayoutData.DesignParamList.ListChanged -= new ListChangedEventHandler(this.DesignParamList_ListChanged);
                try
                {
                    foreach (DesignParamData evictedParam in remapEvictedDeletes)
                    {
                        if (evictedParam == null)
                        {
                            continue;
                        }
                        for (Int32 wi = RldLib.CurrentLayoutData.DesignParamList.Count - 1; wi >= 0; wi--)
                        {
                            if (ReferenceEquals(RldLib.CurrentLayoutData.DesignParamList[wi], evictedParam))
                            {
                                RldLib.CurrentLayoutData.RemoveDesignParamData(RldLib.CurrentLayoutData.DesignParamList[wi]);
                                break;
                            }
                        }
                    }
                }
                finally
                {
                    RldLib.CurrentLayoutData.DesignParamList.ListChanged += new ListChangedEventHandler(this.DesignParamList_ListChanged);
                }
                this.UpdateBindingListItem(wDeleteList, true);
                this.UpdateBindingListItem(wUpdateList, false);
                if (wRestoreExcelCellRefs.Count > 0)
                {
                    Boolean wPrevHandleLayoutEvent = RldLib.XlHelper.IsHandleLayoutSheetEvent;
                    RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
                    try
                    {
                        foreach (KeyValuePair<String, String> wRestoreKv in wRestoreExcelCellRefs)
                        {
                            DesignParamData wRestoreParam = RldLib.CurrentLayoutData.FindDesignParamData(wRestoreKv.Key);
                            String wRestoreAddr = wRestoreParam != null ? wRestoreParam.CellAddress : wRestoreKv.Key;
                            if (!String.IsNullOrWhiteSpace(wRestoreAddr))
                            {
                                RldLib.XlHelper.XlSheetLayout.Worksheet.Range[wRestoreAddr].Value = wRestoreKv.Value;
                            }
                        }
                    }
                    finally
                    {
                        RldLib.XlHelper.IsHandleLayoutSheetEvent = wPrevHandleLayoutEvent;
                    }
                }
                String wDragSourceCellNorm = null;
                String wDragDestUnused = null;
                if (wSingleCellRemapHint
                    && TryInferCutDragSourceAndDest(
                        wRemapLayoutChangeHint,
                        RldLib.CurrentLayoutData.DesignParamList,
                        wChangedRangeManagedCellValueList,
                        out wDragSourceCellNorm,
                        out wDragDestUnused))
                {
                    RestoreExcelSimpleCellRefsPointingTo(wDragSourceCellNorm);
                }
                // mod #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                // del #11501 レイアウトデザイナのユーザビリティ改善 高 start
                //dgvParamList.Visible = true;
                // del #11501 レイアウトデザイナのユーザビリティ改善 高 end
#if DEBUG
                Console.WriteLine(string.Format("{0} ok {1}   - {2} ", DateTime.Now, wDeleteList.Count, wUpdateList.Count));
                if (wDeleteList.Count > 0)
                {
                    foreach (var wKeyValue in wDeleteList)
                    {
                        Console.WriteLine(string.Format("{0} delete {1} - {2} ", DateTime.Now, wKeyValue.Key, wKeyValue.Value));
                    }
                }
                if (wUpdateList.Count > 0)
                {
                    foreach (var wKeyValue in wUpdateList)
                    {
                        Console.WriteLine(string.Format("{0} update {1} - {2} ", DateTime.Now, wKeyValue.Key, wKeyValue.Value));
                    }
                }
#endif
            }
            catch (Exception ex)
            {
                RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}失敗", MSG_HEADER));
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}終了", MSG_HEADER));
            }
        }


        ///// <summary>
        ///// 指定された Excel のセル範囲のデータでバインディングリストを更新します。
        ///// </summary>
        ///// <param name="aRangeAddress">更新するセル範囲</param>
        //private void UpdateBindingList(String aRangeAddress)
        //{
        //    const String MSG_HEADER = "パラメータデータ用バインディングリストの更新";

        //    try
        //    {
        //        RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}開始", MSG_HEADER));

        //        // add 2021-03-22 バグ修正 趙 start
        //        if (this.dgvParamList.IsDisposed)
        //        {
        //            return;
        //        }
        //        // add 2021-03-22 バグ修正 趙 end

        //        // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
        //        string[] address = aRangeAddress.Split(':');
        //        string[] tempAddress = null;
        //        if (RldConst.SettingData.VAL_HAS_TEMPLETE_YES.Equals(RldLib.CurrentLayoutData.DesignSettingData.HasTemplete))
        //        {
        //        	//add 6720 EXCEL関数で使用できないものがある 吉 start
        //            if (null != RldLib.CurrentLayoutData.DesignTempleteData)
        //            {
        //            	//add 6720 EXCEL関数で使用できないものがある 吉 end
        //                tempAddress = RldLib.CurrentLayoutData.DesignTempleteData.Range.Split(':');
        //            //add 6720 EXCEL関数で使用できないものがある 吉 start
        //            }
        //            //add 6720 EXCEL関数で使用できないものがある 吉 end                 
        //        }

        //        // add 2021-03-23 バグ修正 趙 start
        //        int rows0 = 0;
        //        // add 2021-03-23 バグ修正 趙 end

        //        int rows = 0;
        //        dPdList.Clear();
        //        Boolean templeteFlg = false;
        //        if (address.Length >1)
        //        {
        //            byte[] array = new byte[1];
        //            array = System.Text.Encoding.ASCII.GetBytes(address[0]);
        //            if (array[0] >= 65 && array[array.Length -1] >= 65) {                       
        //                aRangeAddress = address[0] + ":" + "XFD";
        //                if (tempAddress != null && (ToIndex(Column(address[0])) <= ToIndex(Column(tempAddress[1]))))
        //                {
        //                    templeteFlg = true;
        //                }                        
        //            }
        //            else
        //            {
        //                if (array[0] >= 65){
        //                    aRangeAddress = "A1:XFD1048576";
        //                    if (tempAddress != null && 
        //                        (((Convert.ToInt32(Regex.Replace(address[0], @"[^0-9]+", "")) <=
        //                        Convert.ToInt32(Regex.Replace(tempAddress[0], @"[^0-9]+", ""))) &&
        //                        (Convert.ToInt32(Regex.Replace(address[1], @"[^0-9]+", "")) >=
        //                        Convert.ToInt32(Regex.Replace(tempAddress[1], @"[^0-9]+", "")))) ||
        //                        ((ToIndex(Column(address[0])) <= ToIndex(Column(tempAddress[0]))) &&
        //                        (ToIndex(Column(address[1])) >= ToIndex(Column(tempAddress[1]))))))
        //                    {
        //                        templeteFlg = true;
        //                    }
        //                }
        //                else
        //                {
        //                    aRangeAddress = address[0] + ":" + "1048576";
        //                    if (tempAddress != null && 
        //                        (Convert.ToInt32(Regex.Replace(address[0], @"[^0-9]+", "")) <= 
        //                        Convert.ToInt32(Regex.Replace(tempAddress[1], @"[^0-9]+", ""))))
        //                    {
        //                        templeteFlg = true;
        //                    }
        //                }                        
        //            }                    
        //        }
        //        else
        //        {
        //            aRangeAddress = "A1:XFD1048576";
        //        }
        //        // add 2020-10-29 FNSI-改修 637バグの修正 夏 end

        //        Dictionary<String, dynamic> wChangedRangeManagedCellValueList;
        //        var wManagedDataList = new List<DesignParamData>();

        //        // 影響を受けるアイテムをwManagedDataListに追加する
        //        using (var wXlSheetCells = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, aRangeAddress))
        //        {

        //            // 変更された範囲内の管理対象セルのアドレスと値を取得
        //            wChangedRangeManagedCellValueList = wXlSheetCells.FindCellAddrValue(
        //                RldConst.PATH_HEADER, Type.Missing, Excel.XlFindLookIn.xlValues, Excel.XlLookAt.xlPart, Excel.XlSearchOrder.xlByRows, Excel.XlSearchDirection.xlNext, false, Type.Missing, Type.Missing);
        //            // mod #8314 グループタブの表示不正 王占宇 start
        //            //// add #8335 FNW帳票取込みの動作に問題あり 夏 start
        //            //if (RldLib.CurrentLayoutData.DesignParamList.Count > 0 &&
        //            //    wChangedRangeManagedCellValueList.Count != RldLib.CurrentLayoutData.DesignParamList.Count)
        //            //{
        //            //    wChangedRangeManagedCellValueList = new Dictionary<string, dynamic>();
        //            //    foreach (var wRetData in RldLib.CurrentLayoutData.DesignParamList)
        //            //    {
        //            //        wChangedRangeManagedCellValueList.Add(wRetData.CellAddress, wRetData.DataPath);
        //            //    }
        //            //}
        //            //// add #8335 FNW帳票取込みの動作に問題あり 夏 end
        //            // add #8335 FNW帳票取込みの動作に問題あり 夏 start
        //            Dictionary<String, dynamic> wChangedRangeManagedCellValueListNew = new Dictionary<string, dynamic>();
        //            Boolean bChangedFlg = false;
        //            // add #8335 FNW帳票取込みの動作に問題あり 夏 end
        //            using (var wXlSheetCells1 = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, address[0]))
        //            {
        //                string strCellValue2 = wXlSheetCells1.GetValue2();

        //                List<DesignParamData> tempList = RldLib.CurrentLayoutData.DesignParamList.ToList();
        //                // mod #8335 FNW帳票取込みの動作に問題あり 夏 start
        //                //if (tempList.Where(p => p.CellAddress == address[0] && p.DataPath == strCellValue2).ToList().Count > 0)
        //                //{
        //                //    wChangedRangeManagedCellValueList = new Dictionary<string, dynamic>();
        //                //    foreach (var wRetData in RldLib.CurrentLayoutData.DesignParamList)
        //                //    {
        //                //        wChangedRangeManagedCellValueList.Add(wRetData.CellAddress, wRetData.DataPath);
        //                //    }
        //                //}
        //                for (int i = 0; i < tempList.Count; i++)
        //                {
        //                    // mod #8475 【レポートレイアウトデザイナ】エクセルにドラッグされた項目の問題 xiaosonglei start
        //                    //if (tempList[i].CellAddress == address[0])
        //                    if ((address.Length == 1 && tempList[i].CellAddress == address[0]) ||
        //                        (address.Length == 2 && tempList[i].CellAddress == address[0] + ":" + address[1]))
        //                    // mod #8475 【レポートレイアウトデザイナ】エクセルにドラッグされた項目の問題 xiaosonglei end
        //                    {
        //                        //if (!(RldConst.PATH_HEADER).Equals(strCellValue2) && !(RldConst.CALC_HEADER).Equals(strCellValue2) && !string.IsNullOrEmpty(strCellValue2))

        //                        if (!(RldConst.PATH_HEADER).Equals(strCellValue2) && !(RldConst.CALC_HEADER).Equals(strCellValue2) && !string.IsNullOrEmpty(strCellValue2))
        //                        {
        //                            tempList[i].DataPath = strCellValue2;
        //                            foreach (var wRetData in RldLib.CurrentLayoutData.DesignParamList)
        //                            {
        //                                wChangedRangeManagedCellValueListNew.Add(wRetData.CellAddress, wRetData.DataPath);
        //                            }
        //                        }
        //                        else
        //                        {
        //                            foreach (var wRetData in RldLib.CurrentLayoutData.DesignParamList)
        //                            {
        //                                if (wRetData.CellAddress != tempList[i].CellAddress)
        //                                {
        //                                    wChangedRangeManagedCellValueListNew.Add(wRetData.CellAddress, wRetData.DataPath);
        //                                }
        //                            }
        //                        }
        //                        bChangedFlg = true;
        //                        break;
        //                    }
        //                }
        //                // mod #8335 FNW帳票取込みの動作に問題あり 夏 end
        //            }
        //            // add #8335 FNW帳票取込みの動作に問題あり 夏 start
        //            if (!bChangedFlg && wChangedRangeManagedCellValueListNew.Count == 0 && wChangedRangeManagedCellValueList.Count > 0)
        //            {
        //                foreach (var wRetData in RldLib.CurrentLayoutData.DesignParamList)
        //                {
        //                    wChangedRangeManagedCellValueListNew.Add(wRetData.CellAddress, wRetData.DataPath);
        //                }
        //            }
        //            foreach (string key in wChangedRangeManagedCellValueList.Keys)
        //            {
        //                if (!wChangedRangeManagedCellValueListNew.ContainsKey(key) &&
        //                    !(RldConst.PATH_HEADER).Equals(wChangedRangeManagedCellValueList[key]) &&
        //                    !(RldConst.CALC_HEADER).Equals(wChangedRangeManagedCellValueList[key]))
        //                    wChangedRangeManagedCellValueListNew.Add(key, wChangedRangeManagedCellValueList[key]);
        //            }
        //            wChangedRangeManagedCellValueList = wChangedRangeManagedCellValueListNew;
        //            // add #8335 FNW帳票取込みの動作に問題あり 夏 end
        //            // mod #8314 グループタブの表示不正 王占宇 end
        //            // 変更された範囲に含まれているバインディングリストアイテムを取得
        //            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
        //            {

        //                // 影響を受けるアイテムならばwManagedDataListに追加する
        //                using (var wXlParamCell = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
        //                {
        //                    // 影響を受けるアイテムならばwManagedDataListに追加する
        //                    if (RldLib.XlHelper.XlApp.Application.Intersect(wXlParamCell.Range, wXlSheetCells.Range) != null)
        //                    {
        //                        wManagedDataList.Add(wData);
        //                    }
        //                }

        //            }
        //        }

        //        // 管理対象データがない場合は抜ける
        //        if (wChangedRangeManagedCellValueList.Count <= 0 && wManagedDataList.Count <= 0)
        //        {
        //            return;
        //        }

        //        // セルのアドレスを変換する
        //        var wBuf = new Dictionary<String, dynamic>();
        //        foreach (var wItem in wChangedRangeManagedCellValueList)
        //        {
        //            using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wItem.Key))
        //            {
        //                // CountLarge が 1 ならば wXlRange.Range.MergeArea.Address[false, false] を、1でないならば wXlRange.Range.Address[false, false] をキーにしてwBufに追加する
        //                wBuf.Add(wXlRange.Range.CountLarge == 1 ? wXlRange.Range.MergeArea.Address[false, false] : wXlRange.Range.Address[false, false], wItem.Value);
        //            }
        //        }

        //        wChangedRangeManagedCellValueList = wBuf;

        //        var wUpdateList = new Dictionary<String, String>();     // Key:セルアドレス / Value:セル値
        //        var wDeleteList = new Dictionary<String, String>();     // Key:セルアドレス / Value:セル値

        //        foreach (var wParam in wManagedDataList)
        //        {
        //            // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
        //            foreach (var wKeyValue in wChangedRangeManagedCellValueList)
        //            {
        //                // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
        //                //if (wParam.DataPath.Equals(wKeyValue.Value))
        //                if (wParam.CellAddress.Equals(wKeyValue.Key))
        //                // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
        //                {
        //                    Boolean addFlg = false;
        //                    // upd 2021-03-18 バグ修正 趙 start
        //                    //int row = Convert.ToInt32(Regex.Replace(wParam.CellAddress, @"[^0-9]+", ""));
        //                    //int afterRow = Convert.ToInt32(Regex.Replace(wKeyValue.Key, @"[^0-9]+", ""));
        //                    int row0 = 0;
        //                    int afterRow0 = 0;
        //                    if (new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wParam.CellAddress).Value != "")
        //                    {
        //                        row0 = Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wParam.CellAddress).Value);
        //                        afterRow0 = Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wKeyValue.Key).Value);
        //                    }
        //                    int row = Convert.ToInt32(new Regex(@"[0-9]+\z").Match(wParam.CellAddress).Value);
        //                    int afterRow = Convert.ToInt32(new Regex(@"[0-9]+\z").Match(wKeyValue.Key).Value);
        //                    // upd 2021-03-18 バグ修正 趙 end
        //                    int column = ToIndex(Column(wParam.CellAddress));
        //                    int afterColumn = ToIndex(Column(wKeyValue.Key));

        //                    // add 2021-05-20 内部バグ修正 趙 start
        //                    int columns = 0;
        //                    if (afterColumn != column)
        //                    {
        //                        columns = afterColumn - column;
        //                    }
        //                    else
        //                    {
        //                        columns = 0;
        //                    }
        //                    // add 2021-05-20 内部バグ修正 趙 end

        //                    // add 2021-03-23 バグ修正 趙 start
        //                    if (afterRow0 != row0)
        //                    {
        //                        rows0 = afterRow0 - row0;
        //                    }
        //                    else
        //                    {
        //                        rows0 = 0;
        //                    }
        //                    // add 2021-03-23 バグ修正 趙 end
        //                    if (afterRow != row)
        //                    {
        //                        rows = afterRow - row;
        //                    }
        //                    else
        //                    {
        //                        rows = 0;
        //                    }
        //                    if (afterRow != row && afterColumn != column)
        //                    {
        //                        foreach (var wParamOld in wManagedDataList)
        //                        {
        //                            if (wKeyValue.Key.Equals(wParamOld.CellAddress) && wKeyValue.Value.Equals(wParamOld.DataPath))
        //                            {
        //                                addFlg = true;
        //                                break;
        //                            }
        //                        }
        //                    }
        //                    if (addFlg == false)
        //                    {
        //                        if (!String.IsNullOrEmpty(wParam.RepeatCount))
        //                        {
        //                            string[] ra = wParam.RepeatAddress.Split(',');
        //                            for (int i = 0; i < ra.Length; i++)
        //                            {
        //                                // upd 2021-03-15 バグ修正 趙 start
        //                                //string fixtype = new Regex(@"[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                //ra[i] = fixtype + (Convert.ToInt32(Regex.Replace(ra[i], @"[^0-9]+", "")) + rows).ToString();

        //                                // upd 2021-05-20 内部バグ修正 趙 start
        //                                //string fixtype1 = new Regex(@"[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                //string fixtype2 = string.Empty;
        //                                //string fixtype3 = string.Empty;
        //                                //if (new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(ra[i]).Value != "")
        //                                //{
        //                                //    fixtype2 = (Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(ra[i]).Value) + rows0).ToString();
        //                                //    fixtype3 = new Regex(@":[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                //}
        //                                //string fixtype4 = (Convert.ToInt32(new Regex(@"[0-9]+\z").Match(ra[i]).Value) + rows).ToString();
        //                                //ra[i] = fixtype1 + fixtype2 + fixtype3 + fixtype4;
        //                                string fixtype1 = ToName(ToIndex(new Regex(@"[a-zA-Z]+").Match(ra[i]).Value) + columns);
        //                                string fixtype2 = string.Empty;
        //                                string fixtype3 = string.Empty;
        //                                if (new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(ra[i]).Value != "")
        //                                {
        //                                    fixtype2 = (Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(ra[i]).Value) + rows0).ToString();
        //                                    string str = new Regex(@":[a-zA-Z]+").Match(ra[i]).Value;
        //                                    fixtype3 = ":" + ToName(ToIndex(new Regex(@"[a-zA-Z]+").Match(str).Value) + columns);
        //                                }
        //                                string fixtype4 = (Convert.ToInt32(new Regex(@"[0-9]+\z").Match(ra[i]).Value) + rows).ToString();
        //                                ra[i] = fixtype1 + fixtype2 + fixtype3 + fixtype4;
        //                                // upd 2021-05-20 内部バグ修正 趙 end

        //                                // upd 2021-03-15 バグ修正 趙 end
        //                            }
        //                            wParam.RepeatAddress = string.Join(",", ra);
        //                        }
        //                        DesignParamData wData = new DesignParamData(wParam);
        //                        wData.CellAddress = wKeyValue.Key;
        //                        wData.ButtonEditFormatConditionText = wParam.ButtonEditFormatConditionText;
        //                        wData.FilterState = wParam.FilterState;
        //                        wData.FormatCondition = wParam.FormatCondition;
        //                        dPdList.Add(wData);
        //                        wChangedRangeManagedCellValueList.Remove(wKeyValue.Key);
        //                        wUpdateList.Add(wKeyValue.Key, wKeyValue.Value as String);
        //                        if (templeteFlg == true)
        //                        {

        //                            int rowCount, columnCount = 0;
        //                            using (var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell)
        //                            {
        //                                using (var wXlRows = new ExcelRangeEx(wXlRange.Range.Rows))
        //                                using (var wXlColumns = new ExcelRangeEx(wXlRange.Range.Columns))
        //                                {
        //                                    rowCount = wXlRows.Range.Count;
        //                                    columnCount = wXlColumns.Range.Count;
        //                                }

        //                                if (rowCount == 1048576 ||
        //                                    ((Convert.ToInt32(Regex.Replace(address[0], @"[^0-9]+", "")) <=
        //                                    Convert.ToInt32(Regex.Replace(tempAddress[0], @"[^0-9]+", ""))) &&
        //                                    (Convert.ToInt32(Regex.Replace(address[1], @"[^0-9]+", "")) >=
        //                                    Convert.ToInt32(Regex.Replace(tempAddress[1], @"[^0-9]+", "")))))
        //                                {
        //                                    String strColumns = "";
        //                                    if (afterColumn < column)
        //                                    {
        //                                        columnCount = -columnCount;
        //                                    }
        //                                    if (ToIndex(Column(address[0])) > ToIndex(Column(tempAddress[0])))
        //                                    {
        //                                        strColumns = ToName(ToIndex(Column(tempAddress[0])));
        //                                    }
        //                                    else
        //                                    {
        //                                        strColumns = ToName(ToIndex(Column(tempAddress[0])) + columnCount);
        //                                    }
        //                                    RldLib.CurrentLayoutData.DesignTempleteData.Range =
        //                                    strColumns +
        //                                    Convert.ToInt32(Regex.Replace(tempAddress[0], @"[^0-9]+", "")).ToString() +
        //                                    ":" +
        //                                    ToName(ToIndex(Column(tempAddress[1])) + columnCount) +
        //                                    Convert.ToInt32(Regex.Replace(tempAddress[1], @"[^0-9]+", "")).ToString();
        //                                    // upd 2021-03-23 バグ修正 趙 start
        //                                    //RldLib.CurrentLayoutData.DesignTempleteData.RangeColumnNo = ToIndex(strColumns);
        //                                    RldLib.CurrentLayoutData.DesignTempleteData.RangeColumnNo = ToIndex(strColumns) + 1;
        //                                    // upd 2021-03-23 バグ修正 趙 end

        //                                    // add 2021-03-23 バグ修正 趙 start
        //                                    // 列数を取得
        //                                    RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount = ToIndex(Column(tempAddress[1])) + columnCount - ToIndex(strColumns) + 1;
        //                                    // add 2021-03-23バグ修正 趙 end
        //                                }
        //                                if (columnCount == 16384 ||
        //                                    ((ToIndex(Column(address[0])) <= ToIndex(Column(tempAddress[0]))) &&
        //                                    (ToIndex(Column(address[1])) >= ToIndex(Column(tempAddress[1])))))
        //                                {
        //                                    String strRows = "";
        //                                    if (afterRow < row)
        //                                    {
        //                                        rowCount = -rowCount;
        //                                    }
        //                                    if (Convert.ToInt32(Regex.Replace(address[0], @"[^0-9]+", "")) > Convert.ToInt32(Regex.Replace(tempAddress[0], @"[^0-9]+", "")))
        //                                    {
        //                                        strRows = Convert.ToInt32(Regex.Replace(tempAddress[0], @"[^0-9]+", "")).ToString();
        //                                    }
        //                                    else
        //                                    {
        //                                        strRows = (Convert.ToInt32(Regex.Replace(tempAddress[0], @"[^0-9]+", "")) + rowCount).ToString();
        //                                    }
        //                                    RldLib.CurrentLayoutData.DesignTempleteData.Range =
        //                                    Column(tempAddress[0]) +
        //                                    strRows +
        //                                    ":" +
        //                                    Column(tempAddress[1]) +
        //                                    (Convert.ToInt32(Regex.Replace(tempAddress[1], @"[^0-9]+", "")) + rowCount).ToString();
        //                                    RldLib.CurrentLayoutData.DesignTempleteData.RangeRowNo = Convert.ToInt32(strRows);

        //                                    // add 2021-03-23 バグ修正 趙 start
        //                                    // 行数を取得
        //                                    RldLib.CurrentLayoutData.DesignTempleteData.RowCount = Convert.ToInt32(Regex.Replace(tempAddress[1], @"[^0-9]+", "")) + rowCount - Convert.ToInt32(strRows) + 1;
        //                                    // add 2021-03-23バグ修正 趙 end
        //                                }
        //                            }

        //                            FormCollection collection = Application.OpenForms;
        //                            frmDesignChildLayoutTemplete frmTemp = null;
        //                            foreach (Form form in collection)
        //                            {
        //                                if ("frmDesignChildLayoutTemplete".Equals(form.Name))
        //                                {
        //                                    frmTemp = (frmDesignChildLayoutTemplete)form;
        //                                    break;
        //                                }
        //                            }
        //                            if (frmTemp != null)
        //                            {
        //                                frmTemp.FormRefresh();
        //                            }
        //                            templeteFlg = false;
        //                        }
        //                        break;
        //                    }
        //                }
        //            }
        //            // add 2020-10-29 FNSI-改修 637バグの修正 夏 end

        //            // レイアウトシート内に該当データが存在する場合
        //            // mod 2020-10-29 FNSI-改修 637バグの修正 夏 start
        //            //if (wChangedRangeManagedCellValueList.ContainsKey(wParam.CellAddress))
        //            if (wChangedRangeManagedCellValueList.ContainsKey(wParam.CellAddress) && dPdList.Count == 0)
        //            // mod 2020-10-29 FNSI-改修 637バグの修正 夏 end
        //            {

        //                String wCellValue = wChangedRangeManagedCellValueList[wParam.CellAddress] as String;

        //                // セルの内容とデータパスが一致しない場合はデータ作成用リストへ追加
        //                if (wParam.DataPath != wCellValue)
        //                {
        //                    wUpdateList.Add(wParam.CellAddress, wCellValue);
        //                }

        //                // 管理対象セルから処理済みのアドレスを削除
        //                wChangedRangeManagedCellValueList.Remove(wParam.CellAddress);
        //            }
        //            // レイアウトシート内に該当データが存在しない場合はデータ削除用リストへ追加
        //            else
        //            {
        //                wDeleteList.Add(wParam.CellAddress, wParam.DataPath);

        //            }

        //        }

        //        // 残った管理対象セルリストのデータをバインディングリストへ追加
        //        foreach (var wKeyValue in wChangedRangeManagedCellValueList)
        //        {
        //            // mod 2020-10-29 FNSI-改修 637バグの修正 夏 start
        //            //wUpdateList.Add(wKeyValue.Key, wKeyValue.Value as String);
        //            foreach (var wParam in wManagedDataList)
        //            {
        //                if (wParam.DataPath.Equals(wKeyValue.Value))
        //                {
        //                    Boolean addFlg = false;
        //                    // upd 2021-03-18 バグ修正 趙 start
        //                    //int row = Convert.ToInt32(Regex.Replace(wParam.CellAddress, @"[^0-9]+", ""));
        //                    //int afterRow = Convert.ToInt32(Regex.Replace(wKeyValue.Key, @"[^0-9]+", ""));
        //                    int row0 = 0;
        //                    int afterRow0 = 0;
        //                    int count = 0;
        //                    if (new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wParam.CellAddress).Value != "")
        //                    {
        //                        row0 = Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wParam.CellAddress).Value);
        //                        afterRow0 = Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wKeyValue.Key).Value);
        //                    }
        //                    int row = Convert.ToInt32(new Regex(@"[0-9]+\z").Match(wParam.CellAddress).Value);
        //                    int afterRow = Convert.ToInt32(new Regex(@"[0-9]+\z").Match(wKeyValue.Key).Value);
        //                    // upd 2021-03-18 バグ修正 趙 end
        //                    int column = ToIndex(Column(wParam.CellAddress));
        //                    int afterColumn = ToIndex(Column(wKeyValue.Key));

        //                    // add 2021-05-20 内部バグ修正 趙 start
        //                    int columns = 0;
        //                    if (afterColumn != column)
        //                    {
        //                        columns = afterColumn - column;
        //                    }
        //                    else
        //                    {
        //                        columns = 0;
        //                    }
        //                    // add 2021-05-20 内部バグ修正 趙 end

        //                    // add 2021-03-23 バグ修正 趙 start
        //                    if (row0 != 0)
        //                    {
        //                        count = row - row0 + 1;
        //                    }
        //                    else
        //                    {
        //                        count = 1;
        //                    }

        //                    if (afterRow0 != row0)
        //                    {
        //                        rows0 = afterRow0 - row0;
        //                    }
        //                    else
        //                    {
        //                        rows0 = 0;
        //                    }
        //                    // add 2021-03-23 バグ修正 趙 end
        //                    if (afterRow != row)
        //                    {
        //                        rows = afterRow - row;
        //                    }
        //                    else
        //                    {
        //                        rows = 0;
        //                    }
        //                    if (afterRow != row && afterColumn != column)
        //                    {
        //                        foreach (var wParamOld in wManagedDataList)
        //                        {
        //                            if (wKeyValue.Key.Equals(wParamOld.CellAddress) && wKeyValue.Value.Equals(wParamOld.DataPath))
        //                            {
        //                                addFlg = true;
        //                                break;
        //                            }
        //                        }
        //                    }
        //                    if (addFlg == false)
        //                    {
        //                        if (!String.IsNullOrEmpty(wParam.RepeatCount))
        //                        {
        //                            string[] ra = wParam.RepeatAddress.Split(',');
        //                            for (int i = 0; i < ra.Length; i++)
        //                            {
        //                                // upd 2021-03-15 バグ修正 趙 start
        //                                //string fixtype = new Regex(@"[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                //ra[i] = fixtype + (Convert.ToInt32(Regex.Replace(ra[i], @"[^0-9]+", "")) + rows).ToString();

        //                                // upd 2021-05-20 内部バグ修正 趙 start
        //                                //string fixtype1 = new Regex(@"[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                //string fixtype2 = string.Empty;
        //                                //string fixtype3 = string.Empty;
        //                                //if (new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wKeyValue.Key).Value != "")
        //                                //{
        //                                //    fixtype2 = (Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wKeyValue.Key).Value) + i * count).ToString();
        //                                //    fixtype3 = new Regex(@":[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                //}
        //                                //string fixtype4 = (Convert.ToInt32(new Regex(@"[0-9]+\z").Match(wKeyValue.Key).Value) + i * count).ToString();
        //                                //ra[i] = fixtype1 + fixtype2 + fixtype3 + fixtype4;
        //                                string fixtype1 = ToName(ToIndex(new Regex(@"[a-zA-Z]+").Match(wKeyValue.Key).Value) + columns);
        //                                string fixtype2 = string.Empty;
        //                                string fixtype3 = string.Empty;
        //                                if (new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wKeyValue.Key).Value != "")
        //                                {
        //                                    fixtype2 = (Convert.ToInt32(new Regex(@"((?i)(?<=[a-zA-Z]+)((?![a-zA-Z]+).)*(?=:[a-zA-Z]+))").Match(wKeyValue.Key).Value) + i * count).ToString();
        //                                    string str = new Regex(@":[a-zA-Z]+").Match(wKeyValue.Key).Value;
        //                                    fixtype3 = ":" + ToName(ToIndex(new Regex(@"[a-zA-Z]+").Match(str).Value) + columns);
        //                                }
        //                                string fixtype4 = (Convert.ToInt32(new Regex(@"[0-9]+\z").Match(wKeyValue.Key).Value) + i * count).ToString();
        //                                ra[i] = fixtype1 + fixtype2 + fixtype3 + fixtype4;
        //                                // upd 2021-05-20 内部バグ修正 趙 end

        //                                // upd 2021-03-15 バグ修正 趙 end
        //                            }
        //                            wParam.RepeatAddress = string.Join(",", ra);
        //                        }
        //                        DesignParamData wData = new DesignParamData(wParam);
        //                        wData.CellAddress = wKeyValue.Key;
        //                        wData.ButtonEditFormatConditionText = wParam.ButtonEditFormatConditionText;
        //                        wData.FilterState = wParam.FilterState;
        //                        wData.FormatCondition = wParam.FormatCondition;
        //                        dPdList.Add(wData);
        //                        wUpdateList.Add(wKeyValue.Key, wKeyValue.Value as String);
        //                    }
        //                    // add 2021-03-16 バグ修正 趙 start
        //                    break;
        //                    // add 2021-03-16 バグ修正 趙 end
        //                }
        //            }
        //            // mod 2020-10-29 FNSI-改修 637バグの修正 夏 end
        //        }

        //        // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
        //        foreach (var wParam in dPdList)
        //        {
        //            foreach (var wKeyValue in wDeleteList)
        //            {
        //                if (wKeyValue.Key.Equals(wParam.CellAddress))
        //                {
        //                    wDeleteList.Remove(wKeyValue.Key);
        //                    break;
        //                }
        //            }
        //        }
        //        // add 2020-10-29 FNSI-改修 637バグの修正 夏 end               

        //        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
        //        foreach (var wKeyValue in wChangedRangeManagedCellValueList)
        //        {
        //            if (!wUpdateList.ContainsKey(wKeyValue.Key))
        //            {
        //                wUpdateList.Add(wKeyValue.Key, wKeyValue.Value as String);
        //            }
        //        }
        //        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

        //        // add #8335 FNW帳票取込みの動作に問題あり 夏 start
        //        foreach (var wRetData in RldLib.CurrentLayoutData.DesignParamList)
        //        {
        //            if (wUpdateList.ContainsKey(wRetData.CellAddress) && wUpdateList.ContainsValue(wRetData.DataPath))
        //            {
        //                wUpdateList.Remove(wRetData.CellAddress);
        //            }
        //        }
        //        // add #8335 FNW帳票取込みの動作に問題あり 夏 end

        //        // 変更内容を適用
        //        this.UpdateBindingListItem(wUpdateList, false);
        //        this.UpdateBindingListItem(wDeleteList, true);
        //        Console.WriteLine(string.Format("{0} ok {1}   - {2} ", DateTime.Now, wUpdateList.Count, wDeleteList.Count));
        //        if (wUpdateList.Count > 0)
        //        {
        //            foreach (var wKeyValue in wUpdateList)
        //            {
        //                Console.WriteLine(string.Format("{0} update {1} - {2} ", DateTime.Now, wKeyValue.Key, wKeyValue.Value));
        //            }
        //        }
        //        if (wDeleteList.Count > 0)
        //        {
        //            foreach (var wKeyValue in wDeleteList)
        //            {
        //                Console.WriteLine(string.Format("{0} delete {1} - {2} ", DateTime.Now, wKeyValue.Key, wKeyValue.Value));
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}失敗", MSG_HEADER));
        //        this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
        //    }
        //    finally
        //    {
        //        RldUtility.WriteLog(NKKLoggingLib.NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}終了", MSG_HEADER));
        //    }
        //}

        #endregion
        // mod 2023-03-24 #8335 鵬 end

        // add 2020-10-29 FNSI-改修 637バグの修正 夏 start

        // mod #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
        /// <summary>Excel 列字母を 0 起始の列インデックスに変換します。失敗時は false（例外は投げません）。</summary>
        public static Boolean TryToIndex(String columnName, out Int32 index)
        {
            index = -1;
            if (String.IsNullOrWhiteSpace(columnName))
            {
                return false;
            }
            String t = columnName.Trim().ToUpperInvariant();
            if (!Regex.IsMatch(t, @"^[A-Z]+$", RegexOptions.CultureInvariant))
            {
                return false;
            }
            Int32 acc = 0;
            for (Int32 i = 0; i < t.Length; i++)
            {
                Char ch = t[i];
                if (ch < 'A' || ch > 'Z')
                {
                    index = -1;
                    return false;
                }
                acc = acc * 26 + (ch - 'A' + 1);
            }
            index = acc - 1;
            return true;
        }

        //Excel文字列を数字に変換（失敗時は変換せず -1 を返し、Debug 出力のみ）
        public static int ToIndex(string columnName)
        {
            if (TryToIndex(columnName, out Int32 index))
            {
                return index;
            }
#if DEBUG
            //String colForLog = columnName ?? String.Empty;
            //Console.WriteLine(String.Format(CultureInfo.InvariantCulture, "[ToIndex] invalid parameter, columnName={0}", colForLog));
#endif
            return -1;
        }

        // mod #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

        //Excel数字を文字列に変換
        public static string ToName(int index)
        {
            if (index < 0) { throw new Exception("invalid parameter"); }

            List<string> chars = new List<string>();
            do
            {
                if (chars.Count > 0) index--;
                chars.Insert(0, ((char)(index % 26 + (int)'A')).ToString());
                index = (int)((index - index % 26) / 26);
            } while (index > 0);

            return String.Join(string.Empty, chars.ToArray());
        }

        private String Column(string columnName)
        {
            Regex re = new Regex(@"[a-zA-Z]+");
            Match m = re.Match(columnName);
            return m.Value;
        }
        // add 2020-10-29 FNSI-改修 637バグの修正 夏 end

        /// <summary>
        /// 指定された Excel のセル位置のデータをバインディングリストへ追加します。
        /// </summary>
        /// <param name="aA1FormatAddress"></param>
        /// <param name="aIsRemove"></param>
        private void UpdateBindingListItem(Dictionary<String, String> aTargetList, Boolean aIsRemove)
        {
            if (aTargetList == null)
            {
                return;
            }
            if (aTargetList.Count == 0)
            {
                return;
            }
            if (this.dgvParamList.IsDisposed)
            {
                return;
            }

            if (this.dgvParamList.InvokeRequired)
            {
                this.Invoke((MethodInvoker)delegate { UpdateBindingListItem(aTargetList, aIsRemove); });
            }
            else
            {
                //add 8394 動作に関する指摘 邾 start
                ArrayList arrayList = new ArrayList();
                dgvParamList.Visible = false;
                //add 8394 動作に関する指摘 邾 end
                Int32 wNewIndex = -1;

                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                RldLib.CurrentLayoutData.DesignParamList.ListChanged -= new ListChangedEventHandler(this.DesignParamList_ListChanged);

                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                if (aIsRemove)
                {
                    var wRemoveTargets = new List<DesignParamData>();
                    foreach (var wKeyValue in aTargetList)
                    {
                        DesignParamData wData = null;
                        String wCellAddress = wKeyValue.Key, wDataPath = wKeyValue.Value;
                        if (!String.IsNullOrEmpty(wCellAddress))
                        {
                            String wDeleteAddrNorm(String addr)
                            {
                                if (String.IsNullOrEmpty(addr))
                                {
                                    return String.Empty;
                                }
                                return addr.Split(':')[0].Replace("$", String.Empty).ToUpperInvariant();
                            }
                            String wTargetAddrNorm = wDeleteAddrNorm(wCellAddress);
                            foreach (DesignParamData candidate in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                if (String.Equals(wDeleteAddrNorm(candidate.CellAddress), wTargetAddrNorm, StringComparison.Ordinal)
                                    && (String.IsNullOrEmpty(wDataPath)
                                        || String.Equals(candidate.DataPath, wDataPath, StringComparison.Ordinal)))
                                {
                                    wData = candidate;
                                    break;
                                }
                            }
                        }
                        if (wData != null && RldLib.CurrentLayoutData.DesignParamList.Contains(wData)
                            && !wRemoveTargets.Contains(wData))
                        {
                            wRemoveTargets.Add(wData);
                        }
                    }
                    wRemoveTargets.Sort((a, b) => RldLib.CurrentLayoutData.DesignParamList.IndexOf(b).CompareTo(RldLib.CurrentLayoutData.DesignParamList.IndexOf(a)));
                    foreach (DesignParamData wData in wRemoveTargets)
                    {
                        this.IsCancelRowEnter = true;
                        RldLib.CurrentLayoutData.RemoveDesignParamData(wData);
                        this.SendNotifyInfo(new RldDesignNotifyInfoNotifySelectedParamChangedEventArgs(wData.CellAddress));
                        this.IsCancelRowEnter = false;
                    }
                    dgvParamList.Visible = true;
                    RldLib.CurrentLayoutData.DesignParamList.ListChanged += new ListChangedEventHandler(this.DesignParamList_ListChanged);
                    return;
                }
                // add #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                foreach (var wKeyValue in aTargetList)
                {
                    //add 8394 動作に関する指摘 邾 start
                    DesignParamData wData = null;
                    //add 8394 動作に関する指摘 邾 end
                    String wCellAddress = wKeyValue.Key, wDataPath = wKeyValue.Value;

                    // 追加/更新時
                    if (!aIsRemove)
                    {
                        // 追加用データを作成
                        if ((wData = RldLib.CurrentLayoutData.CreateDesignParamData(wDataPath, wCellAddress)) != null)
                        {
                            // 不足情報を付加
                            wData = RldLib.ApplyAdditionalInfoToParamData(wData);

                            // 追加先に既にデータがあるか確認
                            wNewIndex = RldLib.CurrentLayoutData.FindDesignParamDataIndex(wCellAddress);
                        }
                        else
                        {
                            // 追加用データを作成できなかった場合は削除モードへ移行
                            aIsRemove = true;
                        }
                    }

                    // 削除時はバインディングリスト内から該当データを検索(見つからない可能性もある)
                    // del #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                    //if (aIsRemove)
                    //{
                    //    wData = RldLib.CurrentLayoutData.FindDesignParamData(wCellAddress);
                    //}
                    // del #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                    if (!aIsRemove)
                    {
                        // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
                        if (dPdList.Count > 0)
                        {
                            foreach (var dPd in dPdList)
                            {
                                // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                                //if (wData.CellAddress == dPd.CellAddress)
                                if (wData.CellAddress == dPd.CellAddress && dPd.DataPath.Equals(wData.DataPath))
                                // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                                {
                                    wData = dPd;
                                    dPdList.Remove(dPd);
                                    break;
                                }
                            }
                        }
                        // add 2020-10-29 FNSI-改修 637バグの修正 夏 end
                        if (wNewIndex != -1)
                        {
                            // 別の項目が配置されていたセルの場合
                            RldLib.CurrentLayoutData.SetDesignParamData(wData, wNewIndex);
                        }
                        else
                        {
                            // 新しいセルの場合
                            //add 8394 動作に関する指摘 邾 start
                            //RldLib.CurrentLayoutData.AddDesignParamData(wData);
                            arrayList.Add(wData);
                            //add #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる start
                            RldLib.CurrentLayoutData.AddDesignParamData(wData);
                            //add #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる end
                            //add 8394 動作に関する指摘 邾 end
                        }
                    }
                    // del #10978 データ項目を移動させると「ラベル項目」設定が消える 高 start
                    //else
                    //{
                    //    this.IsCancelRowEnter = true;
                    //    RldLib.CurrentLayoutData.RemoveDesignParamData(wData);
                    //    dgvParamList.Visible = true;
                    //    // 選択アイテムウィンドウの表示をクリアするためにイベント通知
                    //    if (wData != null)
                    //    {
                    //        this.SendNotifyInfo(new RldDesignNotifyInfoNotifySelectedParamChangedEventArgs(wData.CellAddress));
                    //    }

                    //    this.IsCancelRowEnter = false;
                    //}
                    // del #10978 データ項目を移動させると「ラベル項目」設定が消える 高 end

                    // MOD #5915「患者イベントの取得ができない」について、対応する 鄧シン start
                    if (wData != null && !String.IsNullOrEmpty(wData.RepeatAddress) && !wData.RepeatAddress.StartsWith(wData.CellAddress))
                    {
                        wData.RepeatAddress = wData.CellAddress;
                    }
                    // MOD #5915「患者イベントの取得ができない」について、対応する 鄧シン end
                    // セルの書式設定を更新
                    if (!aIsRemove && wData != null)
                    {
                        this.UpdateLayoutSheetRangeFormatSetting(wData);
                    }
                }
                //del #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる start
                //add 8394 動作に関する指摘 邾 start
                //if (!aIsRemove && wNewIndex == -1)
                //{
                //    foreach (DesignParamData wd in arrayList)
                //    {
                //        RldLib.CurrentLayoutData.AddDesignParamData(wd);
                //    }
                //}
                //add 8394 動作に関する指摘 邾 end
                //#del #9305 行の挿入や削除で繰り返し設定が消え、出力もおかしくなる start
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                RldLib.CurrentLayoutData.DesignParamList.ListChanged += new ListChangedEventHandler(this.DesignParamList_ListChanged);
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

                // RldLib.CurrentLayoutData.DesignParamListを並べ替える
                RldLib.CurrentLayoutData.DesignParamList.Sort();
                // add #12486 レイアウトアプリでバーコード非対応の項目で設定ができてしまう 高 start
                var currentDataSource = dgvParamList.DataSource;
                dgvParamList.DataSource = null;
                dgvParamList.DataSource = currentDataSource;
                // add #12486 レイアウトアプリでバーコード非対応の項目で設定ができてしまう 高 end

                //add 8394 動作に関する指摘 邾 start
                dgvParamList.Visible = true;
                //add 8394 動作に関する指摘 邾 end
            }
        }

        /// <summary>
        /// パラメータ編集画面の選択行を変更できるかどうか確認します。
        /// </summary>
        /// <param name="aAddress"></param>
        /// <param name="aSelectedAddress"></param>
        /// <returns></returns>
        private Boolean CheckUpdateParamGridSelection(String aAddress, out String aSelectedAddress)
        {
            Boolean wRet = false;

            aSelectedAddress = String.Empty;

            // カンマ(,)が含まれている場合は複数選択状態なので不可
            if (aAddress.Contains(","))
            {
                return false;
            }

            // セル管理クラスを生成
            using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, aAddress))
            {

                // 結合状態を取得
                Object wMergeCells = wXlRange.Range.MergeCells;

                // System.DBNull.Value の場合は結合セルを含む複数のセルを選択している状態なので不可
                // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
                string[] currentCell;
                if (wMergeCells != System.DBNull.Value)
                {
                    // 結合セル
                    if ((Boolean)wMergeCells)
                    {
                        aSelectedAddress = aAddress;
                    }
                    else
                    {
                        currentCell = aAddress.Split(':');
                        aSelectedAddress = currentCell[0];
                    }
                    wRet = true;
                }
                else
                {   
                    // 結合セル
                    // ドロップ先のアドレスを取得
                    using (var wXlRangeFirst = new ExcelRangeEx(wXlRange.Range.Cells[1, 1]))
                    {
                        Object wMergeCellsFirst = wXlRangeFirst.Range.MergeCells;

                        // 結合セルへのドロップの場合は正しい範囲を取得
                        if ((Boolean)wMergeCellsFirst)
                        {
                            using (var wXlMerge2 = new ExcelRangeEx(wXlRangeFirst.Range.MergeArea))
                            {
                                aSelectedAddress = wXlMerge2.Range.Address[false, false];
                                wRet = true;
                            }
                        }
                        else
                        {
                            currentCell = aAddress.Split(':');
                            aSelectedAddress = currentCell[0];
                            wRet = true;
                        }
                    }
                }
                // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
            }

            return wRet;
        }

        /// <summary>
        /// パラメータリスト表示用グリッドの選択行を更新します。
        /// </summary>
        /// <param name="aCellAddress"></param>
        /// <param name="aDataPath"></param>
        // mod 8394 動作に関する指摘 吉 start
        // private void UpdateParamGridSelection(String aCellAddress)
        private void UpdateParamGridSelection(String aCellAddress, Boolean isRefreshAllFlag = false)
        // mod 8394 動作に関する指摘 吉 end
        {

            DesignParamData wData = null;
            // add 8394 動作に関する指摘 吉 start
            if (isRefreshAllFlag)
            {
                // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
                //this.UpdateParamDataList();
                this.UpdateParamDataList(aCellAddress);
                // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
            }
            // add 8394 動作に関する指摘 吉 end
            String wColumnName = DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.CellAddress);

            var wGridRow = this.dgvParamList.Rows.Cast<DataGridViewRow>().Where(ele => ele.Cells[wColumnName].Value as String == aCellAddress);
            if (wGridRow.Count() == 1)
            {

                var wRow = wGridRow.ElementAt(0);
                wData = wRow.DataBoundItem as DesignParamData;

                // 選択状態を更新する
                LFunc_SelectionUpdate();

                /// <summary>
                /// (ローカル関数) パラメータリスト表示用データグリッドの選択状態を更新します。
                /// </summary>
                void LFunc_SelectionUpdate()
                {
                    if (this.dgvParamList.IsDisposed)
                    {
                        return;
                    }

                    if (this.dgvParamList.InvokeRequired)
                    {
                        this.Invoke((MethodInvoker)delegate
                        {
                            LFunc_SelectionUpdate();
                        });
                    }
                    else
                    {
                        switch (this.dgvParamList.SelectionMode)
                        {
                            case DataGridViewSelectionMode.FullRowSelect:
                                wRow.Selected = true;
                                break;

                            case DataGridViewSelectionMode.CellSelect:
                                wRow.Cells[DesignParamData.GetProperty(DesignParamData.EnumDataIndex.DataPath).Name].Selected = true;
                                break;

                            default:
                                break;
                        }

                        // 明細表示を更新
                        this.UpdateParamDetailGrid(wData, true);

                        // 選択位置が変更したことを通知
                        this.SendNotifyInfo(new RldDesignNotifyInfoNotifySelectedParamChangedEventArgs(aCellAddress));
                    }
                }
            }
            // add 2021-07-26 5603 移行できなかった項目についての情報が表示されない 李 start
            else
            {
                int rowCount = this.dgvParamList.Rows.Count;
                for (int i = 0; i < rowCount; i++)
                {
                    if (dgvParamList.Rows[i].Selected || dgvParamList.Rows[i].Cells[DesignParamData.GetProperty(DesignParamData.EnumDataIndex.DataPath).Name].Selected)
                    {
                        dgvParamList.Rows[i].Selected = false;
                        dgvParamList.Rows[i].Cells[DesignParamData.GetProperty(DesignParamData.EnumDataIndex.DataPath).Name].Selected = false;
                        break;
                    }
                }

                // 選択状態を更新する
                LFunc_SelectionUpdate();
                /// <summary>
                /// (ローカル関数) パラメータリスト表示用データグリッドの選択状態を更新します。
                /// </summary>
                void LFunc_SelectionUpdate()
                {
                    if (this.dgvParamList.IsDisposed)
                    {
                        return;
                    }

                    if (this.dgvParamList.InvokeRequired)
                    {
                        this.Invoke((MethodInvoker)delegate
                        {
                            LFunc_SelectionUpdate();
                        });
                    }
                    else
                    {
                        // add #12475 FNW帳票取込すると検査日が表示されない 高 start
                        if (wData == null)
                        {
                            if (this.dgvParamList.IsCurrentCellInEditMode)
                            {
                                this.dgvParamList.EndEdit();
                            }
                        }

                        if (this.dgvParamDetail != null && !this.dgvParamDetail.IsDisposed)
                        {
                            if (this.dgvParamDetail.IsCurrentCellInEditMode)
                            {
                                try
                                {
                                    this.dgvParamDetail.EndEdit();
                                }
                                catch (NullReferenceException) {}
                                catch (Exception) {}
                            }
                        }
                        // add #12475 FNW帳票取込すると検査日が表示されない 高 end

                        // 明細表示を更新
                        this.UpdateParamDetailGrid(wData, true);

                        // 選択位置が変更したことを通知
                        this.SendNotifyInfo(new RldDesignNotifyInfoNotifySelectedParamChangedEventArgs(aCellAddress));
                    }
                }
            }
            // add 2021-07-26 5603 移行できなかった項目についての情報が表示されない 李 end
        }

        /// <summary>
        /// パラメータ明細表示用グリッドの表示を更新します。
        /// </summary>
        private void UpdateParamDetailGrid(DesignParamData aData, Boolean aIsDataClear)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(3) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 画面を一旦クリア
            if (aIsDataClear)
            {
                this.DataClear(false);
            }

            // 選択中のデータがない場合は抜ける
            if (aData == null)
            {
                return;
            }

            // 明細表示するプロパティを取得(EoCを除外)
            var wProperties = DesignParamData.Properties.Where(ele => ele.Name != DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.EoC)).ToArray();

            try
            {
                this.dgvParamDetail.SuspendLayout();

                // パラメータ明細表示用データグリッドビューの内容をリセット
                if (aIsDataClear)
                {
                    RldGridRCAttributeReflector.ApplyToRow(this.dgvParamDetail, wProperties);
                }

                for (int wRowIndex = 0; wRowIndex < this.dgvParamDetail.RowCount; wRowIndex++)
                {

                    var wRow = this.dgvParamDetail.Rows[wRowIndex];
                    var wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];

                    String wKeyCellValue = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property].Value as String;

                    // 選択された行のデータを配置する
                    {
                        /// <summary>
                        /// プロパティ名が一致するか確認します。
                        /// </summary>
                        /// <param name="aIndex"></param>
                        Boolean wFuncIsEqualPropName(DesignParamData.EnumDataIndex aIndex) => wKeyCellValue == DesignParamData.GetPropertyName(aIndex);

                        /// <summary>
                        /// セルを読取専用に設定します。
                        /// </summary>
                        void wFuncSetCellReadOnly(Boolean aIsSetReadOnly) =>
                            RldDataGridViewStaticMethods.SetCellReadOnly(
                                this.dgvParamDetail,
                                wRowIndex,
                                (Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue,
                                aIsSetReadOnly);

                        // データパス
                        if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.DataPath))
                        {
                            wValueCell.Value = aData.DataPath;
                        }
                        // プレビューデータ
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.PreviewData))
                        {
                            // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                            wFuncSetCellReadOnly(aData.CanEditBarCode);
                            wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];
                            // add #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                            wValueCell.Value = aData.PreviewData;
                        }
                        // 書式(編集ボタン)
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.ButtonEditDisplayFormatText))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditDisplayFormat);
                        }
                        // 変換リスト(編集ボタン)
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.ButtonEditConvertListText))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditConvertList);
                        }
                        // 繰返し(編集ボタン)
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.ButtonEditRepeatText))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditRepeat);
                        }
                        // 繰返し回数
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.RepeatCount))
                        {
                            wValueCell.Value = aData.RepeatCount;
                        }
                        // 繰返し場所
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.RepeatAddress))
                        {
                            wValueCell.Value = aData.RepeatAddress;
                        }
                        // 縮小して全体を表示
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.IsShrink))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditShrink);
                            // add #10487 デザイナーウィンドウの動作不良2件 高 start
                            wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];
                            // add #10487 デザイナーウィンドウの動作不良2件 高 end
                            wValueCell.Value = aData.IsShrink;
                        }
                        // 最大表示文字数(半角)
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.Length))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditLength);
                            // add #10487 デザイナーウィンドウの動作不良2件 高 start
                            wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];
                            // add #10487 デザイナーウィンドウの動作不良2件 高 end
                            wValueCell.Value = aData.Length;
                        }
                        // フィルタ(編集ボタン)
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.ButtonEditFilterText))
                        {
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                            if (aData.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                                wFuncSetCellReadOnly(aData.CanEditFilter);
                            else if (aData.FilterType == RldConst.FilterType.Group.EQUIP)       // 医材
                                wFuncSetCellReadOnly(aData.CanEditFilter);
                            else if (aData.FilterType == RldConst.FilterType.Group.CATEGORY)
                                wFuncSetCellReadOnly(aData.CanEditFilter);
                            else
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                wFuncSetCellReadOnly(!aData.CanEditFilter);
                        }
                        // フィルタ状態
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.FilterState))
                        {
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                            if (aData.FilterType == RldConst.FilterType.Group.MEDICINE)    // 薬剤
                                wValueCell.Value = string.Empty;
                            else if (aData.FilterType == RldConst.FilterType.Group.EQUIP)       // 医材
                                wValueCell.Value = string.Empty;
                            else if (aData.FilterType == RldConst.FilterType.Group.CATEGORY)
                                wValueCell.Value = string.Empty;
                            else
                            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                wValueCell.Value = aData.FilterState;
                        }
                        // 改ページ
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.IsNewPage))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditNewPage);
                            // add #10487 デザイナーウィンドウの動作不良2件 高 start
                            wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];
                            // add #10487 デザイナーウィンドウの動作不良2件 高 end
                            wValueCell.Value = aData.IsNewPage;
                        }
                        // ラベル項目(編集ボタン)
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.ButtonEditLabelItemText))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditLabelItem);
                        }
                        // 配置場所
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.CellAddress))
                        {
                            wValueCell.Value = aData.CellAddress;
                        }
                        // グループ名
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.GroupName))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditGroupName);
                            // add #10487 デザイナーウィンドウの動作不良2件 高 start
                            wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];
                            // add #10487 デザイナーウィンドウの動作不良2件 高 end
                            wValueCell.Value = aData.GroupName;
                        }
                        // テンプレート内外
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.IsInTemplete))
                        {
                            wValueCell.Value = aData.IsInTemplete;
                        }
                        // add #11535 帳票の汎用バーコード出力対応 高 start
                        // バーコード
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.ButtonEditBarCodeText))
                        {
                            wFuncSetCellReadOnly(!aData.CanEditBarCode);
                        }
                        else if (wFuncIsEqualPropName(DesignParamData.EnumDataIndex.BarCode))
                        {
                            wValueCell.Value = aData.BarCode;
                        }
                        // add #11535 帳票の汎用バーコード出力対応 高 end
                    }

                    // 読取専用のセルの前景色を変更
                    {
                        if (wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue].ReadOnly)
                        {
                            wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemName].Style.ForeColor = System.Drawing.Color.DarkGray;
                            wValueCell.Style.ForeColor = System.Drawing.Color.DarkGray;
                        }
                    }
                }
            }
            catch
            {
                throw;
            }
            finally
            {
                this.dgvParamDetail.ResumeLayout();
            }
        }

        // add #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
        private void UpdataParamData(int i)
        {
            if (i >= RldLib.CurrentLayoutData.DesignParamList.Count)
                return;

            LFunc_Invoke();

            void LFunc_Invoke()
            {
                if (this.dgvParamList.IsDisposed)
                    return;

                if (this.dgvParamList.InvokeRequired)
                {
                    this.Invoke((MethodInvoker)delegate
                    {
                        LFunc_Invoke();
                    });
                }
                else
                {
                    bool isShrink = false;
                    String format;
                    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignParamList[i].CellAddress))
                    {
                        object wValueFormat = wXlRange.Range.NumberFormatLocal;
                        format = wValueFormat == DBNull.Value ? string.Empty : (string)wValueFormat;
                        
                        object wValue = wXlRange.Range.ShrinkToFit;
                        bool wIsShrink = wValue == DBNull.Value || (bool)wValue;
                        if (wIsShrink == true)
                        {
                            isShrink = true;
                        }
                    }
                    
                    bool isShrinkParam = false;
                    if ("1".Equals(RldLib.CurrentLayoutData.DesignParamList[i].IsShrink))
                    {
                        isShrinkParam = true;
                    }
                    bool reCalc = (isShrink != isShrinkParam);
                    RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink, format, reCalc);
                }
            }
        }
        // add #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end

        // add #12616 データ項目の縮小表示が機能しないことがある 高 start
        private static void UpdataParamData_s(int i)
        {
            if (i >= RldLib.CurrentLayoutData.DesignParamList.Count)
                return;

            bool isShrink = false;
            String format;
            using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignParamList[i].CellAddress))
            {
                object wValueFormat = wXlRange.Range.NumberFormatLocal;
                format = wValueFormat == DBNull.Value ? string.Empty : (string)wValueFormat;

                object wValue = wXlRange.Range.ShrinkToFit;
                bool wIsShrink = wValue == DBNull.Value || (bool)wValue;
                if (wIsShrink == true)
                {
                    isShrink = true;
                }
            }

            bool isShrinkParam = false;
            if ("1".Equals(RldLib.CurrentLayoutData.DesignParamList[i].IsShrink))
            {
                isShrinkParam = true;
            }
            bool reCalc = (isShrink != isShrinkParam);

            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            if (reCalc == false)
            {
                string length = RldLib.CurrentLayoutData.DesignParamList[i].Length;
                RldLib.CurrentLayoutData.DesignParamList[i].IsShrink = isShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
                RldLib.CurrentLayoutData.DesignParamList[i].Length = length;
            }
            else
            {
                RldLib.CurrentLayoutData.DesignParamList[i].IsShrink = isShrink ? RldConst.ParamData.VAL_ISSHRINK_DONE : RldConst.ParamData.VAL_ISSHRINK_NONE;
            }
            //RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink, format, reCalc);
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
        }

        private static void UpdateParamDataList_s(string wCellAddr)
        {
            Int32 wNewIndex = -1;

            if (string.IsNullOrEmpty(wCellAddr))
                return;

            wNewIndex = RldLib.CurrentLayoutData.FindDesignParamDataIndex(wCellAddr);

            if (wNewIndex == -1)
                return;

            UpdataParamData_s(wNewIndex);
        }
        // add #12616 データ項目の縮小表示が機能しないことがある 高 end

        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
        /// <summary>
        /// パラメータデータリストを更新します。
        /// </summary>
        // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
        private void UpdateParamDataList(string wCellAddr)
        {
            Int32 wNewIndex = -1;

            if (string.IsNullOrEmpty(wCellAddr))
                return;

            wNewIndex = RldLib.CurrentLayoutData.FindDesignParamDataIndex(wCellAddr);

            if (wNewIndex == -1)
                return;

            RldLib.CurrentLayoutData.DesignParamList.ListChanged -= new ListChangedEventHandler(this.DesignParamList_ListChanged);
            UpdataParamData(wNewIndex);
            RldLib.CurrentLayoutData.DesignParamList.ListChanged += new ListChangedEventHandler(this.DesignParamList_ListChanged);

            ////modify #8559 dongzhaolong start
            //if (this.dgvParamList.IsDisposed)
            //{
            //    return;
            //}
            ////modify #8559 dongzhaolong end

            //RldLib.CurrentLayoutData.DesignParamList.ListChanged -= new ListChangedEventHandler(this.DesignParamList_ListChanged);
            //for (int i = 0; i < RldLib.CurrentLayoutData.DesignParamList.Count; i++)
            //{
            //    bool isShrink = false;
            //    // add 8394 動作に関する指摘 吉 start
            //    String format;
            //    // add 8394 動作に関する指摘 吉 end
            //    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignParamList[i].CellAddress))
            //    {
            //        // add 8394 動作に関する指摘 吉 start
            //        // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe start
            //        //format = wXlRange.Range.NumberFormatLocal;
            //        object wValueFormat = wXlRange.Range.NumberFormatLocal;
            //        format = wValueFormat == DBNull.Value ? string.Empty : (string)wValueFormat;
            //        // mod #11417 レイアウトデザイナでデータ項目フォーカスアウト時に致命的なエラー limingzhe end
            //        // add 8394 動作に関する指摘 吉 end
            //        // mod #11228 セルの編集から抜ける際に演算子エラー 高 start
            //        object wValue = wXlRange.Range.ShrinkToFit;
            //        bool wIsShrink = wValue == DBNull.Value || (bool)wValue;
            //        //if (wXlRange.Range.ShrinkToFit == true)
            //        if (wIsShrink == true)
            //        // mod #11228 セルの編集から抜ける際に演算子エラー 高 end
            //        {
            //            isShrink = true;
            //        }
            //    }
            //    // del #8394(1) 動作に関する指摘 luantian start
            //    // add #8314 グループタブの表示不正 王占宇 start
            //    //if("1".Equals(RldLib.CurrentLayoutData.DesignParamList[i].IsShrink))
            //    //{
            //    //    isShrink = true;
            //    //}
            //    //else
            //    //{
            //    //    isShrink = false;
            //    //}
            //    // add #8314 グループタブの表示不正 王占宇 end
            //    // del #8394(1) 動作に関する指摘 luantian end
            //    // mod 8394 動作に関する指摘 吉 start
            //    // RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink);
            //    //modify #8586,#8457 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
            //    // mod #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 start
            //    //RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink, format, false);
            //    bool isShrinkParam = false;
            //    if ("1".Equals(RldLib.CurrentLayoutData.DesignParamList[i].IsShrink))
            //    {
            //        isShrinkParam = true;
            //    }
            //    bool reCalc = (isShrink != isShrinkParam);
            //    RldLib.CurrentLayoutData.SetDesignParamDataList(i, isShrink, format, reCalc);
            //    // mod #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 end
            //    //modify #8586,#8457 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
            //    // mod 8394 動作に関する指摘 吉 end
            //}
            //RldLib.CurrentLayoutData.DesignParamList.ListChanged += new ListChangedEventHandler(this.DesignParamList_ListChanged);
        }
        // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
        // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

        /// <summary>
        /// 指定されたデータで レイアウトシートのセルの書式設定を更新します。
        /// </summary>
        /// <param name="aData"></param>
        private void UpdateLayoutSheetRangeFormatSetting(DesignParamData aData)
        {
            try
            {
                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, aData.CellAddress))
                {
                    // 書式
                    if (aData.DataType != "DateTime")
                    {
                        // mod #10230 コピーした内容がリセットされる 高 start
                        if (aData.DisplayFormatUpdate)
                        {
                            wXlRange.Range.NumberFormatLocal = aData.DisplayFormat;
                        }
                        // mod #10230 コピーした内容がリセットされる 高 end
                    }
                    else
                    {
                        string strFormat = aData.DisplayFormat;
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                        if (strFormat.Contains("[$-F800]"))
                        {
                            //wXlRange.Range.NumberFormatLocal = 
                            strFormat = "yyyy\"年\"m\"月\"d\"日\"";
                        }
                        else if (strFormat.Contains("[$-F400]"))
                        {
                            //wXlRange.Range.NumberFormatLocal = 
                            strFormat = "h:mm:ss";
                        }
                        // del #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe start
                        //else if (strFormat.Contains("mm/d"))
                        //{
                        //    //wXlRange.Range.NumberFormatLocal = 
                        //    strFormat = strFormat.Replace("mm/", "MM/");
                        //}
                        //else if (strFormat.Contains("m/d"))
                        //{
                        //    //wXlRange.Range.NumberFormatLocal = 
                        //    strFormat = strFormat.Replace("m/", "M/");
                        //}
                        //else if (strFormat.Contains("yyyy-mm-dd"))
                        //{
                        //    //wXlRange.Range.NumberFormatLocal = 
                        //    strFormat = strFormat.Replace("-mm-", "-MM-");
                        //}
                        // del #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe end
                        if (GetDateFormat(strFormat).Replace(" ", "").Length > 0)
                        {
                            if (GetDateFormat(strFormat, GetDateFormat(strFormat).Replace(" ", "")).Length > 0)
                            {
                                //wXlRange.Range.NumberFormatLocal = 
                                strFormat = GetDateFormat(strFormat, GetDateFormat(strFormat).Replace(" ", ""));
                            }
                            else
                            {
                                //wXlRange.Range.NumberFormatLocal = 
                                strFormat = "yyyy/mm/dd hh:mm";
                            }
                        }
                        else
                        {
                            //wXlRange.Range.NumberFormatLocal = 
                            strFormat = GetSubString(strFormat);
                        }
                        // mod #10230 コピーした内容がリセットされる 高 start
                        if (aData.DisplayFormatUpdate)
                        {
                            // mod #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe start
                            if (strFormat.Equals("gyy/m") || strFormat.Equals("ge/m") || strFormat.Equals("gy/m"))
                            {
                                wXlRange.Range.NumberFormatLocal = "ge/m";
                                aData.DisplayFormat = "gy/m";
                            }
                            else
                            {
                                wXlRange.Range.NumberFormatLocal = aData.DisplayFormat = strFormat;
                            }
                            // mod #10469 単患者帳票で「印刷日時」の書式が反映されない limingzhe end
                        }
                        // mod #10230 コピーした内容がリセットされる 高 end
                        // 6096_日付の書式を変更した際、プレビューデータの欄に反映されない 2021/08/25 add start 李

                        DateTime dt = DateTime.Now;
                        string year = dt.Year.ToString();
                        string mounth = dt.Month.ToString();
                        string mounth2 = mounth.Length == 2 ? mounth : "0" + mounth;
                        string day = dt.Day.ToString();
                        string day2 = day.Length == 2 ? day : "0" + day;
                        string hour = dt.Hour.ToString();
                        string hour2 = hour.Length == 2 ? hour : "0" + hour;
                        string minute = dt.Minute.ToString();
                        string mimute2 = minute.Length == 2 ? minute : "0" + minute;
                        string second = dt.Second.ToString();
                        string second2 = second.Length == 2 ? second : "0" + second;
                        string week = GetWeek(dt.DayOfWeek.ToString());

                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                        DateTime dtBasic = new DateTime(1899, 12, 31);
                        TimeSpan tsNow = dt.Subtract(dtBasic);
                        int totalDays = tsNow.Days + 1;
                        string totalHours = (totalDays * 24 + dt.Hour).ToString();
                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 end

                        // add #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei start
                        // string res = "";
                        string res = aData.PreviewData;
                        // add #7297 初回リリース対象外の機能とその関連機能を隠す xiaosonglei end

                        // add #8394(1) 動作に関する指摘 luantian start
                        CultureInfo jpCulture = new CultureInfo("ja-JP", true);

                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
                        CultureInfo currentCulture = new CultureInfo(System.Threading.Thread.CurrentThread.CurrentUICulture.Name, true);
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
                        jpCulture.DateTimeFormat.Calendar = new JapaneseCalendar();

                        var eraTable = new Dictionary<int, string>();
                        for (char e = 'A'; e <= 'Z'; e++)
                        {
                            int eraIndex = jpCulture.DateTimeFormat.GetEra(e.ToString());
                            if (eraIndex > 0)
                                eraTable.Add(eraIndex, e.ToString());
                        }
                        string eraLetter = "";
                        int eraNumber = jpCulture.DateTimeFormat.Calendar.GetEra(dt);
                        if (eraTable[eraNumber] != null)
                        {
                            eraLetter = eraTable[eraNumber];
                        }
                        // add #8394(1) 動作に関する指摘 luantian end

                        if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\"(aaa) h\"時\"mm\"分\""))
                        {
                            res = year + "年" + mounth + "月" + day + "日(" + week + ")" + hour + "時" + mimute2 + "分";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\" h\"時\"mm\"分\""))
                        {
                            res = year + "年" + mounth + "月" + day + "日 " + hour + "時" + mimute2 + "分";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/m/d h:mm"))
                        {
                            res = year + "/" + mounth + "/" + day + " " + hour + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/mm/dd hh:mm"))
                        {
                            res = year + "/" + mounth2 + "/" + day2 + " " + hour2 + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\""))
                        {
                            res = year + "年" + mounth + "月";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\"(aaa)"))
                        {
                            res = year + "年" + mounth + "月" + day + "日(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy\"年\"m\"月\"d\"日\""))
                        {
                            res = year + "年" + mounth + "月" + day + "日";
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/m/d"))
                        {
                            res = year + "/" + mounth + "/" + day;
                        }
                        else if (aData.DisplayFormat.Equals("yyyy/mm/dd"))
                        {
                            res = year + "/" + mounth2 + "/" + day2;
                        }
                        else if (aData.DisplayFormat.Equals("m\"月\"d\"日\"(aaa)"))
                        {
                            res = mounth + "月" + day + "日(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("m\"月\"d\"日\""))
                        {
                            res = mounth + "月" + day + "日";
                        }
                        else if (aData.DisplayFormat.Equals("m/d(aaa)") || aData.DisplayFormat.Equals("M/d(aaa)"))
                        {
                            res = mounth + "/" + day + "(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("m/d"))
                        {
                            res = mounth + "/" + day;
                        }
                        else if (aData.DisplayFormat.Equals("(aaa)"))
                        {
                            res = "(" + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("aaa\"曜日\""))
                        {
                            res = week + "曜日";
                        }
                        else if (aData.DisplayFormat.Equals("m/d h:mm"))
                        {
                            res = mounth + "/" + day + " " + hour + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("h:mm:ss"))
                        {
                            res = hour + ":" + mimute2 + ":" + second2;
                        }
                        else if (aData.DisplayFormat.Equals("h\"時\"mm\"分\"ss\"秒\""))
                        {
                            res = hour + "時" + mimute2 + "分" + second2 + "秒";
                        }
                        else if (aData.DisplayFormat.Equals("h:mm"))
                        {
                            res = hour + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("hh:mm"))
                        {
                            res = hour2 + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("h\"時\"mm\"分\""))
                        {
                            res = hour + "時" + mimute2 + "分";
                        }
                        // add #8394(3,4) 動作に関する指摘 luantian start
                        else if (aData.DisplayFormat.Equals("gy/m"))
                        {
                            res = eraLetter + dt.ToString("y/", jpCulture) + mounth;
                        }
                        else if (aData.DisplayFormat.Equals("ggge\"年\"m\"月\"d\"日\"(aaa)"))
                        {
                            res = dt.ToString("gggy\"年\"" + mounth + "\"月\"d\"日\"(", jpCulture) + week + ")";
                        }
                        else if (aData.DisplayFormat.Equals("ggge\"年\"m\"月\"d\"日\""))
                        {
                            res = dt.ToString("gggy\"年\"" + mounth + "\"月\"d\"日\"", jpCulture);
                        }
                        else if (aData.DisplayFormat.Equals("ge/m/d"))
                        {
                            res = eraLetter + dt.ToString("y/" + mounth + "/d", jpCulture);
                        }
                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                        else if (aData.DisplayFormat.Equals("[h]:mm:ss"))
                        {
                            //res = dt.ToString("h:mm:ss", jpCulture);
                            res = totalHours + ":" + mimute2 + ":" + second2;
                        }
                        else if (aData.DisplayFormat.Equals("[h]\"時間\"mm\"分\"ss\"秒\""))
                        {
                            //res = dt.ToString("h\"時間\"mm\"分\"ss\"秒\"", jpCulture);
                            res = totalHours + "時間" + mimute2 + "分" + second2 + "秒";
                        }
                        else if (aData.DisplayFormat.Equals("[h]:mm"))
                        {
                            //res = dt.ToString("h:mm", jpCulture);
                            res = totalHours + ":" + mimute2;
                        }
                        else if (aData.DisplayFormat.Equals("[h]\"時間\"mm\"分\""))
                        {
                            //res = dt.ToString("h\"時間\"mm\"分\"", jpCulture);
                            res = totalHours + "時間" + mimute2 + "分";
                        }
                        // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 end
                        else if (aData.DisplayFormat.Equals("h:mm AM/PM"))
                        {
                            res = dt.ToString("h:mm ", jpCulture) + dt.ToString("tt", jpCulture);
                        }
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
                        else
                        {
                            if (aData.DisplayFormat == "mmmmm")
                            {
                                res = aData.DisplayFormat.Replace("mmmmm", dt.ToString("MMMMM", CultureInfo.CreateSpecificCulture("en-GB")).Substring(0, 1));
                            }
                            else if (aData.DisplayFormat.Contains("mmmmm"))
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt").Replace("mmmmm", dt.ToString("MMMMM", CultureInfo.CreateSpecificCulture("en-GB")).Substring(0, 1)), currentCulture);
                            }
                            else if (aData.DisplayFormat.Contains("mmmm"))
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt").Replace("mmmm", dt.ToString("MMMM", CultureInfo.CreateSpecificCulture("en-GB"))), currentCulture);
                            }
                            else if (aData.DisplayFormat.Contains("mmm"))
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt").Replace("mmm", dt.ToString("MMM", CultureInfo.CreateSpecificCulture("en-GB"))), currentCulture);
                            }
                            else
                            {
                                res = dt.ToString(aData.DisplayFormat.Replace("AM/PM", "tt"), currentCulture);
                            }
                        }
                        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END

                        // add #8394(3,4) 動作に関する指摘 luantian start
                        aData.PreviewData = res;
                    }

                    //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END
                    // 6096_日付の書式を変更した際、プレビューデータの欄に反映されない 2021/08/25 add end 李
                    // 縮小して全体を表示
                    // mod #10230 コピーした内容がリセットされる 高 start
                    if (aData.DisplayFormatUpdate)
                    {
                        wXlRange.Range.ShrinkToFit = aData.IsShrink == RldConst.ParamData.VAL_ISSHRINK_NONE ? false : true;
                    }
                    aData.DisplayFormatUpdate = false;
                    // mod #10230 コピーした内容がリセットされる 高 end
                }
            }
            catch
            {
                throw;
            }
        }

        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 START
        private string GetDateFormat(string orgFormat, string strBasic = "[]()AYMDHMSGEPymdhmsagep:/-時間分秒年月曜日\"")
        {
            orgFormat = GetSubString(orgFormat);
            int len = orgFormat.Length;
            char[] s2 = new char[len];
            int index = 0;
            for (int i = 0; i < len; i++)
            {
                char c = orgFormat[i];
                if (!strBasic.Contains(c))
                    s2[index++] = c;
            }
            return new String(s2, 0, index);
        }

        private string GetSubString(string orgFormat)
        {
            if (orgFormat.Contains("[") && orgFormat.Contains("]"))
            {
                if (orgFormat.IndexOf("]") - orgFormat.IndexOf("[") == 2)
                {
                    if (!(orgFormat.Substring(orgFormat.IndexOf("[") + 1, 1) == "h"))
                    {
                        string strLeft = orgFormat.Remove(orgFormat.IndexOf("["));
                        string strRight = orgFormat.Substring(orgFormat.IndexOf("]") + 1);
                        orgFormat = strLeft + strRight;
                    }

                }
                else
                {
                    if (orgFormat.IndexOf("]") < orgFormat.IndexOf("["))
                    {
                        orgFormat = Regex.Replace(orgFormat, @"\[\]", "");
                    }
                    else
                    {
                        string strLeft = orgFormat.Remove(orgFormat.IndexOf("["));
                        string strRight = orgFormat.Substring(orgFormat.IndexOf("]") + 1);
                        orgFormat = strLeft + strRight;
                    }

                }
            }
            else
            {
                orgFormat = Regex.Replace(orgFormat, @"\[\]", "");
            }
            return orgFormat;
        }
        //ADD #8394,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 END

        /// <summary>
        /// 通知用イベントを発行します。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void SendNotifyInfo(RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

        #endregion

        #region メンバ関数定義(Mediator)

        /// <summary>
        /// Mediator からのイベントを受信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void ReceiveNotifyInfo(Object sender, RldDesignNotifyInfoEventArgs e)
        {
            switch (e.InfoType)
            {
                //case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifyDragDropStatusChanged:
                //    // ドラッグアンドドロップ状態変更通知受信
                //    this.ActionOfDragDropStatusChanged(sender, (RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs)e);
                //    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifyDragDropCompleted:
                    // ドラッグアンドドロップ操作完了通知受信
                    this.ActionOfDragDropCompleted(sender, (RldDesignNotifyInfoNotifyDragDropCompletedEventArgs)e);
                    // add #8394(3,4) 動作に関する指摘 luantian start
                    this.DataRead();
                    // add #8394(3,4) 動作に関する指摘 luantian end
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestRemoveAllParam:
                    // 全パラメータ編集データ削除要求受信
                    this.ActionOfRemoveAllParam(sender, (RldDesignNotifyInfoRequestRemoveAllParamEventArgs)e);
                    // add #8394(3,4) 動作に関する指摘 luantian start
                    this.DataRead();
                    // add #8394(3,4) 動作に関する指摘 luantian end
                    break;

                default:
                    break;
            }
        }

        ///// <summary>
        ///// ドラッグアンドドロップ状態通知イベント受信時処理を記述します。
        ///// </summary>
        ///// <param name="sender"></param>
        ///// <param name="e"></param>
        //private void ActionOfDragDropStatusChanged(Object sender, RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs e)
        //{
        //    // TODO: 後で直す
        //    // 取得したステータスで分岐
        //    switch( e.Status ) {
        //        case RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs.EnumDragDropStatus.Start:
        //            // ドラッグアンドドロップが開始
        //            //this.IsDragIn = true;
        //            break;

        //        case RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs.EnumDragDropStatus.FinishDrop:
        //            // ドラッグアンドドロップが完了

        //            break;

        //        case RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs.EnumDragDropStatus.None:
        //            // ドラッグアンドドロップが終了
        //            //this.IsDragIn = false;
        //            break;

        //        default:
        //            break;
        //    }
        //}

        /// <summary>
        /// ドラッグアンドドロップ操作完了通知イベント受信時処理を記述します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfDragDropCompleted(Object sender, RldDesignNotifyInfoNotifyDragDropCompletedEventArgs e)
        {
            try
            {
                this.IsCancelRowEnter = true;

                // add #12616 データ項目の縮小表示が機能しないことがある 高 start
                // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                //if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.lastSelectAddr) == false)
                //{
                //    ProcessAtomicAddresses(RldLib.CurrentLayoutData.lastSelectAddr);
                //}

                //RldLib.CurrentLayoutData.lastSelectAddr = e.DroppedCellAddress;
                this.CommitLastSelectAddress(e.DroppedCellAddress);
                // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
                // add #12616 データ項目の縮小表示が機能しないことがある 高 end

                // パラメータリストの選択位置を変更する
                // mod 8394 動作に関する指摘 吉 start
                // this.UpdateParamGridSelection(e.DroppedCellAddress);
                this.UpdateParamGridSelection(e.DroppedCellAddress, e.isRefreshAllFlag);
                // mod 8394 動作に関する指摘 吉 end
            }
            catch (Exception ex)
            {
                // TODO:
            }
            finally
            {
                this.IsCancelRowEnter = false;
            }
        }

        /// <summary>
        /// 全パラメータ編集データ削除要求受信時処理を記述します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRemoveAllParam(Object sender, RldDesignNotifyInfoRequestRemoveAllParamEventArgs e)
        {
            try
            {
                // 画面をクリア
                this.DataClear(true);
                // バインド対象データをすべて削除
                RldLib.CurrentLayoutData.DesignParamList.Clear();
                // バインドし直す
                this.DataRead();
                // add #8394(3,4) 動作に関する指摘 luantian start
                if (this.dgvParamList.RowCount > 0)
                {
                    this.dgvParamList[0, 0].Selected = true;
                }
                // add #8394(3,4) 動作に関する指摘 luantian start
            }
            catch (Exception ex)
            {
                // TODO:
            }
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// 文字数再計算ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnReCalc_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 格納可能な文字数('0'を1文字として計算)を取得します
            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            {
                // 表示文字数の変更ができない場合はスキップ
                if (!wData.CanEditLength)
                {
                    continue;
                }

                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
                {
                    // 格納可能な文字数('0'を1文字として計算)を取得します
                    wData.Length = Convert.ToString(wXlRange.GetStringLength());
                }
            }
        }

        /// <summary>
        /// プレビュー(Html)ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnPreviewHtml_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            this.SendNotifyInfo(new RldDesignNotifyInfoRequestPreviewEventArgs(RldDesignNotifyInfoRequestPreviewEventArgs.EnumMode.Html));
        }

        /// <summary>
        /// プレビュー(Excel)ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnPreviewExcel_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            this.SendNotifyInfo(new RldDesignNotifyInfoRequestPreviewEventArgs(RldDesignNotifyInfoRequestPreviewEventArgs.EnumMode.Excel));
        }

        /// <summary>
        /// パラメータ一覧表示用 DataGridView の RowEnter イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvParamList_RowEnter(object sender, DataGridViewCellEventArgs e)
        {
            // イベントキャンセル状態の場合は抜ける
            if (this.IsCancelRowEnter)
            {
                return;
            }

            // 選択位置を更新中の場合は抜ける
            if (this.IsSelectionChanging)
            {
                return;
            }

            try
            {
                // 選択位置更新処理中フラグ On
                this.IsSelectionChanging = true;

                // 選択行のデータを取得
                if (!(this.dgvParamList.Rows[e.RowIndex].DataBoundItem is DesignParamData wData))
                {
                    return;
                }

                // 選択位置が変更したことを通知
                this.SendNotifyInfo(new RldDesignNotifyInfoNotifySelectedParamChangedEventArgs(wData.CellAddress));

                // セルアドレスを取得して選択する
                if (dgvParamList.RowCount > 1)
                {
                    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wData.CellAddress))
                    {
                        wXlRange.SelectEx();
                    }
                }

                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                this.CommitLastSelectAddress(wData.CellAddress);
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

                // 明細表示用グリッドの表示を更新
                this.UpdateParamDetailGrid(wData, true);
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                // 選択位置更新処理中フラグ Off
                this.IsSelectionChanging = false;
            }
        }

        /// <summary>
        /// パラメータ明細表示用 DataGridView の CellClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvParamDetail_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            // 関係ない列のクリックの場合は抜ける
            if (e.ColumnIndex != (Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue)
            {
                return;
            }

            // プロパティ名を取得(これが列名となるため)
            String wPropName = this.dgvParamDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property, e.RowIndex].Value as String;

            // クリックさせる
            this.m_ParamGridEditHelper.PerformCellClick(this.dgvParamList.Columns[wPropName].Index, this.dgvParamList.CurrentRow.Index);
        }
        //add 9137 zhu start
        private bool isCellEndEdit = false;
        private int olddgvParamListindex = -1;
        //add 9137 zhu end
        /// <summary>
        /// パラメータ明細表示用 DataGridView の CellEndEdit イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        /// <returns></returns>
        private void dgvParamDetail_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                //add 9137 zhu start
                int dgvParamListindex = -1;
                if (isCellEndEdit)
                {
                    dgvParamListindex = olddgvParamListindex;
                }
                else
                {
                    dgvParamListindex = this.dgvParamList.CurrentRow.Index;
                }
                // 選択行のデータを取得
                if (!(this.dgvParamList.Rows[dgvParamListindex].DataBoundItem is DesignParamData wData))
                {
                    return;
                }
                //add 9137 zhu end
                // 編集を行った行のプロパティ名を取得
                String wPropName = this.dgvParamDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property, e.RowIndex].Value as String;
                String wValue = this.dgvParamDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value as String;

                // プレビューデータ
                if (LFunc_IsEqualPropName(DesignParamData.EnumDataIndex.PreviewData))
                {
                    wData.PreviewData = wValue;
                }
                // 縮小して全体を表示
                else if (LFunc_IsEqualPropName(DesignParamData.EnumDataIndex.IsShrink))
                {
                    wData.IsShrink = wValue;
                }
                // 表示文字数
                else if (LFunc_IsEqualPropName(DesignParamData.EnumDataIndex.Length))
                {
                    wData.Length = Convert.ToString(RldLib.ConvertStrToInt32(wValue, false));
                }
                // 改ページ
                else if (LFunc_IsEqualPropName(DesignParamData.EnumDataIndex.IsNewPage))
                {
                    wData.IsNewPage = wValue;
                }
                // グループ名
                else if (LFunc_IsEqualPropName(DesignParamData.EnumDataIndex.GroupName))
                {

                    this.m_ParamGridEditHelper.PerformCellEndEdit_GroupName(
                        this.dgvParamDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex],
                        wData,
                        wData.GroupName);
                }

                /// <summary>
                /// (ローカル関数) プロパティ名が一致するか確認します。
                /// </summary>
                /// <param name="aIndex"></param>
                Boolean LFunc_IsEqualPropName(DesignParamData.EnumDataIndex aIndex)
                {
                    return wPropName == DesignParamData.GetPropertyName(aIndex);
                }
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            //add 9137 zhu start
            isCellEndEdit = false;
            //add 9137 zhu end
        }

        /// <summary>
        /// パラメータ明細表示用 DataGridView の CurrentCellDirtyStateChanged イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvParamDetail_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = (DataGridView)sender;
            if (wDataGridView.IsCurrentCellDirty)
            {
                if (wDataGridView.CurrentCell is DataGridViewCheckBoxCell)
                {
                    wDataGridView.EndEdit();
                }
            }
        }

        #endregion

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// Excel レイアウトシートの Change イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void XlLayoutSheet_Change(Object sender, RldSimpleTextEventArgs e)
        {
            // ドラッグアンドドロップ操作中は抜ける
            if (RldLib.IsRunningDragDrop)
            {
                return;
            }
            // セル位置が空文字だったら抜ける
            if (String.IsNullOrEmpty(e.Text))
            {
                return;
            }

            // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
            if (RldLib.IsSaveLayoutSheet)
            {
                return;
            }
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

            String wCellAddress = e.Text;
            //DEL #8559 DONGZHAOLONG START
            //ADD #8394 NG2 董  START
            //var currentCell = e.Text.Split(':');
            //if (Regex.Matches(currentCell[0], "[a-zA-z]").Count > 0 && Regex.Matches(currentCell[0], @"\d").Count > 0)
            //{
            //    Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentCell[0]);

            //    if ((string.IsNullOrEmpty(Convert.ToString(currentRange.Value)) || !Convert.ToString(currentRange.Value).StartsWith("##")) && isSkip == true)
            //    {
            //        return;
            //    }
            //}
            //ADD #8394 NG2 董 END
            //DEL #8559 DONGZHAOLONG END

            // バインディングリストを更新
            this.UpdateBindingList(wCellAddress);
            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
            // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
            //this.UpdateParamDataList();
            this.UpdateParamDataList(wCellAddress);
            // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
            // add #8394(3,4) 動作に関する指摘 luantian start
            this.DataRead();
            // add #8394(3,4) 動作に関する指摘 luantian end
        }

        /// <summary>
        /// Excel レイアウトシートの SelectionChange イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void XlLayoutSheet_SelectionChange(Object sender, RldSimpleTextEventArgs e)
        {
            // ドラッグアンドドロップ操作中は抜ける
            if (RldLib.IsRunningDragDrop)
            {
                return;
            }
            // セル位置が空文字だったら抜ける
            if (String.IsNullOrEmpty(e.Text))
            {
                return;
            }

            // 選択位置を更新中の場合は抜ける
            if (this.IsSelectionChanging)
            {
                return;
            }

            // add #12616 データ項目の縮小表示が機能しないことがある 高 start
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            //if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.lastSelectAddr) == false)
            //{
            //    ProcessAtomicAddresses(RldLib.CurrentLayoutData.lastSelectAddr);
            //}
            //RldLib.CurrentLayoutData.lastSelectAddr = e.Text;
            this.CommitLastSelectAddress(e.Text);
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
            // add #12616 データ項目の縮小表示が機能しないことがある 高 end

            //ADD #8394 NG2 董 START
            var currentCell = e.Text.Split(':');
            if (isSkip)
            {
                if (Regex.Matches(currentCell[0], "[a-zA-z]").Count > 0 && Regex.Matches(currentCell[0], @"\d").Count > 0)
                {
                    String wAddress = String.Empty;
                    // 選択行の変更が可能か判断し、可能であればグリッドの選択行を更新
                    if (this.CheckUpdateParamGridSelection(e.Text, out wAddress))
                    {
                        this.UpdateParamGridSelection(wAddress);
                    }
                    Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentCell[0]);
                    if (string.IsNullOrEmpty(Convert.ToString(currentRange.Value)) || !Convert.ToString(currentRange.Value).StartsWith("##"))
                    {
                        isSkip = true;
                    }
                    else
                    {
                        isSkip = false;
                    }
                }
                else
                {
                    isSkip = true;
                }
                return;
            }
            else
            {
                if (Regex.Matches(currentCell[0], "[a-zA-z]").Count > 0 && Regex.Matches(currentCell[0], @"\d").Count > 0)
                {
                    Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentCell[0]);
                    if (string.IsNullOrEmpty(Convert.ToString(currentRange.Value)) || !Convert.ToString(currentRange.Value).StartsWith("##"))
                    {
                        isSkip = true;
                    }
                    else
                    {
                        isSkip = false;
                    }
                }
                else
                {
                    isSkip = true;
                }
            }
            //ADD #8394 NG2 董 END

            try
            {
                // 選択位置更新中フラグを On
                this.IsSelectionChanging = true;

                String wAddress = String.Empty;

                // 選択行の変更が可能か判断し、可能であればグリッドの選択行を更新
                if (this.CheckUpdateParamGridSelection(e.Text, out wAddress))
                {
                    //add #9780 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong start
                    // バインディングリストを更新
                    this.UpdateBindingList(wAddress);
                    //add #9780 データ項目を含むセルを結合させるとパラメータ一覧とのリンクが切れる dongzhaolong end

                    this.UpdateParamGridSelection(wAddress);
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
                    //this.UpdateParamDataList();
                    this.UpdateParamDataList(wAddress);
                    // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                }
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                // 選択位置更新中フラグを Off
                this.IsSelectionChanging = false;
            }
        }

        /// <summary>
        /// パラメータ編集データリストの ListChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DesignParamList_ListChanged(object sender, ListChangedEventArgs e)
        {

            try
            {
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                if (IsSyncingAtomicAddresses)
                {
                    return;
                }
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
                if (RldLib.chkExeclDialog(3) == false)
                    return;
                // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

                // 編集された場合のみ処理を行う
                if (e.ListChangedType != ListChangedType.ItemChanged)
                {
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
                    //this.UpdateParamDataList();

                    var wBindingList = sender as System.ComponentModel.BindingList<DesignParamData>;
                    if (wBindingList == null)
                        return;

                    if (e.NewIndex == -1)
                        return;

                    if (e.NewIndex > (wBindingList.Count -1))
                        return;

                    var wData = wBindingList?[e.NewIndex];
                    if (wData != null) 
                    { 
                        this.UpdateParamDataList(wData.CellAddress);
                    }
                    // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                    return;
                }

                // ロールバック中は処理を行わない
                if (this.IsRollbacking)
                {
                    return;
                }

                Boolean wMustUpdate = false;
                String wPropName = e.PropertyDescriptor?.Name ?? String.Empty;

                if (wPropName == DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.DisplayFormat) ||
                    wPropName == DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.IsShrink))
                {
                    wMustUpdate = true;
                }

                if (wMustUpdate)
                {
                    var wBindingList = sender as System.ComponentModel.BindingList<DesignParamData>;
                    // add #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
                    if (wBindingList == null)
                        return;

                    if (e.NewIndex == -1)
                        return;

                    if (e.NewIndex > (wBindingList.Count - 1))
                        return;
                    // add #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
                    var wData = wBindingList?[e.NewIndex];
                    if (wData != null)
                    {
                        try
                        {
                            // セルの書式設定を更新する
                            // add #10230 コピーした内容がリセットされる 高 start
                            if (wPropName == DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.IsShrink))
                            {
                                wData.DisplayFormatUpdate = true;
                            }
                            // add #10230 コピーした内容がリセットされる 高 end
                            this.UpdateLayoutSheetRangeFormatSetting(wData);
                        }
                        catch (Exception ex)
                        {
                            String wErrMsg = String.Empty;
                            if (wPropName == DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.IsShrink))
                            {
                                wErrMsg = "縮小表示の設定に失敗しました。";
                                // ロールバック中フラグ On
                                this.IsRollbacking = true;
                                // 設定内容を戻す
                                wData.IsShrink = RldConst.ParamData.VAL_ISSHRINK_NONE;
                                // ロールバック中フラグ Off
                                this.IsRollbacking = false;
                            }
                            // 例外情報を生成
                            var wEx = new System.ApplicationException(wErrMsg + "\r\n編集途中の場合は編集を完了して下さい。", ex);
                            // 例外情報を記録(画面にメッセージボックスを表示)
                            this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
                        }
                    }
                }
                // add #10487 デザイナーウィンドウの動作不良2件 高 start
                // 明細表示用グリッドの表示を更新する
                LFunc_SelectionUpdate();
                /// <summary>
                /// (ローカル関数) 明細表示用グリッドの表示を更新。
                /// </summary>
                void LFunc_SelectionUpdate()
                {
                    if (this.dgvParamList.IsDisposed)
                    {
                        return;
                    }

                    if (this.dgvParamList.InvokeRequired)
                    {
                        this.Invoke((MethodInvoker)delegate
                        {
                            LFunc_SelectionUpdate();
                        });
                    }
                    else
                    {
                        var wBindingList1 = sender as System.ComponentModel.BindingList<DesignParamData>;
                        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
                        //if (e.NewIndex == this.dgvParamList.CurrentRow.Index)
                        if (this.dgvParamList.CurrentRow != null && e.NewIndex == this.dgvParamList.CurrentRow.Index)
                        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
                        {
                            var wData1 = wBindingList1?[e.NewIndex];
                            // add #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
                            if (wBindingList1 == null)
                                return;

                            if (e.NewIndex == -1)
                                return;

                            if (e.NewIndex > (wBindingList1.Count - 1))
                                return;
                            // add #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end
                            if (wData1 != null)
                            {
                                // 明細表示用グリッドの表示を更新
                                this.UpdateParamDetailGrid(wData1, false);
                            }
                        }
                    }
                }
                // add #10487 デザイナーウィンドウの動作不良2件 高 end
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        #endregion

        // 6096_日付の書式を変更した際、プレビューデータの欄に反映されない 2021/08/25 add start 李
        private string GetWeek(string EngWeek)
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("Monday", "月");
            data.Add("Tuesday", "火");
            data.Add("Wednesday", "水");
            data.Add("Thursday", "木");
            data.Add("Friday", "金");
            data.Add("Saturday", "土");
            data.Add("Sunday", "日");
            return data[EngWeek];
        }



        // add #9379 【デグレ】表示文字列数の設定変更がフォーカスアウトしないと反映しない dong start
        private void dgvParamList_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = sender as DataGridView;
            if (wDataGridView.IsCurrentCellDirty)
            {
                if (wDataGridView.CurrentCell is DataGridViewTextBoxCell wTextBoxCell)
                {
                    // add #10485 グループ名編集の挙動でNGが2件 高 start
                    if (this.dgvParamList.Columns[wDataGridView.CurrentCell.ColumnIndex].Name != DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.GroupName))
                    // add #10485 グループ名編集の挙動でNGが2件 高 end
                    {
                        wDataGridView.EndEdit();
                        this.dgvParamList.BeginEdit(false);
                    }
                }
            }

        }
        // add #9379 【デグレ】表示文字列数の設定変更がフォーカスアウトしないと反映しない dong end
        // 6096_日付の書式を変更した際、プレビューデータの欄に反映されない 2021/08/25 add end 李

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        // when datagridview sort, reset DataSource, display of button is ok.
        private void RefreshButtonColumns()
        {
            LFunc_Invoke();

            void LFunc_Invoke()
            {
                if (this.dgvParamList.IsDisposed)
                {
                    return;
                }

                if (this.dgvParamList.InvokeRequired)
                {
                    dgvParamList.Invoke((MethodInvoker)delegate
                    {
                        LFunc_Invoke();
                    });
                }
                else
                {
                    var currentDataSource = dgvParamList.DataSource;
                    dgvParamList.DataSource = null;
                    dgvParamList.DataSource = currentDataSource;

                    dgvParamList.CurrentCell = dgvParamList[0, 0];
                    dgvParamList.Focus();
                }
            }
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end

        // add #12475 FNW帳票取込すると検査日が表示されない 高 start
        public void dgvList_EndEdit()
        {
            // データグリッドビュー
            var wDataGridView = dgvParamList;

            if (wDataGridView.IsCurrentCellInEditMode)
            {
                wDataGridView.EndEdit();
            }

            // 明細表示用 DataGridView
            wDataGridView = dgvParamDetail;

            if (wDataGridView.IsCurrentCellInEditMode)
            {
                wDataGridView.EndEdit();
            }
        }
        // add #12475 FNW帳票取込すると検査日が表示されない 高 end

        // add #12616 データ項目の縮小表示が機能しないことがある 高 start
        /// <summary>
        /// Parses a selection address string into independent cell/merged cell addresses
        /// </summary>
        /// <param name="addressString">For example "A1,B2,C3" or "A1:B5" or "A1,A3:C5,E7"</param>
        /// <returns>Comma-separated string of independent single cell or merged cell complete addresses</returns>
        public static string ParseToAtomicUnits(string addressString)
        {
            var result = new List<string>();

            // 0. Check if the address string contains row-only or column-only selections
            if (IsRowOrColumnSelection(addressString))
            {
                // For row or column selections, return empty string (handled separately in ProcessAtomicAddresses)
                return string.Empty;
            }

            // 1. Split by comma into multiple areas (handling non-contiguous selections)
            string[] areas = addressString.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string area in areas)
            {
                string trimmedArea = area.Trim();

                // Skip row or column selections in individual areas
                if (IsRowOrColumnSelection(trimmedArea))
                {
                    continue;
                }

                // 2. Determine if it's a single cell or a range (contains colon)
                if (trimmedArea.Contains(":"))
                {
                    // It's a contiguous range, expand into independent cells/merged cells
                    var atomicCells = ExpandRangeToAtomicUnits(trimmedArea);
                    result.AddRange(atomicCells);
                }
                else
                {
                    // It's a single cell address, check if it belongs to a merged cell
                    string atomicCell = GetAtomicCellAddress(trimmedArea);
                    result.Add(atomicCell);
                }
            }

            // 3. Remove duplicates (same cell may appear in multiple areas)
            result = result.Distinct().ToList();

            // Return as comma-separated string
            return string.Join(",", result);
        }

        /// <summary>
        /// Determines whether the address string represents a row-only or column-only selection
        /// </summary>
        /// <param name="address">Address string like "1:4", "1:4,6:8", "A:D", "A:C,E:G"</param>
        /// <returns>True if it's a row or column selection, otherwise false</returns>
        private static bool IsRowOrColumnSelection(string address)
        {
            if (string.IsNullOrEmpty(address)) return false;

            // Split by comma to check each area
            string[] areas = address.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string area in areas)
            {
                string trimmedArea = area.Trim();

                // Pattern 1: Row selection (e.g., "1:4", "5:10")
                // Format: number:number
                if (System.Text.RegularExpressions.Regex.IsMatch(trimmedArea, @"^\d+:\d+$"))
                {
                    return true;
                }

                // Pattern 2: Column selection (e.g., "A:D", "A:C", "E:G")
                // Format: letter(s):letter(s) (no digits)
                if (System.Text.RegularExpressions.Regex.IsMatch(trimmedArea, @"^[A-Za-z]+:[A-Za-z]+$"))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Checks if a cell address is within a row or column selection range
        /// </summary>
        /// <param name="cellAddress">Cell address like "A1" or "B5"</param>
        /// <param name="selection">Row/Column selection like "2:3" or "A:D"</param>
        /// <returns>True if the cell is within the selection range</returns>
        private static bool IsCellInRowOrColumnSelection(string cellAddress, string selection)
        {
            try
            {
                // Parse the cell address to get row number and column letter
                string columnLetter = System.Text.RegularExpressions.Regex.Match(cellAddress, @"^[A-Za-z]+").Value;
                string rowNumberStr = System.Text.RegularExpressions.Regex.Match(cellAddress, @"\d+$").Value;

                if (!int.TryParse(rowNumberStr, out int rowNumber))
                {
                    return false;
                }

                // Split the selection by comma to handle multiple areas
                string[] areas = selection.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                foreach (string area in areas)
                {
                    string trimmedArea = area.Trim();

                    // Check row selection (e.g., "2:3")
                    if (System.Text.RegularExpressions.Regex.IsMatch(trimmedArea, @"^\d+:\d+$"))
                    {
                        string[] parts = trimmedArea.Split(':');
                        if (int.TryParse(parts[0], out int startRow) && int.TryParse(parts[1], out int endRow))
                        {
                            if (rowNumber >= startRow && rowNumber <= endRow)
                            {
                                return true;
                            }
                        }
                    }
                    // Check column selection (e.g., "A:D")
                    else if (System.Text.RegularExpressions.Regex.IsMatch(trimmedArea, @"^[A-Za-z]+:[A-Za-z]+$"))
                    {
                        string[] parts = trimmedArea.Split(':');
                        string startCol = parts[0];
                        string endCol = parts[1];

                        // Convert column letters to column numbers for comparison
                        int startColNum = ColumnLetterToNumber(startCol);
                        int endColNum = ColumnLetterToNumber(endCol);
                        int currentColNum = ColumnLetterToNumber(columnLetter);

                        if (currentColNum >= startColNum && currentColNum <= endColNum)
                        {
                            return true;
                        }
                    }
                }
            }
            catch
            {
                return false;
            }

            return false;
        }

        /// <summary>
        /// Converts a column letter to column number (e.g., "A" -> 1, "Z" -> 26, "AA" -> 27)
        /// </summary>
        private static int ColumnLetterToNumber(string columnLetter)
        {
            int result = 0;
            foreach (char c in columnLetter.ToUpper())
            {
                result = result * 26 + (c - 'A' + 1);
            }
            return result;
        }

        /// <summary>
        /// Gets the atomic address for a single cell (handles merged cells)
        /// </summary>
        private static string GetAtomicCellAddress(string cellAddress)
        {
            try
            {
                Excel.Range cell = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellAddress);

                // Check if the cell belongs to a merged cell
                var mergedCell = GetMergedCellRange(cell);
                if (mergedCell != null)
                {
                    string mergedAddress = mergedCell.Address;
                    // Convert from absolute format ($A$1:$B$2) to relative format (A1:B2)
                    string relativeAddress = mergedAddress.Replace("$", "");
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(mergedCell);
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(cell);
                    return relativeAddress;
                }

                System.Runtime.InteropServices.Marshal.ReleaseComObject(cell);
                return cellAddress;
            }
            catch
            {
                // If any error occurs, return the original address
                return cellAddress;
            }
        }

        /// <summary>
        /// Expands a contiguous range (e.g., A1:C5) into independent cell/merged cell addresses
        /// </summary>
        private static List<string> ExpandRangeToAtomicUnits(string rangeAddress)
        {
            var atomicUnits = new List<string>();

            try
            {
                // Get the Range object for the specified range
                Excel.Range range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(rangeAddress);

                int rowIndex = 1;
                int maxRow = range.Rows.Count;
                int maxCol = range.Columns.Count;

                while (rowIndex <= maxRow)
                {
                    int colIndex = 1;
                    while (colIndex <= maxCol)
                    {
                        Excel.Range cell = range.Cells[rowIndex, colIndex];

                        // Check if the cell belongs to a merged cell
                        var mergedCell = GetMergedCellRange(cell);
                        if (mergedCell != null)
                        {
                            // Get merged area address in relative format
                            string mergedAddress = mergedCell.Address.Replace("$", "");
                            if (!atomicUnits.Contains(mergedAddress))
                            {
                                atomicUnits.Add(mergedAddress);
                            }

                            // Calculate how many rows and columns this merged cell occupies
                            int mergedRows = mergedCell.Rows.Count;
                            int mergedCols = mergedCell.Columns.Count;

                            // Skip all columns in the merged area for current row
                            colIndex += mergedCols;

                            // Skip all remaining rows in the merged area
                            // Since merged area spans multiple rows, jump directly to the next row after this merged area
                            if (mergedRows > 1)
                            {
                                // Skip the next (mergedRows - 1) rows
                                rowIndex += (mergedRows - 1);
                                // Break out of the column loop since we're moving to a new row
                                break;
                            }

                            System.Runtime.InteropServices.Marshal.ReleaseComObject(mergedCell);
                        }
                        else
                        {
                            // Not a merged cell, add single cell address
                            string cellAddress = cell.Address.Replace("$", "");
                            atomicUnits.Add(cellAddress);
                            colIndex++;
                        }

                        System.Runtime.InteropServices.Marshal.ReleaseComObject(cell);
                    }
                    rowIndex++;
                }

                System.Runtime.InteropServices.Marshal.ReleaseComObject(range);
            }
            catch (Exception)
            {
                // Fallback handling: return the original address directly
                atomicUnits.Add(rangeAddress);
            }

            return atomicUnits;
        }

        /// <summary>
        /// Gets the merged cell range that the cell belongs to (if it exists)
        /// </summary>
        private static Excel.Range GetMergedCellRange(Excel.Range cell)
        {
            try
            {
                if (cell.MergeCells)
                {
                    // Get the complete range of the merged area
                    Excel.Range mergedArea = cell.MergeArea;
                    return mergedArea;
                }
            }
            catch
            {
                // Some edge cases may cause errors
            }
            return null;
        }

        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        /// <summary>
        /// Excel 選択が変わったとき、直前の選択セルに対する縮小設定を DesignParamList に反映し、lastSelectAddr を更新します。
        /// </summary>
        /// <param name="newAddress">新しい Excel 選択アドレス</param>
        private void CommitLastSelectAddress(String newAddress)
        {
            if (String.IsNullOrEmpty(newAddress))
            {
                return;
            }

            String wPrevious = RldLib.CurrentLayoutData.lastSelectAddr;
            if (!String.IsNullOrEmpty(wPrevious)
                && !String.Equals(wPrevious, newAddress, StringComparison.OrdinalIgnoreCase))
            {
                ProcessAtomicAddresses(wPrevious);
            }

            RldLib.CurrentLayoutData.lastSelectAddr = newAddress;
        }
        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

        /// <summary>
        /// Processes a selection address by parsing it into atomic units and updating the parameter data list for each unit
        /// </summary>
        /// <param name="address">The selection address string (e.g., "A1,B2,C3" or "A1:B5" or "A1,A3:C5,E7")</param>
        public static void ProcessAtomicAddresses(string address)
        {
            // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            if (IsSyncingAtomicAddresses)
            {
                return;
            }

            try
            {
                IsSyncingAtomicAddresses = true;
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

                if (string.IsNullOrEmpty(address)) return;

                // Check if the address is a row or column selection
                if (IsRowOrColumnSelection(address))
                {
                    // Handle row/column selection by checking DesignParamList
                    ProcessRowOrColumnSelection(address);
                    return;
                }

                // 1. Call ParseToAtomicUnits to get comma-separated addresses
                string atomicAddresses = ParseToAtomicUnits(address);

                if (string.IsNullOrEmpty(atomicAddresses)) return;

                // 2. Split by comma to loop through each individual address
                string[] addresses = atomicAddresses.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                // 3. Loop through each address and call UpdateParamDataList
                foreach (string wAddress in addresses)
                {
                    string trimmedAddress = wAddress.Trim();
                    if (!string.IsNullOrEmpty(trimmedAddress))
                    {
                        UpdateParamDataList_s(trimmedAddress);
                    }
                }
            }
            catch (Exception)
            { }
            finally
            {
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                IsSyncingAtomicAddresses = false;
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
            }
        }

        /// <summary>
        /// Processes row or column selection by checking DesignParamList
        /// </summary>
        /// <param name="address">Row or column selection like "2:3" or "A:D"</param>
        private static void ProcessRowOrColumnSelection(string address)
        {
            if (string.IsNullOrEmpty(address)) return;

            // Loop through DesignParamList
            for (int i = 0; i < RldLib.CurrentLayoutData.DesignParamList.Count; i++)
            {
                var designParam = RldLib.CurrentLayoutData.DesignParamList[i];
                string cellAddress = designParam.CellAddress;

                if (string.IsNullOrEmpty(cellAddress)) continue;

                // Check if the cell address is within the row/column selection range
                if (IsCellInRowOrColumnSelection(cellAddress, address))
                {
                    UpdateParamDataList_s(cellAddress);
                }
            }
        }
        // add #12616 データ項目の縮小表示が機能しないことがある 高 end
    }
}
