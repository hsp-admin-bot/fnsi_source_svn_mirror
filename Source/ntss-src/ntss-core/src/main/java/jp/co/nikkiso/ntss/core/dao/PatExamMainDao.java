package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatExamPatternConditions;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMainForAllExamResultInfo;
import jp.co.nikkiso.ntss.core.entity.PatExamMainForAllOtherInfo;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForDetails;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForGraph;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForOneOrder;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForPatIdLastDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainWeightPrint;
import jp.co.nikkiso.ntss.core.entity.custom.TemplatePatExamMain;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfPat;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq33;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq46;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

//add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
//add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

@ConfigAutowireable
@Dao
public interface PatExamMainDao {

  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者検査結果リスト
   */
  @Select
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatExamMain> selectPatExamMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to);
  List<PatExamMain> selectPatExamMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByIsOrder(int pat_id, String dialysis_date_from, String dialysis_date_to);
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  // add FNSI-患者検査結果取得用 杜 start
  /**
   * * 患者検査結果取得用
   * @param facility_cd 施設コード
   * @return 検査結果のResponse
   */
  @Select
  List<PatExamMain> selectPatExamMainByFacilityCd(String facility_cd);

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 患者検査結果取得用(再計算用)
   * @param facility_cd
   * @param startDate
   * @param endDate
   * @return
   */
  @Select
  List<Long> selectPatByFacilityCdAndDate(String facility_cd, String startDate, String endDate);
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  /**
   * * 患者検査結果取得用
   * @param facility_cd 施設コード
   * @return 検査結果のResponse
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdAndRegOrderClass(String pat_id);
//add 9735,9741,9729 再計算 guan start
  /**
   * 再計算では計算時間に基づいて、再計算する患者検査結果を取得する
   * @param pat_id
   * @param fromDate
   * @param toDate
   * @return 検査結果のResponse
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdAndFromdateToDate(String pat_id, String fromDate, String toDate);
  //add 9735,9741,9729 再計算 guan end

  // add FNSI-検体検査の表示の修正 楊 start
  /**
   * 検査予定前回検査日取得
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @return 患者検査結果リスト
   */
  @Select
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatExamMain> selectPatExamMainLastDateByDateCd(int pat_id, String dialysis_date_from);
  List<PatExamMain> selectPatExamMainLastDateByDateCd(int pat_id, String dialysis_date_from, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-検体検査の表示の修正 楊 end

  /**
   * 体重計レシート印刷用
   * @param patId 患者ID
   * @param maxDate 取得範囲最新日付
   * @param limitDate 取得範囲の過去期限（nullで全件）
   * @param itemCdList 取得する検査項目コードのリスト
   * @return
   */
  @Select
  List<PatExamMainWeightPrint> selectExamForWeight(Long patId, Timestamp maxDate, Timestamp limitDate, List<String> itemCdList);

  /**
   * 治療状況大画面で表示する検査予定を取得
   * @param patId 患者ID
   * @param regExamDateFrom 登録時検査日時
   * @param regExamDateTo 登録時検査日時
   * @return
   */
  @Select
  List<PatExamMain> selectPatExamMainForLargeDisp(Long patId, Timestamp regExamDateFrom, Timestamp regExamDateTo);

  /**
   * 指定IDの検査結果を取得する
   * @param examMainCd 検査結果ID
   * @return 患者検査結果
   */
  @Select
  PatExamMain selectPatExamMainByExamMainCd(Long examMainCd);

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<PatExamMain> selectPatExamMainByExamMainCdList(List<Long> examMainCdList);
  // Add By HandsomeLin At 2023/02/16 End

  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
  /**
   * 指定IDの検査依頼を取得する
   * @param examMainCd 検査結果ID
   * @return 患者検査結果
   */
  @Select
  PatExamMain selectPatExamMain(Long examMainCd);
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

  /**
   * 透析予定日変更時、検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  @Update(sqlFile = true)
  int updateRegExamDate(Map<String,String> params);

  /**
   * 透析予定中止時、検査依頼削除
   * @param params 患者ID,日付
   */
  @Update(sqlFile = true)
  int updateIsDel(Map<String,String> params);

  //add 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
  @Select
  List<PatExamMain> selectPatExamMainForDel(Long patId, String date);
  //add 7322 exam_ord連携の出力グループ 20221116 zhaoqi end

  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括クエリを追加します。上のselectPatExamMainForDelメソッドの拡張 -- start */
  @Select
  List<PatExamMain> selectPatExamMainForDelByPatIdAndDateList(Long patId, List<String> dateList);
  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括クエリを追加します。上のselectPatExamMainForDelメソッドの拡張 -- end */

  /**
   * 患者検査結果リスト取得用
   * @param patIdList 患者IDリスト
   * @param startDate 表示期間(開始日)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMainData> selectPatExamMainByPatIdList(List<Long> patIdList, String startDate);

  /**
   * 患者検査予定リスト取得用(is_order = 1 のデータのみ)
   * @param patIdList 患者IDリスト
   * @param startDate 表示期間(開始日)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMainData> selectPatExamMainByPatIdListExamOrder(List<Long> patIdList, String startDate,String facilityCd);

  /**
   * 指定日の患者検査結果取得
   * @param patId 患者ID
   * @param examDateFrom 登録時検査日時のFrom(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @param examDateTo 登録時検査日時のTo(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdExamdate(Long patId, Timestamp examDateFrom, Timestamp examDateTo);

  //add 8287 検査計算項目が計算されない 修正 ztc 20230623 strat
  /**
   * 指定日の患者検査結果取得
   * @param patId 患者ID
   * @param examDateFrom 登録時検査日時のFrom(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @param examDateTo 登録時検査日時のTo(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdExamEquRangeDate(Long patId, Timestamp examDateFrom, Timestamp examDateTo);
  //add 8287 検査計算項目が計算されない 修正 ztc 20230623 end

  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない dou start
  /**
   * 指定日の患者検査結果取得
   * @param patId 患者ID
   * @param examDateFrom 登録時検査日時のFrom(取り込みファイルはYYYYMMDDで指定されるため)
   * @param examDateTo 登録時検査日時のTo(取り込みファイルはYYYYMMDDで指定されるため)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdAndDate(Long patId, String examDateFrom, String examDateTo);
  // add #8144 【デグレ】検査計算結果が検査後にしか反映されない dou start
  /**
   * 指定日の患者検査結果取得
   * @param patId 患者ID
   * @param examDate 登録時検査日時のFrom(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @return 患者検査結果リスト
   */
  @Select
  PatExamMain selectPatExamMainByPatIdExamDateTime(Long patId, Timestamp examDate,String regOrderClass);

  //add 9737 TAC_BUNの計算が正しくない guan start
  /**
   * 指定日の患者検査結果取得
   * @param patId 患者ID
   * @param examDate 登録時検査日時のFrom(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdExamDateTimeList(Long patId, String examDate);
  /**
   * クエリ・チェック結果の最後の時間が最も近いデータのセット
   *
   * @param patId 患者ID
   * @param examDate 登録時検査日時
   * @return
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdAndDateLast(Long patId, String examDate);

  /**
   * クエリ検査の結果次の時間が最も近いデータのセット
   *
   * @param patId 患者ID
   * @param examDate 登録時検査日時
   * @return
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdAndDateNext(Long patId, String examDate);
  //add 9737 TAC_BUNの計算が正しくない guan end
  /**
   * 患者検査結果取得
   * @param patId 患者ID
   * @param examDateFrom 登録時検査日時のFrom(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @param examDateTo 登録時検査日時のTo(取り込みファイルはYYYYMMDD HHmmで指定されるため)
   * @param orderClass 検査区分
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdExamdateOrderclass(Long patId, Timestamp examDateFrom, Timestamp examDateTo, String regOrderClass);

  // Add By HandsomeLin At 2023/02/12 Start
  // #8242
  /**
   * 患者検査結果取得(日次バッチ処理設定用)
   * @param patId 患者ID
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatId(Long patId);
  // Add By HandsomeLin At 2023/02/12 End

  /**
   * 患者検査結果取得(パターン登録用)
   * @param patId 患者ID
   * @param regExamDate 登録時検査日時
   * @param regOrderClass 検査区分
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectPatExamMainByPatIdRegexamdateOrderclass(Long patId, Timestamp regExamDate, String regOrderClass);

  /**
   * 患者検査結果取得(前回検査時)
   * @param patId 患者ID
   * @param resultDateTo 今回検査結果日時(この日時より前のデータが取得される)
   * @param examItemCd 前回検査結果が欲しい検査項目コード
   * @return 患者検査結果
   */
  @Select
  PatExamMain selectLastExamResult(Long patId, Timestamp resultDateTo, String examItemCd, String regOrderClass);

  /**
   * 検査依頼を保存(更新).
   * @param patExamMain PatExamMainのEntity
   * @return 更新件数
   */
  @Update(include = {"orderExamSetInfo", "examOrderInfo", "orderLabelInfo", "isLock", "indUserId", "isDel", "upDate", "upStaff"})
  int updateOrderExamSetInfo(PatExamMain patExamMain);

  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
  /**
   * 検査依頼を削除(削除).
   * @param patExamMain PatExamMainのEntity
   */
  @Delete(sqlFile = true)
  int deleteByExamMainCd(PatExamMain patExamMain);
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  @Delete (sqlFile = true)
  int deleteByExamMainCdAndFacility(PatExamMain patExamMain);
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  /**
   * 検査依頼を保存(追加).
   * @param patExamMain PatExamMainのEntity
   * @return 更新件数
   */
  @Insert
  int insertOrderExamSetInfo(PatExamMain patExamMain);

  /**
   * 検査結果を保存(更新).
   * @param patExamMain PatExamMainのEntity
   * @return 更新件数
   */
  @Update(include = {"examStatus","dataGenClass","examResultInfo", "resultExamDate", "upDate"})
  int updateResultExamSetInfo(PatExamMain patExamMain);

  /**
   * 検査パターンにマッチする検査依頼を登録.
   * @param patExamMain PatExamMainのEntity
   * @return 更新件数
   */
  @Insert
  int insertPatExamMainToPattern(PatExamMain patExamMain);

  /**
   * 患者個別検査結果一覧リスト取得用
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param resultFrom 結果検査日 検索FROM
   * @param resultTo 結果検索日 検索TO
   * @param examDateOrder 検査結果画面表示順
   * @return 指定患者の患者検査結果データ一式
   */

  @Select
  List<PatExamMainForDetails> selectPatExamMainDetailList(String facilityCd, String patId, String resultFrom, String resultTo, String examDateOrder);

  /**
   * 検査結果一覧リスト取得用
   * @param facilityCd 施設コード
   * @param patIdList 患者IDリスト
   * @param resultFrom 結果検査日 検索FROM
   * @param resultTo 結果検索日 検索TO
   * @return 患者検査結果データ一式(json分解済)
   */

  @Select
  List<PatExamMainForRecord> selectPatExamMainRecordList(String facilityCd, List<Long> patIdList, String resultFrom, String resultTo);


  /**
   * 検査結果一覧リスト：最終検査日取得用
   * @param patIdList 患者IDリスト
   * @return
   */
  @Select
  List<PatExamMainForPatIdLastDate> selectPatExamMainPatIdLastDate(String facilityCd, List<Long> patIdList);

  /**
   * 検査結果OneOrder取得用
   * @param patId 患者ID
   * @return 患者検査結果データ一式(json分解済)
   */

  @Select
  List<PatExamMainForOneOrder> selectPatExamMainOneOrder(String examMainCd);


  /**
   * 検査結果OneOrder更新用
   * @param PatExamMain 更新用患者検査結果
   * @return update件数
   */

  @Update(sqlFile = true)
  int updatePatExamMainOneOrder(Long examMainCd, String examResultInfo, Long upStaff, String examDate, String regOrderClass);


  /**
   * 検査結果OneOrder更新用
   * @param PatExamMain 更新用患者検査結果
   * @return Insert件数
   */

  @Insert(sqlFile = true)
  int insertPatExamMainOneOrder(PatExamMain param);

  @Select
  Long countTreatRequestByPatId(Long patId, Long ordNo, String facilityCd);

  /**
   * 通信サーバ用検査結果を取得
   * @param patId 患者ID
   * @return
   */
  @Select
  List<LcdReq33> selectPatExamMainByExamMainCdComSv(Long examMainCd);

  /**
   * 通信サーバ用検査一覧（検査日最大12件）を取得
   * @param patId 患者ID
   * @return
   */
  @Select
  List<LcdReq46> selectPatExamMainByPatIdComSv(Long patId);

  @Select
  PatExamMain selectById(Long patId, String facilityCd, Long copOrderNo1);

  @Insert
  int insert(PatExamMain entity);

  @Insert(sqlFile = true)
  int insertWithSeq(PatExamMain entity);

  @Update(excludeNull = true)
  int update(PatExamMain entity);

  /*
   * 登録日までに患者の検査を数える
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   */
  @Select
  List<NumberOfPat> countPatExamByRegDate(String startDate, String endDate, String facilityCd);

  /**
   * 登録検査日ごとに患者IDを選択
   * @param date 日付
   * @param facilityCd  施設コード
   */
  @Select
  List<PatExamMain> selectPatIdsByRegExamDate(String date, String facilityCd);

  /**
   * 指定期間の検査依頼取得(スケジュール表の同日予定表示用)
   * @param facilityCd  施設コード
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 検査依頼リスト
   */
  @Select
  List<PatExamMainData> selectScheduleListByPeriod(String facilityCd, String startDate, String endDate);

  /**
   * 既に存在する検査結果データの取得.
   * @param patId 患者Id.
   * @param regOrderClass 検査区分.
   * @param resultExamDate 検査日時.
   * @param exclExamMainCd 除外する検査結果コード.
   * @return 検査結果データ.
   */
  @Select
  PatExamMain selectExistResult(Long patId, String regOrderClass, String resultExamDate, Long exclExamMainCd);

  // add #9273 施設設定マスタのNo105の設定どおり動かない。 start
  /**
   * 既に存在する検査結果データの取得.
   *
   * @param patId 患者Id.
   * @param startDate
   * @return 検査結果データ.
   */
  @Select
  List<PatExamMain> selectExistResultByPatId(Long patId, String startDate);
  // add #9273 施設設定マスタのNo105の設定どおり動かない。 end

  /**
   * 既に存在する検査依頼データの取得.
   * @param patId 患者Id.
   * @param regOrderClass 検査区分.
   * @param regExamDate 検査依頼日.
   * @param exclExamMainCd 除外する検査結果コード.
   * @return 検査依頼データ.
   */
  @Select
  PatExamMain selectExistOrder(Long patId, String regOrderClass, String regExamDate, Long exclExamMainCd);

  /**
  * 検査結果情報をクリアする
  *
  * @param examMainCd 検査結果ID
  */
  @Update(sqlFile = true)
  int updateForClearExamResultInfo(Long examMainCd);

  /**
   * 検査依頼削除
   * @param examMainCd 検査結果ID
   */
  @Update(sqlFile = true)
  int updateIsDelOneOrder(Long examMainCd);

  /**
   * 指定患者検索結果のis_order取得(排他チェック兼用)
   * @param examMainCd 検査結果ID
   * @return is_order
   */
  @Select(ensureResult = true)
  //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 start
  //String selectIsOrderByExamMainCd(Long examMainCd, String checkDate);
  PatExamMain selectIsOrderByExamMainCd(Long examMainCd, String checkDate);
  //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 end
  /**
  * 指定された患者検査結果を履歴として作成(論理削除済)
  *
  * @param examMainCd 検査結果ID
  * @param upStaff 更新スタッフ
  */
  @Insert(sqlFile = true)
  int insertIsDelResult(Long examMainCd, Long upStaff);


  /**
  * 検査結果データをリセットして未入力状態に更新
  *
  * @param examMainCd 検査結果ID
  * @param upStaff 更新スタッフ
  */
  @Update(sqlFile = true)
  int updateResultDel(Long examMainCd, Long upStaff);


  /**
  * 対象の検査データを論理削除する
  *
  * @param examMainCd 検査結果ID
  * @param upStaff 更新スタッフ
  */
  @Update(sqlFile = true)
  int updateIsDelByExamMainCd(Long examMainCd, Long upStaff);

  /**
   * グラフデータ（患者検査項目）を取得
   * @param params examItemX, examItemY, resultExamDateFrom, resultExamDateTo, regOrderClass
   * @param patId 患者ID
   * @param patList
   * @param regOrderClassList
   */
  @Select
  List<PatExamMainForGraph> selectPatExamForGraph(Map<String, String> params, Long patId, List<Long> patList, List<String> regOrderClassList);

  // add #12462 患者情報共有 zrx start
  /**
   * グラフデータ（患者検査項目）を取得
   * @param params examItemX, examItemY, resultExamDateFrom, resultExamDateTo, regOrderClass
   * @param patId 患者ID
   * @param patList
   * @param regOrderClassList
   */
  @Select
  List<PatExamMainForGraph> selectPatExamForGraphShr(Map<String, String> params, List<Long> patList, List<String> regOrderClassList);
// add #12462 患者情報共有 zrx end

  // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Select
  List<TemplatePatExamMain> selectDatalistByPatIdListFacilityCd(List<Long> patIdList, String facilityCd, String startDate, String endDate);
  // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
  /**
   * 患者カレンダー取得用
   * @param patId 患者ID
   * @param startDate 表示期間(開始日)
   * @param endDate 終了日
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMainData> selectPatExamMainByPatIdAndFacilityCode(String facilityCd, Long patId, String startDate, String endDate);

  /**
   * 患者カレンダー取得用
   * @param patId 患者ID
   * @param startDate 表示期間(開始日)
   * @param endDate 終了日
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMainData> selectPatExamRequestByPatIdAndFacilityCode(String facilityCd, Long patId, String startDate, String endDate);
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end

  //add 20210205「障害票一覧_検査予定.xlsx」7対応 顔 start
  /**
   * 対象の検査データを論理修正する
   *
   * @param PatExamMainHs　病人のデータ
   *
   */
  @Update(sqlFile = true)
  int updateExamSetInfo(Map<String,String> info);
  //add 20210205「障害票一覧_検査予定.xlsx」7対応 顔 end

  //add 障害票一覧_一般撮影監査依頼 劉全航 start
  @Select
  List<PatExamMainData> selectPatExamMainByPatIdAndRegExamDateAndFacilityCd(List<Long> patIdList, String regExamDate, String facilityCd);
  //add 障害票一覧_一般撮影監査依頼 劉全航 end
  @Select
  PatExamMain selectOneByPatIdAndFacilityCdAndRegExamDate(Long patId, String regExamDate, String facilityCd, String regOrderClass, String phyOrdClass);
  //add No.9   吉 start
  @Select
  List<Long> selectByDetailedSearchCondition(PatExamPatternConditions conditions, List<Long> patIdList, List<String> facilityCdList);
  //add No.9  吉 end
  @Update(sqlFile = true)
  int deleteExamRequestByPatId(String facilityCd, Long patId, Long upStaff, Long indUserId, List<Long> examMainCdList);
  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 end

  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 start
  //add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi start
  @Select
  PatExamMain selectByPatIdAndRegRadDateAndFacilityCdForNew(Long patId, String regExamDate, String facilityCd, String regOrderClass);
  //add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi end
  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 end
  // add 2021-03-30 課題No.37:オーダ番号につてい 孫 start

  //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
  //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
  //mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
  @Select
  List<PatExamMainForAllOtherInfo> selectForALlOtherInfo(Long patId, String facilityCd, String baseDate);
  //mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
  //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
  //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end

  /**
   * 指定期間の検査依頼取得
   * @param patId 患者ID
   * @param regExamDate 登録時検査日時(YYYY-MM-DD)
   * @param facilityCd  施設コード
   * @return 患者検査結果リスト
   */
  @Select
  List<PatExamMain> selectByPatIdAndRegRadDateAndFacilityCd(Long patId, String regExamDate, String facilityCd);
  // add 2021-03-30 課題No.37:オーダ番号につてい 孫 end

  // add 20210820 #61411： FNSI-加検査オーダ作成 鄭 start
  @Select
  // mod 9989 種別単位の検索条件が正しくない donghao start
  //List<PatEventCoopInfo> selectPatExamDate(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  List<PatEventCoopInfo> selectPatExamDate(String facility_cd, String dialysis_date_from, String dialysis_date_to,boolean phyFlg);
  // add 20210820 #61411： FNSI-加検査オーダ作成 鄭 end
  // mod 9989 種別単位の検索条件が正しくない donghao end
  // add 20210820 #61411： FNSI-加検査オーダ作成 鄭 end
  /**
   * 患者情報画面の入外・転入出、死亡登録で予定の削除処理実施の時の、削除対象確認で使用
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param deleteDate 日付
   */
  @Select
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
//  List<PatExamMain> selectDeleteTarget(Long patId, String facilityCd, String deleteDate);
  List<PatExamMain> selectDeleteTarget(Long patId, String facilityCd, String indStartDate, String indEndDate);
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
  /*add FNSI-改修内容redmain6287 任 start*/
  @Select
  List<Long> getExamCds(Long patId);
  /*add FNSI-改修内容redmain6287 任 end*/
  //add FNSI-redmine6060 fang start

  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi start
  @Select
  int checkRegOrderClassForJournal(Long examMainCd);
  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi end

  //add 9480 検査計算に透析時間を使用すると計算結果が表示されない guan start
  /**
   *
   * @param patI 患者番号
   * @param facilityCd 施設番号
   * @param treatDate 治療日
   * @return
   */
  @Select
  List<Long> selectPatExamMainForAutoCalculation(Long patId, String facilityCd, String treatDate);
  //add 9480 検査計算に透析時間を使用すると計算結果が表示されない guan end
  //add FNSI-redmine6060 fang start
  //mod FNSI-6842 劉全航 start
  @Select
  List<PatExamMainData> selectPatExamRequestByRegExamDateAndRegOrderClass(String facilityCd, Long patId, String startDate, String endDate, List<String> regOrderClass, List<Integer> weeksArry);
  //mod FNSI-6842 劉全航 end
  // add #7573透析実績，患者情報が更新されても、検査結果が再計算されない gaoey start
  @Select
  List<Long> selectPatExamMainForAutoCalculationById(Long patId, String treatDate);
  // add #7573透析実績，患者情報が更新されても、検査結果が再計算されない gaoey end
  // add #10147 患者情報を更新時に検査計算(更新)されない zkm start
  @Select
  List<Long> doAutoCalculationByPatIdAndTreatDate(Long patId, String treatDateFrom, String treatDateTo);
  // add #10147 患者情報を更新時に検査計算(更新)されない zkm end

  @Select
  PatExamMain selectByPatIdAndRegRadDateAndFacilityCdForNewphy(Long patId, String regExamDate, String facilityCd, String regOrderClass);

  @Select
  List<PatExamMainForAllOtherInfo> selectForALlOtherInfophy(Long patId, String facilityCd, String baseDate);

  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
  @Select
  List<PatExamMainForAllExamResultInfo> selectExamResultInfoByCalcExamItemCd(String facilityCd, Long patId, String calcExamItemCd);

  @Select
  Boolean selectTpHTDataAvailable(String facilityCd, Long examMainCd, String defaultCalcExamItemCd);
  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
  @Select
  PatExamMain selectOneExistResult(Long patId,  String facilityCd, Timestamp regExamDate,String regOrderClass);

  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
  @Select
  List<PatExamMain> selectExamByRegDate(String facilityCd, Long patId, String regExamDate);

  @Select
  List<PatExamMain> selectExamByRegDateAndOrderClass(String facilityCd, Long patId, String regExamDate, String regOrderClass);

  @Insert(sqlFile = true)
  int insertPatExamMainOfMergedList(List<PatExamMain> patExamMainOfMergedList);

  @Update(sqlFile = true)
  int updatePatExamMainOfMergedList(List<PatExamMain> patExamMainOfMergedList);

  @Delete(sqlFile = true)
  int deleteByExamMainCdList(List<Long> examMainCdList);

  @Select
  PatExamMain selectMaxPatExamMainNo();
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end

  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
  @Select
  int findByPatIdDateListCd(String facility_cd, Long pat_id, List<Map<String, String>> moveOutDateMapList);
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
  @Update(sqlFile = true)
  int updateExamOrderInfoByItemCd(String facilityCd,String examItemName,String examItemCd,String isDisp,Timestamp regExamDate);

  @Update(sqlFile = true)
  int updateExamOrderInfoByItemCdAndSetCd(String facilityCd,String setCd,String examOrderInfo,Timestamp regExamDate,String setName,String isDisp);
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
  @Select
  List<PatExamMain> selectPatExamMainByDateListAndExcludeKeyList(String facilityCd, Long patId, List<String> treatDateList, List<Long> excludeExamMainCdList);
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  @Select
  List<PatExamMain> selectExamOrderInfoByItemCd(String facilityCd,String examItemCd,Timestamp regExamDate);

  @Select
  List<PatExamMain> selectExamOrderInfoByItemCdAndSetCd(String facilityCd,String setCd,Timestamp regExamDate);
  //add 10553 連携イベント発生部分不正【最優先】zhao end

  // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start
  @Select
  List<PatExamMain> selectPatExamMainByDateListAndExcludeKeyListD(String facilityCd, Long patId, List<String> treatDateList, List<Long> excludeExamMainCdList);

  @Select
  List<PatExamMain> selectPatExamMainByDateListAndExcludeKeyListCOrU(String facilityCd, Long patId, List<String> treatDateList, List<Long> excludeExamMainCdList);
  // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx end

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<PatExamMain> deathSelectPatExamMain(String facilityCd, List<PatPersonalMain> personalMainList);

  @Select
  List<PatExamMain> deletePatExamMainToHistoryByDeathPatList(String facilityCd, List<PatExamMain> deathPatList);

  @Select
  List<PatExamMain> updatePatExamMainResultByDeathPatList(String facilityCd, List<PatExamMain> deathPatList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end
}

