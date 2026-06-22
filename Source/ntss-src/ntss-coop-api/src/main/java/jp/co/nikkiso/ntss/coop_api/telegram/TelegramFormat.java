package jp.co.nikkiso.ntss.coop_api.telegram;

/**
 * 電文の出力形式を表す列挙型です。
 * 使用例：TelegramFormat.CSV
 */
public enum TelegramFormat {
    /**
     * CSV形式です。
     */
    CSV {
        /**
         * CSV形式で出力するために文字列をエスケープします。
         * <p>
         * このメソッドは以下の要件を満たしています：
         * </p>
         * <ul>
         * <li>値に改行（\n または \r）やカンマ（,）が含まれる場合は、
         * 値全体をダブルクォーテーション（"）で囲みます。</li>
         * <li>値にダブルクォーテーション（"）が含まれる場合は、
         * CSVの仕様に従ってダブルクォーテーションを2つ（""）にエスケープします。</li>
         * </ul>
         * 
         * @param value 対象となる文字列（null の場合は空文字として扱われます）
         * @return CSV仕様に従って整形された文字列
         */
        @Override
        public String format(String value) {
            if (value == null)
                return "";

            boolean containsSpecialChar = value.contains(",") || value.contains("\"") || value.contains("\n")
                    || value.contains("\r");

            // ダブルクォーテーションが含まれる場合は "" にエスケープ
            String escaped = value.replace("\"", "\"\"");

            // 改行やカンマが含まれる場合は全体を "..." で囲む
            if (containsSpecialChar) {
                return "\"" + escaped + "\"";
            } else {
                return escaped;
            }
        }
    }
    /**
     * XMLやTEXTなどの他のフォーマットを追加することができます。
     */
    ;

    /**
     * 文字列から TelegramFormat を取得します。
     * 入力が null または不正な形式の場合は null を返します。
     *
     * @param value 文字列形式（例: "csv", "XML"）
     * @return 対応する TelegramFormat、存在しない場合は null
     */
    public static TelegramFormat fromString(String value) {
        if (value == null)
            return null;
        switch (value.toUpperCase()) {
            case "CSV":
                return CSV;
            default:
                return null;
        }
    }

    /**
     * 指定された値をこのフォーマットに基づいて変換します。
     * 
     * @param value 変換対象の値
     * @return 変換後の文字列
     */
    public abstract String format(String value);
}