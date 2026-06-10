package jp.co.nikkiso.ntss.coop_api.telegram.context;

import jp.co.nikkiso.ntss.coop_api.telegram.helper.SharedSysdateStore;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 明細レイアウト単位での電文生成処理における文脈情報を保持するコンテキストクラスです。
 * <p>
 * {@link TelegramContext} に加えて、個別の明細定義
 * ({@link MstCoopLayoutDetail})、SQLコード、データセット結果を含みます。
 * 特に {@link jp.co.nikkiso.ntss.coop_api.telegram.processor.tag.ItemProcessor}
 * などの処理単位において、
 * 1レコードに対応した処理のための情報を提供します。
 * </p>
 */
public class ProcessingContext {

    /** 電文全体のコンテキスト（レイアウト、ジャーナルなどの基本情報） */
    private final TelegramContext telegramContext;

    /** 明細レイアウト情報（null の場合、ルート直下の処理を意味する） */
    private final MstCoopLayoutDetail detail;

    /** 対象となるSQL定義コード（空でない場合、動的SQL出力が前提） */
    private final String sqlCode;

    /** SQL実行結果の1行分のマップ（カラム名→値） */
    private final Map<String, Object> dataSetResult;

    /** 現在の共有システム日時キー（共有システム日時が有効な場合） */
    private final SharedSysdateStore.Key currentSharedSysdateKey;

    private Map<String, List<Map<String, Object>>> dataSetResultMap;

    private ProcessingContext(Builder builder) {
        this.telegramContext = builder.telegramContext;
        this.detail = builder.detail;
        this.sqlCode = builder.sqlCode;
        this.dataSetResult = builder.dataSetResult;
        this.currentSharedSysdateKey = builder.currentSharedSysdateKey;
        this.dataSetResultMap = builder.dataSetResultMap;
    }

    /**
     * コンテキストビルダーを取得します。
     *
     * @return {@link Builder}
     */
    public static Builder builder() {
        return new Builder();
    }

    /**
     * 電文全体のコンテキストを取得します。
     *
     * @return {@link TelegramContext}
     */
    public TelegramContext getTelegramContext() {
        return telegramContext;
    }

    /**
     * 明細レイアウト定義を取得します。
     *
     * @return {@link MstCoopLayoutDetail}
     */
    public MstCoopLayoutDetail getDetail() {
        return detail;
    }

    /**
     * SQLコード（-xxxxxなどの設定値）を取得します。
     *
     * @return SQL定義コード
     */
    public String getSqlCode() {
        return sqlCode;
    }

    /**
     * SQL結果の1行分のマップデータを取得します。
     *
     * @return カラム名→値のマップ
     */
    public Map<String, Object> getDataSetResult() {
        return dataSetResult;
    }

    /**
     * SQLコードごとのデータセット結果マップを取得します。
     *
     * @return SQLコード → レコード一覧マップ
     */
    public Map<String, List<Map<String, Object>>> getDataSetResultMap() {
        return dataSetResultMap;
    }

    /**
     * SQLコードごとのデータセット結果マップを設定します。
     * 
     * @param dataSetResultMap
     */
    public void addDataSetResultMap(Map<String, List<Map<String, Object>>> dataSetResultMap) {
        if (dataSetResultMap == null) {
            dataSetResultMap = new HashMap<>();
        }
        dataSetResultMap.putAll(dataSetResultMap);
    }

    // ===== デリゲート: TelegramContext を中継するヘルパーメソッド群 =====

    /**
     * ジャーナル情報を取得します。
     *
     * @return {@link SysCoopJournal}
     */
    public SysCoopJournal getJournal() {
        return telegramContext.getJournal();
    }

    /**
     * レイアウト定義を取得します。
     *
     * @return {@link MstCoopLayout}
     */
    public MstCoopLayout getLayout() {
        return telegramContext.getLayout();
    }

    /**
     * 現在の共有システム日時キーを取得します。
     * <p>
     * 共有システム日時が有効な場合、現在のキーを返します。
     * </p>
     *
     * @return 現在の共有システム日時キー
     */
    public SharedSysdateStore.Key getCurrentSharedSysdateKey() {
        return currentSharedSysdateKey;
    }

    /**
     * {@link ProcessingContext} を生成するビルダークラスです。
     */
    public static class Builder {
        public SharedSysdateStore.Key currentSharedSysdateKey;
        private TelegramContext telegramContext;
        private MstCoopLayoutDetail detail;
        private String sqlCode;
        private Map<String, Object> dataSetResult;
        private Map<String, List<Map<String, Object>>> dataSetResultMap;

        /**
         * 電文全体のコンテキストを設定します。
         *
         * @param telegramContext {@link TelegramContext}
         * @return this
         */
        public Builder telegramContext(TelegramContext telegramContext) {
            this.telegramContext = telegramContext;
            return this;
        }

        /**
         * 明細レイアウト情報を設定します。
         *
         * @param detail {@link MstCoopLayoutDetail}
         * @return this
         */
        public Builder detail(MstCoopLayoutDetail detail) {
            this.detail = detail;
            return this;
        }

        /**
         * SQL定義コードを設定します。
         *
         * @param sqlCode SQLコード（-xxxx形式など）
         * @return this
         */
        public Builder sqlCode(String sqlCode) {
            this.sqlCode = sqlCode;
            return this;
        }

        /**
         * SQL結果の1行分のデータを設定します。
         *
         * @param dataSetResult カラム名→値のマップ
         * @return this
         */
        public Builder dataSetResult(Map<String, Object> dataSetResult) {
            this.dataSetResult = dataSetResult;
            return this;
        }

        /**
         * 現在の共有システム日時キーを設定します。
         * <p>
         * 共有システム日時が有効な場合に使用されます。
         * </p>
         *
         * @param currentSharedSysdateKey 現在の共有システム日時キー
         * @return this
         */
        public Builder currentSharedSysdateKey(SharedSysdateStore.Key currentSharedSysdateKey) {
            this.currentSharedSysdateKey = currentSharedSysdateKey;
            return this;
        }

        public Builder dataSetResultMap(Map<String, List<Map<String, Object>>> dataSetResultMap) {
            this.dataSetResultMap = dataSetResultMap;
            return this;
        }

        /**
         * {@link ProcessingContext} のインスタンスを構築します。
         *
         * @return {@link ProcessingContext}
         */
        public ProcessingContext build() {
            return new ProcessingContext(this);
        }
    }

    /**
     * 共有システム日付のキャッシュ管理を行うストアを取得します。
     * 
     * @return {@link SharedSysdateStore}
     */
    public SharedSysdateStore getSharedSysdateStore() {
        return telegramContext.getSharedSysdateStore();
    }

}
