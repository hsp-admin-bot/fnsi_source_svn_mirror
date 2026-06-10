using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// フィルタフィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterReceiptData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// データ種別コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "classCd")]
        public Int64 ClassCode { get; set; } = 0;

        /// <summary>
        /// データ種別名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "className")]
        public String ClassName { get; set; } = String.Empty;

        /// <summary>
        /// データ分類コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "kindCd")]
        public Int64 KindCode { get; set; } = 0;

        /// <summary>
        /// データ分類名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "kindName")]
        public String KindName { get; set; } = String.Empty;

        /// <summary>
        /// 項目コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "receiptCd")]
        public Int64 ReceiptCode { get; set; } = 0;

        /// <summary>
        /// 項目名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "receiptName")]
        public String ReceiptName { get; set; } = String.Empty;

        #endregion
    }
}
