package jp.co.nikkiso.ntss.coop_api.telegram.model;

import lombok.Builder;
import lombok.ToString;

/**
 * {@code TelegramDump} は、電文の出力内容とその出力先パスを保持するデータモデルです。
 * <p>
 * 主に電文生成処理の結果として使用され、ファイルへの書き出しや後続処理において
 * ダンプされた電文データを管理する役割を担います。
 * </p>
 *
 * <p>本クラスはイミュータブルであり、インスタンス生成後に状態が変化することはありません。</p>
 */
@Builder
@ToString
public class TelegramDump {

    /** 出力ファイルのパス。複数ファイルの場合は結合されたファイル名形式になることがあります。 */
    private final String dumpPath;

    /** 電文本体の内容。通常はCSVやTEXT形式で生成された整形済み文字列。 */
    private final String dumpString;

    /**
     * 出力先ファイルパスを取得します。
     *
     * @return ダンプファイルのパス（例: `file1.csv`、または `file1.csv|file2.csv` など）
     */
    public String getDumpPath() {
        return dumpPath;
    }

    /**
     * 整形済みの電文文字列を取得します。
     *
     * @return 出力される電文内容の文字列（改行や区切り文字を含む）
     */
    public String getDumpString() {
        return dumpString;
    }
}
