
namespace ConvertCommon.dto
{
    /// <summary>
    /// クラス間受け渡し用のコンバート条件Dto
    /// </summary>
    public class MakeSqlDto
    {
        /// <summary>
        /// 施設コード
        /// </summary>
        public string facilityCd;

        /// <summary>
        /// 系列施設コード
        /// </summary>
        public string seriesCd;

        /// <summary>
        /// テーブル名
        /// </summary>
        public string tableName;

        /// <summary>
        /// データ取得開始日
        /// </summary>
        public string startDate;

        /// <summary>
        /// データ取得終了日
        /// </summary>
        public string endDate;

        /// <summary>
        /// プライマリキーの値
        /// </summary>
        public string pkeyValue;

        /// <summary>
        /// テンプレートSQL
        /// </summary>
        public string sqlForTool;

        /// <summary>
        /// 同期用取得条件SQL
        /// </summary>
        public string sqlForSync;

        /// <summary>
        /// diff用取得条件SQL
        /// </summary>
        public string sqlForDiff;

        /// <summary>
        /// 期間指定用取得条件SQL
        /// </summary>
        public string sqlForSpecifyPeriod;

        /// <summary>
        /// 出力済除外用条件SQL
        /// </summary>
        public string sqlForExclusiveOutputted;

        /// <summary>
        /// 期間指定実施フラグ
        /// </summary>
        public bool isPeriod;

        /// <summary>
        /// 出力済は除外する
        /// </summary>
        public bool isExclusion;

        /// <summary>
        /// 同期処理フラグ
        /// </summary>
        public bool isSync;

        /// <summary>
        /// ユーザー権限設定関連のWith句SQL
        /// </summary>
        public string authoritySettingWithBlock;


        /// <summary>
        /// SERIES_CD有効かどうか
        /// </summary>
        public string isSERIESCD;
    }
}
