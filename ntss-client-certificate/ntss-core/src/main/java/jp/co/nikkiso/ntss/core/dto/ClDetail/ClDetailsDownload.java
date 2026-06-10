package jp.co.nikkiso.ntss.core.dto.ClDetail;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class ClDetailsDownload {

    private String passwordCl;

    private Timestamp expiredDate;

    private Integer maxDownload;

    private Integer curDownload;

    private String facilityCd;

    private String facilityName;
  //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
    private Integer clCertificateId;
  //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end

    private String manyFacilityName;
  private String manyFacilityCd;
}
