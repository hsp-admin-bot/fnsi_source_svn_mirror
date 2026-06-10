package jp.co.nikkiso.ntss.device_edge.util.MedicalCareInfo;

import java.io.IOException;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import lombok.Getter;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
/**
 *  共通診療情報処理クラス.
 */
@Service
@Getter
public class MedicalCareInfoServiceImpl implements MedicalCareInfoService {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * 共通診療情報のJSON文字列を与から、共通診療情報クラスに展開します。
   * 名称項目はセットされないため、名称が必要な場合は各findメソッドを呼んでください。
   * @param mediCareInfo
   */
  public MedicalCareInfo createMedicalCareInfo(String mediCareInfoJsonString) {
    MedicalCareInfo mediCareInfo = new MedicalCareInfo();
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_parent = mapper.readTree(mediCareInfoJsonString);
      mediCareInfo = this.setItems(jsonNode_parent);

    } catch (IOException e) {
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    return mediCareInfo;
  }

  @Autowired
  MstWardDao mstWardDao;

  /**
   * 格納されている病棟コードをもとに病棟マスタから病棟名を検索し、返します。
   */
  public String findWardName(MedicalCareInfo mediCareInfo) {
    // マスタ情報取得
    MstWard mstWard = mstWardDao.selectByCd(mediCareInfo.wardCd);
    // 名称を返す
    return mstWard == null ? "" : mstWard.getWardName();
  }

  @Autowired
  MstCourseDao mstCourseDao;

  /**
   * 格納されている主科コードをもとに診療科マスタから診療科名を検索し、返します。
   */
  public String findMainCourseName(MedicalCareInfo mediCareInfo) {
    // マスタ情報取得
    MstCourse mstCourse = mstCourseDao.selectByCd(mediCareInfo.mainCourseCd);
    // 名称を返す
    return mstCourse == null ? "" : mstCourse.getCourseName();
  }

  /**
   * 格納されている透析実施科コードをもとに診療科マスタから診療科名を検索し、返します。
   */
  public String findDialysisCourseName(MedicalCareInfo mediCareInfo) {
    // マスタ情報取得
    MstCourse mstCourse = mstCourseDao.selectByCd(mediCareInfo.dialysisCourseCd);
    // 名称を返す
    return mstCourse == null ? "" : mstCourse.getCourseName();
  }

  /****** プライベートメソッド *********/

  /**
   * JSONノードからMedicalCareInfoクラスに展開して返します。
   * @param jsonNode
   * @return
   */
  private MedicalCareInfo setItems(JsonNode jsonNode) {
    MedicalCareInfo mediCareInfo = new MedicalCareInfo();

    // 各項目のノード取得
    JsonNode mainCourseCdNode = jsonNode.get("main_course_cd");
    JsonNode dialysisCourseCdNode = jsonNode.get("dialysis_course_cd");
    JsonNode wardCdNode = jsonNode.get("ward_cd");
    JsonNode dialysisCountNode = jsonNode.get("dialysis_count");
    JsonNode purificationCountNode = jsonNode.get("purification_count");
    JsonNode otherDialysisCountNode = jsonNode.get("other_dialysis_count");
    JsonNode facilityCdNode = jsonNode.get("facility_cd");
    JsonNode dialysisStartDateNode = jsonNode.get("dialysis_start_date");
    JsonNode hospitalStartDateNode = jsonNode.get("hospital_start_date");

    // 各値を戻り値にセット
    mediCareInfo.mainCourseCd = Utilities.getIntJsonNode(mainCourseCdNode, 0);
    mediCareInfo.dialysisCourseCd = Utilities.getIntJsonNode(dialysisCourseCdNode, 0);
    mediCareInfo.wardCd =  Utilities.getIntJsonNode(wardCdNode, 0);
    mediCareInfo.dialysisCount = Utilities.getIntJsonNode(dialysisCountNode, 0);
    mediCareInfo.purificationCount = Utilities.getIntJsonNode(purificationCountNode, 0);
    mediCareInfo.otherDialysisCount = Utilities.getIntJsonNode(otherDialysisCountNode, 0);
    mediCareInfo.facilityCd = Utilities.getTextJsonNode(facilityCdNode, "");
    mediCareInfo.dialysisStartDate = Utilities.getTextJsonNode(dialysisStartDateNode, "");
    mediCareInfo.hospitalStartDate = Utilities.getTextJsonNode(hospitalStartDateNode, "");

    return mediCareInfo;
  }

}
