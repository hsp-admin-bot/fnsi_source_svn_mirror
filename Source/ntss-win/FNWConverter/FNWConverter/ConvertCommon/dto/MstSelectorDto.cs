using System;
using System.Collections.Generic;
using System.Linq;

namespace ConvertCommon.dto
{
    /// <summary>
    /// 選択マスタ
    /// </summary>
    public partial class MstSelectorDto
    {
        public const string TABLE_NAME = "mst_selector";

        public MstSelectorDto()
        {
            // 分割件数デフォルト100件
            this.chunkSize = 100;
        }
        /// <summary>
        /// SQLを分割するJson項目のコードと名称のセット数
        /// </summary>
        public int chunkSize;

        /// <summary>
        /// 施設コード
        /// </summary>
        public string facilityCd;

        /// <summary>
        /// マスタ物理名称
        /// </summary>
        public string masterPhysicalName;

        /// <summary>
        /// 並び順設定
        /// </summary>
        public List<OrderSetting> orderSettingList = new List<OrderSetting>();

        internal string getValues(IEnumerable<OrderSetting> chunk)
        {
            throw new NotImplementedException();
        }

        public IEnumerable<IEnumerable<OrderSetting>> chunkOrderSettingList()
        {
            var chunks = orderSettingList.Select((v, i) => new { v, i })
            .GroupBy(x => x.i / chunkSize)
            .Select(g => g.Select(x => x.v));
            return chunks;
        }

        /// <summary>
        /// 登録日時
        /// </summary>
        public string regDate;

        /// <summary>
        /// 更新日時
        /// </summary>
        public string upDate;

        public string[] uniqueKeys = new string[]
        {
                "facility_cd",
                "master_physical_name"
        };

        /// <summary>
        /// カラム名定義
        /// </summary>
        public string[] columnNames = new string[]{
                "facility_cd",
                "master_physical_name",
                "order_settings",
                "reg_date",
                "up_date"};

        /// <summary>
        /// 列の値をカンマ区切りで返す
        /// </summary>
        /// <returns></returns>
        public string getValues(List<OrderSetting> procOrderSettingList)
        {
            string ret = "'" + this.facilityCd + "'," +
            "'" + this.masterPhysicalName + "'," +
            this.makeValueBlockForOrderSetting(procOrderSettingList) + "," +
            this.regDate + "," +
            this.upDate;
            return ret;
        }

        /// <summary>
        /// 列の値をカンマ区切りで返す（Update用）
        /// </summary>
        /// <returns></returns>
        public string getValuesForUpdate(List<OrderSetting> procOrderSettingList,bool isDiff)
        {
            // mod 7853-差分コンバートで更新/削除ができない 楊 start
            // mod #8400 LL start
            string ret = "order_settings=jsonb_set(" + TABLE_NAME + ".order_settings::jsonb,'{items}'," +
                    TABLE_NAME + ".order_settings::jsonb->'items'||" +
                    this.makeValueBlockForUpdateOrderSetting(procOrderSettingList) + "::jsonb)," +
                "up_date=" + this.upDate;
            // if (isDiff)
            // {
            //     ret = "order_settings=jsonb_set(" + TABLE_NAME + ".order_settings::jsonb,'{items}'," +
            //             this.makeValueBlockForUpdateOrderSetting(procOrderSettingList) + "::jsonb)," +
            //         "up_date=" + this.upDate;
            // }
            // else
            // {
            // ret = "order_settings=jsonb_set(" + TABLE_NAME + ".order_settings::jsonb,'{items}'," +
            //        TABLE_NAME + ".order_settings::jsonb->'items'||" +
            //        this.makeValueBlockForUpdateOrderSetting(procOrderSettingList) + "::jsonb)," +
            //    "up_date=" + this.upDate;
            // }
            // mod #8400 LL end
            // mod 7853-差分コンバートで更新/削除ができない 楊 end
            return ret;
        }

        /// <summary>
        /// OrderSettingの値をPostgresSQL用に加工して返す
        /// </summary>
        /// <returns></returns>
        public string makeValueBlockForOrderSetting(List<OrderSetting> procOrderSettingList)
        {
            const string templeteJBOSql = "json_build_object({0})";
            const string templeteJBASql = "json_build_object('items',json_build_array(VARIADIC ARRAY[{0}]))";
            string jba = string.Join(",", procOrderSettingList.Select(os =>
                {
                    // add FNSI-jlac10Cdを追加 楊 start
                    // return string.Format(templeteJBOSql, "'code'," + os.code + ",'name'," + os.name);
                    if (os.name.ToString().Contains(facilityCd))
                    {
                        return string.Format(templeteJBOSql, "'code'," + os.code + ",'name'," + os.jlac10Cd + ",'jlac10Cd'," + os.jlac10Cd);
                    }
                    else {
                        return string.Format(templeteJBOSql, "'code'," + os.code + ",'name'," + os.name + ",'jlac10Cd'," + os.jlac10Cd);
                    }
                    // add FNSI-jlac10Cdを追加 楊 end
                }).ToArray());
            string ret = string.Format(templeteJBASql,jba);
            return ret;
        }

        /// <summary>
        /// OrderSettingの値をPostgresSQL用に加工して返す（Update用）
        /// </summary>
        /// <returns></returns>
        public string makeValueBlockForUpdateOrderSetting(List<OrderSetting> procOrderSettingList)
        {
            const string templeteJBOSql = "json_build_object({0})";
            const string templeteJBASql = "json_build_array(VARIADIC ARRAY[{0}])";
            string jba = string.Join(",", procOrderSettingList.Select(os =>
            {
                // add FNSI-jlac10Cdを追加 楊 start
                // return string.Format(templeteJBOSql, "'code'," + os.code + ",'name'," + os.name);
                if (os.name.ToString().Contains(facilityCd))
                {
                    return string.Format(templeteJBOSql, "'code'," + os.code + ",'name'," + os.jlac10Cd + ",'jlac10Cd'," + os.jlac10Cd);
                }
                else
                {
                    return string.Format(templeteJBOSql, "'code'," + os.code + ",'name'," + os.name + ",'jlac10Cd'," + os.jlac10Cd);
                }
                // add FNSI-jlac10Cdを追加 楊 end
            }).ToArray());
            string ret = string.Format(templeteJBASql, jba);
            return ret;
        }

    }

    /// <summary>
    /// 並び順設定
    /// </summary>
    public partial class OrderSetting
    {
        /// <summary>
        /// 該当マスタの主キー
        /// 値ではなくコード変換用のSQLが設定される
        /// </summary>
        private object _code;
        public object code
        {
            get
            {
                if (_code == null || string.Empty.Equals(_code))
                {
                    return "null";
                }
                else
                {
                    return _code.ToString();
                }
            }
            set
            {
                _code = value;
            }
        }

        /// <summary>
        /// 名称
        /// </summary>
        private object _name;
        public object name
        {
            get
            {
                if (_name == null || string.Empty.Equals(_name))
                {
                    return "null";
                }
                else
                {
                    return "'" + _name.ToString() + "'";
                }
            }
            set
            {
                _name = value;
            }
        }

        // add FNSI-jlac10Cdを追加 楊 start
        /// <summary>
        /// jlac10Cd
        /// </summary>
        private object _jlac10Cd;
        public object jlac10Cd
        {
            get
            {
                return "null";
            }
            set
            {
                _jlac10Cd = value;
            }
        }
        // add FNSI-jlac10Cdを追加 楊 end
    }
}
