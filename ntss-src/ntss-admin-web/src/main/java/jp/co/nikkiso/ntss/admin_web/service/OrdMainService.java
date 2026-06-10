package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdInfoListForPatListByOrdNoResponse;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainWeekPatternResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionCheckResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.api.service.utils.InvokeResult;
import jp.co.nikkiso.ntss.core.dto.FacilitySettingNo.FacilitySettingNoDisplayOrder;
import jp.co.nikkiso.ntss.core.dto.OrdMain.FutureOrdMainConditionInfo;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainMedicineDelete;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainRequest;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainSharingInfo;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdMainWithlastWeightAfter;
import jp.co.nikkiso.ntss.core.dto.OrdMain.UpdateOrdMainMediInfoDTO;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdSearchCondition;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdSearchInstCondition;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.OrdSearchTreatmentCondition;
import jp.co.nikkiso.ntss.core.entity.FluidSpeedAndAmountEntity;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.OrdChAp;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainEsListener;
import jp.co.nikkiso.ntss.core.entity.OrdMainForJournal;
import jp.co.nikkiso.ntss.core.entity.OrdMainUptSchInfoVo;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatCalendarEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.SysDataItem;
import jp.co.nikkiso.ntss.core.entity.TreatmentConditionSetting;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import jp.co.nikkiso.ntss.core.entity.custom.OrdAdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainIndIndCommentInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurAndTreatmentList;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainKurBed;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.OrdScheduleCustom;
import org.json.JSONObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;

import java.text.ParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
//2019.01.29 import jp.co.nikkiso.ntss.core.entity.DummyOrdMain;


public interface OrdMainService {

  OrdMain selectByOrdNo(Long ordNo);

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  List<OrdMain> selectListByOrdNo(List<Long> ordNoList);
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  List<OrdMain> selectByOrdNoList(List<Long> ordNoList);

  Page<OrdMain> findAll(Pageable pageable);

  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 start
  List<OrdMain> selectFutureScheduleByDateCd(String facility_cd, Long pat_id);
  // add FNSi6002-補液速度操作範囲上限を超えて設定できる 周 end

  List<OrdMain> findByCd(String pat_id, String treat_date_from, String treat_date_to, Long ord_no, Integer edition, String is_del);

  // mod #11716 曜日パターン変更の不正 関 start
  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
  List<OrdMain> findByDateCdDayInfo(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry ,String is_del, String indTreatmentCd);
  // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
  // mod #11716 曜日パターン変更の不正 関 end
//2019.01.29  List<DummyOrdMain> findByDateCd(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry ,String is_del);
  List<OrdMain> findByDateCd(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry ,String is_del);
  //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
  List<OrdMainWithlastWeightAfter> findByDateCdWithlastWeightAfter(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry , String is_del);
  //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
  List<OrdMain> findByDateCd(String facility_cd, Long pat_id, String dialysis_date_from, Long ord_no, List<Integer> weeksArry ,String is_del);
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

  // add #9273 施設設定マスタのNo105の設定どおり動かない。 start
  boolean checkExamResult(List<PatExamMain> patListRet, String treatDate);
  //10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy start
  boolean checkRadResult(List<PatRadMain> patListRet, String treatDate);
  //10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zy end
  // add #9273 施設設定マスタのNo105の設定どおり動かない。 end

  //  add 4693 鞠 start
  List<OrdMain> selectOrdMainByFacilityCd(String facilityCd,String treatDate);
//  int updateOrdMainByOrdNo(Long ordNo);
  //  add 4693 鞠 start

  List<OrdMainSharingInfo> findByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, Long ord_no, List<Integer> weeksArry , String is_del);

  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
  List<OrdMainSharingInfo> findOrdMainByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> weeksArry, Integer patShareMode);
  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

  /* upd by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<OrdMain> findByBaseDate(String facilityCd, Long patId, String baseDate, Integer period, Integer pastPeriod);
  List<OrdMainSharingInfo> findByBaseDate(String facilityCd, Long patId, String baseDate, Integer period, Integer pastPeriod, Integer patShareMode);
  /* upd by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --end */

  List<OrdMain> findByPastBaseDate(String facilityCd, Long patId, String baseDate, Integer period);

  List<OrdMainKurAndTreatmentList> getOrdMainKurAndTreatmentList(String facility_cd, Long pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> week_pattern, String is_del);

  List<SysDataItem> findByCd(String facility_cd, Integer template_no, Integer item_category, Integer item_sub_category);

  List<OrdMain> findByTreatItemCd(String pat_id, String dialysis_date_from, String dialysis_date_to, List<Integer> weeks_array, String kur_cd, String treat_item_cd_before, Integer edition, String is_del);

  // 投与薬剤、医療材料、指示コメント更新対象ordNo Listの取得
  List<OrdMain> findUpdateTarget(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs, String targetDialysisState);
  List<OrdMain> findUpdateTarget(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add 9664 by kangjie 20231205 start
  List<OrdMain> findUpdateTargetOrdMain(String facilityCd, String treatDateFrom,Integer treatmentCd);
  // add 9664 by kangjie 20231205 end

  /* add by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --start */
  List<OrdMain> selectOrdMainForTareOrOffwaterJournal(Long patId, String facilityCd, String treatDateFrom, String treatDateTo
          , List<Integer> weeks, List<Integer> treats, List<Long> kurs, String targetDialysisState);
  /* add by chamaojia 2026-05-18 [12703] 【securify】API診断を実施するとntss-admin-webが落ちる --end */

  // add #11731_【因島：改良】指示コメント番号の指定方法 start
  // 指示コメント情報（指示コメント番号で集約）の取得
  List<OrdMainIndIndCommentInfo> getIndIndCommentInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add #11731_【因島：改良】指示コメント番号の指定方法 end

//add 8204 周安寧 start
  List<TreatmentConditionSetting> getTreatmentConditionSetting(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
//add 8204 周安寧 end
  // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
  List<TreatmentRecordSetting> getByPatIdAndOrdNo(Long patId);
  // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
  /**
   * 曜日変更ダイアログの項目用データ取得 (指定条件範囲の治療方法毎の曜日リストの取得).
   * @param pat_id 患者ID
   * @param facility_cd 施設コード
   * @param dialysis_date_from 開始日
   * @param dialysis_date_to 終了日
   * @param rst_dialysis_state 状態
   * @return 治療方法毎の曜日リスト
   */
  List<String> weekPerTreatCdList(Long pat_id, String facility_cd, String dialysis_date_from, String dialysis_date_to, String rst_dialysis_state);

  OrdMain create(OrdMain ordMain);

  OrdMain update(OrdMain ordMain);

//2019.01.29  long insert(DummyOrdMain ordMain);
  @Transactional
  long insert(OrdMain ordMain);

  /* modify by chamaojia 2023-03-25 [6118] 一括保存拡張外部呼び出し可能インタフェース --start */
  /**
   * 一括保存ord _main
   * @param ordMainList      データセット
   * @param useNewOrdNoFlag  ord_no ord_no新規生成フラグが必要   true:必要
   * @return
   */
  List<OrdMain> insertList(List<OrdMain> ordMainList, boolean useNewOrdNoFlag);
  /* modify by chamaojia 2023-03-25 [6118] 一括保存拡張外部呼び出し可能インタフェース  --end */
  // add 12250 ord_material_saveの処理を2回重複実行している zkm start
  /**
   * 一括保存ord_main
   * @param ordMainList      データセット
   * @param useNewOrdNoFlag  ord_no ord_no新規生成フラグが必要   true:必要
   * @return
   */
  List<OrdMain> insertListWithoutMaterialSave(List<OrdMain> ordMainList, boolean useNewOrdNoFlag);
  // add 12250 ord_material_saveの処理を2回重複実行している zkm end

//  int delete(
//      Long pat_id,
//      String dialysis_date_from,
//      String dialysis_date_to,
//      List<Integer> treatment_cd,
//      List<Integer> kur_cd);

  int deleteByOrdNo(List<Long> ordNoList);

  /* add by shiyw 2023-03-21 [#8101] --start */
  int deleteByOrMainList(List<OrdMain> ordMainList);
  /* add by shiyw 2023-03-21 [#8101] --start */

  // mod #11716 曜日パターン変更の不正 関 start
  //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   start
  int batchDeleteByOrdNo(List<Long> ordNoList);
  //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   end
  // mod #11716 曜日パターン変更の不正 関 end

  //add #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 start
  int deleteByOrdNoQm(List<Long> ordNoList);
  //add #6227 2022-08-26 ord_mainの削除データ不正 赵鑫宇 end

  void copyDataById(List<Long> ordNoList);

  int moveDataToIndDate(
          OrdMain ordMain,
          String indScheduleUserInfo
      );

  // add #10196 rst=456 move Treatment plan ztc 20240304 start
  int moveDataToIndDateOfRst(
          OrdMain ordMain,
          String indScheduleUserInfo
  );
  // mod #10196 rst=456 move Treatment plan ztc 20240304 end

  //レコードをコピーして新しいレコードを作成する
  //キー:オーダー番号
  //設定:
  //    治療日:コピー先治療日
  //    ※以下、初期化
  //    ベッドコード
  //    ベッド名
  //    ベッド更新日
  //    クールコード
  //    クール名
  //    クール更新日
  //    治療開始時間
  int copyData(
      OrdMain ordMain
  );

  int updateTreatMethod(String treatItemCd, List<Integer> ordNo);

  void delete(Long ord_no, Integer edition);

//  // 指示コメント編集
//  int updateCommentInfo(
//      Long ordNo,
//      String commentInfo,
//      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
//      String isRstUpdate
//      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
//  );
 // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
//  // 指定番号の指示コメント削除
//  int deleteCommentInfo(
//      Long ordNo,
//      String commentInfo,
//      Boolean isNewRegistration,
//      String isRstUpdate
//      );
 // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
  /**
   * 治療情報スケジュール更新+ダミースケジュール作成
   * @param ordNoList 抽出データ（メインスケジュールのオーダ番号リスト)
   * @param indKurCd 編集データ（指示：クールコード）
   * @param indKurName 編集データ（指示：クール名）
   * @param indTreatStart_time 編集データ（指示：治療開始時刻）
   * @param indBedCd 編集データ（指示：ベッドコード）
   * @param indBedName 編集データ（指示：ベッド名）
   * @param indUserId 編集データ（指示者）
   * @param updUserid 編集データ（更新者）
   * @param updateMode 更新モード 0->通常,1->ベッド未登録処理
   * @return 正常終了:true、異常終了:false
   */
  Boolean updateOrdMainScheduleInfo(
    List<Long> ordNoList,
    Long indKurCd,
    String indKurName,
    String indTreatStartTime,
    Long indBedCd,
    String indBedName,
    Long indUserId,
    Long updUserid,
    Integer updateMode,
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
    boolean rstUpdFlg);
    // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end

  // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  start
  /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他条件追加  --start */
  // int updateOrdMainInfo(List<Long> ord_no, String ord_info, Long up_ind_user_id, Long up_user_id, Map<Long, JSONObject> coagulantInfo, String needExcludeItem);
  /* modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他条件追加  --end */
  int updateOrdMainInfo(List<Long> ord_no, String ord_info, Long up_ind_user_id, Long up_user_id, Map<Long, JSONObject> coagulantInfo, String needExcludeItem, Long patId);
  // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  end
  // add 10150_9664 by kangjie 20240830 start
  int updateFluidSpeedAndAmount(List<FluidSpeedAndAmountEntity> fluidSpeedAndAmountEntities, boolean rstDialysisState);
  // add 10150_9664 by kangjie 20240830 start
  /* modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他条件追加  --start */
  int updateRstOrdMainInfo(List<Long> ord_no, String rst_info, String needExcludeItem);
  /* modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他条件追加  --end */

//  int updateOrdMainEquipInfo(
//    Long ord_no,
//    String ord_info,
//    String rst_info
//  );
  // add by liuzhibo 2022-12-14#6961_#5698＿無期限医材変更　補填あり変更時間問題の修正 -- start /
  int updateOrdMainEquipInfo (
    OrdMain ord,
//    String ord_info,
//    String rst_info,
    Long upIndUseId,
    Long upUseId
  );
  // add by liuzhibo 2022-12-14#6961_#5698＿無期限医材変更　補填あり変更時間問題の修正 -- end /

  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、上のupdateOrdMainEquipInfoメソッドの拡張  --start */
  int updateOrdMainEquipInfoByOrdMainList(
    List<OrdMain> ordMainList,
    Long upIndUseId,
    Long upUseId,
    //mod 9806 ljx start 医療材料
    Boolean rst_update_flg);
  //mod 9806 ljx end
  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、上のupdateOrdMainEquipInfoメソッドの拡張  --end */

//    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  int updateUseId(
//    Long ordNo,
//    Long upUserId
//  );
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
  // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 start
  // int updateOrdMainMediInfo(
    // Long ord_no,
    // String ord_info,
    // String rst_info
  // );
//  int updateOrdMainMediInfo(
//    Long ord_no,
//    String ord_info,
//    String rst_info,
//    Boolean log_update_flg
//  );
  // mod FNSI-FutreNetWeb+SI課題管理No.5686 李 end

  long selectMaxIndMediInfoNo();

  // add FNSI-投薬最新識別番号の設定 李 start
  long selectMaxMediInfoNo(String facilityCd, String patId);
  // add FNSI-投薬最新識別番号の設定 李 end

  // add FNSI-医療材料最新識別番号の設定 start
  long selectMaxEquipInfoNo(String facilityCd, String patId);
  // add FNSI-医療材料最新識別番号の設定 end

  /**
   * 治療方法変更
   */
  int updateTreatmentMethod(
      List<Long> ordNoList,
      OrdMain ordMain,
      Long indUserId,
      Long updUserId
      );

  // add by liuzhibo 2022-12-14#6961_#5698＿無期限薬剤変更　投薬パターン変更時間問題の修正 -- start /
  int updateOrdMainMediInfo(
    OrdMain ord,
    String ord_info,
    String rst_info,
    Boolean log_update_flg,
    Long upIndUseId,
    Long upUseId);
  // add by liuzhibo 2022-12-14#6961_#5698＿無期限薬剤変更　投薬パターン変更時間問題の修正 -- end /

  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、上のupdateOrdMainMediInfoメソッドの拡張  --start */
  //mod 9806 ljx start 投与薬剤
  //int updateOrdMainMediInfoByList(List<UpdateOrdMainMediInfoDTO> dataList, Boolean log_update_flg);
  int updateOrdMainMediInfoByList(List<UpdateOrdMainMediInfoDTO> dataList, Boolean log_update_flg, Boolean rst_update_flg);
  //mod 9806 ljx end
  /* add by chamaojia 2023-03-22 [6961] 新しいバッチ処理インタフェース、上のupdateOrdMainMediInfoメソッドの拡張  --end */

  /**
   * 実績:治療方法変更
   */
  int updateRstTreatmentMethod(
      List<Long> ordNoList,
      Integer treatmentCd,
      String treatmentName
      );

  /**
   * 削除されるord_noを取得
   */
  List<OrdMain> selectByDeleteOrdNo(
      Long pat_id,
      String dialysis_date_from,
      String dialysis_date_to,
      List<Integer> treatment_cd,
      List<Integer> kur_cd);

  /**
   * 曜日移動するord_noを取得
   * @param pat_id 患者ID
   * @param facility_cd 施設コード
   * @param dialysis_date_from 開始日
   * @param dialysis_date_to 終了日
   * @param rst_dialysis_state 状態
   * @param treatment_cd 治療方法コード
   * @param treat_week 曜日Noのリスト
   * @return
   */
  List<OrdMain> selectMoveTarget(
      Long pat_id,
      String facility_cd,
      String dialysis_date_from,
      String dialysis_date_to,
      String rst_dialysis_state,
      Integer treatment_cd,
      List<Integer> treat_week,
      boolean hasIndKurCd);

  /**
   * 治療単位順
   * @param searchTreatmentCondition
   * @param searchCondition
   * @return
   */
  List<OrdChAp> getOrderByTreatmentCondition (OrdSearchTreatmentCondition searchTreatmentCondition, OrdSearchCondition searchCondition);

  /**
   * 指示単位順
   * @param searchInstCondition
   * @param searchCondition
   * @return
   */
  List<OrdChAp> getOrderByInstCondition (OrdSearchInstCondition searchInstCondition, OrdSearchCondition searchCondition);

  List<OrdMain> findForSearchFreeBedDate(String facility_cd, Long pat_id, Long kur_cd, List<Integer> treat_week_list, String search_start_date, String search_end_date, Boolean is_all, Long bed_cd);

  List<OrdMain> selectTreatDateListAll(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);

  List<OrdMain> getOrdMainRegExamDate(String facility_cd, Long pat_id, String start_date, String end_date, List<String> reg_order_class, List<Integer> weeksArry ,String is_del);
  /**
   * 患者IDのみで透析情報番号を取得する
   * 開示元施設とのデータも取得するので施設コードでを簡略する
   */
  Page<OrdMainTreatDate> getOrdNoList(Pageable pageable, Long pat_id);

  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
  String getMaxTreatmentDate(String patId, String facilityCd);
  // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

  /**
   * 指示・実績のDWを変更
   * @param ordNo
   * @param dw
   * @return
   */
  int updateIndRstDw(Long ordNo, Double dw);

  void updateAddInfoById(Long ordNo, String string);

  List<String> getAdditionShortNameList(String facilityCd, Long patId, Long ordNo);

  List<OrdAdditionInfo> selectAdditionInfo(String facilityCd, Long patId, Long ordNo);

  //add #12462 患者情報共有 zrx start
  List<OrdAdditionInfo> selectAdditionInfo(Long ordNo);
  //add #12462 患者情報共有 zrx end

  /**
   * オーダー番号リストからスケジュール検索
   * @param facilityCd 検索施設コード
   * @param ordNoList オーダ番号リスト
   * @return 検索にヒットしたスケジュールのリスト
   */
  List<OrdScheduleCustom> getOrdScheduleByOrdNoList(String facilityCd, List<Long> ordNoList);

  /**
   * 治療日からベッド・クール登録済みのスケジュール検索
   * @param facilityCd 検索施設コード
   * @param treatDate 検索対象治療日(yyyyMMdd形式)
   * @return 検索にヒットしたスケジュールのリスト
   */
  // mod FNSI-FutreNetWeb+SI課題管理No.4220 李 start
  // List<OrdSchedule> getReservedOrdScheduleByTreatDate(String facilityCd, String treatDate, Long patId);
  List<OrdSchedule> getReservedOrdScheduleByTreatDate(String facilityCd, String treatDate);
  // mod FNSI-FutreNetWeb+SI課題管理No.4220 李 end

  /**
   * 患者IDリストのオーダーを取得する
   * @param patIds 患者IDリスト
   * @param facilityCd 施設コード
   * @param treatDate 治療日
   */
  List<OrdMainKurBed> selectByPatIdsWithBedAndKur(List<Long> patIds, String facilityCd, String treatDate);


  /**
   * 対象治療情報の開始時刻を取得する
   * @param ordNo
   * @return
   */
  String getOrdIndTreatStartTime(Long ordNo);

  // add FNSI-修正 共有設定 start
  Page<OrdMainTreatDate> selectOrdNoListWithShared(Pageable pageable, Long pat_id, String sharedFlag);
  // add FNSI-修正 共有設定 end

  //add クールマスタ 王 start
  List<Long> selectByFacilityCd(String facilityCd);

  List<OrdMain> selectKurByFacilityCd(String facilityCd);
  //add クールマスタ 王 end

  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 start
  /**
   * 指最終更新指示者のカラム追加と更新
   * @param ordMainCdList　オーダー番号リスト
   * @param upIndUseId 最終更新指示者ID
   * @param upUseId 最終更新者ID
   * @return
   */
  int updUpUseId(List<Long> ordMainCdList, Long upIndUseId, Long upUseId);
  // add FNSI-最終更新指示者のカラム追加と更新処理 楊 end

  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
  String selectWeightInfo(Long ordNo);
  int updateWeightInfo(Long ordNo,String weightInfo);
  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
  List<String> selectOrdNo(String patId, String facilityCd, String treatDate);
  // add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end

  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
  //mod FNSI-7270 劉全航 start
  //List<FacilitySettingNoDisplayOrder> selectMedEquipDisplayOrder();
  List<FacilitySettingNoDisplayOrder> selectMedEquipDisplayOrder(String facilityCd);
  //mod FNSI-7270 劉全航 end
  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end

  /**
   * 治療中指示変更通知（1件）
   * @param ordNo オーダー番号
   * @param patIndApprove 更新するデータ
   * @return アップデート件数
   */
  int updateContentChangeSingleWithNotification(Long ordNo, PatIndApprove patIndApprove) throws Exception;

  /**
   * 治療中指示変更通知（複数）
   * @param ordNoList オーダー番号リスト
   * @param patIndApprove 更新するデータ
   * @return アップデート件数
   */
  int updateContentChangeListWithNotification(List<Long> ordNoList, PatIndApprove patIndApprove) throws Exception;

  /**
   * 治療中指示変更通知（複数・施設設定マスタNo22有効時）
   * @param ordNoList オーダー番号リスト
   * @param patIndApprove 更新するデータ
   * @return アップデート件数
   */
  int updateContentChangeListByBedControlWithNotification(List<Long> ordNoList, PatIndApprove patIndApprove) throws Exception;

  /**
   * サインイン時クール未登録チェック通知
   * @param facilityCd 施設コード
   * @param userId 利用者ID
   * @return 成功or失敗
   */
  Boolean notifyKurNotSet(String facilityCd, Long userId) throws Exception;

  /**
   * サインイン時クール未登録チェック通知
   * @param facilityCd 施設コード
   * @param userId 利用者ID
   * @return 成功or失敗
   */
  Boolean notifyBedNotSet(String facilityCd, Long userId) throws Exception;

  // add FNSI-マスタ削除表示の対応課題--治療方法 李 start
  /*
   * 治療方法コードで、治療方法名を取得する
   * @return 治療方法名
   */
  String selectMstTreatmentNameByCd(String treatmentCd);
  // add FNSI-マスタ削除表示の対応課題--治療方法 李 end

  // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
  /*
   * ベッドコードで、ベッド名を取得する
   * @return ベッド名
   */
  String selectMstBedNameByCd(String bedCd);
  /*
   * クールコードで、クール名を取得する
   * @return クール名
   */
  String selectMstKurNameByCd(String KurCd);
  // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end
  // redmine 4672  姜 start
  Integer getIndVaCd(Long ord_no);

  SendConditionCheckResponse checkFuicchi(ApiEntityOrdMain.CheckFuicchi bodyData);
  // redmine 4672  姜 start
  //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
  HashMap<String, List<Integer>> selectPatOrdMainAfterTreatDate(Long patId, String facilityCd, String treatDate);

  //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
  int delete(OrdMain selectByOrdNo);

  /* add by shiyw 2023-02-24 [#8101] 患者経過総合応答速度の最適化です --start */
  int batchDelete(List<OrdMain> ordList);
  /* add by shiyw 2023-02-24 [#8101] 患者経過総合応答速度の最適化です --end */

//  int updateWeightBefore(Long ordNo, BigDecimal setweight, String setDate);

//  int updateWeightAfter(Long ordNo, BigDecimal setweight, String setDate);

//  int updateReturnHomeDateAndState(Long ordNo, Timestamp measureDate, String afterWeight);

//  int updateRstTare(Long ordNo, String buildRstTareInfoWheelChair);

//  int updateRstOffWater(Long ordNo, String offWater);

//  int updateBeforeWeight(Long ordNo, String writeValueAsString, String offWater, String buildRstTareInfoWithWheelChair, Timestamp acceptDate, String dw);

//  int updateIndStartTareAndOffWater(Long ordNo, String offWaterInfo, String tareInfo);

//  int updateRstTareOffWaterInfo(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate);

//  int updateTareAndOffWater(long parseLong, String tareInfo, String offWaterInfo);

//  int updateIndTareOffWaterInfo(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate);

//  int updateRstTareAndOffWater(Long ordNo, String tareInfo, String offWaterInfo, Timestamp upDate);

//  int updateFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek, String tareInfo, String offWaterInfo, Timestamp upDate);

  List<OrdMain> selectFutureIndTareAndOffWater(Long patId, String treatDate, Integer treatWeek);

//  int updateDeviceInfo(Long ord_no, String facility_cd, Long pat_id, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String device_info);

//  int updateRstDeviceSetInfo(Long ord_no, String facility_cd, Long pat_id, String start_date, String end_date, List<Integer> week, List<Integer> treat_method, List<Integer> kur_cd, String device_info);

//  int immediateCommitOffWater(Long ordNo, String offWaterInfo);

//  int immediateCommitTare(Long ordNo, String tareInfo);

//  int updateCheckAfterWeight(Long ordNo, String mediInfo);

//  int updateMediInfo(Long ordNo, String mediInfo);

//  int updateDeviceSetInfo(Long ord_no, String deviceSetInfoJson);

//  int updateCancelSendCondition(Long ordNo, Timestamp timestamp);

//  int updatePatId(Long patId, Long ordNo, Timestamp update);

//  int updateRstDialysisCnt(Long ordNo, Long dialCount);

//  void updateScheduleAssignment(OrdMainUpdateForScheduleAssignment baseordMain, Timestamp update);

//  int updateDeleteByOrdNo(Long ordNo, Timestamp upDate);

//  int updateDeleteByPatId(Long pat_id);

  List<OrdMain> selectByPatId(Long patId);

//  int updateIsConfirm(Long ordNo, String updateTargetIsConfirm, String isConfirm);

//  int updateIndCondInfoWithTreatCondSetting(List<Long> ordNoList, String toAddTreatCond, List<String> toDeleteTreatCondList, Boolean isUpdateRst);

//  int updateIndCondInfoWithTreatMethodNonReplenish(List<Long> ordNoList, Boolean isUpdateReplenishLiquid);

//  int updateIndCondInfoWithTreatMethodReplenish(List<Long> ordNoList, Boolean isUpdateReplenishLiquid);

//  int updateIndCondInfoWithTreatMethodNonReplenishSup(List<Long> ordNoList, Boolean isUpdateReplenishLiquid, Long oldDeviceMode);

//  int updateIndCondInfoWithTreatMethodReplenishSup(List<Long> ordNoList, Boolean isUpdateReplenishLiquid, Long oldDeviceMode);
  List<OrdMain> selectByFacilityCdAndTreatDate(String facilityCd, String treatDate,Short treatWeek,Integer indKurCd,Integer indBedCd);

    List<OrdMain> selectByPatIdAndDeviceMode(String facilityCd,Long patId, Integer afbf);

  List<OrdMain> selectBySingleNeedle(String facilityCd, Long patId);

  OrdMainWeekPatternResponse updateWeekPatternInfo(ApiEntityOrdMain.ValiWeekPattern bodyData);

  OrdMain addIndUserAndUpdUserInfo(OrdMain ordMain, Long ind_user_id, Long upd_user_id);
  // add bug 7810 修正 start
  List<OrdMain> selectByAuxiliaryLiquidAndDeviceMode(String facilityCd, Long patId,List<Integer> deviceModeLiat,Double auxiliaryLiquid);
  List<OrdMain> selectByBloodFlowAndDeviceMode(String facilityCd, Long patId, Double dstBloodFlow);
  List<OrdMain> selectByDialysisFluidTemperatureAndDeviceMode(String facilityCd, Long patId, Double dstDialysisFluidTemperatureUp, Double dstDialysisFluidTemperatureDown);
  // add bug 7810 修正 end

  /* add by luchanghai  2023-02-01 [CodeOptimization]  start */
  List<String> getDuplicatedOrdList(String facilityCd, List<Long> ordNoList);
  boolean getPatSwitchFlag(String facilityCd, Long ordNo, String rstState);

  ResponseEntity<String> insertByOrdNo( ApiEntityOrdMain.ValiCreateTreatPlanByOrdNo bodyData, BindingResult validationResult ) throws ParseException;
  //mod #12462 患者共有情報- 患者カレンダー by zrx start
//  PatCalendarEvent selectPatCalendarFor3Months(String startDate, String endDate, String weekPattern, String facilityCd, Long patId);
  PatCalendarEvent selectPatCalendarFor3Months(String startDate, String endDate, String weekPattern, String facilityCd, Long patId, Integer patShareMode);
  //mod #12462 患者共有情報- 患者カレンダー by zrx end
  /* add by luchanghai  2023-02-01 [CodeOptimization]  end */
  // del 11454 時間外加算自動処理が機能していない zkm start
//  //add  6817 手動実績作成に失敗しても透析回数がカウントされてしまう 張 start
//    ResponseEntity<String> getStringResponseEntity(Long ord_no, Long patId) throws URISyntaxException;
//  //add  6817 手動実績作成に失敗しても透析回数がカウントされてしまう 張 end
  // del 11454 時間外加算自動処理が機能していない zkm end

  //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --start /
  int uptOrdMainInfoList(List<OrdMainEsListener> ordMainUptList);

  void batchUpdateOrdMainScheduleInfo(List<OrdMainUptSchInfoVo> ordMainUptSchInfoVoList);
  //upd by ztc 2023-03-20 Treatment method change branch 2, 3 optimization --end /
  //#8484　医療材料選択IFのリスト不正　Start
  // 選択肢マスタ(mst_selector)による部材コードの並び替え.
  List<Integer> getCodesOrderByMstSelector(String facility_cd, List<Integer> equip_cds, String equip_type);
  //#8484　医療材料選択IFのリスト不正　End
  // add 9200 by kangjie 20230912 start
  List<OrdMain> getOrdMainOfIndMediInfo(ApiEntityOrdMain.ValiIndMediInfoSearchCondition bodyData);
  // add 9200 by kangjie 20230912 end
  //add FNSI-9355 ljx start
  List<OrdMain> deepCopyList(List<OrdMain> targetList);
  //add FNSI-9355 ljx end
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
  InvokeResult<Map<String,List>> updatetByTreatSetCdOptimizeImpl(ApiEntityOrdMain.ValiCreateTreatPlan bodyData, NtssUser ntssUser, List<JournalCreateRequestPayload> ctlNoList, long mediInfoNo) throws Exception;
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  /**
   * ダミースケジュール再作成
   * @param facilityCd 施設コード
   * @param userId ユーザID
   * @param updUserId 更新者
   * @return
   * @throws Exception
   */
  //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
//  OrdMainForJournal updateIndScheduleOnceForAll(String facilityCd, Long userId, Long updUserId, String pcKey) throws Exception;
  OrdMainForJournal updateIndScheduleOnceForAll(String facilityCd, Long userId, Long updUserId, String pcKey, List<MstKur> oldMstKurList) throws Exception;
  //mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end
  //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
  List<OrdMainMedicineDelete> getPatIndMmdicine(OrdMainRequest ordMainRequest);

  List<OrdMainMedicineDelete> getPatIndAndRstMmdicine(OrdMainRequest ordMainRequest);
  //add 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end

  //add 9324 治療情報を異なる状態で変更した後のord _ checklistの再編成共通方法 gjn start
  /**
   * 治療情報を異なる状態で変更した後のord _ checklistの再編成共通方法
   *
   * @param ordMains
   * @param rstDialysisState
   * @param rstDialysisState
   */
  void makeOrdCheckListByOrdChange(OrdMainForCheckListSchedule ordMains, String rstDialysisState);

  void updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist action, List<Long> insOrdNo);
  //add 9324 治療情報を異なる状態で変更した後のord _ checklistの再編成共通方法 gjn end

  /* #10282 Create a new interface to synchronize processing progress. START */

  void initializeProcessCount(String facilityCd, String key);

  void setUpdKurProcess(String key, int process);
  /**
   * Retrieve the current processing progress from the global cache variables.
   *
   * @param key cache key
   * @return  current processing progress
   */
  OrdMainForJournal getUpdKurProcess(String key);

  void mainProcessHasFail(String key);

  boolean checkUpdKurProcessIsRunning(String facilityCd);
  /* #10282 Create a new interface to synchronize processing progress. END */

  // add 9664 by kangjie 20240425 start
  void updateNewSteps(String fluidJsonString,List<Long> ords);
  // add 9664 by kangjie 20240425 end

  // add 9664 by kangjie 20240513 start
  FutureOrdMainConditionInfo findFutureOrdMainConditionInfo(Long patId, String facilityCd, String treatDateFrom, String treatDateTo, List<Integer> weeks, List<Integer> treats, List<Long> kurs);
  // add 9664 by kangjie 20240513 end

  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
  int findByPatIdDateListCd(String facility_cd, Long pat_id, List<Map<String, String>> moveOutDateMapList);
  // add #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end

  // add 10443 身体情報・DW・目標体重バグ 関  start
  OrdMain getTreatDate(Long patId, String facilityCd, String treatDateFrom, List<Integer> weeks, List<Integer> treats, List<Long> kurs, boolean isIndFlag);
  // add 10443 身体情報・DW・目標体重バグ 関  end

  //add #11841 【たくしん会】ord_mainの登録不正 zrx start
  OrdMain delJSONKey(OrdMain ordMain);
  //add #11841 【たくしん会】ord_mainの登録不正 zrx end

  /**
   * 患者リスト用治療情報取得
   * @param facilityCd 施設コード
   * @param ordNoList オーダ番号リスト
   * @return 対象オーダー番号をキーにした治療情報のマップ
   */
  HashMap<String, OrdInfoListForPatListByOrdNoResponse> getOrdInfoListForPatListByOrdNo(String facilityCd, List<Long> ordNoList);
}
