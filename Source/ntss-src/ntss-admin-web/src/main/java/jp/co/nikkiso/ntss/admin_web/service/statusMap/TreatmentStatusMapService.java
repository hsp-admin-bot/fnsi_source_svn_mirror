package jp.co.nikkiso.ntss.admin_web.service.statusMap;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.statusMap.MarkerInfoResponse;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForNotAssignedSchedule;
import org.springframework.http.ResponseEntity;

public interface TreatmentStatusMapService {
  PatPersonalMain patientSelect(Long patId);

  List<MstPersonalUser> personalUserSelect(String facilityCd);

  /**
   * 治療状況マップのベッド上部マーカーに表示する情報を取得する
   * @param ord_no
   * @param facilityCd
   * @return
   */
  List<MarkerInfoResponse> getMarkerInfo(List<Long> ord_no, String facilityCd);

  /**
   * 治療予定のベッド移動前チェック結果を取得
   * @param ord_no
   * @param bedNo
   * @param facilityCd
   * @return
   */
  List<MarkerInfoResponse> checkBeforeMoveOrdMain(Long ord_no, Long bedNo, String facilityCd);


  List<OrdMainForNotAssignedSchedule> getNotAssignedOrdMain(String facilityCd, String treatDate, Long bedCd);

  OrdMain getOrdMainByOrdNo(Long ordNo);

  int assignBedToOrdMain(
      String facilityCd,
      Long ordNo,
      Long bedCd,
      String treatDate,
      Long kurCd,
      Long userId);

  int updateNextPatInfo( Long bedCd );

  /**
   * 治療状況マップ指示確認処理を行う
   * @param ordNo 治療番号
   * @param content 指示情報
   * @throws Exception
   */
  int updatePatIndApproveCheckForMap(Long ordNo, String content) throws Exception;

  /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
  ResponseEntity<Integer> unassigmentOrdMain(String facilityCd, Long ordNo, Long userId);
  /* add by sunmingyuan  2023-02-01 CodeOptimization  end */
}
