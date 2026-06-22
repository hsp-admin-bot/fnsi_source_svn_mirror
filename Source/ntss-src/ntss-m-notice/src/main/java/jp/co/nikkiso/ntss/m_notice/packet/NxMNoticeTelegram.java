package jp.co.nikkiso.ntss.m_notice.packet;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeError;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.NullEmptyMessage;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramElement;

/**
 * NX通信の構造体クラス
 */
public class NxMNoticeTelegram extends MNoticeTelegram {

  /**
   * NX通信電文のデータを分解します。
   * 
   * @param buffer NX通信電文
   */
  public NxMNoticeTelegram(byte[] buffer) {
    this.FD_X(TelegramElement.MODEL_CODE, 1, 3);
    this.FD_X(TelegramElement.COM_FORMAT_CD, 4, 1);
    this.FD_X(TelegramElement.SERIAL_NUMBER, 5, 8);
    this.FD_X(TelegramElement.FACILITY_CODE, 13, 6);
    this.FD_B(TelegramElement.OCCURRENCE_DATE, 19, 4);
    this.FD_B(TelegramElement.OCCURRENCE_TIME, 23, 3);
    this.FD_X(TelegramElement.RECORDING_CODE, 26, 4);

    this.FD_V(TelegramElement.ADDRESS2, 30, 2);
    this.FD_V(TelegramElement.HUMAN_DETECTION, 32, 2);
    this.FD_V(TelegramElement.ADDRESS3, 34, 2);
    this.FD_V(TelegramElement.DECIMAL_POSITION, 36, 2);
    this.FD_V(TelegramElement.CHANGE_BEFORE, 38, 4);
    this.FD_V(TelegramElement.ADDRESS4, 42, 2);
    this.FD_V(TelegramElement.CHANGE_AFTER, 44, 4);
    this.FD_V(TelegramElement.ADDRESS5, 48, 2);
    this.FD_V(TelegramElement.EXTENDED_DATA1, 50, 4);
    this.FD_V(TelegramElement.ADDRESS6, 54, 2);
    this.FD_V(TelegramElement.EXTENDED_DATA2, 56, 4);
    this.FD_V(TelegramElement.ADDRESS7, 60, 2);
    this.FD_V(TelegramElement.RESERVE, 62, 2);
    this.FD_V(TelegramElement.CHECK_SUM, 64, 1);

    byte[] NxRec = new byte[64];
    byte[] BodyRec = new byte[34];
    byte[] checkRec = new byte[34];
    NxRec = Arrays.copyOfRange(buffer, 0, 29);
    BodyRec = Arrays.copyOfRange(buffer, 29, 63);
    checkRec = Arrays.copyOfRange(buffer, 63, 64);

    Map<Integer, byte[]> mapAress = new HashMap<>();

    for (int i = 0; i < 6; i++) {
      int adress = 0;
      for (int ix = 0; ix < 2; ix++) {
        adress += (int) BodyRec[ix];
        adress &= 0x00ff;
      }
      switch (adress) {
      case 2:
        mapAress.put(2, Arrays.copyOfRange(BodyRec, 0, 4));
        BodyRec = Arrays.copyOfRange(BodyRec, 4, BodyRec.length);
        break;
      case 3:
        mapAress.put(3, Arrays.copyOfRange(BodyRec, 0, 8));
        BodyRec = Arrays.copyOfRange(BodyRec, 8, BodyRec.length);
        break;
      case 4:
        mapAress.put(4, Arrays.copyOfRange(BodyRec, 0, 6));
        BodyRec = Arrays.copyOfRange(BodyRec, 6, BodyRec.length);
        break;
      case 5:
        mapAress.put(5, Arrays.copyOfRange(BodyRec, 0, 6));
        BodyRec = Arrays.copyOfRange(BodyRec, 6, BodyRec.length);
        break;
      case 6:
        mapAress.put(6, Arrays.copyOfRange(BodyRec, 0, 6));
        BodyRec = Arrays.copyOfRange(BodyRec, 6, BodyRec.length);
        break;
      case 7:
        mapAress.put(7, Arrays.copyOfRange(BodyRec, 0, 4));
        BodyRec = Arrays.copyOfRange(BodyRec, 4, BodyRec.length);
        break;
      default:
        i = 99;
        break;
      }
    }

    byte[] val4 = { 0, 0, 0, 0 };
    byte[] val6 = { 0, 0, 0, 0, 0, 0 };
    byte[] val8 = { 0, 0, 0, 0, 0, 0, 0, 0 };
    ByteBuffer byteBuf = ByteBuffer.allocate(64);
    byteBuf.put(NxRec);

    for (int i = 2; i < 8; i++) {
      if (mapAress.get(i) != null) {
        byteBuf.put(mapAress.get(i));
      } else {
        switch (i) {
        case 2:
          byteBuf.put(val4);
          break;
        case 3:
          byteBuf.put(val8);
          break;
        case 4:
        case 5:
        case 6:
          byteBuf.put(val6);
          break;
        case 7:
          byteBuf.put(val4);
          break;
        }
      }
    }
    byteBuf.put(checkRec);
    this.setRec(byteBuf.array());
    // 電文項目のヌルと空文字チェック
    validNullEmptyIkkiko(this);
  }

  /**
   * NX通信電文項目のnull、空文字チェックを行います。
   * 
   * @throws InvalidAlertFormatException
   *           必須項目でnullもしくは空文字が存在する場合
   */
  private void validNullEmptyIkkiko(MNoticeTelegram telegram) {
    final List<String> messages = new ArrayList<>();
    // チェックディジット処理
    if (telegram.getCheckSum() != telegram.getCheckDigit()) {
      messages.add(MNoticeError.CHECK_DIGIT + " 期待値:" + telegram.getFV(TelegramElement.CHECK_SUM).toString() + ", 実際の値:"
          + telegram.getCheckDigit());
    } else {
      // チェックデジットが正しければ、null・空文字チェックを行う
      if (isEmpty(telegram.getFV(TelegramElement.MODEL_CODE).toString())) {
        messages.add(NullEmptyMessage.MODEL_CODE);
      }
      if (isEmpty(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString())) {
        messages.add(NullEmptyMessage.SERIAL_NUMBER);
      }
      if (isEmpty(telegram.getFV(TelegramElement.FACILITY_CODE).toString())) {
        messages.add(NullEmptyMessage.FACILITY_CODE);
      }
      if (isEmpty(telegram.getFV(TelegramElement.OCCURRENCE_DATE).toString())) {
        messages.add(NullEmptyMessage.OCCURRENCE_DATE);
      }
      if (isEmpty(telegram.getFV(TelegramElement.OCCURRENCE_TIME).toString())) {
        messages.add(NullEmptyMessage.OCCURRENCE_TIME);
      }
      if (isEmpty(telegram.getFV(TelegramElement.RECORDING_CODE).toString())) {
        messages.add(NullEmptyMessage.RECORDING_CODE);
      }
      if (isEmpty(telegram.getFV(TelegramElement.CHECK_SUM).toString())) {
        messages.add(NullEmptyMessage.CHECK_SUM);
      }
    }

    if (!messages.isEmpty()) {
      throw new InvalidAlertFormatException(String.format("%s", String.join(", ", messages)));
    }
  }

  /**
   * 装置記録補助データに設定するデータを作成します。
   * 
   * @return 装置記録補助データリスト
   */
  public List<String> getAddressDatasAsHexString() {
    String address2 = (String) this.getFV(TelegramElement.ADDRESS2);
    String humanDetection = (String) this.getFV(TelegramElement.HUMAN_DETECTION);
    String address3 = (String) this.getFV(TelegramElement.ADDRESS3);
    String decimalPosition = (String) this.getFV(TelegramElement.DECIMAL_POSITION);
    String changeBefore = (String) this.getFV(TelegramElement.CHANGE_BEFORE);
    String address4 = (String) this.getFV(TelegramElement.ADDRESS4);
    String changeAfter = (String) this.getFV(TelegramElement.CHANGE_AFTER);
    String address5 = (String) this.getFV(TelegramElement.ADDRESS5);
    String extendedData1 = (String) this.getFV(TelegramElement.EXTENDED_DATA1);
    String address6 = (String) this.getFV(TelegramElement.ADDRESS6);
    String extendesData2 = (String) this.getFV(TelegramElement.EXTENDED_DATA2);
    String address7 = (String) this.getFV(TelegramElement.ADDRESS7);
    String reserve = (String) this.getFV(TelegramElement.RESERVE);
    return Arrays.asList(address2, humanDetection, address3, decimalPosition, changeBefore, address4, changeAfter,
        address5, extendedData1, address6, extendesData2, address7, reserve);
  }
}
