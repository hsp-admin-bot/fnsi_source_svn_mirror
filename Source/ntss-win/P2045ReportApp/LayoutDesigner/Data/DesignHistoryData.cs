using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// 変更履歴データ
    /// </summary>
    public class DesignHistoryData
    {
        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// 編集者
            /// </summary>
            Editor = 0,
            /// <summary>
            /// 編集日時
            /// </summary>
            EditTime,
            /// <summary>
            /// データ名
            /// </summary>
            DataName,
            /// <summary>
            /// 座標
            /// </summary>
            Address,
            /// <summary>
            /// 内容
            /// </summary>
            Content
        }

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// 全プロパティ
        /// </summary>
        private static System.Reflection.PropertyInfo[] m_Properties = typeof(DesignHistoryData).GetProperties();

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 全てのプロパティを取得します。
        /// </summary>
        public static System.Reflection.PropertyInfo[] Properties
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return DesignHistoryData.m_Properties;
            }
        }

        /// <summary>
        /// プロパティ名のキャッシュ
        /// </summary>
        private static Dictionary<EnumDataIndex, String> PropertyNameCache { get; set; } = new Dictionary<EnumDataIndex, String>();

        #endregion

        #region メンバプロパティ定義(データ定義)

        /// <summary>
        /// 編集者の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout(Width = 50)]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.Editor, HeaderText = "編集者")]
        public String Editor { get; set; } = String.Empty;

        /// <summary>
        /// 編集日時の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.EditTime, HeaderText = "編集日時")]
        public String EditTime { get; set; } = String.Empty;

        /// <summary>
        /// データ名の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DataName, HeaderText = "データ名")]
        public String DataName { get; set; } = String.Empty;

        /// <summary>
        /// 座標の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout(Width = 50)]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.Address, HeaderText = "座標")]
        public String Address { get; set; } = String.Empty;

        /// <summary>
        /// 内容の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout(AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill)]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.Content, HeaderText = "内容")]
        [RldGridRCAppearanceDefaultCellStyle(LayoutWrapMode = DataGridViewTriState.True)]
        public String Content { get; set; } = String.Empty;

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

            foreach( var wProperty in DesignHistoryData.Properties ) {
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
            if( !DesignHistoryData.PropertyNameCache.ContainsKey(aIndex) ) {
                var wProp = DesignHistoryData.GetProperty(aIndex);
                DesignHistoryData.PropertyNameCache.Add(aIndex, wProp.Name);
            }

            return PropertyNameCache[aIndex];
        }

        #endregion
    }
}
