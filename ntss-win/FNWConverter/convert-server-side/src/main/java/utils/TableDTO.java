package utils;

import lombok.Getter;
import lombok.Setter;

public class TableDTO implements Comparable<TableDTO>{
    @Getter
    @Setter
    private String tabName;
    @Getter
    @Setter
    private String comment;
    @Getter
    @Setter
    private Integer count;

    @Override
    public String toString() {
        return tabName + "," + comment + "," + count;
    }

    @Override
    public int compareTo(TableDTO tableDTO) {
        return this.count - tableDTO.count;
    }
}
