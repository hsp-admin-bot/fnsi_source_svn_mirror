package jp.co.nikkiso.ntss.coop_api.telegram.model;

/**
 * 電文の1項目を表すモデルクラスです。
 */
public class Fragment {

    /** 項目名（ログ・デバッグ用） */
    private String name;

    /** 値（または出力式） */
    private String value;

    public Fragment(String name, String value) {
        this.name = name;
        this.value = value;
    }

    public String getName() {
        return name;
    }

    public String getValue() {
        return value;
    }
}

