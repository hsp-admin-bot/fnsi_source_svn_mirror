/**
 * 遠隔監視施設一覧 MainContent
 */
<template>
  <div class='main-content-area'>
    <table class='ntss-list'>
      <thead>
        <tr>
          <th v-for='column in columns'
              :key='column.key'
              :class="[sortedClass(column.key), column.centerAlign ? 'list-header-th-center' : '']"
              class="ntss-list-header-th-sticky"
              :style="{ width:column.width + '%'}"
              @click="sortBy(column.key)">{{ column.colName }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for='facility in filterFunction(sortFacilityItems)'
            :key='facility.facilityName'
            class="ntss-list-body-tr"
            :class="getBackgroudColorClass(facility)"
            @click='goNext(facility.departmentCd, facility.facilityCd, facility.facilityName)'>
          <td class='ntss-list-body-td'>{{ facility.departmentCd }}</td>
          <td class='ntss-list-body-td'>{{ facility.facilityName }}</td>
          <!-- mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start -->
          <!-- <td class='ntss-list-body-td ntss-list-body-td-text-center'>{{ facility.mNoticeCnt }}</td> -->
          <td class='ntss-list-body-td ntss-list-body-td-text-center'>{{ facility.serviceSupportCnt }}</td>
          <!-- mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end -->
          <!-- 予防保全対応不完全のため非表示とする -->
          <td class='ntss-list-body-td ntss-list-body-td-text-center' v-if=false>{{ facility.preventiveCnt }}</td>
          <td class='ntss-list-body-td ntss-list-body-td-text-center'
              :class="[ getComProblemClass(facility) ? 'com-problem-row ' : '']">{{ facility.comProblemCnt }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
import { OPERATION_VIEWER_AUTO_SETTING, OPERATION_VIEWER_FORCE_SIGNOUT } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import commonjs from "@/constants/operationViewerCommon";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import { initForceSignOutFlag } from "@/functions/common/CommonFunctions.js";

export default {
  mixins: [NextTransitionMixin],
  data() {
    return {
      // 列情報
      // key : ソート時のキー
      // colName : 列名
      // width : 列幅(%指定)
      columns: [
        {
          key: "departmentCd",
          colName: "部署符号",
          width: 5,
          centerAlign: false
        },
        {
          key: "facilityNameKana",
          colName: "施設名",
          width: 100,
          centerAlign: false
        },
        {
          key: "mNoticeCnt",
          colName: "警",
          width: 5,
          centerAlign: true
        },
        //予防保全対応不完全のため非表示とする
        //{
        //  key: "preventiveCnt",
        //  colName: "予",
        //  width: 5
        //},
        {
          key: "comProblemCnt",
          colName: "ー",
          width: 5,
          centerAlign: true
        }
      ],
      sort: {
        key: "",
        isAsc: true
      },
      timerObj: null,
      /**
       * 「警報通知発生降順のソート」がチェックされている時にソートするキー名
       */
      isAlarmSortKey: "maxEventRegDate",
      selfScreenPath: "",
      refreshInterval: 0
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "isNkkFacility"
    ]),
    ...mapGetters("operation-viewer/facility", ["getFacilities"]),
    facilities() {
      return this.getFacilities;
    },
    /**
     * ソート処理
     */
    sortFacilityItems() {
      // ソート時でstate自体の順序を書き換えないため
      let list = this.getFacilities.slice();
      // 警報通知発生降順にソートフラグをstoreから取得
      const isAlarmSort = this.getCondition().isAlarmSort;
      // 最大イベント発生日時が含まれるリスト
      const hasMaxEventRegDateList = list.filter(r => {
        return (r.maxEventRegDate);
      });
      const notHasMaxEventRegDateList = list.filter(r => {
        return (!r.maxEventRegDate);
      });
      // ソートキーが指定されている場合
      if (this.sort.key) {
        // 警報通知発生降順ソートにチェックされている場合
        if (isAlarmSort) {
          list = [
            ...hasMaxEventRegDateList.sort((a, b) => commonjs.compareKey(a, b, this.isAlarmSortKey, false)),
            ...notHasMaxEventRegDateList.sort((a, b) => commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc))
          ];
        } else {
          list.sort((a, b) => commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc));
        }
      } else {
        if (isAlarmSort) {
          list = [
            ...hasMaxEventRegDateList.sort((a, b) => commonjs.compareKey(a, b, this.isAlarmSortKey, false)),
            ...notHasMaxEventRegDateList
          ];
        }
      }
      return list;
    }
  },
  methods: {
    // 施設一覧を取得する
    ...mapGetters("operation-viewer/facility", ["getCondition"]),
    ...mapActions("operation-viewer/facility", ["fetchFacilities"]),
    ...mapActions("operation-viewer/machine", ["setFacilityInfo"]),
    /**
     * サインイン者が担当している施設一覧を取得する.
     */
    fetchFacilityList(autoRefreshFlag) {
      this.fetchFacilities({userId: this.getStateUserAccountInfo.userId, autoRefreshFlag}).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('FacilitiesMainComponent.vue', 'fetchFacilityList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // TODO Httpステータス 400時のエラー処理
      });
    },
    /**
     * 次ページに遷移する.
     *
     * @param {*} departmentCd 部署符号
     * @param {*} facilityCd 施設コード
     * @param {*} facilityName 施設名
     */
    goNext(departmentCd, facilityCd, facilityName) {
      const facilityInfo = {
        departmentCd,
        facilityCd,
        facilityName
      };
      this.setFacilityInfo(facilityInfo);
      // Mixinで定義したメソッドで次画面へ遷移
      this.goNextView();
    },
    /**
     * 昇順/降順のclassを作成する.
     *
     * @param {String} key ソートキー
     *                     ※columns.key名
     * @returns クラス名
     */
    sortedClass(key) {
      return this.sort.key === key
        ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
        : "";
    },
    /**
     * ソートキーを設定する.
     *
     * @param {String} key ソートキー
     *                     ※columns.key名
     */
    sortBy(key) {
      if (key === this.sort.key && !this.sort.isAsc) {
        // ソートをクリア
        this.sort.key = "";
        this.sort.isAsc = true;
        return;
      }
      this.sort.isAsc = this.sort.key === key ? !this.sort.isAsc : true;
      this.sort.key = key;
    },
    /**
     * 背景色用のクラスを取得する.
     *
     * サインイン者が日機装施設に属している場合は、サービス対応件数で背景色の制御を行う.
     * それ以外は、緊急発報件数、予防保守件数、通信不良件数での背景色の制御を行う.
     *
     * @param {*} facility リスト1行毎の施設情報
     * @returns クラス名
     */
    getBackgroudColorClass(facility) {
      // 日機装施設の場合
      if (this.isNkkFacility) {
        return facility.serviceSupportCnt > 0 ? "emergency-row" : "";
      } else {
        // 警報通知 > 予防保守 の順番で背景色を変更
        return facility.mNoticeCnt > 0 ? "emergency-row" : facility.preventiveCnt > 0 ? "preventive-row" : "";
      }
    },
    // 通信不良有無列の背景色設定
    getComProblemClass(facilityObj) {
      let rtn = false;
      // 日機装施設の場合
      if (this.isNkkFacility && facilityObj.comProblemCnt > 0) {
        rtn = true;
      } else if (facilityObj.mNoticeCnt === 0 &&
                 facilityObj.preventiveCnt === 0 &&
                 facilityObj.comProblemCnt > 0) {
        rtn = true;
      }
      return rtn;
    },
    /**
     * 抽出条件によるフィルタリングを行う.
     *
     * @param {Array} facilities 施設一覧
     */
    filterFunction(facilities) {
      // 選択されている部署符号
      const departmentCd = this.getCondition().departmentCd;
      // 選択されている都道府県
      const prefName = this.getCondition().prefName;
      // 入力されている施設名
      const facilityName = this.getCondition().facilityName;
      // 緊急発報の表示可否
      const isEmergency = this.getCondition().facilityEmergency;
      // 予防保守の表示可否
      const isProphylaxis = this.getCondition().facilityProphylaxis;
      // 通信不要の表示可否
      const isDefect = this.getCondition().facilityDefect;
      // 全情報の表示可否
      const isAll = this.getCondition().facilityAll;
      // 抽出条件で絞り込んだ結果を格納する変数
      const filterFacilities = [];
      // 抽出条件が未入力の場合
      if (
        (!departmentCd || departmentCd === "-") &&
        (!prefName || prefName === "-") &&
        !facilityName &&
        isAll
      ) {
        return facilities;
      }
      // -----------------------------------------
      // 抽出条件が入力されている場合
      // -----------------------------------------
      for (let idx = 0; idx < facilities.length; idx++) {
        // 抽出条件対象フラグ
        let isFileter = true;
        if (
          departmentCd != null &&
          departmentCd !== "" &&
          departmentCd !== "-"
        ) {
          if (facilities[idx].departmentCd === departmentCd) {
            isFileter = true;
          } else {
            isFileter = false;
          }
        }
        if (
          prefName != null &&
          prefName !== "" &&
          prefName !== "-" &&
          isFileter
        ) {
          if (facilities[idx].prefecuturesName === prefName) {
            isFileter = true;
          } else {
            isFileter = false;
          }
        }
        if (facilityName != null && facilityName !== "" && isFileter) {
          if (facilities[idx].facilityName.indexOf(facilityName) > -1) {
            isFileter = true;
          } else {
            isFileter = false;
          }
        }
        if (isFileter) {
          if (isAll) {
            filterFacilities.push(facilities[idx]);
          } else if (isEmergency) {
            if (this.isNkkFacility ? facilities[idx].serviceSupportCnt > 0 : facilities[idx].mNoticeCnt > 0) {
              filterFacilities.push(facilities[idx]);
            }
          } else if (isProphylaxis && facilities[idx].preventiveCnt > 0) {
            filterFacilities.push(facilities[idx]);
          } else if (isDefect && facilities[idx].comProblemCnt > 0) {
            filterFacilities.push(facilities[idx]);
          }
        }
      }
      return filterFacilities;
    },
    /**
     * 再描画する.
     */
    refresh(autoRefreshFlag) {
      const paths = this.$route.matched.map(item => item.path);
      if (!paths?.includes(this.selfScreenPath)) {
        return;
      }
      this.fetchFacilityList(autoRefreshFlag);
      // 指定された間隔で一覧の再取得を行う
      clearTimeout(this.timerObj);
      this.timerObj = setTimeout(() => {
        this.refresh(true)
      }, this.refreshInterval);
    },
    async refreshVal() {
      let data = await getMstFacilitySettingValue(this.getFacilityCd, OPERATION_VIEWER_AUTO_SETTING);
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 30000;
        }
      } else if (data.status == 400) {
        getErrorMessage("FacilitiesMainComponent.vue", "getInterval", { response: data });
        this.refreshInterval = 30000;
      }
      /* 自動更新サインアウトフラグ取得 */
      await initForceSignOutFlag("operation-viewer/facility/setForceSignOutFlag", OPERATION_VIEWER_FORCE_SIGNOUT);
    },
  },
  async created() {
    // 画面名称取得
    this.selfScreenPath = this.$route.path;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    await this.refreshVal();
    this.refresh();
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    clearTimeout(this.timerObj);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.list-header-th-center {
  text-align: center;
}
</style>
