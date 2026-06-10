package jp.co.nikkiso.ntss.core.entity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 定期点検項目カテゴリEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_category")
@Getter
@Setter
public class MstMenteCategory extends BaseEntity {
  private static final String DETAIL_LIST_KEY = "detail_list";
  private static final String TYPE_INFO_KEY = "type_info";

  /**
   * 点検カテゴリコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "mainte_category_cd")
  private Long menteCategoryCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * カテゴリー名
   */
  private String categoryName;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 詳細
   */
  private String detail;
  /**
   * 用途
   */
  private String mainteClass;

  /**
   * 詳細に含まれる点検項目リスト部分を設定する
   */
  public void setDetailList(String value) {
    if (hasTypeList()) {
      // 詳細が装置型式リストを持つ形式になっている場合
      JSONObject detailObject = new JSONObject(this.detail);
      detailObject.put(DETAIL_LIST_KEY, new JSONArray(value));
      this.detail = detailObject.toString();
    } else {
      this.detail = value;
    }
  }
  /**
   * 詳細に含まれる点検項目リスト部分を返す
   */
  public String getDetailList() {
    if (hasTypeList()) {
      // 詳細が装置型式リストを持つ形式になっている場合
      JSONObject detailObject = new JSONObject(this.detail);
      JSONArray detailList = detailObject.getJSONArray(DETAIL_LIST_KEY);
      return detailList.toString();
    } else {
      return this.detail;
    }
  }
  /**
   * 詳細に含まれる装置型式リスト部分を設定する
   */
  public void setTypeList(String value) {
    if (hasTypeList()) {
      // 詳細が装置型式リストを持つ形式になっている場合
      JSONObject detailObject = new JSONObject(this.detail);
      detailObject.put(TYPE_INFO_KEY, new JSONArray(value));
      this.detail = detailObject.toString();
    }
    // #9451対応時のメモ：
    // 詳細が装置型式リストを持つ形式になっていない場合に
    // ここで詳細の形式変更を行うことはしない
    // 現時点ではフロント側のマスタメンテでレコードが追加・更新される際にのみ
    // 詳細が装置型式リストを持つ形式に変わりうる想定としている
  }
  /**
   * 詳細に含まれる装置型式リスト部分を返す
   */
  public String getTypeList() {
    if (hasTypeList()) {
      // 詳細が装置型式リストを持つ形式になっている場合
      JSONObject detailObject = new JSONObject(this.detail);
      JSONArray typeList = detailObject.getJSONArray(TYPE_INFO_KEY);
      return typeList.toString();
    } else {
      JSONArray typeList = new JSONArray();
      return typeList.toString();
    }
  }

  /**
   * 詳細が装置型式リストを持つ形式になっているかを返す
   */
  private Boolean hasTypeList() {
    try {
      JSONObject detailObject = new JSONObject(this.detail);
      JSONArray typeList = detailObject.getJSONArray(TYPE_INFO_KEY);
      return typeList != null;
    } catch (JSONException e) {
      return false;
    }
  }
}
