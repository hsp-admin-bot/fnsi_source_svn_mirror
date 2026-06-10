package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.job.MstJobRequest;
import jp.co.nikkiso.ntss.admin_web.request.mstInfo.MstInfoRequest;
import jp.co.nikkiso.ntss.admin_web.response.MedicineResponse;
import jp.co.nikkiso.ntss.admin_web.response.MedicineResponseExtends;
import jp.co.nikkiso.ntss.admin_web.response.mstDialyzer.DialyzerSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstEquipment.EquipmentSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicine.MedicineSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MedicineMixSharingInfoResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MstMedicineMixDto;
import jp.co.nikkiso.ntss.admin_web.response.sysFunction.SysFunctionResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityMstInfo;
import jp.co.nikkiso.ntss.core.dto.mstDisease.MstDiseaseCNF;
import jp.co.nikkiso.ntss.core.entity.MstAddMonitor;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstBbsKind;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstBedIndex;
import jp.co.nikkiso.ntss.core.entity.MstComFixedPhrase;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstDialyzerDto;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentDto;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentExtends;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentSet;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamMatome;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstFavoriteFacility;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineExtendsDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineGroup;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMixExtendsDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineSet;
import jp.co.nikkiso.ntss.core.entity.MstMenuGroup;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.MstPatCalendarLayout;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatListLayout;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.MstPatViewerLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.MstRelationship;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSeverity;
import jp.co.nikkiso.ntss.core.entity.MstSpitz;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstTakeMedicine;
import jp.co.nikkiso.ntss.core.entity.MstTransport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusDispItem;
import jp.co.nikkiso.ntss.core.entity.MstUrlLinkRegister;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyType;
import jp.co.nikkiso.ntss.core.entity.SysAddress;
import jp.co.nikkiso.ntss.core.entity.SysCountry;
import jp.co.nikkiso.ntss.core.entity.SysDataListCategory;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.SysFunctionAdvanced;
import jp.co.nikkiso.ntss.core.entity.SysGenericMedicine;
import jp.co.nikkiso.ntss.core.entity.SysSubscriptionPlan;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.HolidayDetail;
import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;

import java.util.List;
import java.util.Map;

/**
 * 各マスタ情報のServiceインターフェース
 */
public interface MstInfoService {
  /*
   * ベッドマスタ
   */
  Page<MstBed> findMstBedAll(Pageable pageable);

  Page<MstBed> findMstBedByFacilityCd(Pageable pageable, String facility_cd, String is_disp, String is_del);

// FNSI-修正 マスタ削除の対応 chen add start
  Page<MstBed> findMstBedByFacilityCdDel(Pageable pageable, String facility_cd);
// FNSI-修正 マスタ削除の対応 chen add end

  List<MstBed> findMstBedByFacilityCd(String facility_cd);
//add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
    List<MstBed> selectBedListByFacilityCd(String facility_cd);
//add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end

    String findBedNameByBedCd(Long bedCd);
  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
  String findBedNameByBedCdIncludeDel(Long bedCd);
  public List<MstBed> selectAllByFacilityCd(String facility_cd);
//add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
  /**
   * ベッドマスタ一覧取得(空きベッド検索)
   * @param facility_cd 検索施設コード
   * @param pat_id 検索対象外患者ID(ベッド割り当て予定の患者ID)
   * @param kur_cd 検索クールコード
   * @param treat_week_list 検索曜日リスト
   * @param search_start_date 検索開始日(形式:yyyyMMdd)
   * @param search_end_date 検索終了日(形式:yyyyMMdd)
   * @param is_all 全ベッド取得フラグ(true:全ベッド取得、false:空きベッドのみ取得)
   * @param ms_max_treat 施設設定マスタに登録されている予定数しきい値
   * @param is_valid_period 指定された期間日数が施設設定：空きベッド候補切替指示期間(日)以上であるかを示すフラグ
   * @param indTreatmentCdList 更新対象治療方法リスト
   * @param indKurCdList 更新対象クールリスト
   * @return 検索にヒットしたスケジュールのリスト
   */
  //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
//  List<MstBedIndex> selectForSearchFreeBeds(String facility_cd, Long pat_id, Long kur_cd, List<Integer> treat_week_list, String search_start_date, String search_end_date,
////mod 5619 装置と紐づいていないベッドも表示 張 start
//// add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc start
////      Boolean is_all, Long ms_max_treat, Boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList);
//      Boolean is_all, Long ms_max_treat, Boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList,Long init_bed_cd, Boolean is_infiniteDate);
//// add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc end
////  mod 5619 装置と紐づいていないベッドも表示 張 end
  List<MstBedIndex> selectForSearchFreeBeds(String facility_cd, Long pat_id, Long kur_cd, List<Integer> treat_week_list, String search_start_date, String search_end_date,
                                            Boolean is_all, Long ms_max_treat, List<Integer> indTreatmentCdList, List<Long> indKurCdList);
  //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
  /*
   * 共通定型文マスタ
   */
  Page<MstComFixedPhrase> findMstComFixedPhraseAll(Pageable pageable, MstComFixedPhrase params);
  Page<MstComFixedPhrase> findMstComFixedPhraseByJobCd(Pageable pageable, MstComFixedPhrase params, String JobCd);

  /*
   * 診療科マスタ
   */
  Page<MstCourse> findMstCourseAll(Pageable pageable, MstCourse params);

  Page<MstCourse> findMstCourseAllIncludDelete(Pageable pageable, MstCourse params);

  /*
   * 透析困難マスタ
   */
  Page<MstDialysisDifficulty> findMstDialysisDifficultyAll(Pageable pageable, MstDialysisDifficulty params);

  /*
   * ダイアライザマスタ
   */
  Page<MstDialyzer> findMstDialyzerAll(Pageable pageable, MstDialyzer params);

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
  List<MstDialyzerDto> findMstDialyzerTabooAllergy(String facilityCd, Long patId, String TreatDate, boolean... isDelFlg);
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  List<MstDialyzer> findMstDialyzerAllByFacillityCd(String facilityCd);
  //#8484　医療材料選択IFのリスト不正　Start
  List<MstDialyzer> findMstDialyzerTabooAllergyIncludeDeleted(String facilityCd, Long patId);
  //#8484　医療材料選択IFのリスト不正　End
// FNSI-修正 マスタ削除の対応 chen add start
  Page<MstDialyzer> findMstDialyzerAllNoDel(Pageable pageable, MstDialyzer params);
// FNSI-修正 マスタ削除の対応 chen add end

  /**
   * コードでダイアライザマスタを取得する
   * @param dialyzerCd
   * @return
   */
  MstDialyzer findMstDialyzerByCd(String dialyzerCd);

  /*
   * ダイアライザマスタ（削除済のデータも含む）
   */
  //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
  Page<MstDialyzer> findMstDialyzerAllIncludeDeleted(Pageable pageable, MstDialyzer params);
  //#8484　医療材料選択IFのリスト不正(#9978対応)　End
  /*
   * 病名マスタ
   */
  Page<MstDisease> findMstDiseaseAll(Pageable pageable, MstDisease params);

  /*
   * 病名マスタ（削除済み含む）
   */
  Page<MstDisease> findMstDiseaseAllIncludeDeleted(Pageable pageable, MstDisease params);

  /* add #9482 患者情報画面/新規患者登録の表示が遅い。2023-09-21 by liumx --start */
  /*
   * 病名取得
   */
  List<MstDisease> getMstDiseaseByCds(Integer[] diseaseCds);
  /* add #9482 患者情報画面/新規患者登録の表示が遅い。2023-09-21 by liumx --end */

  /*
   * 医療材料分類マスタ
   */
  Page<MstEquipmentClass> findMstEquipmentClassAll(Pageable pageable, MstEquipmentClass params);

  /*
   * 医療材料分類マスタ（削除済のデータも含む）
   */
  Page<MstEquipmentClass> findMstEquipmentClassAllIncludeDeleted(Pageable pageable, MstEquipmentClass params);

  /*
   * 医療材料マスタ
   */
  Page<MstEquipment> findMstEquipmentAll(Pageable pageable, MstEquipment params);

// FNSI-修正 マスタ削除の対応 chen add start
  /*
   * 医療材料マスタ
   */
  Page<MstEquipment> findMstEquipmentAllNoDel(Pageable pageable, MstEquipment params);
// FNSI-修正 マスタ削除の対応 chen add end

  /**
   * コードで医療材料マスタを取得する
   */
  MstEquipment findMstEquipmentByCd(String equipmentCd);
  /**
   * 施設コードに該当する医療材料を禁忌・アレルギー情報つきで取得.
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param typeCdList 取得する医療材料分類リスト
   * @return
   */
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  // List<MstEquipment> findMstEquipmentTabooAllergy(String facilityCd, Long patId, List<Integer> typeCdList);
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
  List<MstEquipmentDto> findMstEquipmentTabooAllergy(String facilityCd, Long patId, List<Integer> typeCdList, String TreatDate, boolean... isDelFlg);
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  //#8484　医療材料選択IFのリスト不正　Start
  // 対象患者の禁忌・アレルギー情報を含めた 医療材料マスタ一覧(削除済み・期限切れを含む)を取得
  List<MstEquipment> findMstEquipmentTabooAllergyIncludeDeleted(String facilityCd, Long patId, List<Integer> typeCdList, boolean... isDelFlg);
  //#8484　医療材料選択IFのリスト不正　End
  /*
   * 医療材料マスタ（削除済のデータも含む）
   */
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240909 start
  //#8484　医療材料選択IFのリスト不正(#9978対応)　Start
  Page<MstEquipmentExtends> findMstEquipmentAllIncludeDeleted(Pageable pageable, MstEquipment params);
  //#8484　医療材料選択IFのリスト不正(#9978対応)　End
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240909 end
  /*
   * 医療材料セットマスタ
   */
  Page<MstEquipmentSet> findMstEquipmentSetAll(Pageable pageable, MstEquipmentSet params);
  /*
   * 医療材料セットマスタ(禁忌・アレルギー情報込み)
   */
  List<MstEquipmentSet> findMstEquipmentSetAllTabooAllergy(String facilityCd, Long patId);

  /*
   * マスタ削除の対応 医療材料セットマスタ(禁忌・アレルギー情報込み)
   */
  List<MstEquipmentSet> findMstEquipmentSetWithDeleted(String facilityCd, Long patId);

  /*
   * 施設マスタ
   */
  Page<MstFacility> findMstFacilityAll(Pageable pageable);
  MstFacility findMstFacilityByCd(String facility_cd);
  void saveMstFacility(Map<String, List<String>> payload, NtssUser ntssUser) throws Exception;
  Page<MstFacility> findMstFacilityAllWithoutCancelFacilities(Pageable pageable);

  /*
   * インプラントマスタ
   */
  Page<MstImplant> findMstImplantAll(Pageable pageable, MstImplant params);

  /*add FNSI-改修内容5237 任 start*/
  Page<MstImplant> findMstImplantDelAll(Pageable pageable, MstImplant params);
  /*add FNSI-改修内容5237 任 end*/
  /*
   * インプラントマスタ
   */
  Page<MstImplant> findMstImplantAllIncludeDel(Pageable pageable, MstImplant params);

  /**
   * コードでインプラント名を取得する
   */
  List<MstImplant> findMstImplantNameByCdList(List<Integer> implantCdList);
  /*
   * 感染症マスタ
   */
  Page<MstInfection> findMstInfectionAll(Pageable pageable, MstInfection params);
  /*
   * 感染症マスタ（削除済み含む）
   */
  List<MstInfection> findMstInfectionAllIncludeDel(String facilityCd);
  /*
   * クールマスタ
   */
  Page<MstKur> findMstKurAll(Pageable pageable);

  Page<MstKur> findMstKurByFacilityCd(Pageable pageable, String facility_cd, String is_del);

// FNSI-修正 マスタ削除の対応 chen add start
  Page<MstKur> findMstKurByFacilityCdDel(Pageable pageable, String facility_cd);
// FNSI-修正 マスタ削除の対応 chen add end

  /**
   * クールコードでクール名を検索
   */
  String findKurNameByKurCd(String kurCd);

  List<MstKur> saveMstKur(String facility_cd,  Map<String, List<String>> payload) throws Exception ;

  /**
   * 常勤医設定変更
   * @param mstKur
   * @return
   */
  int saveDoctorMstKur(MstKur mstKur);

  void saveMstSelector(String facility_cd,  Map<String, String> payload) throws Exception ;

  /*
   * 投与タイミングマスタ
   */
  Page<MstMedicateTiming> findMstMedicateTimingAll(Pageable pageable, MstMedicateTiming params);
  // FNSI-修正 マスタ削除の対応 chen add start
  /*
   * 投与タイミングマスタ
   */
  Page<MstMedicateTiming> findMstMedicateTimingIncludeDeleted(Pageable pageable, MstMedicateTiming params);
// FNSI-修正 マスタ削除の対応 chen add end

  /*
   * 薬剤分類マスタ
   */
  Page<MstMedicineClass> findMstMedicineClassAll(Pageable pageable, MstMedicineClass params);

  /*
   * 薬剤分類マスタ（削除済のデータも含む）
   */
  Page<MstMedicineClass> findMstMedicineClassAllIncludeDeleted(Pageable pageable, MstMedicineClass params);

  /*
   * 薬剤マスタ
   */
  Page<MstMedicine> findMstMedicineAll(Pageable pageable, MstMedicine params);
// FNSI-修正 マスタ削除の対応 chen add start
  /*
   * 薬剤マスタ
   */
  MstMedicine findMstMedicineByCd(MstMedicine params);
// FNSI-修正 マスタ削除の対応 chen add end

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /* modify by chamaojia 2024-02-28 [10196] Add interface parameter 'selectMedicineCd' --start */
  // add FNSI-期限切れ削除済みと表示するの修正 start
  List<MstMedicineDto> findMstMedicineTabooAllergy(String facilityCd, Long PatId, Integer selectMedicineCd, boolean... isDelFlg);
  // add FNSI-期限切れ削除済みと表示するの修正 end
  /* modify by chamaojia 2024-02-28 [10196] Add interface parameter 'selectMedicineCd' --end */
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  /**
   * コードで薬剤を検索
   */
  MstMedicine findMstMedicineByCd(String medicineCd);

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /*
   * 薬剤マスタ（削除済のデータも含む）
   */
  Page<MstMedicineExtendsDto> findMstMedicineAllIncludeDeleted(Pageable pageable, MstMedicine params);
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  /*
   * 薬剤セットマスタ
   */
  Page<MstMedicineSet> findMstMedicineSetAll(Pageable pageable, MstMedicineSet params);

  /*
   * 一般名処方マスタ
   */
  Page<SysGenericMedicine> findSysGenericMedicineAll(Pageable pageable);

  /*
   * 一般名処方マスタ（削除済のデータも含む）
   */
  Page<SysGenericMedicine> findSysGenericMedicineAllIncludeDeleted(Pageable pageable);

  /*
   * 薬剤グループマスタ
   */
  Page<MstMedicineGroup> findMstMedicineGroupAll(Pageable pageable, MstMedicineGroup params);


  // add 投薬支援マスタ 削除されたデータの処理 孔 start
  /*
   * 薬剤グループマスタ（削除済のデータも含む）
   */
  Page<MstMedicineGroup> findMstMedicineGroupAllIncludeDeleted(Pageable pageable, MstMedicineGroup params);
  // add 投薬支援マスタ 削除されたデータの処理 孔 end

  /*
   * 薬剤セットマスタ(禁忌・アレルギー情報込み)
   */
  List<MstMedicineSet> findMstMedicineSetAllTabooAllergy(String facilityCd, Long PatId);

  // FNSI-修正 マスタ削除の対応 wangchen add start
  List<MstMedicineSet> findMstMedicineSetWithDeleted(String facilityCd, Long PatId);
  // FNSI-修正 マスタ削除の対応 wangchen add end

  /*
   * 患者カレンダーレイアウトマスタ
   */
  Page<MstPatCalendarLayout> findMstPatCalendarLayoutAll(Pageable pageable, MstPatCalendarLayout params);

  /*
   * マルチ患者一覧レイアウトマスタ
   */
  Page<MstPatListLayout> findMstPatListLayoutAll(Pageable pageable, MstPatListLayout params);

  @Transactional
  void updateMstPatListLayoutByCd(long pat_list_layout_cd, String payload) throws Exception ;

  /*
   * 患者メモマスタ
   */
  Page<MstPatMemo> findMstPatMemoAll(Pageable pageable, MstPatMemo params);

  /**
   * 患者経過総合ビューアレイアウトマスタ情報を取得する.
   * ※params内に取得する対象の施設コードが設定されている事.
   *
   * @param pageable ページネーション
   * @param params 患者経過総合ビューアレイアウトマスタのエンティティ
   * @return 施設コードに該当する患者経過総合ビューアレイアウトマスタのリスト
   */
  Page<MstPatViewerLayout> findMstPatViewerLayoutAll(Pageable pageable, MstPatViewerLayout params);

  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
  /**
   * 患者経過総合ビューアレイアウトマスタのバイタル・モニタグラフの選択肢を取得する.
   *
   * @param facilityCd 施設コード
   * @param vitalMonitorClass バイタル・モニタクラス
   * @param isAllDisp 全表示フラグ
   * @return バイタル・モニタグラフの選択肢リスト
   */
  List<MstPatViewerLayoutMonitorItem> selectMonitorItemForMstPatViewerLayout(String facilityCd, String vitalMonitorClass, String isAllDisp);
  /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */

  /*
   * 手技マスタ
   */
  Page<MstProcedure> findMstProcedureAll(Pageable pageable, MstProcedure params);

  /*
   * 手技マスタ（削除済み含む）
   */
  Page<MstProcedure> findMstProcedureAllIncludeDeleted(Pageable pageable, MstProcedure params);

  /*
   * 続柄マスタ
   */
  Page<MstRelationship> findMstRelationshipAll(Pageable pageable, MstRelationship params);

  Page<MstRelationship> findMstRelationshipAllIncludeDel(Pageable pageable, MstRelationship params);

  /*
   * 透析室・ベッドグループマスタ
   */
  Page<MstRoomBedGroup> findMstRoomBedGroupAll(Pageable pageable, MstRoomBedGroup params);

  /*
   * 重症度マスタ
   */
  Page<MstSeverity> findMstSeverityAll(Pageable pageable, MstSeverity params);

  /*
   * 重症度マスタ,包含删除
   */
  Page<MstSeverity> findMstSeverityAllIncludeDel(Pageable pageable, MstSeverity params);

  /*
   * 禁忌・アレルギーマスタ
   */
  Page<MstTabooAllergy> findMstTabooAllergyAll(Pageable pageable, MstTabooAllergy params);

  /*
   * 禁忌・アレルギーマスタ（削除済のデータも含む）
   */
  Page<MstTabooAllergy> findMstTabooAllergyAllIncludeDeleted(Pageable pageable, MstTabooAllergy params);

  /*
   * 搬送区分マスタ
   */
  Page<MstTransport> findMstTransportAll(Pageable pageable, MstTransport params);

// add FutreNetWeb+SI課題管理No4770対応 趙 start
  /*
   * 検査セットマスタ
   */
  Page<MstExamSet> findMstExamAll(Pageable pageable, MstExamSet params);
// add FutreNetWeb+SI課題管理No4770対応 趙 end

  /**
   * 搬送区分マスタ取得，包含删除
   * @param pageable
   * @param params
   * @return
   */
  Page<MstTransport> findMstTransportAllIncludeDel(Pageable pageable, MstTransport params);

  /*
   * 治療方法マスタ
   */
  Page<MstTreatment> findMstTreatmentAll(Pageable pageable, MstTreatment params);

// FNSI-修正 マスタ削除の対応 chen add start
  /*
   * 治療方法マスタ
   */
  Page<MstTreatment> findMstTreatmentAllDel(Pageable pageable, MstTreatment params);
// FNSI-修正 マスタ削除の対応 chen add end

  /*
   * 治療方法マスタ（削除済のデータも含む）
   */
  Page<MstTreatment> findMstTreatmentAllIncludeDeleted(Pageable pageable, MstTreatment params);

  /**
   * 治療マスタを取得する
   */
  String findMstTreatmentNameByCd(Integer treatmentCd);

  List<MstTreatment> findMstTreatmentList(MstTreatment params);

  /*
   * 治療方法セットマスタ
   */
  Page<MstTreatmentSet> findMstTreatmentSetAll(Pageable pageable, MstTreatmentSet params);

  List<MstTreatmentSet> findMstTreatmentSetByCd(Integer treatment_set_cd);

  /*
   * 利用者マスタ
   */
  Page<MstPersonalUser> findMstPersonalUserAll(Pageable pageable, String facility_cd);

  /*
   * 利用者マスタ,包含删除
   */
  Page<MstPersonalUser> findMstPersonalUserAllIncludeDel(Pageable pageable, String facility_cd);

  /*
   * 利用者マスタ,有効利用者
   */
  Page<MstPersonalUser> findMstPersonalUserInUse(Pageable pageable, String facility_cd);


  /**
   * 利用者マスタ(個人情報DB)を取得する
   */
  List<MstPersonalUser> getMstPersonalUserNameByIdList(List<Long> listUserId);

  /*
   * VAマスタ
   */
  Page<MstVa> findMstVaAll(Pageable pageable, MstVa params);

// FNSI-修正 マスタ削除の対応 chen add start
  /*
   * VAマスタ
   */
  Page<MstVa> findMstVaAllNoDel(Pageable pageable, MstVa params);
// FNSI-修正 マスタ削除の対応 chen add end

  /*
   * VAマスタ（削除済み含む）
   */
  List<MstVa> findMstVaAllIncludeDel(String facilityCd);

  /*
   * 病棟マスタ
   */
  Page<MstWard> findMstWardAll(Pageable pageable, MstWard params);

  /*
   * 病棟マスタ
   */
  Page<MstWard> findMstWardAllIncludeDel(Pageable pageable, MstWard params);

  /*
   * 住所マスタ
   */
  Page<SysAddress> findSysAddressAll(Pageable pageable, SysAddress params);

  /*
   * 国名マスタ
   */
  Page<SysCountry> findSysCountryAll(Pageable pageable);

  /*
   * デバイスエッジマスタ
   */
  void saveMstDeviceEdge(Map<String, List<String>> payload) throws Exception;

  /*
   * システム設定
   */
  List<SysSystemDefine> findSysSystemDefineByCtlNo(Integer ctl_no);

  /*
   * 機能一覧マスタ
   */
  Page<SysFunction> findSysFunction(Pageable pageable, SysFunction param);
  Page<SysFunction> findSysFunctionDispOnly(Pageable pageable, SysFunction param);
  List<SysFunction> findSysFunctionDispOnlyNoPaging();
  List<SysFunction> findSelectByDelAndDisp();
  /*
   * 職種マスタ
   */
  Page<MstJob> findMstJobByCd(Pageable pageable, MstJob params);
  List<MstJob> findMstJobByFacilityCd(String facilityCd);
  void saveMstJob(Map<String, List<String>> payload) throws Exception;
  void updMstJobAuthorities(List<MstJobRequest> payload, NtssUser ntssUser) throws Exception;

  /*
   * 選択肢マスタ(マスタ名指定)
   */
  MstSelector findMstSelectorByMstName(String facilityCd, String masterName);
  /*
   * 選択肢マスタ(マスタ名指定)
   * 施設は開示先施設
   */
  List<MstSelector> findMstSelectListByMstName(String facilityCd, String masterName);

  /*
   * 掲示板種別マスタ
   */
  Page<MstBbsKind> findMstBbsKindByFacilityCd(Pageable pageable, MstBbsKind params);
// add マスタ削除 対応 chen start
  /*
   * 掲示板種別マスタ
   */
  List<MstBbsKind> findMstBbsKindAll(MstBbsKind params);
// add マスタ削除 対応 chen end
  /*
   * 掲示板種別マスタ（削除済み含む）
   */
  List<MstBbsKind> findMstBbsKindIncludeDeleted(MstBbsKind params);

  /*
   * 観察記録種別マスタ
   */
  Page<MstObsKind> selectMstObsKindByFacilityCd(Pageable pageable, MstObsKind params);

  /*
   * 調製薬剤マスタ
   */
  Page<MstMedicineMix> findMstMedicineMixAll(Pageable pageable, MstMedicineMix params);

// FNSI-修正 マスタ削除の対応 chen add start
  /*
   * 調製薬剤マスタ
   */
  MstMedicineMix findMstMedicineMixByCdNoDel(MstMedicineMix params);
// FNSI-修正 マスタ削除の対応 chen add end
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /* modify by chamaojia 2024-02-28 [10196] Add interface parameter 'selectMedicineCd' --start */
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
  List<MstMedicineMixDto> findMstMedicineMixTabooAllergy(String facilityCd, Long PatId, Integer selectMedicineCd, boolean... isDelFlg);
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
  /* modify by chamaojia 2024-02-28 [10196] Add interface parameter 'selectMedicineCd' --end */
  /**
   * 調製薬剤マスタ
   * 引数の調製薬剤マスタのリストに、それぞれの配下の薬剤の使用開始日の最大値、使用終了日の最小値を追加する
   *
   * @param mstMedicineMixList 調製薬剤マスタのリスト
   * @param facilityCd 施設コード
   * @param PatId 患者ID
   * @return 使用開始日の最大値、使用終了日の最小値を追加した調製薬剤マスタのリスト
   */
  List<MstMedicineMixDto> mstMedicineMixAddTerm(List<MstMedicineMixDto> mstMedicineMixList, String facilityCd, Long PatId);
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end
  /**
   * コードで調製薬剤マスタを取得する
   */
  MstMedicineMix findMstMedicineMixByCd(String medicineMixCd);

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /**
   * 調製薬剤マスタ（削除済のデータも含む）
   */
  Page<MstMedicineMixExtendsDto> findMstMedicineMixAllIncludeDeleted(Pageable pageable, MstMedicineMix params);
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  /*
   * 検査項目マスタ
   */
  Page<MstExamItem> selectMstExamItemByFacilityCd(Pageable pageable, MstExamItem params);
  List<MstExamItem> findExamItemListForExamCalc(String facilityCd);
  // #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
  List<MstSelector> findMstExamItemForComsvByFacilityCd(String facilityCd);
  // #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end

  /*
   * 採血管マスタ
   */
  Page<MstSpitz> selectMstSpitzByFacilityCd(Pageable pageable, MstSpitz params);

  /*
   * 放射線検査セットマスタ
   * マスタメンテナンスでの並び順で並び替え
   */
  Page<MstRadSet> selectMstRadSetByFacilityCd(Pageable pageable, MstRadSet params);

  /*
   * 加算マスタ
   * マスタメンテナンスでの並び順で並び替え
   */
  Page<MstAddition> findMstAdditionByFacilityCd(Pageable pageable, MstAddition params);

  /*
   * 施設マスタのパラメータ指定による検索
   */
  List<SysFacility> findBySearchConditions(String prefecturesCd, String keyword, Integer limit, Integer page);

  /*
   * よく使う施設マスタ
   * マスタメンテナンスでの並び順で並び替え
   */
  Page<MstFavoriteFacility> selectMstFavoriteFacilityByFacilityCd(Pageable pageable, String facilityCd);

  /*
   * 全施設マスタ
   */
  void saveSysFacility(Map<String, List<String>> payload) throws Exception;

  /**
   * 与えられた施設コード及びバイタル・モニタ区分に該当する {@link MstAddMonitor} のリストを取得.
   * 該当するデータがない場合、空のリストを返す.
   *
   * @param facilityCd 施設コード
   * @param vitalMonitorClass バイタル・モニタ区分
   * @return {@link MstAddMonitor}のリスト
   */
  List<MstAddMonitor> selectMstAddMonitorByVitalMonitorClass(String facilityCd, String vitalMonitorClass);

  /**
   * 与えらた施設に該当する {@link MstAddMonitor} のリストを取得.
   * 該当するデータがない場合、空のリストを返す.
   *
   * @param facilityCd 施設コード
   * @return 該当する {@link MstAddMonitor} のリスト
   */
  List<MstAddMonitor> selectMstAddMonitorByFacilityCd(String facilityCd);

  /**
   * 与えられたバイタル・モニタ項目コードに該当する {@link MstAddMonitor} を取得.
   * 該当するデータがない場合、nullを返す.
   *
   * @param vitalMonitorItemCd バイタル・モニタ項目コード
   * @return 該当する {@link MstAddMonitor}
   */
  MstAddMonitor selectMstAddMonitorByCd(Long vitalMonitorItemCd);

  /**
   * 施設コードに該当する通常薬剤、調整薬剤を取得.
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @return
   */
  List<MedicineResponse> selectMedicineAllWithMix(Pageable pageable, String facilityCd);

  /**
   * 施設コードに該当する患者イベントのサブカテゴリを取得する.
   *
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @return 施設コードに該当する患者イベントのサブカテゴリのリスト
   */
  List<MstPatEventSubCategory> selectPatEventSubCategory(Pageable pageable, String facilityCd);

  /**
   * 施設コードに該当する患者イベントのサブカテゴリを取得する（削除済み含む）.
   *
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @return 施設コードに該当する患者イベントのサブカテゴリのリスト
   */
  List<MstPatEventSubCategory> selectPatEventSubCategoryIncludeDeleted(Pageable pageable, String facilityCd);

  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 start
  /**
   * 施設コードに該当する通常薬剤、調整薬剤を禁忌・アレルギー情報つきで取得.
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param classType 取得する分類区分 -1：すべて、0：該当なし、1：抗凝固剤、2：透析液、3：補液
   * @return
   */
  List<MedicineResponseExtends> selectMedicineAllTabooAllergyWithMix(Pageable pageable, String facilityCd, Long patId, Integer classType);
  //mod #10659 【00】禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 zhaoqi 20240703 end

  /**
   * 水質検査箇所マスタ.
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @return
   */
  List<WaterSurveyPoint> selectALLWaterSurveyPoint(Pageable pageable, String facilityCd);

  /**
   * 水質検査箇所マスタ.
   * @param surveyPointCd 調査箇所コード
   * @return
   */
  WaterSurveyPoint selectWaterSurveyPointByCd(Long surveyPointCd);

  /**
   * 施設カレンダーレイアウトマスタ.
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @return
   */

  Page<MstFacilityCalendarLayout> findMstFacilityCalendarLayoutAll(Pageable pageable, String facilityCd);

  /**
   * 水質検査種別マスタ.
   * @param pageable ページネーション
   * @param facilityCd 施設コード
   * @return
   */
  List<MstWaterSurveyType> selectALLWaterSurveyType(Pageable pageable, String facilityCd);
  /**
   * 水質検査種別マスタ.
   * @param surveyTypeCd 水質検査種別コード
   * @return
   */
  MstWaterSurveyType selectWaterSurveyTypeByCd(Long surveyTypeCd);

  /**
   * 施設マスタ を施設カナ名の昇順で取得する.
   *
   * @param pageable ページネーション
   * @return 施設マスタのリスト
   */
  Page<MstFacility> findMstFacilitySortByKana(Pageable pageable);

  /**
   * 施設コード="nkknkk"の対象年の休日マスタを{@link HolidayDetail}のリストで取得する.
   *
   * @param holidayY 対象年
   * @return {@link HolidayDetail}のリスト
   */
  List<HolidayDetail> selectMstHolidayByNkk(Integer holidayY);

  /**
   * 拡張機能取を取得.
   * @return
   */
  List<SysFunctionAdvanced> selectAllSysFunctionAdvanceds();

  /**
   * 外部リンク登録マスタを取得する
   * @param facilityCd 施設コード
   * @return 外部リンクリスト
   */
  List<MstUrlLinkRegister> selectAllMstUrlLinkRegister(String facilityCd);

  /**
   * メニューグループマスタを取得する
   * @param facilityCd 施設コード
   * @return メニューグループリスト
   */
  List<MstMenuGroup> selectAllMstMenuGroup(String facilityCd);

  /**
   * 職種マスタを取得する
   * @param facilityCd 施設コード
   * @return 職種リスト
   */
  List<MstJob> selectAllMstJob(String facilityCd);

  /**
   * すべての装置マスタを取得する
   * @param facilityCd 施設コード
   * @return 装置マスタリスト
   */
  List<MstMachine> selectAllMstMachine(String facilityCd);

  /**
   * 指定CDの警報通知マスタレコードを取得する
   * @param alarm_notification_cd 警報通知コード
   * @return 警報通知マスタレコード
   */
  MstAlarmNotification findAlarmNotificationDetail(Long alarmNotificationCd);

  /**
   * 施設コードですべての機能を取得.
   * @return
   */
  List<SysFunctionResponse> findSysFuncAdvAndSysFuncByFacilityCd(String facilityCd);

  /**
   * プラン定義を検索
   * @return
   */
  Page<SysSubscriptionPlan> findSysSubscriptionPlan(Pageable pageable);

    /**
     * 用法・用語マスタ取得する.
     *
     * @param listClass
     *            リスト分類
     * @param facilityCd
     *            施設コード
     * @return 用法・用語マスタ
     */
    public List<MstTakeMedicine> getTakeMedicine(String listClass, String facilityCd);

  /**
   * 連携施設を取得.
   * @param facilityCd 施設コード
   * @return 連携施設マスタ
   */
  MstCoopFacility getMstCoopFacility(String facilityCd);

  /**
   * テンプレートコードによりデータリストカテゴリ配列を取得
   * @param templateCd テンプレートコード
   * @return データリストカテゴリ配列
   */
  List<SysDataListCategory> findSysDataListCategoryByTemplateCd(Integer templateCd);

  /**
   *  ログ条件用の機能リストを取得
   * @return
   */
  List<SysFunction> findSysFunctionForLogCondition();

  /*
   * 検査まとめ表
   * @return
   */
  Page<MstExamMatome> findmstExamMatomeAll();

  /**
   * 連携エッジマスタ情報を取得.
   * @param facilityCd 施設コード
   * @return 連携エッジマスタ情報
   */
  List<MstIfEdge> getMstIfEdgeByFacilityCd(String facilityCd);

  /**
   * 連携エッジマスタ情報保存
   * @param mstIfEdge
   * @return
   */
  boolean submitMstIfEdge(MstIfEdge mstIfEdge);

  /*add FNSI-改修内容5204 任 start*/
  Page<MstMedicine> findMstMedicineUnit(Pageable pageable, MstMedicine params);

  Page<MstMedicineMix> findMstMedicineMixUnit(Pageable pageable, MstMedicineMix params);

  Page<MstEquipment> findMstEquipmentUnit(Pageable pageable, MstEquipment params);
  /*add FNSI-改修内容5204 任 end*/

  /*add by yuyifu 2023-01-31 [CodeOptimization] start*/
  /**
   * @param medicineMixCd medicineMixCd
   * @param patId         patId
   * @return result
   */
  MedicineMixSharingInfoResponse getMstMedicineMixSharingInfoByCd(String medicineMixCd, Long patId);
  /*add by yuyifu 2023-01-31 [CodeOptimization] end*/

  /* add by biangang  2023-01-31 CodeOptimization  start */

  /**
   * ベッドマスタ一覧取得(空きベッド検索)
   *
   * @param bodyData         bodyData
   * @param validationResult validationResult
   * @return 正常終了:検索にヒットしたスケジュールのリスト、異常終了:null
   */
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 start
//  ResponseEntity<List<MstBed>> getSelectForSearchFreeBeds(ApiEntityMstInfo.ValiSearchFreeBeds bodyData
  ResponseEntity<List<MstBedIndex>> getSelectForSearchFreeBeds(ApiEntityMstInfo.ValiSearchFreeBeds bodyData
    , BindingResult validationResult);
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 end
  /* add by biangang  2023-01-31 CodeOptimization  end */

  /* add by biangang  2023-01-31 CodeOptimization  start */

  /**
   * ダイアライザー名を取得
   */
  ResponseEntity<DialyzerSharingInfoResponse> getMstDialyzerSharingInfoByCd(String dialyzerCd,
                                                                                   Long patId);
  /* add by biangang  2023-01-31 CodeOptimization  end */

  /* add by biangang  2023-02-01 CodeOptimization  start */

  /**
   * コードで機器を入手する
   */
  ResponseEntity<EquipmentSharingInfoResponse> getMstEquipmentSharingInfoByCd(String equipmentCd,
                                                                                     Long patId);
  /* add by biangang  2023-02-01 CodeOptimization  end */

  /* add by biangang  2023-02-01 CodeOptimization  start */

  /**
   * コードで薬を手に入れる
   */
  ResponseEntity<MedicineSharingInfoResponse> getMstMedicineSharingInfoByCd(String medicineCd,
                                                                                   Long patId);
  /* add by biangang  2023-02-01 CodeOptimization  end */

  //add #10236 api要求をマージして、ブラウザ要求スレッドのスタックをできるだけ減らす shiyw start
  Map<String, Object> getMstInfo(MstInfoRequest mstInfoRequest);
  //add #10236 api要求をマージして、ブラウザ要求スレッドのスタックをできるだけ減らす shiyw end

  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
  Map<String, Object> getMstInfoByOrdNo(List<Long> ordNoList);
  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

  /**
   * 削除を除く治療状況レイアウト表示項目マスタを取得する.
   * 該当データがない場合、空のリストを返却する.
   *
   * @return 治療状況レイアウト表示項目マスタのリスト
   */
  List<MstTreatmentStatusDispItem> getMstTreatmentStatusDispItemAll();
  //add #12462 患者情報共有- 患者カレンダー zrx start
  Map<String, Object> getShrMstInfoByPatId(MstInfoRequest mstInfoRequest);
  //add #12462 患者情報共有- 患者カレンダー zrx end
}
