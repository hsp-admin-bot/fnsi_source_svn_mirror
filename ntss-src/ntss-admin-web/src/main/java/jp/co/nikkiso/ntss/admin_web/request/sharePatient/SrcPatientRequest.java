package jp.co.nikkiso.ntss.admin_web.request.sharePatient;

import java.util.List;

import lombok.Data;

@Data
public class SrcPatientRequest {

    /**
     * 施設IDソース .
     */
    private String facilityCdLogin;
    /**
     * 施設ID先.
     */
    private Long patIdDst;
    /**
     * 患者IDソース .
     */
    private Long patIdSrc;

    /**
     * 受理した患者情報一覧 .
     */
    private List<ReceivedPatientInfoInput> receivedPatientInfos;
}
