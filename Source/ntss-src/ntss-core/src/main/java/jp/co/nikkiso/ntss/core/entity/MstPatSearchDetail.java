package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 詳細患者検索
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_search_detail")
@Getter
@Setter
public class MstPatSearchDetail extends BaseEntity {

    /**
     * 詳細患者検索コード.
     */
    @Id
    private Long searchCd;
    
    /**
     * 詳細患者検索名.
     */
    private String searchName;
    

    /**
     * 施設コード.
     */
    private String facilityCd;

    /**
     * 利用者ID.
     */
    private Long userId;

    /**
     * 検索条件内容.
     */
    private String searchCondition;

    /**
     * 表示フラグ.
     * ('0': 非表示、'1': 表示)
     */
    private String isDisp;

    /**
     * 削除フラグ.
     * ('0': 通常、'1': 削除)
     */
    private String isDel;
}
