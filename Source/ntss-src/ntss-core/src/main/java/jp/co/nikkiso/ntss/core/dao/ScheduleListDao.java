package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;



@ConfigAutowireable
@Dao
public interface ScheduleListDao {

  @Select
    // #10061
//  List<Map<String,Object>> selectBedListMain(String facilityCd,List<String> treatDateList);
  List<Map<String,Object>> selectBedListMain(String facilityCd, String startDate, String endDate);
  @Select
    // #10061
//  List<Map<String,Object>> selectBedListNotYet(String facilityCd,List<String> treatDateList);
  List<Map<String,Object>> selectBedListNotYet(String facilityCd, String startDate, String endDate);
  // #10061
  @Select
//  List<Map<String,Object>> selectBedListKurNotYet(String facilityCd,List<String> treatDateList);
  List<Map<String,Object>> selectBedListKurNotYet(String facilityCd, String startDate, String endDate);
  @Select
  List<MstKur> selectKurNameList(String facilityCd);
  @Select
  List<MstRoomBedGroup> selectRoomBedList(String facilityCd);
  @Select
  List<Map<String,Object>> selectBedMaxCount(String facilityCd);
  @Select
  List<Map<String,Object>> selectPatInfoForCheck(Long ordNo);
  //  add by ShiHongda 2023-02-08 [optimize] --start /
  @Select
  List<Map<String,Object>> selectPatInfoForListCheck(List<Long> ordNoList);
  //  add by ShiHongda 2023-02-08 [optimize] --end /
  @Select
  Boolean checkSamePatDayKurMode(Long ordNo,String treatDate,Long kurCd);
  // mod #11493 スケジュール表　更新不正 関 start
  @Select
  Boolean checkPatExistance(Long ordNo,String treatDate,Long kurCd,Long bedCd, String dialysisState, String isDummy);
  // mod #11493 スケジュール表　更新不正 関 end
  @Update(sqlFile = true)
  int updateScheduleListData(
      Long ordNo,               //条件:オーダー番号
      String condTreatDate,     //条件:治療日
      String facilityCd,        //条件:施設コード
      String newTreatDate,      //更新対象:治療日
      Long kurCd,               //更新対象:クールコード
      Long bedCd                //更新対象:ベッドコード
    );

  /**
   * ベッド移動時のデータ更新(メインスケジュール)
   * 治療状況は0(条件送信前)に変更する
   * @param ordNo
   * @param condTreatDate
   * @param facilityCd
   * @param newTreatDate
   * @param kurCd
   * @param bedCd
   * @param indUserId
   * @param updUserId
   * @return
   */
  //mod 10860 ind_schedule_user_infoのデータ不正 zhao start
//  @Update(sqlFile = true)
//  int updateOrdMainData(
//      Long ordNo,               //条件:オーダー番号
//      String condTreatDate,     //条件:治療日
//      String facilityCd,        //条件:施設コード
//      String newTreatDate,      //更新対象:治療日
//      Long kurCd,               //更新対象:クールコード
//      Long bedCd,                //更新対象:ベッドコード
//      Long indUserId,           //更新対象:指示者ID
//      Long updUserId            //更新対象:更新者ID
//    );
  @Update(sqlFile = true)
  int updateOrdMainData(
    Long ordNo,               //条件:オーダー番号
    String condTreatDate,     //条件:治療日
    String facilityCd,        //条件:施設コード
    String newTreatDate,      //更新対象:治療日
    Long kurCd,               //更新対象:クールコード
    Long bedCd,                //更新対象:ベッドコード
    Long indUserId,           //更新対象:指示者ID
    Long updUserId,            //更新対象:更新者ID
    String updUserFirstName,
    String updUserLastName,
    String indUserFirstName,
    String indUserLastName
  );
  //mod 10860 ind_schedule_user_infoのデータ不正 zhao end
  //add #10601 スケジュール表動作不正 start
  @Select
  List<OrdSchedule> selectForSearchReservedBed2(List<IndScheduleInfo> indScheduleInfoList);
  //add #10601 スケジュール表動作不正 end

  // add #11493 スケジュール表　更新不正 関 start
  @Select
  int selectBatchMovePatExistanceByIndScheduleList(List<IndScheduleInfo> indScheduleInfoList, String facilityCd);
  // add #11493 スケジュール表　更新不正 関 end

}
