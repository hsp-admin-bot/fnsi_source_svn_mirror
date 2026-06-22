package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * クライアント証明書機能
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "client_cer_facility")
@Getter
@Setter
public class ClFacility {

   //add FNSI-【1006】最新の改修対象一覧.NO50を修正 周安寧 start
    //Id
    @Id
    private Integer Id;
    //add FNSI-【1006】最新の改修対象一覧.NO50を修正 周安寧 END
    //施設ID
    //DEL FNSI-【1006】最新の改修対象一覧.NO50を修正 周安寧 START
    //@Id
    //DEL FNSI-【1006】最新の改修対象一覧.NO50を修正 周安寧 END
    private String facilityCd;

    //施設名
    private String facilityName;

    //施設のパスワード
    private String facilityPassword;

    //失敗したサインインの数
    private int attemptFail;

    //登録日
    private Timestamp regDate;

    //更新日
    private Timestamp upDate;

    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    // 仮登録フラグ
    private int isProvisional;

    /**
     * 削除フラグ
     */
    private String isDelete;
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
