namespace FNSICloudConvertClient.Models
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 施設情報
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class FacilityInfo
    {
        /// <summary>施設コード</summary>
        public string FacilityCd { get; set; } = string.Empty;

        /// <summary>施設名称</summary>
        public string FacilityName { get; set; } = string.Empty;

        public override string ToString()
        {
            return string.Format("[{0}] {1}", FacilityCd, FacilityName);
        }
    }
}
