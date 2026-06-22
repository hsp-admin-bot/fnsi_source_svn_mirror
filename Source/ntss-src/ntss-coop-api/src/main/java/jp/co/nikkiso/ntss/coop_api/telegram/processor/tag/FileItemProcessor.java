package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.BiFunction;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramHelper;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLayoutValidator;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Telegram;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.selector.FragmentItemProcessorSelector;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.xml.File;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Record;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * {@code FileItemProcessor} は {@link File} タグを処理し、電文を生成するプロセッサです。
 */
@Component
public class FileItemProcessor extends ItemProcessorBase<Telegram> {
    private static final String FILE_NAME = "file_name";
    private static final String FOLDER_NAME = "folder_name";
    private static final String DETAIL_ID = "detail_id";
    private final TelegramLayoutValidator layoutValidator;
    private final RecordItemProcessor recordItemProcessor;

    public FileItemProcessor(TelegramHelper helper, TelegramLayoutValidator layoutValidator,
            ConvertCommonService convertCommonService, FragmentItemProcessorSelector fragmentItemProcessorSelector,
            RecordItemProcessor recordItemProcessor) {
        super(helper, convertCommonService, fragmentItemProcessorSelector);
        this.layoutValidator = layoutValidator;
        this.recordItemProcessor = recordItemProcessor;
    }

    @Override
    public boolean supports(Item item) {
        return item instanceof File;
    }

    @Override
    protected List<Telegram> doProcess(Item item, ProcessingContext baseContext) {
        File file = (File) item;
        List<Map<String, Object>> dataSetList = helper.getDataSetList(file, baseContext);

        // 並列に List<Telegram> を取得 → flatten
        return runParallelInOrder(
                dataSetList,
                (row, i) -> processRow(row, i, file, baseContext) // 各行ごとに List<Telegram> を返す
        ).stream()
                .flatMap(List::stream)
                .collect(Collectors.toList());
    }

    private List<Telegram> processRow(Map<String, Object> row, int rowIndex, File file, ProcessingContext baseContext) {
        layoutValidator.validateDetailId(row, baseContext.getTelegramContext(), file.getName());

        String detailId = String.valueOf(row.get(DETAIL_ID));
        MstCoopLayoutDetail detail = helper.fetchLayoutDetail(detailId, file, baseContext);
        layoutValidator.validate(detail.getCoopSettingRoot().getItemList());

        ProcessingContext rowContext = buildRowContext(row, rowIndex, file, baseContext, detail);

        return selectTelegramStrategy(row, detail, rowContext);
    }

    private List<Telegram> selectTelegramStrategy(Map<String, Object> row,
            MstCoopLayoutDetail detail, ProcessingContext rowContext) {
        if (shouldCreateNestedFile(detail)) {
            return createNestedFileTelegrams(detail, rowContext);
        } else if (shouldCreateDetailRecords(detail)) {
            validateFileName(row, rowContext);
            List<List<Fragment>> records = createDetailRecords(detail, rowContext);
            return buildTelegramFromRecords(row, records);
        } else {
            validateFileName(row, rowContext);
            List<Fragment> fragments = createDetailFragments(detail, rowContext);
            return buildTelegramFromFragments(row, fragments);
        }
    }

    private boolean shouldCreateNestedFile(MstCoopLayoutDetail detail) {
        return Optional.ofNullable(detail.getCoopSettingRoot().getItemList())
                .orElseGet(List::of)
                .stream()
                .anyMatch(item -> item instanceof File);
    }

    private boolean shouldCreateDetailRecords(MstCoopLayoutDetail detail) {
        return Optional.ofNullable(detail.getCoopSettingRoot().getItemList())
                .orElseGet(List::of)
                .stream()
                .anyMatch(item -> item instanceof Record);
    }

    private List<Telegram> buildTelegram(Map<String, Object> row, BiFunction<String, String, Telegram> buildFunc) {
        List<Telegram> telegrams = new ArrayList<>();
        String folderName = Optional.ofNullable(row.get(FOLDER_NAME)).map(Object::toString).orElse(null);

        Optional.ofNullable(row.get(FILE_NAME))
                .map(Object::toString)
                .map(fileName -> buildFunc.apply(fileName, folderName))
                .ifPresent(telegrams::add);

        return telegrams;
    }

    private List<Telegram> buildTelegramFromRecords(Map<String, Object> row, List<List<Fragment>> records) {
        return buildTelegram(row, (fileName, folderName) -> Telegram
                .build(builder -> builder.fileName(fileName).folderName(folderName).addRecords(records)));
    }

    private List<Telegram> buildTelegramFromFragments(Map<String, Object> row, List<Fragment> fragments) {
        return buildTelegram(row, (fileName, folderName) -> Telegram
                .build(builder -> builder.fileName(fileName).folderName(folderName).addRecord(fragments)));
    }

    private void validateFileName(Map<String, Object> row, ProcessingContext baseContext) {
        Optional.ofNullable(row.get(FILE_NAME))
                .orElseThrow(() -> new NtssException("[file_name] カラムが設定されていません。 SqlCode:" + baseContext.getSqlCode()));
    }

    private List<List<Fragment>> createDetailRecords(MstCoopLayoutDetail detail, ProcessingContext rowContext) {
        List<List<Fragment>> records = new ArrayList<>();
        List<Item> items = Optional
                .ofNullable(detail.getCoopSettingRoot().getItemList())
                .orElseGet(List::of)
                .stream()
                .filter(item -> item instanceof Record)
                .toList();
        for (Item item : items) {
            records.addAll(recordItemProcessor.process(item, rowContext));
        }

        return records;
    }

    /**
     * ネストされたファイル電文を生成します。
     * 
     * @param detail
     * @param rowContext
     * @return ネストされたファイル電文のリスト
     */
    private List<Telegram> createNestedFileTelegrams(MstCoopLayoutDetail detail, ProcessingContext rowContext) {
        List<Telegram> telegrams = new ArrayList<>();
        List<Item> items = Optional
                .ofNullable(detail.getCoopSettingRoot().getItemList())
                .orElseGet(List::of)
                .stream()
                .filter(item -> item instanceof File)
                .toList();
        for (Item item : items) {
            telegrams.addAll(process(item, rowContext));
        }
        return telegrams;
    }
}
