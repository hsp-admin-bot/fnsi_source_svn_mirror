using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    public class TotalLayoutData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 横の集計単位の取得及び設定を行います。
        /// </summary>
        public String UnitV { get; set; } = String.Empty;

        /// <summary>
        /// 縦の集計単位の取得及び設定を行います。
        /// </summary>
        public String UnitH { get; set; } = String.Empty;

        /// <summary>
        /// 集計単位日付の取得及び設定を行います。
        /// </summary>
        public String UnitDate { get; set; } = "年";

        // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
        /// <summary>
        ///出力値のない列は省略する取得及び設定を行います。
        /// </summary>
        public String EffectDataV { get; set; } = "0";
        // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

        // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
        /// <summary>
        //出力値のない行は省略する取得及び設定を行います。
        /// </summary>
        public String EffectDataH { get; set; } = "0";
        // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

        /// <summary>
        /// 表示内容の取得及び設定を行います。
        /// </summary>
        public String Contents { get; set; } = "項目値";

        // add #11973 日常点検一覧帳票が正常に出せない 高 start
        /// <summary>
        /// 表示内容種類の取得及び設定を行います。
        /// </summary>
        public String ContentsType { get; set; } = "先頭";
        // add #11973 日常点検一覧帳票が正常に出せない 高 end

        /// <summary>
        /// 表示変換の取得及び設定を行います。
        /// </summary>
        public String Conversion { get; set; } = String.Empty;

        /// <summary>
        /// 縦の合計の取得及び設定を行います。
        /// </summary>
        public String CountH { get; set; } = "0";

        /// <summary>
        /// 横の合計の取得及び設定を行います。
        /// </summary>
        public String CountV { get; set; } = "0";

        /// <summary>
        /// 起点セルの取得及び設定を行います。
        /// </summary>
        public String OriginRange { get; set; } = String.Empty;
        // add #6035 2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない　孟堅 start
        /// <summary>
        /// 帳票区分保存先アドレス
        /// </summary>
        public String ReportType { get; set; } = String.Empty;
        // add #6035 2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない　孟堅 end
        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
        ////add 6608 2次元帳票excel エクスポート 吉 start
        //public String MultiTotalDefaul { get; set; } = String.Empty;
        ////add 6608 2次元帳票excel エクスポート 吉 end
        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
        // add #11011 集計内訳タブ仕様変更 高 end
        // <summary>
        /// 横の集計単位のaddress取得及び設定を行います。
        /// </summary>
        public String UnitVAddress { get; set; } = String.Empty;

        /// <summary>
        /// 縦の集計単位のaddress取得及び設定を行います。
        /// </summary>
        public String UnitHAddress { get; set; } = String.Empty;
        // add #11011 集計内訳タブ仕様変更 高 end
        // add #11973 日常点検一覧帳票が正常に出せない 高 start
        public bool UnitDateVisible { get; set; } = true;
        // add #11973 日常点検一覧帳票が正常に出せない 高 end
        #endregion
    }
}
