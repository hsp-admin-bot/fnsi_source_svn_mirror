package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.ItemFacilityCalendar;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfInspectionResult;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfInspectionResultExtends;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.SelfDiagnosisResult;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

@ConfigAutowireable
@Dao
public interface FacilityCalendarDao {
	/**
	 * 定期的に検査結果をカウント
	 * @param startDate 開始日
	 * @param endDate 終了日
	 * @param facilityCd 施設コード
	 */
	@Select
	List<NumberOfInspectionResult> countInspectionResultByAns2(String startDate, String endDate, String facilityCd);

  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --start */
  /**
   * 毎日の点検で検査結果を数える
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd 施設コード
   * @param mainteLayoutCdList 点検レイアウトコード集合
   */
  @Select
  //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
  // mod #9552 日常点検の個別選択ができない 商 start
  //List<NumberOfInspectionResult> countInspectionResultByAns1(String startDate, String endDate, String facilityCd);
  List<NumberOfInspectionResultExtends> countInspectionResultByAns1(String startDate, String endDate, String facilityCd, List<String> mainteLayoutCdList);
  // mod #9552 日常点検の個別選択ができない 商 end
  //mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --end */

	/**
	   * 計画による結果水調査のカウント
	   * @param startDate 開始日
	   * @param endDate 終了日
	   * @param facilityCd  施設コード
	   */
	@Select
  // mod 検査中+実績 数修正 chen start
	// List<ItemFacilityCalendar> countResultWaterSurveyByPlan(String startDate, String endDate, String facilityCd, String plan);
  List<ItemFacilityCalendar> countResultWaterSurveyByPlan(String startDate, String endDate, String facilityCd);
  // mod 検査中+実績 数修正 chen end

	/**
	   * 調査ポイント記録の合計
	   * @param startDate 開始日
	   * @param facilityCd  施設コード
	   */
	@Select
	ItemFacilityCalendar sumOfSurveyPointRecord(String facilityCd);

  // add FutreNetWeb+SI課題管理No4038対応 趙 start
  /**
   * 検査予定を持つ箇所の件数
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param plan 予定
   */
  @Select
  List<ItemFacilityCalendar> sumOfSurveyPointRecordByPlan(String startDate, String endDate, String facilityCd, String plan);
  // add FutreNetWeb+SI課題管理No4038対応 趙 end

  // add FutreNetWeb+SI課題管理No4037対応 趙 start
  /**
   * 検査箇所予定と実績の合計
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   * @param plan 予定
   */
  @Select
  List<ItemFacilityCalendar> sumOfSurveyPointRecordToatl(String startDate, String endDate, String facilityCd, String plan);
  // add FutreNetWeb+SI課題管理No4037対応 趙 end

  // add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou start
  /**
   * 自己診断結果を数える
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd 施設コード
   */
  @Select
  List<SelfDiagnosisResult> countSelfDiagnosisResult(String startDate, String endDate, String facilityCd);
  // add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou end

  //add FNSI6369自己診断結果が表示しない 周 start
  /**
   * 自己診断結果を数える
   * @param facilityCd 施設コード
   */
  @Select
  int countSelfDiagnosisMachinesCount(String facilityCd);
  //add FNSI6369自己診断結果が表示しない 周 end

}
