using System;
using System.Linq;
using System.IO;

namespace ConvertCommon.dto
{
    /// <summary>
    /// ConfigInfoDtoのラッパークラス
    /// 初期設定・検索に使用する
    /// </summary>
    public static class ConfigInfoDtoUtil
    {
        public static ConfigInfoDto configInfoDto { get; private set; }

        /// <summary>
        /// スタティックコンストラクタ
        /// </summary>
        static ConfigInfoDtoUtil()
        {
            setConvertInfo();
        }

        /// <summary>
        /// ConvertInfo.xmlを設定
        /// </summary>
        private static void setConvertInfo()
        {
            // add 2023-07-06 #8585 マルチスレッド start
            lock (Common.FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                // add FNSI-差分コンバート対応 楊 start
                //if (false == File.Exists(@".\SQL\config\ConvertInfo.xml"))
                if (false == File.Exists(AppDomain.CurrentDomain.BaseDirectory + @".\SQL\config\ConvertInfo.xml"))
                // add FNSI-差分コンバート対応 楊 end
                {
                    string msg = "ConvertInfo.xmlの取得に失敗しました。";
                    ConvertBase.WriteErrorLog(msg);
                    throw new FileNotFoundException(msg);
                }
                // add FNSI-差分コンバート対応 楊 start
                //using (System.IO.FileStream fs = new System.IO.FileStream(@".\SQL\config\ConvertInfo.xml", System.IO.FileMode.Open))
                using (System.IO.FileStream fs = new System.IO.FileStream(AppDomain.CurrentDomain.BaseDirectory + @".\SQL\config\ConvertInfo.xml", System.IO.FileMode.Open))
                {
                    //System.Xml.Serialization.XmlSerializer serializer = new System.Xml.Serialization.XmlSerializer(typeof(ConfigInfoDto));
                    System.Xml.Serialization.XmlSerializer serializer = System.Xml.Serialization.XmlSerializer.FromTypes(new[] { typeof(ConfigInfoDto) })[0];
                    // add FNSI-差分コンバート対応 楊 end
                    configInfoDto = (ConfigInfoDto)serializer.Deserialize(fs);
                }
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }

        /// <summary>
        /// 設定XMLを取得し・DTOに設定して返す
        /// </summary>
        public static ConfigInfoDto getConfigXml(string filePath)
        {
            // add 2023-07-06 #8585 マルチスレッド start
            lock (Common.FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                if (false == File.Exists(filePath))
                {
                    string msg = filePath + "が存在しません。";
                    ConvertBase.WriteErrorLog(msg);
                    throw new FileNotFoundException(msg);
                }
                ConfigInfoDto configInfoDto;
                using (System.IO.FileStream fs = new System.IO.FileStream(filePath, System.IO.FileMode.Open))
                {
                    System.Xml.Serialization.XmlSerializer serializer = System.Xml.Serialization.XmlSerializer.FromTypes(new[] { typeof(ConfigInfoDto) })[0];
                    configInfoDto = (ConfigInfoDto)serializer.Deserialize(fs);
                }
                return configInfoDto;
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }

        /// <summary>
        /// NTSSテーブル名を指定してrootNodeTableInfoを取得する
        /// </summary>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        public static rootNodeTableInfo getTableInfo(string ntssTableName)
        {
            rootNodeTableInfo tableInfo = configInfoDto.tableInfo
                .Where(x => x.ntssTableName.Equals(ntssTableName))
                .First();
            return tableInfo;
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

        /// <summary>
        /// MstSelectorの処理対象のテーブルか判定
        /// </summary>
        /// <param name="ntssTableName"></param>
        /// <returns></returns>
        public static bool isNeedMstSelector(string ntssTableName)
        {
            bool ret = configInfoDto.tableInfo
                .Where(x => x.ntssTableName.Equals(ntssTableName))
                .Any(x => !(string.IsNullOrEmpty(x.mstSelectorCode)) && !(string.IsNullOrEmpty(x.mstSelectorName)));

            return ret;
        }

    }
}
