package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramHelper;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLogger;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;

import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

/**
 * {@code SimpleItemProcessor} は {@link Item} のうち、通常項目（{@code <item>} タグ）を処理するクラスです。
 * <p>
 * {@link Item#isOcc()} が {@code false} である項目に対して、{@link TelegramHelper} を用いて
 * 単一の {@link Fragment} を生成します。
 * 処理中に {@link NtssException} が発生した場合はログ出力を行い、例外を再スローします。
 * </p>
 */
@Component
@Order(100)
public class SimpleItemProcessor implements FragmentItemProcessor {
    private final TelegramLogger logger;
    private final TelegramHelper helper;

    /**
     * コンストラクタ
     *
     * @param helper Telegram フラグメント生成支援ユーティリティ
     * @param logger ロガー
     */
    public SimpleItemProcessor(TelegramHelper helper, TelegramLogger logger) {
        this.helper = helper;
        this.logger = logger;
    }

    @Override
    public boolean supports(Item item) {
        return !item.isOcc();
    }

    @Override
    public List<Fragment> process(Item item, ProcessingContext context) {
        try {
            return Collections.singletonList(createFragment(item, context));
        } catch (NtssException e) {
            logError(context);
            throw e;
        }
    }

    /**
     * フラグメントを生成します。
     *
     * @param item 対象項目
     * @param context コンテキスト
     * @return 生成された Fragment
     */
    private Fragment createFragment(Item item, ProcessingContext context) {
        String fragmentValue = helper.createTelegramFragment(item, null, context);
        return new Fragment(item.getName(), fragmentValue);
    }

    /**
     * エラー時のログ出力を行います。
     *
     * @param context 実行コンテキスト
     */
    private void logError(ProcessingContext context) {
        logger.error(
                this.getClass(),
                context.getLayout().getFacilityCd(),
                "配信電文の作成に失敗しました。facility_cd:[%s], coop_cd:[%s], coop_version:[%s], coop_cd_sub:[%s]",
                context.getLayout().getFacilityCd(),
                context.getLayout().getCoopCd(),
                context.getLayout().getCoopVersion(),
                context.getLayout().getCoopCdSub());
    }
}
