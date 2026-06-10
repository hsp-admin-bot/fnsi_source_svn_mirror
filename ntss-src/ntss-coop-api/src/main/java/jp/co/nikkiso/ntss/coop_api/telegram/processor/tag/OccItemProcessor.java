package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramHelper;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLayoutValidator;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.selector.FragmentItemProcessorSelector;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;
import jp.co.nikkiso.ntss.core.exception.NtssException;

import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * {@code OccItemProcessor} は {@link Occ} 要素を処理し、フラグメントを生成するプロセッサです。
 */
@Component
@Order(0) // Occ優先
public class OccItemProcessor extends ItemProcessorBase<Fragment> implements FragmentItemProcessor {

    private final TelegramLayoutValidator layoutValidator;

    public OccItemProcessor(TelegramHelper helper, TelegramLayoutValidator layoutValidator,
            ConvertCommonService convertCommonService,
            FragmentItemProcessorSelector fragmentItemProcessorSelector) {
        super(helper, convertCommonService, fragmentItemProcessorSelector);
        this.layoutValidator = layoutValidator;
    }

    @Override
    public boolean supports(Item item) {
        return item instanceof Occ;
    }

    @Override
    protected List<Fragment> doProcess(Item item, ProcessingContext baseContext) {
        Occ occ = (Occ) item;
        List<Map<String, Object>> dataSetList = helper.getDataSetList(occ, baseContext);
        List<Fragment> fragments = new ArrayList<>();

        for (int i = 0; i < dataSetList.size(); i++) {
            fragments.addAll(processRow(dataSetList.get(i), i, occ, baseContext));
        }

        int repeatCount = parseRepeatCount(occ);
        fragments.addAll(generatePadding(occ, repeatCount, dataSetList.size(), baseContext));

        return fragments;
    }

    private List<Fragment> processRow(Map<String, Object> row, int rowIndex, Occ occ, ProcessingContext baseContext) {
        layoutValidator.validateDetailId(row, baseContext.getTelegramContext(), occ.getName());

        String detailId = String.valueOf(row.get("detail_id"));
        MstCoopLayoutDetail detail = helper.fetchLayoutDetail(detailId, occ, baseContext);

        ProcessingContext rowContext = buildRowContext(row, rowIndex, occ, baseContext, detail);
        return createDetailFragments(detail, rowContext);
    }

    private int parseRepeatCount(Occ occ) {
        return Optional.ofNullable(occ.getRepeat())
                .filter(s -> !s.isEmpty())
                .map(this::safeParseInt)
                .orElse(0);
    }

    private int safeParseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new NtssException("Occ の repeat 属性の値が不正です: " + value, e);
        }
    }
}
