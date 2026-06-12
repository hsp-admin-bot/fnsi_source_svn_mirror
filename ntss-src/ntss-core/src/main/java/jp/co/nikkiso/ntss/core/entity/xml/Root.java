package jp.co.nikkiso.ntss.core.entity.xml;

import java.io.StringReader;
import java.io.StringWriter;
import java.util.List;

import jakarta.xml.bind.JAXB;
import jakarta.xml.bind.annotation.XmlAttribute;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlElements;
import jakarta.xml.bind.annotation.XmlRootElement;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;

import lombok.NoArgsConstructor;

/**
 * 変換レイアウトのルートを表すクラス。（JAXBエンティティ）
 */
@Domain(valueType = String.class)
@NoArgsConstructor
@XmlRootElement(name = "root")
public class Root {

  /**
   * ModelMapper
   */
  private static ModelMapper modelMapper = new ModelMapper();

  /**
   * 変換レイアウトのid<br/>
   * （他のレイアウトから参照される場合のみ必須）
   */
  private String id;

  /** 変換レイアウトの名称（name属性） */
  private String name;

  /** 1電文に複数患者が含まれる場合の設定 */
  private String multi;

  /** 項目のリスト（item要素） */
  private List<Item> itemList;

  private boolean useSharedSysdate;

  private boolean updateSharedSysdate;

  /**
   * レイアウトIDを取得する。
   * 
   * @return レイアウトID
   */
  @XmlAttribute
  public String getId() {
    return id;
  }

  /**
   * レイアウトIDを設定する。
   * 
   * @param id レイアウトID
   */
  public void setId(String id) {
    this.id = id;
  }

  /**
   * 変換レイアウトの名称を取得する。
   *
   * @return 変換レイアウトの名称
   */
  @XmlAttribute
  public String getName() {
    return name;
  }

  /**
   * 変換レイアウトの名称を設定する。
   *
   * @param name 変換レイアウトの名称
   */
  public void setName(String name) {
    this.name = name;
  }

  /**
   * 複数患者指定の値を取得する。
   *
   * @return 複数患者指定
   */
  @XmlAttribute
  public String getMulti() {
    return multi;
  }

  /**
   * 複数患者指定を設定する。
   *
   * @param multi 複数患者指定
   */
  public void setMulti(String multi) {
    this.multi = multi;
  }

  /**
   * 共有システム日時を使用するかどうかを取得する。
   *
   * @return trueの場合、共有システム日時使用する
   */
  @XmlAttribute
  public boolean getUseSharedSysdate() {
    return useSharedSysdate;
  }

  /**
   * 共有システム日時を使用するかどうかを設定する。
   *
   * @param useSharedSysdate trueの場合、共有システム日時使用する
   */
  public void setUseSharedSysdate(boolean useSharedSysdate) {
    this.useSharedSysdate = useSharedSysdate;
  }

  /**
   * 共有システム日時を更新するかどうかを取得する。
   *
   * @return trueの場合、共有システム日時を更新する
   */
  @XmlAttribute
  public boolean getUpdateSharedSysdate() {
    return updateSharedSysdate;
  }

  /**
   * 共有システム日時を更新するかどうかを設定する。
   *
   * @param updateSharedSysdate trueの場合、共有システム日時を更新する
   */
  public void setUpdateSharedSysdate(boolean updateSharedSysdate) {
    this.updateSharedSysdate = updateSharedSysdate;
  }

  /**
   * 項目のリストを取得する。
   *
   * @return 項目のリスト
   */
  @XmlElements({
      @XmlElement(name = "item", type = Item.class),
      @XmlElement(name = "occ", type = Occ.class),
      @XmlElement(name = "file", type = File.class),
      @XmlElement(name = "record", type = Record.class)
  })
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
   * コンストラクタ。
   *
   * @param value XML形式文字列
   */
  public Root(String value) {
    StringReader sr = new StringReader(value);
    Root obj = JAXB.unmarshal(sr, Root.class);
    modelMapper.map(obj, this);
  }

  /**
   * Rootオブジェクト配下を文字列に変換する。
   *
   * @return XML形式文字列
   */
  public String getValue() {
    StringWriter sw = new StringWriter();
    JAXB.marshal(this, sw);
    return sw.toString();
  }

}
