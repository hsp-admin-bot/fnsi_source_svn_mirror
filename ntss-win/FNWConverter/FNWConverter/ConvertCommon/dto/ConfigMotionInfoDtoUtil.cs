using System;
using System.Linq;
using System.IO;

namespace ConvertCommon.dto
{
    /// <summary>
    /// ConfigInfoDtoのラッパークラス
    /// 初期設定・検索に使用する
    /// </summary>
    public static class ConfigMotionInfoDtoUtil
    {
        public static ConfigInfoDto configInfoDto { get; private set; }

        /// <summary>
        /// スタティックコンストラクタ
        /// </summary>
        static ConfigMotionInfoDtoUtil()
        {
            setConvertInfo();
        }

        /// <summary>
        /// ConvertInfo.xmlを設定
        /// </summary>
        private static void setConvertInfo()
        {
            if (false == File.Exists(AppDomain.CurrentDomain.BaseDirectory + @".\SQL\config\ConvertMotionConfig.xml"))
            {
                string msg = "ConvertMotionConfig.xmlの取得に失敗しました。";
                ConvertBase.WriteErrorLog(msg);
                throw new FileNotFoundException(msg);
            }

            using (System.IO.FileStream fs = new System.IO.FileStream(AppDomain.CurrentDomain.BaseDirectory + @".\SQL\config\ConvertMotionConfig.xml", System.IO.FileMode.Open))
            {
                System.Xml.Serialization.XmlSerializer serializer = System.Xml.Serialization.XmlSerializer.FromTypes(new[] { typeof(ConfigInfoDto) })[0];
                configInfoDto = (ConfigInfoDto)serializer.Deserialize(fs);
            }
        }

        /// <summary>
        /// xmlConfigNameを指定してrootNodeTableInfoを取得する
        /// </summary>
        /// <param name="xmlConfigName"></param>
        /// <returns></returns>
        public static rootNodeTableInfo getTableInfoByXmlConfigName(string xmlConfigName)
        {
            rootNodeTableInfo tableInfo = configInfoDto.tableInfo
                .Where(x => x.xmlConfigName.Equals(xmlConfigName))
                .First();
            return tableInfo;
        }
    }
}
