package jp.co.nikkiso.ntss.core.entity.xml;

import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;

/**
 * 変換レイアウトの繰り返し項目を表すクラス。（JAXBエンティティ）
 */
public class Occ extends Item {

  /** 項目のリスト */
  private List<Item> itemList;

  /** 繰り返し回数の固定指定 */
  private String repeat;

  /** sys_data_set.sql_code */
  private String sqlCode;

  /** 長さがrepeatを超える場合の設定 */
  private String multi;

  /**
   * occ要素の下の項目のリストを取得する。
   *
   * @return 項目のリスト
   */
  @XmlElement(name = "item")
  public List<Item> getItemList() {
    return itemList;
  }

  /**
   * 項目のリストを設定する。
   *
   * @param itemList 項目のリスト
   */
  public void setItemList(List<Item> itemList) {
    this.itemList = itemList;
  }

  /**
   * 繰り返し回数（固定指定）を取得する。
   *
   * @return 繰り返し回数（固定指定）
   */
  @XmlAttribute
  public String getRepeat() {
    return repeat;
  }

  /**
   * 繰り返し回数（固定指定）を設定する。
   *
   * @param repeat 繰り返し回数（固定指定）
   */
  public void setRepeat(String repeat) {
    this.repeat = repeat;
  }

  /**
   * item要素が繰り返し要素か否か判別する。
   * @return 繰り返し要素ならばtrue
   */
  @Override
  public boolean isOcc() {
    return true;
  }

  /**
   * sql_codeを取得する
   * @return sql_code
   */
  @XmlAttribute(name="sqlCode")
  public String getSqlCode() {
    return sqlCode;
  }

  /**
   * sql_codeを設定する
   * @param sqlCode
   */
  public void setSqlCode(String sqlCode) {
    this.sqlCode = sqlCode;
  }

  @XmlAttribute(name="multi")
  public String getMulti() {
    return multi;
  }

  public void setMulti(String multi) {
    this.multi = multi;
  }
}
