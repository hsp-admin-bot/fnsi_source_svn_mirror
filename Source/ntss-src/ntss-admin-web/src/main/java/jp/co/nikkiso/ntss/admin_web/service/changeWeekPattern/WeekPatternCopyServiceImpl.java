package jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern;

import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dto.OrdMain.OrdNoTreatDateCopyDto;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentInstance;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WeekPatternCopyServiceImpl implements WeekPatternCopyService{

  @Autowired
  MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  OrdMaterialSaveService ordMaterialSaveService;

  @Autowired
  OrdScheduleDao ordScheduleDao;

  @Autowired
  PatIndApproveDao patIndApproveDao;

  @Autowired
  WeekPatternInfoServiceImpl weekPatternInfoServiceImpl;

  @Autowired
  private OrdMainService ordMainService;

  @Getter
  @Setter
  public static class CopyPlanResult {
    private boolean success;
    private List<OrdMain> ordMainList;
  }

  public CopyPlanResult weekPatternCopy(List<TreatmentInstance> treatmentInstanceList,
                                       WeekPatternResponse weekResponse,
                                                      String facilityCd,
                                                      Long patId,
                                                      Long ind_user_id,
                                                      Long upd_user_id) {

    CopyPlanResult result = new CopyPlanResult();

    String endDate = weekResponse.getWeekChangeEndDate();

    String indTreatStartDate = weekResponse.getWeekChangeStartDate();

    List<OrdNoTreatDateCopyDto> copyDtoList = new ArrayList<>();
    List<OrdNoTreatDateCopyDto> patternCopyDtoList = new ArrayList<>();
    if (treatmentInstanceList != null && !treatmentInstanceList.isEmpty()) {
      for (TreatmentInstance instance : treatmentInstanceList) {
        if (TreatmentInstance.ChangeType.COPY.equals(instance.getChangeType())) {
          OrdNoTreatDateCopyDto dto = new OrdNoTreatDateCopyDto(instance.getOrdNo(), instance.getTreatDate(), instance.getBedCd());
          if (TreatmentInstance.Source.ORD_MAIN.equals(instance.getSource())
            && weekPatternInfoServiceImpl.isInRange(instance.getTreatDate(), indTreatStartDate, endDate)) {

            copyDtoList.add(dto);
          } else if (TreatmentInstance.Source.PAT_TREATMENT_PATTERN.equals(instance.getSource())
            && weekPatternInfoServiceImpl.isInRange(instance.getTreatDate(), indTreatStartDate, endDate)) {
            patternCopyDtoList.add(dto);
          }
        }
      }
    }

    boolean hasCopyAction = !copyDtoList.isEmpty() || !patternCopyDtoList.isEmpty();

    if (!hasCopyAction) {
      result.setOrdMainList(Collections.emptyList());
      result.setSuccess(true);
      return result;
    }

    List<OrdMain> updatedOrdMainList = new ArrayList<>();

    if (!copyDtoList.isEmpty()) {
      updatedOrdMainList.addAll(
        ordMainDao.insertOrdMainForTreatDateCopy(copyDtoList, ind_user_id, upd_user_id)
      );
    }

    if (!patternCopyDtoList.isEmpty()) {
      updatedOrdMainList.addAll(
        ordMainDao.insertOrdMainFromTreatmentPattern(
          patternCopyDtoList, facilityCd, patId, ind_user_id, upd_user_id
        )
      );
    }

    List<Long> ordNoList = updatedOrdMainList.stream()
      .map(OrdMain::getOrdNo)
      .collect(Collectors.toList());

    if (!ordNoList.isEmpty()) {
      backfillEquipNoForCopiedOrdMain(updatedOrdMainList, ind_user_id, upd_user_id);
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(ordNoList);
      patIndApproveDao.insertList(ordNoList, facilityCd);
    }

    result.setOrdMainList(updatedOrdMainList);
    result.setSuccess(!hasCopyAction || !updatedOrdMainList.isEmpty());

    return result;
  }

  /**
   * 週パターンコピー後に、医療材料JSONのno欠損を補完する.
   */
  private void backfillEquipNoForCopiedOrdMain(List<OrdMain> ordMainList, Long indUserId, Long updUserId) {
    for (OrdMain ord : ordMainList) {
      JSONArray indEquipArr = new JSONArray(ObjectUtils.isEmpty(ord.getIndEquipInfo()) ? "[]" : ord.getIndEquipInfo());
      JSONArray rstEquipArr = new JSONArray(ObjectUtils.isEmpty(ord.getRstEquipInfo()) ? "[]" : ord.getRstEquipInfo());
      boolean hasChanged = false;

      for (int i = 0; i < indEquipArr.length(); i++) {
        JSONObject indEquip = indEquipArr.getJSONObject(i);
        if (!indEquip.has("no") || indEquip.isNull("no") || "0".equals(indEquip.get("no").toString())) {
          long newNo = ordMainService.selectMaxEquipInfoNo(ord.getFacilityCd(), String.valueOf(ord.getPatId()));
          indEquip.put("no", newNo);
          hasChanged = true;

          String indCd = indEquip.opt("cd") == null ? "" : indEquip.opt("cd").toString();
          String indEquipType = indEquip.opt("equip_type") == null ? "0" : indEquip.opt("equip_type").toString();
          for (int j = 0; j < rstEquipArr.length(); j++) {
            JSONObject rstEquip = rstEquipArr.getJSONObject(j);
            String rstCd = rstEquip.opt("cd") == null ? "" : rstEquip.opt("cd").toString();
            String rstEquipType = rstEquip.opt("equip_type") == null ? "0" : rstEquip.opt("equip_type").toString();
            if (indCd.equals(rstCd) && indEquipType.equals(rstEquipType)
              && (!rstEquip.has("no") || rstEquip.isNull("no") || "0".equals(rstEquip.get("no").toString()))) {
              rstEquip.put("no", newNo);
            }
          }
        }
      }

      if (hasChanged) {
        ord.setIndEquipInfo(indEquipArr.toString());
        ord.setRstEquipInfo(rstEquipArr.toString());
        ordMainDao.updateOrdMainEquipInfoAndUserId(
          ord.getOrdNo(), ord.getIndEquipInfo(), ord.getRstEquipInfo(), indUserId, updUserId, true
        );
      }
    }
  }
}
