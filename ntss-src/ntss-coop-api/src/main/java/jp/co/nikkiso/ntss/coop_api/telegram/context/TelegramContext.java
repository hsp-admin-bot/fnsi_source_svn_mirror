package jp.co.nikkiso.ntss.coop_api.telegram.context;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.entity.xml.Root;
import lombok.Getter;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.coop_api.telegram.TelegramFormat;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.SharedSysdateStore;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;

/**
 * 電文生成時に必要な文脈情報を保持するコンテキストクラスです。
 * <p>
 * 各種レイアウト・データセット・フォーマット・区切り文字等の情報を統一的に取り扱うことで、
 * CSVやXML、TEXTなどの電文形式に対応するビルダー処理における共通基盤を提供します。
 * 本クラスはイミュータブルであり、ビルダー形式でインスタンスを生成します。
 * </p>
 */
@Getter
public class TelegramContext {

    /** レイアウトXML上のルート要素（電文構造の出発点） */
    private final Root root;

    /** 電文生成に紐づく送受信ジャーナル情報（電文の種別、受付日など） */
    private final SysCoopJournal journal;

    /** 電文レイアウト定義（mst_coop_layout） */
    private final MstCoopLayout layout;

    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    /** 通連携設定情報（mst_coop_ini） */
    private final MstCoopIni coopIni;
    /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

    /** SQL実行結果を保持するマップ（SQLコード → レコード一覧） */
    private Map<String, List<Map<String, Object>>> dataSetResultMap;

    /** 電文のフォーマット（CSV, XML, TEXT 等） */
    private final TelegramFormat format;

    /** 電文項目を区切るための文字列（デフォルト: ","） */
    private final String delimiter;

    /** 日時処理に利用される Clock ラッパー */
    private final ClockWrapper clock;

    /** 複数ファイル電文出力時の区切りフォーマット（デフォルト: "----- %s -----"） */
    private final String fileSplitDelimiterFormat;

    /** 複数ファイル名の区切り文字（デフォルト: "|"） */
    private final String fileNameDelimiter;

    /** 共有システム日付のキャッシュ管理を行うストア */
    private SharedSysdateStore sharedSysdateStore;

    /**
     * 内部コンストラクタ（Builder 経由でのみ呼ばれます）
     *
     * @param builder ビルダーインスタンス
     */
    private TelegramContext(Builder builder) {
        this.root = builder.root;
        this.journal = builder.journal;
        this.layout = builder.layout;
        /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        this.coopIni = builder.coopIni;
        /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        this.dataSetResultMap = builder.dataSetResultMap;
        this.format = builder.format;
        this.delimiter = builder.delimiter;
        this.clock = builder.clock;
        this.fileSplitDelimiterFormat = builder.fileSplitDelimiterFormat;
        this.fileNameDelimiter = builder.fileNameDelimiter;
        this.sharedSysdateStore = builder.sharedSysdateStore;
    }

    /**
     * TelegramContext を構築するためのビルダーを返します。
     *
     * @return TelegramContext.Builder
     */
    public static Builder builder() {
        return new Builder();
    }

    /**
     * SQLコードごとのデータセット結果マップを追加します。
     *
     */
    public void addDataSetResultMap(Map<String, List<Map<String, Object>>> dataSetResultMap) {
        if (this.dataSetResultMap == null) {
            this.dataSetResultMap = new HashMap<>();
        }
        this.dataSetResultMap.putAll(dataSetResultMap);
    }

    /**
     * 共有システム日付のキャッシュ管理を行うストアを取得します。
     *
     * @return SharedSysdateStore
     * @throws IllegalStateException ストアが未設定の場合に発生
     */
    public SharedSysdateStore getSharedSysdateStore() {
        if (sharedSysdateStore == null) {
            throw new IllegalStateException("SharedSysdateStore is not initialized. Please set it using the builder.");
        }
        return sharedSysdateStore;
    }

    /**
     * TelegramContext のビルダークラスです。
     * 必須情報を順に設定して {@link #build()} を呼び出すことで安全にインスタンス生成できます。
     */
    public static class Builder {
        private Root root;
        private SysCoopJournal journal;
        private MstCoopLayout layout;
        /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        private MstCoopIni coopIni;
        /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        private Map<String, List<Map<String, Object>>> dataSetResultMap;
        private TelegramFormat format = TelegramFormat.CSV;
        private String delimiter = ",";
        private ClockWrapper clock;
        private String fileSplitDelimiterFormat = "----- %s -----";
        private String fileNameDelimiter = "|";
        private SharedSysdateStore sharedSysdateStore;

        /**
         * ルート要素を設定します。
         *
         * @param root XMLレイアウトのルート
         * @return this
         */
        public Builder root(Root root) {
            this.root = root;
            return this;
        }

        /**
         * ジャーナル情報を設定します。
         *
         * @param journal sys_coop_journal の内容
         * @return this
         */
        public Builder journal(SysCoopJournal journal) {
            this.journal = journal;
            return this;
        }

        /**
         * レイアウト定義を設定します。
         *
         * @param layout mst_coop_layout の内容
         * @return this
         */
        public Builder layout(MstCoopLayout layout) {
            this.layout = layout;
            return this;
        }

        /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        public Builder coopIni(MstCoopIni coopIni) {
            this.coopIni = coopIni;
            return this;
        }
        /* add by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

        /**
         * SQLコードごとのデータセット結果マップを設定します。
         *
         * @param map SQLコード → レコードリスト
         * @return this
         */
        public Builder dataSetResultMap(Map<String, List<Map<String, Object>>> map) {
            this.dataSetResultMap = map;
            return this;
        }

        /**
         * 電文の出力フォーマットを設定します。
         *
         * @param format CSV, XML など
         * @return this
         */
        public Builder format(TelegramFormat format) {
            this.format = format;
            return this;
        }

        /**
         * 電文の区切り文字を設定します。
         *
         * @param delimiter 区切り文字（デフォルト: ","）
         * @return this
         */
        public Builder delimiter(String delimiter) {
            this.delimiter = delimiter;
            return this;
        }

        /**
         * クロックラッパーを設定します（日時操作用）。
         *
         * @param clock {@link ClockWrapper}
         * @return this
         */
        public Builder clock(ClockWrapper clock) {
            this.clock = clock;
            return this;
        }

        /**
         * ファイル区切りフォーマットを設定します（複数ファイル出力用）。
         *
         * @param fileSplitDelimiterFormat デフォルト: "----- %s -----"
         * @return this
         */
        public Builder fileSplitDelimiterFormat(String fileSplitDelimiterFormat) {
            if (StringUtils.hasText(fileSplitDelimiterFormat)) {
                this.fileSplitDelimiterFormat = fileSplitDelimiterFormat;
                return this;
            }
            return this; // デフォルト値を使用
        }

        /**
         * ファイル名の区切り文字を設定します。
         *
         * @param fileNameDelimiter デフォルト: "|"
         * @return this
         */
        public Builder fileNameDelimiter(String fileNameDelimiter) {
            if (StringUtils.hasText(fileNameDelimiter)) {
                this.fileNameDelimiter = fileNameDelimiter;
                return this;
            }
            return this; // デフォルト値を使用
        }

        /**
         * 共有システム日付ストアを設定します。
         *
         * @param sharedSysdateStore 共有システム日付のキャッシュ管理を行うストア
         * @return this
         */
        public Builder sharedSysdateStore(SharedSysdateStore sharedSysdateStore) {
            this.sharedSysdateStore = sharedSysdateStore;
            return this;
        }

        /**
         * 設定された情報に基づいて TelegramContext を構築します。
         *
         * @return {@link TelegramContext}
         */
        public TelegramContext build() {
            return new TelegramContext(this);
        }

    }
}
