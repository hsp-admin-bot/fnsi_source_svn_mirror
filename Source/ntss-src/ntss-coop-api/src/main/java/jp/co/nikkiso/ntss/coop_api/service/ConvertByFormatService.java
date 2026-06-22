package jp.co.nikkiso.ntss.coop_api.service;

import java.io.UnsupportedEncodingException;

import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * col属性が指定された値を取得するインタフェース。（フォーマット別）
 */
public interface ConvertByFormatService {

  /**
   * レイアウトXMLでcol属性が指定された項目の値を取得する。
   *
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param key0 電子カルテ種別
   * @param coopCdSub 電文種別補足コード
   * @param telegram 変換対象電文
   * @param keyResult key属性が指定された項目の値
   * @return col属性収集結果
   * @throws UnsupportedEncodingException SJISエンコーディングが使用できない場合
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopCdSub, byte[] telegram,
//                    ResultMap keyResult)
//    throws UnsupportedEncodingException, NtssException;
  ResultMap convert(String facilityCd, String direction, String coopCd, String coopCdIndex, String coopVersion,
                    String key0, String coopCdSub, byte[] telegram, ResultMap keyResult)
    throws UnsupportedEncodingException, NtssException;
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
