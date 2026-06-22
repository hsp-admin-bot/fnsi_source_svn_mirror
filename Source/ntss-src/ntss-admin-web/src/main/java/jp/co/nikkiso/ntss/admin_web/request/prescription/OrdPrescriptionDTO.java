package jp.co.nikkiso.ntss.admin_web.request.prescription;

import jakarta.validation.constraints.NotNull;

import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import lombok.Data;

@Data
public class OrdPrescriptionDTO {
    /**
     * 処方情報(認証DB)のEntity.
     */
    @NotNull
    private OrdPrescription ordPrescription;

    /**
     * 処方情報(認証DB)のEntity.
     * 
     */
    @NotNull
    private OrdPersonalPrescription ordPersonalPrescription;
}
