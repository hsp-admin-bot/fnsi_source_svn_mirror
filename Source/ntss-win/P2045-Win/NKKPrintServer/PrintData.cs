using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.Serialization;

namespace NKKPrintServer
{

    /// <summary>
    /// 印刷データ
    /// </summary>
    [DataContract]
    public class PrintData
    {

        /// <summary>
        /// PDFファイル名
        /// </summary>
        [DataMember]
        public string filename { get; set; }

        /// <summary>
        /// PDFファイル名
        /// </summary>
        [DataMember]
        public string bucket { get; set; }

        /// <summary>
        /// プリンタ名
        /// </summary>
        [DataMember]
        public string printerName { get; set; }
        // add #9728,9601 start
        /// <summary>
        /// serviceIp
        /// </summary>
        [DataMember]
        public string serviceIp { get; set; }
        // add #9728,9601 end

    }

}
