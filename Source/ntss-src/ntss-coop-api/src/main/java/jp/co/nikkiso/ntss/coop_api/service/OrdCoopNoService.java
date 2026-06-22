package jp.co.nikkiso.ntss.coop_api.service;


import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

import java.util.List;
import java.util.Map;


public interface OrdCoopNoService {
  /**
   * 連携オーダ番号を採番する
   *
   * @param journal - {@link SysCoopJournal journal}
   */
  OrdCoopNo getOrdCoopNoByJournal(SysCoopJournal journal);

  /**
   * 連携オーダ番号を採番する
   *
   * @param curSysCoopNoCtlNo - 連携オーダ番号の管理番号
   * @param journal - {@link SysCoopJournal journal}
   * @return 連携オーダ番号
   */
  String createOrdCoopNo(Long curSysCoopNoCtlNo, SysCoopJournal journal);

  /**
   * OrdCoopNo 削除処理
   * @param journal - {@link SysCoopJournal}
   * @return
   */
  void deleteOrdCoopNoByJournal(SysCoopJournal journal);
  /**
   * 連携オーダ番号を採番する（受信）
   * @param rm データ
   * @param idMap　個人情報
   * @param key0   電子カルテ種別
   * @return
   */
// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  String getReceiveCoopOrdNo(JournalConvertResult.ResultMap rm, Map<String, Object> idMap, MstCoopIniConstant.CoopIniMemo coopIniMemo);
  String getReceiveCoopOrdNo(JournalConvertResult.ResultMap rm, Map<String, Object> idMap, String key0);

// mod 2023-01-12 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  List<OrdCoopNo> getOrdCoopNoListByJournalList(List<SysCoopJournal> journalList,String faciltiyCd) ;


}
