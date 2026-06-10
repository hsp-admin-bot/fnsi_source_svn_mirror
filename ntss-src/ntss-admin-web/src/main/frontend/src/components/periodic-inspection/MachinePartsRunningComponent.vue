<template>
  <modal-base @onClose="onClose" class="custom-modal">
    <div slot="body">
        <table class="ntss-list-detail">
          <thead>
          <tr>
            <th class="ntss-list-header-th-sticky">部品名</th>
            <th class="ntss-list-header-th-sticky">運転時間</th>
          </tr>
          </thead>
          <tbody v-if="partsRunningModel.comType === 1" >
          <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dialyzeDeviceRows' :key='rows'>
            <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
            <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dialyzeDevice[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
          </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && partsRunningModel.comFormatCd === 'A'">
          <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dabRows' :key='rows'>
            <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
            <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dab[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
          </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && partsRunningModel.comFormatCd === 'D'">
          <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dadRows' :key='rows'>
            <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
            <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dad[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
          </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && partsRunningModel.comFormatCd === 'R'">
          <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in droRows' :key='rows'>
            <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
            <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dro[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
          </tr>
          </tbody>

        </table>
    </div>
    <div slot="footer" class="flex-container justify-content-flex-end">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="onClose">閉じる</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
  import { EventBus } from "@/eventBus";
  import ModalBase from "@/components/modals/ModalBase";
  import { mapGetters, mapActions } from "vuex";
  import {ApiHelper} from "../../apis/AxiosHelper";

  export default {
    name: "MachinePartsRunningComponent",
    components: {
      "modal-base": ModalBase,
    },
    data() {
      return {
        dialyzeDeviceRows: [
          { itemName: "装置運転時間", jsonAddress: 0, unit: "h" },
          { itemName: "消耗品グループ１", jsonAddress: 1, unit: "h" },
          { itemName: "消耗品グループ２", jsonAddress: 2, unit: "h" },
          { itemName: "消耗品グループ３", jsonAddress: 3, unit: "h" },
          { itemName: "複式ポンプポペット運転時間", jsonAddress: 4, unit: "h" },
          {
            itemName: "複式ポンプキャップシール運転時間",
            jsonAddress: 5,
            unit: "h"
          },
          {
            itemName: "複式ポンプキャップスライダー運転時間",
            jsonAddress: 6,
            unit: "h"
          },
          { itemName: "背圧弁ダイアフラム運転時間", jsonAddress: 7, unit: "h" },
          { itemName: "除水ポンプポペット運転時間", jsonAddress: 8, unit: "h" },
          {
            itemName: "除水ポンプキャップシール運転時間",
            jsonAddress: 9,
            unit: "h"
          },
          { itemName: "脱気ポンプメカシ運転時間", jsonAddress: 10, unit: "h" },
          { itemName: "加圧ポンプメカシ運転時間", jsonAddress: 11, unit: "h" },
          { itemName: "原液ポンプポペット運転時間", jsonAddress: 12, unit: "h" },
          {
            itemName: "原液ポンプキャップシール運転時間",
            jsonAddress: 13,
            unit: "h"
          },
          {
            itemName: "原液背圧ダイアフラム運転時間",//1234567890-
            jsonAddress: 14,
            unit: "h"
          },
          { itemName: "原液フィルター運転時間", jsonAddress: 15, unit: "h" },
          { itemName: "微粒子ろ過フィルタ運転時間", jsonAddress: 16, unit: "h" },
          { itemName: "エアフィルタ運転時間", jsonAddress: 17, unit: "h" },
          { itemName: "薬液フィルタ運転時間", jsonAddress: 18, unit: "h" },
          { itemName: "透析液戻り口フィルタ", jsonAddress: 19, unit: "h" },
          { itemName: "装置背面ファン用フィルタ", jsonAddress: 20, unit: "h" },
          { itemName: "原液ノズルＯリング", jsonAddress: 21, unit: "h" },
          { itemName: "バイパスコネクタＯリング", jsonAddress: 22, unit: "h" },
          {
            itemName: "ダイアライザーカップリングＯリング",
            jsonAddress: 23,
            unit: "h"
          },
          { itemName: "電磁弁", jsonAddress: 24, unit: "h" },
          { itemName: "薬液電磁弁", jsonAddress: 25, unit: "h" },
          { itemName: "脱気ポンプインペラ", jsonAddress: 26, unit: "h" },
          { itemName: "加圧ポンプインペラ", jsonAddress: 27, unit: "h" },
          { itemName: "複式ポンプテープベアリング", jsonAddress: 28, unit: "h" },
          { itemName: "逆止弁", jsonAddress: 29, unit: "h" },
          { itemName: "脱気ポンプフィルタ", jsonAddress: 30, unit: "h" },
          {
            itemName: "微粒子ろ過フィルタ２運転時間",
            jsonAddress: 31,
            unit: "h"
          },
          { itemName: "レベル調整ポンプしごき部", jsonAddress: 32, unit: "h" },
          { itemName: "サンプルポートガスケット", jsonAddress: 33, unit: "h" },
          { itemName: "ダイアライザーカップリング", jsonAddress: 34, unit: "h" },
          { itemName: "サンプルポート逆止弁", jsonAddress: 35, unit: "h" },
        ],
        dabRows: [
          { itemName: "装置運転時間", jsonAddress: 1, unit: "h" },
          { itemName: "消耗品グループ１", jsonAddress: 2, unit: "h" },
          { itemName: "消耗品グループ２", jsonAddress: 3, unit: "h" },
          { itemName: "消耗品グループ３", jsonAddress: 4, unit: "h" },
          { itemName: "水計量シリンダ（往復動運転）", jsonAddress: 5, unit: "h" },
          {
            itemName: "水計量シリンダ（バイパス運転）",
            jsonAddress: 6,
            unit: "h"
          },
          { itemName: "Ｂ原液注入ポンプＰ１運転時間", jsonAddress: 7, unit: "h" },
          { itemName: "Ａ原液注入ポンプＰ２運転時間", jsonAddress: 8, unit: "h" },//少一个
          { itemName: "送液ポンプＰ４運転時間", jsonAddress: 9, unit: "h" },
          { itemName: "薬液注入ポンプＰ５運転時間", jsonAddress: 10, unit: "h" },
          { itemName: "脱気ポンプＰ６運転時間", jsonAddress: 11, unit: "h" },
          { itemName: "脱気ポンプＰ７運転時間", jsonAddress: 12, unit: "h" },
          {
            itemName: "パワーユニットファンフィルタ",
            jsonAddress: 13,
            unit: "h"
          },
          {
            itemName: "水計量シリンダ電磁弁動作回数",
            jsonAddress: 14,
            unit: "万回"
          },
          { itemName: "給水電磁弁動作回数", jsonAddress: 15, unit: "万回" },
        ],
        dadRows: [
          { itemName: "装置運転時間", jsonAddress: 1, unit: "h" },
          { itemName: "消耗品グループ１（時間）", jsonAddress: 3, unit: "h" },
          { itemName: "消耗品グループ１（回数）", jsonAddress: 2, unit: "回" },
          { itemName: "消耗品グループ２", jsonAddress: 4, unit: "h" },
          { itemName: "消耗品グループ３", jsonAddress: 5, unit: "h" },
          { itemName: "減容カッター", jsonAddress: 6, unit: "回" },
          { itemName: "微粒子除去フィルタ", jsonAddress: 7, unit: "h" },
          { itemName: "電源装置ファン用フィルタ", jsonAddress: 8, unit: "h" },
          { itemName: "ＨＥＰＡフィルタ用フィルタ", jsonAddress: 9, unit: "h" },
        ],
        droRows: [
          { itemName: "１０μフィルタ", jsonAddress: 1, unit: "h" },
          { itemName: "カーボンフィルタ", jsonAddress: 2, unit: "h" },
          { itemName: "ＬＲＯ膜", jsonAddress: 3, unit: "h" },
          { itemName: "ＲＯ膜", jsonAddress: 4, unit: "h" },
          { itemName: "エアフィルタ", jsonAddress: 5, unit: "h" },
          { itemName: "ＲＯ水タンクＵＶランプ", jsonAddress: 6, unit: "h" },
          { itemName: "濃縮水タンクＵＶランプ", jsonAddress: 7, unit: "h" },
          { itemName: "排水回収ＲＯ膜", jsonAddress: 8, unit: "h" },
        ],
        params: {
          facilityCd: null,
          machineTypeCd: null,
          machineSerial: null,
        },
      };
    },
    computed: {
      ...mapGetters("periodic-inspection", ["getMachine", "getBeforeModel"]),
      ...mapGetters("motion-record-done", ["getPartsRunningResult"]),
      partsRunningModel() {
        return this.getPartsRunningResult;
      },
    },
    methods: {
      ...mapActions("motion-record-done", ["setPartsRunningResult"]),
      initMachine() {
        this.params.facilityCd =  this.getMachine.facilityCd;
        this.params.machineTypeCd = this.getMachine.machineTypeCd;
        this.params.machineSerial =  this.getMachine.machineSerial;
        ApiHelper.get(`/mente-main/parts_running/${this.params.facilityCd}/${this.params.machineTypeCd}/${this.params.machineSerial}`).then(res => {
          this.setPartsRunningResult(res.data);
        });
      },
      // 閉じるボタン処理
      onClose() {
        if (this.getBeforeModel.name === "PeriodicInspectionModal") {
          EventBus.$emit("closeShowSomeThingModal", this.getBeforeModel);
        } else {
          EventBus.$emit("closesMachineModal", this.getBeforeModel);
        }
      },
    },
    created() {
      this.initMachine();
    },
    mounted() {
      if (this.getBeforeModel.name === "PeriodicInspectionModal") {
        const spanElement = document.querySelector(".parentModalPeriodicInspection .toolbar__title span");
        if (spanElement) {
          spanElement.textContent = "部品の運転／交換時間";
        }
      }
    },
  };
</script>

<style>
  .parentModalPeriodicInspection {
    z-index: 10000;
  }
  .parentModalPeriodicInspection > div > .modal-container {
    width: 100%;
    height: 100%;
  }
</style>
<style scoped>
  .ntss-list-detail {
    border-collapse: collapse;
    margin: 0 auto;
    width: -webkit-fill-available;
    top: 0px;
    background-color: var(--ntss-list-background-color);
  }
  .ntss-list-body-tr {
    border: solid 1px #cccccc;
    color: #050505;
  }
  .ntss-list-body-td {
    border: solid 1px #cccccc;
    width: 10%;
  }
</style>
