package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatRadPatternDetailedConditions;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
import org.seasar.doma.Delete;
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainData;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfPat;

@ConfigAutowireable
@Dao
public interface PatRadMainDao {

  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者検査結果リスト
   */
  @Select
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatRadMain> selectPatRadMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to);
  List<PatRadMain> selectPatRadMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to, Integer patShareMode);
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
  List<PatRadMain> selectPatRadMainByIsOrder(int pat_id, String dialysis_date_from, String dialysis_date_to);
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  @Select
  List<PatRadMain> selectPatRadMainByRadResultCd(int pat_id, String dialysis_date_from, String rad_result_cd);
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
  /**
   * 指定IDの放射線検査依頼を取得する
   * @param radResultCd 検査結果ID
   * @return 患者検査結果
   */
  @Select
  PatRadMain selectPatRadMain(Long radResultCd);
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

  /**
   * 患者放射線検査結果リスト取得用
   * @param patIdList 患者IDリスト
   * @return 患者検査結果リスト
   */
  @Select
  List<PatRadMainData> selectPatRadMainByPatIdList(List<Long> patIdList, String startDate);

  /**
   * 患者、検査セットごとの前回検査日を取得
   * @param patIdList 患者IDリスト
   * @return 患者検査結果リスト
   */
  @Select
  List<String> selectLastRadDateList(List<Long> patIdList, String startDate);

  // add FNSI-放射線検査の表示の修正 楊 start
  /**
   * 患者経過総合ビューア取得用前回検査日を取得
   * @param patId 患者ID
   * @param startDate 表示開始日
   * @return 患者検査結果リスト
   */
  @Select
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatRadMain> selectLastRadDate(Long patId, String startDate);
  List<PatRadMain> selectLastRadDate(Long patId, String startDate, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-放射線検査の表示の修正 楊 end

  // Add By HandsomeLin At 2023/02/12 Start
  // #8242
  // Why do not using selectPatRadMainByPatIdList()? Because fields be selected are different!
  // Ref: selectPatRadMainByPatIdRegRaddateOrderclass(Long, Timestamp, String);
  /**
   * 患者放射線検査依頼取得(日次バッチ処理設定用)
   * @param patId 患者ID
   * @return 患者検査結果リスト
   */
  @Select
  List<PatRadMain> selectPatRadMainByPatId(Long patId);
  // Add By HandsomeLin At 2023/02/12 End

  /**
   * 患者放射線検査依頼取得(パターン登録用)
   * @param patId 患者ID
   * @param regRadDate 登録時検査日時
   * @param regOrderClass 検査区分
   * @return 患者検査結果リスト
   */
  @Select
  List<PatRadMain> selectPatRadMainByPatIdRegRaddateOrderclass(Long patId, Timestamp regRadDate, String regOrderClass);

  /**
   * 指定期間の放射線検査依頼取得(スケジュール表の同日予定表示用)
   * @param facilityCd  施設コード
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 放射線検査依頼リスト
   */
  @Select
  List<PatRadMainData> selectScheduleListByPeriod(String facilityCd, String startDate, String endDate);

  /**
   * 放射線検査依頼を保存(更新).
   * @param patRadMain PatRadMainのEntity
   * @return 更新件数
   */
  @Update(include = {"regRadDate", "orderRadSetInfo", "isLock", "isDel", "upDate"})
  int updateOrderRadSetInfo(PatRadMain patRadMain);

  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
  /**
   * 放射線検査依頼をを削除(削除).
   * @param patRadMain PatRadMainのEntity
   */
  @Delete(sqlFile = true)
  int deleteByRadResultCd(PatRadMain patRadMain);
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  @Delete(sqlFile = true)
  int deleteByRadResultCdAndFacility(PatRadMain patRadMain);
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  @Update(sqlFile = true)
  int updateRegRadDate(Map<String,String> params);
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  @Update(sqlFile = true)
  int updateRegRadDateByRadResultCd(Map<String,String> params);
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

  /**
   * 透析予定中止時、放射線検査依頼削除
   * @param params 患者ID,日付
   */
  @Update(sqlFile = true)
  int updateIsDel(Map<String,String> params);

  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括変更を追加します。上のupdateIsDelメソッドの拡張 -- start */
  /**
   * 透析予定中止時、放射線検査依頼削除
   * @param patId     患者ID
   * @param dateList  日付
   */
  @Update(sqlFile = true)
  int updateIsDelByPatIdAndDateList(String patId, List<String> dateList);
  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括変更を追加します。上のupdateIsDelメソッドの拡張 -- end */

  /**
   * 放射線検査依頼を保存(追加).
   * @param patRadMain PatRadMainのEntity
   * @return 更新件数
   */
  @Insert
  int insertOrderRadSetInfo(PatRadMain patRadMain);

  /**
   * 登録日別の患者放射線検査のカウント
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   */
  @Select
  List<NumberOfPat> countPatRadByRegDate(String startDate, String endDate, String facilityCd);

  /**
   * 登録日から患者IDを選択
   * @param date 日付
   * @param facilityCd  施設コード
   */
  @Select
  List<PatRadMain> selectPatIdsByRegRadDate(String date, String facilityCd);

  /**
   * 主キーで選択
   *
   * @param ratResultCd システムで管理する一意な放射線検査結果コード
   */
  @Select
  PatRadMain selectByPrimaryKey(Long ratResultCd);
  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 start

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<PatRadMain> selectByPrimaryKeyList(List<Long> ratResultCdList);
  // Add By HandsomeLin At 2023/02/16 End

  @Select
  PatRadMain selectByPatIdAndRegRadDateAndFacilityCdForNew(Long patId, String regRadDate, String facilityCd);
  // add 2022-01-18 課題No.37:オーダ番号につてい再対応 孫 end
  //add 障害票一覧_一般撮影監査依頼 劉全航 start
  @Select
  List<PatRadMain> selectByPatIdAndRegRadDateAndFacilityCd(Long patId, String regRadDate, String facilityCd);

  @Update(sqlFile = true)
  int updateRadStatusByRadResultCd(List<Long> radResultCdList,String radStatus);

  @Select
  List<PatRadMain> selectByPatIdListAndRegRadDateAndFacilityCd(List<Long> patIdList, String regRadDate,String facilityCd);
  //add 障害票一覧_一般撮影監査依頼 劉全航 end
  //add No.9   吉 start
  @Select
  List<Long> selectByDetailedSearchCondition(List<Long> patIdList, PatRadPatternDetailedConditions conditions, List<String> facilityCdList);
  //add No.9   吉 end
  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 start
  @Update(sqlFile = true)
  int deleteRadRequestByPatId(String facilityCd, Long patId, Long upStaff, Long indUserId, List<Long> radResultCdList);
  //add FNSI-患者が死亡した後、検査依頼を削除します 劉全航 end
  // add 20210820 #61411： FNSI-加放射線検査オーダ 鄭 start
  @Select
  // mod 9989 種別単位の検索条件が正しくない donghao start
  // List<PatEventCoopInfo> selectPatRedMainDate(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  List<PatEventCoopInfo> selectPatRadMainDate(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  // add 20210820 #61411： FNSI-加放射線検査オーダ 鄭 end
  // mod 9989 種別単位の検索条件が正しくない donghao end
  // add 20210820 #61411： FNSI-加放射線検査オーダ 鄭 end

  /**
   * 患者情報画面の入外・転入出、死亡登録で予定の削除処理実施の時の、削除対象確認で使用
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param deleteDate 日付
   */
  @Select
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
//  List<PatRadMain> selectDeleteTarget(Long patId, String facilityCd, String deleteDate);
  List<PatRadMain> selectDeleteTarget(Long patId, String facilityCd, String indStartDate, String indEndDate);
  // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
  @Select
  int findByPatIdDateListCd(String facility_cd, Long pat_id, List<Map<String, String>> moveOutDateMapList);
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
  @Update(sqlFile = true)
  int updateOrderRadSetInfoBySetCd(String facilityCd, String setName, String setCd, String isDisp, Timestamp regRadDate);
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
  @Select
  List<PatRadMain> selectPatRadMainByDateListAndExcludeKeyList(String facilityCd, Long patId, List<String> treatDateList, List<Long> excludeRadResultCdList);
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  @Select
  List<PatRadMain> selectOrderRadSetInfoBySetCd(String facilityCd, String setCd, Timestamp regRadDate);
  //add 10553 連携イベント発生部分不正【最優先】zhao end

  // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start
  @Select
  List<PatRadMain> selectPatRadMainByDateListAndExcludeKeyListD(String facilityCd, Long patId, List<String> treatDateList, List<Long> excludeRadResultCdList);

  @Select
  List<PatRadMain> selectPatRadMainByDateListAndExcludeKeyListCOrU(String facilityCd, Long patId, List<String> treatDateList, List<Long> excludeRadResultCdList);
  // add #11203 1日に複数回治療予定が存在する場合のexam_ordの削除イベント発行の動作不正 zrx start

  //add #10901 死亡患者受信時処理について 20241231 zrx start
  @Select
  List<PatRadMain> deletePatRadMainToHistoryByDeathPatList(String facilityCd, List<PatPersonalMain> personalMainList);
  //add #10901 死亡患者受信時処理について 20241231 zrx end
}
