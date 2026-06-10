package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineFormat;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvIntervalNotificationInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineStateForMinimumTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.Machine;
import jp.co.nikkiso.ntss.core.entity.custom.MachineTreatingState;
import jp.co.nikkiso.ntss.core.entity.custom.NoticeCounts;
import jp.co.nikkiso.ntss.core.entity.custom.PartsRunning;

/**
 * 装置状態管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntMachineStateDao {

  @Select
  List<MntMachineState> selectAll();

  @Select
  List<MntMachineState> selectByBedCd(Long bedCd);
  //add   7686 sql最適化    ljg start
  @Select
  List<MntMachineState> selectByBedCdcopy(Long bedCd);
  //add   7686 sql最適化    ljg end
  @Select
  List<ComsvMntMachineState> selectByFacilityCd(String facilityCd);

  @Select
  MntMachineState selectByMachineSerial(String machineSerial);

  @Select
  MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial);

  @Select
  ComsvMntMachineState selectMachineKey(String facilityCd, String machineTypeCd, String machineSerial);

  @Insert
  int insert(MntMachineState mntMachineState);

  @Delete
  int delete(MntMachineState mntMachineState);

  @Update
  int update(MntMachineState mntMachineState);

  /**
   * 装置一覧で使用する抽出処理.
   *
   * @param facilityCd 施設コード
   * @return 装置一覧用Entityのリスト
   */
  @Select
  List<Machine> selectMachinesByFacilityCd(String facilityCd);

  /**
   * 装置一覧で使用する抽出処理(顧客施設用).
   *
   * @param facilityCd 施設コード
   * @return 装置一覧用Entityのリスト
   */
  @Select
  List<Machine> selectMachinesForFacilitysByFacilityCd(String facilityCd);

  /**
   * 施設ごとの各項目通知件数を抽出.
   *
   * @param facilityCd 施設コード
   * @return 通知件数取得用Entity
   */
  @Select
  NoticeCounts selectNoticeCounts(String facilityCd);

  /**
   * 部品運転時間を抽出.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 部品運転時間
   */
  @Select
  PartsRunning selectUseTimeByKey(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * デバイスエッジからの受信データをもとに情報を更新する(使用時間)
   * @param param 更新するレコード
   * @return
   */
  @Update(sqlFile = true)
  int updateUseTime(MntMachineState param);

  /**
   * デバイスエッジからの受信データをもとに情報を更新する(装置状態)
   * @param param 更新するレコード
   * @return
   */
  @Update(sqlFile = true)
  int updateMachineState(MntMachineState param);

  // #9111 2023.07.14 add 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 start
  /**
   * デバイスエッジからの受信データをもとに情報を更新する(複数の装置状態、1台にも対応)
   * @param param 更新するレコード群
   * @return
   */
  @Update(sqlFile = true)
  int updateMachineStateMultiple(List<MntMachineState> paramList);
  // #9111 2023.07.14 add 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 end

  // #9243 2023.07.31 add 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 start
  /**
   * デバイスエッジからの受信データをもとに情報を更新する(複数の工程状態と通信不良有無、1台にも対応)
   * @param param 更新するレコード群
   * @return
   */
  @Update(sqlFile = true)
  int updateProcessStateAndIsPreventiveMainteMultiple(List<MntMachineState> paramList);
  // #9243 2023.07.31 add 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 end

  /**
   * 装置の条件送信日時を更新する
   * @param param 更新するデータ
   * @return
   */
  @Update(sqlFile = true)
  int updateCondSend(MntMachineState param);

  /**
   * 装置の条件確認日時を更新する
   * @param param 更新するデータ
   * @return
   */
  @Update(sqlFile = true)
  int updateCondSet(MntMachineState param);

  /**
   * 装置の透析開始日時を更新する
   * @param param 更新するデータ
   * @return
   */
  @Update(sqlFile = true)
  int updateDialStart(MntMachineState param);

  /**
   * 装置の透析終了日時を更新する
   * @param param 更新するデータ
   * @return
   */
  @Update(sqlFile = true)
  int updateDialEnd(MntMachineState param);

  /**
   * 装置の透析開始日時（患者未登録運転開始）を更新する
   * @param param 更新するデータ
   * @return
   */
  @Update(sqlFile = true)
  int updateUnregisteredPat(MntMachineState param);

  /**
   * 装置の警報リストを更新
   * @param param 更新するレコード
   * @return
   */
  @Update(sqlFile = true)
  int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList);

  /**
   * 定期的に血圧未測定間隔やケア未実施間隔の通知に必要な情報
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  @Select
  List<ComsvIntervalNotificationInfo> selectIntervalNotificationInfo(String facilityCd, Integer deviceEdgeNo);

  /**
   * 現患者クリアAPI
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Update(sqlFile = true)
  int updateCurrentPatClear(String facilityCd, String machineTypeCd, String machineSerial, Timestamp upDate);

  /**
   * 装置設定一時データクリアAPI
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Update(sqlFile = true)
  int updateDeviceSetInfoClear(String facilityCd, String machineTypeCd, String machineSerial, Timestamp upDate);

  /**
   * 次患者更新API
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Update(sqlFile = true)
  int updateNextPatInfo(String facilityCd, String machineTypeCd, String machineSerial, Long nextPatid, Long nextOrdNo, Long nextKurCd, Timestamp startPlanDate, Timestamp upDate);

  @Update(sqlFile = true)
  int updateNextPatDate(String facilityCd, String machineTypeCd, String machineSerial, Long nextPatid, Long nextOrdNo, Long nextKurCd, Timestamp startPlanDate, Timestamp endPlanDate, Timestamp upDate, String tmpDeviceSetInfo, boolean isTmpDeviceSetInfo);


  /**
   * 患者確認済み(治療状況リストエントリー済み)チェック.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 対象の装置情報
   */
  @Select
  List<MntMachineState> selectByEntryCheckInfo(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 装置治療状況チェック.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param processState 工程状態
   * @return 対象の装置情報
   */
  @Select
  List<MntMachineState> selectByProcessState(String facilityCd, String machineTypeCd, String machineSerial, String processState);

  /**
   * 装置情報取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 装置情報
   */
  @Select
  Machine selectMachineByCondition(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 治療状況リスト：装置情報取得.
   *
   * @param facilityCd 施設コード
   * @return 装置情報
   */
  @Select
  List<MntMachineState> selectAllByFacilityCd(String facilityCd);

  /**
   * ベッドマスタのBedCdから紐づいている装置の状態を取得（mnt_machine_state.bed_cdを使用しない場合）.
   *
   * @param bedCd ベッドコード
   * @return 装置情報
   */
  @Select
  MachineTreatingState selectByMstBedCd(Long bedCd);

  /**
   * 後体重測定日時を更新
   * @param param 更新するレコード
   * @return
   */
  @Update(sqlFile = true)
  int updateWeighAfterDate(String facilityCd, String machineTypeCd, String machineSerial, Timestamp weightAfterDate);

  /**
   * 前体重測定日時を更新
   * @param param 更新するレコード
   * @return
   */
  @Update(sqlFile = true)
  int updateWeighBeforeDate(String facilityCd, String machineTypeCd, String machineSerial, Timestamp weightAfterDate);

  /**
   * 患者IDを更新
   * @param patId 患者ID
   * @param ordNo ordNo
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
  int updatePatId(Long patId, Long ordNo, String facilityCd, String machineTypeCd, String machineSerial, Timestamp upDate);

  /**
   * ordNoと患者IDを更新
   * @param param 更新するレコード
   * @return
   */
  @Update(sqlFile = true)
  int updateOrdNoPatId(Long patId, Long baseordNo, Long ordNo, Timestamp upDate, String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 施設内装置状態を装置種別情報とともに取得.
   *
   * @param facilityCd 施設コード
   * @return 装置一覧用Entityのリスト
   */
  @Select
  List<MntMachineState> selectMachinesWithModelByFacilityCd(String facilityCd);

  // add FNSI-改修内容5702修正 xuty start
  /**
   * 施設内装置状態を装置種別情報とともに取得.
   *
   * @param facilityCd 施設コード
   * @return 装置一覧用Entityのリスト
   */
  @Select
  List<MntMachineFormat> selectMachinesWithFormatByFacilityCd(String facilityCd);
  // add FNSI-改修内容5702修正 xuty end

  /* add by chamaojia 2024-03-28 [10303、10304] add query interface --start */
  @Select
  List<MntMachineFormat> selectMachinesToTreatmentStatus(String facilityCd, List<Long> bedCdList);
  /* add by chamaojia 2024-03-28 [10303、10304] add query interface --end */

  /**
   * オーダー番号で紐づく装置情報取得.
   * @param facilityCd 施設コード
   * @param ordNo オーダー番号
   */
  @Select
  List<MntMachineState> selectByOrdNo(String facilityCd, Long ordNo);

  /**
   * デバイスエッジ番号で紐づく装置情報取得.
   *
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return 装置情報
   */
  @Select
  List<MntMachineState> selectAllByDeviceEdgeNo(String facilityCd, Integer deviceEdgeNo);

  /**
   * 指定条件で次患者の治療予定日付から最小の日付を取得する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param startDate 検索開始日付
   * @param endDate 検索終了日付
   * @return
   */
  @Select
  ComsvMntMachineStateForMinimumTreatDate selectMinimumTreatDate(String facilityCd, Integer deviceEdgeNo, String startDate, String endDate );

  @Update(sqlFile = true)
  int updateClearOrdNo(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo, Timestamp upDate);

  @Select
  List<MntMachineState> selectByNextPatId(String facilityCd, Long nextPatId);

  /* add by chamaojia 2023-04-14 [5482 No.16、17、18] 患者ID別集合照会方法の追加 --start */
  @Select
  List<MntMachineState> selectByNextPatIdList(String facilityCd, List<Long> nextPatIdList);
  /* add by chamaojia 2023-04-14 [5482 No.16、17、18] 患者ID別集合照会方法の追加 --end */

  /**
   * 次回透析オーダ番号のリストを取得する
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param nextOrdNoList 次回透析オーダ番号のリスト
   * @return
   */
  @Select
  List<MntMachineState> selectByNextOrdNoList(Long patId, String facilityCd, List<Long> nextOrdNoList);
  //mod 7188 治療条件，装置設定を変更すると次患者が再送される start zhao
  @Select
  List<MntMachineState> selectByNextOrdNoAndNextPatId(Long patId, String facilityCd, List<Long> nextOrdNoList);
  //mod 7188 治療条件，装置設定を変更すると次患者が再送される end   zhao

  @Select
  List<MntMachineState> selectNextOrdNoByFacilityCd(String facilityCd);

  /**
   * 特定の装置番号の装置の状態を指定の値にする
   * @param facilityCd 施設コード
   * @param codeList 装置番号
   * @param mntParams 更新する工程状態・警報状態を格納したEntity
   * @return
   */
  @Update(sqlFile = true)
  int updateProcessStateByMachinesNoList(String facilityCd, List<Long> codeList, MntMachineState mntParams);

  /**
   * 特定の装置番号の装置のステータスを指定の値にする
   * @param facilityCd 施設コード
   * @param codeList 装置番号
   * @param mntParams 更新する工程状態・警報状態を格納したEntity
   * @return
   */
  @Update(sqlFile = true)
  int updateMachineStateByMachinesNoList(String facilityCd, List<Long> codeList, MntMachineState mntParams);

  // add #6822「DABの表示が不正」について、対応する。 dengshen start
  /**
   * 特定の装置番号の装置のステータスを指定の値にする
   * @param facilityCd 施設コード
   * @param codeList 装置番号
   * @param mntParams 更新する工程状態・警報状態を格納したEntity
   * @return
   */
  @Update(sqlFile = true)
  int updateMachineStateAndProcessStateByMachinesNoList(String facilityCd, List<Long> codeList, MntMachineState mntParams);
  // add #6822「DABの表示が不正」について、対応する。 dengshen end

  /**
   * 死活監視用 装置状態更新
   * @param machineState 装置状態
   * @return
   */
  @Update(sqlFile = true)
  int updateAliveMoni(MntMachineState machineState);

  /**
   * 死活監視用 装置状態更新
   * @param machineState 装置状態
   * @param deviceEdgeNo デバイスエッジ番号
   * @param isExcludeOffline true:オフライン装置を除外 false: オフライン装置も含めて更新
   * @return
   */
  @Update(sqlFile = true)
  int updateProcessStateByEdge(MntMachineState machineState, Integer deviceEdgeNo, Boolean isExcludeOffline);

  // add 治療記録用データと治療状況用データの登録先を振分けにする zhaoyunbin start
  /**
   * 治療記録用データと治療状況用データの登録先を振分けにする
   * @param machineState 装置状態
   * @return
   */
  @Update(sqlFile = true)
  int updateTreatmentStatus(MntMachineState machineState);
  // add 治療記録用データと治療状況用データの登録先を振分けにする zhaoyunbin end

  // add FNSI-画面リロードの修正 徐 start
  /**
   * 検索ordNo
   * @param param 装置状態
   * @return
   */
  @Select
  MntMachineState selectMachineState(MntMachineState param);

  @Select
  List<MntMachineState> selectMonitorByFacilityCdAndPatIdAndOrdNo(List<MniMonitor> bodyDataList);
  // add FNSI-画面リロードの修正 徐 end
  // add FNSI-？？？？患者割り当て 陳 start

  @Update(sqlFile = true)
  int updateOrdNoPatIdByOrdNo(Long patId, Long baseordNo, Long ordNo, Timestamp upDate);
  // add FNSI-？？？？患者割り当て 陳 end

  // add FNSI修正 486修正 房 start
  @Update(sqlFile = true)
  int updatePatInfo(String facilityCd, String machineTypeCd, String machineSerial, Timestamp upDate, Long patId, Long ordNo, boolean nextFlag);
  // add FNSI修正 486修正 房 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * (AWSとDEの通信断からの復旧)装置状態更新
   * @param param 装置状態
   * @return
   */
  @Update(sqlFile = true)
  int updateMachineStateCommFail(MntMachineState machineState);

  /**
   * (AWSとDEの通信断からの復旧)工程状態更新
   * @param param 装置状態
   * @return
   */
  @Update(sqlFile = true)
  int updateProcessState(MntMachineState machineState);
  // add AWSとDEの通信断からの復旧 --趙-- end
  // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen start
  @Update(sqlFile = true)
  int updateClearNoticeCnt(String facilityCd, String machineTypeCd, String machineSerial);

  @Update(sqlFile = true)
  int updateNoticeCnt(String facilityCd, String machineTypeCd, String machineSerial, Integer mNoticeCnt);

  @Select
  MntMachineState selectNoticeCntByRecordNo(Long motionRecordNo);
  // add bug #5812 通信エラー解消後に対処済みにしても赤色のまま 修正 chen end

  // add FNSI-7217 必要なデータを事前にクエリする 查 start
  @Select
  List<MntMachineState> selectMntMachineStateByFacilityCd(String facilityCd);
  // add FNSI-7217 必要なデータを事前にクエリする 查 end
//add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
  /**
   * 装置治療状況チェック.
   * processState 工程状態！=99
   * @param patId 患者ID
   * @return 対象の装置情報
   */
  @Select
  List<MntMachineState> selectByPatId(Long patId);
  //add 7074 2022-12-02 設定していないホスト報知が通知される 張 end

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  @Update(sqlFile = true)
  int updateStartDate(MntMachineState param);

  @Update(sqlFile = true)
  int updateEndDate(MntMachineState param);

  @Update(sqlFile = true)
  int updateMNoticeCnt(String facilityCd, String machineTypeCd, String machineSerial,
                       int mNoticeCnt, Timestamp upDate);

  @Update(sqlFile = true)
  int updatePreventiveMainteCnt(String facilityCd, String machineTypeCd, String machineSerial,
                                int preventiveMainteCnt, Timestamp upDate);

  @Update(sqlFile = true)
  int updateServiceSupportCnt(String facilityCd, String machineTypeCd, String machineSerial,
                              int serviceSupportCnt, Timestamp upDate);

  @Update(sqlFile = true)
  int updateBedInfoByBedCd(Long bedCd);

  @Update(sqlFile = true)
  int updateBedInfoByPk(String facilityCd, String machineTypeCd, String machineSerial,
                        Long bedCd, String bedNm);

  /* add by chamaojia 2024-07-03 [10806] Add SQL for clearing bed related information --start */
  @Update(sqlFile = true)
  int updateBedInfoToClearByPk(String facilityCd, String machineTypeCd, String machineSerial);
  /* add by chamaojia 2024-07-03 [10806] Add SQL for clearing bed related information --end */

  @Select
  int selectMachineStateRowCntByPk(String facilityCd, String machineTypeCd, String machineSerial);

  @Update(sqlFile = true)
  int updateOldMachineByPk(String facilityCd, String oldMachineTypeCd, String oldMachineSerial,
                           String newMachineTypeCd, String newMachineSerial, String model, String machineName,
                           Timestamp upDate);
  /* add by quzhinan  2023-02-01 [Trigger]  end */

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Select
  MntMachineState selectActiveByBedCd(String facilityCd, Long bedCd);
  //add #10412 次患者更新関連全体見直し対応 朴 end

  // add 10880 start */
  @Select
  List<MntMachineState> selectByOrdNoList(String facilityCd, List<Long> ordNoList);
  // add 10880 end */

  // ＃10889 2024.09.13 add オフラインフラグ初期化 TDC片口 start
  @Update(sqlFile = true)
  int updateIsOfflineInitialize(String facilityCd, String machineTypeCd, String machineSerial);
  // ＃10847 2024.09.13 add オフラインフラグ初期化 TDC片口 end
}
