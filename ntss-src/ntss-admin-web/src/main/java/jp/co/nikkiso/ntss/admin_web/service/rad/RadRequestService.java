package jp.co.nikkiso.ntss.admin_web.service.rad;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.rad.RadRequestResponse;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadPatternData;


/**
 * 放射線検査結果のServiceインタフェース.
 */
public interface RadRequestService {
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 検査結果のResponse
   */
  List<PatRadMain> FindPatRadMainByIsOrder(int pat_id, String dialysis_date_from, String dialysis_date_to);
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 検査結果のResponse
   */
   /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PatRadMain> FindPatRadMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to);
  List<PatRadMain> FindPatRadMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param rad_result_cd 放射線検査結果コード
   * @return 検査結果のResponse
   */
  List<PatRadMain> FindPatRadMainByRadResultCd(int pat_id, String dialysis_date_from, String rad_result_cd);
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end

  // add FNSI-放射線検査の表示の修正 楊 start
  /**
   * 患者経過総合ビューア取得用
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @return 検査結果のResponse
   */
   /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // PatRadMain FindPatRadMainLastDateByDateCd(long pat_id, String dialysis_date_from);
  PatRadMain FindPatRadMainLastDateByDateCd(long pat_id, String dialysis_date_from, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add FNSI-放射線検査の表示の修正 楊 end

  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付
   */
  int updateRegRadDate(Map<String,String> params) throws Exception;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  /**
   * 透析予定日変更時、放射線検査依頼日追従
   * @param params 患者ID,変更前日付,変更後日付,code
   */
  int updateRegRadDateByRadResultCd(Map<String,String> params) throws Exception;
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
  /**
   * 透析予定中止時、放射線検査依頼削除
   * @param params 患者ID,日付
   */
  int updateIsDel(Map<String,String> params) throws Exception;

  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- start */
  /**
   * 透析予定中止時、放射線検査依頼削除
   * @param patId    患者ID
   * @param dateList 日付
   */
  int updateIsDelByPatIdAndDateList(String patId, List<String> dateList) throws Exception;
  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- end */

  /**
   * 放射線検査結果のResponse作成.
   * @param patIdList 患者IDリスト.
   * @param startDate 表示期間(開始日).
   * @param facilityCd 施設コード.
   * @return 検査結果のResponse
   */
  //mod #12462 患者情報共有 zrx start
//  RadRequestResponse createRadRequestResponse(List<Long> patIdList, String startDate, String facilityCd);
  default RadRequestResponse createRadRequestResponse(List<Long> patIdList, String startDate, String facilityCd) {
    return createRadRequestResponse(patIdList, startDate, facilityCd, null);
  }

  RadRequestResponse createRadRequestResponse(List<Long> patIdList, String startDate, String facilityCd, Integer patientShareMode);
  //mod #12462 患者情報共有 zrx end

  /**
   * 放射線検査依頼 保存処理.
   *
   * @param updateData 画面で編集した検査依頼データ
   * @param facilityCd 施設コード.
   * @param userId ユーザーID.
   * @param patExamPatternList 検査セットパターンのリスト
   * @param patExtInfoList スケジュール延長最終日の更新リスト
   * @return 検査依頼 保存処理結果
   */
  boolean updateMasterData(List<Map<String, String>> updateData, String facilityCd, Long userId, List<PatRadPatternData> patRadPatternList, List<Map<String, String>> patExtInfoList);

  /**
   * 放射線検査セットデータの取得.
   *
   * @param facilityCd 施設コード.
   * @return 検査セット一覧.
   */
  List<MstRadSet> selectRadSetList(String facilityCd);

  //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 start
  /**
   *
   * @param patId 患者ID
   * @param examDate 結果時検査日時
   * @param radStatus 状況区分
   * @return
   */
  int updatePatRadStatus(Long patId, String examDate, String facilityCd, String radStatus);
  //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 end
}
