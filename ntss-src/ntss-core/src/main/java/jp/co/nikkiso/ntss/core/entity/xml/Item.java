package jp.co.nikkiso.ntss.core.entity.xml;

import javax.xml.bind.annotation.XmlAttribute;

/**
 * 変換レイアウトの項目を表すクラス。（JAXBエンティティ）
 */
public class Item {

  /** 項目名 */
  private String name;

  /** 項目の長さ */
  private int len;

  // add redmain #5166 「データの長さによりエラーになってしまう」 鄧シン start
  /** 切り取り方式(”L“:左に切る、”R“:右に切る、”N“:切らない、null:左に切る)　*/
  private  String subMode;
  // add redmain #5166 「データの長さによりエラーになってしまう」 鄧シン end

  /** 出力項目キー */
  private String col;

  /** 照合キー */
  private String key;

  /** 終端要素フラグ */
  private boolean term;

  /** 型（string, numericのいずれか） */
  private String type;

  /** 特殊値指定（固定値、JSONルックアップ、datasetによる値変換） */
  private String value;

  /** 文字列結合フラグ */
  private boolean append;

  /** 繰り返し要素の別指定 */
  private String detail;

  /** 電文長フラグ */
  private boolean messageLen;

  /** パディング位置 */
  private String paddingPosition;

  /** パディングフォーマット */
  private String paddingFormat;

  /** データ長 */
  private String dataLength;

  /** データ長使用項目 */
  private String dataLengthUse;


  private String coopCdSub;
  private String itemType;
  private String repeat;
  private String dataSet;
  private String sqlParam;

  @XmlAttribute
  public String getCoopCdSub() {
    return coopCdSub;
  }

  @XmlAttribute
  public String getItemType() {
    return itemType;
  }

  @XmlAttribute
  public String getRepeat() {
    return repeat;
  }

  /**
   * @param repeat 繰り返す
   */
  public void setRepeat(String repeat) {
    this.repeat = repeat;
  }

  @XmlAttribute
  public String getDataSet() {
    return dataSet;
  }

  @XmlAttribute
  public String getSqlParam() {
    return sqlParam;
  }

  /**
   * 項目名を取得する。
   *
   * @return 項目名
   */
  @XmlAttribute
  public String getName() {
    return name;
  }

  /**
   * 項目名を設定する。
   *
   * @param name 項目名
   */
  public void setName(String name) {
    this.name = name;
  }

  /**
   * 項目の長さを取得する。
   *
   * @return 項目の長さ
   */
  @XmlAttribute
  public int getLen() {
    return len;
  }

  /**
   * 項目の長さを設定する。
   *
   * @param len 項目の長さ
   */
  public void setLen(int len) {
    this.len = len;
  }

  // add redmain #5166 「データの長さによりエラーになってしまう」 鄧シン start
  /**
   * 切り取り方式を取得する。
   *
   * @return 切り取り方式
   */
  @XmlAttribute
  public String getSubMode() {
    return subMode;
  }

  /**
   * 切り取り方式を設定する。
   *
   * @param subMode 切り取り方式
   */
  public void setSubMode(String subMode) {
    this.subMode = subMode;
  }
  // add redmain #5166 「データの長さによりエラーになってしまう」 鄧シン end

  /**
   * 出力項目キーを取得する。
   *
   * @return 出力項目キー
   */
  @XmlAttribute
  public String getCol() {
    return col;
  }

  /**
   * 出力項目キーを設定する。
   *
   * @param col 出力項目キー
   */
  public void setCol(String col) {
    this.col = col;
  }

  /**
   * 照合キーを取得する。
   *
   * @return 照合キー
   */
  @XmlAttribute
  public String getKey() {
    return key;
  }

  /**
   * 照合キーを設定する。
   *
   * @param key 照合キー
   */
  public void setKey(String key) {
    this.key = key;
  }

  /**
   * 終端要素フラグを取得する。
   *
   * @return 端要素フラグ
   */
  @XmlAttribute
  public boolean getTerm() {
    return term;
  }

  /**
   * 端要素フラグを設定する。
   *
   * @param term 端要素フラグ
   */
  public void setTerm(boolean term) {
    this.term = term;
  }

  /**
   * 型を取得する。
   *
   * @return 型
   */
  @XmlAttribute
  public String getType() {
    return type;
  }

  /**
   * 型を設定する。
   *
   * @param type 型
   */
  public void setType(String type) {
    this.type = type;
  }

  /**
   * 特殊値指定を取得する。
   *
   * @return 特殊値指定
   */
  @XmlAttribute
  public String getValue() {
    return value;
  }

  /**
   * 特殊値指定を設定する。
   *
   * @param value 特殊地指定
   */
  public void setValue(String value) {
    this.value = value;
  }

  /**
   * 文字列結合フラグを取得する。
   *
   * @return 文字列結合フラグ
   */
  @XmlAttribute(name = "append")
  public boolean getAppend() {
    return append;
  }

  /**
   * 文字列結合フラグを設定する。
   *
   * @param append 文字列結合フラグ
   */
  public void setAppend(boolean append) {
    this.append = append;
  }

  /**
   * 繰り返し要素の別指定を取得する。
   *
   * @return 繰り返し要素の別指定
   */
  @XmlAttribute
  public String getDetail() {
    return detail;
  }

  /**
   * 繰り返し要素の別指定を設定する。
   *
   * @param detail 繰り返し要素の別指定
   */
  public void setDetail(String detail) {
    this.detail = detail;
  }

  /**
   * 電文長フラグを取得する。
   *
   * @return 電文長フラグ
   */
  @XmlAttribute
  public boolean getMessageLen() {
    return messageLen;
  }

  /**
   * 電文長フラグを設定する。
   *
   * @param messageLen 電文長フラグ
   */
  public void setMessageLen(boolean messageLen) {
    this.messageLen = messageLen;
  }

  /**
   * item要素が繰り返し要素か否か判別する。
   * @return 繰り返し要素ならばtrue、それ以外はfalse
   */
  public boolean isOcc() {
    return false;
  }

  /**
   * パディング位置を取得します
   * @return パディング位置
   */
  @XmlAttribute(name="padding_position")
  public String getPaddingPosition() {
    return paddingPosition;
  }

  /**
   * パディング位置を設定します
   * @param paddingPosition
   */
  public void setPaddingPosition(String paddingPosition) {
    this.paddingPosition = paddingPosition;
  }

  /**
   * パディングフォーマットを取得します
   * @return パディングフォーマット
   */
  @XmlAttribute(name="padding_format")
  public String getPaddingFormat() {
    return paddingFormat;
  }

  /**
   * パディングフォーマットを設定します
   * @param paddingFormat
   */
  public void setPaddingFormat(String paddingFormat) {
    this.paddingFormat = paddingFormat;
  }

  /**
   * データ長を取得します
   * @return データ長
   */
  @XmlAttribute(name="data_length")
  public String getDataLength() {
    return dataLength;
  }

  /**
   * データ長を設定します
   * @param dataLength
   */
  public void setDataLength(String dataLength) {
    this.dataLength = dataLength;
  }

  /**
   * データ長使用項目を取得します
   * @return データ長使用項目
   */
  @XmlAttribute(name="data_length_use")
  public String getDataLengthUse() {
    return dataLengthUse;
  }

  /**
   * データ長使用項目を設定します
   * @param dataLengthUse
   */
  public void setDataLengthUse(String dataLengthUse) {
    this.dataLengthUse = dataLengthUse;
  }
}
