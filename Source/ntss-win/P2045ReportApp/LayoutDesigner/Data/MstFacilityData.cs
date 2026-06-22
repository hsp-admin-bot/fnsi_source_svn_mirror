using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 施設データ
    /// </summary>
    public class MstFacilityData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 施設コード
        /// </summary>
        public String facilityCd { get; set; } = String.Empty;

        /// <summary>
        /// 施設名
        /// </summary>
        public String facilityName { get; set; } = String.Empty;

        #endregion
    }
}
