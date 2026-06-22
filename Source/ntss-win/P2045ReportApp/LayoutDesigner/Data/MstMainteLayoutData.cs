using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 日常・定期点検レイアウトマスタデータ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class MstMainteLayoutData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 点検レイアウトコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "menteLayoutCd")]
        public Int64 MenteLayoutCd { get; set; } = 0;

        /// <summary>
        /// レイアウト名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "layoutName")]
        public String LayoutName { get; set; } = String.Empty;

        #endregion
    }
}
