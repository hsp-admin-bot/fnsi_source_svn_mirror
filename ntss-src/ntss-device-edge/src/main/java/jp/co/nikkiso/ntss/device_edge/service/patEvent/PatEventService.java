package jp.co.nikkiso.ntss.device_edge.service.patEvent;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatEventDataTemplate;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.device_edge.response.patEvent.PatEventMasterResponse;

public interface PatEventService {

//  Page<PatEvent> findAll(Pageable pageable);
//
  List<PatEvent> selectByPatIdNewest(Long pat_id, Timestamp event_start_date_from, Timestamp event_start_date_to);

  List<PatEvent> selectByCd(Long pat_event_cd);

  List<PatEvent> create(List<PatEvent> patEvent);

  PatEvent update(PatEvent patEvent);

  PatEvent updateResultParams(PatEvent patEvent);

  PatEvent updateBbsCtlNo(PatEvent patEvent);

  void delete(Long pat_event_cd);

  PatEventMasterResponse findPatEventMaster(String facilityCd);

  List<MstPatEventDataTemplate> selectPatEventTemplate(String facilityCd);

  List<MstPatEventSubCategory> selectPatEventSubCategory(String facilityCd);

  List<MstPatEventCategory> selectPatEventCategory(String facilityCd);

  /**
   * ファイルダウンロード
   * @throws Exception
   */
   String downloadEventFileAttachment(String filepath) throws Exception;

  /**
   * ファイルアップロード
   * @throws Exception
   */
   void uploadEventFileAttachment(MultipartFile file, String patEvent) throws Exception;

  /**
   * ファイル削除
   * @throws Exception
   */
   void deleteEventFileAttachment(List<Map<String, String>> fileInfo, Long pat_id) throws Exception;

   /**
    * イメージファイルダウンロード
    * @throws Exception
    */
    String downloadEventImageAttachment(String filepath, Timestamp upDate, String facilityCd) throws Exception;

   /**
    * イメージファイルアップロード
    * @throws Exception
    */
    void uploadEventImageAttachment(MultipartFile file, String patEvent) throws Exception;

   /**
    * イメージファイル削除
    * @throws Exception
    */
    void deleteEventImageAttachment(List<Map<String, String>> fileInfo, Long pat_id) throws Exception;

}
