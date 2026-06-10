package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;

public interface MntMotionRecordService {
  int insertMntMotion(MntMotionRecord param);

  int insertDarMotion(MntMotionRecord param);

  int insertLogMotion(MntMotionRecord param,
      String aux_data_array_0,
      String aux_data_array_1,
      String aux_data_array_2,
      String aux_data_array_3);

  //add #269:強制オフライン 劉 start
  int insertLogMotionAndOrdNo(MntMotionRecord param,
      String aux_data_array_0,
      String aux_data_array_1,
      String aux_data_array_2,
      String aux_data_array_3);
  //add #269:強制オフライン 劉 end

  int insertLogMotionMessage(MntMotionRecord param);

  //add #269:強制オフライン 劉 start
  int insertLogMotionMessageAndOrdNo(MntMotionRecord param);
  //add #269:強制オフライン 劉 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  int insertLogMotionMessageCommFail(MntMotionRecord param);
  int insertLogMotionCommFail(MntMotionRecord param,
                      String aux_data_array_0,
                      String aux_data_array_1,
                      String aux_data_array_2,
                      String aux_data_array_3);
  // add AWSとDEの通信断からの復旧 --趙-- end
}
