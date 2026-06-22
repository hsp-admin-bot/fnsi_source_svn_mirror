package jp.co.nikkiso.ntss.admin_web.request.weight;

import java.math.BigDecimal;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
public class WeightStateRequest {

  /**
   * カード読み取りクラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class CardReadValue {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * カードのidm
     */
    @JsonProperty("idm")
    private String idm;

    /**
     * カードに記録されているid
     */
    @JsonProperty("id")
    private String id;

    // add FNSI-仕様追加 カード有効無効なチェック処理 徐 start
    /**
     * カードチェック結果
     */
    @JsonProperty("cardCheckValue")
    private String cardCheckValue;
    // add FNSI-仕様追加 カード有効無効なチェック処理 徐 end
    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public CardReadValue(String value) {
      try {
        CardReadValue obj = objectMapper.readValue(value, CardReadValue.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
      }
    }

    /**
     * 基本型の値を返す.
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  /**
   * 体重計識別コード
   */
  private Long weightCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 体重計番号
   */
  private int weightNo;
  /**
   * デバイスエッジ番号
   */
  private int deviceEdgeNo;
  /**
   * カード読み取り値
   */
  private CardReadValue cardReadValue;
  /**
   * カード書き込み値
   */
  private String cardWriteValue;
  /**
   * 測定重量
   */
  private BigDecimal scaleValue;
  /**
   * カード書き込み結果
   */
  private int writeResult;
  /**
   * 体重計接続状態
   */
  private String isConnect;

  // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
  /**
   * 田中衡機の測定重量
   */
  private String scaleValueList;
  // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end
}
