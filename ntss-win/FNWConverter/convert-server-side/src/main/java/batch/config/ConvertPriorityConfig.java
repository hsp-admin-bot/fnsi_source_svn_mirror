package batch.config;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import batch.part.PsqlCopyUtils;
import lombok.Data;
import web.config.EventLoggerUtil;
import web.constant.LoggingConstant;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * ymlファイルからconvert-priorityの情報を取得し保存するクラス
 */
@Data
@Component
@ConfigurationProperties(prefix="convert-priority")
public class ConvertPriorityConfig{

    private Map<String,String> config;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    /**
     * ymlファイルから優先度が設定されているテーブルのリストを取得
     */
    public List<String> getTableNames(){
        return new ArrayList<String>(config.keySet());
    }

    /**
     * ymlファイルからテーブルのコンバート優先度を取得する
     * 
     * @param tableName
     * @return 優先度の番号（低いほうが優先度高い）
     * @throws Exception
     */
    public int getPriority(String tableName) {
        // テーブルの優先度が設定されていない場合はエラー
        if(!config.containsKey(tableName)){
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("ymlファイルconvert-priority内" + tableName + "の優先度が設定されていません。",
                    LoggingConstant.DEFAULT_FACILITYCD, "getPriority(String tableName)");
            eventLoggerUtil.recordLog(LoggingConstant.DEFAULT_FACILITYCD, eventLogMessage, LogLevel.INFO);
            return 999;
        }else{
            return Integer.parseInt(config.get(tableName));
        }
    }

    /**
     * SQLファイルパスリストを受け取り、優先度順にソートする
     * <p>
     *      処理イメージ
     *      入力
     *      D:\mst_medicine.sql
     *      D:\mst_medicine_class.sql
     *      ↓
     *      ファイル名よりテーブル名取得し付加
     *      D:\mst_medicine.sql,mst_medicine
     *      D:\mst_medicine_class.sql,mst_medicine_class
     *      テーブル名でymlファイルを検索し、取得した優先度を付加
     *      D:\mst_medicine.sql,mst_medicine,2
     *      D:\mst_medicine_class.sql,mst_medicine_class,1
     *      ↓
     *      優先度で並び替え
     *      D:\mst_medicine_class.sql,mst_medicine_class,1
     *      D:\mst_medicine.sql,mst_medicine,2
     *      ↓
     *      出力
     *      D:\mst_medicine_class.sql
     *      D:\mst_medicine.sql
     * </p>
     * 
     * @throws Exception
     */
    public List<String> sortSqlFileList(List<String> sqlFileList) {
        List<SqlFilePriority> sqlFilePriorityList = new ArrayList<SqlFilePriority>();

        for(String sqlFilePath:sqlFileList){
            String tableName = PsqlCopyUtils.getTableName(sqlFilePath);
            int priority = getPriority(tableName);
            SqlFilePriority sqlFilePriority = new SqlFilePriority();
            sqlFilePriority.priority = priority;
            sqlFilePriority.sqlFilePath = sqlFilePath;
            sqlFilePriorityList.add(sqlFilePriority);
        }

        // 優先度順で並び替えて文字列リストに変換
        List<String> ret = sqlFilePriorityList
                        .stream()
                        .sorted((a,b) -> a.priority - b.priority)
                        .map(dto -> dto.sqlFilePath)
                        .collect(Collectors.toList());

        return ret;
    }

    private static class SqlFilePriority{
        String sqlFilePath;
        int priority;
    }
}