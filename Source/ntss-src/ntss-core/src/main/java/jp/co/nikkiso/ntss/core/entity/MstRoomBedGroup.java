package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstRoomBedGroupEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * mst_room_bed_group(ベッドグループ・透析室マスタ)のエンティティクラス
 */
@Entity(listener = MstRoomBedGroupEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_room_bed_group")
@Getter
@Setter
public class MstRoomBedGroup extends BaseBlankEntity {
  /**
   * 透析室・ベッドグループコード
   */
  private Integer roomBedGroupCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 透析室・ベッドグループ名
   */
  private String roomBedGroupName;

  /**
   * ベッド一覧
   */
  private String bedList;

  /**
   * FNW+で管理する施設内の一意な透析室・ベッドグループ番号
   */
  private String fnRoomBedGroupNo;

  /**
   * グループ区分
   */
  private Short groupClass;

  /**
   * 連携コード1
   */
  private String inHospitalCd_1;

  /**
   * 連携コード2
   */
  private String inHospitalCd_2;

  /**
   * 連携コード3
   */
  private String inHospitalCd_3;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
}
