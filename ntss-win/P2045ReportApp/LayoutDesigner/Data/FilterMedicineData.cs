using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 薬剤フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterMedicineData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 薬剤分類コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "classCd")]
        public Int64 ClassCode { get; set; } = 0;

        /// <summary>
        /// 薬剤分類名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "className")]
        public String ClassName { get; set; } = String.Empty;

        /// <summary>
        /// 薬剤種別(通常薬剤/調製薬剤)コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "preparation")]
        public Int32 MedicineType { get; set; } = 0;

        /// <summary>
        /// 薬剤種別(通常薬剤/調製薬剤)名の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [System.Runtime.Serialization.IgnoreDataMember()]
        public String MedicineTypeName
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                String wRet = String.Empty;

                switch( this.MedicineType ) {
                    case 1:
                        wRet = @"通常薬剤";
                        break;

                    case 2:
                        wRet = @"調製薬剤";
                        break;
                }

                return wRet;
            }
        }

        /// <summary>
        /// 薬剤コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "medicineCd")]
        public Int64 MedicineCode { get; set; } = 0;

        /// <summary>
        /// 薬剤名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "medicineName")]
        public String MedicineName { get; set; } = String.Empty;

        #endregion
    }
}
