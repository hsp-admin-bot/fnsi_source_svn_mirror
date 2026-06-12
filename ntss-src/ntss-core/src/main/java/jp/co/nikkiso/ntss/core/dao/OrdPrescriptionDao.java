package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionCount;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionList;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.OrdPrescription;

@ConfigAutowireable
@Dao
public interface OrdPrescriptionDao {

    /**
     * 処方歴検索.
     *
     * @param patId 患者ID
     * @param issueDateFrom 交付日From
     * @param issueDateTo 交付日To
     * @param prescriptionType 処方種別
     * @param facilityCd 施設CD
     * @param issueState 交付状態
     * @param ordPrescriptionNoList 処方オーダー番号（0個以上の可変長引数）
     * @return 処方歴
     */
    @Select
    List<OrdPrescription> searchPrescriptionHistory(Long patId, String facilityCd, String issueDateFrom,
      String issueDateTo, String prescriptionType, String issueState, Timestamp regDate,
      Long... ordPrescriptionNoList);
    /**
     * 処方箋情報を登録
     * @param ordPrescription
     * @return
     */
    @Insert(sqlFile = true)
    int insert(OrdPrescription ordPrescription);
    /**
     * 処方箋情報を更新
     * @param ordPrescription
     * @return
     */
    @Update(sqlFile = true)
    int update(OrdPrescription ordPrescription);
    /**
     * 処方箋情報を削除
     * @param ordPrescriptionNo
     * @param upDate
     * @return
     */
    //mod 10553 start
//    @Update(sqlFile = true)
//    int delete(Long ordPrescriptionNo, Timestamp upDate);
    @Select
    List<OrdPrescription> deleteAndRerutning(Long ordPrescriptionNo, Timestamp upDate);
    //mod 10553 end
    /**
     * 処方オーダー番号で処方箋情報を取得
     * @param ordPrescriptionNo
     * @return
     */
    @Select
    OrdPrescription selectByOrdPrescriptionNo(Long ordPrescriptionNo);

    // add FNSI-改修内容イベント一覧の日付直下に、施設名を表示する dou start
    /**
     * 処方一覧を取得
     * @return
     */
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
    @Select
    List<PrescriptionList> getPrescriptionList(List<Long> patIdList, String issueDate, List<String> prescriptionTypeList, String facilityCd);
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end

    // add FNSI-処方を追加 姜 start
    @Select
// mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
//    List<PrescriptionCount> getPrescriptionCount(String patId,String facilityCd);
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    // List<PrescriptionCount> getPrescriptionCount(String patId,String facilityCd,String startDate,String endDate);
    List<PrescriptionCount> getPrescriptionCount(String patId,String facilityCd,String startDate,String endDate, Integer patShareMode);
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end
  // add FNSI-処方を追加 姜  end

  @Select
  List<Long> getPrescriptionListByPatId(Long patId,String facilityCd);

  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
  @Select
  List<OrdPrescription> selectCoopedPrescriptions(String facilityCd);
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end

  // add 20210826 #61411： FNSI-追加処方情報連携作成 鄭 start
  @Select
  List<PatEventCoopInfo> selectOrdPrescriptionDate(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  // add 20210826 #61411： FNSI-追加処方情報連携作成 鄭 start

  // add #6346 処方の項目が足りない 王永吉 start
  /**
   * 処方を取得する。
   * @param patId 患者ID
   * @param fromDate 治療日範囲の開始
   * @param toDate 治療日範囲の終了
   * @return
   */
  @Select
  // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
//  List<OrdPrescription>selectResultByPatId(Long patId, String fromDate, String toDate);
  // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//  List<OrdPrescription>selectResultByPatId(Long patId, String fromDate);
  List<OrdPrescription>selectResultByPatId(Long patId, String fromDate,List<String> prescriptionClassList);
  // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
  // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
  // add #6346 処方の項目が足りない 王永吉 end

  // add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
  /**
   * 処方最新を取得する
   * @param patId
   * @param fromDate
   * @param prescriptionClassList
   * @return
   */
  @Select
  List<OrdPrescription>selectResultLastOneByPatId(Long patId, String fromDate,List<String> prescriptionClassList);
// add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end

  /**
   * 対処処方件数を取得(一括交付済み変更)
   * @param patIdList 患者IDリスト
   * @param issueDate 交付日
   * @return
   */
  @Select
  int getPatPrescriptionCount(List<Long> patIdList, String issueDate, String facilityCd);

  /**
   * 交付状態変更対象を取得(一括交付済み変更)
   * @param patIdList 患者IDリスト
   * @param issueDate 交付日
   * @return
   */
  @Select
  List<PrescriptionList> getOrdPrescriptionNoList(List<Long> patIdList, String issueDate, String facilityCd);

  /**
   * 交付状態を更新
   * @param ordPrescriptionNoList
   * @param upDate
   * @return
   */
  //mod 10553 start
//  @Update(sqlFile = true)
//  int updateIssueState(List<Long> ordPrescriptionNoList, Timestamp upDate, String facilityCd);
  @Select
  List<OrdPrescription> updateIssueStateAndRerutning(List<Long> ordPrescriptionNoList, Timestamp upDate, String facilityCd);
  //mod 10553 end

  // add 10210 帳票における患者情報の取得元について sunsy start
  /**
   * 指定日の過去1年以内で、直近の有効なデータ、1件分
   * @param patId
   * @param fromDate
   * @return
   */
  @Select
  Long getOrdPrescriptionNoOne(Long patId, String fromDate, String facilityCd);
  // add 10210 帳票における患者情報の取得元について sunsy end

  /**
   *
   * @param ordRpCds
   * @return
   */
  @Select
  List<OrdPrescription> selectOrdRpByPks(List<Long> ordRpCds);
  // add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　start
  @Select
  List<OrdPrescription> selectPrescriptionResultByPatId(Long patId, String fromDate, String toDate);
  // add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　end

  // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
  @Select
  // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//  List<OrdPrescription>selectResultByPatIdAndDateFromTo(Long patId, String facilityCd, String fromDate, String toDate);
  List<OrdPrescription>selectResultByPatIdAndDateFromTo(Long patId, String facilityCd, String fromDate, String toDate, List<String> prescriptionClassList);
  // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
  // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end

  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  /**
   * key日付（fromDate）以前で、ord_prescription テーブルから
   * 指定患者（patId）・施設（facilityCd）に該当する
   * 最も近い処方データ（前回）を1件取得する。
   *
   * @param patId      患者ID
   * @param fromDate   基準日付（yyyyMMdd）
   * @param facilityCd 施設コード
   * @return 条件に該当する ord_prescription_no（存在しない場合は null）
   */
  @Select
  Long selectOrdPrescriptionNearestPastByKeyDateAndCd(Long patId, String fromDate, String facilityCd);

  /**
   * key日付（fromDate）以前で、ord_prescription テーブルから
   * 指定患者（patId）・施設（facilityCd）に該当する
   * 最も近い処方データ（前回）の fromDate（発行日等）を1件取得する。
   *
   * 帳票出力時の抽出基準日付を再設定する目的で使用する。
   *
   * @param patId      患者ID
   * @param fromDate   基準日付（yyyyMMdd）
   * @param facilityCd 施設コード
   * @return 条件に該当する fromDate（存在しない場合は null）
   */
  @Select
  String selectOrdPrescriptionNearestPastByKeyDateAndFromDate(Long patId, String fromDate, String facilityCd);
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
}
