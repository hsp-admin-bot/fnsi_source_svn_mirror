package jp.co.nikkiso.ntss.m_notice.packet;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeError;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramElement;

/**
 * 電文構造体クラス
 */
public class MNoticeTelegram {
  
  public static final String IKKIKO_FIRST_STRING = "V";

  private Hashtable<String, Integer> recDef = new Hashtable<String, Integer>(); // レコード定義
  private List<Integer> fldstartPos = new ArrayList<Integer>(); // フィールド定義（Array）
  private List<Integer> fldbyteLen = new ArrayList<Integer>(); // フィールド定義（Array）
  private List<String> fldtype = new ArrayList<String>(); // フィールド定義（Array）
  private int reclen; // レコード長
  private byte[] recBuf;

  /**
   * 要素ごとに電文を分解します。
   * 
   * @param fldName 要素名
   * @return 電文から分解した要素データ
   */
  public final Object getFV(String fldName) {
    Integer ix = recDef.get(fldName);
    String fdValue = null; // 文字列値
    String fdType = fldtype.get(ix);
    Integer fdStat = fldstartPos.get(ix);
    Integer fdLen = fldbyteLen.get(ix);
    int ii = 0;
    byte[] fdBuf = new byte[fdLen];

    switch (fdType) {
    case "X":
      String resultx = null;
      for (int i = fdStat; i < fdLen + fdStat; i++) {
        fdBuf[ii] = recBuf[i];
        ii++;
      }
      try {
        resultx = new String(fdBuf, "SHIFT_JIS");
        fdValue = resultx;
      } catch (UnsupportedEncodingException e) {
        // TODO Auto-generated catch block
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//        e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        throw new RuntimeException(e);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      }
      break;
    case "B":
      for (int i = fdStat; i < fdLen + fdStat; i++) {
        fdBuf[ii] = recBuf[i];
        ii++;
      }
      long resultb = 0;
      for (byte b : fdBuf) {
        int digit1 = b >> 4;
        int digit2 = b & 0x0f;
        resultb = (resultb * 100) + (digit1 * 10) + digit2;
      }
      fdValue = String.valueOf(resultb);
      break;
    case "D":
      long resultd = 0;
      String hex = null;
      for (int i = fdStat; i < fdLen + fdStat; i++) {
        fdBuf[ii] = recBuf[i];
        ii++;
      }
      ByteBuffer buffer = ByteBuffer.wrap(fdBuf);
      resultd = buffer.getShort() & 0xffff_ffffL;
      hex = Long.toHexString(resultd);
      fdValue = String.valueOf(hex);
      break;
    case "V":
      int nbcc = 0;
      for (int i = fdStat; i < fdLen + fdStat; i++) {
        fdBuf[ii] = recBuf[i];
        ii++;
      }
      for (int i = 0; i < fdBuf.length; i++) {
        nbcc = (nbcc << 8) + (fdBuf[i] & 0xff);
      }
      fdValue = String.valueOf(nbcc);
      break;
    }
    return fdValue;
  }

  public final void FD_X(String fldName, int fldStartPos, int fldByteLen) {
    BFldDef(fldName, fldStartPos, fldByteLen, "X");
  }

  public final void FD_B(String fldName, int fldStartPos, int fldByteLen) {
    BFldDef(fldName, fldStartPos, fldByteLen, "B");
  }

  public final void FD_D(String fldName, int fldStartPos, int fldByteLen) {
    BFldDef(fldName, fldStartPos, fldByteLen, "D");
  }

  public final void FD_V(String fldName, int fldStartPos, int fldByteLen) {
    BFldDef(fldName, fldStartPos, fldByteLen, "V");
  }

  private void BFldDef(String fldName, int fldStartPos, int fldByteLen, String fldType) {
    int intIndex = 0; // 指標
    // フィールド定義追加指標取得
    intIndex = recDef.size();
    // フィールド開始位置
    fldstartPos.add(fldStartPos - 1);
    // フィールドバイト長
    fldbyteLen.add(fldByteLen);
    // フィールドタイプ
    fldtype.add(fldType);
    // レコード定義へのフィールド追加
    recDef.put(fldName, intIndex);

    return;
  }

  public final int getReclen() {
    return reclen;
  }

  public final void setReclen(int lval) {
    reclen = lval;
    recBuf = new byte[lval];
  }

  public final String getRec() {
    return recBuf.toString();
  }

  public final void setRec(byte[] buffer) {
    recBuf = buffer == null ? null : buffer.clone();
  }

  /**
   * チェックディジットを行います。
   * 
   * @return チェックサムの値
   */
  public int getCheckDigit() {
    // BCC算出
    int nbcc = 0;
    for (int i = 0; i < recBuf.length - 1; i++) {
      nbcc += (int) recBuf[i];
      nbcc &= 0x00ff;
    }
    return nbcc;
  }

  /**
   * チェックサムの値を取得します。
   * 
   * @return チェックサムの値
   */
  public int getCheckSum() {
    String sum = (String) this.getFV(TelegramElement.CHECK_SUM);
    return Integer.parseInt(sum);
  }

  boolean isEmpty(String str) {
    return StringUtils.isEmpty(str);
  }

  /**
   * 装置記録コードより、医器工か日機装の装置かチェックする
   * 
   * @param code
   *          装置記録コード
   * @return 医器工のとき、trueを返す。それ以外のときfalseを返す。
   */
  protected boolean isIkikoMachineCode(String code) {
    String firstCharacter = code.substring(0, 1);
    return IKKIKO_FIRST_STRING.equals(firstCharacter);
  }

  /**
   * イベント発生日時をTimestamp型に変換します。
   * 
   * @return イベント発生日時
   */
  public Timestamp getOccurrenceDateTime() {
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
    String occurrenceDateTime = String.format("%08d", Integer.parseInt(this.getFV(TelegramElement.OCCURRENCE_DATE).toString()))
        + String.format("%06d", Integer.parseInt(this.getFV(TelegramElement.OCCURRENCE_TIME).toString()));
    try {
      return new Timestamp(simpleDateFormat.parse(occurrenceDateTime).getTime());
    } catch (ParseException e) {
      throw new InvalidAlertFormatException(MNoticeError.GET_EVENT_REG_DATE, e);
    }
  }
}
