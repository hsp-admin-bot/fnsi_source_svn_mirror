package batch.listener;

import batch.part.PsqlCopyUtils;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.job.parameters.JobParameters;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.core.listener.StepExecutionListener;
import org.springframework.batch.infrastructure.item.ExecutionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import batch.ApplicationConst.JobParameterKeys;
import batch.ApplicationConst.PromotionKeys;
import batch.part.ProgressManagement;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

@Component
public class StepStartEndListener implements StepExecutionListener {

    @Autowired
    ProgressManagement progressManagement;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Override
    public void beforeStep(StepExecution stepExecution) {
        // ジョブ停止判定・停止
        this.judgementJobStop(stepExecution);
        //施設コード取得
        JobParameters jobParameters = stepExecution.getJobParameters();
        String facility_cd = jobParameters.getString(JobParameterKeys.FACILITY_CD);
        // テーブル毎の進捗更新
        progressManagement.createConvertTableStatus(stepExecution,"開始");
        ExecutionContext cxt = stepExecution.getJobExecution().getExecutionContext();
        if(cxt.containsKey(PromotionKeys.NEXT_PROCESSING_FILE) && stepExecution.getStepName().equals("ReadSqlFileWriteDbStep")){
        	String tableName = PsqlCopyUtils.getTableName(cxt.getString(PromotionKeys.NEXT_PROCESSING_FILE));
        	//ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(tableName + " : 移行開始",
                    facility_cd, "StepStartEndListener.beforeStep(StepExecution stepExecution)");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.INFO);
        }
        
    }

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        // テーブル毎の進捗更新
        progressManagement.createConvertTableStatus(stepExecution,"終了");
        ExecutionContext cxt = stepExecution.getJobExecution().getExecutionContext();
        //施設コード取得
        JobParameters jobParameters = stepExecution.getJobParameters();
        String facility_cd = jobParameters.getString(JobParameterKeys.FACILITY_CD);
        if(cxt.containsKey(PromotionKeys.NEXT_PROCESSING_FILE) && stepExecution.getStepName().equals("TruncateTableStep")){
        	String tableName = PsqlCopyUtils.getTableName(cxt.getString(PromotionKeys.NEXT_PROCESSING_FILE));
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(tableName + " : 移行完了",
                    facility_cd, "StepStartEndListener.afterStep(StepExecution stepExecution)");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.INFO);
        }
        return stepExecution.getExitStatus();
    }



    /**
     * ジョブ停止判定・停止
     */
    private void judgementJobStop(StepExecution stepExecution){
		String facility_cd = stepExecution.getJobParameters().getString(JobParameterKeys.FACILITY_CD);
		boolean isTerminate = progressManagement.isStatusEqualsTerminate(facility_cd);
		if(isTerminate){
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("ジョブ停止命令確認 step: [" + stepExecution.getStepName() + "#beforeStep]",
                    facility_cd, "StepStartEndListener.judgementJobStop(StepExecution stepExecution)");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.DEBUG);
            stepExecution.setTerminateOnly();
		}else{
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("ジョブ継続 step: [" + stepExecution.getStepName() + "#beforeStep]",
                    facility_cd, "StepStartEndListener.judgementJobStop(StepExecution stepExecution)");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.DEBUG);
        }
    }

}