using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{
    /// <summary>
    /// SYS_DATA_SETデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class SysDataSetData
    {

        #region 内部クラス定義

        /// <summary>
        /// 帳票種別
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class ReportClasses
        {

            #region メンバプロパティ定義

            /// <summary>
            /// 種別コード配列の取得及び設定を行います。
            /// </summary>
            [System.Runtime.Serialization.DataMember(Name = "classes")]
            public int[] Classes { get; set; } = null;

            #endregion
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 作成日時の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "regDate")]
        public string CreateDate { get; set; } = string.Empty;

        /// <summary>
        /// 更新日時の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "upDate")]
        public string UpdateDate { get; set; } = string.Empty;

        /// <summary>
        /// SQLコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "sqlCd")]
        public string SqlCd { get; set; } = string.Empty;

        /// <summary>
        /// DB種別(1:db4, 2:db5, 3:db6)の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dbClass")]
        public int DbClass { get; set; } = 0;

        /// <summary>
        /// detail情報の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "detailInfo")]
        public SysDataSetDetailInfoData DetailInfo { get; set; } = null;

        /// <summary>
        /// 繰返し可否フラグの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "canRepeat")]
        public string CanRepeat { get; set; } = string.Empty;

        /// <summary>
        /// 使用用途の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "useApplication")]
        public string UseApplication { get; set; } = string.Empty;

        /// <summary>
        /// 帳票種別の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "reportClass")]
        public ReportClasses ReportClass { get; set; } = null;

        /// <summary>
        /// メモの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "memo")]
        public string Memo { get; set; } = string.Empty;

        /// <summary>
        /// メモの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "preSqlInfo")]
        public SysDataSetPreSqlInfo PreSqlInfo { get; set; } = null;
        #endregion

    }
}
