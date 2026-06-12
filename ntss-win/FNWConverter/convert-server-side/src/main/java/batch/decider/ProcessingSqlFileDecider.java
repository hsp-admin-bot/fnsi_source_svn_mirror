package batch.decider;

import java.io.File;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.List;

import org.springframework.batch.core.job.JobExecution;
import org.springframework.batch.core.job.parameters.JobParameters;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.core.configuration.annotation.JobScope;
import org.springframework.batch.core.job.flow.FlowExecutionStatus;
import org.springframework.batch.core.job.flow.JobExecutionDecider;
import org.springframework.batch.infrastructure.item.ExecutionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import batch.ApplicationConst;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.LogLevel;

/**
 * 処理するSQLファイルが存在するか判定するdecider
 *（クラス変数を保持しているため、インスタンスのスコープはJobScopeにし、
 * ジョブ起動毎にインスタンスを再作成する。）
 */
@Component
@JobScope
public class ProcessingSqlFileDecider implements JobExecutionDecider {

    private int index = 0;
    /**
     * すべてファイルのサイズ
     */
    private long allFileSize = 0;

    /**
     * 成功ファイルのサイズ
     */
    private long fileSize = 0;
    // add #10859-6 djy start
    private int currentTableNumber = 0;
    private int currentTableNumber_min = 1;
    private int currentTableNumber_coop = 1;
    private int currentTableNumber_trata = 1;
    private int currentTableNumber_checklist = 1;
    private int currentTableNumber_scale = 1;
    private int currentTableNumber_approve = 1;
    private int currentTableNumber_approvehis = 1;
    private String lastTable = "";
    // add #10859-6 djy end
    @Autowired
    Utils utils;

    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Override
    public FlowExecutionStatus decide(JobExecution jobExecution, StepExecution stepExecution) {
        ExecutionContext context = jobExecution.getExecutionContext();
        JobParameters jobParameters = jobExecution.getJobParameters();
        String facilityCd = jobParameters.getString(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();
        // ジョブ実行情報からカンマで区切られた処理対象のSQLファイルパスを取得
        String sqlFiles = context.getString(ApplicationConst.PromotionKeys.SQL_FILE_LIST);
        if(null == sqlFiles || sqlFiles.isEmpty()){
            return new FlowExecutionStatus("COMPLETED");
        }
        List<String> sqlFileList = Arrays.asList(sqlFiles.split(","));
        int limitIndex = sqlFileList.size() - 1;
        // 進捗情報をジョブ実行情報に設定

        // すべてファイルのサイズを作成する
        //mod zc 7339 start
        calculateAllFileSize(sqlFileList);
        String allleng = readAllLengthFromFile(stepExecution, facilityCd);
        //mod zc  7339 end
        if(index <=  limitIndex){
            updateProgressForCurrentFile(context, sqlFileList, allleng);
        } else {
            updateProgressForCompletion(context, allleng);
        }

        return resolveFlowExecutionStatus(context, sqlFileList, limitIndex);
    }

    /**
     * SQLファイルリストから全ファイルサイズの合計を算出する
     */
    private void calculateAllFileSize(List<String> sqlFileList) {
        allFileSize=0;
        for (String filePath : sqlFileList) {
            File file = new File(filePath);
            allFileSize = new BigDecimal(allFileSize).add(new BigDecimal(file.length())).longValue();
        }
    }

    /**
     * Filelength.txtから全長情報を読み込む
     */
    private String readAllLengthFromFile(StepExecution stepExecution, String facilityCd) {
        String   allleng="0";
        String   sinputePath = stepExecution.getJobExecution().getJobParameters().getString(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH);
        File fileProductionDbToConvertDb = new File(sinputePath + "/Filelength.txt");
        if (fileProductionDbToConvertDb != null && 0 != fileProductionDbToConvertDb.length()){
            List<String> sqlFilelength = null;
            try {
                sqlFilelength = utils.readFile(fileProductionDbToConvertDb);
                allleng = sqlFilelength.get(0);
            } catch (Exception e) {
                eventLoggerUtil.recordLog(
                        facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "/Filelength.txtファイル読み込み異常：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".decide()"),
                    LogLevel.ERROR);
            }
        }
        return allleng;
    }

    /**
     * 処理中のSQLファイルに対する進捗情報を更新する
     */
    private void updateProgressForCurrentFile(ExecutionContext context, List<String> sqlFileList, String allleng) {
            // 成功ファイルのサイズの追加
            File successFile = new File(sqlFileList.get(index));
            fileSize = new BigDecimal(fileSize).add(new BigDecimal(successFile.length())).longValue();
            //mod zc 7339 start
            // 進捗情報をジョブ実行情報の初期化
            Long surplus = Long.parseLong(allleng)-Long.parseLong(String.valueOf(allFileSize));
            String progress =surplus + "/"+allleng;
            //mod zc 7339 end
            context.putString(ApplicationConst.PromotionKeys.CONVERT_PROGRESS, progress);
            // add #10859-6 djy start
            String basename = successFile.getName();
            String tableName = basename.substring(0, basename.lastIndexOf('_'));

        updateCurrentTableNumber(tableName);
        lastTable = tableName;
        String string = context.getString(ApplicationConst.PromotionKeys.SQL_FILE_TABLE_COUNT_LIST);
        List<String> sqlFileCount = Arrays.asList(string.split(","));
        String s = sqlFileCount.get(index).replace(sqlFileList.get(index),"");
        BigDecimal bigDecimal1 = BigDecimal.valueOf(currentTableNumber*100);
        BigDecimal bigDecimal = BigDecimal.valueOf(Integer.parseInt(s));
        context.putString(ApplicationConst.PromotionKeys.TABLE_PROGRESS, bigDecimal1.divide(bigDecimal, 2, RoundingMode.HALF_UP)+"%");
        // add #10859-6 djy end
    }

    /**
     * テーブル名に基づいて現在のテーブル番号を更新する
     */
    private void updateCurrentTableNumber(String tableName) {
            if(tableName.equals("mni_monitor")){
                currentTableNumber= currentTableNumber_min++;
            }else if(tableName.equals("ord_coop_no")){
                currentTableNumber=currentTableNumber_coop++;
            }else if(tableName.equals("ord_treat_condition")){
                currentTableNumber=currentTableNumber_trata++;
            }else if(tableName.equals("ord_checklist")){
                currentTableNumber=currentTableNumber_checklist++;
            }else if(tableName.equals("ord_weight_scale")){
                currentTableNumber=currentTableNumber_scale++;
            }else if(tableName.equals("pat_ind_approve")){
                currentTableNumber=  currentTableNumber_approve++;
            }else if(tableName.equals("pat_ind_approve_history")){
                currentTableNumber=  currentTableNumber_approvehis++;
            } else if(lastTable.equals(tableName)){
                currentTableNumber++;
            } else {
                currentTableNumber = 1;
            }
    }

    /**
     * 全SQLファイル処理完了時の進捗情報を更新する
     */
    private void updateProgressForCompletion(ExecutionContext context, String allleng) {
            //mod zc 7339 start
            Long surplus = Long.parseLong(allleng)-Long.parseLong(String.valueOf(allFileSize));
            //mod zc 7339 end
            String progress = surplus+"/" + String.valueOf(allleng);
            context.putString(ApplicationConst.PromotionKeys.CONVERT_PROGRESS, progress);
            // add #10859-6 djy start
            context.putString(ApplicationConst.PromotionKeys.TABLE_PROGRESS, "100%");
            // add #10859-6 djy end
        }

    /**
     * 次に処理するSQLファイルの有無に応じてフロー実行ステータスを決定する
     */
    private FlowExecutionStatus resolveFlowExecutionStatus(ExecutionContext context, List<String> sqlFileList, int limitIndex) {
        if(index <=  limitIndex){
            // 処理対象SQLファイルあり
            String sqlFilePath = sqlFileList.get(index);
            context.putString(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE, sqlFilePath);
            index++;
            return new FlowExecutionStatus("CONTINUE");
        }else{
            // 完了
            return new FlowExecutionStatus("COMPLETED");
        }
    }
}
