package batch.part;

import batch.ApplicationConst;
import batch.ApplicationConst.PromotionKeys;
import batch.entity.IndHistoryEntity;
import batch.entity.OrdMainHst;
import batch.entity.PatGroupDetailHistoryEntity;
import batch.entity.PatInsuranceHistoryEntity;
import batch.entity.PatMainHistoryEntity;
import batch.entity.PatPersonalMainHistoryEntity;
import batch.entity.PatUniqueHistoryEntity;
import batch.entity.RstHistoryEntity;
import batch.listener.JobStartEndLIstener;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.item.ExecutionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.BasicQuery;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import utils.GlobalContext;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.batch.runtime.BatchStatus;
import javax.sql.DataSource;
import java.io.Serial;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 進捗管理クラス
 */
@Component
public class ProgressManagement{
    
    private static final Logger logger = LoggerFactory.getLogger(ProgressManagement.class);

    //add MONGOデータ削除処理を追加する zc start
    @Autowired(required = false)
    MongoTemplate mongoTemplate;
    //add MONGOデータ削除処理を追加する zc end

    // add #10859-6 djy start
    @Autowired
    Utils utils;
    // add #10859-6 djy end

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    // 開始中と強制終了は現状使用しないためコメントアウト
    public final String STARTED = BatchStatus.STARTED.toString();
    public final String COMPLETED = BatchStatus.COMPLETED.toString();
    public final String FAILED = BatchStatus.FAILED.toString();
    public final String STOPPING = BatchStatus.STOPPING.toString();
    public final String STOPPED = BatchStatus.STOPPED.toString();
    
    public final Map<String,String> StatusToJp = new HashMap<String,String>(){
        @Serial
        private static final long serialVersionUID = 1L;

        {
            put(STARTED,"実行中");
            put(COMPLETED,"正常終了");
            put(FAILED,"異常終了");
            put(STOPPING,"停止中");
            put(STOPPED,"停止完了");
        }
    };

    
    /**
     * 起動中と認識させるステータス一覧
     */
    public final List<String> runningStatusList = 
        Arrays.asList(STARTED,STOPPING);

    /**
     * プライマリDBのデータソース（Convert）
     */
    @Autowired
    DataSource dataSource;

    @Autowired
    NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert;

    /**
     * 進捗テーブルにデータが存在するかチェックする
     * （初回起動かチェックする）
     * @param facilityCd
     * @return true:存在しない false:存在する
     */
    public boolean isFirstTime(String facilityCd){
        List<Map<String,Object>> statusList = getStatusList(facilityCd);
        if(statusList.isEmpty()){
            return true;
        }else{
            return false;
        }
    }

    /**
     * ジョブが起動中か判定する
     * @param facilityCd
     * @return true:起動中
     */
    public boolean isRunning(String facilityCd){
        if(isFirstTime(facilityCd)){
            // 初回起動の場合、起動中の判定を行わない
            return false;
        }
        String status = getStatus(facilityCd);
        if(runningStatusList.contains(status)){
            return true;
        }else{
            return false;
        }
    }

    /**
     * バッチステータスの登録
     * @param facilityCd 施設コード
     * @param status ステータス
     * @param jobInstanceId ジョブインスタンスID
     * @param jobName ジョブ名
     */
    public void insertBatchStatus(String facilityCd,
                                String status,
                                long jobInstanceId,
                                String jobName){
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        
        String sql = "INSERT INTO batch_convert_status "
        + " (facility_cd,status,job_instance_id,job_name,reg_date)"
        + " VALUES"
        + " (?,?,?,?,?)";
        logger.trace("insertBatchStatus実行" + sql);
        jdbcTemplate.update(sql,
            facilityCd,status,jobInstanceId,jobName,now);
    }

    /**
     * バッチステータスの更新
     * @param facilityCd 施設コード
     * @param status ステータス
     * @param jobInstanceId ジョブインスタンスID
     * @param jobName ジョブ名
     */
    public void updateBatchStatus(int convertProcId,
                                String facilityCd,
                                String status,
                                long jobInstanceId,
                                String jobName){
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        
        String sql = "UPDATE batch_convert_status "
        + " SET"
        + " facility_cd=?,"
        + " status=?,"
        + " job_instance_id=?,"
        + " job_name=?,"
        + " up_date=?"
        + " where convert_proc_id=?";
        logger.trace("updateBatchStatus実行：" + sql);
        jdbcTemplate.update(sql,
            facilityCd,status,jobInstanceId,jobName,now,convertProcId);
    }

    /**
     * ジョブに終了命令が発行されていないかチェックする
     * @param facilityCd
     * @return true:停止命令あり
     */
    public boolean isStatusEqualsTerminate(String facilityCd){
        boolean result = false;
        logger.trace("isStatusEqualsTerminate実行");
        String status = getStatus(facilityCd);
        if(STOPPING.equals(status)){
            result = true;
        }
        return result;
    }

    /**
     * 施設コードに対応する最新のconvert_proc_idを取得する
     * @param facilityCd
     * @return 最新のconvert_proc_id
     */
    public int getConvertProcId(String facilityCd){
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);

        String sql = "SELECT convert_proc_id from batch_convert_status a"
        + " where convert_proc_id= "
        + " (SELECT max(convert_proc_id) from batch_convert_status where facility_cd= ? )";
        logger.trace("getConvertProcId実行：" + sql);
        int convertProcId = jdbcTemplate.queryForObject(
                        sql, new Object[] { facilityCd }, Integer.class);
        return convertProcId;
    }

    /**
     * ジョブのステータスを取得する
     * @param facilityCd
     * @return 取得したジョブのステータス（取得できない場合はNULL）
     */
    public String getStatus(String facilityCd){
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        String sql;
        sql = "SELECT status from batch_convert_status a"
        	        + " where convert_proc_id= "
        	        + " (SELECT max(convert_proc_id) from batch_convert_status where facility_cd= ? )";
        logger.trace("getStatus実行：" + sql);
        String status = jdbcTemplate.queryForObject(
                        sql, new Object[] { facilityCd }, String.class);
        return status;
    }

    /**
     * 施設コードで検索し、List<Map<String,Object>>で取得する
     * @param facilityCd 施設コード
     * @return ResultSet
     */
    public List<Map<String,Object>> getStatusList(String facilityCd){
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        // mod 2020-12-15 594 facilitycdに空判定を追加  う start
        String sql;
        List<Map<String,Object>> statusList = null;
        if(facilityCd.isEmpty()) {
        	statusList = new ArrayList<Map<String, Object>>();
        } else {
        	sql = "SELECT * from batch_convert_status "
        	        + " where convert_proc_id = "
        	        + " (SELECT max(convert_proc_id) from batch_convert_status where facility_cd= ? )";
        	logger.trace("getStatusList実行：" + sql);
        	statusList = jdbcTemplate.queryForList(sql,new Object[] { facilityCd });
        }
        // mod 2020-12-15 594 facilitycdに空判定を追加  う end
        return statusList;
    }

    /**
     * 施設コードで検索し、List<Map<String,Object>>で取得する
     * @param facilityCd 施設コード
     * @return ResultSet
     */
    // mod ProgressBarの修正 楊 start
    public List<Map<String,Object>> getTableStatusList(String facilityCd, String orderNo){
        // mod ProgressBarの修正 楊 end
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);

        String sql = "SELECT * from batch_convert_table_status "
        + " where convert_proc_id = "
        + " (SELECT max(convert_proc_id) from batch_convert_status where facility_cd= ? and job_name='ConvertJob')"
        // add ProgressBarの修正 楊 start
        + " AND (order_no > ?)"
        // add ProgressBarの修正 楊 end
        + " order by order_no";
        logger.trace("getTableStatusList実行" + sql);

        List<Map<String,Object>> statusList = null;

        // mod ProgressBarの修正 楊 start
        statusList = jdbcTemplate.queryForList(sql,new Object[] { facilityCd, Integer.parseInt(orderNo) });
        // mod ProgressBarの修正 楊 end
        return statusList;
    }
    
    /**
     * 施設コードで検索し、List<Map<String,Object>>で取得する
     * @param facilityCd 施設コード
     * @return ResultSet
     */
    // mod ログ出力修正 楊 start
    public List<Map<String,Object>> getTableStatusListForLog(String facilityCd, String orderNo){
        // mod ログ出力修正 楊 end
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        // mod ログ出力修正 楊 start
        String sql = "SELECT facility_cd,table_name||' '||concat(type_name,'') table_name, content, TO_CHAR(reg_date,'YYYY/MM/DD HH24:MI:SS') reg_date, order_no from batch_convert_table_status "
                + " where convert_proc_id = "
                + " (SELECT max(convert_proc_id) from batch_convert_status where facility_cd= ? )"
                + " AND (order_no > ?)"
                + " AND (proc_name ='' OR proc_name = ?)"
                + " order by order_no";
        logger.trace("getTableStatusList実行" + sql);
        List<Map<String,Object>> statusList = null;
        // mod #10418 SQL注入対策：パラメータバインディング start
        statusList = jdbcTemplate.queryForList(sql,new Object[] { facilityCd, Integer.parseInt(orderNo), ApplicationConst.StepNameToProcNameMap.get("ReadSqlFileWriteDbStep") });
        // mod #10418 SQL注入対策：パラメータバインディング end
        // mod ログ出力修正 楊 end
        return statusList;
    }


    /**
     * ジョブに停止命令を発行（ステータスを停止中に更新）
     */
    public void stopJob(String facilityCd){
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        
        String sql = "UPDATE batch_convert_status "
        + " SET"
        + " status=?,"
        + " up_date=?"
        + " WHERE facility_cd= ? AND status<>? AND convert_proc_id = (select max(convert_proc_id) from batch_convert_status WHERE facility_cd= ? AND status<>?)";
        logger.trace("stopJob実行：" + sql);
        jdbcTemplate.update(sql,
            STOPPING,now,facilityCd,STOPPING,facilityCd,STOPPING);
    }


    //add  MONGOデータ削除処理を追加する  鄭  start
    /**
     * 削除Mongo
     * @param facilityCd
     * @return
     */
    public void DelPatMongoJobOperator(String facilityCd) throws Exception {

        ArrayList<DBObject> listMogo = new ArrayList<DBObject>();
        getFilterContition(listMogo, "facility_cd", facilityCd, "$eq");
        DBObject objMogo = new BasicDBObject();
        objMogo.put("$and", listMogo);
        Query queryMogo = new BasicQuery(objMogo.toString());
        mongoTemplate.remove(queryMogo, PatGroupDetailHistoryEntity.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":pat_group_detail_history");
        mongoTemplate.remove(queryMogo, PatInsuranceHistoryEntity.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":pat_insurance_history");
        mongoTemplate.remove(queryMogo, PatMainHistoryEntity.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":pat_main_history");
        mongoTemplate.remove(queryMogo, PatPersonalMainHistoryEntity.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":pat_personal_main_history");
        mongoTemplate.remove(queryMogo, PatUniqueHistoryEntity.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":pat_unique_history");
        // #8400 zl start
        mongoTemplate.remove(queryMogo, IndHistoryEntity.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":ind_history");
    	// #8400 zl end
        //add  #10675 & #10676 djy start
        mongoTemplate.remove(queryMogo, OrdMainHst.class);
        logger.info("コンバートMONGODBテーブル削除実行：" + facilityCd + ":ord_main_hst");
        //add  #10675 & #10676 djy end

        //add  #11023  zc start
        mongoTemplate.remove(queryMogo, RstHistoryEntity.class);
        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("コンバートMONGODBテーブル削除実行：" + facilityCd + ":rst_history",
                facilityCd, "ProgressManagement.DelPatMongoJobOperator()");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //add  #11023  zc end
    }

    /**
     * MongoDB検索条件作成
     * @param conditionlist 条件リスト
     * @param key コラム
     * @param value データ
     * @param operator 条件演算子
     */
    private void getFilterContition(ArrayList<DBObject> conditionlist, String key, Object value, String operator) {
        if (value != null) {
            DBObject logConditionList = new BasicDBObject();
            if (value instanceof String strValue) {
                if (ObjectUtils.isEmpty(strValue)) {
                    return;
                }
                if (strValue.contains(",")) {
                    String[] strArray = ((String) value).split(",");
                    List list = Arrays.asList(strArray);
                    logConditionList.put(key, new BasicDBObject("$in", list));
                } else {
                    logConditionList.put(key, new BasicDBObject(operator, value));
                }
            } else if (value instanceof List) {
                if (((List) value).isEmpty()) {
                    return;
                }
                logConditionList.put(key, new BasicDBObject(operator, value));
            }
            conditionlist.add(logConditionList);
        }
    }
    //add  MONGOデータ削除処理を追加する  鄭  end

    /**
     * テーブル毎の進捗更新
     * @param jobExecution
     * @param content
     */
    public void createConvertTableStatus(JobExecution jobExecution,String content){
        // テーブル毎の進捗更新
        ExecutionContext cxt = jobExecution.getExecutionContext();
        long job_instance_id = jobExecution.getJobInstance().getInstanceId();
        String sql_file_path = null;
        if(cxt.containsKey(PromotionKeys.NEXT_PROCESSING_FILE)){
            sql_file_path = cxt.getString(PromotionKeys.NEXT_PROCESSING_FILE);
        }

        // バッチ処理進捗 XX/XX の形式で保持している場合、取得してstatusに追加
        String status = "";
        if(cxt.containsKey(PromotionKeys.CONVERT_PROGRESS)){
            status = cxt.getString(PromotionKeys.CONVERT_PROGRESS);
        }else{
            status = "0" + "/" + "0";
        }

        // add #10859-6 djy start
        String facilityCd = jobExecution.getJobParameters().getString(ApplicationConst.JobParameterKeys.FACILITY_CD);
        // add #10859-6 djy end

        int convertProcId = cxt.getInt(PromotionKeys.CONVERT_PROC_ID);
        
        BatchConvertTableStatus e = new BatchConvertTableStatus();
        e.setConvertProcId(convertProcId);
        e.setJobInstanceId(job_instance_id);
        e.setSqlFilePath(sql_file_path);
        // mod #10859-6 djy start
        e.setFacilityCd(facilityCd);
        // mod #10859-6 djy end
        e.setStatus(status);
        e.setProcName("");
        e.setContent(content);
        this.createConvertTableStatus(e);
    }


    /**
     * テーブル毎の進捗更新
     * @param stepExecution
     * @param content
     */
    public void createConvertTableStatus(StepExecution stepExecution,String content){
        // テーブル毎の進捗更新
        ExecutionContext cxt = stepExecution.getJobExecution().getExecutionContext();
        long job_instance_id = stepExecution.getJobExecution().getJobInstance().getInstanceId();
        String sql_file_path = null;
        String proc_name = ApplicationConst.StepNameToProcNameMap.get(stepExecution.getStepName());
        if(cxt.containsKey(PromotionKeys.NEXT_PROCESSING_FILE)){
            sql_file_path = cxt.getString(PromotionKeys.NEXT_PROCESSING_FILE);
        }

        // バッチ処理進捗 XX/XX の形式で保持している場合、取得してstatusに追加
        String status = "";
        if(cxt.containsKey(PromotionKeys.CONVERT_PROGRESS)){
            status = cxt.getString(PromotionKeys.CONVERT_PROGRESS);
        }

        // add #10859-6 djy start
        String facilityCd = stepExecution.getJobParameters().getString(ApplicationConst.JobParameterKeys.FACILITY_CD);
        String typeName = null;
        String tableName = PsqlCopyUtils.getTableName(sql_file_path);
        if(PsqlCopyUtils.isDiffTable(sql_file_path)){
            typeName = "差分";
        }else{
            if(!ObjectUtils.isEmpty(tableName)){
                GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
                if(globalContext != null && globalContext.AlreadyImportedTableSet != null && !globalContext.AlreadyImportedTableSet.isEmpty() && globalContext.AlreadyImportedTableSet.contains(tableName)){
                    typeName = "追加";
                }else {
                    typeName = "初回";
                }
            }
        }
        // add #10859-6 djy end

        int convertProcId = cxt.getInt(PromotionKeys.CONVERT_PROC_ID);
        
        BatchConvertTableStatus e = new BatchConvertTableStatus();
        e.setConvertProcId(convertProcId);
        e.setJobInstanceId(job_instance_id);
        e.setSqlFilePath(sql_file_path);
        e.setTableName(PsqlCopyUtils.getTableName(sql_file_path));
        e.setStatus(status);
        e.setProcName(proc_name);
        e.setContent(content);
        // add #10859-6 djy start
        e.setTypeName(typeName);
        e.setFacilityCd(facilityCd);
        // add #10859-6 djy end
        this.createConvertTableStatus(e);
    }

    /**
     * テーブル毎の進捗更新
     * @param context
     * @param content
     */
    public void createConvertTableStatus(ChunkContext context,String content){
        this.createConvertTableStatus(context.getStepContext().getStepExecution(),content);
    }


    /**
     * エンティティを元にコンバートテーブルステータスへ１レコード登録する
     * @param e
     */
    public void createConvertTableStatus(BatchConvertTableStatus e){
        String sql = "INSERT "
        + "INTO batch_convert_table_status( "
        + "  convert_proc_id "
        + "  , job_instance_id "
        + "  , table_name "
        // add #10859-6 djy start
        + "  , type_name "
        + "  , facility_cd "
        // add #10859-6 djy end
        + "  , sql_file_path "
        + "  , status "
        + "  , proc_name "
        + "  , content "
        + "  , reg_date "
        + ") "
        + "VALUES ( "
        + "  :convert_proc_id "
        + "  , :job_instance_id "
        + "  , :table_name "
        // add #10859-6 djy start
        + "  , :type_name "
        + "  , :facility_cd "
        // add #10859-6 djy end
        + "  , :sql_file_path "
        + "  , :status "
        + "  , :proc_name "
        + "  , :content "
        + "  , :reg_date "
        + ") ";
    
        Map<String,Object> paraMap = new MapSqlParameterSource("convert_proc_id",e.getConvertProcId())
                    .addValue("job_instance_id",e.getJobInstanceId())
                    .addValue("table_name",e.getTableName())
                    // add #10859-6 djy start
                    .addValue("type_name",e.getTypeName())
                    .addValue("facility_cd",e.getFacilityCd())
                    // add #10859-6 djy end
                    .addValue("sql_file_path",e.getSqlFilePath())
                    .addValue("status",e.getStatus())
                    .addValue("proc_name",e.getProcName())
                    .addValue("content",e.getContent())
                    .addValue("reg_date",e.getRegDate())
                    .getValues();

        namedParameterJdbcTemplateConvert.update(sql,paraMap);
    }


    /**
     * BatchConvertTableStatusテーブル登録用エンティティ
     */
    @Data
    private static class BatchConvertTableStatus{
        // シーケンスのため、基本設定しない
        private long OrderNo;
        private int ConvertProcId;
        private long JobInstanceId;
        private String TableName;
        // add #10859-6 djy start
        private String TypeName;
        private String facilityCd;
        // add #10859-6 djy end
        private String SqlFilePath;
        private String Status;
        private String ProcName;
        private String Content;
        private LocalDateTime RegDate;

        // コンストラクタ、現在の日時を設定
        public BatchConvertTableStatus(){
            this.RegDate = LocalDateTime.now();
        }
    }


}