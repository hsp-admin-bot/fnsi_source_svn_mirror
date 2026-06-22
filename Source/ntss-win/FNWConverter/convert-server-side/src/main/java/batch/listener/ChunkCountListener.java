package batch.listener;

import java.text.MessageFormat;

import batch.ApplicationConst;
import org.springframework.batch.core.listener.ChunkListener;
import org.springframework.batch.core.scope.context.StepSynchronizationManager;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.infrastructure.item.Chunk;
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
public class ChunkCountListener implements ChunkListener<String, String>{


	private MessageFormat fmt = new MessageFormat("{0} 行 処理完了");


	@Autowired
	ProgressManagement progressManagement;

	/**
	 * ロギング ツール クラスの導入
	 */
	@Autowired
	private EventLoggerUtil eventLoggerUtil;

	@Override
	public void beforeChunk(Chunk<String> context) {
		// ジョブ停止判定

		StepExecution se =
				StepSynchronizationManager.getContext().getStepExecution();
		String facility_cd =
				se.getJobParameters().getString(JobParameterKeys.FACILITY_CD);
		boolean isTerminate = progressManagement.isStatusEqualsTerminate(facility_cd);


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
	public void afterChunk(Chunk<String> context) {

		StepExecution se =
				StepSynchronizationManager.getContext().getStepExecution();

		long count = context.getItems().size();
		// csv 正しい実行行数の取得
		if (context!=null && (context.toString().contains("mni_monitor") || context.toString().contains("mnt_motion_record"))){
			count--;
		}

		String facility_cd =
				se.getJobParameters().getString(JobParameterKeys.FACILITY_CD);
		// 処理されたレコードの数がチャンク間隔の倍数である場合、または全件処理時、ログメッセージを出力
		//ログ
		EventLogMessage eventLogMessage1 = eventLoggerUtil.getEventLogMessage(fmt.format(new Object[] { count }),
				facility_cd, "ChunkCountListener.afterChunk(ChunkContext context)"); // mod #12229 ログの内容を修正する:beforeChunk->afterChunk shiyw 2025-12-19
		eventLoggerUtil.recordLog(facility_cd, eventLogMessage1, LogLevel.INFO);

		// テーブル毎の進捗更新
		// mod #10859-6 djy start
		Object progressObj =
				se.getJobExecution()
						.getExecutionContext()
						.get(ApplicationConst.PromotionKeys.TABLE_PROGRESS);
		String progress =
				progressObj == null ? "" : progressObj.toString();
		progressManagement.createConvertTableStatus(se,String.valueOf(count) + "件 処理完了"+"--"+progress+"--");
		// mod #10859-6 djy end
	}

	@Override
	public void onChunkError(
			Exception exception,
			Chunk<String> chunk) {

		StepExecution se =
				StepSynchronizationManager.getContext().getStepExecution();

		String facility_cd =
				se.getJobParameters().getString(JobParameterKeys.FACILITY_CD);

		EventLogMessage eventLogMessage =
				eventLoggerUtil.getEventLogMessage(
						exception.getMessage(),
						facility_cd,
						"ChunkCountListener.onChunkError");

		eventLoggerUtil.recordLog(
				facility_cd,
				eventLogMessage,
				LogLevel.ERROR);
	}
}