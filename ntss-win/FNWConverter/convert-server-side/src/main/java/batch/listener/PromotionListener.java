package batch.listener;

import org.springframework.batch.core.listener.ExecutionContextPromotionListener;

import batch.ApplicationConst.YmlElementNames;

/**
 * 後続ステップに値を受け渡すリスナー
 */
public class PromotionListener extends ExecutionContextPromotionListener {
    
    public PromotionListener(){
        String[] keySet = {
            YmlElementNames.RELATION_TO_TABLE_NAME
        };
        this.setKeys(keySet);
    }
}