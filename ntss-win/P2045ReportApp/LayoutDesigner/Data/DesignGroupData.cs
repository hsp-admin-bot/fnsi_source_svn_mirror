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
    /// グループデータクラス
    /// </summary>
    public class DesignGroupData : System.ComponentModel.INotifyPropertyChanged
    {
        #region メンバ定数定義

        /// <summary>
        /// ボタン/チェックボックス列の幅
        /// </summary>
        private const Int32 COL_BUTTON_WIDTH = 50;

        #endregion

        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// グループパス
            /// </summary>
            GroupPath = 0,
            /// <summary>
            /// カテゴリ
            /// </summary>
            DataCategory,
            /// <summary>
            /// クラス
            /// </summary>
            DataClass,
            /// <summary>
            /// グループ名
            /// </summary>
            GroupName,
            /// <summary>
            /// 改ページ有無
            /// </summary>
            IsNewPage,
            /// <summary>
            /// フィルタ(編集ボタン)
            /// </summary>
            ButtonEditFilterText,
            /// <summary>
            /// フィルタデータ
            /// </summary>
            FilterData,
            /// <summary>
            /// フィルタ状態
            /// </summary>
            FilterState,
            /// <summary>
            /// フィルタ種別
            /// </summary>
            FilterType,
            /// <summary>
            /// 繰返し回数
            /// </summary>
            RepeatCount,
            /// <summary>
            /// テンプレート内外
            /// </summary>
            IsInTemplete,
            /// <summary>
            /// 改ページ変更可否
            /// </summary>
            CanEditNewPage,
            /// <summary>
            /// フィルタ変更可否
            /// </summary>
            CanEditFilter,
            /// <summary>
            /// EndofColumn
            /// </summary>
            EoC
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// 改ページ有無
        /// </summary>
        private String m_IsNewPage = RldConst.GroupData.VAL_ISNEWPAGE_FALSE;
        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
        private Boolean m_CanEditNewPage = true;
        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        /// <summary>
        /// グループ名
        /// </summary>
        private string m_GroupName = string.Empty;
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
        /// <summary>
        /// フィルタ選択状態
        /// </summary>
        private String m_FilterState = String.Empty;

        /// <summary>
        /// 全プロパティ
        /// </summary>
        private static System.Reflection.PropertyInfo[] m_Properties = typeof(DesignGroupData).GetProperties();

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
            get {
                return DesignGroupData.m_Properties;
            }
        }

        /// <summary>
        /// プロパティ名のキャッシュ
        /// </summary>
        private static Dictionary<EnumDataIndex, String> PropertyNameCache { get; set; } = new Dictionary<EnumDataIndex, String>();

        #endregion

        #region メンバプロパティ定義(データ定義)

        /// <summary>
        /// グループを一意に特定するためのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.GroupPath)]
        public String GroupPath { get; set; } = String.Empty;

        /// <summary>
        /// カテゴリの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataCategory, HeaderText = "カテゴリ")]
        public String DataCategory { get; set; } = String.Empty;

        /// <summary>
        /// クラスの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataClass, HeaderText = "クラス")]
        public String DataClass { get; set; } = String.Empty;

        /// <summary>
        /// グループ名の取得及び設定を行います。#6066  2022-02-09 削除RldGridRCBehaviorの ReadOnly = true 鄭
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
        //[RldGridRCBehavior()]
        // del #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(ReadOnly = true)]
        // del #11501 レイアウトデザイナのユーザビリティ改善 高 end
        // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
        [RldGridRCLayout(Width = 150)]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.GroupName, HeaderText = "グループ")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //public String GroupName { get; set; } = String.Empty;
        public string GroupName
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => m_GroupName;
            [System.Diagnostics.DebuggerStepThrough()]
            set => SetPropertyOfString(ref m_GroupName, value);
        }
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end

        /// <summary>
        /// 改ページ有無変更用チェックボックス列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewCheckBoxColumn), IsDataBind = true)]
        [RldGridRCDataCheckBox(FalseValue = RldConst.GroupData.VAL_ISNEWPAGE_FALSE, TrueValue = RldConst.GroupData.VAL_ISNEWPAGE_TRUE)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 6)]
        [RldGridRCAppearanceCheckBoxAttribute(DisplayIndex = (Int32)EnumDataIndex.IsNewPage, HeaderText = "改頁")]
        [RldGridRCAppearanceDefaultCellStyle(DataNullValue = RldConst.GroupData.VAL_ISNEWPAGE_FALSE, LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public String IsNewPage
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => this.m_IsNewPage;
            [System.Diagnostics.DebuggerStepThrough()]
            set => this.SetPropertyOfString(ref this.m_IsNewPage, value);
        }


        /// <summary>
        /// フィルタ変更用ボタン列を表します。
        /// </summary>
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        [RldGridRCDesign(typeof(DataGridViewButtonColumn), IsDataBind = false)]
        //[RldGridRCBehavior(Resizable = DataGridViewTriState.False, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCBehavior()]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCLayout(Width = COL_BUTTON_WIDTH + 16)]
        //update 8615-15 zhu start
        // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
        //[RldGridRCAppearanceButton(DisplayIndex = (Int32)EnumDataIndex.ButtonEditFilterText, FlatStyle = FlatStyle.Flat, HeaderText = "フィルタ", Text = "選択", ToolTipText = "出力するデータの項目を選択する時はボタンをクリックしてください", UseColumnTextForButtonValue = true,Visible =false)]
        [RldGridRCAppearanceButton(DisplayIndex = (Int32)EnumDataIndex.ButtonEditFilterText, FlatStyle = FlatStyle.Flat, HeaderText = "フィルタ", Text = "選択", ToolTipText = "出力するデータの項目を選択する時はボタンをクリックしてください", UseColumnTextForButtonValue = true, Visible = true)]
        // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
        //update 8615-15 zhu end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        public String ButtonEditFilterText { get; set; } = String.Empty;

        /// <summary>
        /// フィルタデータの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterData)]
        public String FilterData { get; set; } = String.Empty;  

        /// <summary>
        /// フィルタ状態の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start 
        //[RldGridRCBehavior(ReadOnly = true, SortMode = DataGridViewColumnSortMode.NotSortable)]
        //[RldGridRCLayout(Width = 70)]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Width = 75)]
        //update 8615-15 zhu start
        // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
        //[RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterState, HeaderText = "フィルタ\r\n状態",Visible =false)]
        //[RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterState, HeaderText = "フィルタ\r\n状態", Visible = true)]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterState, HeaderText = "状態", Visible = true)]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
        //update 8615-15 zhu end
        public String FilterState
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => this.m_FilterState;
            [System.Diagnostics.DebuggerStepThrough()]
            set => this.SetPropertyOfString(ref this.m_FilterState, value);
        }

        /// <summary>
        /// フィルタ種別の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterType)]
        public String FilterType { get; set; } = String.Empty;

        /// <summary>
        /// 繰返し回数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.RepeatCount)]
        public String RepeatCount { get; set; } = String.Empty;

        /// <summary>
        /// テンプレート内外の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
        //[RldGridRCBehavior(ReadOnly = true, Resizable = DataGridViewTriState.False)]
        //[RldGridRCLayout(Width = COL_BUTTON_WIDTH)]
        [RldGridRCBehavior(ReadOnly = true)]
        [RldGridRCLayout(Width = 86)]
        //[RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.IsInTemplete, HeaderText = "テンプ\r\nレート")]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.IsInTemplete, HeaderText = "テンプレート")]
        // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
        [RldGridRCAppearanceDefaultCellStyle(LayoutAlignment = DataGridViewContentAlignment.MiddleCenter)]
        public String IsInTemplete { get; set; } = RldConst.GroupData.VAL_IS_IN_TEMPLETE_NONE;

        /// <summary>
        /// ダミー列の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior(ReadOnly = true, SortMode = DataGridViewColumnSortMode.NotSortable)]
        [RldGridRCLayout(AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill, FillWeight = 100)]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.EoC, HeaderText = " ")]
        public String EoC { get; set; } = String.Empty;

        #endregion

        #region メンバプロパティ定義(ボタン/チェックボックス使用可否判定)

        /// <summary>
        /// 改ページ有無を変更できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.CanEditNewPage)]
        //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
        public Boolean CanEditNewPage
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get => this.m_CanEditNewPage;
            [System.Diagnostics.DebuggerStepThrough()]
            set => this.SetPropertyOfBool(ref this.m_CanEditNewPage, value);
        }//{ get; set; } = true;
        //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end

        /// <summary>
        /// フィルタ変更ボタンを使用できるかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.CanEditFilter)]
        public Boolean CanEditFilter
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                Boolean wRet = false;

                switch( this.FilterType ) {
                    case RldConst.FilterType.Group.MEDICINE:        // 薬剤
                    case RldConst.FilterType.Group.EQUIP:           // 医材
                    case RldConst.FilterType.Group.PATEVENT:        // イベント
                    case RldConst.FilterType.Group.ADDITION:        // 加算
                    case RldConst.FilterType.Group.DIALDIFF:        // 透析困難コメント
                    case RldConst.FilterType.Group.OBSKIND:         // 観察記録種別
					//add #8615 zhu start
                    case RldConst.FilterType.Group.CATEGORY:
                    case RldConst.FilterType.Group.EXAMINE:
                    case RldConst.FilterType.Group.EXAM_SET:
                    case RldConst.FilterType.Group.WATER_SURVEY:
                    case RldConst.FilterType.Group.INSPECTION:
                    //add #8615 zhu end
                    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                    case RldConst.FilterType.Group.PECEIPT:        // レセプト
                    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                    // add #11625 クラス「指示履歴」の仕様変更② 高 start
                    case RldConst.FilterType.Group.LOGTARGET:     // 指示履歴
                    // add #11625 クラス「指示履歴」の仕様変更② 高 end
                    // add #12006 感染症がフィルタできない 高 start
                    case RldConst.FilterType.Group.INFECTION:     // 感染症
                    // add #12006 感染症がフィルタできない 高 end
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                    case RldConst.FilterType.Group.WQTESTPOINT:     // 水質検査個所
                    case RldConst.FilterType.Group.WQTESTTYPE:      // 水質検査種別
                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                    case RldConst.FilterType.Group.EQUIP_DIA:        // 器材
                    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                        wRet = true;
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
        /// 指定されたデータインデックスのプロパティを取得します。
        /// </summary>
        /// <param name="aIndex"></param>
        /// <returns></returns>
        public static System.Reflection.PropertyInfo GetProperty(EnumDataIndex aIndex)
        {
            System.Reflection.PropertyInfo wRet = null;

            foreach( var wProperty in DesignGroupData.Properties ) {
                var wAttribute = System.Attribute.GetCustomAttribute(wProperty, typeof(RldGridRCAppearanceAttribute), true) as RldGridRCAppearanceAttribute;
                if( wAttribute != null && wAttribute.DisplayIndex == (Int32)aIndex ) {
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
        public static String GetPropertyName(EnumDataIndex aIndex)
        {
            // キャッシュにない場合は取得してキャッシュ
            if( !DesignGroupData.PropertyNameCache.ContainsKey(aIndex) ) {
                var wProp = DesignGroupData.GetProperty(aIndex);
                DesignGroupData.PropertyNameCache.Add(aIndex, wProp.Name);
            }

            return PropertyNameCache[aIndex];
        }

        /// <summary>
        /// グループシートで管理対象とする列一覧の取得を行います。
        /// </summary>
        /// <returns></returns>
        public static System.Collections.Generic.List<EnumDataIndex> GetReadWriteDataList()
        {
            var wRet = new System.Collections.Generic.List<EnumDataIndex>();

            // 保存対象列をセット
            foreach( EnumDataIndex wIndex in Enum.GetValues(typeof(EnumDataIndex)) ) {

                // 不要な列を除外していく
                switch( wIndex ) {
                    case EnumDataIndex.ButtonEditFilterText:
                    case EnumDataIndex.FilterState:
                    case EnumDataIndex.CanEditNewPage:
                    case EnumDataIndex.CanEditFilter:
                    case EnumDataIndex.EoC:
                        continue;
                }

                // 残った場合は追加
                wRet.Add(wIndex);
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義(非公開部)

        /// <summary>
        /// プロパティが変更したことを通知します。
        /// </summary>
        /// <param name="aPropertyName"></param>
        private void FirePropertyChanged([System.Runtime.CompilerServices.CallerMemberName] String aPropertyName = null) => this.PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(aPropertyName));

        /// <summary>
        /// String 型のプロパティの値が変わった場合にプロパティの値を変更し、変更イベントを発行します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aNewValue"></param>
        /// <param name="aPropertyName"></param>
        private void SetPropertyOfString(ref String aTarget, String aNewValue, [System.Runtime.CompilerServices.CallerMemberName] String aPropertyName = null)
        {
            if( aTarget == aNewValue ) return;

            aTarget = aNewValue;
            this.FirePropertyChanged(aPropertyName);
        }

        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
        private void SetPropertyOfBool(ref bool aTarget, bool aNewValue, [System.Runtime.CompilerServices.CallerMemberName] String aPropertyName = null)
        {
            if (aTarget == aNewValue) return;

            aTarget = aNewValue;
            this.FirePropertyChanged(aPropertyName);
        }
        #endregion

    }
}
