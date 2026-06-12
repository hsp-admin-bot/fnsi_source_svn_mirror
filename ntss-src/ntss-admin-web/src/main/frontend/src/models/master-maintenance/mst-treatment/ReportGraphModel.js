import {
    REPORT_GRAPH
} from "@/constants/mstTreatmentDefine.js";

/**
 * 帳票グラフを表現するクラス.
 */
export class ReportGraph {
    /**
     * コンストラクタ
     * @param {Boolean} isBp 血圧か否か
     *                       血圧の場合、true
     *                       血圧以外の場合はfalse(デフォルト)
     * @param {String} monitorItemCd モニタ項目コード(デフォルト："-")
     * @param {Number} monitorType モニタ区分(デフォルト:0)
     *                              1:sys_monitor_item
     *                              2:mst_add_monitor
     * @param {Number} graphMax グラフ上限値(デフォルト:null)
     * @param {Number} graphMin グラフ下限値(デフォルト:null)
     * @param {String} plotType プロット形状(デフォルト："-")
     * @param {String} plotColor プロット色(デフォルト："#FFFFFF")
     * @param {Number} plotSize プロットサイズ(デフォルト：1)
     * @param {String} lineType 線種(デフォルト："-")
     * @param {String} lineColor 線色(デフォルト："#FFFFFF")
     * @param {Number} lineThickness 線の太さ(デフォルト：1)
     * @param {Boolean} show_check 血圧利用フラグ(デフォルト：true)
     */
    constructor(
        isBp = false,
        monitorItemCd = "-",
        monitorType = 0,
        graphMax = null,
        graphMin = null,
        // add 8071 治療方法のグラフ設定が反映されない 吉 start
        plotType = "triangle",
        // add 8071 治療方法のグラフ設定が反映されない 吉 end
        plotColor = "#FFFFFF",
        plotSize = 1,
        lineType = "triangle",
        lineColor = "#FFFFFF",
        lineThickness = 1,
        // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
        show_check = true
        // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
    ) {
        this.isBp = isBp;
        this.monitorItemCd = monitorItemCd;
        this.monitorType = monitorType;
        this.graphMax = graphMax;
        this.graphMin = graphMin;
        this.plotType = plotType;
        this.plotColor = plotColor;
        this.plotSize = plotSize;
        this.lineType = lineType
        this.lineColor = lineColor;
        this.lineThickness = lineThickness;
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
        this.show_check = show_check;
      // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
    }

    /**
     * 空の要素を作成
     */
    createEmpty() {
        return new ReportGraph();
    }

    /**
     * 保存データを取得する.
     *
     * @returns 保存データ
     */
    getSaveData() {
        // モニタ項目コード(mst_add_monitor)の場合、コードの頭1バイトが'@'が付与されているので除去する.
        const cd = this.monitorItemCd.replace(REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX, "");
        return {
            is_bp: this.isBp,
            cd: cd,
            type:
                this.monitorItemCd.startsWith(REPORT_GRAPH.MONITOR_ITEM_CD_PREFIX)
                    ? REPORT_GRAPH.MONITOR_TYPE.MST_ADD_MONITOR
                    : REPORT_GRAPH.MONITOR_TYPE.SYS_MONITOR_ITEM,
            plot_type: this.plotType,
            plot_color: this.plotColor,
            plot_size: this.plotSize,
            line_type: this.lineType,
            line_color: this.lineColor,
            line_thickness: this.lineThickness,
            max: this.graphMax,
            min: this.graphMin,
          // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm start
            ...(["90", "91", "92"].includes(cd) && { show_check: this.show_check }),
          // add 11847 【因島：改良】治療方法マスタ＞帳票グラフ設定にて血圧の表示非表示を変更可能とする zkm end
        };
    }
}
