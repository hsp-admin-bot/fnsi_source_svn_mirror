package jp.co.nikkiso.ntss.web_api.web.rest;

import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


import java.util.ArrayList;
import java.util.List;

// add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
@RestController
@RequestMapping("convertUtil")
public class ConvertAppResource {
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//  @Autowired
//  private AsyncMaterialSaveHandlerTask asyncMaterialSaveHandlerTask;
  // del 12250 ord_material_saveの処理を2回重複実行している zkm end


  @PostMapping("/SetOrdMaterialSave")
  public ResponseEntity<String> setOrdMaterialSaveHandleResponse(@RequestBody String bodydata) {
    JSONObject receiveData = new JSONObject(bodydata);
    List<Long> ordMainCdList = new ArrayList<>();
    int rscounts = -1;
    try {
      JSONArray ordMainCdArray = receiveData.getJSONArray("ordMainCds");
      for (int i = 0; i < ordMainCdArray.length(); i++) {
        ordMainCdList.add(ordMainCdArray.getLong(i));
      }

      // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//      rscounts = ordMaterialSaveService.batchProcessingDataMod(
//        asyncMaterialSaveHandlerTask.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveBatchHandleDTO(
//            ordMainCdList,
//            null,
//            OrdMaterialSaveBatchHandleDTO.getBatchModifiedMode(
//              true, true, true, true,
//              receiveData.getBoolean("indRstFlag") ? OrdMaterialSaveDto.RST_CLASS : OrdMaterialSaveDto.IND_CLASS,
//              receiveData.getBoolean("rstUpdFlag")
//            )
//            // mod #10843 djy start
//            //)
//          ),receiveData.getBoolean("diffFlag")
//          // mod #10843 djy start
//        )
//      );
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(ordMainCdList);
      // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    } catch (Exception ex) {
      return new ResponseEntity<String>(ex.toString(),HttpStatus.INTERNAL_SERVER_ERROR);
    }

    return new ResponseEntity<String>(String.valueOf(rscounts),HttpStatus.OK);
  }

  /**
   * 処方情報対応追加
   *
   * @param bodyData  param
   * @return
   */
  @PostMapping("/setOrdRPMaterialSave")
  public ResponseEntity<String> setOrdPrescriptionMaterialSave(@RequestBody String bodyData) {
    int rsCounts = -1;

    try {
      JSONObject receiveData = new JSONObject(bodyData);
      JSONArray ordRpCdArray = receiveData.getJSONArray("ordRpCds");
      if (ordRpCdArray != null && ordRpCdArray.length() > 0) {
        List<Long> ordRpCdList = new ArrayList<>(ordRpCdArray.length());

        for (int i = 0; i < ordRpCdArray.length(); i++) {
          ordRpCdList.add(ordRpCdArray.getLong(i));
        }

        rsCounts = this.ordMaterialSaveService.savePrescriptionOrdMaterialSaveByPks(ordRpCdList);
      }

    } catch (Exception ex) {
      return new ResponseEntity<>(ex.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
    return new ResponseEntity<>(String.valueOf(rsCounts), HttpStatus.OK);
  }
}
// add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
