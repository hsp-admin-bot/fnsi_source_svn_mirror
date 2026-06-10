package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MniMonitorCalendr;
import org.seasar.doma.BatchInsert;
import org.seasar.doma.BatchUpdate;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.SysMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorRemainingTime;
import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorSelected;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMniMonitor;

/**
 * 装置モニタデータのDaoインタフェース
 * @author Y.Kataguchi
 *
 */
@ConfigAutowireable
@Dao
public interface MniMonitorDao {

  /**
   * 全装置モニタデータを取得する.
   *
   * @return 全装置モニタデータのリスト
   */
  @Select
  List<MniMonitor> selectAll();

  /**
   * 指定された管理番号の装置モニタデータ取得
   *
   * @param bioMoniCtlNo 取得する生体モニタリング管理番号
   * @return 生体モニタリング管理番号に該当する装置モニタデータ
   */
  @Select
  List<MniMonitor> selectByBioMoniCtlNo( List<Long> bioMoniCtlNo );

  /**
   *
   * 一部項目の抽出select
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param bioMoniCtlNo 生体モニタリング管理番号(指定番号以降の値を取得)
   * @param ordNo 一意なオーダー番号
   * @param occurDate 発生日時(指定日時以降の値を取得 nullなら全件対象)
   * @param keys　モニタデータのキー情報
   * @return
   */
  @Select
  List<MniMonitorSelected> selectPickupByMachine(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      long bioMoniCtlNo,
      long ordNo,
      Timestamp occurDate,
      List<String> keys);

  /**
   *
   * 一部項目の抽出select
   * @author M.Hasiguti
   * @param pat_id 患者ID
   * @param ord_no オーダ番号
   * @param bioMoniCtlNo 生体モニタリング管理番号
   * @param dialysis_date_from 発生日時(指定日以降の値を取得 nullなら全件対象)
   * @param dialysis_date_to 発生日時(指定日までの値を取得 nullなら全件対象)
   * @return
   */
  @Select
  List<OrdMniMonitor> selectByPatid(String pat_id, Long ord_no, Long bio_moni_ctl_no, String dialysis_date_from, String dialysis_date_to);

  /**
  * 在宅透析患者向け画面に表示する値の抽出select
   *
  * @param facilityCd 施設コード
  * @param patId 患者ID
  * @param ordNo オーダ番号
  * @return
  */
  @Select
  List<MniMonitor> selectMonitorData(String facilityCd, Long patId, Long ordNo);

  /**
   * 一部項目の抽出select EX(画面更新検証用ダミー取得)
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param bioMoniCtlNo 生体モニタリング管理番号(指定番号以降の値を取得)
   * @param lastCtlNo 生体モニタリング管理番号(指定番号まで取得)
   * @param occurDate 発生日時(指定日時以降の値を取得)
   * @param lastOccurDate 発生日時(指定日時まで取得)
   * @param keys　モニタデータのキー情報
   * @return
   */
  @Select
  List<MniMonitorSelected> selectPickupByMachineEx(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      long bioMoniCtlNo,
      long lastCtlNo,
      Timestamp occurDate,
      Timestamp lastOccurDate,
      List<String> keys);

  /**
   * 一部項目の抽出select EX(画面更新検証用ダミー取得)
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param bioMoniCtlNo 生体モニタリング管理番号(指定番号以降の値を1件取得)
   * @param occurDate 発生日時(指定日時以降の値を取得)
   * @param keys　モニタデータのキー情報
   * @return
   */
  @Select
  List<MniMonitorSelected> selectPickupByMachineExDiff(
      String facilityCd,
      String machineTypeCd,
      String machineSerial,
      long bioMoniCtlNo,
      Timestamp occurDate,
      List<String> keys);

  /**
   * 指定オーダ番号のモニタ情報を取得する.
   * ※削除されているレコードも取得される為、呼出側にて削除を取り除く必要がある.
   * (治療状況リスト：装置一覧のモニタデータ取得）
   *
   * @param ordNo システムで管理する一意なオーダ番号
   * @return オーダ番号に該当するモニタ情報のリスト
   */
  @Select
  List<MniMonitor> selectByOrdNo(Long ordNo);

  /**
   * 最新モニタ値の抽出select (治療状況リスト/マップ：モニタデータ取得）
   * @param ordNo システムで管理する一意なオーダ番号
   * @param dataType データ種別
   * @return
   */
  @Select
  List<MniMonitor> selectNowOrdNoDataType(String ordNo, Short dataType);
  // FNSI-修正、#7217、SQLに問題があり非常に高負荷、xugj mod start
  /**
   * dataType毎の最新モニタ値の抽出select (治療状況リスト/マップ：モニタデータ取得）
   * @param ordNoList システムで管理する一意なオーダ番号
   * @return
   */
  @Select
  List<MniMonitor> selectNewestOrdNoAllDataType(List<Long> ordNoList, String facilityCd);
  // FNSI-修正、#7217、SQLに問題があり非常に高負荷、xugj mod end

  /**
   * 最新モニタ値の抽出select (治療状況リスト/マップ：モニタデータ取得）
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param dataType データ種別
   * @return
   */
  @Select
  List<MniMonitor> selectNowMachineDataType(String facilityCd, String machineTypeCd, String machineSerial, Short dataType);

  /**
   * 指定モニタ値の抽出select (治療状況リスト/マップ：モニタデータ取得）
   * @param ordNoList システムで管理する一意なオーダ番号
   * @param dataType データ種別
   * @return
   */
  @Select
  //mod FNSI 治療状況リスト画面性能改善　劉祥霖　start
  List<MniMonitor> selectByOrdNoDataType(List<Long> ordNoList, Short dataType,String facilityCd);
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
  /**
   * 指定オーダ番号のモニタ情報を取得する.
   * ※削除されているレコードも取得される為、呼出側にて削除を取り除く必要がある.
   * (治療状況リスト：装置一覧のモニタデータ取得）
   *
   * @param facilityCdAndOrdNoList
   * @return オーダ番号に該当するモニタ情報のリスト
   */
  @Select
  List<MniMonitorCalendr> selectByOrdNos(List<Map<String, Object>> facilityCdAndOrdNoList);
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
  //mod FNSI 治療状況リスト画面性能改善　劉祥霖　end
  /**
   * 指定オーダーで特定データ種別のモニタデータのうち最新の1件を取得
   * @param ordNo システムで管理する一意なオーダ番号
   * @param dataType データ種別
   * @return
   */
  @Select
  MniMonitor selectByOrdNoDataTypeLast(
    // #10373 Add a parameter to improve performance, This param will help query to hit index quit well.
    // Added by Zhou.tao
    String facilityCd,
    Long ordNo
    , Short dataType);

  /**
   * モニタデータの挿入
   *
   * @param param 挿入するモニタデータのレコード
   * @return
   */
  @Insert(sqlFile = true)
  int insertMonitor(MniMonitor param);

  /**
   * 条件送信キャンセル時の更新処理
   * @param ordNo オーダ番号
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
  int updateClearOrdNo(Long ordNo, Timestamp upDate);

  /**
   * スケジュール割り当て時の更新処理
   * @param baseOrdNo オーダ番号
   * @param ordNo ？？？？患者のオーダ番号
   * @param patId 患者ID
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
  int updateOrdNoPatId(Long baseOrdNo, Long ordNo, Long patId, Timestamp upDate);

  /**
   * insert処理
   * @param param 挿入するモニタデータのレコード
   * @return
   */
  @Insert
  int insert(MniMonitor param);

  //add #7859 透析レポートの出力に失敗する場合がある(500エラー） 20220803 zhaoqi start
  /**
   * 治療記録をコピーする
   * @param ordNoOld コピー元ordNo
   * @param ordNoNew コピー先ordNo
   * @return
   */
  @Insert(sqlFile = true)
  int insertAll(Long ordNoOld, Long ordNoNew);
  //add #7859 透析レポートの出力に失敗する場合がある(500エラー） 20220803 zhaoqi end

  // add 共通通信：サーバ上へ登録した前血圧、後血圧について 高 start
  /**
   * update処理
   * @param param 更新処理
   * @return
   */
  @Update
  int update(MniMonitor param);
  // add 共通通信：サーバ上へ登録した前血圧、後血圧について 高 end

  /**
   * トレンドグラフ用のモニタデータ収集
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param startDate　検索範囲開始日時
   * @param endDate 検索範囲終了日時
   * @return
   */
  @Select
  List<MniMonitor> selectMonitorOnMachine(String facilityCd, String machineTypeCd, String machineSerial, String startDate, String endDate);

  /**
   * 治療記録で手入力時の更新処理
   * <pre>
   *   更新は、モニタデータ及び更新日時のみとする。
   * </pre>
   * @param bioMniCtlNo 更新する生体モニタリング番号
   * @param dataType 更新するデータ種別
   * @param monitorData 更新するモニタデータ
   * @param isDel 更新する削除フラグ
   * @param occurDate 更新する発生日時
   * @param upDate 更新する更新日時
   * @param updStaffId 更新者ID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateMonitorData(Long bioMniCtlNo, Short dataType, String monitorData, String isDel, Timestamp occurDate, Timestamp upDate, Long updStaffId);

  /**
   * バイタル情報のオーダ番号／患者ID更新処理.
   * <pre>
   *   治療記録の実績マージでバイタル情報をマージする場合に、
   *   引数で与えられたtargetOrdNoに該当するバイタル情報のオーダ番号及び患者IDを更新する。
   * </pre>
   * @param targetOrdNo 更新対象のオーダ番号
   * @param ordNo 更新するオーダ番号（このオーダ番号で更新する.）
   * @param patId 更新対象の患者ID
   * @param upDate 更新日時
   * @param updStaffId 更新者ID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateVitalDataByResultMerge(Long targetOrdNo, Long ordNo, Long patId, Timestamp upDate, Long updStaffId);

  /**
   * モニタ情報のオーダ番号／患者ID更新処理.
   * <pre>
   *   治療記録の実績マージでモニタ情報をマージする場合に、
   *   引数で与えられたtargetOrdNoに該当するモニタ情報のオーダ番号及び患者IDを更新する。
   * </pre>
   * @param targetOrdNo 更新対象のオーダ番号
   * @param ordNo 更新するオーダ番号（このオーダ番号で更新する.）
   * @param patId 更新対象の患者ID
   * @param upDate 更新日時
   * @param updStaffId 更新者ID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateMonitorDataByResultMerge(Long targetOrdNo, Long ordNo, Long patId, Timestamp upDate, Long updStaffId);

  /**
   * 指定された生体モニタリング番号のデータ種別更新処理.
   * @param bioMniCtlNo 更新対象の生体モニタリング番号
   * @param dataType 更新するデータ種別
   * @return 更新件数
   */
  @Update(sqlFile=true)
  int updateDataTypeByKey(Long bioMniCtlNo, Short dataType);

  /**
   * 指定した条件に一致したモニタ情報のデータ区分を変更する
   * @param ordNo 変更対象とするオーダ番号
   * @param oldDataType 変更対象とするデータ区分
   * @param newDataType 更新するデータ区分
   * @return
   */
  @Update(sqlFile = true)
  int updateDataTypeByOrdNoDataType(Long ordNo, Short oldDataType, Short newDataType);

  /**
   * 与えられたオーダ番号及び取得するモニタ項目（システム設定）のリストから未削除(is_del='0')で該当するデータを取得する.
   * ※モニタ項目(システム設定)にないモニタ項目を1件も格納されていないデータは取得しない.
   * <code>dataTypeArray</code>に<code>null</code>を指定した場合にはエラーが発生する為、空のリストを必ず指定する事.
   *
   * @param ordNo オーダ番号
   * @param sysMonitorItemList モニタ項目{@link SysMonitorItem}のリスト
   * @param dataTypeList 取得するデータタイプの配列
   * @return 条件に該当する {@link MniMonitor} のリスト
   */
  @Select
  // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
  // List<MniMonitor> selectMonitorDataByMoniDataNo(Long ordNo, List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList);
  List<MniMonitor> selectMonitorDataByMoniDataNo(Long ordNo,
      List<SysMonitorItem> sysMonitorItemList, List<Short> dataTypeList,String facilityCd);
  // mod 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end

  // add #11897 治療経過表のグラフ出力が要求通りではない 高 start
  @Select
  List<MniMonitor> selectMonitorDataByMoniDataNoAll(Long ordNo, List<Short> dataTypeList,String facilityCd);
  // add #11897 治療経過表のグラフ出力が要求通りではない 高 end

  /**
   * 指定モニタ（血圧）値の抽出select (前血圧／後血圧：モニタデータ取得）
   *
   * @param ordNo システムで管理する一意なオーダ番号
   * @return オーダ番号に該当するバイタルの {@link MniMonitor} のリスト
   */
  @Select
  List<MniMonitor> selectByOrdNoVital(Long ordNo);

  // add #10422 ？？？？患者の患者割り当てが遅い 20240314 ztc start
  /**
   * ？？？？患者治療のデータを割り当て患者のデータになるように書き換える
   * @param baseOrdNo 割り当て対象のオーダ番号
   * @param ordNo ？？？？患者のオーダ番号
   * @param upDate 更新日付
   * @param facilityCd 施設コード
   *
   * @return
   */
  @Update(sqlFile = true)
  int updateOrdNoByOrdNoFacilityCd(String facilityCd, Long baseOrdNo, Long ordNo, Timestamp upDate);
  // add #10422 ？？？？患者の患者割り当てが遅い 20240314 ztc end

  @Select
  List<MniMonitor> selectByIdListFacilityCd(List<Long> patIdList, String facilityCd, String startDate, String endDate);

  // add FNSI-redmine#5170 付 房 start
  @Delete(sqlFile = true)
  int deleteByOrdNo(Long ordNo);
  // add FNSI-redmine#5170 付 房 end

  /**
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param ordNo オーダ番号
   * @return
   */
  @Select
  MniMonitor selectMonitorByFacilityCdAndPatIdAndOrdNo(String facilityCd, Long patId, Long ordNo);

  /**
  *
  * @param facilityCd 施設コード
  * @param ordNoList オーダ番号一覧
  * @return
  */
  @Select
  List<MniMonitor> selectVitalByFacilityCdAndOrdNos(String facilityCd, List<Long> ordNoList);

  /**
   * 複数の(施設コード, オーダ番号)ペアでバイタル情報を一括取得する
   *
   * @param facilityCdAndOrdNoList 施設コード(facility_cd)とオーダ番号(ord_no)を持つMapのリスト
   * @return バイタルデータ(data_type in (2,4,5,6))のリスト
   */
  @Select
  List<MniMonitor> selectVitalByFacilityCdAndOrdNoList(List<Map<String, Object>> facilityCdAndOrdNoList);

  // add FNSI-6127 ljx start
  @Select
  MniMonitor selectByBioMoniCtlNoOne( Long bioMoniCtlNo );
  // add FNSI-6127 ljx end

  @Select
    // mod #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
//  MniMonitorRemainingTime selectRemainingTime(Long ordNo);
    // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
//  MniMonitorRemainingTime selectRemainingTime(Long ordNo,String facilityCd);
  MniMonitorRemainingTime selectRemainingTime(Long ordNo,String facilityCd,Long patId,String fromDate,String toDate);
  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
  // mod #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end

  // #10344 Add
  @Select
  List<MniMonitor> selectRecordByConds(MniMonitor param);

  @BatchUpdate(batchSize = 500)
  int[] batchUpdateRecordByConds(List<MniMonitor> params);

  @BatchInsert(batchSize = 1000)
  int[] batchInsertRecord(List<MniMonitor> params);

  @Select
  List<MniMonitor> selectRecordByOrdNoAndDataType(String facilityCd, Long ordNo, List<Short> dataTypes);

  // #10344 Add

  // #9312 Add Start
  /**
   * 治療状況モニタデータ収集
   * @param facilityCd  施設コード
   * @param ordNoList   検索オーダ番号範囲
   * @return   モニタデータ
   */
  @Select
  List<MniMonitor> selectTreatmentMonitorDataByOrdNo(String facilityCd, List<Long> ordNoList);
  // #9312 Add End
}
