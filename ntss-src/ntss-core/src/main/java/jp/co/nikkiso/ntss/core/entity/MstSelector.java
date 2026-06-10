package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import org.springframework.dao.DataAccessException;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * マスタ定義のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_selector")
@Getter
@Setter
public class MstSelector extends BaseEntity {

  /**
   * 1カラムを表すクラス.
   */
  @Getter
  @Setter
  public static class Item {

    /**
     * コード項目 デフォルト値.
     */
    public static final Long CODE_DEFAULT = 1L;

    /**
     * 名称項目 デフォルト値.
     */
    public static final String NAME_DEFAULT = "";
    /**
     * JLAC10コード デフォルト値
     */
    public static final String JLAC10DC_DEFAULT = "";

    /**
     * 表示フラグ
     */
    public static final String IS_DISP_ONE = "1";

    /**
     *削除フラグ
     */
    public static final String IS_DEL_ZERO = "0";

    /**
     * コード項目.
     */
    @JsonProperty("code")
    private Long code = CODE_DEFAULT;

    /**
     * 名称項目.
     */
    @JsonProperty("name")
    private String name = NAME_DEFAULT;


    /**
     * JLAC10コード項目.
     */
    @JsonProperty("jlac10Cd")
    private String jlac10Cd = JLAC10DC_DEFAULT;

    /**
     * 表示フラグ
     */
    @JsonProperty("isDisp")
    private String is_disp = IS_DISP_ONE;

    /**
     *削除フラグ
     */
    @JsonProperty("isDel")
    private String is_del = IS_DEL_ZERO;

  }

  /**
   * 並び順情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrderSettings {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * カラムのリスト.
     */
    @JsonProperty("items")
    private List<Item> items;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public OrderSettings(String value) {
      try {
        OrderSettings obj = objectMapper.readValue(value, OrderSettings.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new DataAccessException("マスタセレクタの並び順設定内容が不正です") {
        };
      }
    }

    /**
     * 基本型の値を返す.
     *
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;

  /**
   * マスタ名(物理名称).
   */
  @Id
  private String masterPhysicalName;

  /**
   * 並び順設定.
   */
  private OrderSettings orderSettings;

}
