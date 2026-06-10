package batch.step;

import batch.ApplicationConst;
import batch.listener.ChunkCountListener;
import batch.listener.JobStartEndLIstener;
import batch.listener.StepStartEndListener;
import batch.processor.PassThroughProcessor;
import batch.reader.FlatFileLineReader;
import batch.writer.BatchCsvWriterDb;
import batch.writer.JdbcBatchSqlItemWriter;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import utils.GlobalContext;
import utils.MasterDataService;

import javax.sql.DataSource;


/**
 * SQLファイルを読み込み実行するChunkStep
 */
@Configuration
@EnableBatchProcessing
public class ReadSqlFileWriteDbStep extends StepStartEndListener {

    private final String STEP_NAME = "ReadSqlFileWriteDbStep";

    @Autowired
    public StepBuilderFactory stepBuilderFactory;

    /**
     * 処理件数を通知
     */
    @Autowired
    public StepStartEndListener stepStartEndListener;

    @Autowired
    public ChunkCountListener chunkCountListener;

    /**
     * プライマリDBのデータソース（Convert）
     */
    @Autowired
    public DataSource dataSource;

    @Value("${spring.batch.chunkSize}")
    private int chunkSize;

    //add #12229 ord_weight_scale start
    @Autowired
    private MasterDataService masterDataService;
    //add #12229 ord_weight_scale end


    /**
     * 指定したSQLファイルを１行ずつ読み込む 戻り値は厳密に指定した方が良い。 インターフェースにすると@StepScopeにした場合、
     * openメソッドが無い理由でreaderがopenできなくてエラーになる場合あり
     */
    @Bean
    @StepScope
    public FlatFileItemReader<String> reader(@Value("#{jobExecutionContext['" + ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE + "']}") String inputFilePath) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        globalContext.fileName = inputFilePath;
        return new FlatFileLineReader(inputFilePath, java.nio.charset.StandardCharsets.UTF_8.toString());
    }

    /**
     * 読み込んだSQLファイルを１行ずつwriterに渡す
     */
    @Bean
    public PassThroughProcessor<String> processor() {
        return new PassThroughProcessor<String>();
    }

    /**
     * processorから受け取ったSQL文字列を実行する
     * 
     * @throws Exception
     */
    @Bean
    @StepScope
    public ItemWriter<String> writer() {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        // 7341
        if (globalContext.fileName.contains(".csv")) {
            BatchCsvWriterDb<String> aaa = new BatchCsvWriterDb<>(dataSource, globalContext.fileName, globalContext.facilityCd, globalContext);
            return aaa;
        } else {
            JdbcBatchSqlItemWriter<String> writer = new JdbcBatchSqlItemWriter<String>(dataSource, globalContext.fileName, globalContext.facilityCd, globalContext,masterDataService);
            return writer;
        }
    }

    /**
     * stepの作成
     * 
     * @throws Exception
     */
    @Bean(name = STEP_NAME)
    public Step step() throws Exception {
        return stepBuilderFactory.get(STEP_NAME)
            .listener(stepStartEndListener)
            .<String, String> chunk(chunkSize)
            .reader(reader(null))
            .processor(processor())
            .writer(writer())
            .listener(chunkCountListener)
            .build();
    }
}