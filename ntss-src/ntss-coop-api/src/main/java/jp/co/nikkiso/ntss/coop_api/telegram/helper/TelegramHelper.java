package jp.co.nikkiso.ntss.coop_api.telegram.helper;

import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.factory.TelegramFragmentFactory;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 電文処理の共通ヘルパークラスです。
 * 電文作成における共通処理を提供します。
 */
@Component
public class TelegramHelper {

    @Autowired
    private ConvertSendCommonService convertSendCommonService;
    @Autowired
    private ConvertCommonService convertCommonService;
    @Autowired
    private TelegramFragmentFactory telegramFragmentFactory;

    private static final String DEFAULT_ENCODE = JournalConvertConstants.TELEGRAM_ENCODING_BY_MS932;

    /**
     * 1つのXML要素(レイアウト)に対する電文作成
     *
     * @param item             - {@link Item}
     * @param calculator       - {@link TelegramLengthCalculator}
     * @param dataSetResultMap - mst_coop_layoutのdataset結果Map
     * @param sqlCode          - 親detailレイアウトのoccから受け取ったSQLCODE
     * @param journal          - {@link SysCoopJournal}
     * @param detailLayout     - 親detailレイアウト
     * @param dataSetResult    - detailレイアウトからループしているdatasetの1要素
     * @return 1つのXML要素(レイアウト)に対する電文
     * @throws UnsupportedEncodingException
     * @throws Exception
     */
    public String createTelegramFragment(Item item, MstCoopLayoutDetail detailLayout, ProcessingContext context) {
        try {
            // パディング専用のレイアウトが来たら、後続処理である出力のロジックを介さずパディングする
            if (detailLayout != null && detailLayout.getCoopCdDetailSub().equals("blank")) {
                return "";
            }
            String expression;
            expression = URLDecoder.decode(item.getValue(), DEFAULT_ENCODE);
            String fragment = telegramFragmentFactory.createFragment(expression, item, context);
            return context
                    .getTelegramContext()
                    .getFormat()
                    .format(fragment);
        } catch (UnsupportedEncodingException e) {
            throw new NtssException(e);
        }
    }

    /**
     * オカレンス要素に紐づくデータセットを取得します。
     *
     * @param occ     処理対象のオカレンス要素（sqlCode を含む）
     * @param context データセットおよびジャーナル情報を含む処理コンテキスト
     * @return オカレンスに対応するデータセットリスト（Mapのリスト）
     */
    public List<Map<String, Object>> getDataSetList(Occ occ, ProcessingContext context) {
        List<Map<String, Object>> dataSetList = context.getDataSetResultMap().get(occ.getSqlCode());
        if (dataSetList == null) {
            throw new NtssException("データの取得に失敗しました。拡張設定に該当SQLの設定が含まれていない可能性があります。SQLCode: " + occ.getSqlCode());
        }
        return dataSetList;
    }

    /**
     * レイアウト詳細情報を取得します。
     * @param detailId 詳細ID
     * @param occ      Occ要素
     * @param context  ProcessingContext
     * @return 
     */
    public MstCoopLayoutDetail fetchLayoutDetail(String detailId, Occ occ, ProcessingContext context) {
        return convertCommonService.getMstCoopLayoutDetailBySub(
                context.getJournal().getFacilityCd(),
                context.getJournal().getDirection(),
                context.getJournal().getCoopCd(),
                context.getJournal().getCoopVersion(),
                occ.getDetail(),
                detailId);
    }

    /**
     * レイアウト詳細情報を取得します。
     * @param detailId 詳細ID
     * @param occ      Occ要素
     * @param context telegramContext
     * @return 
     */
    public MstCoopLayoutDetail fetchLayoutDetail(String detailId, Occ occ, TelegramContext context) {
        return convertCommonService.getMstCoopLayoutDetailBySub(
                context.getJournal().getFacilityCd(),
                context.getJournal().getDirection(),
                context.getJournal().getCoopCd(),
                context.getJournal().getCoopVersion(),
                occ.getDetail(),
                detailId);
    }

    /**
     * dataset を List<Map<String, Object>> として取り出します。
     */
    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> extractDatasetList(LayoutExtSetting coopExtSetting) {
        Object datasetObj = coopExtSetting.get("dataset");

        if (!(datasetObj instanceof List)) {
            throw new IllegalArgumentException("dataset の型が List ではありません");
        }
        List<?> list = (List<?>) datasetObj;
        if (list.isEmpty() || !(list.get(0) instanceof Map)) {
            throw new IllegalArgumentException("dataset のリストの中身が Map ではありません");
        }

        return (List<Map<String, Object>>) datasetObj;
    }

    /**
     * dataset の中の $SHARED_SYSDATE を置換します。
     */
    private void replaceSharedSysdate(List<Map<String, Object>> datasetList, LocalDateTime now) {
        Pattern pattern = Pattern.compile("\\$SHARED_SYSDATE(?::([a-zA-Z0-9/\\- :]+))?");

        for (Map<String, Object> datasetMap : datasetList) {
            for (Map.Entry<String, Object> entry : datasetMap.entrySet()) {
                Object value = entry.getValue();

                if (value instanceof String) {
                    String replacedValue = replaceSysdateInString((String) value, pattern, now);
                    entry.setValue(replacedValue);
                }
            }
        }
    }

    /**
     * 1つの文字列内の $SHARED_SYSDATE を置換します。
     */
    private String replaceSysdateInString(String strValue, Pattern pattern, LocalDateTime now) {
        Matcher matcher = pattern.matcher(strValue);
        StringBuffer sb = new StringBuffer();

        while (matcher.find()) {
            String format = matcher.group(1);
            if (format == null || format.trim().isEmpty()) {
                format = "yyyyMMdd";
            }

            String formattedDate;
            try {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format.trim());
                formattedDate = formatter.format(now);
            } catch (Exception e) {
                formattedDate = "[INVALID_FORMAT]";
            }

            matcher.appendReplacement(sb, Matcher.quoteReplacement(formattedDate));
        }
        matcher.appendTail(sb);

        return sb.toString();
    }

    /**
     * 共有システム日時をSharedSysdateStoreに格納、またはcoop_ext_setting内の$SHARED_SYSDATEを置き換えます。
     * 
     * @param context TelegramContext
     */
    public void initSharedSysdate(TelegramContext context) {
        Root root = context.getLayout().getCoopSettingRoot();
        SharedSysdateStore sharedSysdateStore = context.getSharedSysdateStore();
        // 更新するフラグがtrueの場合はshared_sysdateの更新を行う
        if (root.getUseSharedSysdate() && root.getUpdateSharedSysdate()) {
            sharedSysdateStore
                    .putSysdate(
                            root.getName(),
                            0,
                            LocalDateTime.now());
        }
        // 共有システム時刻を使用する場合は、coop_ext_settingの$SHARED_SYSDATEを置き換える
        if (root.getUseSharedSysdate()) {
            LocalDateTime sharedSysdate = sharedSysdateStore
                    .getSysdate(new SharedSysdateStore.Key(root.getName(), 0));
            List<Map<String, Object>> datasetList = extractDatasetList(context.getLayout().getCoopExtSetting());
            replaceSharedSysdate(datasetList, sharedSysdate);
        }
    }

    /**
     * 共有システム日時をSharedSysdateStoreに格納、またはcoop_ext_setting内の$SHARED_SYSDATEを置き換えます。
     * 
     * @param context  ProcessingContext
     * @param rowIndex 行インデックス
     * @param detail   MstCoopLayoutDetail
     */
    public void putSharedSysdate(ProcessingContext context, int rowIndex, MstCoopLayoutDetail detail) {
        Root root = detail.getCoopSettingRoot();
        SharedSysdateStore sharedSysdateStore = context.getSharedSysdateStore();
        // 更新するフラグがtrueの場合はshared_sysdateの更新を行う
        if (root.getUseSharedSysdate() && root.getUpdateSharedSysdate()) {
            sharedSysdateStore.putSysdate(
                    root.getName(),
                    rowIndex,
                    LocalDateTime.now());
        }
        // 共有システム時刻を使用する場合は、coop_ext_settingの$SHARED_SYSDATEを置き換える
        if (root.getUseSharedSysdate()) {
            LocalDateTime sharedSysdate = sharedSysdateStore
                    .getSysdate(new SharedSysdateStore.Key(root.getName(), rowIndex));
            List<Map<String, Object>> datasetList = extractDatasetList(detail.getCoopExtSetting());
            replaceSharedSysdate(datasetList, sharedSysdate);
        }
    }

    /**
     * 詳細レイアウトのcoop_ext_settingデータを取得し、ProcessingContextに追加します。
     * 
     * @param detail
     * @param rowContext
     * @return
     */
    /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
    public Map<String, List<Map<String, Object>>> fetchDetailCoopExtSettingData(LayoutExtSetting coopExtSetting,
            SysCoopJournal journal, Map<String, Object> row, MstCoopIni coopIni) {
        if (coopExtSetting == null) {
            throw new NtssException("detailレイアウトの拡張設定が存在しません。journal.coop_cd: " + journal.getCoopCd()
                    + ", destination: " + journal.getDirection());
        }
        try {
            Map<String, List<Map<String, Object>>> dataSetResultMap = convertSendCommonService
                    .createRequestAndRequestByDataSetApi(
                            journal,
                            coopExtSetting,
                            row,
                            coopIni);
            return dataSetResultMap;
        } catch (Exception e) {
            throw new NtssException("detailレイアウトの拡張設定データの取得に失敗しました。journal.coop_cd: " + journal.getCoopCd()
                    + ", destination: " + journal.getDirection(), e);
        }
    }
  /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
}