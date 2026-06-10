package jp.co.nikkiso.ntss.core.entity.json;

import java.io.IOException;
import java.util.HashMap;

import org.seasar.doma.Domain;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.NoArgsConstructor;

/**
 * {@link MstCoopLayout}、{@link MstCoopLayoutDetail} の拡張設定カラムをマップするクラス。
 */
@Domain(valueType = String.class)
@NoArgsConstructor
public class LayoutExtSetting extends HashMap<String, Object> {
  /**
   * ObjectMapper
   */
  private static final ObjectMapper objectMapper = new ObjectMapper();

  /**
   * 文字列表現からJSONオブジェクトを構成する。
   *
   * @param value 文字列表現
   */
  public LayoutExtSetting(String value) {

    try {
      LayoutExtSetting l = objectMapper.readValue(value, LayoutExtSetting.class);

      for (String key : l.keySet()) {
        put(key, l.get(key));
      }

    } catch (IOException e) {
      throw new NtssException("変換レイアウトマスタJSONに不整合があります。", e);
    }
  }

  /**
   * 文字列表現を返す。
   *
   * @return 文字列表現
   */
  public String getValue() {
    try {
      return objectMapper.writeValueAsString(this);
    } catch (JsonProcessingException e) {
      throw new NtssException("JSON文字列への変換でエラーが発生しました。", e);
    }
  }
}
