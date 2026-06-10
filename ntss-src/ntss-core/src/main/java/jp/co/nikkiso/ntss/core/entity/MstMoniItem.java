package jp.co.nikkiso.ntss.core.entity;


import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * モニタアイテムマスタ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_moni_item")
@Getter
@Setter
public class MstMoniItem extends BaseBlankEntity {
  /**
   * 施設コード
   */
  String facilityCd;
  /**
   * 機種
   */
  String model;
  /**
   * モニタ項目番号
   */
  int moniNo;
  /**
   * FNW+で管理する施設内の一意なモニタ種別
   */
  int fnMoniType;
  /**
   * FNW+で管理する施設内の一意なモニタ項目番号
   */
  int fnMoniNo;
  /**
   * モニタデータ項目名
   */
  String monDataName;
  /**
   * モニタデータ短縮名
   */
  String monDataShortName;
  /**
   * データ種別
   */
  int dataType;
  /**
   * アイテム定義 カラム名
   */
  String itemColumnName;
  /**
   * 小数部桁数
   */
  int decimalFigure;
  /**
   * 単位
   */
  String unit;
  /**
   * 最大値
   */
  int upper;
  /**
   * 最小値
   */
  int lower;
  /**
   * 対応機種
   */
  int supportModel;
  /**
   * 積算
   */
  int addUp;
  /**
   * 表示順
   */
  int dispOrder;
  /**
   * 表示有無
   */
  String isDisp;
  /**
   * 必須フラグ
   */
  String isIndispensable;
  /**
   * 帳票表示順
   */
  int reportDispOrder;
  /**
   * タグ種別
   */
  int tagType;
  /**
   * 目標値-上限-下限設定可否フラグ
   */
  String isTargetUpperLowerSet;
  /**
   * データＩＤ
   */
  int dataId;
  /**
   * データサイズ
   */
  int dataSize;
  /**
   * 取得データ型
   */
  int dataKind;
  /**
   * 登録日時
   */
  Timestamp regDate;
  /**
   * 更新日時
   */
  Timestamp upDate;
}
