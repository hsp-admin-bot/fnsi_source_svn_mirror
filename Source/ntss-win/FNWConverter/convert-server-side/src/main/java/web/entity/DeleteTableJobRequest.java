package web.entity;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.net.InetAddress;
import java.util.List;

public class DeleteTableJobRequest {

    private String facilityCd;

    private String ip;

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

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (ip == null || ip.isBlank() || ip.length() > 200) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        //パス通過の禁止
        if (ip.contains("../")
                || ip.contains("..\\")) {

            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        //#12737 【securify】convert-server-sideが落ちる end
        this.ip = ip;
    }
}
