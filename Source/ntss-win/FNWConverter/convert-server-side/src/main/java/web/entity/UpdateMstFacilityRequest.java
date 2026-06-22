package web.entity;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

public class UpdateMstFacilityRequest {
    private String facilityCd;

    public String getFlag() {
        return flag;
    }

    public void setFlag(String flag) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (!"0".equals(flag) && !"1".equals(flag)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Forbidden"
            );
        }
        //#12737 【securify】convert-server-sideが落ちる end
        this.flag = flag;
    }

    private String  flag;

    public String getFacilityCd() {
        return facilityCd;
    }

    public void setFacilityCd(String facilityCd) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (facilityCd == null || facilityCd.length() > 110) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Forbidden"
            );
        }
        try {
            ObjectMapper mapper = new ObjectMapper();

            List<String> values = mapper.readValue(
                    facilityCd,
                    new TypeReference<List<String>>() {}
            );

            // ハッシュは1つだけ許可されます
            if (values.size() != 1) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }

            String hash = values.get(0);

            //データベース定義varchar(100)
            if (hash == null || hash.length() > 100) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }

        } catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Forbidden"
            );
        }
        //#12737 【securify】convert-server-sideが落ちる end
        this.facilityCd = facilityCd;
    }
}
