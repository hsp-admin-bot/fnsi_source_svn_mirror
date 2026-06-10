package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataRequest;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataRequestList;
import jp.co.nikkiso.ntss.admin_web.response.OtherScheduleListResponse;

import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.springframework.http.ResponseEntity;

/**
 * スケジュール表のServiceインタフェース.
 */
public abstract interface ScheduleListService {

  /**
   * ベッド一覧取得用
   * @param facilityCd 施設コード
   * @param treatDateList   治療日
   * @return ベッド一覧情報
   * @throws Exception
   */
  List<Map<String,Object>> getBedListMain(
          String facilityCd,
          List<String> treatDateList
      );
  /**
   * ベッド未登録一覧取得用
   * @param facilityCd 施設コード
   * @param treatDateList   治療日
   * @return ベッド未登録一覧情報
   * @throws Exception
   */
  List<Map<String,Object>> getBedListNotYet(
          String facilityCd,
          List<String> treatDateList
      );
  /**
   * クール未登録一覧取得用
   * @param facilityCd 施設コード
   * @param treatDateList   治療日
   * @return クール未登録一覧情報
   * @throws Exception
   */
  List<Map<String,Object>> getBedListKurNotYet(
          String facilityCd,
          List<String> treatDateList
      );
  /**
   * 患者情報取得用(チェック用情報)
   * @param ordNo オーダー番号
   * @return 患者情報(不一致、治療時間、同姓同名、予定有無チェック用) ※TODO:予定有無の追加
   * @throws Exception
   */
  List<Map<String,Object>> selectPatInfoForCheck(
          Long ordNo
      );

//  add by ShiHongda 2023-02-08 [optimize] --start /
  /**
   * 患者情報取得用(チェック用情報)
   * @param ordNoList オーダー番号List
   * @return 患者情報(不一致、治療時間、同姓同名、予定有無チェック用) ※TODO:予定有無の追加
   * @throws Exception
   */
  List<Map<String,Object>> selectPatInfoForListCheck(
    List<Long> ordNoList
  );
//  add by ShiHongda 2023-02-08 [optimize] --end /


  /**
   * 患者情報一覧取得用
   * @param List<String> facilityCdList 施設コードリスト
   * @param List<Long> patIdList   患者IDリスト
   * @return クール未登録一覧情報
   * @throws Exception
   */
  List<PatPersonalMain>  getPatInfoList(
          List<String> facilityCdList,
          List<Long> patIdList
      );

  /**
   * add 10061 by kangjie
   * @param facilityCdList
   * @param patIdList
   * @return
   */
  List<PatPersonalMain> getPatPersonalMainDtoList(List<String> facilityCdList,
                                                     List<Long> patIdList);
  /**
   * クール名一覧取得用
   * @param String facilityCd 施設コード
   * @return クール名一覧
   * @throws Exception
   */
  List<MstKur>  getKurNameList(
          String facilityCd
      );
  /**
   * ベッド数最大値取得用
   * @param String facilityCd 施設コード
   * @return ベッド情報リスト
   * @throws Exception
   */
  List<Map<String,Object>>   getBedMaxCount(
          String facilityCd
      );
  /**
   * ベッドグループ情報取得用
   * @param String facilityCd 施設コード
   * @return ベッドグループ情報一覧
   * @throws Exception
   */
  List<MstRoomBedGroup>  getRoomBedGroupList(
          String facilityCd
      );
  /**
   * 指定期間分のその他予定取得(検査予定、放射線検査予定、患者イベント)
   * @param String startDate 開始日
   * @param String endDate 終了日
   * @param String facilityCd 施設コード
   * @return 指定期間分のその他予定リスト
   * @throws Exception
   */
  OtherScheduleListResponse getOtherScheduleListByPeriod(
          String startDate,
          String endDate,
          String facilityCd
      );
  /**
   * 同一患者同一治療日同一クール同一治療方法のチェック
   * @param Long ordNoList オーダー番号
   * @param String treatDate 治療日
   * @param Long kurCd クールコード
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  Boolean  checkSamePatDayKurMode(
          Long ordNo,
          String treatDate,
          Long kurCd
      );
  /**
   * ベッド患者情報の存在チェック
   * @param Long ordNoList オーダー番号
   * @param String treatDate 治療日
   * @param Long kurCd クールコード
   * @param Long bedCd ベッドコード
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  // mod #11493 スケジュール表　更新不正 関 start
  Boolean  checkPatExistance(
          Long ordNo,
          String treatDate,
          Long kurCd,
          Long bedCd,
          String dialysisState,
          String isDummy
      );
  // mod #11493 スケジュール表　更新不正 関 end
  /**
   * スケジュール表の更新処理(単体)
   * @param Long ordNo              条件:オーダー番号
   * @param String condTreatDate    条件:治療日
   * @param String facilityCd       条件:施設コード
   * @param String newTreatDate     更新対象:治療日
   * @param Long kurCd              更新対象:クールコード
   * @param Long bedCd              更新対象:ベッドコード
   * @return 更新数
   * @throws Exception
   */
  public int  updateScheduleListData(
      Long ordNo,
      String condTreatDate,
      String facilityCd,
      String newTreatDate,
      Long kurCd,
      Long bedCd
      );
  /**
   * ord_mainの更新処理(単体)
   * @param Long ordNo              条件:オーダー番号
   * @param String condTreatDate    条件:治療日
   * @param String facilityCd       条件:施設コード
   * @param String newTreatDate     更新対象:治療日
   * @param Long kurCd              更新対象:クールコード
   * @param Long bedCd              更新対象:ベッドコード
   * @param Long indUserId          更新対象:指示者ID
   * @param Long updUserId          更新対象:更新者ID
   * @return 更新数
   * @throws Exception
   */
  public int  updateOrdMainData(
      Long ordNo,
      String condTreatDate,
      String facilityCd,
      String newTreatDate,
      Long kurCd,
      Long bedCd,
      Long indUserId,
      Long updUserId

      );

  /**
   * 指示変更有りフラグを更新
   * @param ordNo 対象オーダー番号
   * @param condTreatDate 変更前治療予定日
   * @param newTreatDate 変更後治療予定日
   * @return
   * @throws Exception
   */
  public int changedIndData(Long ordNo, String condTreatDate, String newTreatDate) throws Exception;

  /**
   * FNSI-add 対応401 孫灝 20201203
   * @param ordNo
   * @return
   */
  int deleteOrdCheckListByOrdNo(long ordNo, String facilityCd);

  /**
   * FNSI-add 1006 No.426 --Sanjingye Sun 20201217
   * selecting db find event start Date and event end Date
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @return
   */
  List<PatEvent> selectPatEventPeriod(String facilityCd, String patId, String eventStartDate);
  // add 9273 start
  /**
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @param ordNo
   * @return
   */
  List<PatEvent> selectPatEventByOrdNoWithOutStartDate(String facilityCd, String patId, String eventStartDate, Long ordNo);
  /**
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @param eventEndDate
   * @return
   */
  List<PatEvent> selectPatEventByOrdNoAndDate(String facilityCd, String patId, String eventStartDate, String eventEndDate, List<Long> ordNoList);
  // add 9273 end

  /**
   * FNSI-add 1006 No.426 -- Sanjingye Sun 20201217
   * update event_start_date and event_end_date of pat_event
   * @param patEvent
   * @return
   */
  int updatePatEventPeriod(PatEvent patEvent);

  /**
   * add FNSI 1006 No.426 -- Sanjingye Sun 20201224
   * delete pat event according to facilityCd,patId and beforeDate by update 'isDel' field to 1
   * @param patEvent
   * @return
   */
  int updatePatEventIsDel(PatEvent patEvent);


  /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
  Map<String, Object> getBedAndKurInfoFromDB(String facilityCd);

  ResponseEntity<List<String>> getScheduleListDataFromDB_DAO(String treatDate, String facilityCd);

  ResponseEntity<List<String>> updateScheduleListData(UpdateScheduleListDataRequest request);
  /* add by yuqinlong  2023-02-02 [CodeOptimization] end  */

  //add #10601 スケジュール表動作不正 start
  ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed2(UpdateScheduleListDataRequestList request);
  //add #10601 スケジュール表動作不正 end

  // add #11493 スケジュール表　更新不正 関 start
  Boolean checkBatchMovePatExistance(String bodydata, String facilityCd) throws JsonProcessingException;
  // add #11493 スケジュール表　更新不正 関 end
}
