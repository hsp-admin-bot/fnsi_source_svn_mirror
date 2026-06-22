package batch.decider;

import batch.ApplicationConst;
import batch.ApplicationConst.YmlElementNames;
import batch.config.DbRelationConfig;
import batch.part.PsqlCopyUtils;
import org.springframework.batch.core.job.JobExecution;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.core.configuration.annotation.JobScope;
import org.springframework.batch.core.job.flow.FlowExecutionStatus;
import org.springframework.batch.core.job.flow.JobExecutionDecider;
import org.springframework.batch.infrastructure.item.ExecutionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;


/**
 * コード変換テーブルを本番DBから取得し作成するか判定するdecider
 * （クラス変数を保持しているため、インスタンスのスコープはJobScopeにし、
 * ジョブ起動毎にインスタンスを再作成する。）
 */
@Component
@JobScope
public class CreateCodeConvertTableDecider implements JobExecutionDecider {

    private int count = 0;

    @Autowired
    private DbRelationConfig dbRelationConfig;

    @Override
    public FlowExecutionStatus decide(JobExecution jobExecution, StepExecution stepExecution) {
        ExecutionContext context = jobExecution.getExecutionContext();

        // 処理対象ファイル名からテーブル名の取得
        String sqlFilePath = context.getString(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE);

        String tableName = PsqlCopyUtils.getTableName(sqlFilePath);

        if (!context.containsKey(ApplicationConst.PromotionKeys.COPIED_TABLE_NAMES)) {
            // キーが存在しない場合、作成する
            context.put(ApplicationConst.PromotionKeys.COPIED_TABLE_NAMES, new HashMap<String, String>());
        }

        int limit = dbRelationConfig.getCountRelationTable(tableName);
        if (count < limit) {
            // 後続ステップへ渡すパラメータを設定する
            context.putString(YmlElementNames.RELATION_TO_TABLE_NAME, dbRelationConfig.getConfig().get(tableName)[count]);

            count++;
            return new FlowExecutionStatus("CONTINUE");
        } else {
            // 完了
            count = 0;
            return new FlowExecutionStatus("COMPLETED");
        }
    }
}
