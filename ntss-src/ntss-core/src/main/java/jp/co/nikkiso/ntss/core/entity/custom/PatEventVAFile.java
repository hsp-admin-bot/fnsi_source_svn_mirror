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
 * 患者イベントのVA画像取得用カスタムエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatEventVAFile extends BaseEntity{

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
   * イベント日時
   */
  //mod FNSI-バグ 通信サーバ 劉 start
  //Timestamp eventDate;
  Timestamp eventStartDate;
  //mod FNSI-バグ 通信サーバ 劉 end
  /**
   * 項目種別
   */
  Integer formatClass;
  /**
   * 画像情報配列
   */
  String resultValue;
  /**
   * 項目配列順位
   */
  Integer idx;
  /**
   * 画像配列順位
   */
  Integer idx2;
  /**
   * 画像(VA)名
   */
  String name;
  /**
   * VA転送対象フラグ
   */
  String isSendVa;
  /**
   * S3上での画像ファイルパス
   */
  String filePath;
}
