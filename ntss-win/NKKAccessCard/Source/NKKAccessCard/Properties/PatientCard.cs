using System;
using Newtonsoft.Json;

namespace NKKAccessCardLib.Properties
{
    public class PatientCard
    {
        public static void main()
        {
        
        }
    }

    public class CardSettingItem
    {
        public string JsonField;
        public string Spec;
        public int BeginOffset;
        public int StorageSize;

        public CardSettingItem(string jsonField, string spec, int beginOffset, int storageSize)
        {
            JsonField = jsonField;
            Spec = spec;
            BeginOffset = beginOffset;
            StorageSize = storageSize;
        }
    }

    public class CardSetting
    {
        /// <summary>
        /// チェックサム（体重関連）
        /// </summary>
        [JsonProperty(PropertyName = "weight_checksum")]
        public string WeightChecksum;

        /// <summary>
        /// 前体重
        /// </summary>
        [JsonProperty(PropertyName = "weight_before")]
        public string WeightBefore;

        /// <summary>
        /// 体重測定値
        /// </summary>
        [JsonProperty(PropertyName = "weight_mea")]
        public string WeightMeasure;

        /// <summary>
        /// 体重値使用済みフラグ
        /// </summary>
        [JsonProperty(PropertyName = "weight_body_flag")]
        public string WightBodyFlag;

        /// <summary>
        /// チェックサム（設定関連）
        /// </summary>
        [JsonProperty(PropertyName = "setting_checksum")]
        public string SettingChecksum;

        /// <summary>
        /// データVer.
        /// </summary>
        [JsonProperty(PropertyName = "data_ver")]
        public string DataVersion;

        /// <summary>
        /// 治療モード
        /// </summary>
        [JsonProperty(PropertyName = "treat_mode")]
        public string TreatMode;

        /// <summary>
        /// 透析時間
        /// </summary>
        [JsonProperty(PropertyName = "dialysis_time")]
        public string DialysisTime;

        /// <summary>
        /// 目標体重
        /// </summary>
        [JsonProperty(PropertyName = "target_weight")]
        public string TargetWeight;

        /// <summary>
        /// 除水補正値1 名称
        /// </summary>
        [JsonProperty(PropertyName = "water_info_name_1")]
        public string WaterInfoName1;
     
        /// <summary>
        /// 除水補正値2 名称
        /// </summary>
        [JsonProperty(PropertyName = "water_info_name_2")]
        public string WaterInfoName2;
        
        /// <summary>
        /// 除水補正値3 名称
        /// </summary>
        [JsonProperty(PropertyName = "water_info_name_3")]
        public string WaterInfoName3;
        
        /// <summary>
        /// 除水補正値4 名称
        /// </summary>
        [JsonProperty(PropertyName = "water_info_name_4")]
        public string WaterInfoName4;
        
        /// <summary>
        /// 除水補正値5 名称
        /// </summary>
        [JsonProperty(PropertyName = "water_info_name_5")]
        public string WaterInfoName5;

        /// <summary>
        /// 除水補正値1 重量
        /// </summary>
        [JsonProperty(PropertyName = "water_info_weight_1")]
        public string WaterInfoWeight1;
        
        /// <summary>
        /// 除水補正値2 重量
        /// </summary>
        [JsonProperty(PropertyName = "water_info_weight_2")]
        public string WaterInfoWeight2;
        
        /// <summary>
        /// 除水補正値3 重量
        /// </summary>
        [JsonProperty(PropertyName = "water_info_weight_3")]
        public string WaterInfoWeight3;
        
        /// <summary>
        /// 除水補正値4 重量
        /// </summary>
        [JsonProperty(PropertyName = "water_info_weight_4")]
        public string WaterInfoWeight4;
        
        /// <summary>
        /// 除水補正値5 重量
        /// </summary>
        [JsonProperty(PropertyName = "water_info_weight_5")]
        public string WaterInfoWeight5;

        /// <summary>
        /// 風袋補正値1 名称
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_name_1")]
        public string IndTareInfoName1;
        
        /// <summary>
        /// 風袋補正値2 名称
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_name_2")]
        public string IndTareInfoName2;
        
        /// <summary>
        /// 風袋補正値3 名称
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_name_3")]
        public string IndTareInfoName3;
        
        /// <summary>
        /// 風袋補正値4 名称
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_name_4")]
        public string IndTareInfoName4;
        
        /// <summary>
        /// 風袋補正値5 名称
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_name_5")]
        public string IndTareInfoName5;

        /// <summary>
        /// 風袋補正値1 重量
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_weight_1")]
        public string IndTareInfoWeight1;
        
        /// <summary>
        /// 風袋補正値2 重量
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_weight_2")]
        public string IndTareInfoWeight2;
        
        /// <summary>
        /// 風袋補正値3 重量
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_weight_3")]
        public string IndTareInfoWeight3;
        
        /// <summary>
        /// 風袋補正値4 重量
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_weight_4")]
        public string IndTareInfoWeight4;
        
        /// <summary>
        /// 風袋補正値5 重量
        /// </summary>
        [JsonProperty(PropertyName = "ind_tare_info_weight_5")]
        public string IndTareInfoWeight5;
    }
}