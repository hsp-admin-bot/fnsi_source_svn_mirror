package jp.co.nikkiso.ntss.m_notice.packet;

import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeError;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.NullEmptyMessage;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramElement;

/**
 * 医器工装置の構造体クラス
 */
public class IkikoMNoticeTelegram extends MNoticeTelegram {

  /**
   * 医器工装置電文のデータを分解します。
   * 
   * @param buffer 医器工装置電文
   */
  public IkikoMNoticeTelegram(byte[] buffer) {
    this.FD_X(TelegramElement.MODEL_CODE, 1, 3);
    this.FD_X(TelegramElement.COM_FORMAT_CD, 4, 1);
    this.FD_X(TelegramElement.SERIAL_NUMBER, 5, 8);
    this.FD_X(TelegramElement.FACILITY_CODE, 13, 6);
    this.FD_B(TelegramElement.OCCURRENCE_DATE, 19, 4);
    this.FD_B(TelegramElement.OCCURRENCE_TIME, 23, 3);
    this.FD_X(TelegramElement.RECORDING_CODE, 26, 4);
    this.FD_X(TelegramElement.RECORDING_MESSAGE, 30, 50);
    this.FD_V(TelegramElement.CHECK_SUM, 80, 1);
    this.setRec(buffer);
    // 電文項目のヌルと空文字チェック
    validNullEmptyIkkiko(this);
  }

  /**
   * 医器工装置電文項目のnull、空文字チェックを行います。
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
      if (isEmpty(telegram.getFV(TelegramElement.RECORDING_MESSAGE).toString())) {
        messages.add(NullEmptyMessage.RECORDING_MESSAGE);
      }
      if (isEmpty(telegram.getFV(TelegramElement.CHECK_SUM).toString())) {
        messages.add(NullEmptyMessage.CHECK_SUM);
      }
    }

    if (!messages.isEmpty()) {
      throw new InvalidAlertFormatException(String.format("%s", String.join(", ", messages)));
    }
  }
}
