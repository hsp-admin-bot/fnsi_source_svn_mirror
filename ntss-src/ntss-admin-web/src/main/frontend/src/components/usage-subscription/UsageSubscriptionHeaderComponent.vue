<template>
  <v-card>
    <div class="header-item">
      <table class="event-area">
        <tbody>
        <tr class="header-row">
          <td class="search-button-area"></td>
          <td class="plan-name-area">
            <label class="plan-name">初回申込プラン：</label>
            <label v-if="planName" class="plan-name">{{ planName }}</label>
            <select v-if="isNkk && isFirst" v-model="selectedPlan" class="select-input">
              <option
                v-for="plan in subscriptionPlans"
                :key="plan.subscriptionPlanNo"
                :value="plan"
              >{{ plan.subscriptionPlanName }}</option>
            </select>
          </td>
          <td v-if="isNkk" class="text-right">
            <kendo-dropdownlist
              ref="dropdown"
              v-model="selectedFacility"
              :data-source="mstFacilities"
              data-text-field="facilityName"
              data-value-field="facilityCd"
              :filter="'contains'"
              style="margin-right: 70px"
              class="kendo-width-style"
            ></kendo-dropdownlist>
          </td>
        </tr>
      
        </tbody>
      </table>
    </div>
  </v-card>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { sendRequestGetMstFacility } from "@/apis/mst-user-maintenance";
import { sendRequestGetPlan } from "@/apis/usage-subscription";
import { EventBus } from "@/compat/vue/event-bus.js";
export default {
  name: "UsageSubscriptionHeaderComponent",
  data() {
    return {
      mstFacilities: [],
      selectedFacility: null,
      subscriptionPlans: [],
      selectedPlan: null,
      selfScreenName: ""
    };
  },
  computed: {
    ...mapGetters("usage-subscription", {
      planName: "subscriptionPlanName",
      isFirst: "isFirst"
    }),
    ...mapGetters("account-edit", {
      stateUserAccountInfo: "getStateUserAccountInfo"
    }),
    /**
     * 日機装ユーザーをチェックする。
     */
    isNkk() {
      return this.stateUserAccountInfo.facilityCd === "nkknkk";
    }
  },
  watch: {
    selectedFacility() {
      this.setSelectedFacility(this.selectedFacility);
      this.selectedPlan = null;
    },
    selectedPlan() {
      this.setSelectedPlan(this.selectedPlan);
    }
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    this.clearStore();
    await this.init();
  },
  methods: {
    ...mapActions("usage-subscription", [
      "setSelectedFacility",
      "setSelectedPlan",
      "setPlanName"
    ]),
    async init() {
      if (this.isNkk) {
        this.setSelectedFacility(null);
        const mstFacilities = await sendRequestGetMstFacility();
        this.mstFacilities = mstFacilities.data;
        const subscriptionPlans = await sendRequestGetPlan();
        this.subscriptionPlans = subscriptionPlans.data;
      } else {
        this.setSelectedFacility(this.stateUserAccountInfo.facilityCd);
      }
    },
    /**
     * ストアをクリア
     */
    clearStore() {
      this.setSelectedFacility(null);
      this.setSelectedPlan(null);
      this.setPlanName(null);
    },
    async refresh() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      this.clearStore();
      await this.init();
      this.selectedFacility = null;
    }
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
  }
};
</script>
<style scoped>
.select-input {
  font-size: 1.6em;
  height: 1.6em;
  box-sizing: content-box;
}

.search-button-area {
  width: 2em;
}

.event-area {
  height: 100%;
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  color: var(--ntss-header-color);
}

.plan-name-area {
  display: flex;
  align-items: center;
  height: 100%;
  transform-origin: 50% 50%;
}

.plan-name {
  display: inline-block;
  width: auto;
  font-size: 1.6em;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.text-right {
  text-align: right;
}
@media screen and (max-width: 480px) {
  .text-right {
  text-align: right;
  padding-left: 2em;
  }

  .header-row {
  display: flex;
  flex-wrap: wrap;
  }
}
</style>
