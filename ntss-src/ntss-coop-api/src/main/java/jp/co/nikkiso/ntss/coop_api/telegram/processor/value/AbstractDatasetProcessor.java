package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * {@code AbstractDatasetProcessor} は、{@code dataset:sqlCode.column} 形式で
 * データセットから値を抽出し、サブクラスで定義される変換処理を適用するための共通基底クラスです。
 *
 * <p>
 * このクラスを継承することで、共通処理（データセットの参照とパース）を再利用しつつ、
 * 要素種別（AUTH_ID, JOB_CD 等）ごとの変換処理を柔軟に実装できます。
 * </p>
 */
public abstract class AbstractDatasetProcessor implements ValueProcessor {
    @Autowired
    protected ConvertSendCommonService convertSendCommonService;

    /**
     * この Processor が対応する value の prefix を返します。
     * 例：auth_id, job_cd, staff_name など。
     *
     * @return 対象となる接頭辞文字列
     */
    protected abstract String getPrefix();

    /**
     * データセットから取得した raw 値を変換する処理です。
     * 各サブクラスで目的に応じた変換を実装します。
     *
     * @param value   データセットから抽出された値
     * @param context 処理コンテキスト
     * @return 変換後の文字列
     */
    protected abstract String convert(String value, ProcessingContext context);

    /**
     * 指定された式がこの Processor に対応する prefix で始まっているかを確認します。
     *
     * @param expression {@link Item#getValue()} の式
     * @return サポート対象であれば true
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && expression.startsWith(getPrefix() + ":");
    }

    /**
     * データセットから SQLCODE およびカラム名に基づいて値を取得し、変換後に返却します。
     *
     * @param expression "prefix:SQLCODE.column" の形式
     * @param item       対象 {@link Item}
     * @param context    処理文脈
     * @return 加工済みの出力文字列
     * @throws NtssException フォーマットエラー、データ不在などの異常時
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        String key = expression.replace(getPrefix() + ":", "");
        String[] parts = key.split("\\.");
        if (parts.length != 2) {
            throw new NtssException("形式が不正です: " + expression);
        }

        String targetSqlCode = parts[0];
        String column = parts[1];

        List<Map<String, Object>> rows = Optional.ofNullable(context.getDataSetResultMap().get(targetSqlCode))
                .orElseThrow(() -> new NtssException(
                        "SQLコード [" + targetSqlCode + "] に対するデータが取得できませんでした。"
                                + "電文生成用レイアウトの設定に不備がある可能性があります。"));

        if (rows == null || rows.isEmpty())
            return "";

        // 単発想定のため、決め打ち
        Object raw = rows.get(0).get(column);
        String value = raw != null ? raw.toString() : "";

        return convert(value, context);
    }

}
