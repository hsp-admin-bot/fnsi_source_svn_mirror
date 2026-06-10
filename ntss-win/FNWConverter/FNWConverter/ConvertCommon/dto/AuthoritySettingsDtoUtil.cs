using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using ConvertCommon.Common;

namespace ConvertCommon.dto
{
    /// <summary>
    /// AuthoritySettingsDtoのラッパークラス
    /// 初期設定・検索に使用する
    /// </summary>
    public static class AuthoritySettingsDtoUtil
    {

        private const string XML_FILE_NAME = "AuthoritySettings.xml";
        private const string SQL_FILE_NAME = "AuthoritySettingsSqlTemplete.sql";
        private const string FILE_PATH = @".\SQL\config\";
        private const string REPLACE_STRING = "{AuthoritySettingsXml}";
        private const string REPLACEMENT_STRING_XML = "'{AuthoritySettingsXml}'";
        private const string BIND_VARIABLE_XML = ":AuthoritySettingsXml";
        /// <summary>
        /// SQLファイルが存在しない場合に仮テーブルを作成する用
        /// </summary>
        private const string DUMMY_SQL = "with admin_user_authority_list as ( " +
                                        "select " +
                                        "null as target_kind, " +
                                        "null as fnw_job_class_cd, " +
                                        "null as fnw_staff_cd, " +
                                        "null as user_settings, " +
                                        "null as user_type, " +
                                        "null as administrator, " +
                                        "null as default_menu_settings " +
                                        "from dual " +
                                        "), " +
                                        "job_authority_list as ( " +
                                        "select " +
                                        "null as target_kind, " +
                                        "null as fnw_job_class_cd, " +
                                        "null as fnw_staff_cd, " +
                                        "null as user_settings, " +
                                        "null as user_type, " +
                                        "null as administrator, " +
                                        "null as default_menu_settings " +
                                        "from dual " +
                                        "), " +
                                        "job_authority_list_default as ( " +
                                        "select " +
                                        "null as target_kind, " +
                                        "null as fnw_job_class_cd, " +
                                        "null as fnw_staff_cd, " +
                                        "null as user_settings, " +
                                        "null as user_type, " +
                                        "null as administrator, " +
                                        "null as default_menu_settings " +
                                        "from dual " +
                                        ") ";


        public static AuthoritySettingsDto authoritySettingsDto { get; private set; }

        /// <summary>
        /// XML文字列を格納
        /// </summary>
        public static string xmlString { get; private set; }

        /// <summary>
        /// SQL文字列を格納
        /// </summary>
        public static string authoritySettingWithBlock { get; private set; }

        /// <summary>
        /// クラス初期設定
        /// </summary>
        public static void init()
        {
            // ファイルが存在しない場合は処理中止
            // Exceptionでプログラムを停止させる
            CheckXMLFileExists();
            CheckSQLFileExists();

            // DTOに永続化しとく（将来XML⇔DTO変換が必要になったとき用）
            // ついでにXMLパース目的、パース失敗したらエクセプションが飛ぶ
            SetAuthoritySettingsDto();

            // XML文字列取得
            xmlString = GetAuthoritySettingsXml();

            // SQLWith句取得
            authoritySettingWithBlock = GetAuthoritySettingsSql();
        }

        /// <summary>
        /// AuthoritySettings.xmlをDtoに設定
        /// </summary>
        private static void SetAuthoritySettingsDto()
        {
            try
            {
                if (false == File.Exists(FILE_PATH + XML_FILE_NAME))
                {
                    string msg = FILE_PATH + XML_FILE_NAME + "の取得に失敗しました。";
                    ConvertBase.WriteErrorLog(msg);
                    throw new FileNotFoundException(msg);
                }

                using (System.IO.FileStream fs = new System.IO.FileStream(FILE_PATH + XML_FILE_NAME, System.IO.FileMode.Open))
                {
                    System.Xml.Serialization.XmlSerializer serializer = System.Xml.Serialization.XmlSerializer.FromTypes(new[] { typeof(AuthoritySettingsDto) })[0];
                    authoritySettingsDto = (AuthoritySettingsDto)serializer.Deserialize(fs);
                }
            }catch(Exception ex)
            {
                throw ex;
            }
        }

        private const string AUTHORITY_SETTING_SQL_TEMP = "job_authority_list as ({0}),\r\n" +
                                                        "job_authority_list_default as ({1}),\r\n" +
                                                        "admin_user_authority_list as ({2})\r\n";
        private const string JOB_AUTHORITY_LIST_SQL_CHILD_TEMP = "select \r\n" +
                                                            "'{0}' as target_kind,\r\n" +
                                                            "'{1}' as fnw_job_class_cd,\r\n" +
                                                            "'{2}' as fnw_staff_cd,\r\n" +
                                                            "'{3}' as user_settings,\r\n" +
                                                            "'{4}' as user_type,\r\n" +
                                                            "'{5}' as administrator,\r\n" +
                                                            "'{6}' as default_menu_settings\r\n" +
                                                            "from dual {7}";
        private const string JOB_AUTHORITY_LIST_SQL_PARENT_TEMP = "(select * from ({0}))";

        /// <summary>
        /// DTOからWITH句用のSQLを作成して返す
        /// </summary>
        /// <returns></returns>
        private static string GetSqlFromDto()
        {
            // job_authority_list表SQLの生成
            string jobAuthSqlChildWork;
            List<string> jobAuthSqlChildList = new List<string>();
            if(authoritySettingsDto.job_authority_list == null || 
                authoritySettingsDto.job_authority_list.Count() == 0)
            {
                // 0件のjob_authority_list仮表作成
                jobAuthSqlChildWork = string.Format(JOB_AUTHORITY_LIST_SQL_CHILD_TEMP,
                    "job",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "where 1=0");
                jobAuthSqlChildList.Add(jobAuthSqlChildWork);
            }
            else
            {
                foreach (authority_settingsJob_authority_list dto in authoritySettingsDto.job_authority_list)
                {
                    jobAuthSqlChildWork = string.Format(JOB_AUTHORITY_LIST_SQL_CHILD_TEMP,
                    "job",
                    dto.fnw_job_class_cd,
                    "",
                    DeleteNewLineCode(dto.user_settings),
                    dto.user_type,
                    dto.administrator,
                    "",
                    "");
                    jobAuthSqlChildList.Add(jobAuthSqlChildWork);
                }
            }
            // 完成したSQLを格納
            string jobAuthSqlParentWork = string.Join(" UNION ", jobAuthSqlChildList.ToArray());
            string jobAuthSql = string.Format(JOB_AUTHORITY_LIST_SQL_PARENT_TEMP, jobAuthSqlParentWork);

            // job_authority_list_default表の作成
            string jobAuthDefSqlChildWork;
            List<string> jobAuthDefSqlChildList = new List<string>();
            if (authoritySettingsDto.job_authority_list_default == null)
            {
                // 0件のjob_authority_list仮表作成
                jobAuthDefSqlChildWork = string.Format(JOB_AUTHORITY_LIST_SQL_CHILD_TEMP,
                    "job",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "where 1=0");
            }
            else
            {
                    jobAuthDefSqlChildWork = string.Format(JOB_AUTHORITY_LIST_SQL_CHILD_TEMP,
                    "job",
                    authoritySettingsDto.job_authority_list_default.fnw_job_class_cd,
                    "",
                    DeleteNewLineCode(authoritySettingsDto.job_authority_list_default.user_settings),
                    authoritySettingsDto.job_authority_list_default.user_type,
                    authoritySettingsDto.job_authority_list_default.administrator,
                    "",
                    "");
            }
            // 完成したSQLを格納
            string jobAuthDefSql = string.Format(JOB_AUTHORITY_LIST_SQL_PARENT_TEMP, jobAuthDefSqlChildWork);

            // admin_user_staff_cd_list表の作成
            string adminUserSqlChildWork;
            List<string> adminUserSqlChildList = new List<string>();
            if (authoritySettingsDto.admin_user_authority_list.fnw_staff_cd == null || 
                authoritySettingsDto.admin_user_authority_list.fnw_staff_cd.Count() == 0)
            {
                // 0件のjob_authority_list仮表作成
                adminUserSqlChildWork = string.Format(JOB_AUTHORITY_LIST_SQL_CHILD_TEMP,
                    "job",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "where 1=0");
                jobAuthDefSqlChildList.Add(adminUserSqlChildWork);
            }
            else
            {
                foreach (string fnw_staff_cd in authoritySettingsDto.admin_user_authority_list.fnw_staff_cd)
                {
                    adminUserSqlChildWork = string.Format(JOB_AUTHORITY_LIST_SQL_CHILD_TEMP,
                    "userid",
                    "",
                    fnw_staff_cd,
                    DeleteNewLineCode(authoritySettingsDto.admin_user_authority_list.user_settings),
                    authoritySettingsDto.admin_user_authority_list.user_type,
                    authoritySettingsDto.admin_user_authority_list.administrator,
                    "",
                    "");
                    adminUserSqlChildList.Add(adminUserSqlChildWork);
                }
            }
            // 完成したSQLを格納
            string adminUserSqlParentWork = string.Join(" UNION ", adminUserSqlChildList.ToArray());
            string adminUserSql = string.Format(JOB_AUTHORITY_LIST_SQL_PARENT_TEMP, adminUserSqlParentWork);

            string ret = string.Format(AUTHORITY_SETTING_SQL_TEMP, jobAuthSql, jobAuthDefSql, adminUserSql);
            return ret;
        }


        /// <summary>
        /// AuthoritySettings.xmlを読み込み文字列として返す
        /// </summary>
        public static string GetAuthoritySettingsXml()
        {
            if (false == File.Exists(FILE_PATH + XML_FILE_NAME))
            {
                string msg = FILE_PATH + XML_FILE_NAME + "の取得に失敗しました。";
                ConvertBase.WriteErrorLog(msg);
                throw new FileNotFoundException(msg);
            }

            string ret;
            using (System.IO.StreamReader sr = new System.IO.StreamReader(FILE_PATH + XML_FILE_NAME, Encoding.GetEncoding("Shift_JIS")))
            {
                ret = sr.ReadToEnd();
            }

            // XML宣言を削除する
            ret = XmlControl.DeleteXmlDecleare(ret);

            // XMLコメントを削除する
            ret = XmlControl.DeleteXmlComments(ret);

            // 改行を削除する
            ret = XmlControl.DeleteNewLineCode(ret);

            return ret;
        }


        /// <summary>
        /// AuthoritySettings.xml、AuthoritySettings.sqlを読み込み
        /// With句用のSQLを生成して返す
        /// </summary>
        /// <returns></returns>
        public static string GetAuthoritySettingsSql()
        {
            string sqlTemp;
            using (System.IO.StreamReader sr = new System.IO.StreamReader(FILE_PATH + SQL_FILE_NAME, Encoding.GetEncoding("Shift_JIS")))
            {
                sqlTemp = sr.ReadToEnd();
            }

            // XMLからWITH句用のSQL文を構築して返す
            string withSql = GetSqlFromDto();
            //string xml = AuthoritySettingsDtoUtil.GetAuthoritySettingsXml();
            //string xmlAddToClob = XmlToToClobFunctions(xml);
            string ret = sqlTemp.Replace(REPLACE_STRING, withSql);

            return ret;
        }

        /// <summary>
        /// 改行を削除して返す
        /// </summary>
        /// <param name="tagret"></param>
        /// <returns></returns>
        private static string DeleteNewLineCode(string target)
        {
            string ret = target.Replace(Environment.NewLine, " ");
            return ret;
        }

        /// <summary>
        /// XML文字列を分割しSQLのTO_CLOB(文字列１)||TO_CLOB(文字列２)
        /// の形にして返す
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        private static string XmlToToClobFunctions(string target)
        {
            string replaceTarget = "</user_settings>";
            string targetAddNewLineCode = target.Replace(replaceTarget, replaceTarget + Environment.NewLine);
            string[] xmlStrings = XmlControl.SplitXml(targetAddNewLineCode, Environment.NewLine);

            string ret = " TO_CLOB('" + string.Join("')||TO_CLOB('", xmlStrings) + "')";
            return ret;
        }

        /// <summary>
        /// 次世代側のユーザー権限設定に必要なXMLが存在するかチェックする
        /// </summary>
        /// <returns></returns>
        public static void CheckXMLFileExists()
        {
            if (false == File.Exists(FILE_PATH + XML_FILE_NAME))
            {
                string msg = FILE_PATH + XML_FILE_NAME + "の取得に失敗しました。";
                ConvertBase.WriteErrorLog(msg);
                throw new FileNotFoundException(msg);
            }
        }

        /// <summary>
        /// 次世代側のユーザー権限設定に必要なSQLが存在するかチェックする
        /// </summary>
        /// <returns></returns>
        public static void CheckSQLFileExists()
        {
            if (false == File.Exists(FILE_PATH + SQL_FILE_NAME))
            {
                string msg = FILE_PATH + SQL_FILE_NAME + "の取得に失敗しました。";
                ConvertBase.WriteErrorLog(msg);
                throw new FileNotFoundException(msg);
            }
        }

    }
}
