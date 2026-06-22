package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * 装置マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_machine")
@Getter
@Setter
public class MstMachine extends BaseEntity {

  /**
   * 型式コード.
   */
  @Id
  private String machineTypeCd;

  /**
   * 製造番号.
   */
  @Id
  private String machineSerial;
  //スペースを削除する 6901 関 start
  public String getMachineSerial() {
    if (machineSerial != null) {
      return machineSerial.trim();
    }
    return machineSerial;
  }

  public void setMachineSerial(String machineSerial) {
    if (machineSerial != null) {
      this.machineSerial = machineSerial.trim();
    }
  }
  //スペースを削除する 6901 end
  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;

  /**
   * 装置名.
   */
  private String machineName;

  /**
   * 装置番号
   */
  private Long machineNo;

  /**
   * IPアドレス.
   */
  private String ipAddress;

  /**
   * ポート番号.
   */
  private String port;

  /**
   * 通信フォーマット.
   */
  private String comFormatCd;

  /**
   * 通信種別.
   */
  private Integer comType;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

  /**
   * データ収集可否
   */
  private String isFtp;

  /**
   * 画像転送可否
   */
  private String isVa;

  /**
   * 設置日
   */
  private Timestamp settingDate;

  /**
   * 廃棄日
   */
  private Timestamp deleteDate;

  /**
   * バージョン
   */
  private String version;

  /**
   * 装置オプション(JSON文字列).
   */
  private String machineOption;

  /**
   * メモ
   */
  private String memo;

  /**
   * 使用不可フラグ
   */
  private String isDisable;

  /**
   * 対応可否フラグ(HD)
   */
  private String isSupportHd;

  /**
   * 対応可否フラグ(ECUM)
   */
  private String isSupportEcum;

  /**
   * 対応可否フラグ(HDF)
   */
  private String isSupportHdf;

  /**
   * 対応可否フラグ(HF)
   */
  private String isSupportHf;

  /**
   * 対応可否フラグ(HD+補液)
   */
  private String isSupportHdHo;

  /**
   * 対応可否フラグ(ECUM+補液)
   */
  private String isSupportEcumHo;

  /**
   * 対応可否フラグ(AFBF)
   */
  private String isSupportAfbf;

  /**
   * 対応可否フラグ(OHDF)
   */
  private String isSupportOhdf;

  /**
   * 対応可否フラグ(OHF)
   */
  private String isSupportOhf;

  /**
   * 対応可否フラグ(I-HDF)
   */
  @Column(name = "is_support_i_hdf")
  private String isSupportIHdf;

  /**
   * 対応可否フラグ（特殊浄化）
   */
  private String isSupportBloodPurify;

  /**
   * TMP初期補正中点(HD)
   */
  private Integer tmpCenterHd;

  /**
   * TMP初期補正中点(ECUM)
   */
  private Integer tmpCenterEcum;

  /**
   * TMP初期補正中点(HDF)
   */
  private Integer tmpCenterHdf;

  /**
   * TMP初期補正中点(HF)
   */
  private Integer tmpCenterHf;

  /**
   * TMP初期補正中点(HD+補液)
   */
  private Integer tmpCenterHdHo;

  /**
   * TMP初期補正中点(OCHF)
   */
  private Integer tmpCenterOhdf;

  /**
   * TMP初期補正中点(OHF)
   */
  private Integer tmpCenterOhf;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;

  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
  /**
   * 特殊浄化装置種別
   */
  private String blood_purify_type;
  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * 特殊浄化通信アプリ使用選択
   */
  private String isBloodPurifyUse;
  /**
   * FNW+で管理する施設内の一意な装置番号
   */
  private String fnDeviceNo;
  /**
   * FNW用装置区分 ０：透析装置 １：機械室装置
   */
  private String fnClassCd;
  //add #10412 次患者更新関連全体見直し対応 朴 end
  /**
   * 連携コード1
   */
  @Column(name = "in_hospital_cd_1")
  private String inHospitalCd1;
  /**
   * 連携コード2
   */
  @Column(name = "in_hospital_cd_2")
  private String inHospitalCd2;
  /**
   * 装置マスタ並び順
   */
  @Transient
  private Long machineIndex;
}


