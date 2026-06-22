package jp.co.nikkiso.ntss.api.service.conditionSend;


import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;

import java.util.List;
import java.util.Map;


/**
 * 条件送信3011のServiceインタフェース.
 */
public abstract interface ConditionSendResultUtilService {


  /**
   * 各名称取得用(一部コード)
   * @param ordNo オーダー番号
   * @return 名称
   *    key                 value
   *    ----------------+-------------
   *    pat_id              患者ID
   *    facility_cd         施設コード
   *    facility_name       施設名
   *    treatment_name      治療名
   *    kur_name            クール名
   *    bed_name            ベッド名
   *    machine_no          装置番号
   *    machine_name        装置名
   */
  public Map<String,Object> getNamesFromDbs(Long ordNo) ;


  /**
   * ord_main情報の取得
   * @param ord_no  オーダー番号
   */
  public OrdMain getOrdMainInfo(Long ord_no) ;
  /**
   * pat_main情報の取得
   * @param pat_id  患者ID
   */
  public PatMain getPatMainInfo(Long pat_id) ;
  /**
   * pat_unque情報の取得
   * @param pat_id  患者ID
   */
  public PatUnique getPatUniqueInfo(Long pat_id) ;
  /**
   * mnt_machine_state情報の取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   */
  public List<MntMachineState> getMntMachineStateInfo(
        String facilityCd,
        String machineTypeCd,
        String machineSerial
      ) ;

  /**
   * オフラインかどうかの確認
   * @param ord_no  オーダー番号
   * @return true:オンライン
   */
  public boolean checkOfflineOrNot(Long ord_no) ;

  /**
   * 治療方法が特殊浄化かどうかの確認
   * @param ord_no  オーダー番号
   * @return true:治療方法が特殊浄化
   */
  public boolean checkDeviceModeIsPureOrNot(Long ord_no) ;

  /**
   * 指定した患者の治療状況の確認
   *  実績:治療状況が、治療中以上かどうかの確認
   * @param ord_no  オーダ番号
   * @param facility_cd  施設コード
   * @return true:治療中以上
   */
  public boolean checkPatStatusNotUnderOperation(Long ord_no,String facility_cd) ;

  /**
   * 病棟名、診療科名の取得
   * @param facility_cd 施設コード
   * @param ward_cd     病棟コード
   * @param course_cd   診療科コード
   * @return 名称
   *    key                 value
   *    ----------------+-------------
   *    ward_name           病棟名
   *    course_name         診療科名
   */
  public Map<String,Object> getWardAndCourseName(
        String facility_cd,
        Integer ward_cd,
        Integer course_cd
      ) ;

  /**
   * ord_mainの更新処理
   * @param ordMain  ord_mainエンティティクラス
   * @return 更新件数
   */
  public int updateOrdMain(OrdMain ordMain) ;

  /**
   * mnt_machine_stateの更新処理
   * @param mntMachineState  mnt_machine_stateエンティティクラス
   * @return 更新件数
   */
  public int updateMntMachineState(MntMachineState mntMachineState) ;

  /*
   *    薬剤情報の取得
   * @param facility_cd     施設コード
   * @param medicine_type   薬剤区分
   * @param cd              薬剤(or 調整薬剤)コード
   */
  public Map<String,Object> getMedicineInfo(
        String facilityCd,
        Integer medicine_type,
        Integer cd
      );

  /**
   * 治療終了予定時刻の更新
   * @param ord_no  オーダー番号
   * @param facility_cd 施設コード
   * @param machine_type_cd 型式コード
   * @param machine_serial  製造番号
   * @return    更新件数
   */
  public int updateEndPlanDateOnMntMachineState(
      Long ord_no,
      String facility_cd,
      String machine_type_cd,
      String machine_serial
  ) ;

  /*
   *    投与タイミング名の取得
   * @param facility_cd     施設コード
   * @param timing_cd       投与タイミングコード
   */
  public String getTimingName(
        String facilityCd,
        Integer timing_cd
      );

  /*
   *    手技名の取得
   * @param facility_cd     施設コード
   * @param name_cd         手技コード
   */
  public String getProcedureName(
        String facilityCd,
        Integer procedure_cd
      );

  /*
   *    医療材料情報の取得
   * @param facility_cd     施設コード
   * @param cd              医療材料コード
   */
  public Map<String,Object> getEquipmentInfo(
         String facilityCd,
         Integer cd
      ) ;

  /*
   *    ダイアライザー情報(名称)の取得
   * @param facility_cd     施設コード
   * @param cd              ダイアライザコード
   * @return   key            value
   *            model_number    型番
   *            maker           メーカー名
   */
  public Map<String,Object> getDialyzerNames(
         String facilityCd,
         Integer cd
      ) ;

  /*
   *    医療材料情報またはVAの名称リストの取得
   * @param target          取得対象 "EQUIP":医療材料, "VA":VA
   * @param facility_cd     施設コード
   * @param cdList          コード(リスト)
   * @return mapリスト
   *           key            value
   *            cd    コード
   *            name  名称
   */
  public List<Map<String,Object>> getNameListWithCase(
        String target,
        String facilityCd,
        List<Integer> cdList
      ) ;
}
