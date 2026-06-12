package jp.co.nikkiso.ntss.admin_web.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.response.reLoopRateMain.RecirculationRateComment;
import jp.co.nikkiso.ntss.admin_web.response.reLoopRateMain.RecirculationRateDTO;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReloopInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@Service
public class RecirculationRateCommentServiceImpl implements RecirculationRateCommentService {

    @Autowired
    private OrdMainDao ordMainDao;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

    /**
     * 治療記録Service.
     */
    @Autowired
    private TreatmentRecordService treatmentRecordService;

    @Override
    public RecirculationRateDTO get(Long ordNo) {
        ObjectMapper mapper = new ObjectMapper();
        OrdMainRstWeightInfo weightInfo = getOrdMainRstWeightInfo(ordNo);
        String reloopInfo = weightInfo.getReloopInfo();
        try {
            List<ReloopInfo> reloopInfos = null;
            if (reloopInfo == null || reloopInfo.isEmpty()) {
                reloopInfos = new ArrayList<>();
            } else {
                reloopInfos = mapper.readValue(reloopInfo, new TypeReference<List<ReloopInfo>>() {
                });
            }
            List<RecirculationRate> recirculationRates = treatmentRecordService.getRecirculationRate(ordNo);
            List<RecirculationRateComment> comments = merge(reloopInfos, recirculationRates);

            reloopInfos = new ArrayList<>();
            for (RecirculationRateComment c : comments) {
                ReloopInfo loopRateMain = new ReloopInfo();
                loopRateMain.setBioMoniCtlNo(c.getBioMoniCtlNo());
                loopRateMain.setReloopComment(c.getReloopComment());
                reloopInfos.add(loopRateMain);
            }
            update(ordNo, reloopInfos);

            RecirculationRateDTO dto = new RecirculationRateDTO();
            dto.setWeightInfo(getOrdMainRstWeightInfo(ordNo));
            dto.setComments(comments);
            return dto;
        } catch (tools.jackson.core.JacksonException e) {
            throw new NtssException(e);
        }
    }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

    @Override
    public void update(Long ordNo, OrdMainRstWeightInfo dto) {
        try {

          // add FNSI-改修内容追加OrdMain履歴 付 start
          getHistory(ordNo);
          // mangoDb-updateWeightInfo-insertSuccess
          // add FNSI-改修内容追加OrdMain履歴 付 end

            ObjectMapper mapper = new ObjectMapper();
            ordMainDao.updateWeightInfo(ordNo, mapper.writeValueAsString(dto));
        } catch (tools.jackson.core.JacksonException e) {
            throw new NtssException(e);
        }
    }

    private void update(Long ordNo, List<ReloopInfo> reloopInfos) {
        try {

          // add FNSI-改修内容追加OrdMain履歴 付 start
          getHistory(ordNo);
          // mangoDb-updateWeightInfo-insertSuccess
          // add FNSI-改修内容追加OrdMain履歴 付 end

            ObjectMapper mapper = new ObjectMapper();
            OrdMainRstWeightInfo dto = getOrdMainRstWeightInfo(ordNo);
            dto.setReloopInfo(mapper.writeValueAsString(reloopInfos));
            ordMainDao.updateWeightInfo(ordNo, mapper.writeValueAsString(dto));
        } catch (tools.jackson.core.JacksonException e) {
            throw new NtssException(e);
        }
    }

    private List<RecirculationRateComment> merge(List<ReloopInfo> reloopInfos,
            List<RecirculationRate> recirculationRates) {
        final Map<Long, RecirculationRateComment> headersMap = new LinkedHashMap<>();

        for (final RecirculationRate recirculationRate : recirculationRates) {
            headersMap.put(recirculationRate.getBioMoniCtlNo(), mapTorecirculationRateComment(recirculationRate));
        }

        for (final ReloopInfo reloopInfo : reloopInfos) {
            if (headersMap.containsKey(reloopInfo.getBioMoniCtlNo())) {
                RecirculationRateComment recirculationRateComment = headersMap.get(reloopInfo.getBioMoniCtlNo());
                recirculationRateComment.setReloopComment(reloopInfo.getReloopComment());
                headersMap.put(reloopInfo.getBioMoniCtlNo(), recirculationRateComment);
            }
        }

        return new ArrayList<RecirculationRateComment>(headersMap.values());
    }

    private OrdMainRstWeightInfo getOrdMainRstWeightInfo(Long ordNo) {
        String weight = ordMainDao.selectWeightInfo(ordNo);
        ObjectMapper mapper = new ObjectMapper();
        try {
            return weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
                    : mapper.readValue(weight, OrdMainRstWeightInfo.class);
        } catch (tools.jackson.core.JacksonException e) {
            throw new NtssException(e);
        }
    }

    private RecirculationRateComment mapTorecirculationRateComment(RecirculationRate rate) {
        return new RecirculationRateComment(rate.getBioMoniCtlNo(), rate.getDate(), rate.getRecirculationRate(),
                rate.getBloodFlow(), null);
    }

}
