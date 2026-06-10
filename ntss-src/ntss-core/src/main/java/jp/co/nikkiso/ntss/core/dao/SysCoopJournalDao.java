package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.BatchInsert;
import org.seasar.doma.BatchUpdate;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Suppress;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.message.Message;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournalExtends;
import jp.co.nikkiso.ntss.core.entity.custom.ExternalCoopPayload;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import jp.co.nikkiso.ntss.core.entity.custom.SysCoopJournalParam;

/**
 * 外部連携用ジャーナルDao
 */
@ConfigAutowireable
@Dao
public interface SysCoopJournalDao {
  /**
   * 配信ステータスを更新します
   *
   * @param ctlNoList  - {@link SysCoopJournal#getCtlNo()} の List
   * @param coopResult - 配信ステータス
   * @param now        - 現在時刻
   * @return 更新件数
   */
  @Update(sqlFile = true)
  //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
  //int updateByCoopResult(List<Long> ctlNoList, String coopResult, Timestamp now);
  int updateByCoopResult(String ctlNoList, String coopResult, Timestamp now);
  //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end

  // mod 2020-11-04 FNSI-改修 外部連携706 徐 start

  /**
   * 連携施設を削除する
   *
   * @param lastDate   不要なジャナル保持限界日
   * @param facilityCd 施設コード
   * @return 0または1
   */
  @Update(sqlFile = true)
  int deleteSysCoopJournal(Timestamp lastDate, String facilityCd);
  // mod 2020-11-04 FNSI-改修 外部連携706 徐 end
  // mod 2022-07-06 FNSI-改修 外部連携#7705 ljx start

  /**
   * 連携施設を削除する(layout無効の場合、電文作成不要のため)
   *
   * @param ctlNo
   * @return 0または1
   */
  @Update(sqlFile = true)
  int deleteSysCoopJournalByCtlNo(Long ctlNo);
  // mod 2022-07-06 FNSI-改修 外部連携#7705 ljx start


  /**
   * ジャーナルデータを更新します
   *
   * @param journal - {@link SysCoopJournal}
   * @return 更新件数
   */
  @Update(includeUnchanged = false)
  int update(SysCoopJournal journal);

  /**
   * ジャーナルデータを登録します<br>
   * （テーブル定義の DEFAULT句を使用するため、NULL値のカラムは insert文から除外されます）
   *
   * @param journal - {@link SysCoopJournal}
   * @return 登録件数
   */
  @Insert(excludeNull = true)
  int insert(SysCoopJournal journal);

  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start 名前間違い変量を削除する
  @BatchInsert(batchSize = 10,exclude = {"isEditable","isDel"})
  int[] insert(List<SysCoopJournal> journals);
  //mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end 名前間違い変量を削除する

  /**
   * ジャーナルデータを検索します
   *
   * @param facilityCd  - 施設コード
   * @param coopCd      - 電文種別
   * @param coopCdIndex - 電文付帯情報
   * @param crud        - 作成更新区分
   * @param direction   - 送信/受信
   * @return {@link SysCoopJournal}
   */
  @Select
  SysCoopJournal select(String facilityCd, String coopCd, String coopCdIndex, String crud, String direction);

  /**
   * select by PK
   *
   * @param ctlNo - PK
   * @return {@link SysCoopJournal}
   */
  @Select
  SysCoopJournal selectByPK(Long ctlNo);

  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  @Select
  List<SysCoopJournal> selectByCtlNoList(List<Long> ctlNoList);
  /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */

//  /**
//   * select by ordNo,patId,direction
//   *
//   * @param ordNo      - オーダ番号
//   * @param patId      - 患者番号
//   * @param direction  - 送信/受信
//   * @param coopCd     - 電文種別
//   * @param coopVersion    - 連携版番号
//   * @param facilityCd     - 施設コード
//   * @param coopResultList - 配信処理ステータス リスト
//   * @param coopOrdNo      - （連携先)オーダ番号
//   * @return {@link SysCoopJournal}
//   */
//  @Select
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<SysCoopJournal> selectByOrdNoPatIdDirection(Long ordNo, Long patId, String direction, String coopCd, String facilityCd, List<String> coopResultList, String coopOrdNo);
//  List<SysCoopJournal> selectByOrdNoPatIdDirection(Long ordNo, Long patId, String direction, String coopCd,
//                              String coopVersion, String facilityCd, List<String> coopResultList, String coopOrdNo);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * select by ordNo,patId,direction
   *
   * @param coopResult - 通信結果
   * @param direction  -  送信/受信
   * @param facilityCd - 施設コード
   * @param ordNo （次世代FN)オーダ番号
   * @param patId 患者番号（システム）
   * @return {@link SysCoopJournal}
   */
  @Select
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  List<SysCoopJournal> selectByCoopResult(String coopResult, String direction, String facilityCd, Long ordNo, Long patId,String hospPatId,String crud,List<String> toSkipAnaResult, String coopCd);
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */
  //add #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 start
  @Select
  List<SysCoopJournal> selectUnDeliveryAsSkip(String facilityCd, Long ordNo, Long patId);
  //add #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 end
  /**
   * 変換対象となるジャーナルを取得します
   *
   * @param facilityCd - 施設コード
   * @param direction  - 送信/受信
   * @param anaResult  - 変換処理結果
   * @param coopResult - 通信結果
   * @param ctlNoList 管理番号リスト
   * @param ordNo （次世代FN)オーダ番号
   * @param patId 患者番号（システム）
   * @return List<{ @ link SysCoopJournal }>
   */
  @Select
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --start */
  List<SysCoopJournal> selectToConvert(String facilityCd, String direction, String anaResult, String coopResult, List<Long> ctlNoList
    , Long ordNo, Long patId);
  /* modify by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加ctlNoList  --end */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */

//#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 start
  /**
   * 変換対象のジャーナル数量統計
   *
   * @param facilityCd - 施設コード
   * @param direction  - 送信/受信
   * @param anaResult  - 変換処理結果
   * @param coopResult - 通信結果
   * @param ctlNoList  管理番号リスト
   * @param ordNo      （次世代FN)オーダ番号
   * @param patId      患者番号（システム）
   * @return List<{ @ link SysCoopJournal }>
   */
  @Select
  Long selectToConvertCount(String facilityCd, String direction, String anaResult, String coopResult, List<Long> ctlNoList
    , Long ordNo, Long patId);
//#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 end

  /**
   * 変換対象となるジャーナルを1件取得します
   *
   * @param facilityCd - 施設コード
   * @param direction  - 送信/受信
   * @param anaResult  - 変換処理結果
   * @param coopResult - 通信結果
   * @param ctlNoList 管理番号リスト
   * @param ordNo （次世代FN)オーダ番号
   * @param patId 患者番号（システム）
   * @return List<{ @ link SysCoopJournal }>
   */
  @Select
  List<SysCoopJournal> selectToConvertOne(String facilityCd, String direction, String anaResult, String coopResult, List<Long> ctlNoList
    , Long ordNo, Long patId);

  /**
   * 対象ジャーナルの変換処理結果を更新します
   *
   * @param ctlNo     - 管理番号
   * @param anaResult - 変換処理結果
   * @param message   - メッセージ
   * @param now       - 現在時刻
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateAnaResult(long ctlNo, String anaResult, String message, Timestamp now);

  /**
   * 対象ジャーナルの変換処理結果と電文を更新します
   *
   * @param ctlNo     - 管理番号
   * @param anaResult - 変換処理結果
   * @param dumpPath  - 電文名
   * @param dump      - 電文
   * @param now       - 現在時刻
   * @return 更新件数
   */
  @Update(sqlFile = true)
  // mod 2020-12-09 FNSI-改修 外部連携727 夏 start
  //int updateAnaResultAndStoreDump(long ctlNo, String anaResult, String dumpPath, byte[] dump, Timestamp now);
  // mod 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start
  //int updateAnaResultAndStoreDump(String coopOrdNo, long ctlNo, String anaResult, String dumpPath, byte[] dump, Timestamp now);
  int updateAnaResultAndStoreDump(String crud, String coopOrdNo, long ctlNo, String anaResult, String dumpPath, byte[] dump, Timestamp now);
  // mod 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end
  // mod 2020-12-09 FNSI-改修 外部連携727 夏 end

  /**
   * 対象ジャーナルの変換状態を更新します（未変換→変換中）
   *
   * @param ctlNoList  ジャーナルの管理番号のリスト
   * @param statusCode 変換状態（変換中）
   * @param now        システム日付
   * @return 更新件数
   */
  @Update(sqlFile = true)
  // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 mod start
//  int updateConvStatusConverting(List<Long> ctlNoList, String statusCode, Timestamp now);
  int updateConvStatusConverting(String ctlNoList, String statusCode, Timestamp now);
  // #8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 mod end

  /* add by chamaojia 2023-06-20 新規シングルピック変更方法  --start */
  // 新規シングルピック変更方法
  /**
   * 対象ジャーナルの変換状態を更新します（未変換→変換中）
   *
   * @param ctlNo  管理番号
   * @param statusCode 変換状態（変換中）
   * @param now        システム日付
   * @param beforeStatusCode 変換前状態
   * @return
   */
  @Update(sqlFile = true)
  int updateConvStatusConvertingToOne(long ctlNo, String statusCode, Timestamp now, String beforeStatusCode);
  /* add by chamaojia 2023-06-20 新規シングルピック変更方法  --end */

  /**
   * 対象ジャーナルの変換状態を更新します（変換中→完了）
   *
   * @param ctlNoList  ジャーナルの管理番号のリスト
   * @param statusCode 変換状態（完了）
   * @param now        システム日付
   * @return 更新件数
   */
  @Update(sqlFile = true)
  //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
  //int updateConvStatusCompleted(List<Long> ctlNoList, String statusCode, Timestamp now);
  int updateConvStatusCompleted(String ctlNoList, String statusCode, Timestamp now);
  //#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end

  /**
   * sys_coop_journal_ctl_no_seq を取得します
   *
   * @return sequence
   */
  @Select
  long selectNextSeqCtlNo();

  @Select
  List<SysCoopJournal> selectByConditionNoMoreTo(String facilityCd, ExternalCoopPayload payload);

  @Update(sqlFile = true)
  int updateSysExternal(SysCoopJournal journal, byte[] dump);

  @Update(sqlFile = true)
  int updatePatIdAndHospPatIdByCtlNo(long ctlNo, String hospPatId, Long patId, Long ordNo, Timestamp now);

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  @Update(sqlFile = true)
  // mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 start
//  int updateTempContent(long ctlNo, String tempContent, Timestamp now);
  int updateTempContent(long ctlNo, String tempContent, String crud, Timestamp now);
  // mod 2021-08-25 受信時、電文内容を解析した後、sys_coop_journalのcrudを更新するの対応 孫 end

  @Update(sqlFile = true)
  int updateCoopOrdNo(long ctlNo, String hospPatId, Long patId, Long ordNo, String coopOrdNo, Timestamp now);

  @Update(sqlFile = true)
  int updateCoopOrdNoByCtlNo(Long ctlNo, String coopOrdNo);

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  // add 20210820 #61411： FNSI-連携イベント中止ツールを追加 鄭 start
  @Select
  List<PatEventCoopInfo> selectStopPatInfoDate(String facility_cd, String dialysis_date_from, String dialysis_date_to, String strSyubetu);

  // add 20210820 #61411： FNSI-連携イベント中止ツールを追加 鄭 end
  // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 start
  // 種別が「ini_dial」、または「profile」のレコードを取得する
  @Select
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<SysCoopJournal> selectForNotCoopCheck(String facilityCd, String direction, Long patId, String hospPatId, String checkCoopCd);
  List<SysCoopJournal> selectForNotCoopCheck(String facilityCd, String coopVersion, String direction, Long patId,
                                             String hospPatId, String checkCoopCd);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // add 2021-08-25 #5887:富士通連携設定の構築の対応 孫 end

  //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 start
  //del 6993 profile連携で受信した生存の有無登録 zhaoqi 20221103 start
//  @Select
//  List<SysCoopJournal> selectForOrdNoCheck(String facilityCd, Long patId, Timestamp dieDate);
  //del 6993 profile連携で受信した生存の有無登録 zhaoqi 20221103 end
  //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 end

  //mod 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
  //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221103 start
  @Select
  List<SysCoopJournalExtends> selectForOrdNoCheck(String facilityCd, Long patId, String dieDate);
  //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221103 end
  //mod 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end

  // mod 2022-03-21 #7104:rep_dial連携で送信するFTPフォルダ名 孫 start
  @Update(sqlFile = true)
  int updateMessage(long ctlNo, String message);

  // mod 2022-03-21 #7104:rep_dial連携で送信するFTPフォルダ名 孫 end
  //mod FNSI-7528 劉全航 start
  @Select
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  byte[] selectLastVersionDump(String facilityCd, Long ordNo, Long patId);
  byte[] selectLastVersionDump(String facilityCd, String coopVersion, Long ordNo, Long patId);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  //mod FNSI-7528 劉全航 end
  // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 start
  @Update(sqlFile = true)
  int updateInAnaResultToNull(long ctlNo);
  // add #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 end

  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start

  /**
   * 応答待ちのジャーナルデータを更新します
   *
   * @param facilityCd 施設コード
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateWaitingStatus(String facilityCd);


  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end
  //　add #5607 連動機能の実装確認 20221205 孟堅　start
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  @Select
//  List<SysCoopJournal> selectCoop(String facilityCd, String direction, String anaResult, String coopResult, String coop_cd);
//  @Select
//  List<SysCoopJournal> selectCoop(String facilityCd, String key0, String direction, String anaResult, String coopResult, String coop_cd);
  /* modify by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
  // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 start
  @Select
  List<SysCoopJournal> selectCoopByCoopCdKey0s(String facilityCd, String direction, String anaResult, String coopResult, List<Long> ctlNoList);
  // upd #8567 （#8179问题调查结果）外部連携全般に必要な機能が制限されている改正 ztc 0508 end
  /* modify by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  //  add #5607 連動機能の実装確認 20221205 孟堅　end

  /**
   * crudとcoopCdとcoopVeresionとordNoとpatIdとdirectionとfacilityCdで検索
   */
//  @Select
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<SysCoopJournal> selectByCrudCoopCd(String crud, String coopCd, Long ordNo, Long patId, String direction, String facilityCd);
//  List<SysCoopJournal> selectByCrudCoopCd(String crud, String coopCd, String coopVersion, Long ordNo, Long patId,
//                                          String direction, String facilityCd);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

//  /**
//   * coopCdで検索
//   */
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  @Select
//  List<SysCoopJournal> selectByOrdNoPatIdDirectionCoopCd(Long ordNo, Long patId, String direction, String coopCd, String facilityCd, List<String> coopResultList);
//
//  @Select
//  List<SysCoopJournal> selectCoopResultUnprocessSkipError(String crud, List<String> coopResultList, Long ordNo, Long patId, String direction, String facilityCd);
//  @Select
//  List<SysCoopJournal> selectByOrdNoPatIdDirectionCoopCd(String coopVersion, Long ordNo, Long patId, String direction,
//                                                         String coopCd, String facilityCd, List<String> coopResultList);
//
//  @Select
//  List<SysCoopJournal> selectCoopResultUnprocessSkipError(String coopVersion, String crud, List<String> coopResultList,
//                                                          Long ordNo, Long patId, String direction, String facilityCd,Timestamp regDate);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  @Select
  List<SysCoopJournal> selectByCrudCoopCdCoopCdIndex(String crud, String coopCd, String coopCdIndex, Long ordNo,
                                                     String coopVersion,Long patId, String direction, String facilityCd,List<String> anaResult,String coopResult,Timestamp regDate);

  @Select
  List<SysCoopJournal> selectJournals(SysCoopJournalParam journal);

  @Select
  List<SysCoopJournal> selectJournalsLargeEqualRegDate(SysCoopJournalParam journal);
  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230129 zhaoqi start
  @Select
  SysCoopJournal selectJournalForExamOrdCheck(String baseDate, Long patId);
  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230129 zhaoqi end

  //add 8179 GX-常勤医空白の場合点検 start
  @Update(sqlFile = true)
  int updateCtlnodump(long ctlNo,String anaResult,String coopResult,String coopOrdNo,String message, String dumpPath, byte[] dump);
  //add 8179 GX-常勤医空白の場合点検 end

  // #6993-profile連携で受信した生存の有無登録 周 20230204 add start
  @Select
  List<SysCoopJournal> selectExamOrdJournalsToSkip(SysCoopJournalParam journal);

  @Update(sqlFile = true)
  int updateExamOrdJournalToSkip(SysCoopJournalParam scjParam);
  // #6993-profile連携で受信した生存の有無登録 周 20230204 add end

  // #9336 処理保留イベントの最適化処理が正常に行われない 2023-08-09 卓 start
  @Update(sqlFile = true)
  int updateExamOrdJournalToSkipCrudCU(SysCoopJournalParam scjParam);
  // #9336 処理保留イベントの最適化処理が正常に行われない 2023-08-09 卓 end

  //#7781 mod 【デグレ】削-除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 start
  @Suppress(messages = { Message.DOMA4182 })
  @BatchUpdate(sqlFile = true)
  int[] updateJournalListSkip(List<SysCoopJournal> journalList);

    //#7781  mod【デグレ】削除電文の連携オーダ番号が取得できず内部エラーになる 2023-03-03 卓 end

  @Update(sqlFile = true)
  int updateReportDialJournalToSkip(SysCoopJournalParam scjParam);

  /**
   * 帳票生成データを更新します
   * @param ctlNo - 管理番号
   * @param dumpPath - 帳票データのパス
   * @param reportCd - 帳票コード
   * @return
   */
  @Update(sqlFile = true)
  int updateReportDataByCtlNo(Long ctlNo, String dumpPath, Long reportCd);

  /**
   * ctl_noのより小さい条件に合うレコード件数を取得
   *
   * @param facilityCd  - 施設コード
   * @param direction - 送信/受信
   * @param anaResult - 変換処理結果
   * @param coopResult - 通信結果
   * @param coopCd - 電文種別
   * @param ctlNo - 管理番号
   * @return 件数
   */
  @Select
  Long selectSmallCtlNoJournalCount(String facilityCd, String direction, String anaResult, String coopResult
    , String coopCd, Long ctlNo);

  /**
   * in_ana_dateから指定分数経過したdirection=R, ana_result=1のレコードを取得
   *
   * @param facilityCd  - 施設コード
   * @param waitMinutes - 分数
   * @return {@link SysCoopJournal}
   */
  @Select
  SysCoopJournal selectByAnalysisElapsedTime(String facilityCd, int waitMinutes);
}
