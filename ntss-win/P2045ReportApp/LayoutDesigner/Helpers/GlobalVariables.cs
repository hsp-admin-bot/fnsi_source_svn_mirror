using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 HTML ドキュメント操作ヘルパークラス
    /// </summary>
    public static class GlobalVariables
    {
        //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong start
        public static int printType { get; set; } = 0;
        public static string usedRangeAddress { get; set; } = string.Empty;
        public static string oldUsedRangeAddress { get; set; } = string.Empty;
        //edit #9850 印刷範囲外に文字が入力されていないのにメッセージが出る dongzhaolong end
    }
}
