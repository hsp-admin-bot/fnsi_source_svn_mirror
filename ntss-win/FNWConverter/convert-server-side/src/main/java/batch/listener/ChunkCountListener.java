package batch.listener;

import java.text.MessageFormat;

import batch.ApplicationConst;
import org.springframework.batch.core.ChunkListener;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import batch.ApplicationConst.JobParameterKeys;
import batch.part.ProgressManagement;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * 指定した間隔で処理されたアイテムの数を記録する
 */
@Component
public class ChunkCountListener implements ChunkListener{


	private MessageFormat fmt = new MessageFormat("{0} 行 処理完了");


	@Autowired
	ProgressManagement progressManagement;

	/**
	 * ロギング ツール クラスの導入
	 */
	@Autowired
	private EventLoggerUtil eventLoggerUtil;

	@Override
	public void beforeChunk(ChunkContext context) {
		// ジョブ停止判定
		String facility_cd = context.getStepContext().getJobParameters().get(JobParameterKeys.FACILITY_CD).toString();
		boolean isTerminate = progressManagement.isStatusEqualsTerminate(facility_cd);
		StepExecution se = context.getStepContext().getStepExecution();
		if(isTerminate){
			se.setTerminateOnly();
			//ログ
			EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("ジョブ停止命令確認 step: [" + se.getStepName() + "#beforeChunk]",
					facility_cd, "ChunkCountListener.beforeChunk(ChunkContext context)");
			eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.INFO);
		}else{
			//ログ
			EventLogMessage eventLogMessage1 = eventLoggerUtil.getEventLogMessage("ジョブ継続 step: [" + se.getStepName() + "#beforeChunk]",
					facility_cd, "ChunkCountListener.beforeChunk(ChunkContext context)");
			eventLoggerUtil.recordLog(facility_cd, eventLogMessage1, LogLevel.INFO);
		}
	}

	@Override
	public void afterChunk(ChunkContext context) {

		int count = context.getStepContext().getStepExecution().getReadCount();
		// csv 正しい実行行数の取得
		if (context!=null && (context.toString().contains("mni_monitor") || context.toString().contains("mnt_motion_record"))){
			count--;
		}
		String facility_cd = context.getStepContext().getJobParameters().get(JobParameterKeys.FACILITY_CD).toString();
		// 処理されたレコードの数がチャンク間隔の倍数である場合、または全件処理時、ログメッセージを出力
		//ログ
		EventLogMessage eventLogMessage1 = eventLoggerUtil.getEventLogMessage(fmt.format(new Object[] { count }),
				facility_cd, "ChunkCountListener.afterChunk(ChunkContext context)"); // mod #12229 ログの内容を修正する:beforeChunk->afterChunk shiyw 2025-12-19
		eventLoggerUtil.recordLog(facility_cd, eventLogMessage1, LogLevel.INFO);

		// テーブル毎の進捗更新
		// mod #10859-6 djy start
		String progress = context.getStepContext().getJobExecutionContext().get(ApplicationConst.PromotionKeys.TABLE_PROGRESS).toString();
		progressManagement.createConvertTableStatus(context,String.valueOf(count) + "件 処理完了"+"--"+progress+"--");
		// mod #10859-6 djy end
	}

	@Override
	public void afterChunkError(ChunkContext context) {
		// 何もしない
	}
}