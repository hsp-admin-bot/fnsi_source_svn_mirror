package jp.co.nikkiso.ntss.coop_api.telegram.helper;

import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.core.entity.xml.File;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Record;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * {@code TelegramLayoutValidator} は、電文レイアウト定義に対する構文的・論理的な検証処理を提供します。
 *
 * <p>
 * 検証対象は、Root直下のタグの混在禁止、明細取得のためのキー存在確認（detail_id, file_name）などです。
 * </p>
 *
 * <p>
 * 異常が検出された場合、{@link NtssException} をスローして上位へ通知します。
 * </p>
 */
@Component
public final class TelegramLayoutValidator {

    private final ConvertSendCommonService convertSendCommonService;

    /**
     * バリデータのコンストラクタ。
     *
     * @param convertSendCommonService 共通サービス（CRUD種別に応じた文字列取得など）
     */
    public TelegramLayoutValidator(ConvertSendCommonService convertSendCommonService) {
        this.convertSendCommonService = convertSendCommonService;
    }

    private enum TagCategory {
        FILE,
        RECORD,
        ITEM_OR_OCC;

        static Optional<TagCategory> of(Item item) {
            if (item instanceof File)
                return Optional.of(FILE);
            if (item instanceof Record)
                return Optional.of(RECORD);
            if (item instanceof Item || item instanceof Occ)
                return Optional.of(ITEM_OR_OCC);
            return Optional.empty(); // 想定外のタグは無視
        }
    }

    public void validate(List<Item> itemList) {
        validateExclusiveTags(itemList);
    }

    private static void validateExclusiveTags(List<Item> items) {
        if (items == null || items.isEmpty()) {
            return; // 空リストは検証不要
        }
        
        EnumSet<TagCategory> used = EnumSet.noneOf(TagCategory.class);

        for (Item item : items) {
            TagCategory.of(item).ifPresent(used::add);
            if (used.size() > 1) {
                throw new NtssException(
                        "連携電文設定マスタ（mst_coop_layout）の連携設定（coop_setting）のRoot直下に、"
                                + "<file>, <record>, <item>/<occ> タグが混在しています。同時に使用することはできません。"
                                + "いずれか1種類のみを使用してください。");
            }
        }
    }

    /**
     * 明細レコード処理に必要な {@code detail_id} キーが存在することを検証します。
     *
     * @param dataSet 検証対象のデータ行（キー:カラム名）
     * @param ctx     電文生成時の文脈情報
     * @param name    オカレンス名（エラーメッセージ出力用）
     * @throws NtssException detail_id が存在しない場合
     */
    public void validateDetailId(Map<String, Object> dataSet, TelegramContext ctx, String name) {
        if (!dataSet.containsKey("detail_id")) {
            throw new NtssException("対象datasetに必須なキーである[detail_id]が存在しません。"
                    + formatContextInfo(ctx, name));
        }
    }

    /**
     * ファイル出力処理に必要な {@code file_name} キーが存在することを検証します。
     *
     * @param dataSet 検証対象のデータ行（キー:カラム名）
     * @param ctx     電文生成時の文脈情報
     * @param name    項目名またはファイル名（エラーメッセージ出力用）
     * @throws NtssException file_name が存在しない場合
     */
    public void validateFileName(Map<String, Object> dataSet, TelegramContext ctx, String name) {
        if (!dataSet.containsKey("file_name")) {
            throw new NtssException("対象datasetに必須なキーである[file_name]が存在しません。"
                    + formatContextInfo(ctx, name));
        }
    }

    /**
     * エラーメッセージに使用するジャーナル情報を文字列として整形します。
     *
     * @param ctx  文脈情報
     * @param name 項目名やオカレンス名
     * @return 整形済みのエラーメッセージ一部
     */
    private String formatContextInfo(TelegramContext ctx, String name) {
        return String.format(" facility_cd:[%s], coop_cd:[%s], coop_version:[%s], coop_cd_sub:[%s], name:[%s]",
                ctx.getJournal().getFacilityCd(),
                ctx.getJournal().getCoopCd(),
                ctx.getJournal().getCoopVersion(),
                convertSendCommonService.getCoopCdSub(ctx.getJournal().getCrud()),
                name);
    }
}
