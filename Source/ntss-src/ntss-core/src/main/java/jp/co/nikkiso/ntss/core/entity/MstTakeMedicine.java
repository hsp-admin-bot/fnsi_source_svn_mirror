package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_take_medicine")
@Getter
@Setter
public class MstTakeMedicine extends BaseEntity {

    /**
     * 用法用語マスタコード
     */
    @Id
    private Long takeMedicineCd;
    /**
     * 施設コード
     */
    private String facilityCd;
    /**
     * リスト種別
     */
    private String listClass;
    /**
     * リスト名
     */
    private String listName;
    /**
     * リスト選択肢
     */
    private String listDetails;
    /**
     * 表示フラグ
     */
    private String isDisp;
    /**
     * 削除フラグ
     */
    private String isDel;
}
