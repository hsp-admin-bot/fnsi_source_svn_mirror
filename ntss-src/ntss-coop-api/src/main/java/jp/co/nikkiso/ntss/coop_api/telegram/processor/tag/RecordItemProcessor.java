package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramHelper;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLayoutValidator;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.selector.FragmentItemProcessorSelector;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Record;
import jp.co.nikkiso.ntss.core.exception.NtssException;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * {@code RecordItemProcessor} は {@link Record} 要素を処理し、
 * 複数のフラグメントリスト（レコード）を生成するプロセッサです。
 */
@Component
public class RecordItemProcessor extends ItemProcessorBase<List<Fragment>> {

    private final TelegramLayoutValidator layoutValidator;

    public RecordItemProcessor(TelegramHelper helper, TelegramLayoutValidator layoutValidator,
            ConvertCommonService convertCommonService,
            FragmentItemProcessorSelector fragmentItemProcessorSelector) {
        super(helper, convertCommonService, fragmentItemProcessorSelector);
        this.layoutValidator = layoutValidator;
    }

    @Override
    public boolean supports(Item item) {
        return item instanceof Record;
    }

    @Override
    protected List<List<Fragment>> doProcess(Item item, ProcessingContext baseContext) {
        Record record = (Record) item;
        List<Map<String, Object>> dataSetList = helper.getDataSetList(record, baseContext);

        List<List<Fragment>> records = runParallelInOrder(
                dataSetList,
                (row, i) -> processRow(row, i, record, baseContext));

        int repeatCount = parseRepeatCount(record);
        records.add(generatePadding(record, repeatCount, dataSetList.size(), baseContext));

        return records;
    }

    private List<Fragment> processRow(Map<String, Object> row, int rowIndex, Record record,
            ProcessingContext baseContext) {
        layoutValidator.validateDetailId(row, baseContext.getTelegramContext(), record.getName());

        String detailId = String.valueOf(row.get("detail_id"));
        MstCoopLayoutDetail detail = helper.fetchLayoutDetail(detailId, record, baseContext);

        ProcessingContext rowContext = buildRowContext(row, rowIndex, record, baseContext, detail);
        return createDetailFragments(detail, rowContext);
    }

    private int parseRepeatCount(Record record) {
        return Optional.ofNullable(record.getRepeat())
                .filter(s -> !s.isEmpty())
                .map(this::safeParseInt)
                .orElse(0);
    }

    private int safeParseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new NtssException("Record の repeat 属性が不正です: " + value, e);
        }
    }
}
