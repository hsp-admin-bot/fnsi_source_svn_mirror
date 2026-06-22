package jp.co.nikkiso.ntss.admin_web.request.exam;

import java.sql.Timestamp;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class examResultFileCaptureRequest {
  /**
   * レコード区分(A1固定)
   */
  private String recordKbn;
  /**
   * センターコード(空白)
   */
  private String centerCd;
  /**
   * 採取日(YYYYMMDD)
   */
  private String examDate;
  /**
   * 採取時刻(HHmm)
   */
  private String examTime;
  /**
   * 採取時刻(HHmm)
   */
  private Timestamp examDateTime;
  /**
   * 透析前後(1:透析前、2:透析後、0:その他)
   */
  private String orderClass;
  /**
   * 予備
   */
  private String reserve1;
  /**
   * 受託者 KEY
   */
  private String recieverKey;
  /**
   * 患者ID
   */
  private Long patId;
  /**
   * 院内表示用患者ID
   */
  private String hospPatId;
  /**
   * 患者死亡日(yyyyMMdd形式、存命中はnull)
   */
  private Timestamp patDieDate;
  /**
   * 患者性別
   */
  private Integer patSex;
  /**
   * 予備
   */
  private String reserve2;
  /**
   * 報告状況（M:中間報告、E:最終報告)
   */
  private String reportCd;
  /**
   * 検体状態・乳び
   */
  private String kentaiNyubi;
  /**
   * 検体状態・溶血
   */
  private String kentaiYoketu;
  /**
   * 検体状態・ビリルビン
   */
  private String kentaiBilirubin;
  /**
   * 検査結果情報１・項目コード
   */
  private String examItemCd1;
  /**
   * 検査結果情報１・予備
   */
  private String examReserve1;
  /**
   * 検査結果情報１・検査結果値
   */
  private String examResult1;
  /**
   * 検査結果情報１・検査値形態(L:未満、E:以下、U:以上、O:超過、B:結果なし）
   */
  private String examCheck1;
  /**
   * 検査結果情報１・結果コメント１
   */
  private String examComment1_1;
  /**
   * 検査結果情報１・結果コメント２
   */
  private String examComment2_1;
  /**
   * 検査結果情報１・検査結果有無
   */
  private boolean isExistExam1;
  /**
   * 検査結果情報２・項目コード
   */
  private String examItemCd2;
  /**
   * 検査結果情報２・予備
   */
  private String examReserve2;
  /**
   * 検査結果情報２・検査結果値
   */
  private String examResult2;
  /**
   * 検査結果情報２・検査値形態(L:未満、E:以下、U:以上、O:超過、B:結果なし）
   */
  private String examCheck2;
  /**
   * 検査結果情報２・結果コメント１
   */
  private String examComment1_2;
  /**
   * 検査結果情報２・結果コメント２
   */
  private String examComment2_2;
  /**
   * 検査結果情報２・検査結果有無
   */
  private boolean isExistExam2;
  /**
   * 検査結果情報３・項目コード
   */
  private String examItemCd3;
  /**
   * 検査結果情報３・予備
   */
  private String examReserve3;
  /**
   * 検査結果情報３・検査結果値
   */
  private String examResult3;
  /**
   * 検査結果情報３・検査値形態(L:未満、E:以下、U:以上、O:超過、B:結果なし）
   */
  private String examCheck3;
  /**
   * 検査結果情報３・結果コメント１
   */
  private String examComment1_3;
  /**
   * 検査結果情報３・結果コメント２
   */
  private String examComment2_3;
  /**
   * 検査結果情報３・検査結果有無
   */
  private boolean isExistExam3;
  /**
   * 検査結果情報４・項目コード
   */
  private String examItemCd4;
  /**
   * 検査結果情報４・予備
   */
  private String examReserve4;
  /**
   * 検査結果情報４・検査結果値
   */
  private String examResult4;
  /**
   * 検査結果情報４・検査値形態(L:未満、E:以下、U:以上、O:超過、B:結果なし）
   */
  private String examCheck4;
  /**
   * 検査結果情報４・結果コメント１
   */
  private String examComment1_4;
  /**
   * 検査結果情報４・結果コメント２
   */
  private String examComment2_4;
  /**
   * 検査結果情報４・検査結果有無
   */
  private boolean isExistExam4;
  /**
   * 検査結果情報５・項目コード
   */
  private String examItemCd5;
  /**
   * 検査結果情報５・予備
   */
  private String examReserve5;
  /**
   * 検査結果情報５・検査結果値
   */
  private String examResult5;
  /**
   * 検査結果情報５・検査値形態(L:未満、E:以下、U:以上、O:超過、B:結果なし）
   */
  private String examCheck5;
  /**
   * 検査結果情報５・結果コメント１
   */
  private String examComment1_5;
  /**
   * 検査結果情報５・結果コメント２
   */
  private String examComment2_5;
  /**
   * 検査結果情報５・検査結果有無
   */
  private boolean isExistExam5;
  /**
   * 空白
   */
  private String space;

}
