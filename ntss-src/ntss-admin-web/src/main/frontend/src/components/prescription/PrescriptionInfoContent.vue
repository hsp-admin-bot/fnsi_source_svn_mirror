/** * 処方情報ポップオーバー */
<template>
  <v-ons-popover
    v-if="popoverVisible"
    :target="targetPositionElement"
    :visible="loadCompletedFlg"
    animation="none"
    :direction="popoverDisplayDirection"
    :class="[fontSizeSet, 'popover-style']"
    cancelable
    @preshow="popoverPreShow"
    @postshow="popoverPostShow"
    @posthide="
      popoverPosthide();
      closePopover();
    "
  >
    <div>
      <v-ons-row>
        <v-ons-col>
          <div class="prescription-list-frame">
            <table class="list-wrapper detail-cell" style="margin-left: 0;">
              <tr>
                <td>{{prescriptionInfoData.checkHos === "1" ? "院外" : "院内"}}</td>
                <td></td>
              </tr>
              <tr>
                <td style="padding: 0 10px 0 0;">交付日：{{prescriptionInfoData.startDate}}</td>
                <td style="white-space: nowrap;">使用期間：{{prescriptionInfoData.endDate}}</td>
              </tr>
              <tr>
                <td style="padding: 0 10px 0 0;white-space: nowrap;">保険：{{prescriptionInfoData.patInsurance.substring(prescriptionInfoData.patInsurance.indexOf("&") + 1)}}</td>
                <td style="white-space: nowrap;">保険医：{{insuranceDoctorName}}</td>
              </tr>
            </table>
          </div>
        </v-ons-col>
      </v-ons-row>
      </br>
      <v-ons-row>
        <v-ons-col>
          <div class="prescription-list-frame">
            <table class="list-wrapper">
              <thead>
                <tr>
                  <th class="list-header-th">後発<br/>不可</th>
                  <th class="list-header-th">患者<br/>希望</th>
                  <th class="list-header-th"></th>
                  <th class="list-header-th"></th>
                  <th class="list-header-th"></th>
                  <th class="list-header-th"></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="prescriptionDetail in prescriptionDetailList">
                  <td style="text-align: center; width: 30px;">
                    <v-ons-checkbox
                      v-show="prescriptionDetail.unchg === 'x'"
                      v-model="prescriptionDetail.unchg === 'x' ? true:false"
                      @click.stop.prevent
                    ></v-ons-checkbox>
                  </td>
                  <td style="text-align: center; width: 30px;">
                    <v-ons-checkbox
                      v-show="prescriptionDetail.pat_req === 'x'"
                      v-model="prescriptionDetail.pat_req === 'x' ? true:false"                      
                      @click.stop.prevent
                    ></v-ons-checkbox>
                  </td>
                  <td class="detail-cell">{{prescriptionDetail.Rp ? prescriptionDetail.Rp + ")" : ""}}</td>
                  <td class="detail-cell" style="padding: 0 10px 0 10px;white-space: nowrap;">{{prescriptionDetail.R}}</td>
                  <td class="detail-cell" style="padding: 0 10px 0 0;text-align: right;white-space: nowrap;">{{prescriptionDetail.F5}}</td>
                  <td class="detail-cell" style="padding: 0 10px 0 0;white-space: nowrap;">{{prescriptionDetail.F6}}</td>
                </tr>
                <tr>
                  <td class="detail-cell"></td>
                  <td class="detail-cell"></td>
                  <td class="detail-cell" colspan="2">
                    リフィル可
                    <v-ons-checkbox
                      v-model="prescriptionInfoData.isRefill"
                      @click.stop.prevent
                    ></v-ons-checkbox>{{prescriptionInfoData.refillNum ? "(" + prescriptionInfoData.refillNum + "回)" : ""}}
                  </td>
                  <td class="detail-cell"></td>
                  <td class="detail-cell"></td>
                </tr>
              </tbody>
            </table>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-ons-popover>
</template>

<script>
import PopoverMixin from "@/components/PopoverMixin";
import {popoverPreShow, popoverPostShow, popoverPosthide} from "@/functions/common/CommonPopoverFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";

export default {
  mixins: [PopoverMixin, IndUserSelectMixin],

  props: {
    /**
     * @description ポップオーバー表示フラグ
     */
    popoverVisible: {
      type: Boolean,
      default: false
    },

    /**
     * @description 処方情報
     */
    prescriptionInfoData: {
      type: Object,
      default: () => {
        return {
          checkHos: "",      //処方区分
          startDate: "",     //交付日
          endDate: "",       //使用期間
          patInsurance: "",  //保険
          doctor: "",        //保険医
          isRefill: false,   //リフィル可
          refillNum: ""      //リフィル回数
        };
      }
    },
    
    /**
     * @description 処方箋の詳細情報
     */
    prescriptionDetailList: {
      type: Array,
      default: () => []
    },

    /**
     * @description ポップオーバーの呼び出し元(DOMオブジェクト)
     */
    targetPositionElement: {
      type: [Object, HTMLElement],
      default() {
        return this.$parent;
      }
    }
  },

  data() {
    return {
      /**
       * @description ポップオーバーの表示方向
       */
      popoverDirection: "",

      /**
       * @description 画面の高さ
       */
      windowHeight: window.innerHeight,

      /**
       * @description 画面の幅
       */
      windowWidth: window.innerWidth,
      
      /**
       * @description 保険医のフルネーム
       */
      insuranceDoctorName: "",
      
      /**
       * @description 画面の表示内容の取得完了フラグ
       */
      loadCompletedFlg: false,
      
      /**
       * @description ポップオーバー再表示フラグ
       */
      redrawFlg: false
    };
  },

  computed: {
    /**
     * @description ポップオーバーの表示方向
     */
    popoverDisplayDirection() {
      if (!this.popoverVisible) return null;
      let popoverElement = document.getElementsByClassName("disp_target_popover__content")[0];
      if(popoverElement && this.windowHeight >= 450){
        popoverElement.style.cssText = "height: 450px !important;";
      } else if(popoverElement && this.windowHeight < 450){
        popoverElement.style.cssText = "height: " + this.windowHeight + "px !important;";
      }
      const elemPosition = this.targetPositionElement.$el
        ? this.targetPositionElement.$el.getBoundingClientRect()
        : this.targetPositionElement.getBoundingClientRect();
      let direction = "right";
      let defaultHeight = 450;
      if (this.windowHeight <= defaultHeight && elemPosition.top >= 260) {
        if (elemPosition.right < this.windowWidth / 2) {
          direction = "right";
        } else {
          direction = "left";
        }
      } else if (this.windowWidth - elemPosition.right < 500) {
        if (elemPosition.top < this.windowHeight / 2) {
          direction = "down";
        } else {
          direction = "up";
        }
      } else if (elemPosition.top < 260){
        direction = "down";
      }
      this.setPopoverDirection(direction);
      return direction;
    }
  },
  
  async mounted() {
    //保険医のフルネームの取得
    this.insuranceDoctorName = await this.getInsuranceDoctorName(this.prescriptionInfoData.doctor);
    //同一のRpの2行目以降の値をブランクに設定
    let previousRowRp = "";
    this.prescriptionDetailList.forEach(item => {
      if(previousRowRp && item.Rp === previousRowRp){
        item.Rp = "";
      }else {
        previousRowRp = item.Rp;
      }
    });
    this.loadCompletedFlg = true;
    //リサイズのイベントリスナー登録
    window.addEventListener("resize", (ev) => {
      this.resizeEventListener();
      this.popoverDisplayDirection;
    });
  },
  
  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * @description 保険医のフルネームの取得
     */
    async getInsuranceDoctorName(userId){
      let insuranceDoctorName = "";
      await this.getIndUserList(AUTHORITY_CODES.PRESCRIPTION_EDIT, AUTHORITY_CODES.PRESCRIPTION_PEDIT)
      .then(response => {
        const doctor = response.doctorList.find((item) => {
          return item.user_id === userId;
        });
        if(doctor){
          insuranceDoctorName = doctor.fullName;
        }
      });
      return insuranceDoctorName;
    },
    /**
     * @description リサイズ発生時のイベント
     */
    resizeEventListener(){
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },
    /**
     * @description ポップオーバー非表示
     */
    closePopover() {
      if(!this.redrawFlg){
        this.$emit("popover-close", false);
        this.popoverDirection = "";
      }
    },

    /**
     * @description ポップオーバーの表示方向設定
     */
    setPopoverDirection(direction) {
      this.popoverDirection = direction;
    },
    
    /**
     * @description ポップオーバーの表示/非表示制御
     */
    updateVisibleFlg(loadCompletedFlg, redrawFlg){
      this.$nextTick(() => {
        this.loadCompletedFlg = loadCompletedFlg;
        this.redrawFlg = redrawFlg;
      });
    }
  },
  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    window.removeEventListener("resize",this.resizeEventListener);
  }
};
</script>

<style scoped>
.popover-style >>> .popover--top,
.popover-style >>> .popover--right,
.popover-style >>> .popover--left,
.popover-style >>> .popover--bottom {
  width: initial;
}
.popover-style >>> .popover__content {
  width: 600px;
  height: 450px;
  max-height: none !important; /* NOTE: windowSizeを変更すると[Onsen UI]の制御が走り、縮むため[Onsen UI]の制御を無効化 */
  padding: 25px;
  border: solid 1px var(--preventive-checked-border-color);
  margin: 3px;
}
.prescription-list-frame {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
  border: none;
}
@media screen and (max-width: 420px) {
  .popover-style >>> .popover__content {
    width: auto;
    padding: 10px;
  }
}
@media screen and (max-height: 420px) {
  .popover-style >>> .popover__content {
    width: 350px;
    padding: 5px;
  }
}
.popover-style >>> .popover-mask {
  z-index: 1999 !important;
}
.popover-style >>> .popover {
  z-index: 10001 !important;
}
.list-wrapper {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
  background-color: var(--ntss-list-background-color);
}
.list-wrapper tr {
  background-color: var(--ntss-list-item-background-color);
  border-color: 1px solid var(--master-maintenance-kgrid-border-color);
}
.list-header-th {
  background-image: none;
  font-weight: unset;
  padding: 4px;
  border-top: none;
  white-space: pre;
  text-align: left;
  top: 0px;
  font-size: 11px !important;
}
.detail-cell {
  width: auto;
}
</style>
