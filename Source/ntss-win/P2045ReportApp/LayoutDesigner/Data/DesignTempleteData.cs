using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// テンプレート繰返し設定データクラス
    /// </summary>
    public class DesignTempleteData
    {
        #region メンバ定数定義

        /// <summary>
        /// ボタン/チェックボックス列の幅
        /// </summary>
        private const int COL_BUTTON_WIDTH = 50;

        #endregion

        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// 範囲
            /// </summary>
            Range = 0,
            /// <summary>
            /// 範囲左上行番号
            /// </summary>
            RangeRowNo,
            /// <summary>
            /// 範囲左上列番号
            /// </summary>
            RangeColumnNo,
            /// <summary>
            /// サイズ
            /// </summary>
            Size,
            /// <summary>
            /// 行数
            /// </summary>
            RowCount,
            /// <summary>
            /// 列数
            /// </summary>
            ColumnCount,
            /// <summary>
            /// 繰返回数(縦)
            /// </summary>
            RepeatCountV,
            /// <summary>
            /// 繰返回数(横)
            /// </summary>
            RepeatCountH,
            /// <summary>
            /// 余白(縦)
            /// </summary>
            MarginV,
            /// <summary>
            /// 余白(横)
            /// </summary>
            MarginH,
            /// <summary>
            /// 繰返方向(コンボボックス)
            /// </summary>
            ComboBoxEditDirectionText,
            /// <summary>
            /// 繰返方向
            /// </summary>
            DirectionData,
            /// <summary>
            /// 改ページ
            /// </summary>
            IsNewPage,
            /// <summary>
            /// 繰返しモード(コンボボックス)
            /// </summary>
            ComboBoxEditRepeatModeText,
            /// <summary>
            /// 繰返しモード
            /// </summary>
            RepeatMode,
            /// <summary>
            /// 繰返方向変更可否
            /// </summary>
            CanEditDirection,
            /// <summary>
            /// 改ページ変更可否
            /// </summary>
            CanEditNewPage,
            /// <summary>
            /// 繰返しモード変更可否
            /// </summary>
            CanEditRepeatMode,
            /// <summary>
            //add #8763 zhu start
            /// <summary>
            /// 繰返しモード変更可否
            /// </summary>
            CanEditRepeatNo,
            /// <summary>
            /// 繰返しモード
            /// </summary>
            RepeatNo,
            /// <summary>
            /// 繰り返しキー
            /// </summary>
            ComboBoxEditRepeatNo,
            //add #8763 zhu end
            /// 繰返し開始セル位置リスト
            /// </summary>
            RepeatStartPosList,
            /// <summary>
            /// EndofColumn
            /// </summary>
            EoC
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// 全プロパティ
        /// </summary>
        private static System.Reflection.PropertyInfo[] m_Properties = typeof(DesignTempleteData).GetProperties();

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 全てのプロパティを取得します。
        /// </summary>
        public static System.Reflection.PropertyInfo[] Properties
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return DesignTempleteData.m_Properties;
            }
        }

        /// <summary>
        /// プロパティ名のキャッシュ
        /// </summary>
        private static Dictionary<EnumDataIndex, string> PropertyNameCache { get; set; } = new Dictionary<EnumDataIndex, string>();

        #endregion

        #region メンバプロパティ定義(データ定義)

        /// <summary>
        /// 繰返範囲の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.Range, HeaderText = "範囲")]
        public string Range { get; set; } = string.Empty;

        /// <summary>
        /// 繰返範囲の左上行番号の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RangeRowNo)]
        public int RangeRowNo { get; set; } = 1;

        /// <summary>
        /// 繰返範囲の左上列番号の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RangeColumnNo)]
        public int RangeColumnNo { get; set; } = 1;

        /// <summary>
        /// 繰返サイズの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.Size, HeaderText = "サイズ")]

        // mod #9157 FNW帳票取り込み時の不正 董昊 start
        //public string Size => string.Format("縦{0} × 横{1}", this.RowCount, this.ColumnCount);
        //public string Size1 => string.Format("縦{0} × 横{1}", this.SizeRowCount, this.SizeColumnCount);

        public string Size {

            get {
                string size = string.Empty;

                if (this.SizeRowCount == 0 && this.SizeColumnCount == 0)
                {
                    size = string.Format("縦{0} × 横{1}", this.RowCount, this.ColumnCount);
                }
                else
                {
                    size = string.Format("縦{0} × 横{1}", this.SizeRowCount, this.SizeColumnCount);
                }

                return size;
            }
        }
        // mod #9157 FNW帳票取り込み時の不正 董昊 start
        /// <summary>
        /// 行数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RowCount)]
        public int RowCount { get; set; } = 0;

        /// <summary>
        /// 列数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.ColumnCount)]
        public int ColumnCount { get; set; } = 0;

        // add #9157 FNW帳票取り込み時の不正 董昊 start
        /// <summary>
        /// サイズ行数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RowCount)]
        public int SizeRowCount { get; set; } = 0;

        /// <summary>
        /// サイズ列数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.ColumnCount)]
        public int SizeColumnCount { get; set; } = 0;
        // add #9157 FNW帳票取り込み時の不正 董昊 end

        /// <summary>
        /// 縦方向への繰返回数の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatCountV, HeaderText = "繰返回数(縦)")]
        public string RepeatCountV { get; set; } = "1";

        /// <summary>
        /// 横方向への繰返回数の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatCountH, HeaderText = "繰返回数(横)")]
        public string RepeatCountH { get; set; } = "1";

        /// <summary>
        /// 縦方向の余白の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.MarginV, HeaderText = "余白(縦)")]
        public string MarginV { get; set; } = "0";

        /// <summary>
        /// 横方向の余白の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.MarginH, HeaderText = "余白(横)")]
        public string MarginH { get; set; } = "0";

        /// <summary>
        /// 繰返方向変更用コンボボックス列を表します。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewComboBoxColumn), IsDataBind = false)]
        [RldGridRCBehaviorComboBox()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceComboBox(DisplayIndex = (int)EnumDataIndex.ComboBoxEditDirectionText, DisplayStyle = DataGridViewComboBoxDisplayStyle.ComboBox, DisplayStyleForCurrentCellOnly = true, FlatStyle = FlatStyle.Flat, HeaderText = "繰返方向")]
        public string ComboBoxEditDirectionText { get; set; } = string.Empty;

        /// <summary>
        /// 繰返方向の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehaviorComboBox()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceComboBox(DisplayIndex = (int)EnumDataIndex.DirectionData)]
        public string DirectionData { get; set; } = RldConst.TempleteData.VAL_DIRECTION_N;

        /// <summary>
        /// 改ページ有無変更用チェックボックス列を表します。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewCheckBoxColumn), IsDataBind = true)]
        [RldGridRCDataCheckBox(FalseValue = RldConst.TempleteData.VAL_ISNEWPAGE_FALSE, TrueValue = RldConst.TempleteData.VAL_ISNEWPAGE_TRUE)]
        [RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCAppearanceCheckBox(DisplayIndex = (int)EnumDataIndex.IsNewPage, HeaderText = "改頁")]
        [RldGridRCAppearanceDefaultCellStyle(DataNullValue = RldConst.TempleteData.VAL_ISNEWPAGE_FALSE, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string IsNewPage { get; set; } = RldConst.TempleteData.VAL_ISNEWPAGE_FALSE;

        /// <summary>
        /// 繰返方向変更用コンボボックス列を表します。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewComboBoxColumn), IsDataBind = false)]
        [RldGridRCBehaviorComboBox()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceComboBox(DisplayIndex = (int)EnumDataIndex.ComboBoxEditRepeatModeText, DisplayStyle = DataGridViewComboBoxDisplayStyle.ComboBox, DisplayStyleForCurrentCellOnly = true, FlatStyle = FlatStyle.Flat, HeaderText = "抽出条件")]
        public string ComboBoxEditRepeatMode { get; set; } = string.Empty;

        /// <summary>
        /// 繰返しモードの取得及び設定を行います。取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatMode)]
        public string RepeatMode { get; set; } = RldConst.TempleteData.VAL_REPEAT_MODE_NONE;
        //add #8763 zhu start
        /// <summary>
        /// 繰り返しキーkey
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewComboBoxColumn), IsDataBind = false)]
        [RldGridRCBehaviorComboBox()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceComboBox(DisplayIndex = (int)EnumDataIndex.ComboBoxEditRepeatNo, DisplayStyle = DataGridViewComboBoxDisplayStyle.ComboBox, DisplayStyleForCurrentCellOnly = true, FlatStyle = FlatStyle.Flat, HeaderText = "繰り返しキー")]
        public string ComboBoxEditRepeatNo { get; set; } = string.Empty;

        /// <summary>
        /// 繰り返しキーkey。取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatNo)]
        public string RepeatNo { get; set; } = RldConst.TempleteData.VAL_REPEAT_NO_NONE;

        /// <summary>
        /// 繰り返しキーkeyを変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (int)EnumDataIndex.CanEditRepeatNo)]
        public bool CanEditRepeatNo => false;

        /// <summary>
        /// ダミー列の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCLayout(AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill, FillWeight = 100)]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.EoC, HeaderText = " ")]
        public string EoC { get; set; } = string.Empty;

        #endregion

        #region メンバプロパティ定義(ボタン/チェックボックス使用可否判定)

        /// <summary>
        /// 繰返方向を変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (int)EnumDataIndex.CanEditDirection)]
        public bool CanEditDirection => true;

        /// <summary>
        /// 改ページ有無を変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditNewPage)]
        public bool CanEditNewPage => true;

        /// <summary>
        /// 繰返しモードを変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (int)EnumDataIndex.CanEditRepeatMode)]
        public bool CanEditRepeatMode => false;

        /// <summary>
        /// テンプレートを配置する開始セルリストの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatStartPosList)]
        public List<System.Drawing.Point> RepeatStartPosList
        {

            get {
                var wRet = new List<System.Drawing.Point>();

                int wMarginV = RldLib.ConvertStrToInt32(this.MarginV, false);
                int wMarginH = RldLib.ConvertStrToInt32(this.MarginH, false);
                int wRowCntAll = RldLib.ConvertStrToInt32(this.RepeatCountV, false);
                int wColCntAll = RldLib.ConvertStrToInt32(this.RepeatCountH, false);

                // wRetオブジェクトにセル位置を追加するローカル関数
                void addPoint(int rowCount, int colCount)
                {
                    int wRowNo = this.RangeRowNo + ((this.RowCount + wMarginV) * rowCount);
                    int wColNo = this.RangeColumnNo + ((this.ColumnCount + wMarginH) * colCount);

                    // wRetオブジェクトにセル位置を追加する
                    wRet.Add(new System.Drawing.Point(wColNo, wRowNo));
                }

                if (this.DirectionData.Equals(RldConst.TempleteData.VAL_DIRECTION_Z))
                {
                    // Z型の場合
                    // 行のループ
                    for (int wRowCnt = 0; wRowCnt < wRowCntAll; wRowCnt++)
                    {
                        // 列のループ
                        for(int wColCnt = 0; wColCnt < wColCntAll; wColCnt++ ) {

                            // 初回は自分自身のためスキップ
                            if( wRowCnt == 0 && wColCnt == 0 ) continue;

                            // wRetオブジェクトにセル位置を追加する
                            addPoint(wRowCnt, wColCnt);

                        }
                    }
                }
                else
                {
                    // N型の場合
                    // 列のループ
                    for (int wColCnt = 0; wColCnt < wColCntAll; wColCnt++)
                    {
                        // 行のループ
                        for(int wRowCnt = 0; wRowCnt < wRowCntAll; wRowCnt++ ) {

                            // 初回は自分自身のためスキップ
                            if( wRowCnt == 0 && wColCnt == 0 ) continue;

                            // wRetオブジェクトにセル位置を追加する
                            addPoint(wRowCnt, wColCnt);

                        }
                    }
                }

                return wRet;
            }
        }

        #endregion

        #region メンバ関数定義(公開部)

        /// <summary>
        /// 指定されたデータインデックスのプロパティを取得します。
        /// </summary>
        /// <param name="aIndex"></param>
        /// <returns></returns>
        public static System.Reflection.PropertyInfo GetProperty(EnumDataIndex aIndex)
        {
            System.Reflection.PropertyInfo wRet = null;

            foreach( var wProperty in DesignTempleteData.Properties ) {
                var wAttribute = System.Attribute.GetCustomAttribute(wProperty, typeof(RldGridRCAppearanceAttribute), true) as RldGridRCAppearanceAttribute;
                if( wAttribute != null && wAttribute.DisplayIndex == (int)aIndex ) {
                    wRet = wProperty; break;
                }
            }

            return wRet;
        }

        /// <summary>
        /// 指定されたデータインデックスのプロパティ名を取得します。
        /// </summary>
        /// <param name="aIndex"></param>
        /// <returns></returns>
        public static string GetPropertyName(EnumDataIndex aIndex)
        {
            // キャッシュにない場合は取得してキャッシュ
            if( !DesignTempleteData.PropertyNameCache.ContainsKey(aIndex) ) {
                var wProp = DesignTempleteData.GetProperty(aIndex);
                DesignTempleteData.PropertyNameCache.Add(aIndex, wProp.Name);
            }

            return PropertyNameCache[aIndex];
        }

        /// <summary>
        /// 繰返方向コンボボックスセルに選択リストをセットします。
        /// </summary>
        /// <param name="aCell"></param>
        public static void SetDirectionComboBoxItem(ref DataGridViewCell aCell)
        {
            // コンボボックスセルではない場合は抜ける
            if( !(aCell is DataGridViewComboBoxCell wCell) ) return;

            wCell.DisplayMember = "Value";
            wCell.ValueMember = "Code";
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_DIRECTION_N, Value = string.Format("{0}型", RldConst.TempleteData.VAL_DIRECTION_N) });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_DIRECTION_Z, Value = string.Format("{0}型", RldConst.TempleteData.VAL_DIRECTION_Z) });
        }

        /// <summary>
        /// 抽出条件コンボボックスセルに選択リストをセットします。
        /// </summary>
        /// <param name="aCell"></param>
        public static void SetRepeatModeComboBoxItem(ref DataGridViewCell aCell)
        {
            // コンボボックスセルではない場合は抜ける
            if( !(aCell is DataGridViewComboBoxCell wCell) ) return;

            wCell.DisplayMember = "Value";
            wCell.ValueMember = "Code";
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_NONE, Value = string.Empty });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_MODE_DIALYSIS, Value = "透析日" });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_MODE_EXAMIN, Value = "検査日" });
            //add #8763-3 zhu start            
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_MODE_PRESCRIPTIONNO, Value = "処方箋交付日" });            
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_MODE_RESULTCD, Value = "放射線検査日" });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_MODE_MAINTENO, Value = "点検日" });
            //add #8763-3 zhu end
            // add #10605 観察記録がテンプレート繰返しされない 高 start
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_MODE_EVENTSTARTDATE, Value = "イベント開始日" });
            // add #10605 観察記録がテンプレート繰返しされない 高 end
        }
        //add #8763 zhu start
        /// <summary>
        /// 抽出条件コンボボックスセルに選択リストをセットします。
        /// </summary>
        /// <param name="aCell"></param>
        public static void SetRepeatNoComboBoxItem(ref DataGridViewCell aCell)
        {
            // コンボボックスセルではない場合は抜ける
            if (!(aCell is DataGridViewComboBoxCell wCell)) return;

            wCell.DisplayMember = "Value";
            wCell.ValueMember = "Code";
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_NONE, Value = string.Empty });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_ORDNO, Value = "治療番号" });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_PRESCRIPTIONNO, Value = "処方番号" });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_MAINCD, Value = "検査番号" });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_RESULTCD, Value = "放射線検査番号" });
            wCell.Items.Add(new DesignComboBoxItemData() { Code = RldConst.TempleteData.VAL_REPEAT_NO_MAINTENO, Value = "点検番号" });
        }
        #endregion
    }
}
