package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * 患者イベントのカスタムエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatEventData extends BaseEntity{

  /**
   * システムで管理する一意な患者イベントコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  Long patEventCd;
  /**
   * システムで管理する一意な患者ID
   */
  Long patId;
  /**
   * 施設コード
   */
  String facilityCd;
  /**
   * FNW+で管理する施設内の一意なシーケンスID
   */
  Long fnCtlNo;
  /**
   * 状況区分
   */
  String eventStatus;

  /**
   * テンプレートコード
   */
  Long templateCd;
  /**
   * テンプレート名称
   */
  String templateName;
  /**
   * カテゴリコード
   */
  Long categoryCd;
  /**
   * カテゴリ名称
   */
  String categoryName;
  /**
   * VA画像フラグ
   */
  String isVa;
  /**
   * 観察記録対象フラグ
   */
  String isObserve;
  /**
   * システムで管理する一意なオーダ番号
   */
  Long ordNo;
  /**
   * 項目情報
   */
  String inputParams;
  /**
   * イベント日時
   */
  Timestamp eventDate;
  /**
   * イベント日時(集計用文字列).
   */
  String strEventDate;
  /**
   * サブカテゴリコード
   */
  Long sub_categoryCd;
  /**
   * サブカテゴリ名称
   */
  String subCategoryName;
  /**
   * 項目実績
   */
  String resultParams;
  /**
   * スコア合計
   */
  Integer scoreTotal;
  /**
   * 起票者情報
   */
  String regStaffInfo;
  /**
   * 編集者情報
   */
  String upStaffInfo;
  /**
   * 掲示板管理番号
   */
  Long bbsCtlNo;
  /**
  * 最新フラグ
  */
  String isNewest;
  /**
   * 削除フラグ
   */
  String isDel;
}
