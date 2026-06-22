package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;

public interface MntMotionRecordService {
  /**
   * 装置記録にメンテナンス情報を登録
   * @param param 装置記録
   * @return
   */
  int insertMntMotion(MntMotionRecord param);

  /**
   * 装置記録に溶解記録情報を登録
   * @param param 装置記録
   * @return
   */
  int insertDarMotion(MntMotionRecord param);

  /**
   * 装置記録を登録(メッセージ変換あり)
   * @param param 装置記録
   * @param aux_data_array_0 パラメータ1
   * @param aux_data_array_1 パラメータ2
   * @param aux_data_array_2 パラメータ3
   * @param aux_data_array_3 パラメータ4
   * @return
   */
  int insertLogMotion(MntMotionRecord param,
      String aux_data_array_0,
      String aux_data_array_1,
      String aux_data_array_2,
      String aux_data_array_3);

  /**
   * 装置記録を登録(メッセージ変換なし)
   * @param param 装置記録
   * @return
   */
  int insertLogMotionMessage(MntMotionRecord param);

  /**
   * 装置記録(オーダー番号付)を登録(メッセージ変換あり)
   * @param param 装置記録
   * @param aux_data_array_0 パラメータ1
   * @param aux_data_array_1 パラメータ2
   * @param aux_data_array_2 パラメータ3
   * @param aux_data_array_3 パラメータ4
   * @return
   */
  int insertLogMotionAndOrdNo(MntMotionRecord param,
      String aux_data_array_0,
      String aux_data_array_1,
      String aux_data_array_2,
      String aux_data_array_3);

  /**
   * 装置記録(オーダー番号付)を登録(メッセージ変換なし)
   * @param param 装置記録
   * @return
   */
  int insertLogMotionMessageAndOrdNo(MntMotionRecord param);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  MntMotionRecord findByManageNo(Long motionRecordNo);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
}
