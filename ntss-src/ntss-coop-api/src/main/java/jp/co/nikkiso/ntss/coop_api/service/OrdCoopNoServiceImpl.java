package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.coop_api.service.sysCoopNo.SysCoopNoService;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalLogUtil;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.OrdCoopNoConstant;
import jp.co.nikkiso.ntss.coop_api.utils.ReceiveCoopOrdNoConstants;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopNoDao;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.SysCoopNo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

// #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
@Service
public class OrdCoopNoServiceImpl implements OrdCoopNoService {
  @Autowired
  private ClockWrapper clockWrapper;
  @Autowired
  private SysCoopNoDao sysCoopNoDao;
  @Autowired
  private OrdCoopNoDao ordCoopNoDao;
  @Autowired
  private SysCoopNoService sysCoopNoService;
  @Autowired
  private MstCoopIniService mstCoopIniService;
//  @Autowired
//  private EventLoggerFactory eventLoggerFactory;
//  @Autowired
//  private LogServiceCore logServiceCore;

//  @Autowired
//  private LogService logService;


  /**
   * journalによるOrdCoopNoの取得
   *
   * @param journal - {@link SysCoopJournal journal}
   */
  @Override
  public OrdCoopNo getOrdCoopNoByJournal(SysCoopJournal journal) {
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<OrdCoopNo> ordCoopNos = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd());
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    List<OrdCoopNo> ordCoopNos = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(), journal.getPatId(),
      journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd(), coopVersion);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (!ordCoopNos.isEmpty()) {
      return ordCoopNos.get(0);
    }
    return null;
  }
  /**
   *
   */
  @Override
  public List<OrdCoopNo> getOrdCoopNoListByJournalList(List<SysCoopJournal> journalList,String faciltityCd) {
    Set<Long> ordNoSet = new HashSet<Long>();
    for (SysCoopJournal journal : journalList) {
      ordNoSet.add(journal.getOrdNo());
    }


    if (ordNoSet.size() > 0) {
      List<Long> ordNoList=new ArrayList<>();
      ordNoList.addAll(ordNoSet);
      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectOrdCoopNoByCoopOrdNoList(ordNoList,faciltityCd);
      return ordCoopNoList;

    }
    return new ArrayList<>();
  }
  /**
   * 連携オーダ番号を採番する
   *
   * @param sysCoopNoCtlNo - 連携オーダ番号の管理番号
   * @param journal           - {@link SysCoopJournal journal}
   * @return 連携オーダ番号
   */
  @Transactional
  @Override
  public String createOrdCoopNo(Long sysCoopNoCtlNo, SysCoopJournal journal) {
    String coopOrdNo = "";
    String coopOrdNoCheck = "";
    Long updateByCurCoopOrdNo = null;
    boolean isNeedSaiban = true;

// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    //3.1.1. 1の処理で取得したctl_noをキーにしてsys_coop_noを取得する(forupdate)
    SysCoopNo curSysCoopNo = sysCoopNoDao.selectByCtlNo(sysCoopNoCtlNo);

    while (isNeedSaiban) {
      //3.1.2. 現在の連携オーダ番号シーケンスを+1する
      if (updateByCurCoopOrdNo == null) {
        updateByCurCoopOrdNo = curSysCoopNo.getCurCoopOrdNo() + 1;
      } else {
        updateByCurCoopOrdNo++;
      }

      //3.1.3. 上記結果が最大値を超えた場合には最小値に設定する
      if (updateByCurCoopOrdNo > curSysCoopNo.getRangeMax()) {
        updateByCurCoopOrdNo = curSysCoopNo.getRangeMin();
      }

      //3.1.4. 連携オーダ番号、パディング文字、位置、前置文字、後置文字等を用いて連携オーダ番号（文字列）を作成する
      StringBuilder coopOrdNoSb = new StringBuilder();
      //前置文字
      //#4042対応 2021/04/08 start
      if (curSysCoopNo.getPrefixChar() != null) {
        coopOrdNoSb.append(curSysCoopNo.getPrefixChar());
      }
      //パティングした文字
      String padding = padding(String.valueOf(updateByCurCoopOrdNo), curSysCoopNo.getNoOfDigit(),
        curSysCoopNo.getPaddingChar(), curSysCoopNo.getPaddingPos());
      coopOrdNoSb.append(padding);
      //後置文字
      if (curSysCoopNo.getSuffixChar() != null) {
        coopOrdNoSb.append(curSysCoopNo.getSuffixChar());
      }
      //#4042対応 2021/04/08 end

      coopOrdNo = coopOrdNoSb.toString();

      // 資源の枯渇を判断する
      if (coopOrdNo.equals(coopOrdNoCheck)) {
        String error = String.format("連携オーダ番号を採番する時、使用できる番号がなくなりました。pat_id:[%s]", journal.getPatId());
        JournalLogUtil.outputErrorLog(error, journal.getFacilityCd(), this.getClass().getName());
        throw new NtssException(error);
      }
      // 最初の番号を保存します。
      if (StringUtils.isEmpty(coopOrdNoCheck)) {
        coopOrdNoCheck = coopOrdNo;
      }

      //3.1.5. 以下のsqlを発行し、結果が0件でない場合には3.1.2に戻り処理を繰り返す
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getPatId(), coopOrdNo);
//      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), coopOrdNo);
//      // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getFacilityCd(), coopVersion,
        journal.getPatId(), journal.getHospPatId(), coopOrdNo);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      if (ordCoopNoList.isEmpty()) {
        isNeedSaiban = false;
        Timestamp now = new Timestamp(clockWrapper.getClockMillis());
//        // DB更新ログ出力ロジック wangzuo Start
//        String tableNameSys = "sys_coop_no";
//        // SQL検索条件
//        StringBuffer wheresSys = new StringBuffer("");
//        wheresSys.append(" WHERE\n");
//        wheresSys.append(" ctl_no = " + sysCoopNoCtlNo + "\n");
//
//        // logCommon設定
//        DataUpdateLogCommonNew logCommonSys = getLogCommon(sysCoopNoDao, tableNameSys, wheresSys, getEventLogMessage());
//        // ログ出力カラム情報及び更新前データ情報取得
//        boolean setResultSys = logCommonSys.setInfo();
//        // DB更新ログ出力ロジック wangzuo End
//
//        //3.1.6. sys_coop_noをupdateする(対象カラム: cur_coop_ord_no )
//        int updateCountSys = sysCoopNoDao.updateCurCoopOrdNo(updateByCurCoopOrdNo, sysCoopNoCtlNo, now);
//        // DB更新ログ出力ロジック wangzuo Start
//        // 更新後データ取得、差分あれば、log出力
//        if (setResultSys && updateCountSys > 0) {
//          logCommonSys.updateLog();
//        }
//        // DB更新ログ出力ロジック wangzuo End


        // 更新現在の連携オーダ番号
        sysCoopNoService.updateCurCoopOrdNo(updateByCurCoopOrdNo, sysCoopNoCtlNo, now);

        // #7301 ind_dial連携・rst_dial連携・rep_dial連携のオーダ番号 start
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        if (mstCoopIniService.validateCoopByFacilityCd(MstCoopIniConstant.CoopIniMemo.F_HOSP.getResult(),journal.getFacilityCd())) {
        if (Key0Constant.GX.equals(key0)) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          if (CoopCdConstant.RST_DIAL.equals(journal.getCoopCd()) || CoopCdConstant.REP_DIAL.equals(journal.getCoopCd())) {
            OrdCoopNo indDialOrdCoopNo = this.getOrdCoopNoByCoopCd(journal,CoopCdConstant.IND_DIAL);
            if (indDialOrdCoopNo != null) {
              coopOrdNo = indDialOrdCoopNo.getCoopOrdNo();
            }
          }
        }
        // #7301 ind_dial連携・rst_dial連携・rep_dial連携のオーダ番号 end


        OrdCoopNo ordCoopNo = new OrdCoopNo();
        ordCoopNo.setCtlNo(ordCoopNoDao.selectNextSeqCtlNo());
        ordCoopNo.setFacilityCd(journal.getFacilityCd());
        ordCoopNo.setPatId(journal.getPatId());
        // add 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
        ordCoopNo.setHospPatId(journal.getHospPatId());
        // add 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
        ordCoopNo.setOrdNo(journal.getOrdNo());
        ordCoopNo.setCoopCd(journal.getCoopCd());
        ordCoopNo.setCoopOrdNo(coopOrdNo);
        ordCoopNo.setUserId(journal.getUserId());
        ordCoopNo.setRegDate(now);
        ordCoopNo.setUpDate(now);
// add 2021-09-30 #6549:連携オーダ番号管理テーブルにてステータスがnullのデータが発生している 孫 start
        ordCoopNo.setStatus(OrdCoopNoConstant.Status.UNPROCESS.getResult());
// add 2021-09-30 #6549:連携オーダ番号管理テーブルにてステータスがnullのデータが発生している 孫 end
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        ordCoopNo.setCoopVersion(coopVersion);
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        //3.1.8. ord_coop_noをinsertする
        ordCoopNoDao.insert(ordCoopNo);
      }
    }
    return coopOrdNo;
  }


  /**
   * OrdCoopNo 削除処理
   *
   * @param journal - {@link SysCoopJournal}
   * @return
   */
  @Transactional
  @Override
  public void deleteOrdCoopNoByJournal(SysCoopJournal journal) {
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());

// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd(), now);4
    // 連携版番号
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
    int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(),
      journal.getCoopCd(), coopVersion, now, journal.getFacilityCd(), journal.getCoopOrdNo());
    /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // logCommon設定
    String tableNameOrd = "ord_coop_no";
    // SQL検索条件
    StringBuffer wheresOrd = new StringBuffer("");
    wheresOrd.append(" WHERE\n");
    wheresOrd.append(" pat_id = " + journal.getPatId() + "\n");
    wheresOrd.append(" AND\n");
    wheresOrd.append(" ord_no = " + journal.getOrdNo() + "\n");
    wheresOrd.append(" AND\n");
    wheresOrd.append(" coop_cd = '" + journal.getCoopCd() + "'\n");
    /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
    wheresOrd.append(" AND\n");
    wheresOrd.append(" facility_cd = '" + journal.getFacilityCd() + "'\n");
    /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
    wheresOrd.append(" AND\n");
    wheresOrd.append(" (is_del = '0' OR is_disp = '1')" + "\n");
    wheresOrd.append(" AND\n");
    wheresOrd.append(" coop_ord_no = '" + journal.getCoopOrdNo() + "'\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommonOrd = JournalLogUtil.getLogCommon(ordCoopNoDao, tableNameOrd, wheresOrd, JournalLogUtil.getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultOrd = logCommonOrd.setInfo();
    // 更新後データ取得、差分あれば、log出力
    if (setResultOrd && updateCountOrd > 0) {
      logCommonOrd.updateLog();

    }

  }
  // add #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 start
  /***
   * 連携オーダ番号を採番する（受信）
   * @param rm データ
   * @param idMap　個人情報
   * @param key0   電子カルテ種別
   * @return
   */
  @Override
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public String getReceiveCoopOrdNo(JournalConvertResult.ResultMap rm, Map<String, Object> idMap, MstCoopIniConstant.CoopIniMemo coopIniMemo) {
  public String getReceiveCoopOrdNo(JournalConvertResult.ResultMap rm, Map<String, Object> idMap, String key0) {
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
    String coopOrdNo = null;
    String facilityCd = (String)idMap.get(ReceiveCoopOrdNoConstants.ID_FACILITY_CD);
    //1. オーダ番号連携対象か否かを判定する
    String coopCd = (String)rm.getSpecial(JournalConvertConstants.COOP_CD);
    String crud = (String)rm.getSpecial(JournalConvertConstants.CRUD);
    Long patId = (Long) idMap.get(ReceiveCoopOrdNoConstants.ID_PAT_ID);
    Long ordNo = (Long)idMap.get(ReceiveCoopOrdNoConstants.ID_ORD_NO);
    Long userId = (Long)rm.getSpecial(JournalConvertConstants.USER_ID);
    // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
    String hospPatId = (String)idMap.get(ReceiveCoopOrdNoConstants.ID_HOSP_PAT_ID);
    // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = "";
    if (idMap.containsKey(ReceiveCoopOrdNoConstants.ID_COOP_VERSION)) {
      coopVersion = StringUtils.isEmpty(idMap.get(ReceiveCoopOrdNoConstants.ID_COOP_VERSION))?"":(String)idMap.get(ReceiveCoopOrdNoConstants.ID_COOP_VERSION);
    }
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end


    //3.携オーダ番号を取得する
    // 画面パラメータ[患者番号,オーダ番号,連携種別(pat_id,ord_no,coop_cd)] で、連携オーダ番号(ord_coop_no)を取得する
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
////    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(facilityCd, patId, null, ordNo, coopCd);
//    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(facilityCd, patId, hospPatId, ordNo, coopCd);
//    // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(facilityCd, patId, hospPatId,
      ordNo, coopCd, coopVersion);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (!ordCoopNoList.isEmpty()) {
      // 連携オーダ番号(ord_coop_no)を取得する場合、連携オーダ番号を設定する
      coopOrdNo = ordCoopNoList.get(0).getCoopOrdNo();
    } else {
      // 連携オーダ番号(ord_coop_no)を取得しませんの場合
      // ジャーナルデータのcrud（作成更新区分）がD（削除）以外の場合、連携オーダ番号を採番する
      if (!"D".equals(crud)) {
        // 連携オーダ番号を採番する
        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod start
        //coopOrdNo = getNewCoopOrdNo(curSysCoopNoCtlNo, rm);
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        switch (coopIniMemo){
//// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////          case F_HOSP:coopOrdNo =getCoopNo(rm,coopCd,hospPatId,patId,patId,userId,facilityCd);break;
//          case F_HOSP:coopOrdNo =getCoopNo(rm,coopCd,hospPatId,patId,patId,userId,facilityCd,coopVersion);break;
//// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//        }
        switch (key0) {
          case Key0Constant.GX:
            coopOrdNo = getCoopNo(rm, coopCd, hospPatId, patId, patId, userId, facilityCd, coopVersion);
            break;
        }
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        // #8079-sys_coop_journalに受信した内容と異なる内容が記録される 周 mod end
      }
    }

    // ジャーナルデータのcrud（作成更新区分）のチェックを行う。
    if ("C".equals(crud)) {
      // 連携オーダ番号(ord_coop_no)が存在、かつ、ステータスが実施済(status = 1：処理済)
      // かつ、電文種別!=[profile]の場合、crudはUにする。
      if (!ordCoopNoList.isEmpty() && "1".equals(ordCoopNoList.get(0).getStatus())
        && !"profile".equals(coopCd)) {
        crud = "U";
      }
    } else if ("U".equals(crud)) {
      // 連携オーダ番号(ord_coop_no)が存在しない、
      // または、[存在、かつ、ステータスが未処理(status = 0：未処理)]の場合、crudはCにする。
      if (ordCoopNoList.isEmpty()
        || (!ordCoopNoList.isEmpty() && "0".equals(ordCoopNoList.get(0).getStatus()))) {
        crud = "C";
      }
    } else if ("D".equals(crud)) {
      // ord_coop_noが存の場合、is_del=1を設定する
      if (!ordCoopNoList.isEmpty()) {
        Timestamp now = new Timestamp(clockWrapper.getClockMillis());

        String tableNameOrd = "ord_coop_no";
        // SQL検索条件
        StringBuffer wheresOrd = new StringBuffer("");
        wheresOrd.append(" WHERE\n");
        wheresOrd.append(" pat_id = " + patId + "\n");
        wheresOrd.append(" AND\n");
        wheresOrd.append(" ord_no = " + ordNo + "\n");
        wheresOrd.append(" AND\n");
        wheresOrd.append(" coop_cd = '" + coopCd + "'\n");
        /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
        wheresOrd.append(" AND\n");
        wheresOrd.append(" facility_cd = '" + facilityCd + "'\n");
        /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
        wheresOrd.append(" AND\n");
        wheresOrd.append(" (is_del = '0' OR is_disp = '1')" + "\n");
        wheresOrd.append(" AND\n");
        wheresOrd.append(" coop_ord_no = '" + coopOrdNo + "'\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommonOrd = JournalLogUtil.getLogCommon(ordCoopNoDao, tableNameOrd, wheresOrd, JournalLogUtil.getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResultOrd = logCommonOrd.setInfo();

// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
////        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(patId, null, ordNo, coopCd, now);
//        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(patId, hospPatId, ordNo, coopCd, now);
//        // mod 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end
        /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(patId, hospPatId, ordNo, coopCd, coopVersion, now, facilityCd, coopOrdNo);
        /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        // 更新後データ取得、差分あれば、log出力
        if (setResultOrd && updateCountOrd > 0) {
        }
      }
    }

    return coopOrdNo;
  }
  // add #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 end
  // add #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 start

  /**
   * 　
   * @param rm　データ
   * @param coopCd 電文種別
   * @param hospPatId  患者番号(連携用)
   * @param patId　患者番号(システム)
   * @param ordNo　管理番号
   * @param userId 操作者ID
   * @param facilityCd　施設
   * @param coopVersion　連携版番号
   * @return
   */
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  private String getCoopNo(JournalConvertResult.ResultMap rm,String coopCd,String hospPatId,Long patId,Long ordNo,Long userId,String facilityCd){
  private String getCoopNo(JournalConvertResult.ResultMap rm,String coopCd,String hospPatId,Long patId,Long ordNo,
                           Long userId,String facilityCd,String coopVersion){
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    String coopOrdNo=null;
    switch (coopCd){
      case CoopCdConstant.INI_DIAL:coopOrdNo=(String)rm.get(ReceiveCoopOrdNoConstants.GX_INIDIAL_COOP_NO);break;
    }
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(facilityCd ,patId,hospPatId, coopOrdNo);
    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(facilityCd, coopVersion, patId, hospPatId, coopOrdNo);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (ordCoopNoList.isEmpty()) {
      Timestamp now = new Timestamp(clockWrapper.getClockMillis());
      OrdCoopNo ordCoopNo = new OrdCoopNo();
      ordCoopNo.setCtlNo(ordCoopNoDao.selectNextSeqCtlNo());
      ordCoopNo.setFacilityCd(facilityCd);
      ordCoopNo.setPatId(patId);
      ordCoopNo.setOrdNo(ordNo);
      ordCoopNo.setCoopCd(coopCd);
      ordCoopNo.setCoopOrdNo(coopOrdNo);
      ordCoopNo.setUserId(userId);
      ordCoopNo.setRegDate(now);
      ordCoopNo.setUpDate(now);
      ordCoopNo.setStatus("0");
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      ordCoopNo.setCoopVersion(coopVersion);
// add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      ordCoopNoDao.insert(ordCoopNo);
    }
    return  coopOrdNo;
  }
  // add #7047 GX連携用sys_coop_noでcoop_ord_cdが重複するデータが存在する 2022-12-09 孟堅 end
  /**
   * Padding対応
   *
   * @param target     - Padding対象
   * @param itemLength - Paddingする桁数
   * @param format     パディング文字
   * @param position   パディングする位置(left : 左、right : 右)
   * @return Paddingされた文字列
   */
  private String padding(String target, long itemLength, String format, String position) {
    long formatedLength = itemLength - target.getBytes().length;
    // add 2022-01-28 #7060:profile連携のイベントでエラーが発生する 孫 start
    if (formatedLength <= 0) {
      return target;
    }
    // add 2022-01-28 #7060:profile連携のイベントでエラーが発生する 孫 end
    // 半角スペース×桁数で文字列用意
    String paddingByDefaultFormat = "%".concat(String.valueOf(formatedLength)).concat("s");
    String paddingByDefault = String.format(paddingByDefaultFormat, " ");

    // パディング文字なし：０パディング、パディング文字がある場合にはパディング文字でパディングする
    String paddingOnly = StringUtils.isEmpty(format) ? paddingByDefault.replace(" ", "0") : paddingByDefault.replace(" ", format);
    return position.equals("left") ? paddingOnly.concat(target) : target.concat(paddingOnly);
  }

  private OrdCoopNo getOrdCoopNoByCoopCd(SysCoopJournal journal,String coopCd){
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<OrdCoopNo> ordCoopNos = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), coopCd);
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
    List<OrdCoopNo> ordCoopNos = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(), journal.getPatId(),
      journal.getHospPatId(), journal.getOrdNo(), coopCd, coopVersion);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (!ordCoopNos.isEmpty()) {
      return ordCoopNos.get(0);
    }
    return null;
  }
//  /**
//   * ログ出力共通クラス設定、取得
//   *
//   * @return logCommon ログ出力共通クラス
//   */
//  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
//    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
//    logCommon.setEventLoggerFactory(eventLoggerFactory);
//    logCommon.setLogServiceCore(logServiceCore);
//    logCommon.setConfig(Config.get(dao));
//    logCommon.setTableName(tableName);
//    logCommon.setWhereStr(whereStr);
//    logCommon.setCommonEventLogMessage(eventLogMessage);
//    return logCommon;
//  }

//  /**
//   * ログ情報設定
//   *
//   * @return eventLogMessage
//   */
//  private EventLogMessage getEventLogMessage() {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//
//    // サービス名
//    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
//    return eventLogMessage;
//  }

//  /**
//   * エラーログ出力
//   *
//   * @param facilityCd 施設コード
//   * @param message    ログメッセージ
//   */
//  private void outputErrorLog(String facilityCd, String message) {
//    outputLog(LogLevel.ERROR, facilityCd, message);
//  }
//
//  /**
//   * ログ出力
//   *
//   * @param level      {@link LogLevel} ログレベル
//   * @param facilityCd 施設コード
//   * @param message    ログメッセージ
//   */
//  private void outputLog(LogLevel level, String facilityCd, String message) {
//    EventLogMessage elm = new EventLogMessage();
//    elm.setFacilityCd(facilityCd);
//    elm.setLogMessage(message);
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//    elm.setInvokeClass(this.getClass().getName());
//    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//    logService.log(level, elm, null, LoggingConstant.SERVICE_NAME.FNSI, null);
//  }
}
// #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
