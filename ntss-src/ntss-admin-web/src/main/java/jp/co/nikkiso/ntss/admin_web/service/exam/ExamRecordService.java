package jp.co.nikkiso.ntss.admin_web.service.exam;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.exam.examResultFileCaptureRequest;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamResultFileCaptureResponse;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamRecordItem;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForExamRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForOneOrder;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForPatIdLastDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainInfo;


public interface ExamRecordService {

  /**
   *検査セットデータの取得.
   *
   * @param facilityCd 施設コード.
   * @return 利用者データ情報.
   */
  List<MstExamSet> selectExamRecordSetList(String facilityCd);

  /**
   * 検査項目マスタデータの取得
   * @param facilityCd 施設コード
   * @return 指定施設の検査項目データ一式
   */
  List<MstExamItem> selectExamItemList(String facilityCd);

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 検査項目マスタデータの取得
   * @param facilityCd 施設コード
   * @return 指定施設の検査項目データ一式
   */
  List<MstExamItem> selectExamItemListForRecalc(String facilityCd);
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  /**
   * 治療情報テーブルから過去治療履歴の取得(過去5回分)
   * @param patId 患者コード
   * @param facilityCd 施設コード
   */
  List<OrdMainForExamRecord> selectRstStartDateList(Long patId,String facilityCd);


  /**
   * 検査項目マスタデータの取得
   * @param facilityCd 施設コード
   * @param examItemCd 検査項目コード(in句)
   * @param examClass 検査使用区分(in句)
   * @param dispFlg 有効フラグ
   * @return 指定施設の検査項目データ一式
   */
  List<MstExamRecordItem> selectExamItemListForItemCd(String facilityCd, List<Long> examItemCd, List<String> examClass, String dispFlg);


  /**
   * 検査項目マスタデータの取得(対象施設全件)
   * @param facilityCd 施設コード
   * @param examClass 検査使用区分(in句)
   * @param dispFlg 有効フラグ
   * @return 指定施設の検査項目データ一式
   */
  List<MstExamRecordItem> selectExamItemListForExamClass(String facilityCd, List<String> examClass, String dispFlg);

  /**
   * 検査結果データの取得
   * @param facilityCd 施設コード
   * @param patIdList 患者IDリスト(in句用)
   * @param resultFrom 結果検査日 検索FROM
   * @param resultTo 結果検索日 検索TO
   * @return 指定患者の患者検査結果データ一式
   */
  List<PatExamMainForRecord> selectExamMainToRecord(String facilityCd, List<Long> patIdList, String resultFrom, String resultTo);


  /**
   * 検査結果データ:最終検査日の取得
   * @param facilityCd 施設コード
   * @param patIdList 患者IDリスト(in句用)
   * @return 最終検査日のリスト(patIdごと)
   */
  List<PatExamMainForPatIdLastDate> selectExamMainToPatIdLastDate(String facilityCd, List<Long> patIdList);


  /**
   * 患者検査結果データの取得
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param resultFrom 結果検査日 検索FROM
   * @param resultTo 結果検索日 検索TO
   * @param examDateOrder 検査結果画面表示順
   * @return 指定患者の患者検査結果データ一式
   */
  List<PatExamMainInfo> selectExamMainToPatId(String facilityCd, String patId, String resultFrom, String resultTo, String examDateOrder);

  /**
   * 患者検査結果データ（1Order分の全検査項目別データ）の取得
   * @param examMainCd 検査結果ID
   * @return 指定患者の患者検査結果データ一式
   */
  List<PatExamMainForOneOrder> selectExamMainForOneOrder(String examMainCd);


   /**
   * 検査結果情報の登録処理
   * @param insertData PatExamMain形式更新情報
   * @throws Exception
   */
  Long insertExamMainForOneOrder(PatExamMain insertData) throws Exception;

  /**
   * 検査結果情報の更新処理
   * @param examMainCd 検査結果コード
   * @param examResultInfo 検査結果情報
   * @param upStaff 更新者ID
   * @param examDate 検査日
   * @throws Exception
   */
  void updateExamMainForOneOrder(Long examMainCd, String examResultInfo, Long upStaff, String examDate, String regOrderClass) throws Exception;


  /**
   * 選択患者に紐づくord_mainより指定された最新5件分のデータを取得
   * @param patId 患者Id
   * @param facilityCd 施設コード
   * @return 指定患者の透析実施に関する情報
   */
  List<OrdMainForExamRecord> selectOrdMainStartDatesList(Long patId, String facilityCd);


  /**
   * ファイル一括登録処理.
   *
   * @param facilityCd 施設コード.
   * @param request 取り込んだ検査結果ファイルデータ.
   * @return 登録件数、スキップレコード情報.
   */
  ExamResultFileCaptureResponse examResultFileCapture(Long userId, String facilityCd, List<examResultFileCaptureRequest> request);

  /**
   *検査セットデータの取得.
   *
   * @param facilityCd 施設コード.
   * @return 利用者データ情報.
   */
  List<MstExamSet> selectExamSetList(String facilityCd);

  /**
   * 既に存在する検査結果データの取得.
   *
   * @param patId 患者Id.
   * @param regOrderClass 検査区分.
   * @param resultExamDate 検査日時.
   * @param exclExamMainCd 除外する検査結果コード.
   * @return 検査結果データ.
   */
  PatExamMain selectExistResult(Long patId, String regOrderClass, String resultExamDate, Long exclExamMainCd);

  // add #9273 施設設定マスタのNo105の設定どおり動かない。 start
  /**
   * 既に存在する検査結果データの取得.
   *
   * @param patId 患者Id.
   * @param startDate
   * @return 検査結果データ.
   */
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
  PatExamMain selectExistOrder(Long patId, String regOrderClass, String regExamDate, Long exclExamMainCd);


  /**
  * 検査結果レコードを1件取得
  *
  * @param examMainCd 検査結果ID
  * @return 検査結果データ.
  */
  PatExamMain selectPatExamMainByExamMainCd(Long examMainCd);

  /**
  * 検査結果情報をクリアする
  *
  * @param examMainCd 検査結果ID
  */
  void clearExamResultInfo(Long examMainCd) throws Exception;

  /**
  * 検査結果レコードを論理削除する
  *
  * @param examMainCd 検査結果ID
  */
  void deletePatExamMain(Long examMainCd) throws Exception;

  /**
   * 検査結果データより削除ケースを判別し
   * それに合わせた論理削除及び履歴作成を行って結果レスポンスを返す
   * (検査結果モーダル:削除ボタン押下用)
   * @param examMainCd 検査結果コード
   * @param upStaff 更新スタッフID
   * @param checkDate 排他制御用日時
   */
  void deleteExamMainForOneOrder(Long examMainCd, Long upStaff, String checkDate) throws Exception;

  /**
   * 検査完畢后發出通知
   * @param patId
   * @param facilityCd
   */
  void registerNotification(Long patId, String facilityCd) throws Exception;

  // add FNSI-終了およびその結果を通知機能で教える 江 start
  /**
   * 検査ファイル取り込通知登録
   * @param facilityCd
   * @param successfulCount
   * @param failedCount
   */
  void registerNotificationForReadFiles(String facilityCd,String successfulCount,String failedCount) throws Exception;
  // add FNSI-終了およびその結果を通知機能で教える 江 end

  //  add マスタ削除対応 張 start
  List<Long> selectExamItemListForFacilityCd(String facilityCd);
  //  add マスタ削除対応 張 end
  //mod FNSI-6842 劉全航 start
  List<PatExamMainData> selectPatExamRequestByRegExamDateAndRegOrderClass(String facilityCd, Long patId, String startDate, String endDate, List<String> regOrderClass, List<Integer> weeksArry);
  //mod FNSI-6842 劉全航 end
}
