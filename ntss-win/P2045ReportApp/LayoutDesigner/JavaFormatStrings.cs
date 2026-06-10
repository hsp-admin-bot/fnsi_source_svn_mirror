using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    internal class JavaFormatStrings : Dictionary<string, string>
    {

        /// <summary>
        /// JavaFormatString インスタンス実体
        /// </summary>
        private static JavaFormatStrings formats = null;

        #region コンストラクタ

        /// <summary>
        /// コンストラクタ
        /// </summary>
        private JavaFormatStrings() { }

        #endregion

        /// <summary>
        /// JavaFormatString インスタンス
        /// </summary>
        /// <returns></returns>
        public static JavaFormatStrings GetInstance()
        {
            if (formats == null)
            {
                // 初期化
                formats = new JavaFormatStrings
                {
                    // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 start
                    { frmSelectFormat.DECIMAL_FORMAT[0], "%.0f" },
                    { frmSelectFormat.DECIMAL_FORMAT[1], "%.1f" },
                    { frmSelectFormat.DECIMAL_FORMAT[2], "%.2f" },
                    { frmSelectFormat.DECIMAL_FORMAT[3], "%.3f" },
                    { frmSelectFormat.DATETIME_FORMAT[0], "yyyy年M月d日(E) H時mm分" },
                    { frmSelectFormat.DATETIME_FORMAT[1], "yyyy年M月d日 H時mm分" },
                    { frmSelectFormat.DATETIME_FORMAT[2], "yyyy/M/d H:mm" },
                    { frmSelectFormat.DATETIME_FORMAT[3], "yyyy/MM/dd HH:mm" },
                    { frmSelectFormat.DATETIME_FORMAT[4], "yyyy年M月" },
                    { frmSelectFormat.DATETIME_FORMAT[5], "Gyyyy/M" },//GY/M
                    { frmSelectFormat.DATETIME_FORMAT[6], "yyyy年M月d日(E)" },
                    { frmSelectFormat.DATETIME_FORMAT[7], "yyyy年M月d日" },
                    { frmSelectFormat.DATETIME_FORMAT[8], "yyyy/M/d" },
                    { frmSelectFormat.DATETIME_FORMAT[9], "yyyy/MM/dd" },
                    { frmSelectFormat.DATETIME_FORMAT[10], "GGGG年M月d日(E)"},//"ggge\"年\"m\"月\"d\"日\"(aaa)"
                    { frmSelectFormat.DATETIME_FORMAT[11], "GGGG年M月d日"},//"ggge\"年\"m\"月\"d\"日\""
                    { frmSelectFormat.DATETIME_FORMAT[12], "Gyyyy/M/d" },//"ge/m/d",
                    { frmSelectFormat.DATETIME_FORMAT[13], "M月d日(E)" },
                    { frmSelectFormat.DATETIME_FORMAT[14], "M月d日" },
                    { frmSelectFormat.DATETIME_FORMAT[15], "M/d(E)" },
                    { frmSelectFormat.DATETIME_FORMAT[16], "M/d" },
                    { frmSelectFormat.DATETIME_FORMAT[17], "(E)" },
                    { frmSelectFormat.DATETIME_FORMAT[18], "EEEE" },
                    { frmSelectFormat.DATETIME_FORMAT[19], "M/d H:mm" },
                    { frmSelectFormat.DATETIME_FORMAT[20], "[h]:mm:ss" },//"[h]:mm:ss",
                    { frmSelectFormat.DATETIME_FORMAT[21], "H:mm:ss" },
                    { frmSelectFormat.DATETIME_FORMAT[22], "[h]時間mm分ss秒" },//"[h]\"時間\"mm\"分\"ss\"秒\"",
                    { frmSelectFormat.DATETIME_FORMAT[23], "H時mm分ss秒" },
                    { frmSelectFormat.DATETIME_FORMAT[24], "[h]:mm" },//"[h]:mm",
                    { frmSelectFormat.DATETIME_FORMAT[25], "H:mm" },
                    { frmSelectFormat.DATETIME_FORMAT[26], "HH:mm" },
                    { frmSelectFormat.DATETIME_FORMAT[27], "[h]時間mm分" },//"[h]\"時間\"mm\"分\"",
                    { frmSelectFormat.DATETIME_FORMAT[28], "H時mm分" },
                    { frmSelectFormat.DATETIME_FORMAT[29], "H:mm a" }//"h:mm AM/PM"
                    // edit #8394 4-1,#8566 日付時刻型のデータ項目に書式設定が反映しない 董 end
                };
            }
            return formats;

        }

        /// <summary>
        /// Gets or sets the value associated with the specified key.
        /// </summary>
        /// <param name="key">The key of the value to get or set.</param>
        /// <returns>The value associated with the specified key. If the specified key is not found, a get operation throws a System.Collections.Generic.KeyNotFoundException, and a set operation creates a new element with the specified key.</returns>
        public new string this[string key] => ContainsKey(key) ? base[key] : "";

    }

}
