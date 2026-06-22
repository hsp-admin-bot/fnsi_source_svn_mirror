package batch;

import java.io.Serial;
import java.util.HashMap;
import java.util.Map;

/**
 * 定数クラス
 */
public final class ApplicationConst{
    private ApplicationConst(){
    }

    // add #11302 コンバートの削除処理で処理が進まなくなることがある limingyang start
    public static class TableName {
        public static final String MNT_NOTIFICATION_STATUS = "mnt_notification_status";
        public static final String MNT_NOTIFICATION_MESSAGE = "mnt_notification_message";
    }
    // add #11302 コンバートの削除処理で処理が進まなくなることがある limingyang end

    // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm start
    public static class LatestFlag {

        public static final String LATEST_FLAG = "latest_flag";
        public static final String ON = "on";
        public static final String OFF = "off";
    }
    // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm end

    public static class JobParameterKeys {
        public static final String JOB = "job";
        public static final String TIME_STAMP = "timestamp";
        public static final String INPUT_FILE_PATH = "inputFilePath";
        public static final String DB_TYPE = "dbType";
        public static final String FACILITY_CD = "facilityCd";
        public static final String TABLE_NAME = "tableName";
        /** DeleteTableJob は、残存ファイルの削除にルートパス（IP アドレスまたはサーバーパス）を使用します。複数の施設が同時に実行されている場合、GlobalContext の上書きを避けるために、このパスは JobParameters を介して渡されます。 */ // #11998 add
        public static final String IP_ADDRESS = "ipAddress"; // #11998 add
        // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
        public static final String RESTART = "restart";
        // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
    }

    /**
     * 後続ステップへ値の受け渡しに使用するキー
     */
    public static class PromotionKeys {
        public static final String SQL_FILE_LIST = "sqlFileList";
        public static final String NEXT_PROCESSING_FILE = "nextProcessingFile";
        public static final String COPIED_TABLE_NAMES = "copiedTableNames";
        public static final String CONVERT_PROC_ID = "convertProcId";
        public static final String COMPLETED_FILE_PATH = "completedFilePath";
        public static final String CONVERT_PROGRESS = "convertProgress";
        // add #10859-6 djy start
        public static final String TABLE_PROGRESS = "tableProgress";
        public static final String SQL_FILE_TABLE_COUNT_LIST = "sqlFileTableCountList";
        // add #10859-6 djy end
    }

    public static class YmlElementNames{
        public static final String RELATION_TO_TABLE_NAME = "relationToTableName";
        public static final String TRUNCATE_TABLE_NAME = "truncateTableName";
    }

    public static class DbType{
        public static final String CONVERT = "convert";
        public static final String NKK4 = "nkk4";
        public static final String NKK5 = "nkk5";
        public static final String NKK6 = "nkk6";
    }

    public static class JdbcTempleteName {
        public static final String JDBC_TEMPLATE_NKK4 = "jdbcTemplateNkk4";
        public static final String JDBC_TEMPLATE_NKK5 = "jdbcTemplateNkk5";
        public static final String JDBC_TEMPLATE_NKK6 = "jdbcTemplateNkk6";
        public static final String JDBC_TEMPLATE_CONVERT = "jdbcTemplateConvert";
        public static final String NAMED_PARAMETER_JDBCTEMPLATE_NKK4 = "namedParameterJdbcTemplateNkk4";
        public static final String NAMED_PARAMETER_JDBCTEMPLATE_NKK5 = "namedParameterJdbcTemplateNkk5";
        public static final String NAMED_PARAMETER_JDBCTEMPLATE_NKK6 = "namedParameterJdbcTemplateNkk6";
        public static final String NAMED_PARAMETER_JDBCTEMPLATE_CONVERT = "namedParameterJdbcTemplateConvert";
    }

    public static Map<String,String> StepNameToProcNameMap = new HashMap<String,String>(){
        @Serial
        private static final long serialVersionUID = 1L;

        {
            put("ReadSqlFileWriteDbStep","一時作業用DBへデータ登録");
            put("ConvertDbToProductionDbStep","一時作業用DBから本番DBへエクスポート");
            put("ProductionDbToConvertDbStep","本番DBからデータ取得");
            put("TruncateTableStep","本番DBへのコピーが完了した一時作業用DBのデータ削除");
            put("TruncateRelationTableStep","外部キー変換用の一時作業用DBのデータ削除");
            put("DeleteTableInConvertDbStep","一時作業用DBのテーブル全削除");
        }
    };

    /**
     * 停止理由
     */
    public enum StopReason{
        MULTIPLE_ACTIVATION("MULTIPLE_ACTIVATION"),
        NO_TARGET("NO_TARGET"),
        ERROR("ERROR"),
        ;

        private final String text;

        private StopReason(final String text) {
            this.text = text;
        }

        public String getString() {
            return this.text;
        }
    }
}