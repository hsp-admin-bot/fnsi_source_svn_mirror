package jp.co.nikkiso.ntss.admin_web.request.sharePatient;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.PublicPatientInfo;
import lombok.Data;

@Data
public class DstPatientRequest {

    /**
     * 施設ID .
     */
    private String facilityCdLogin;

    /**
     * 患者ID .
     */
    private Long patId;

    /**
     * 患者情報 .
     */
    private List<PublicPatientInfo> publicPatientInfos;

    //add FNSI-削除ボタンがクリックできないバグを修正します 江 start
    private List<Long> deletedPatNameId;
    //add FNSI-削除ボタンがクリックできないバグを修正します 江 end

}
