using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// パラメータデータクラス
    /// </summary>
    public class DesignParamData : INotifyPropertyChanged
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
            /// データパス
            /// </summary>
            DataPath = 0,
            /// <summary>
            /// カテゴリ
            /// </summary>
            DataCategory,
            /// <summary>
            /// クラス
            /// </summary>
            DataClass,
            /// <summary>
            /// 項目名
            /// </summary>
            DataName,
            /// <summary>
            /// SQLコード
            /// </summary>
            SqlCode,
            /// <summary>
            /// データ項目コード
            /// </summary>
            DataCode,
            /// <summary>
            /// データ種別
            /// </summary>
            DataType,
            /// <summary>
            /// プレビューデータ
            /// </summary>
            PreviewData,
            /// <summary>
            /// 書式(編集ボタン)
            /// </summary>
            ButtonEditDisplayFormatText,
            /// <summary>
            /// 書式
            /// </summary>
            DisplayFormat,
            /// <summary>
            /// 変換リスト(編集ボタン)
            /// </summary>
            ButtonEditConvertListText,
            /// <summary>
            /// 変換リスト
            /// </summary>
            ConvertList,
            /// <summary>
            /// 繰返し(編集ボタン)
            /// </summary>
            ButtonEditRepeatText,
            /// <summary>
            /// 繰返し可否
            /// </summary>
            CanRepeat,
            /// <summary>
            /// 繰返し回数
            /// </summary>
            RepeatCount,
            /// <summary>
            /// 繰返し場所
            /// </summary>
            RepeatAddress,
            /// <summary>
            /// 縮小して全体を表示
            /// </summary>
            IsShrink,
            /// <summary>
            /// 表示桁数(半角)
            /// </summary>
            Length,
            /// <summary>			
            /// フィルタデータ
            /// </summary>
            FilterData,
            //mod #8615 zhu start
            /// <summary>
            /// フィルタ状態
            /// </summary>
            //FilterState,
            //mod #8615 zhu end
            /// <summary>
            /// フィルタ種別
            /// </summary>
            FilterType,
            /// <summary>
            /// 改ページ有無
            /// </summary>
            IsNewPage,
            /// <summary>
            /// ラベル項目(編集ボタン)
            /// </summary>
            ButtonEditLabelItemText,
            /// <summary>
            /// ラベル項目
            /// </summary>
            LabelItem,
            /// <summary>
            /// 配置場所
            /// </summary>
            CellAddress,
            /// <summary>
            /// グループ名
            /// </summary>
            GroupName,            
            /// <summary>
			/// フィルタ(編集ボタン)
            /// </summary>
            ButtonEditFilterText,
            //mod #8615 zhu start
            /// <summary>
            /// フィルタ状態
            /// </summary>
            FilterState,
            //mod #8615 zhu end
            /// <summary>
            /// グループパス
            /// </summary>
            GroupPath,
            /// <summary>
            /// テンプレート内外
            /// </summary>
            IsInTemplete,
            /// <summary>
            /// 特別な用途に使用するデータ
            /// </summary>
            ParticularInfo,
            /// <summary>
            /// 計算結果かどうか
            /// </summary>
            IsCalcResult,
            /// <summary>
            /// 条件付き書式(編集ボタン)
            /// </summary>
            ButtonEditFormatConditionText,
            /// <summary>
            /// 条件付き書式
            /// </summary>
            FormatCondition,
            /// <summary>
            /// 書式変更可否
            /// </summary>
            CanEditDisplayFormat,
            /// <summary>
            /// 変換リスト変更可否
            /// </summary>
            CanEditConvertList,
            /// <summary>
            /// 繰返し変更可否
            /// </summary>
            CanEditRepeat,
            /// <summary>
            /// 縮小して全体を表示変更可否
            /// </summary>
            CanEditShrink,
            /// <summary>
            /// 文字数変更可否
            /// </summary>
            CanEditLength,
            /// <summary>
            /// フィルタ変更可否
            /// </summary>
            CanEditFilter,
            /// <summary>
            /// 改ページ変更可否
            /// </summary>
            CanEditNewPage,
            /// <summary>
            /// ラベル項目変更可否
            /// </summary>
            CanEditLabelItem,
            /// <summary>
            /// グループ変更可否
            /// </summary>
            CanEditGroupName,
            // add #11535 帳票の汎用バーコード出力対応 高 start
            /// <summary>
			/// フィルタ(編集ボタン)
            /// </summary>
            ButtonEditBarCodeText,
            /// <summary>
            /// バーコード可否
            /// </summary>
            CanBarCode,
            /// <summary>
            /// バーコード
            /// </summary>
            BarCode,
            /// <summary>
            /// バーコード変更可否
            /// </summary>
            CanEditBarCode,
            // add #11535 帳票の汎用バーコード出力対応 高 end
            /// <summary>
            /// EndofColumn
            /// </summary>
            EoC,
            // add 2021-08-30 6009画像 李 start
            IsImage,
            // add 2021-08-30 6009画像 李 end
            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong add
            RowCount,
            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
            // add #10230 コピーした内容がリセットされる 高 start
            DisplayFormatUpdate
            // add #10230 コピーした内容がリセットされる 高 end
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// プレビューデータ
        /// </summary>
        private string m_PreviewData = string.Empty;
        /// <summary>
        /// 表示書式
        /// </summary>
        private string m_DisplayFormat = string.Empty;
        /// <summary>
        /// 変換リスト
        /// </summary>
        private DesignConvertList m_ConvertList = new DesignConvertList();
        /// <summary>
        /// 縮小して全体を表示
        /// </summary>
        private string m_IsShrink = RldConst.ParamData.VAL_ISSHRINK_NONE;
        /// <summary>
        /// 表示文字数
        /// </summary>
        private string m_Lengh = string.Empty;
        //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
        /// <summary>
        /// 表示文字行数
        /// </summary>
        private string m_RowCount = string.Empty;
        //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
        /// <summary>
        /// 改ページ有無
        /// </summary>
        private string m_IsNewPage = RldConst.ParamData.VAL_ISNEWPAGE_FALSE;
        /// <summary>
        /// フィルタ選択状態
        /// </summary>
        private string m_FilterState = string.Empty;
        /// <summary>
        /// グループ名
        /// </summary>
        private string m_GroupName = string.Empty;
        // add #11535 帳票の汎用バーコード出力対応 高 start
        /// <summary>
        /// バーコード
        /// </summary>
        private string m_BarCode = string.Empty;
        // add #11535 帳票の汎用バーコード出力対応 高 end

        /// <summary>
        /// 全プロパティ
        /// </summary>
        private static readonly System.Reflection.PropertyInfo[] m_Properties = typeof(DesignParamData).GetProperties();

        #endregion

        #region 生成と破棄

        /// <summary>
        /// パラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        public DesignParamData() { }

        /// <summary>
        /// (コピーコンストラクタ)
        /// パラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aSrcData"></param>
        public DesignParamData(DesignParamData aSrcData)
        {
            DataPath = aSrcData.DataPath;
            DataCategory = aSrcData.DataCategory;
            DataClass = aSrcData.DataClass;
            DataName = aSrcData.DataName;
            SqlCode = aSrcData.SqlCode;
            DataCode = aSrcData.DataCode;
            DataType = aSrcData.DataType;
            PreviewData = aSrcData.PreviewData;
            ButtonEditDisplayFormatText = aSrcData.ButtonEditDisplayFormatText;
            DisplayFormat = aSrcData.DisplayFormat;
            ButtonEditConvertListText = aSrcData.ButtonEditConvertListText;
            ConvertList = aSrcData.ConvertList;
            ButtonEditRepeatText = aSrcData.ButtonEditRepeatText;
            CanRepeat = aSrcData.CanRepeat;
            RepeatAddress = aSrcData.RepeatAddress;
            //add #8623 【デグレ】項目を配置した際にエラーメッセージが発生 / プレビューデータの不正 董 start 
            CellAddress = aSrcData.CellAddress;
            //add #8623 【デグレ】項目を配置した際にエラーメッセージが発生 / プレビューデータの不正 董 end 
            IsShrink = aSrcData.IsShrink;
            Length = aSrcData.Length;
            ButtonEditFilterText = aSrcData.ButtonEditFilterText;
            FilterData = aSrcData.FilterData;
            FilterType = aSrcData.FilterType;
            IsNewPage = aSrcData.IsNewPage;
            ButtonEditLabelItemText = aSrcData.ButtonEditLabelItemText;
            LabelItem = aSrcData.LabelItem;
            GroupName = aSrcData.GroupName;
            //add #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
            FilterState = aSrcData.FilterState;
            //add #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
            IsInTemplete = aSrcData.IsInTemplete;
            ParticularInfo = aSrcData.ParticularInfo;
            IsCalcResult = aSrcData.IsCalcResult;
            EoC = aSrcData.EoC;
            IsImage = aSrcData.IsImage;
            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
            RowCount = aSrcData.RowCount;
            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong  end
            // add #11535 帳票の汎用バーコード出力対応 高 start
            CanBarCode = aSrcData.CanBarCode;
            BarCode = aSrcData.BarCode;
            ButtonEditBarCodeText = aSrcData.ButtonEditBarCodeText;
            // add #11535 帳票の汎用バーコード出力対応 高 end
            // add #10230 コピーした内容がリセットされる 高 start
            DisplayFormatUpdate = aSrcData.DisplayFormatUpdate;
            // add #10230 コピーした内容がリセットされる 高 end
        }

        #endregion




        #region メンバイベント定義

        /// <summary>
        /// プロパティ値変更通知用イベント
        /// </summary>
        public event PropertyChangedEventHandler PropertyChanged;

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 全てのプロパティを取得します。
        /// </summary>
        public static System.Reflection.PropertyInfo[] Properties
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_Properties;
        }

        /// <summary>
        /// プロパティ名のキャッシュ
        /// </summary>
        private static Dictionary<EnumDataIndex, string> PropertyNameCache { get; set; } = new Dictionary<EnumDataIndex, string>();

        /// <summary>
        /// 繰返しリストの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private List<string> RepeatList { get; } = new List<string>();

        #endregion

        #region メンバプロパティ定義(データ定義)

        /// <summary>
        /// データパスの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Frozen = true, Width = 200)]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataPath, HeaderText = "データ名")]
        public string DataPath { get; set; } = string.Empty;

        /// <summary>
        /// カテゴリの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataCategory)]
        public string DataCategory { get; set; } = string.Empty;

        /// <summary>
        /// クラスの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataClass)]
        public string DataClass { get; set; } = string.Empty;

        /// <summary>
        /// 項目名の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataName)]
        public string DataName { get; set; } = string.Empty;

        /// <summary>
        /// SQLコードの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.SqlCode)]
        public string SqlCode { get; set; } = string.Empty;

        /// <summary>
        /// データ項目コードの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataCode)]
        public string DataCode { get; set; } = string.Empty;

        /// <summary>
        /// データ種別の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataType)]
        public string DataType { get; set; } = string.Empty;

        /// <summary>
        /// プレビューデータの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.PreviewData, HeaderText = "プレビューデータ")]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.PreviewData, HeaderText = "プレビュー")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public string PreviewData
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_PreviewData;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_PreviewData, value);
        }

        /// <summary>
        /// 書式変更用ボタン列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 8)]
        [RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditDisplayFormatText, FlatStyle = FlatStyle.Flat, HeaderText = "書式", Text = "編集", ToolTipText = "情報の候補を変更する時はボタンをクリックしてください", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public string ButtonEditDisplayFormatText { get; set; } = string.Empty;

        /// <summary>
        /// 書式の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DisplayFormat)]
        public string DisplayFormat
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_DisplayFormat;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_DisplayFormat, value);
        }

        /// <summary>
        /// 変換リスト変更用ボタン列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 8)]
        //[RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditConvertListText, FlatStyle = FlatStyle.Flat, HeaderText = "データ\r\n変換", Text = "編集", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditConvertListText, FlatStyle = FlatStyle.Flat, HeaderText = "変換", Text = "編集", UseColumnTextForButtonValue = true)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string ButtonEditConvertListText { get; set; } = string.Empty;

        /// <summary>
        /// 変換リストの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.ConvertList)]
        public DesignConvertList ConvertList
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_ConvertList;
            [System.Diagnostics.DebuggerStepThrough()]
            set
            {
                m_ConvertList = value;
                FirePropertyChanged();
            }
        }

        /// <summary>
        /// 繰返し変更用ボタン列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 8)]
        //[RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditRepeatText, FlatStyle = FlatStyle.Flat, HeaderText = "繰り\r\n返し", Text = "編集", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditRepeatText, FlatStyle = FlatStyle.Flat, HeaderText = "繰返", Text = "編集", UseColumnTextForButtonValue = true)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string ButtonEditRepeatText { get; set; } = string.Empty;

        /// <summary>
        /// 繰返し可能項目かどうかの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanRepeat)]
        public bool CanRepeat { get; set; } = false;

        /// <summary>
        /// 繰返回数の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(ReadOnly = true, Resizable = DataGridViewTriState.False)]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Width = 55)]
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatCount, HeaderText = "繰返\r\n回数")]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatCount, HeaderText = "回数")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleRight)]
        public string RepeatCount
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                string wRet = string.Empty;

                if (RepeatList.Count > 0)
                {
                    wRet = Convert.ToString(RepeatList.Count);
                }

                return wRet;
            }
        }

        /// <summary>
        /// 繰返範囲の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RepeatAddress, HeaderText = "繰返範囲")]
        public string RepeatAddress
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                var wRet = new StringBuilder();

                if (RepeatList.Count > 0)
                {
                    for (int i = 0; i < RepeatList.Count; i++)
                    {
                        wRet.AppendFormat("{0}{1}", RepeatList[i], RldConst.ParamData.SPLITSTR_REPEATADDRESS);
                    }

                    wRet.Length -= 1;
                }

                return wRet.ToString();
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set
            {
                if (string.IsNullOrEmpty(value))
                {
                    return;
                }

                RepeatList.Clear();
                RepeatList.AddRange(GetSplitAddress(value));

                FirePropertyChanged();
                FirePropertyChanged(GetPropertyName(EnumDataIndex.RepeatCount));
            }
        }

        /// <summary>
        /// 該当セルが縮小して全体を表示するように設定されているかどうかの取得及び設定を行います。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewCheckBoxColumn), IsDataBind = true)]
        [RldGridRCDataCheckBox(FalseValue = RldConst.ParamData.VAL_ISSHRINK_NONE, TrueValue = RldConst.ParamData.VAL_ISSHRINK_DONE)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 6)]
        //[RldGridRCAppearanceCheckBox(DisplayIndex = (int)EnumDataIndex.IsShrink, HeaderText = "縮小\r\n表示")]
        [RldGridRCAppearanceCheckBox(DisplayIndex = (int)EnumDataIndex.IsShrink, HeaderText = "縮小")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(DataNullValue = RldConst.ParamData.VAL_ISSHRINK_NONE, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string IsShrink
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_IsShrink;
            [System.Diagnostics.DebuggerStepThrough()]
            set
            {
                if (value == RldConst.ParamData.VAL_ISSHRINK_DONE)
                {
                    Length = string.Empty;
                    //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
                    RowCount = string.Empty;
                    //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
                }
                // add #8586-2 パラメータ属性「表示文字列長」が反映しない xiaosonglei start
                else
                {
                    // 文字列型で縮小表示ではない場合は変更可
                    if (DataType.ToLower() == RldConst.ParamData.VAL_DATATYPE_STRING.ToLower())
                    {
                        using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, CellAddress))
                        {
                            // 格納可能な文字数('0'を1文字として計算)を取得します
                            Length = Convert.ToString(wXlRange.GetStringLength());
                            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
                            RowCount = Convert.ToString(wXlRange.GetStringRowCount());
                            //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
                        }
                    }
                }
                // add #8586-2 パラメータ属性「表示文字列長」が反映しない xiaosonglei end

                SetPropertyOfString(ref m_IsShrink, value);
            }
        }

        /// <summary>
        /// 表示桁数の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False)]
        //[RldGridRCLayout(Width = 80)]
        [RldGridRCLayout(Width = 80)]
        // mod FNSI-表示文字列長（半角）が正しい。現在の仕様では、純粋な文字数で見ているため、バイト数を指定する 孫 start
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.Length, HeaderText = "表示文字数\r\n(半角)")]
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.Length, HeaderText = "表示文字列\r\n長（半角）")]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.Length, HeaderText = "半角字数")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        // mod FNSI-表示文字列長（半角）が正しい。現在の仕様では、純粋な文字数で見ているため、バイト数を指定する 孫 end
        [RldGridRCAppearanceDefaultCellStyle(DataNullValue = "0", BehaviorFormat = "", LayoutAlignment = DataGridViewContentAlignment.MiddleRight)]
        public string Length
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_Lengh;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_Lengh, value);
        }
        //update 8615-14 zhu start

        //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.RowCount)]
        public string RowCount
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_RowCount;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_RowCount, value);
        }
        //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end
        // add #10230 コピーした内容がリセットされる 高 start
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DisplayFormatUpdate)]
        public bool DisplayFormatUpdate { get; set; } = false;
        // add #10230 コピーした内容がリセットされる 高 end

        /// <summary>
        /// フィルタ変更用ボタン列を表します。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        //[RldGridRCBehavior(SortMode = DataGridViewColumnSortMode.NotSortable, ReadOnly = true)]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        //[RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditFilterText, FlatStyle = FlatStyle.Flat, HeaderText = "フィルタ", Text = "選択", ToolTipText = "出力するデータの項目を選択する時はボタンをクリックしてください", UseColumnTextForButtonValue = false)]
        //[RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 16)]
        [RldGridRCAppearanceButton(DisplayIndex = (Int32)EnumDataIndex.ButtonEditFilterText, FlatStyle = FlatStyle.Flat, HeaderText = "フィルタ", Text = "選択", ToolTipText = "出力するデータの項目を選択する時はボタンをクリックしてください", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        //update 8615-14 zhu end
        public string ButtonEditFilterText { get; set; } = string.Empty;

        /// <summary>
        /// フィルタデータの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.FilterData)]
        public string FilterData { get; set; } = string.Empty;

        /// <summary>
        /// フィルタ状態の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(ReadOnly = true, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Width = 75)]
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.FilterState, HeaderText = "フィルタ\r\n状態")]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.FilterState, HeaderText = "状態")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public string FilterState
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_FilterState;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_FilterState, value);
        }

        /// <summary>
        /// フィルタ種別の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.FilterType)]
        public string FilterType { get; set; } = string.Empty;

        /// <summary>
        /// 改ページ有無変更用チェックボックス列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewCheckBoxColumn), IsDataBind = true)]
        [RldGridRCDataCheckBox(FalseValue = RldConst.ParamData.VAL_ISNEWPAGE_FALSE, TrueValue = RldConst.ParamData.VAL_ISNEWPAGE_TRUE)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 6)]
        [RldGridRCAppearanceCheckBox(DisplayIndex = (int)EnumDataIndex.IsNewPage, HeaderText = "改頁")]
        [RldGridRCAppearanceDefaultCellStyle(DataNullValue = RldConst.ParamData.VAL_ISNEWPAGE_FALSE, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public string IsNewPage
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_IsNewPage;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_IsNewPage, value);
        }

        /// <summary>
        /// ラベル項目変更用ボタン列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 10)]
        //[RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditLabelItemText, FlatStyle = FlatStyle.Flat, HeaderText = "ラベル\r\n項目", Text = "編集", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditLabelItemText, FlatStyle = FlatStyle.Flat, HeaderText = "ラベル", Text = "編集", UseColumnTextForButtonValue = true)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string ButtonEditLabelItemText { get; set; } = string.Empty;

        /// <summary>
        /// ラベル項目設定情報の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.LabelItem)]
        public string LabelItem { get; set; } = string.Empty;   // TODO: クラス化

        /// <summary>
        /// 配置場所の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCLayout(Width = 50)]
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CellAddress, HeaderText = "配置\r\n場所")]
        [RldGridRCLayout(Width = 70)]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CellAddress, HeaderText = "セル")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public string CellAddress { get; set; } = string.Empty;

        /// <summary>
        /// グループ名の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout(Width = 150)]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.GroupName, HeaderText = "グループ")]
        public string GroupName
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_GroupName;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_GroupName, value);
        }

        /// <summary>
        /// グループパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.GroupPath)]
        // mon #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2020-08-02 start
        // public string GroupPath => LayoutDataSet.MakeGroupPath(DataCategory, DataClass, GroupName, IsInTemplete);
        public string GroupPath => LayoutDataSet.MakeGroupPath(DataCategory, DataClass, GroupName, IsInTemplete, CellAddress);
        // mon #6066 1つの項目を増やすごとに1つの項目が増えるグループ 鄭  2020-08-02 end


        /// <summary>
        /// テンプレート内外の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(ReadOnly = true, Resizable = DataGridViewTriState.False)]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Width = 86)]
        //[RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.IsInTemplete, HeaderText = "テンプ\r\nレート")]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.IsInTemplete, HeaderText = "テンプレート")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string IsInTemplete { get; set; } = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;

        /// <summary>
        /// 特別な用途に使用する情報の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.ParticularInfo)]
        public string ParticularInfo { get; set; } = string.Empty;

        /// <summary>
        /// 計算結果を出力する項目かどうかの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.IsCalcResult)]
        public bool IsCalcResult { get; set; } = false;

        /// <summary>
        /// ダミー列の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCLayout(AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill, FillWeight = 100)]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.EoC, HeaderText = " ")]
        public string EoC { get; set; } = string.Empty;

        /// <summary>
        /// 条件付き書式設定ボタン列を表します。
        /// </summary>
        // del #11390 【たくしん会】レイアウトデザイナの「条件付き書式」機能は廃止する limingzhe start
        //[RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        // del #11390 【たくしん会】レイアウトデザイナの「条件付き書式」機能は廃止する limingzhe end
        [RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditFormatConditionText, FlatStyle = FlatStyle.Flat, HeaderText = "条件付き書式", Text = "編集", ToolTipText = "情報の候補を変更する時はボタンをクリックしてください", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string ButtonEditFormatConditionText { get; set; } = string.Empty;

        /// <summary>
        /// 条件付き書式の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.FormatCondition)]
        public Data.FormatConditionRules FormatCondition
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get;
            [System.Diagnostics.DebuggerStepThrough()]
            set;
        } = new Data.FormatConditionRules();

        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.IsImage)]
        public string IsImage { get; set; } = string.Empty;

        #endregion

        #region メンバプロパティ定義(ボタン/チェックボックス使用可否判定)

        /// <summary>
        /// 書式変更ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditDisplayFormat)]
        public bool CanEditDisplayFormat
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // データ種別が数値と日付の場合のみ使用可能
                if (string.Compare(DataType, RldConst.ParamData.VAL_DATATYPE_DECIMAL, true) == 0 ||
                    string.Compare(DataType, RldConst.ParamData.VAL_DATATYPE_DATETIME, true) == 0)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// 変換リスト変更ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditConvertList)]
        public bool CanEditConvertList
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // 変換リストが定義されている場合のみ使用可能
                if (ConvertList.Count > 0)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// 繰返し変更ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditRepeat)]
        public bool CanEditRepeat
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // 繰返し可能項目(データ項目リストで設定)の場合のみ使用可能
                if (CanRepeat)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// 縮小して全体を表示するかどうかを変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditShrink)]
        public bool CanEditShrink { get; } = true;

        /// <summary>
        /// 表示桁数を変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditLength)]
        public bool CanEditLength
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // 文字列型で縮小表示ではない場合は変更可
                if (DataType.ToLower() == RldConst.ParamData.VAL_DATATYPE_STRING.ToLower() &&
                    IsShrink == RldConst.ParamData.VAL_ISSHRINK_NONE)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// フィルタ変更ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditFilter)]
        public bool CanEditFilter
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // フィルタ種別が検査系/水質の場合のみ使用可能
                switch (FilterType)
                {
                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    case RldConst.FilterType.Group.MEDICINE:        // 薬剤
                    case RldConst.FilterType.Group.EQUIP:           // 医材
                    case RldConst.FilterType.Group.PATEVENT:        // イベント
                    case RldConst.FilterType.Group.ADDITION:        // 加算
                    case RldConst.FilterType.Group.DIALDIFF:        // 透析困難コメント
                    case RldConst.FilterType.Group.OBSKIND:         // 観察記録種別
                                                                    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end

                    //case RldConst.FilterType.Parameter.EXAMINE:
                    //case RldConst.FilterType.Parameter.EXAM_SET:
                    //case RldConst.FilterType.Parameter.WATER_SURVEY:
                    //// add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                    //case RldConst.FilterType.Parameter.INSPECTION:
                    //// add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                    //// add FNSI-5915 李 start
                    //case RldConst.FilterType.Parameter.CATEGORY:
                    // add FNSI-5915 李 end

                    //add #8615 zhu start
                    case RldConst.FilterType.Group.EXAMINE:
                    case RldConst.FilterType.Group.EXAM_SET:
                    case RldConst.FilterType.Group.WATER_SURVEY:
                    // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                    case RldConst.FilterType.Group.INSPECTION:
                    // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                    case RldConst.FilterType.Group.WQTESTPOINT:
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                    // add FNSI-5915 李 start
                    case RldConst.FilterType.Group.CATEGORY:
                        //add #8615 zhu end

                        wRet = true;
                        break;

                    default:
                        break;
                }

                return wRet;
            }
        }

        /// <summary>
        /// 改ページ有無を変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditNewPage)]
        public bool CanEditNewPage
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // 繰返し可能項目ではなく、データ種別が文字列で縮小表示設定されていない場合のみ使用可能
                if (!CanRepeat &&
                    DataType.ToLower() == RldConst.ParamData.VAL_DATATYPE_STRING &&
                    IsShrink == RldConst.ParamData.VAL_ISSHRINK_NONE)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// ラベル項目変更用ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditLabelItem)]
        public bool CanEditLabelItem
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // 特別な用途に使用する情報が "Label" の場合のみ使用可能
                if (string.CompareOrdinal(ParticularInfo.ToLower(), "label") == 0)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// グループを変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditGroupName)]
        public bool CanEditGroupName
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // 繰返し項目の場合のみ使用可能
                if (CanRepeat)
                {
                    wRet = true;
                }

                return wRet;
            }
        }

        /// <summary>
        /// セル幅
        /// </summary>
        public int CellWidth;

        // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
        /// <summary>
        /// セル幅
        /// </summary>
        public int CellHeight;
        // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

        // add #11294 紹介状で集計部分がずれて出力される 高 start
        public string repDirection = "0";
        // add #11294 紹介状で集計部分がずれて出力される 高 end

        // add #11535 帳票の汎用バーコード出力対応 高 start
        /// <summary>
        /// バーコード変更用ボタン列を表します。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 26)]
        //[RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditBarCodeText, FlatStyle = FlatStyle.Flat, HeaderText = "バー\r\nコード", Text = "編集", UseColumnTextForButtonValue = true)]
        [RldGridRCAppearanceButton(DisplayIndex = (int)EnumDataIndex.ButtonEditBarCodeText, FlatStyle = FlatStyle.Flat, HeaderText = "バーコード", Text = "編集", UseColumnTextForButtonValue = true)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public string ButtonEditBarCodeText { get; set; } = string.Empty;

        /// <summary>
        /// バーコード可能項目かどうかの取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanBarCode)]
        public bool CanBarCode { get; set; } = false;

        /// <summary>
        /// バーコードの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(ReadOnly = true, Resizable = DataGridViewTriState.False)]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Width = 100)]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.BarCode, HeaderText = "バーコード設定")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public string BarCode
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_BarCode;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_BarCode, value);
        }

        /// <summary>
        /// バーコード変更ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.CanEditBarCode)]
        public bool CanEditBarCode
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                bool wRet = false;

                // バーコード項目の場合のみ使用可能
                if (CanBarCode)
                {
                    wRet = true;
                }

                return wRet;
            }
        }
        // add #11535 帳票の汎用バーコード出力対応 高 end

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

            foreach (System.Reflection.PropertyInfo wProperty in Properties)
            {
                var wAttribute = Attribute.GetCustomAttribute(wProperty, typeof(RldGridRCAppearanceAttribute), true) as RldGridRCAppearanceAttribute;
                if (wAttribute != null && wAttribute.DisplayIndex == (int)aIndex)
                {
                    wRet = wProperty;
                    break;
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
            if (!PropertyNameCache.ContainsKey(aIndex))
            {
                System.Reflection.PropertyInfo wProp = GetProperty(aIndex);
                PropertyNameCache.Add(aIndex, wProp.Name);
            }

            return PropertyNameCache[aIndex];
        }

        /// <summary>
        /// パラメータシートで管理対象とする列一覧の取得を行います。
        /// </summary>
        /// <returns></returns>
        public static List<EnumDataIndex> GetReadWriteDataList()
        {
            var wRet = new List<EnumDataIndex>();

            // 保存対象列をセット
            foreach (EnumDataIndex wIndex in Enum.GetValues(typeof(EnumDataIndex)))
            {

                // 不要な列を除外していく
                switch (wIndex)
                {
                    case EnumDataIndex.ButtonEditDisplayFormatText:
                    case EnumDataIndex.ButtonEditConvertListText:
                    case EnumDataIndex.ButtonEditRepeatText:
                    case EnumDataIndex.RepeatCount:
                    case EnumDataIndex.ButtonEditFilterText:
                    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
                    //case EnumDataIndex.FilterState:
                    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
                    case EnumDataIndex.ButtonEditLabelItemText:
                    case EnumDataIndex.GroupPath:
                    case EnumDataIndex.CanEditDisplayFormat:
                    case EnumDataIndex.CanEditConvertList:
                    case EnumDataIndex.CanEditRepeat:
                    case EnumDataIndex.CanEditShrink:
                    case EnumDataIndex.CanEditLength:
                    case EnumDataIndex.CanEditFilter:
                    case EnumDataIndex.CanEditNewPage:
                    case EnumDataIndex.CanEditLabelItem:
                    case EnumDataIndex.CanEditGroupName:
                    case EnumDataIndex.EoC:
                    case EnumDataIndex.ButtonEditFormatConditionText:
                    // add #11535 帳票の汎用バーコード出力対応 高 start
                    case EnumDataIndex.DisplayFormatUpdate:
                    case EnumDataIndex.CanEditBarCode:
                    case EnumDataIndex.ButtonEditBarCodeText:
                    // add #11535 帳票の汎用バーコード出力対応 高 end
                    // add #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 start
                    case EnumDataIndex.FormatCondition:
                    // add #11443 帳票ファイル「パラメータ」シートの未使用箇所対応 高 end
                        continue;
                }

                // 残った場合は追加
                wRet.Add(wIndex);
            }

            return wRet;
        }

        /// <summary>
        /// 繰返し範囲区切り文字で区切られた文字列から
        /// </summary>
        /// <param name="aCombineAddress"></param>
        /// <returns></returns>
        public static IEnumerable<string> GetSplitAddress(string aCombineAddress)
        {
            string[] wAddresses = aCombineAddress.Split(new string[] { RldConst.ParamData.SPLITSTR_REPEATADDRESS }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string wAddress in wAddresses)
            {
                yield return wAddress;
            }
        }

        #endregion

        #region メンバ関数定義(非公開)

        /// <summary>
        /// プロパティが変更したことを通知します。
        /// </summary>
        /// <param name="aPropertyName"></param>
        private void FirePropertyChanged([System.Runtime.CompilerServices.CallerMemberName] string aPropertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(aPropertyName));
        }

        /// <summary>
        /// String 型のプロパティの値が変わった場合にプロパティの値を変更し、変更イベントを発行します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aNewValue"></param>
        /// <param name="aPropertyName"></param>
        private void SetPropertyOfString(ref string aTarget, string aNewValue, [System.Runtime.CompilerServices.CallerMemberName] string aPropertyName = null)
        {
            if (aTarget == aNewValue)
            {
                return;
            }

            aTarget = aNewValue;
            FirePropertyChanged(aPropertyName);
        }

        /// <summary>
        /// Boolean 型のプロパティの値が変わった場合にプロパティの値を変更し、変更イベントを発行します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aNewValue"></param>
        /// <param name="aPropertyName"></param>
        private void SetPropertyOfBoolean(ref bool aTarget, bool aNewValue, [System.Runtime.CompilerServices.CallerMemberName] string aPropertyName = null)
        {
            if (aTarget == aNewValue)
            {
                return;
            }

            aTarget = aNewValue;
            FirePropertyChanged(aPropertyName);
        }

        /// <summary>
        /// RldGridRCAppearanceButton の Text プロパティを取得します。
        /// </summary>
        /// <param name="aPropertyName"></param>
        /// <returns></returns>
        [Obsolete("未使用")]
        private string GetButtonAttributeText([System.Runtime.CompilerServices.CallerMemberName] string aPropertyName = null)
        {
            string wRet = string.Empty;

            System.Reflection.PropertyInfo wProperty = GetType().GetProperty(aPropertyName);
            if (wProperty != null)
            {
                var wAttribute = Attribute.GetCustomAttribute(wProperty, typeof(RldGridRCAppearanceButtonAttribute)) as RldGridRCAppearanceButtonAttribute;
                if (wAttribute != null)
                {
                    wRet = wAttribute.Text;
                }
            }

            return wRet;
        }

        #endregion
    }
}
