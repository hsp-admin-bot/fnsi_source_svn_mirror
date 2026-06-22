package jp.co.nikkiso.ntss.m_notice.packet;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeError;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.NullEmptyMessage;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramElement;

/**
 * 日機装装置の構造体クラス
 */
public class NikkisoMNoticeTelegram extends MNoticeTelegram {

  /**
   * 日機装装置電文のデータを分解します。
   * 
   * @param buffer 日機装装置電文
   */
  public NikkisoMNoticeTelegram(byte[] buffer) {
    this.FD_X(TelegramElement.MODEL_CODE, 1, 3);
    this.FD_X(TelegramElement.COM_FORMAT_CD, 4, 1);
    this.FD_X(TelegramElement.SERIAL_NUMBER, 5, 8);
    this.FD_X(TelegramElement.FACILITY_CODE, 13, 6);
    this.FD_B(TelegramElement.OCCURRENCE_DATE, 19, 4);
    this.FD_B(TelegramElement.OCCURRENCE_TIME, 23, 3);
    this.FD_X(TelegramElement.RECORDING_CODE, 26, 4);
    this.FD_V(TelegramElement.RECORDING_DATA1, 30, 2);
    this.FD_V(TelegramElement.RECORDING_DATA2, 32, 2);
    this.FD_V(TelegramElement.RECORDING_DATA3, 34, 2);
    this.FD_V(TelegramElement.RECORDING_DATA4, 36, 2);
    this.FD_V(TelegramElement.CHECK_SUM, 38, 1);
    this.setRec(buffer);
    // 電文項目のヌルと空文字、チェックディジットチェック
    validNullEmptyNikkiso(this);
  }

  /**
   * 日機装装置電文項目のnull、空文字チェックを行います。
   * 
   * @throws InvalidAlertFormatException
   *           必須項目でnullもしくは空文字が存在する場合
   */
  private void validNullEmptyNikkiso(MNoticeTelegram telegram) {
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
  public List<String> getRecordingDatasAsHexString() {
    String recordData1 = (String) this.getFV(TelegramElement.RECORDING_DATA1);
    String recordData2 = (String) this.getFV(TelegramElement.RECORDING_DATA2);
    String recordData3 = (String) this.getFV(TelegramElement.RECORDING_DATA3);
    String recordData4 = (String) this.getFV(TelegramElement.RECORDING_DATA4);
    return Arrays.asList(recordData1, recordData2, recordData3, recordData4);
  }
}
