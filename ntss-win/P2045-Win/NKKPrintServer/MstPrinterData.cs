using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKPrintServer
{
    /// <summary>
    /// プリンターマスタデータ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class MstPrinterData
    {

        #region メンバプロパティ定義

        /// <summary>
        /// プリンター名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "printerName")]
        public string PrinterName { get; set; } = string.Empty;

        /// <summary>
        /// 表示用プリンター名の取得及び設定を行います
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dispPrinterName")]
        public string DispPrinterName { get; internal set; }

        #endregion

    }
}
