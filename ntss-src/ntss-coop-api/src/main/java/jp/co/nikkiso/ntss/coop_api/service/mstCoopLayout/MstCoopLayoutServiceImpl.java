package jp.co.nikkiso.ntss.coop_api.service.mstCoopLayout;

import org.springframework.stereotype.Service;

@Service
public class MstCoopLayoutServiceImpl implements MstCoopLayoutService {
// del 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//  @Autowired
//  MstCoopLayoutDao mstCoopLayoutDao;
//  @Autowired
//  MstCoopIniDao mstCoopIniDao;
//  @Autowired
//  ConvertSendCommonService convertSendCommonService;
//  @Autowired
//  MstCoopIniService mstCoopIniService;
//
//  /**
//   * ジャーナルから変換したいレイアウトを取得する
//   */
//  @Override
//  public MstCoopLayout getMstCoopLayout(SysCoopJournal journal, String direction) {
//    // mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    // 連携版番号
//    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
//    List<MstCoopLayout> layoutList = mstCoopLayoutDao.selectList(journal.getFacilityCd(), journal.getCoopCd(),
//      journal.getCoopCdIndex(), coopVersion, direction, convertSendCommonService.getCoopCdSub(journal.getCrud()));
//    // mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//    if (layoutList.isEmpty()) {
//      return null;
//    }
//    return layoutList.get(0);
//  }
//  // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 start
//
////  @Override
////  public MstCoopLayout getMstCoopLayoutByMstCoopIni(SysCoopJournal journal) {
////    String direction = JournalConvertConstants.DIRECTION_SEND;
//    // gx
//    // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 start
//// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    if (mstCoopIniService.validateCoopByFacilityCd(MstCoopIniConstant.CoopIniMemo.F_HOSP.getResult(), journal.getFacilityCd())) {
//
////    String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
////    if (Key0Constant.GX.equals(key0)) {
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
////      return this.getMstCoopLayout(journal, direction);
////    }
////    // nkk
////    if (!CoopCdConstant.RST_DIAL.equals(journal.getCoopCd())) {
////      return this.getMstCoopLayout(journal, direction);
////    }
////    // nkk rst_dial
////    return getMstCoopLayoutRstDial(journal);
//
//    // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 start
////    if (Key0Constant.NKK.equals(key0) && CoopCdConstant.RST_DIAL.equals(journal.getCoopCd())) {
//      // NKKのrst_dialの場合
////      return getMstCoopLayoutRstDial(journal);
////    } else {
//      // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 end
//      // その他場合
////      return this.getMstCoopLayout(journal, direction);
////    }
////  }
//
//  /**
//   * layout iniによる検索範囲の制限
//   * nkk rst_dial
//   */
////  MstCoopLayout getMstCoopLayoutRstDial(SysCoopJournal journal) {
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//////    MstCoopIniInfo formatModeIni = mstCoopIniService.getCoopIniInfo(journal.getFacilityCd(), "DIALYSISSEND", "FORMAT_MODE");
////    String key0 = StringUtils.isEmpty(journal.getKey0())?"":journal.getKey0();
////    MstCoopIniInfo formatModeIni = mstCoopIniService.getCoopIniInfo(journal.getFacilityCd(), key0,"DIALYSISSEND", "FORMAT_MODE");
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
////    String rstDialCoopName = "";
////    String effectValue = mstCoopIniService.getEffectValue(formatModeIni);
////    if (effectValue.equals("0")) {
////      rstDialCoopName = MstCoopLayoutConstant.NKK_RST_DIAL_COOP_NAME;
////
////    } else if (effectValue.equals("1")) {
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//////      MstCoopIniInfo headerModeIni = mstCoopIniService.getCoopIniInfo(journal.getFacilityCd(), "DIALYSISSEND", "HEADER_MODE");
////      MstCoopIniInfo headerModeIni = mstCoopIniService.getCoopIniInfo(journal.getFacilityCd(), key0, "DIALYSISSEND", "HEADER_MODE");
////// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
////      if (headerModeIni.getVal().equals("0")) {
////        rstDialCoopName = MstCoopLayoutConstant.NKK_RST_DIAL_COOP_NAME_EXTEND;
////      }
////      if (headerModeIni.getVal().equals("1")) {
////        rstDialCoopName = MstCoopLayoutConstant.NKK_RST_DIAL_COOP_NAME_EXTEND_NOHEADER;
////      }
////
////    }
////
////    // mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////    String direction = JournalConvertConstants.DIRECTION_SEND;
////    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
////    String coopCdSub = convertSendCommonService.getCoopCdSub(journal.getCrud());
////    MstCoopLayout mstCoopLayout = mstCoopLayoutDao.selectByMstCoopIniHeaderMode(journal.getFacilityCd(), journal.getCoopCd(),
////      journal.getCoopCdIndex(), coopVersion, direction, coopCdSub, rstDialCoopName);
////    // mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
////
////    return mstCoopLayout;
////  }
//  // 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え  卓 2023-2-2 end
// del 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
}
