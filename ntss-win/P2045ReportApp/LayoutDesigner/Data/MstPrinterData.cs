using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    /// <summary>
    /// プリンターマスタデータ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class MstPrinterData
    {

        /// <summary>
        /// プリンターCDの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "printerCd")]
        public long PrinterCd { get; set; } = long.MinValue;

        /// <summary>
        /// プリンター名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "printerName")]
        public string PrinterName { get; set; } = string.Empty;

        /// <summary>
        /// 表示用プリンター名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dispPrinterName")]
        public string DispPrinterName { get; set; } = string.Empty;

    }
}
