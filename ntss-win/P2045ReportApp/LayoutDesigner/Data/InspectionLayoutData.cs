using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    public class InspectionLayoutData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 帳票区分の取得及び設定を行います。
        /// </summary>
        public String ReportType { get; set; } = String.Empty;

        /// <summary>
        /// 用途CDの取得及び設定を行います。
        /// </summary>
        public String UseCD { get; set; } = String.Empty;

		// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        ///// <summary>
        ///// 記録簿CDの取得及び設定を行います。
        ///// </summary>
        //public String RecordCD { get; set; } = String.Empty;

        ///// <summary>
        ///// 点検レイアウトCDの取得及び設定を行います。
        ///// </summary>
        //public String LayoutCD { get; set; } = String.Empty;

        /// <summary>
        /// 型式CDの取得及び設定を行います。
        /// </summary>
        public String MachineTypeCD { get; set; } = String.Empty;
		// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        #endregion
    }
}
