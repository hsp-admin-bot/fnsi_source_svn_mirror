package jp.co.nikkiso.ntss.coop_api.telegram.model;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import java.util.stream.Collectors;

/**
 * 電文1ファイル分を表すモデルクラスです。
 */
public class Telegram {
    private String folderName;

    /** 出力対象のファイル名（拡張子付き） */
    private final String fileName;

    private final List<List<Fragment>> records;

    private Telegram(String folderName, String fileName, List<List<Fragment>> records) {
        this.folderName = folderName;
        this.fileName = fileName;
        this.records = records;
    }

    /**
     * TelegramインスタンスをBuilderを使って構築します。
     *
     * @param builderConsumer TelegramBuilderを操作するConsumer
     * @return 構築されたTelegramインスタンス
     */
    public static Telegram build(Consumer<TelegramBuilder> builderConsumer) {
        TelegramBuilder builder = new TelegramBuilder();
        builderConsumer.accept(builder);
        return builder.build();
    }

    public String getFolderName() {
        return folderName;
    }

    public String getFileName() {
        return fileName;
    }

    public String getFilePathString() {
        if (folderName != null && !folderName.isEmpty()) {
            return Path.of(folderName, fileName).toString();
        }
        return fileName;
    }

    public List<List<Fragment>> getRecords() {
        return records;
    }

    public List<String> getRecordValues(String delimiter) {
        return records.stream()
                .filter(record -> record != null && !record.isEmpty())
                .map(record -> record.stream()
                        .map(Fragment::getValue)
                        .collect(Collectors.joining(delimiter)))
                .collect(Collectors.toList());
    }

    /**
     * Telegramの構築を補助するビルダークラスです。
     */
    public static class TelegramBuilder {
        private String folderName;
        private String fileName;
        private final List<List<Fragment>> records = new ArrayList<>();

        public TelegramBuilder folderName(String folderName) {
            this.folderName = folderName;
            return this;
        }

        /**
         * ファイル名を設定します。
         * 
         * @param fileName 出力対象のファイル名
         * @return ビルダー自身
         */
        public TelegramBuilder fileName(String fileName) {
            this.fileName = fileName;
            return this;
        }

        public TelegramBuilder addRecord(List<Fragment> record) {
            this.records.add(record);
            return this;
        }

        public TelegramBuilder addRecords(List<List<Fragment>> records) {
            this.records.addAll(records);
            return this;
        }

        /**
         * Telegramインスタンスを生成します。
         * 
         * @return Telegramオブジェクト
         */
        public Telegram build() {
            return new Telegram(folderName, fileName, records);
        }

    }
}
