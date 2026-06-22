package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveHistoryDao;
import jp.co.nikkiso.ntss.core.dto.PatIndApproveHistory.PatIndApproveHistoryDTO;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApproveHistory;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class PatIndApproveHistoryServiceImpl implements PatIndApproveHistoryService {
  @Autowired
  PatIndApproveHistoryDao patIndApproveHistoryDao;

  @Autowired
  OrdMainDao ordMainDao;

  // mod FNSI-ログクラスを修正SE fengから指示 周 start
  //Logger LOGGER = LogManager.getLogger(PatIndApproveHistoryService.class);

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;
  // mod FNSI-ログクラスを修正SE fengから指示 周 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int createHistory(PatIndApproveHistoryDTO patIndApproveHistoryDTO) {
    try {
      if (patIndApproveHistoryDTO.getApproveKind().size() == 1) {
        for (Long ordNo : patIndApproveHistoryDTO.getOrdNo()) {
          String approveKind = null;
          Long approve_bef_id = null;
          if (patIndApproveHistoryDTO.getApproveKind() != null
            && patIndApproveHistoryDTO.getApproveKind().size() > 0) {

            approveKind = patIndApproveHistoryDTO.getApproveKind().get(0).toString();
            approve_bef_id = patIndApproveHistoryDao.findApproveAftIdByOrdNo(ordNo, approveKind);
          }

          Long approveAftId = null;
          if (patIndApproveHistoryDTO.getApproveAftId() != null
            && patIndApproveHistoryDTO.getApproveAftId().size() > 0) {

            approveAftId = patIndApproveHistoryDTO.getApproveAftId().get(0);
          }

          save(patIndApproveHistoryDTO.getSignType().get(0), ordNo, approve_bef_id,
            patIndApproveHistoryDTO.getUserId(), approveKind, approveAftId);
        }
      } else if (patIndApproveHistoryDTO.getApproveKind().size() == 2) {
        Long approve_bef_id = null;
        Long ordNo = null;

        for (int i = 0; i < patIndApproveHistoryDTO.getApproveKind().size(); i++) {
          String approveKind = null;
          if (!patIndApproveHistoryDTO.getApproveKind().get(i).equals(0L)) {
            approveKind = patIndApproveHistoryDTO.getApproveKind().get(i).toString();
            if (patIndApproveHistoryDTO.getOrdNo().size() > 0) {
              ordNo = patIndApproveHistoryDTO.getOrdNo().get(0);
              approve_bef_id = patIndApproveHistoryDao.findApproveAftIdByOrdNo(ordNo, approveKind);
            }
          }

          Long approveAftId = null;
          if (patIndApproveHistoryDTO.getApproveAftId() != null
            && patIndApproveHistoryDTO.getApproveAftId().size() > 0
            && !patIndApproveHistoryDTO.getApproveAftId().get(i).equals(0L)) {

            approveAftId = patIndApproveHistoryDTO.getApproveAftId().get(i);
          }
          save(patIndApproveHistoryDTO.getSignType().get(i), ordNo, approve_bef_id,
              patIndApproveHistoryDTO.getUserId(), approveKind, approveAftId);
        }
      }
      return 1;
    } catch (Exception e) {
      // mod FNSI-ログクラスを修正SE fengから指示 周 start
      //LOGGER.error(e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_INDICATION, LoggingConstant.SERVICE_NAME.FNSI,
        null);
      // mod FNSI-ログクラスを修正SE fengから指示 周 end
      return 0;
    }

  }

  /**
   * 指示受け・承認詳細作成
   * @param signType 登録区分
   * @param ordNo オーダ番号
   * @param approveBefId 変更前指示受け承認者
   * @param userId 操作者
   * @param approveKind 指示受け承認区分
   * @param approveAftId 変更後指示受け承認者
   * @return
   */
  private void save(String signType, Long ordNo, Long approveBefId, Long userId, String approveKind,
      Long approveAftId) {
    PatIndApproveHistory patIndApproveHistory = new PatIndApproveHistory();
    patIndApproveHistory.setIndApproveHistoryNo(0l);
    patIndApproveHistory.setSignType(signType);
    patIndApproveHistory.setOrdNo(ordNo);
    patIndApproveHistory.setApproveBefId(approveBefId);
    patIndApproveHistory.setUserId(userId);
    patIndApproveHistory.setApproveKind(approveKind);
    patIndApproveHistory.setApproveAftId(approveAftId);
    if (patIndApproveHistory.getIsDel() == null || patIndApproveHistory.getIsDel().trim().equals("")) {
      patIndApproveHistory.setIsDel("0");
    }
    if (patIndApproveHistory.getIsDisp() == null || patIndApproveHistory.getIsDisp().trim().equals("")) {
      patIndApproveHistory.setIsDisp("1");
    }
    // オーダ番号より治療情報取得
    OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
    patIndApproveHistory.setFacilityCd(ord.getFacilityCd());
    patIndApproveHistoryDao.insertPatIndHistory(patIndApproveHistory);
  }

  //add #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
  /**
   * {@inheritDoc}
   */
  /** 指示履歴一覧の固定ソート（従来フロントと同一: ind_approve_history_no desc） */
  private static final String PAT_IND_APPROVE_HISTORY_ORDER_BY =
      " order by ind_approve_history_no desc";

  @Override
//  public List<PatIndApproveHistory> findPatIndApproveHistoryByOrdNo(Long ordNo, Long page, Long size, String kind, String sort) {
  public List<PatIndApproveHistory> findPatIndApproveHistoryByOrdNo(Long ordNo, Long page, Long size, String kind) {
    if (ordNo == null || ordNo.compareTo(0L) < 0) {
      return null;
    }
    StringBuilder sql_append = new StringBuilder();
    sql_append.append(PAT_IND_APPROVE_HISTORY_ORDER_BY);
    long offset = (page - 1) * size;
    sql_append.append(" offset ");
    sql_append.append(offset);
    sql_append.append(" limit ");
    //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end
    sql_append.append(size);
    return patIndApproveHistoryDao.findByOrdNo(ordNo,kind.toLowerCase(), sql_append.toString());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Long findTotalElements(Long ordNo, String kind) {
    return patIndApproveHistoryDao.findTotalElements(ordNo, kind);
  }
}
