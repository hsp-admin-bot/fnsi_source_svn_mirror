export class TabModel {
    constructor(cd, name, sort, filter, dataSource) {
        this.cd = cd;
        this.name = name;
        this.sort = sort;
        this.filter = filter;
        this.dataSource = dataSource;
        this.rowSelected = null;
        this.cellSelected = null;
        this.rowActive = null;
    }
}
