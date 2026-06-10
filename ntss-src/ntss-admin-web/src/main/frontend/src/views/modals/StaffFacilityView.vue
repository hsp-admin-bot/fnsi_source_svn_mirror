/**
 * 担当施設設定ページ
 */
<template>
  <modal-base @onClose="cancel">
    <facility-search slot="search-area" />
    <div slot="body" class="table-staff-facilities">
      <table class="ntss-list">
        <thead>
          <tr>
            <th
              v-for="column in columns"
              :key="column.key"
              :class="headerCellClass(column.key)"
              :style="{ width: column.width + '%'}"
              @click="sortBy(column.key)"
            >
              <label v-if="column.key !== 'isCharge'">{{ column.colName }}</label>
              <v-ons-checkbox
                v-if="column.key === 'isCharge'"
                v-model="allSelectFlg"
                @change="setStaffAll"
                @click.stop
              ></v-ons-checkbox>
            </th>
          </tr>
        </thead>
        <tbody class="ntss-list-body-tr-custom">
          <tr
            v-for="facility in filterFunction(sortStaffFacilityItems)"
            :key="facility.facilityCd"
            class="ntss-list-body-tr"
          >
            <td class="ntss-list-body-td">
              <v-ons-checkbox
                :value="facility.facilityCd"
                v-model="chargedFacilityCds"
                @change="allSelectFlg = false"
              ></v-ons-checkbox>
            </td>
            <td class="ntss-list-body-td">{{ facility.departmentCd }}</td>
            <td class="ntss-list-body-td nowrap">{{ facility.prefecturesName }}</td>
            <td class="ntss-list-body-td">{{ facility.facilityName }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div slot="footer" class="flex-container margin-footer">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button
          class="button btn1-execute registration-btn"
          @click="registration"
          :disabled="this.chargedFacilityCds.length == 0 || !isChanged"
        >確定</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import StaffFacilityHeaderComponent from "@/components/modals/StaffFacilityHeaderComponent";
import { mapGetters, mapActions } from "vuex";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  name: "staffFacility",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase,
    "facility-search": StaffFacilityHeaderComponent
  },
  data() {
    return {
      // 列情報
      // key : ソート時のキー
      // colName : 列名
      // width : 列幅(px指定) ※指定しない場合は自動で幅が調整される
      columns: [
        {
          key: "isCharge",
          colName: "",
          width: 1
        },
        {
          key: "departmentCd",
          colName: "部署符号",
          width: 5
        },
        {
          key: "prefecturesCd",
          colName: "都道府県",
          width: 5
        },
        {
          key: "facilityNameKana",
          colName: "施設名",
          width: 100
        }
      ],
      sort: {
        key: "",
        isAsc: true
      },
      allSelectFlg: false,
      chargedFacilityCds: []
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("staff-facility", [
      "getStaffFacilities",
      "isRegistered",
      "getCondition"
    ]),
    // ヘッダクリック時のソート
    sortStaffFacilityItems() {
      if (!this.sort.key) {
        // ソートなし
        return this.getStaffFacilities;
      }

      // ソート用の配列を生成
      const list = this.getStaffFacilities.map(m => {
        return {
          key:
            this.sort.key === "isCharge"
              ? this.chargedFacilityCds.indexOf(m.facilityCd) >= 0
              : m[this.sort.key],
          value: m
        };
      });

      list.sort((a, b) => {
        var result = 0;
        // nullの場合の対応
        if (!a.key && b.key) {
          result = -1;
        } else if (a.key && !b.key) {
          result = 1;
        }
        if (a.key > b.key) {
          result = 1;
        } else if (a.key < b.key) {
          result = -1;
        }
        return result * (this.sort.isAsc ? 1 : -1);
      });

      return list.map(m => m.value);
    },
    // 変更済かどうか
    isChanged() {
      return this.getStaffFacilities.some(
        f =>
          this.chargedFacilityCds.find(m => m === f.facilityCd) !=
          (f.isCharge ? f.facilityCd : null)
      );
    }
  },
  methods: {
    ...mapActions("staff-facility", [
      "fetchStaffFacilities",
      "setStaffFacilities",
      "clearCondition"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    // ヘッダーセルのclassを作成
    headerCellClass(key) {
      const c1 =
        key === "isCharge"
          ? "table-header-check-all"
          : "ntss-list-header-th-sticky";
      const c2 =
        key === this.sort.key
          ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
          : "";
      return c1 + " " + c2;
    },
    // ソートするキーを設定する
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
    // 抽出条件のフィルタ
    filterFunction(staffFacilities) {
      // 選択されている部署符号
      const departmentCd = this.getCondition.departmentCd;
      // 選択されている都道府県
      const prefName = this.getCondition.prefName;
      // 入力されている施設名
      const facilityName = this.getCondition.facilityName;
      // 抽出条件で絞り込んだ結果を格納する変数
      const filterFacilities = [];
      // 抽出条件が未入力の場合
      if (
        (!departmentCd || departmentCd === "-") &&
        (!prefName || prefName === "-") &&
        !facilityName
      ) {
        return staffFacilities;
      }
      // -----------------------------------------
      // 抽出条件が入力されている場合
      // -----------------------------------------
      for (let idx = 0; idx < staffFacilities.length; idx++) {
        // 抽出条件対象フラグ
        let isFilter = true;
        if (
          departmentCd != null &&
          departmentCd !== "" &&
          departmentCd !== "-"
        ) {
          if (staffFacilities[idx].departmentCd === departmentCd) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (
          prefName != null &&
          prefName !== "" &&
          prefName !== "-" &&
          isFilter
        ) {
          if (staffFacilities[idx].prefecturesName === prefName) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (facilityName != null && facilityName !== "" && isFilter) {
          if (staffFacilities[idx].facilityName.indexOf(facilityName) > -1) {
            isFilter = true;
          } else {
            isFilter = false;
          }
        }
        if (isFilter) {
          filterFacilities.push(staffFacilities[idx]);
        }
      }
      return filterFacilities;
    },
    /**
     * 全施設の担当状況を一括設定
     */
    setStaffAll() {
      this.chargedFacilityCds = !this.allSelectFlg
        ? this.getStaffFacilities.map(m => m.facilityCd)
        : [];
    },
    /**
     * 登録処理
     */
    registration() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // 登録処理
      const requestBody = {
        userId: this.getStateUserAccountInfo.userId,
        body: {
          staffFacilityCds: this.chargedFacilityCds
        }
      };
      this.setStaffFacilities(requestBody)
        .then(() => {
          // 設定成功
          const options = {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "登録成功",
            // message: "担当施設情報が</br>正常に設定されました。",
            title: DIALOG_MESSAGES[12000299].title,
            message: messageFormat(DIALOG_MESSAGES[12000299].message),  
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            callback: this.hideModal
          };
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert(options);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('StaffFacilityView.vue','registration','登録処理に失敗しました。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            // 設定失敗
            const options = {
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "登録処理に失敗しました。",
              title: DIALOG_MESSAGES[12000290].title,
              message: messageFormat(DIALOG_MESSAGES[12000290].message),  
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            };
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert(options);
          }
        });
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 設定内容に変更がある場合はメッセージを表示
      if (this.isChanged) {
        this.$ons.notification.confirm({
         // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.hideModal();
            }
          }
        });
      } else {
        this.hideModal();
      }
    }
  },
  created() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 共通ローダー:表示開始
    this.setLoadingScreenVisible(true);
    this.fetchStaffFacilities(this.getStateUserAccountInfo.userId).then(() => {
      this.chargedFacilityCds = this.getStaffFacilities
        .filter(m => m.isCharge)
        .map(m => m.facilityCd);
    });
    // 共通ローダー:表示終了
    this.setLoadingScreenVisible(false);
  },
  beforeDestroy: function() {
    this.clearCondition();
  }
};
</script>
<style scoped>
.table-header-check-all {
  color: #fff;
  padding: 4px;
  padding-left: 8px;
  white-space: nowrap;
  border-top: none;
  top: 0;
  position: sticky;
  text-align: left;
  z-index: 2;
  /* TODO モーダルのブラックテーマ適用時に以下３つのスタイルを削除する */
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}
.table-header-check-all:after {
  vertical-align: center;
  padding-left: 4px;
}
/* TODO モーダルのブラックテーマ適用時に以下のスタイルを全て削除する */
.ntss-list {
  background-color: #fafafa;
}
.ntss-list-header-th-sticky {
  background-color: #333333;
  border: solid 1px #cccccc;
  border-top: none;
}
.ntss-list-body-tr {
  border: solid 1px #cccccc;
  color: var(--ntss-base-color);
  background-color: var(--ntss-list-item-background-color);
}
.ntss-list-body-td {
  border: solid 1px #cccccc;
}
.modal-mask >>> .modal-search {
  top: 43px;
  height: 7.5em;
}
.modal-mask >>> .modal-body-search {
  top: calc(43px + 3.2em);
  height: calc(100% - 70px - 5.2em);
}
.ntss-list-body-tr-custom {
  background-color: var(--ntss-base-background-color);
}
@media print {
  .modal-mask >>> .ntss-list {
    position: static !important;
  }
    /** 1枚に収める */
  .modal-mask >>> div {
    height: auto !important;
  }
}
</style>
