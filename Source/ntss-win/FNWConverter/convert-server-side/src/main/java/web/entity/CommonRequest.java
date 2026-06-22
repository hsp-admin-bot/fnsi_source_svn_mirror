package web.entity;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

public class CommonRequest {

    private String facilityCd;

    public String getFacilityCd() {
        return facilityCd;
    }

    public void setFacilityCd(String facilityCd) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (facilityCd == null) {
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

            if (values == null|| values.isEmpty()) {

                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }

            //データベース定義varchar(100)
            for (String hash : values) {

                if (hash == null || hash.length() > 100) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }
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
