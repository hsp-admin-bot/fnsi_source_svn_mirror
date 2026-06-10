package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecordEntity;
import org.seasar.doma.BatchUpdate;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.DissolutionDetail;
import jp.co.nikkiso.ntss.core.entity.custom.GatheringDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MNoticeDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MachineRecordDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MotionRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PreventiveDetail;
import jp.co.nikkiso.ntss.core.entity.custom.TestResultDetail;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq36;

/**
 * 装置動作記録のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntMotionRecordDao {

  /**
   * 装置動作記録の全データを取得する.
   *
   * @return 装置動作記録の全データ
   */
  @Select
  List<MntMotionRecord> selectAll();

  /**
   * 与えられた緊急発報管理番号に該当するする装置動作記録を取得する.
   *
   * @param motionRecordNo 緊急発報管理番号
   * @return 緊急発報管理番号に該当する装置動作記録
   */
  @Select
  MntMotionRecord selectByMotionRecordNo(Long motionRecordNo);

  /**
   * 装置動作記録を登録する.
   * ※{@link MntMotionRecord#getContents()}と{@link MntMotionRecord#getSendEmailText()}は登録対象外とする.
   *
   * @param mntMotionRecord 登録する装置動作記録
   * @return 登録件数
   */
  @Insert(exclude = { "contents", "sendEmailText", "facilityUrlSetting" })
  int insert(MntMotionRecord mntMotionRecord);

  /**
   * 装置動作記録を削除する.
   *
   * @param mntMotionRecord 削除対象の装置動作記録
   * @return 削除件数
   */
  @Delete
  int delete(MntMotionRecord mntMotionRecord);

  /**
   * 装置動作記録を更新する.
   *
   * @param mntMotionRecord 更新する装置動作記録
   * @return 更新件数
   */
  @Update(exclude = { "contents", "sendEmailText", "facilityUrlSetting" })
  int update(MntMotionRecord mntMotionRecord);

  /**
   * 基準日を元に、データが存在する7日分を降順で取得.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 装置番号
   * @param baseDate 基準日
   */
  @Select
  List<String> selectEventRegDates(String baseDate, String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 装置一覧の値を元に、指定期間内の装置動作記録を抽出.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録用Entity
   */
  @Select
  List<MotionRecord> selectByMachinesInfo(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate);

  /**
   * 装置一覧の値を元に、指定期間内の装置動作記録を抽出.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録用Entity
   */
  @Select
  List<MotionRecord> selectByMachinesInfoLimitOffset(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate, Integer limit, Integer offset, List<Integer> dataType, String freeWord);


  /**
   * 装置一覧の値を元に、指定期間内のデータ収集記録以外の装置動作記録を抽出.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録用Entity
   */
  @Select
  List<MotionRecord> selectByMachinesInfoWithoutGatherinngLimitOffset(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate, Integer limit, Integer offset, List<Integer> dataType, String freeWord);

    /**
   * 装置一覧の値を元に、指定期間内の装置動作記録総数を取得
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return String
   */
  @Select
  String countTotalMachinesInfoLimitOffset(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate, List<Integer> dataType, String freeWord);

  /**
   * 装置一覧の値を元に、指定期間内のデータ収集記録以外の装置動作記録総数を取得
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return String
   */
  @Select
  String countTotalMachinesInfoWithoutGatherinngLimitOffset(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate, List<Integer> dataType, String freeWord);

  /**
   * 装置動作記録番号をキーに、装置記録を抽出.
   *
   * @param motionRecordNo 装置動作記録番号
   * @return 装置動作記録詳細_装置記録用Entity
   */
  @Select
  MachineRecordDetail selectMachineRecordDetail(Long motionRecordNo);

  /**
   * 装置動作記録番号をキーに、緊急発報記録を抽出.
   *
   * @param motionRecordNo 装置動作記録番号
   * @return 装置動作記録詳細_緊急発報記録用Entity
   */
  @Select
  MNoticeDetail selectMNoticeDetail(Long motionRecordNo);

  /**
   * 装置動作記録番号をキーに、予防保全/故障予知記録を抽出.
   *
   * @param motionRecordNo 装置動作記録番号
   * @return 装置動作記録詳細_予防保全/故障予知記録用Entity
   */
  @Select
  PreventiveDetail selectPreventiveDetail(Long motionRecordNo);

  /**
   * 装置動作記録番号をキーに、データ収集記録を抽出.
   *
   * @param motionRecordNo 装置動作記録番号
   * @return 装置動作記録詳細_データ収集記録用Entity
   */
  @Select
  GatheringDetail selectGatheringDetail(Long motionRecordNo);

  /**
   * 指定期間内のすべての自己診断結果を抽出/
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録詳細_自己診断結果用Entity
   */
  @Select
  List<TestResultDetail> selectAllTestResults(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate);

  /**
   * 指定期間内の自己診断結果を抽出.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param baseDate 選択日
   * @param testType 自己診断種別
   * @param offset スキップ行数
   * @param limit 取得行数
   * @param jsonAddressList フィルタ条件リスト
   * @return 装置動作記録詳細_自己診断結果用Entity
   */
  @Select
  List<TestResultDetail> selectTestResults(String facilityCd, String machineTypeCd, String machineSerial, String baseDate, int testType, int offset, int limit, List<String> jsonAddressList);

  /**
   * 指定期間内の溶解記録を抽出.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @param offset スキップ行数
   * @param limit 取得行数
   * @param isGraph グラフ作成かどうか
   * @param jsonAddressList フィルタ条件リスト
   * @return 装置動作記録詳細_溶解記録結果用Entity
   */
  @Select
  List<DissolutionDetail> selectDissolutions(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate, int offset, int limit, Boolean isGraph, List<String> jsonAddressList);

  /**
   * 仮想端末情報（ログ）を最大200件降順で抽出
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日（条件送信日時）
   */
  @Select
  List<LcdReq36> selectMachineRecordMessage(String facilityCd, String machineTypeCd, String machineSerial, Timestamp fromDate, long ordNo, int offset);

  //add redmine bug#6392 劉 start
  /**
   * 仮想端末情報（ログ）を最大200件降順で抽出
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日（条件送信日時）
   */
  @Select
  List<LcdReq36> selectLogMessage(String facilityCd, String machineTypeCd, String machineSerial, Timestamp fromDate, int offset);
  //add redmine bug#6392 劉 end

  /**
   * 指定されたデータの対処フラグ・対処者を更新する.
   *
   * @param motionRecordNo 装置動作記録番号
   * @param userId ユーザID
   * @param isCorrection 更新する対処フラグの値
   * @return 成功件数(1件)
   */
  @Update(sqlFile = true)
  @Transactional
  int updateCorrection(Long motionRecordNo, Long userId, String isCorrection);

  /**
   * 対象データの対処フラグ・対処者をすべて更新する.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param userId ユーザID
   * @param dataType データ種別
   */
  @Update(sqlFile = true)
  @Transactional
  int updateAllCorrections(String facilityCd, String machineTypeCd, String machineSerial, Long userId, Integer dataType);

  /**
   * 条件送信キャンセル時の更新処理
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param ordNo オーダ番号
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
  int updateClearOrdNo(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo, Timestamp upDate);

  /**
   * メンテナンスデータ挿入
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertMntMotion(MntMotionRecord param);

  /**
   * 溶解記録挿入
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertDarMotion(MntMotionRecord param);

  /**
   * 装置記録挿入
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertLogMotion(MntMotionRecord param,
      String auxDataArray0,
      String auxDataArray1,
      String auxDataArray2,
      String auxDataArray3);

  /**
   * 装置記録(メッセージあり)挿入
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertLogMotionMessage(MntMotionRecord param);

  /**
   * 装置記録挿入(ord_noあり)
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertLogMotionAndOrdNo(MntMotionRecord param,
      String auxDataArray0,
      String auxDataArray1,
      String auxDataArray2,
      String auxDataArray3);

  /**
   * 装置記録(メッセージ、ord_noあり)挿入
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertLogMotionMessageAndOrdNo(MntMotionRecord param);

  // add #10422 ？？？？患者の患者割り当てが遅い 20240314 ztc start
  /**
   * スケジュール割り当て時の更新処理
   * @param baseOrdNo オーダ番号
   * @param ordNo ？？？？患者のオーダ番号
   * @param upDate 更新日時
   * @param facilityCd 施設コード
   * @return
   */
  @Update(sqlFile = true)
  int updateOrdNoFacilityCd(String facilityCd, Long baseOrdNo, Long ordNo, Timestamp upDate);
  // add #10422 ？？？？患者の患者割り当てが遅い 20240314 ztc end

  /**
   * 装置動作記録を更新する.
   * この関数を呼び出す際は、引数の{@link MntMotionRecord}の
   * {@link MntMotionRecord#setMotionRecordNo(Long)}で
   * 更新対象の装置動作記録番号を設定する必要がある.
   *
   * @param mntMotionRecord 装置動作記録
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateServiceSupport(MntMotionRecord mntMotionRecord);

  /**
   * 装置動作記録(サービス対応)を一括で更新する.
   * この関数を呼び出す際は、引数の{@link MntMotionRecord}の以下のフィールドに
   * 値が設定されている必要がある.
   *
   *  (1) facilityCd(施設コード)
   *  (2) machineTypeCd(型式コード)
   *  (3) machineSerial(製造番号)
   *  (4) serviceSupportUserId(サービス区分更新者ID) ※実際に更新される利用者ID
   *
   * 更新対象のレコード条件は上記(1)~(3)の値と以下の条件に一致するデータである.
   *
   *  (5) サービス区分： '0'(未受付) or '1'(1次対応済み)
   *  (6) データ種別： '2'(緊急発報)
   *
   * @param mntMotionRecord 装置動作記録
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateServiceSupportAll(MntMotionRecord mntMotionRecord);

  /**
   * <code>facilityCd</code>に警報通知の最大イベント発生日時を取得する.
   * <code>machineTypeCd</code>及び、<code>machineSerial/code>が設定されている場合は、
   * 対象装置の最大イベント発生日時を取得する.
   *
   * 対象データは下記の通りとし、条件に合致するレコードの最大値を取得する.
   * 条件に合致するデータが存在しない場合は<code>null</code>を返却する.
   *
   *   データ種別(data_type) : 2
   *   <code>isNkkFacility</code>が<code>true</code>の場合
   *    サービス対応区分(service_support_type) : '0' or '1' or null
   *   <code>isNkkFacility</code>が<code>false</code>の場合
   *    対処(is_correction) : '0' or null
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param isNkkFacility 日機装施設か否か(日機装施設の場合、<code>true</code>を指定）
   * @return 最大イベント発生日時
   */
  @Select
  Timestamp selectMaxEventRegDateByFacilityCd(
    String facilityCd,
    String machineTypeCd,
    String machineSerial,
    boolean isNkkFacility);

  /**
   * 特定の施設コードの警報通知の最新の未対処イベント発生日時/最新の対処中イベント発生日時を取得する.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param isCorrection 0：最新の未対処イベント発生日時 / 2：最新の対処中イベント発生日時
   * @return 最大イベント発生日時
   */
  @Select
  Timestamp selectlatestPendingDateOrWipDate(
    String facilityCd,
    String machineTypeCd,
    String machineSerial,
    String isCorrection);

  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 start
  /**
   * 最新の自己診断合格結果を抽出
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Select
  Long selectMaxMotionRecordNo(
    String facilityCd,
    String machineTypeCd,
    String machineSerial);

  /**
   * 最新の自己診断合格結果を抽出by装置動作記録番号
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param motionRecordNo 装置動作記録番号
   * @return
   */
  @Select
  List<TestResultDetail> selectSelfMeasureResultByMotionRecordNo(
    String facilityCd,
    String machineTypeCd,
    String machineSerial,
    Long motionRecordNo);

  /**
   * 最新の自己診断合格結果を抽出byその日の日付
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Select
  List<TestResultDetail> selectSelfMeasureResultByCurrentDate(
    String facilityCd,
    String machineTypeCd,
    String machineSerial);
  // add 装置の自己診断の結果を施設カレンダーに反映する必要。 劉 end

  //add 共通通信：サーバ上へ登録した前血圧、後血圧について 劉 start
  /**
   * 最新の装置記録抽出
   *
   * @param ordNo オーダ番号
   * @param machineRecordCd 装置記録コード
   * @return
   */
  @Select
  MntMotionRecord selectByOrdNoAndRecordCd(
    Long ordNo,
    String machineRecordCd,
    /* add by chamaojia 2023-05-11 [8229] クエリー条件を追加してインデックス効率を向上  --start */
    String facilityCd);
    /* add by chamaojia 2023-05-11 [8229] クエリー条件を追加してインデックス効率を向上  --end */
  //add 共通通信：サーバ上へ登録した前血圧、後血圧について 劉 end

  //add FNSI修正486改修 房 start
  /**
   * 最新の自己診断合格結果を抽出byその日の日付
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Select
  List<MntMotionRecord> selectMntMotionRecordByOrdNo(
    String facilityCd,
    String machineTypeCd,
    String machineSerial,
    Long ordNo);
  //add FNSI修正486改修 房 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 装置記録(メッセージあり)挿入(AWSとDEの通信断からの復旧)
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertLogMotionMessageCommFail(MntMotionRecord param);

  /**
   * 装置記録挿入(AWSとDEの通信断からの復旧)
   * @param param レコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertLogMotionCommFail(MntMotionRecord param,
                      String auxDataArray0,
                      String auxDataArray1,
                      String auxDataArray2,
                      String auxDataArray3);

  // add AWSとDEの通信断からの復旧 --趙-- end

// add datalist新规模板 chen start
  /**
   * 指定期間内のすべての自己診断結果を抽出/
   *
   * @param facilityCd 施設コード
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録詳細_自己診断結果用Entity
   */
  @Select
  List<MntMotionRecord> selectMotionRecordDatalist(String facilityCd, String fromDate, String toDate);
// add datalist新规模板 chen end

  /**
   * 与えられた装置情報と装置動作記録番号に該当する装置動作記録を取得する.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param motionRecordNo 装置動作記録番号
   * @return 装置情報および装置動作記録番号に該当する装置動作記録
   */
  @Select
  MntMotionRecord selectByMachineAndMotionRecordNo(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      Long motionRecordNo);

  //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 start
  /**
   * 装置記録メッセージ作成
   * @param machineRecordMessage  装置記録メッセージ
   * @param machineRecordCd       装置記録コード
   * @param auxDataArray0         装置記録補助データ1
   * @param auxDataArray1         装置記録補助データ2
   * @param auxDataArray2         装置記録補助データ3
   * @param auxDataArray3         装置記録補助データ4
   * @return
   */
  @Select
  String buildMachineRecordMessage(
    String machineRecordMessage,
    String machineRecordCd,
    String auxDataArray0,
    String auxDataArray1,
    String auxDataArray2,
    String auxDataArray3);
  //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 end

  //add FNSI6369自己診断結果が表示しない 周 start
  /**
   * 自己診断結果を取得する
   * @param facilityCd 施設コード
   */
  @Select
  List<MntMotionRecordEntity> selectMntMotionRecord(String facilityCd, String startDate, String endDate, List<String> montionRecordList);
  //add FNSI6369自己診断結果が表示しない 周 end

//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
  /**
   * 指定期間内のすべての自己診断結果を抽出/
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param fromDate 開始日
   * @param toDate 終了日
   * @return 装置動作記録詳細_自己診断結果用Entity
   */
  @Select
  List<TestResultDetail> selectAllTestResultsSelf(String facilityCd, String machineTypeCd, String machineSerial, String fromDate, String toDate);
//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 end

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  @Select
  int selectMNoticeCnt(String facilityCd, String machineTypeCd, String machineSerial);

  @Select
  int selectPreventiveMainteCnt(String facilityCd, String machineTypeCd, String machineSerial);

  @Select
  int selectServiceSupportCnt(String facilityCd, String machineTypeCd, String machineSerial);
  /* add by quzhinan  2023-02-01 [Trigger]  end */

  /**
   * 自己診断結果の取得
   *
   * @param facilityCd    施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return
   */
  @Select
  String selectSelfMeasureResultByMachineInfo(String facilityCd, String machineTypeCd, String machineSerial);

  // #10344 Add
  /**  */
  @Select
  List<MntMotionRecord> getMntMotionRecordByTreatConds(String facilityCd, Long ordNo, Long bedCd);

  @BatchUpdate(batchSize = 1000, exclude = { "contents", "sendEmailText", "facilityUrlSetting" })
  int[] batchUpdRecord(List<MntMotionRecord> mntMotionRecords);

  // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
  @Select
  MntMotionRecord selectAllByMotionRecordNo(Long motionRecordNo);
  // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
  // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao start
  /**
   * 特定の施設コードの警報通知の最新の未対処イベント発生日時/最新の対処中イベント発生日時を取得する.
   *
   * @param facilityCd 施設コード
   * @param isCorrection 0：最新の未対処イベント発生日時 / 2：最新の対処中イベント発生日時
   * @param mntMotionRecordList 装置動作記録情報（型式コードと製造番号を保存する）
   * @return 最大イベント発生日時
   */
  @Select
  List<MntMotionRecord> selectlatestPendingDateOrWipDateForPerformance(
    String facilityCd,
    String isCorrection,
    List<MntMotionRecord> mntMotionRecordList);

  /**
   * <code>facilityCd</code>に警報通知の最大イベント発生日時を取得する.
   * <code>machineTypeCd</code>及び、<code>machineSerial/code>が設定されている場合は、
   * 対象装置の最大イベント発生日時を取得する.
   *
   * 対象データは下記の通りとし、条件に合致するレコードの最大値を取得する.
   * 条件に合致するデータが存在しない場合は<code>null</code>を返却する.
   *
   *   データ種別(data_type) : 2
   *   <code>isNkkFacility</code>が<code>true</code>の場合
   *    サービス対応区分(service_support_type) : '0' or '1' or null
   *   <code>isNkkFacility</code>が<code>false</code>の場合
   *    対処(is_correction) : '0' or null
   *
   * @param facilityCd 施設コード
   * @param mntMotionRecordList 装置動作記録情報（型式コードと製造番号を保存する）
   * @param isNkkFacility 日機装施設か否か(日機装施設の場合、<code>true</code>を指定）
   * @return 最大イベント発生日時
   */
  @Select
  List<MntMotionRecord> selectMaxEventRegDateByFacilityCdForPerformance(
    String facilityCd,
    List<MntMotionRecord> mntMotionRecordList,
    boolean isNkkFacility);

  /**
   * 自己診断結果の取得
   *
   * @param facilityCd 施設コード
   * @param mntMotionRecordList 装置動作記録情報（型式コードと製造番号を保存する）
   * @return
   */
  @Select
  List<MntMotionRecord> selectSelfMeasureResultByMachineInfoForPerformance(String facilityCd,
                                                                           List<MntMotionRecord> mntMotionRecordList);
  // add #12548 特定の施設で遠隔監視画面を開くと時間がかかる＆DBの負荷上昇 zhao end
}
