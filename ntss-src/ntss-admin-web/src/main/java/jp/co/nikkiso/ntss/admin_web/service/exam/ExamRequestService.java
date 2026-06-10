package jp.co.nikkiso.ntss.admin_web.service.exam;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;

import jp.co.nikkiso.ntss.admin_web.response.exam.ExamRequestResponse;
import jp.co.nikkiso.ntss.core.entity.MntRecalcQue;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternData;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;


/**
 * 検査結果のServiceインタフェース.
 */
public interface ExamRequestService {

  /**
   * 検査結果のResponse作成.
   * @param patIdList 患者IDリスト.
   * @param startDate 表示期間(開始日).
   * @param endDate 表示期間(終了日).
   * @param facilityCd 施設コード.
   * @return 検査結果のResponse
   */
  //mod #12462 患者情報共有 zrx start
//  ExamRequestResponse createExamRequestResponse(List<Long> patIdList, String startDate, String endDate, String facilityCd);
  ExamRequestResponse createExamRequestResponse(List<Long> patIdList, String startDate, String endDate, String facilityCd, Integer patientShareMode) throws Exception;
  //mod #12462 患者情報共有 zrx end

  /**
   * 検査依頼 保存処理.
   *
   * @param updateData 画面で編集した検査依頼データ
   * @param facilityCd 施設コード.
   * @param userId ユーザーID.
   * @param patExamPatternList 検査セットパターンのリスト
   * @param patExtInfoList スケジュール延長最終日の更新リスト
   * @return 検査依頼 保存処理結果
   */
  boolean updateMasterData(List<Map<String, String>> updateData, String facilityCd, Long userId, List<PatExamPatternData> patExamPatternList, List<Map<String, String>> patExtInfoList);


  /**
   *検査セットデータの取得.
   *
   * @param facilityCd 施設コード.
   * @return 検査セット一覧.
   */
  List<MstExamSet> selectExamSetList(String facilityCd);

  /**
   * 検査セットデータの取得.
   * NOTE: 施設の紐づく全レコードを返却します
   * @param facilityCd 施設コード.
   * @return 検査セット一覧.
   */
  List<MstExamSet> selectAllExamSetListByFacility(String facilityCd);

  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 検査結果のResponse
   */
   /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatExamMain> FindPatExamMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to);
  List<PatExamMain> FindPatExamMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 検査結果のResponse
   */
  List<PatExamMain> FindPatExamMainByIsOrder(int pat_id, String dialysis_date_from, String dialysis_date_to);
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  // add FNSI-患者検査結果取得用 杜 start
  /**
   * * 患者検査結果取得用
   * @param facility_cd 施設コード
   * @return 検査結果のResponse
   */
  List<PatExamMain> FindPatExamMainByFacilityCd(String facility_cd);

  // add FNSI-患者検査結果取得用 杜 start
  /**
   * 検査再計算依頼キューテーブル取得用
   * @param facility_cd 施設コード
   * @return 検査再計算依頼キューテーブルリスト
   */
  List<MntRecalcQue> FindMntRecalcQueByFacilityCd(String facility_cd);

  // add FNSI-検体検査の表示の修正 楊 start
  /**
   * 検査予定前回検査日取得
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @return 前回検査結果のResponse
   */
   /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // PatExamMain FindPatExamMainLastDateByDateCd(int pat_id, String dialysis_date_from);
  PatExamMain FindPatExamMainLastDateByDateCd(int pat_id, String dialysis_date_from, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-検体検査の表示の修正 楊 end

  /**
   * 期間内に当てはまる検査パターンを登録
   * @param params 患者ID,期間開始日,期間終了日
   */
  void createPatExamMain(Map<String,String> params) throws Exception;

  /**
   * 検査再計算依頼キューテーブル追加
   * @param params SEQ,ステータス,施設コード,依頼日時,完了日時,内容,進捗,依頼者id,更新者ID
   */
  void createMntRecalcQue(Map<String,String> params) throws Exception;

  /**
   * 検査再計算依頼キューテーブル更新
   * @param params SEQ,ステータス,施設コード,依頼日時,完了日時,内容,進捗,依頼者id,更新者ID
   */
  void updateMntRecalcQue(Map<String,String> params) throws Exception;

  /**
   * 透析予定日変更時、検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  int updateRegExamDate(Map<String,String> params) throws Exception;

  /**
   * 透析予定中止時、検査依頼削除
   * @param params 患者ID,日付
   */

  //mod 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
  void updateIsDel(Map<String,String> params) throws Exception;
  //mod 7322 exam_ord連携の出力グループ 20221116 zhaoqi end

  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- start */
  void updateIsDelByDateList(Long patId, Long userId, String facilityCd, List<String> dateList) throws Exception;
  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- end */

  /**
   * スケジュール延長最終日を取得
   * @param facility_cd
   * @param patIdList
   * @return
   */
  /* add #6358 by zhangruixue 2023-06-13 --start */
  String selectMinSchExtEndDatePost(String facility_cd,List<Long> patIdList);
  /* add #6358 by zhangruixue 2023-06-13 --end */

  /* add by Lm.Mingyue  2023-02-01 [Transaction] start */
  /**
   * FNSI-患者が死亡した後、検査依頼を削除します
   * @param facility_cd 登録施設コード
   */
  int deleteDeadPatRequest(int overDeadlineCount, Map<String, Object> payload, NtssUser ntssUser);
  /* add by Lm.Mingyue  2023-02-01 [Transaction] end */
  List<MstExamSet> selectExamsetByPhyOrdClass(String facilityCd);

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 患者検査結果取得用(再計算用)
   * @param facilityCd 施設コード
   * @param startDate
   * @param endDate
   * @return 検査結果のResponse
   */
  List<PatPersonalMainData> getPatListByFacilityCd(String facilityCd, String startDate, String endDate);
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
  List<PatExamMain> selectExamByRegDate(String facilityCd, Long patId, String regExamDate);

  List<PatExamMain> selectExamByRegDateAndOrderClass(String facilityCd, Long patId, String regExamDate, String regOrderClass);

  // del 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  start
  // void mergePatExamMain(List<PatExamMain> insertPatExamMainList, List<PatExamMain> updatePatExamMainList, List<PatExamMain> deletePatExamMainList) throws Exception;
  // del 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  end
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
}
