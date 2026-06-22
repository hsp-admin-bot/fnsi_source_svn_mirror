package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.*;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;
import java.util.Objects;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)

@Table(name = "shr_pat_info")
@Getter
@Setter
public class ShrPatInfo {

  /**
   * 管理番号
   */
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "shr_pat_info_shr_pat_info_id_seq")
  private Long shrPatInfoId;

  /**
   * 共有元施設コード
   */
  private String fromFacilityCd;

  /**
   * 施設名.
   */
  @Transient
  private String facilityName;

  /**
   * 共有元患者ID
   */
  private Long fromPatId;

  /**
   * 共有先施設コード
   */
  private String toFacilityCd;

  /**
   * 共有先患者ID
   */
  private Long toPatId;

  /**
   * 依頼方向
   */
  private String shareDirection;

  /**
   * 共有元合意フラグ
   */
  private String isFromConsent;

  /**
   * 共有元担当者
   */
  private Long fromUserId;

  /**
   * 共有先合意フラグ
   */
  private String isToConsent;

  /**
   * 共有先担当者
   */
  private Long toUserId;

  /**
   * 患者合意フラグ
   */
  private String isPatConsent;

  /**
   * 狀態
   */
  @Transient
  private String sharedState;

  /**
   * 添付ファイル
   */
  private String shrAttachment;

  /**
   * 共有元最終更新日時
   */
  private Timestamp fromUpDate;
  private Timestamp regDate;

  /**
   * 共有先最終更新日時
   */
  private Timestamp toUpDate;

  /**
   * 共有元施設最終更新者
   */
  private Long fromUpdUserId;

  /**
   * 共有先施設最終更新者
   */
  private Long toUpdUserId;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 院内表示用の患者ID
   */
  @Transient
  private String hosp_pat_id;

  /**
   * 削除フラグを表示
   */
  @Transient
  private Boolean deletionFlag;

  /**
   * 利用者名
   */
  @Transient
  private String userName;

  public Long getShrPatInfoId() { return shrPatInfoId; }
  public void setShrPatInfoId(Long shrPatInfoId) { this.shrPatInfoId = shrPatInfoId; }


  /**
   * 施設コードに基づいてクエリに使用する患者IDを取得する（最簡潔版）
   * 前提：facilityCdは必ずfromFacilityCdまたはtoFacilityCdのいずれかと一致する
   */
  public Long getQueryPatientId(String facilityCd) {
    // fromFacilityCdと一致 → fromPatIdを優先
    if (facilityCd.equals(this.fromFacilityCd)) {
      return this.fromPatId != null ? this.fromPatId : this.toPatId;
    }

    // toFacilityCdと一致 → toPatIdを優先
    return this.toPatId != null ? this.toPatId : this.fromPatId;
  }


  public String getQueryfacilityCd(String facilityCd) {
    // fromFacilityCdと一致 → fromPatIdを優先
    if (facilityCd.equals(this.fromFacilityCd) && Objects.equals(this.shareDirection, "2") && this.fromPatId==null) {
      return this.toFacilityCd;
    }

    if (facilityCd.equals(this.fromFacilityCd)) {
      return this.fromPatId != null ? this.toFacilityCd : this.fromFacilityCd;
    }

    // toFacilityCdと一致 → toPatIdを優先
    return this.fromFacilityCd;
  }

  public Boolean getDisplayDeletionFlag(String facilityCd) {

    // fromFacilityCdと一致 → fromPatIdを優先
    if (facilityCd.equals(this.fromFacilityCd) && Objects.equals(this.shareDirection, "1") ) {
      return this.deletionFlag=true;
    }

    if (facilityCd.equals(this.toFacilityCd) && Objects.equals(this.shareDirection, "2") ) {
      return this.deletionFlag=true;
    }
    // toFacilityCdと一致 → toPatIdを優先
    return this.deletionFlag=false;
  }
}
