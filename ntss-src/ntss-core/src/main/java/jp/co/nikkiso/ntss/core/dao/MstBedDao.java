package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstBedIndex;
import jp.co.nikkiso.ntss.core.entity.custom.BedMachine;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;
import java.util.Map;

@ConfigAutowireable
@Dao
public interface MstBedDao {
  @Select
  List<MstBed> selectAll(SelectOptions options);

  @Select
  List<MstBed> selectByFacilityCd(SelectOptions options, String facility_cd, String is_disp, String is_del);
// FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstBed> selectByFacilityCdDel(SelectOptions options, String facility_cd);
// FNSI-修正 マスタ削除の対応 chen add end

  @Select
  List<MstBed> selectByFacilityCd(String facility_cd, String is_disp, String is_del);

  @Select
  List<MstBed> selectByFacilityCdMachineNo(String facility_cd);

  @Select
  List<MstBed> selectBedListByFacilityCd(String facility_cd);

  /**
   * ベッドマスタ一覧取得(空きベッド検索)
   * @param facilityCd 検索施設コード
   * @param patId 検索対象外患者ID(ベッド割り当て予定の患者ID)
   * @param kurCd 検索クールコード
   * @param treatWeekList 検索曜日リスト
   * @param searchStartDate 検索開始日(形式:yyyyMMdd)
   * @param searchEndDate 検索終了日(形式:yyyyMMdd)
   * @param isAll 全ベッド取得フラグ(true:全ベッド取得、false:空きベッドのみ取得)
   * @param ms_max_treat 施設設定マスタに登録されている予定数しきい値
   * @param is_valid_period 指定された期間日数が施設設定：空きベッド候補切替指示期間(日)以上であるかを示すフラグ
   * @param indTreatmentCdList 更新対象治療方法リスト
   * @param indKurCdList 更新対象クールリスト
   * @return 検索にヒットしたスケジュールのリスト
   */
  //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 start
//   add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc start
//  @Select
////  List<MstBed> selectForSearchFreeBeds(String facilityCd, Long patId, Long kurCd, List<Integer> treatWeekList, String searchStartDate, String searchEndDate,
//  List<MstBedIndex> selectForSearchFreeBeds(String facilityCd, Long patId, Long kurCd, List<Integer> treatWeekList, String searchStartDate, String searchEndDate,
//// mod 7238 2023-03-29 予定コピー画面のベッドの並び順が不正 張 end
////mod 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
////     mod 5619 装置と紐づいていないベッドも表示 張 start
////      boolean isAll, Long ms_max_treat, boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList);
//                                            //boolean isAll, Long ms_max_treat, boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList,long init_bed_cd);
//                                            boolean isAll, Long ms_max_treat, boolean is_valid_period, List<Integer> indTreatmentCdList, List<Long> indKurCdList, long init_bed_cd, int searchCount, Boolean isInfiniteDate);
////  mod 5619 装置と紐づいていないベッドも表示 張 end
////mod 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
//// add 9077 施設設定マスタNo35,39の設定に基づいたベッドリストが生成されない。20230710 ztc end
  @Select
  List<MstBedIndex> selectForSearchFreeBeds(String facilityCd, Long patId, Long kurCd, List<Integer> treatWeekList, String searchStartDate, String searchEndDate,
                                            boolean isAll, Long ms_max_treat, List<Integer> indTreatmentCdList, List<Long> indKurCdList);
  //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
  @Select
  MstBed selectByBedCd(Long bed_cd, String is_disp, String is_del);

  /**
   * 装置から紐づいているベッドを取得する
   * @param facilityCd 施設コード
   * @param machineNo 装置番号
   * @return
   */
  @Select
  List<MstBed> selectByMachine(String facilityCd, Long machineNo);

  /**
   * 指定施設にて装置が割りついているベッド+装置情報の一覧を取得する
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<BedMachine> selectBedMachineByFacilityCd( String facilityCd );

  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
  @Select
  List<MstBed> selectAllByFacilityCd(String facility_cd);
  //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end

  // add 7686 修正 chen start
  @Select
  List<String> selectMstComsvBed(List<String> deviceEdgeNoList, String facilityCd);
  // add 7686 修正 chen end

  //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
  @Select
  int selectForSearchFreeBedsCount(String facilityCd, Long patId, String searchStartDate, String searchEndDate);
  //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 end

  @Select
  Map<String,Object> selectByJournal(String facilityCd, Long ordNo);

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  @Update(sqlFile = true)
  int updateMachineNoByBedCd(Long bedCd, Long machineNo);

  @Select
  List<MstBed> selectByMachineNo(Long machineNo);

  @Update(sqlFile = true)
  int updateMachineNoByMachineNo(Long machineNo);
  /* add by quzhinan  2023-02-01 [Trigger]  end */

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Select
  List<MstBed> selectByFacilityCdAndMachineNoList(String facilityCd, List<Long> machineNoList);
  //add #10412 次患者更新関連全体見直し対応 朴 end

}
