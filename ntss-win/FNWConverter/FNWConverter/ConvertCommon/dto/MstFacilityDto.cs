

namespace ConvertCommon.dto
{
     public class MstFacilityDto
    {


        public string no { get; set; }
        /// <summary>
        /// 施設コード
        /// </summary>
        public string facilityCd { get; set; }

        /// <summary>
        /// 施設名
        /// </summary>
        public string facilityName { get; set; }

        /// <summary>
        /// 日次処理の延長を控えます('0：実行中、１：停止)
        /// </summary>
        public string isSchextException { get; set; }
    }
}
