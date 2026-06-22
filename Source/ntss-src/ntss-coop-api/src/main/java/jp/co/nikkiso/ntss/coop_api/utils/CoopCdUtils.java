package jp.co.nikkiso.ntss.coop_api.utils;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

import java.util.Arrays;
import java.util.List;


public class CoopCdUtils {

  /**
   * Rep_dial
   * coopCdIndex
   */
  public final static List<String> coopCdIndexEnums = Arrays.asList(
    JournalConvertConstants.FORMAT_PDF,
    JournalConvertConstants.FORMAT_XML,
    JournalConvertConstants.FORMAT_LIST_XML);

  /**
   * 初版確定前の治療実績削除で不要なイベントが登録される
   * coopCdはrst _dialとREP _DIAL
   */
  public static Boolean validateCoopCdIsRepDialRstDial(SysCoopJournal journal) {
    return ((CoopCdConstant.REP_DIAL.equals(journal.getCoopCd()) && coopCdIndexEnums.contains(journal.getCoopCdIndex())) ||
      CoopCdConstant.RST_DIAL.equals(journal.getCoopCd()));
  }

}
