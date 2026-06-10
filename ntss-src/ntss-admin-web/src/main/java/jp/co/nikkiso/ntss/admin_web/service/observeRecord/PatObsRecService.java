package jp.co.nikkiso.ntss.admin_web.service.observeRecord;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatObsRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;

public interface PatObsRecService {

  /**
   * 患者観察記録コンボ用ordMainの取得
   * @param patId
   * @param treatDate
   * @param dialysisState
   * @return
   */
  List<OrdMainPatObsRecCombo> selectPatObsRecCombo(String facilityCd, Long patId, String treatDate, Long ordNo,
      Timestamp dialysisDateFrom, Timestamp dialysisDateTo, boolean getIndTreatFlg);

  /**
   * 患者コードから取得する（resourceあり）
   * @param patId 患者ID
   * @return
   */
  List<PatObsRecView> selectByViewSpan(Long patId, Timestamp startDate, Timestamp endDate, String isDel,
      String isNewest);

  /**
   * 患者コードから取得する（resourceあり）
   * @param patId 患者ID
   * @return
   */
  List<PatObsRecView> selectByOrdNo(Long ordNo,  String isDel, String isNewest);

  /**
   * 主キーから取得する（resourceあり）
   * @param ctlNo 管理番号(主キー)
   * @return
   */
  PatObsRecView selectByViewKey(Long patId, Long ctlNo);

  /**
   * 自動生成されるINSERT
   * @param param
   * @return
   */
  int insert(PatObsRec param);

  /**
   * 自動生成されるDELETE
   * @param param
   * @return
   */
  int delete(PatObsRec param);

  /**
   * 自動生成されるUPDATE
   * @param param
   * @return
   */
  int update(PatObsRec param);

  /**
   * resourceでSQL文を指定するInsert
   * @param param
   * @return
   */
  int insertRenew(PatObsRec param);
  
  /**
   * 掲示板管理番号から取得する（resourceあり）
   * @param bbsCtlNo 掲示板管理番号
   * @return
   */
  List<PatObsRec> getObsRecByBbsCtlNo(Long bbsCtlNo);

}
