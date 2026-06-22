package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.ordMain.JournalCreateRequestResponse;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.JournalCreatecallNextPatIdRequestResponse;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;

import java.util.List;


public interface OrdMainCudService {

  // mod bug 8157 修正 chen start
  /**
   * 医材追加
   * @param bodyDataList
   * @return
   */
  JournalCreateRequestResponse createOrdMainEquipInfoBatch(List<ApiEntityOrdMain.ValiOrdEquip> bodyDataList);

  /**
   * 医材削除
   * @param bodyData
   * @return
   */
  JournalCreateRequestResponse deleteOrdMainEquipInfo(ApiEntityOrdMain.ValiOrdEquip bodyData);


  /**
   *薬剤追加
   * @param bodyDataList
   * @return
   */
  JournalCreatecallNextPatIdRequestResponse createOrdMainMediInfoBatch(List<ApiEntityOrdMain.ValiOrdMedi> bodyDataList);

  /**
   * 薬剤削除
   * @param bodyData
   * @return
   */
  JournalCreatecallNextPatIdRequestResponse deleteOrdMainMediInfo(ApiEntityOrdMain.ValiOrdMedi bodyData);

  /**
   * コメント追加、コメント削除、コメント修正
   * @param bodyData
   * @param userId
   * @return
   */
  JournalCreateRequestResponse updateIndComment(ApiEntityOrdMain.ValiCommentCreate bodyData,Long userId);
  // add bug 8157 修正 chen mod

  /* add by chamaojia 2024-02-06 [10196] Convert empty parameters to JSONObject.NULL --start */
  Object changeToJSONObjectNull(Object object);
  /* add by chamaojia 2024-02-06 [10196] Convert empty parameters to JSONObject.NULL --end */

}
