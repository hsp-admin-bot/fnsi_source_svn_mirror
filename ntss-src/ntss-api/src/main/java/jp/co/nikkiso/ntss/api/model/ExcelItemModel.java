package jp.co.nikkiso.ntss.api.model;

import lombok.Data;
import lombok.Getter;
import org.apache.commons.lang3.StringUtils;

import java.util.HashMap;
import java.util.Map;

@Data
/**
 * Excel単一エンティティ
 * 帳票用
 *
 * @author 李
 * @date 2023-09-17
 */
public class ExcelItemModel {
  //region 元のデータ
  /**
   * 元のデータ文字列
   */
  @Getter
  private String propertiesStr;
  //endregion 元のデータ
  //region データ解析
  /**
   * ページオフセット
   */
  private Integer page;
  /**
   * x横 開始座標
   */
  private String start_x;
  /**
   * y縦 開始座標
   */
  private Integer start_y;
  /**
   * x横 終了座標
   */
  private String end_x;
  /**
   * y縦 終了座標
   */
  private Integer end_y;
  /**
   * オフセット量
   */
  private Integer offset;
  /**
   * はっしんよこざひょう
   */
  private String initiate_x;
  /**
   * イニシエータ縦座標
   */
  private Integer initiate_y;
  /**
   * 終了はっしんよこざひょう
   */
  private String end_initiate_x;
  /**
   * 終了イニシエータ縦座標
   */
  private Integer end_initiate_y;
  /**
   * イニシエータ座標オフセット
   */
  private Integer initiate_offset;
  /**
   * データ＃データ＃
   */
  private String data_value;
  //endregion データ解析

  //region グループ情報
  @Getter
  private boolean isGroupData;
  /**
   * グループ名
   */
  @Getter
  private String groupName;
  /**
   * グループが空かどうか
   */
  @Getter
  private boolean isNull;
  /**
   * グループ・データのソート
   */
  @Getter
  private int sort;
  //endregion グループ情報

  /**
   * @param key   元のデータ文字列
   * @param value データ＃データ＃
   */
  public ExcelItemModel(String key, String value) {
    init(key, value);
  }

  /**
   * 初始化方法
   *
   * @param key   元のデータ文字列
   * @param value データ＃データ＃
   */
  private void init(String key, String value) {
    if (StringUtils.isBlank(key)) {
      return;
    }

    this.propertiesStr = key;
    this.groupName = "NoGroupData";
    this.data_value = value;

    this.getCoordinateProperties();

    if (!this.isGroupData) {
      this.sort = 0;
      return;
    }

    this.getGroupInfo();
  }

  /**
   * 座標文字列に変換
   *
   * @return
   */
  public String getData_key() {
    if (!this.isGroupData) {
      return this.propertiesStr;
    }

    StringBuilder sb = new StringBuilder();
    if (isNotBlank(this.page)) {
      sb.append(this.page + "#");
    }
    if (isNotBlank(this.start_x)) {
      sb.append(this.start_x);
    }
    if (isNotBlank(this.start_y)) {
      sb.append(this.start_y);
    }
    if (isNotBlank(this.end_x)) {
      sb.append(":" + this.end_x);
    }
    if (isNotBlank(this.end_y)) {
      sb.append(this.end_y);
    }
    if (isNotBlank(this.offset)) {
      sb.append("-" + this.offset);
    }
    if (isNotBlank(this.initiate_x)) {
      sb.append("." + this.initiate_x);
    }
    if (isNotBlank(this.initiate_y)) {
      sb.append(this.initiate_y);
    }
    if (isNotBlank(this.end_initiate_x)) {
      sb.append(":" + this.end_initiate_x);
    }
    if (isNotBlank(this.end_initiate_y)) {
      sb.append(this.end_initiate_y);
    }
    if (isNotBlank(this.initiate_offset)) {
      sb.append("-" + this.initiate_offset);
    }

    return sb.toString();
  }

  private boolean isNotBlank(Object item) {
    if(item == null){
      return false;
    }

    switch (item.getClass().toString()) {
      case "class java.lang.String":
        return StringUtils.isNotBlank(item.toString());
      case "class java.lang.Integer":
        return item != null;
      default:
        return false;
    }
  }

  /**
   * 座標の分解と真の座標への変換
   *
   * @return 分解および変換後の文字列
   */
  private void getCoordinateProperties() {
    String temp_str = this.propertiesStr;
    Map<String, String> temp_map = null;
    String[] temp_sy = null;
    // mod #10356 クラス「治療状況」のデータ項目がテンプレート範囲外にあるとシステムエラー 吉 start
    // this.isGroupData = temp_str.contains("#");
    this.isGroupData = temp_str.contains("#") && temp_str.contains(".");
    // mod #10356 クラス「治療状況」のデータ項目がテンプレート範囲外にあるとシステムエラー 吉 end

    if (this.isGroupData) {
      this.page = Integer.parseInt(StringUtils.substringBefore(temp_str, "#"));
      temp_str = temp_str.replace(this.page + "#", "");

      temp_sy = temp_str.split("\\.");
      temp_map = getCoordinateProperties_xy(temp_sy[0]);

      if (temp_map != null) {
        this.start_x = (String) defaultValue(temp_map.get("x1"), "");
        this.start_y = temp_map.get("y1") != null ? Integer.parseInt((String) defaultValue(temp_map.get("y1"), "")) : null;
        this.end_x = (String) defaultValue(temp_map.get("x2"), "");
        this.end_y = temp_map.get("y2") != null ? Integer.parseInt((String) defaultValue(temp_map.get("y2"), "")) : null;
        this.offset = temp_map.get("o") != null ? Integer.parseInt((String) defaultValue(temp_map.get("o"), "")) : null;
      }

      if (temp_sy.length > 1) {
        temp_map = getCoordinateProperties_xy(temp_sy[1]);

        if (temp_map != null) {
          this.initiate_x = (String) defaultValue(temp_map.get("x1"), "");
          this.initiate_y = temp_map.get("y1") != null ? Integer.parseInt((String) defaultValue(temp_map.get("y1"), "")) : null;
          this.end_initiate_x = (String) defaultValue(temp_map.get("x2"), "");
          this.end_initiate_y = temp_map.get("y2") != null ? Integer.parseInt((String) defaultValue(temp_map.get("y2"), "")) : null;
          this.initiate_offset = temp_map.get("o") != null ? Integer.parseInt((String) defaultValue(temp_map.get("o"), "")) : null;
        }
      }
    }
  }

  /**
   * 解析横縦座標
   *
   * @param str
   * @return
   */
  private Map<String, String> getCoordinateProperties_xy(String str) {

    //    1#A21
    //    1#A21-1
    //    1#A21:E21-1
    //    1#B2-1.B2-1
    //    1#B2-1.B2:C2-1
    //    1#B2:C8-1.B2-1
    //    1#B2:C8-1.B2:C2-1

    //結果を返す
    Map<String, String> result = new HashMap<>();
    String type = "xy1";

    for (char c : str.toCharArray()) {
      if (Character.isLetter(c)) {
        switch (type) {
          case "xy1":
            result.put("x1", (String)defaultValue(result.get("x1"), "") + c);
            break;
          case "xy2":
            result.put("x2", (String)defaultValue(result.get("x2"), "") + c);
            break;
        }
      }
      if (Character.isDigit(c)) {
        switch (type) {
          case "xy1":
            result.put("y1", (String)defaultValue(result.get("y1"), "") + c);
            break;
          case "xy2":
            result.put("y2", (String)defaultValue(result.get("y2"), "") + c);
            break;
          case "o":
            result.put("o", (String)defaultValue(result.get("o"), "") + c) ;
            break;
        }
      }
      if (":".equals(c + "")) {
        type = "xy2";
      }
      if ("-".equals(c + "")) {
        type = "o";
      }
    }

    return result;
  }

  /**
   * グループ情報の取得
   */
  private void getGroupInfo() {
    this.isNull = false;

    int page = this.page != null ? this.page : 0;
    int start_y = this.start_y != null ? this.start_y : 0;
    int end_y = this.end_y != null ? this.end_y : 0;
    int offset = this.offset != null ? this.offset : 0;
    int initiate_y = this.initiate_y != null ? this.initiate_y : 0;
    int initiate_offset = this.initiate_offset != null ? this.initiate_offset : 0;

    this.groupName = getPropertiesAndRow();
    this.sort = page + start_y + end_y + offset + initiate_y + initiate_offset;
  }

  /**
   * 设置デフォルト値
   *
   * @param v  空でないコンテンツを検証する必要があります
   * @param dv 对应デフォルト値
   * @return 処理後の結果
   */
  private Object defaultValue(String v, String dv) {
    if (StringUtils.isBlank(v)) {
      return dv;
    }
    return v;
  }

  /**
   * 座標行IDの取得
   *
   * @return
   */
  private String getPropertiesAndRow() {
    //    (1#B2:C8-1).B2:C2-1

    StringBuilder sb = new StringBuilder();
    if (isNotBlank(this.page)) {
      sb.append(this.page + "#");
    }
    if (isNotBlank(this.start_x)) {
      sb.append(this.start_x);
    }
    if (isNotBlank(this.start_y)) {
      sb.append(this.start_y);
    }
    if (isNotBlank(this.end_x)) {
      sb.append(":" + this.end_x);
    }
    if (isNotBlank(this.end_y)) {
      sb.append(this.end_y);
    }
    if (isNotBlank(this.offset)) {
      sb.append("-" + this.offset);
    }

    return sb.toString();
  }
}
