package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvComplaintTreatment;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvNextPatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainOrdNoAndRstStartDate;

/**
 * 通信サーバ用治療情報のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface ComsvOrdMainDao {

  /**
   * 治療情報を抽出
   *
   * @param ordNo オーダ番号
   * @return 通信サーバ用治療情報Entity
   */
  @Select
  ComsvOrdMain selectByNo(Long ordNo);

  /**
   * 治療情報を抽出（オーダ番号、患者ID）
   *
   * @param facilityCd 施設コード
   * @param rstMachineNo 実績：装置番号
   * @param startDate 実績：治療開始日時
   * @return 通信サーバ用治療情報Entity
   */
  @Select
  ComsvOrdMain selectUnregisteredPat(ComsvOrdMain param);

  /**
   * 次患者情報を抽出
   *
   * @param ordNo オーダ番号
   * @return 通信サーバ用次患者情報Entity
   */
  @Select
  ComsvNextPatInfo selectNextPatInfo(Long ordNo);


  /**
   * 指定オーダー番号より過去で直近/同一曜日のオーダー番号、治療開始日時を指定件数分取得する
   * @param ordNo オーダー番号
   * @param mode モード[0:直近/1：同一曜日]
   * @param limitCount 取得件数最大値
   * @return オーダー番号と治療開始日時のリスト
   */
  @Select
  List<OrdMainOrdNoAndRstStartDate> selectByOrdNoToPastOrdNo( Long ordNo, Integer mode, Long limitCount );

  /**
   * 治療情報（愁訴処置情報）件数を取得
   *
   * @param ordNo オーダ番号
   * @return 通信サーバ用治療情報Entity
   */
  @Select
  int selectTreatmentCount(Long ordNo);

  /**
   * 治療情報（愁訴処置者情報）件数を取得
   *
   * @param ordNo オーダ番号
   * @return 通信サーバ用治療情報Entity
   */
  @Select
  int selectTreatStaffCount(Long ordNo);

  /**
   * 治療情報（条件送信日時）を更新
   * @param ordNo オーダ番号
   * @param condDate 更新する条件送信日時
   * @return
   */
  @Update(sqlFile = true)
  int updateSendDate(ComsvOrdMain param);

  /**
   * 治療情報（治療開始日時）を更新
   * @param ordNo オーダ番号
   * @param startDate 更新する治療開始日時
   * @return
   */
  @Update(sqlFile = true)
  int updateStartDate(ComsvOrdMain param);

  /**
   * 治療情報（治療終了日時）を更新
   * @param ordNo オーダ番号
   * @param endDate 更新する治療終了日時
   * @return
   */
  @Update(sqlFile = true)
  int updateEndDate(ComsvOrdMain param);
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 zhaoyunbin start
  /**
   * 治療情報（酸素吸入）を更新（登録）
   * @param ordNo オーダ番号
   * @param ctl_no 管理番号
   * @param row_no 行番号
   * @param occurDate 発生日時
   * @param oxygenStart 酸素吸入開始日時
   * @param oxygenAmount 酸素吸入量
   * @return
   */
  @Update(sqlFile = true)
  //int updateOxygenAdd(Long ordNo, String occurDate, String oxygenStart, String oxygenAmount);
  //mod 複数組の酸素吸入データマッチング問題に対応 劉 start
  //int updateOxygenAdd(Long ordNo,  int ctl_no, int row_no, String occurDate, String oxygenStart, String oxygenAmount);
  int updateOxygenAdd(Long ordNo,  int ctl_no, int row_no, String occurDate, String oxygenStart, String oxygenAmount, String linkStartDate);
  //mod 複数組の酸素吸入データマッチング問題に対応 劉 end
  /**
   * 治療情報（酸素吸入処置者）を更新（登録）
   * @param ordNo オーダ番号
   * @param ctl_no 管理番号
   * @param row_no 行番号
   * @param occurDate 発生日時
   * @param staffCd 処置者コード
   * @param staffName 処置者名
   * @return
   */
  @Update(sqlFile = true)
  //int updateTreatStaffAdd(Long ordNo, String occurDate, String staffCd, String staffName);
  int updateTreatStaffAdd(Long ordNo, int ctl_no, int row_no, String occurDate, String staffCd, String staffName);
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 zhaoyunbin end

  @Update(sqlFile = true)
  int updateComplaintTreatStaffAdd(Long ordNo, int ctl_no, String occurDate, String staffCd, String staffName);
  /**
   * 治療情報（穿刺者情報）を更新
   * @param inpNo 入力番号（1,2）
   * @param ordNo オーダ番号
   * @param userId 更新する穿刺者コード
   * @param date 更新する穿刺日時
   * @param userDate 更新する穿刺登録日時
   * @param lastName 更新する穿刺者（姓）
   * @param firstName 更新する穿刺者（名）
   * @return
   */
  @Update(sqlFile = true)
  int updatePunctureUser(int inpNo, Long ordNo, Long userId, String date, String userDate, String lastName, String firstName);

  /**
   * 治療情報（返血者情報）を更新
   * @param inpNo 入力番号（1,2）
   * @param ordNo オーダ番号
   * @param userId 更新する返血者コード
   * @param date 更新する返血日時
   * @param userDate 更新する返血登録日時
   * @param lastName 更新する返血者（姓）
   * @param firstName 更新する返血者（名）
   * @return
   */
  @Update(sqlFile = true)
  int updateReturnUser(int inpNo, Long ordNo, Long userId, String date, String userDate, String lastName, String firstName);

  /**
   * 治療情報（担当者情報）を更新
   * @param inpNo 入力番号（1,2）
   * @param ordNo オーダ番号
   * @param userId 更新する担当者コード
   * @param userDate 更新する担当登録日時
   * @param lastName 更新する担当者（姓）
   * @param firstName 更新する担当者（名）
   * @return
   */
  @Update(sqlFile = true)
  int updateChargeUser(int inpNo, Long ordNo, Long userId, String userDate, String lastName, String firstName);

  /**
   * 治療情報（実績モニタ値）を更新
   * @param ordNo オーダ番号
   * @param rstBloodCirculate 血液循環量
   * @param rstRunningTime 透析運転時間
   * @param rstKtv Kt/V
   * @param addTotal 除水積算値
   * @param addWaterTotal 補液量現在値
   * @param KtvMeasure Kt/V（測定値）
   * @param ufr ＵＲＲ
   * @return
   */
  @Update(sqlFile = true)
  int updateRstMonitor(ComsvOrdMain param);

  /**
   * 治療情報（目標除水量）を更新
   * @param ordNo オーダ番号
   * @param waterRemovealTarget 目標除水量
   * @return
   */
  @Update(sqlFile = true)
  int updateRstWeight(Long ordNo, String waterRemovalTarget);

  /**
   * 治療情報（実績プログラム補液引き残し量）を更新
   * @param ordNo オーダ番号
   * @param pullLeaveAmount プログラム補液引き残し量
   * @return
   */
  @Update(sqlFile = true)
  int updatePullLeaveAmount(ComsvOrdMain param);
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 zhaoyunbin start
  /**
   * 治療情報（愁訴）を登録
   * @param ordNo オーダ番号
   * @param ctl_no 管理番号
   * @param row_no 行番号
   * @param occurDate 発生日時
   * @param param 愁訴マスタ
   * @return
   */
  @Update(sqlFile = true)
  //int updateComplaintAdd(Long ordNo, String occurDate, MstComplaint param);
  int updateComplaintAdd(Long ordNo, int ctl_no, int row_no, String occurDate, MstComplaint param);

  /**
   * 治療情報（処置）を登録
   * @param ordNo オーダ番号
   * @param ctl_no 管理番号
   * @param row_no 行番号
   * @param occurDate 発生日時
   * @param procedureName 手技名称
   * @param param 処置マスタ
   * @param param2 薬剤マスタ
   * @param param3 調整薬剤マスタ
   * @return
   */
  @Update(sqlFile = true)
  //int updateTreatmentAdd(Long ordNo, String occurDate, MstCompTreatment param, MstMedicine param2, MstMedicineMix param3);
  // mod #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou start
  // int updateTreatmentAdd(Long ordNo, int ctl_no, int row_no, String occurDate, MstCompTreatment param, MstMedicine param2, MstMedicineMix param3);
  int updateTreatmentAdd(Long ordNo, int ctl_no, int row_no, String occurDate, String procedureName, MstCompTreatment param, MstMedicine param2, MstMedicineMix param3);
  // mod #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou end
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 zhaoyunbin end
  /**
   * 通信サーバ用治療情報の登録（患者未登録運転開始）
   * @param ord_no
   * @param machine_no
   * @param dial_state
   * @param start_date
   * @return
   */
  @Insert(sqlFile = true)
  int insertUnregisteredPat(ComsvOrdMain param);

  /**
   * 実績投与薬剤の更新
   * @param ordNo オーダー番号
   * @param mediInfo 投薬情報のJSON文字列
   * @return 実行件数
   */
  @Update(sqlFile = true)
  int updateMediInfo(Long ordNo, String mediInfo);
//add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 zhaoyunbin start
  /**
   *
   *通信サーバ用治療情報の愁訴処置情報
   * @param ordNo オーダ番号
   * @return String
   */
  @Select
  ComsvComplaintTreatment selectRecentRstTreatmentInfo(Long ordNo);
//add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 zhaoyunbin end
  // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 治療情報を抽出（オーダ番号、患者ID）(AWSとDEの通信断からの復旧)
   *
   * @param facilityCd 施設コード
   * @param rstMachineNo 実績：装置番号
   * @param pat_id 実績：患者ID
   * @return 通信サーバ用治療情報Entity
   */
  @Select
  ComsvOrdMain selectCommFailPat(ComsvOrdMain param);
  // add AWSとDEの通信断からの復旧 --趙-- end
  // add #IES_6789 dou start
  /**
   * 治療情報（実績：治療条件情報）を更新
   * @param ordNo オーダ番号
   * @param rstCondInfo 実績：治療条件情報
   * @return
   */
  @Update(sqlFile = true)
  int updateRstCondInfo(Long ordNo, String rstCondInfo);
  // add #IES_6789 dou end

  @Update(sqlFile = true)
  int updateOxygenDel(Long ordNo,  int ctl_no, int row_no, String occurDate, String oxygenStart, String oxygenAmount, String linkStartDate);

  @Update(sqlFile = true)
  int updateComplaintDel(Long ordNo, int ctl_no, int row_no, String occurDate, MstComplaint param);

  @Update(sqlFile = true)
  int updateTreatStaffDel(Long ordNo, int ctl_no);
}
