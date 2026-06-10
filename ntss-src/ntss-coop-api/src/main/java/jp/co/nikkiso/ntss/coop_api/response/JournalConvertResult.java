package jp.co.nikkiso.ntss.coop_api.response;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.springframework.util.StringUtils;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;

@Data
@AllArgsConstructor
public class JournalConvertResult {

  /**
   * 処理結果のHTTPステータスコード
   */
  @JsonProperty("status")
  private int status;

  /**
   * 変換結果
   */
  @JsonProperty("result")
  private List<ResultMap> result;

  /**
   * 変換結果出力キー
   * */
  @Getter
  @AllArgsConstructor
  public enum ResultKey {

    /** 管理番号 */
    CTL_NO("ctl_no"),
    /** 変換ステータス */
    ANA_RESULT("ana_result"),
    /** メッセージ */
    MESSAGE("message");

    // フィールド変数
    private final String key;
  }

  /**
   * コンストラクタ ※メッセージのみ
   * @param status HttpStatus(int)
   * @param message 出力メッセージ
   * */
  public JournalConvertResult(int status, String message) {
    this.status = status;
    this.result = new ArrayList<>();

    // 変換結果：メッセージのみ
    ResultMap rm = new ResultMap();
    rm.put(ResultKey.MESSAGE.getKey(), message);
    this.result.add(rm);
  }

  /**
   * ジャーナル変換結果を保持するマップクラス。
   */
  public static class ResultMap extends TreeMap<String, Object> {

    /**
     * キーが衝突した場合、指定された値を順次結合して保持する。
     *
     * @param key キー
     * @param value 追加する値
     */
    public void merge(String key, String value) {
      String v = (String) get(key);
      if (StringUtils.isEmpty(v)) {
        v = "";
      }

      super.put(key, v + value);
    }

    /**
     * キーが衝突した場合、値をリストに変更して登録された順に保持する。
     *
     * @param key キー
     * @param value 追加する値
     */
    public void putAppend(String key, Object value) {
      if (!containsKey(key)) {
        super.put(key, value);
        return;
      }

      Object v = get(key);

      if (v instanceof List) {
        List<Object> l = ObjectMapperUtil.castToObjectList(v);
        super.put(key, l);
        l.add(value);
        return;
      }

      List<Object> l = new ArrayList<>();
      l.add(v);
      l.add(value);
      super.put(key, l);
    }

    /**
     * マップの要素をすべて追加する。
     * キーが衝突した場合、値がリストでなければリストに変更して要素を追加する。
     *
     * @param m マップ
     */
    public void putAppendAll(Map<String, Object> m) {
      Set<String> keySet = m.keySet();

      for (String key : keySet) {
        putAppend(key, m.get(key));
      }
    }

    public void putSpecial(String key, Object value) {
      if (!super.containsKey(key)) {
        super.put("%%" + key, value);
      }
    }

    public Object getSpecial(String key) {
      return super.get("%%" + key);
    }
  }
}
