/**
 * 治療記録の子機能 装置設定ページ
 */
<template>
  <submenu-base>
    <template #header>
      <div>
        <div v-if="isDispBtnMachineSetting()" class="fetch-souchi-settei-button-area">
        <v-ons-button class="button registration-btn btn3-normal" :disabled="isReadOnly || !isShared" @click="fetchSouchiSettei()">装置設定取得</v-ons-button>
      </div>
      </div>
    </template>
    <template #main>
      <div id="setting-component">
        <v-ons-list class="treatment-record-accordion">
        <v-ons-list-item expandable v-model:expanded="isExpandedShijiJouhou">
          <label>指示情報</label>
          <setting-sub
            :titles="shijiJouhou.titles"
            :values="shijiJouhou.values"
            :category="shijiJouhou.category"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedTaijuuJouhou">
          <label>体重情報</label>
          <setting-sub
            :titles="taijuuJouhou.titles"
            :values="taijuuJouhou.values"
            :category="taijuuJouhou.category"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedJosuiHoseiJouhou">
          <label>除水補正</label>
          <setting-sub
            :titles="josuiHoseiJouhou.titles"
            :values="josuiHoseiJouhou.values"
            :category="josuiHoseiJouhou.category"
            @onCellClick="onCellClickOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedSousaHani">
          <label>操作範囲</label>
          <setting-sub
            :titles="sousaHani.titles"
            :values="sousaHani.values"
            :category="sousaHani.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedEcumSetting">
          <label>ECUM設定</label>
          <setting-sub
            :titles="ecumSetting.titles"
            :values="ecumSetting.values"
            :category="ecumSetting.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedKeihouTen">
          <label>警報点</label>
          <setting-sub
            :titles="keihouTen.titles"
            :values="keihouTen.values"
            :category="keihouTen.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedConcentration">
          <label>濃度プログラム自動設定警報</label>
          <setting-sub
            :titles="concentration.titles"
            :values="concentration.values"
            :category="concentration.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedKetsuatsuKei">
          <label>血圧計</label>
          <setting-sub
            :titles="ketsuatsuKei.titles"
            :values="ketsuatsuKei.values"
            :category="ketsuatsuKei.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedBv">
          <label>BV計</label>
          <!-- #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start -->
          <!--
          <setting-sub
            :titles="bv.titles"
            :values="bv.values"
            :category="bv.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
          -->
          <setting-sub
            :titles="bv.titles"
            :values="bv.values"
            :count="this.so2Count"
            :category="bv.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
          <!-- #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 end -->
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedPrimingAndHenketsu">
          <label>プライミング</label>
          <setting-sub
            :titles="primingAndHenketsu.titles"
            :values="primingAndHenketsu.values"
            :category="primingAndHenketsu.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedDFas">
          <label>D-FAS</label>
          <setting-sub
            :titles="dFas.titles"
            :values="dFas.values"
            :category="dFas.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedJoumyakuAtsu">
          <label>静的静脈圧</label>
          <setting-sub
            :titles="seitekiJoumyakuAtsu.titles"
            :values="seitekiJoumyakuAtsu.values"
            :category="seitekiJoumyakuAtsu.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedDiversionProgram">
          <label>除水プログラム</label>
          <setting-sub
            :titles="diversionProgram.titles"
            :values="diversionProgram.values"
            :category="diversionProgram.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedNaInjectionProgram">
          <label>Na注入プログラム</label>
          <setting-sub
            :titles="naInjectionProgram.titles"
            :values="naInjectionProgram.values"
            :category="naInjectionProgram.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedDialysisSolConcentrationProgram">
          <label>透析液濃度プログラム</label>
          <setting-sub
            :titles="dialysisSolConcentrationProgram.titles"
            :values="dialysisSolConcentrationProgram.values"
            :category="dialysisSolConcentrationProgram.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedKetsuryuuRyouProgram">
          <label>血流量・透析液流量プログラム</label>
          <setting-sub
            :titles="ketsuryuuRyouAndTousekiEkiRyuuRyouProgram.titles"
            :values="ketsuryuuRyouAndTousekiEkiRyuuRyouProgram.values"
            :category="ketsuryuuRyouAndTousekiEkiRyuuRyouProgram.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedIHDF">
          <label>I-HDF</label>
          <setting-sub
            :titles="iHdf.titles"
            :values="iHdf.values"
            :category="iHdf.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <v-ons-list-item v-if="isBvUfc" expandable v-model:expanded="isExpandedBVUfc">
          <label>BV-UFC</label>
          <setting-sub
            :titles="bvUfc.titles"
            :values="bvUfc.values"
            :category="bvUfc.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <!-- /* modify by yangzhaokai 2022-12-12 #5502 治療記録＞装置設定のタブの不正 --start */-->
        <v-ons-list-item  v-if="isDialysisAmountProgram" expandable v-model:expanded="isExpandedTousekiEkiProgram"
                          id="tousekiRyouProgramId" @click="changeScroll('tousekiRyouProgramId')">
          <!-- /* modify by yangzhaokai 2022-12-12 #5502 治療記録＞装置設定のタブの不正 --end */-->
          <label>透析量プログラム</label>
          <setting-sub
            :titles="tousekiRyouProgram.titles"
            :values="tousekiRyouProgram.values"
            :category="tousekiRyouProgram.category"
            @onCellClick="onCellClickNotOffWater"
          ></setting-sub>
        </v-ons-list-item>
        <!-- /* modify by yangzhaokai 2022-12-12 #5502 治療記録＞装置設定のタブの不正 --start */-->
        <v-ons-list-item expandable v-model:expanded="isExpandedMasterJouhou"
                         id="masterJouhouId" @click="changeScroll('masterJouhouId')">
          <!-- /* modify by yangzhaokai 2022-12-12 #5502 治療記録＞装置設定のタブの不正 --end */-->
          <label>マスタ情報</label>
          <setting-sub
            :titles="masterJouhou.titles"
            :values="masterJouhou.values"
            :category="masterJouhou.category"
          ></setting-sub>
        </v-ons-list-item>
        <!-- FNSI-add 装置設定画面表示の修正 徐 end -->
      </v-ons-list>
      <v-ons-modal
        v-for="(item, index) in josuiHoseiJouhou.values"
        :key="index"
        v-if="offWaterComponentActive[index]"
        :visible="offWaterComponentActive[index]"
      >
        <tare-and-off-water-base
          header-title="除水補正情報"
          :isTreat=true
          @hide-modal="hideOffWaterComponent(index)"
        >
          <off-water-info-editor
            :propsOrdNo="getOrdNo"
            :propsPatId="patIdByOrdNo"
            :propsFacilityCd="facilityCdByOrdNo"
            :propsTableFlag="3"
            :propsModalData="item"
          />
        </tare-and-off-water-base>
      </v-ons-modal>
      </div>
    </template>
  </submenu-base>
</template>

<script>
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
import { getMachineSo2OptCount } from "@/apis/mst-machine-maintenance";
// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
import {mapGetters, mapActions, mapMutations} from "@/compat/vue/vuex";
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import SettingSubComponent from "@/components/treatment-record/submenu/setting/SettingSubComponent";
import { Setting, CATEGORY } from "@/models/treatment-record/setting/Setting";
import OffWaterInfoEditor from "@/components/deviceset-info/off-water-info/OffWaterInfoEditor";
import baseTareOffwater from "@/components/deviceset-info/base-modules/TareAndOffWaterInfoEditBase.vue";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end
import { EventBus } from "@/compat/vue/event-bus.js";
import { CODES } from "@/constants/TreatmentRecord.js";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";

/** 装置設定値取得元 治療記録 */
import { DATA_SOURCE_TYPE_TREAT } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

class Device {
  constructor(name, type) {
    this.name = name;
    this.type = type;
  }
}

export default {
  mixins: [ComponentGuardMixin,baseDeviceSetInfoList],
  components: {
    "submenu-base": SubmenuBase,
    "setting-sub": SettingSubComponent,
    "off-water-info-editor": OffWaterInfoEditor,
    "tare-and-off-water-base": baseTareOffwater,
  },
  data() {
    return {
      dataSourceType: DATA_SOURCE_TYPE_TREAT,
      isExpandedSousaHani: true,
      isExpandedKeihouTen: true,
      isExpandedKetsuatsuKei: true,
      isExpandedBv: true,
      isExpandedPrimingAndHenketsu: true,
      isExpandedDFas: true,
      isExpandedSouchiProgram: true,
      isExpandedKetsuryuuRyouProgram: true,
      isExpandedTousekiEkiProgram: true,
      isExpandedBVUfc: true,
      isExpandedIHDF: true,
      isExpandedJoumyakuAtsu: true,
      isExpandedKeihouJouhou: true,
      isExpandedShijiJouhou: true,
      isExpandedJosuiHoseiJouhou: true,
      isExpandedTaijuuJouhou: true,
      isExpandedMasterJouhou: true,
      // FNSI-add 装置設定画面表示の修正 徐 start
      isExpandedEcumSetting: true,
      isExpandedConcentration: true,
      isExpandedDiversionProgram: true,
      isExpandedNaInjectionProgram: true,
      isExpandedDialysisSolConcentrationProgram: true,
      dialysisSolConcentrationProgram: {
        titles: [],
        values: [],
        category: CATEGORY.DIALYSIS_SOL_CONCENTRATION_PROGRAM
      },
      naInjectionProgram: {
        titles: [],
        values: [],
        category: CATEGORY.NA_INJECTIONPROGRAM
      },
      diversionProgram: {
        titles: [],
        values: [],
        category: CATEGORY.DIVERSION_PROGRAM
      },
      concentration: {
        titles: [],
        values: [],
        category: CATEGORY.CONCENTRATION_PROGRAM
      },
      ecumSetting: {
        titles: [],
        values: [],
        category: CATEGORY.ECUM_SETTING
      },
      // FNSI-add 装置設定画面表示の修正 徐 end
      sousaHani: {
        titles: [],
        values: [],
        category: CATEGORY.SOUSA_HANI
      },
      keihouTen: {
        titles: [],
        values: [],
        category: CATEGORY.KEIHOU_TEN
      },
      ketsuatsuKei: {
        titles: [],
        values: [],
        category: CATEGORY.KETSUATSU_KEI
      },
      bv: {
        titles: [],
        values: [],
        category: CATEGORY.BV
      },
      primingAndHenketsu: {
        titles: [],
        values: [],
        category: CATEGORY.PRIMING_AND_HENKETSU
      },
      dFas: {
        titles: [],
        values: [],
        category: CATEGORY.DFAS
      },
      souchiProgram: {
        titles: [],
        values: [],
        category: CATEGORY.SOUCHI_PROGRAM
      },
      ketsuryuuRyouAndTousekiEkiRyuuRyouProgram: {
        titles: [],
        values: [],
        category: CATEGORY.KETSURYUU_RYOU_AND_TOUSEKIEKI_RYUURYOU_PROGRAM
      },
      tousekiRyouProgram: {
        titles: [],
        values: [],
        category: CATEGORY.TOUSEKI_RYOU_PROGRAM
      },
      bvUfc: {
        titles: [],
        values: [],
        category: CATEGORY.BV_UFC
      },
      iHdf: {
        titles: [],
        values: [],
        category: CATEGORY.IHDF
      },
      seitekiJoumyakuAtsu: {
        titles: [],
        values: [],
        category: CATEGORY.SEITEKI_JOUMYAKU_ATSU
      },
      shijiJouhou: {
        titles: [],
        values: [],
        category: CATEGORY.SHIJI_JOUHOU
      },
      josuiHoseiJouhou: {
        titles: [],
        values: [],
        category: CATEGORY.JOSUI_HOSEI_JOUHOU
      },
      taijuuJouhou: {
        titles: [],
        values: [],
        category: CATEGORY.TAIJUU_JOUHOU
      },
      masterJouhou: {
        titles: [],
        values: [],
        category: CATEGORY.MASTER_JOUHOU
      },
      rstDeviceSetInfo: null,
      patIdByOrdNo: null,
      facilityCdByOrdNo: null,
      activeDeviceSetInfoComponentName: "",
      deviceSetInfoComponentActive: false, // 実績：装置設定情報を渡すコンポーネントの表示/非表示フラグ
      offWaterComponentActive: [],   // 除水補正情報コンポーネントの表示/非表示フラグ（パラメータが異なるので個別で定義）
      // del #10359 編集権限の動作不正 dengshen start
      // authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
      // del #10359 編集権限の動作不正 dengshen end
      selfScreenName: "",
      //add FNSI修正 装置設定バッグ改修 房 start
      initData: [],
      //add FNSI修正 装置設定バッグ改修 房 end
      // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
      so2Count: 0
      // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
    };
  },
  computed: {
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
    ...mapGetters("treatment-record/common", [
      "getOrdNo",
      "getDialysisState",
      "getOrd",
      // add 孫 svn72
      "getSharedFacilityCd"
      // add 孫 svn72 end
      ]),
    ...mapGetters("user", ["getAdvancedSettings"]),
    rstDeviceSetInfoIsNull() {
      return this.rstDeviceSetInfo === null;
    },
    /**
     * 拡張設定-BV-UFC表示
     */
    isBvUfc() {
      return this.getAdvancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.BV_UFC
      );
    },
    /**
     * 拡張設定-透析量プログラム表示
     */
    isDialysisAmountProgram() {
      return this.getAdvancedSettings.func_advcds.some(
        setting =>
          setting.func_advcd === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
      );
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    },

    ...mapGetters("user", ["getFacilityCd"]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    }

  },
  watch: {
    getOrdNo() {
      this.refresh();
    }
  },
  methods: {
    ...mapActions("treatment-record/setting", {
      getTreatmentRecordSetting: "getTreatmentRecordSetting",
      postOrderReadSettingValue: "postOrderReadSettingValue",
      getTreatmentRecordRstDeviceSetInfo: "getTreatmentRecordRstDeviceSetInfo",
      //add FNSI修正 装置設定バッグ改修 房 start
      setSubParams: "setSubParams",
      //add FNSI修正 装置設定バッグ改修 房 end
    }),
    ...mapMutations("multi-modal", ["setTitle"]),
    async init() {
      if (!this.getOrdNo) {
        return;
      }
      const settingResponse = await this.getTreatmentRecordSetting({
        ordNo: this.getOrdNo,
        selectedPatId: this.selectedPatId
      });

      const ordTreatCondition = settingResponse.data.map(t => {
        return {
          receive_date: t.receive_date,
          treat_condition: JSON.parse(t.treat_condition),
          treat_class: t.treat_class
        };
      });

      if (ordTreatCondition.length === 0) {
        this.showDataNotExistDialog();
        // del #10825 治療記録>装置設定でデータがない場合に別治療日の内容が表示されたままになる 張玲 start
        // return;
        // del #10825 治療記録>装置設定でデータがない場合に別治療日の内容が表示されたままになる 張玲 end
      }

      const settings = ordTreatCondition.map(t => new Setting(t));
      //add FNSI修正 装置設定バッグ改修 房 start
      this.initData = settings;
      //add FNSI修正 装置設定バッグ改修 房 end
      // FNSI-add 装置設定画面表示の修正 徐 start
      // mod #10825 治療記録>装置設定でデータがない場合に別治療日の内容が表示されたままになる 張玲 start
      // ECUM設定
      this.ecumSetting.titles = settings.length == 0 ? [] : settings[0].getEcumSettingTitle();
      this.ecumSetting.values = settings.length == 0 ? [] : settings.map(s => s.getEcumSetting());
      // 濃度プログラム自動設定警報
      this.concentration.titles = settings.length == 0 ? [] : settings[0].getConcentrationTitle();
      this.concentration.values = settings.length == 0 ? [] : settings.map(s => s.getConcentration());
      // 除水プログラム
      this.diversionProgram.titles = settings.length == 0 ? [] : settings[0].getDiversionProgramTitle();
      this.diversionProgram.values = settings.length == 0 ? [] : settings.map(s => s.getDiversionProgram());
      // Na注入プログラム
      this.naInjectionProgram.titles = settings.length == 0 ? [] : settings[0].getNaInjectionProgramTitle();
      this.naInjectionProgram.values = settings.length == 0 ? [] : settings.map(s => s.getNaInjectionProgram());
      // 透析液濃度プログラム
      this.dialysisSolConcentrationProgram.titles = settings.length == 0 ? [] : settings[0].getDialysisSolConcentrationProgramTitle();
      this.dialysisSolConcentrationProgram.values = settings.length == 0 ? [] : settings.map(s => s.getDialysisSolConcentrationProgram());
      // FNSI-add 装置設定画面表示の修正 徐 end
      // TODO 項目名は別ファイルに定義する。
      this.sousaHani.titles = settings.length == 0 ? [] : settings[0].getSousaHaniTitle();
      this.sousaHani.values = settings.length == 0 ? [] : settings.map(s => s.getSousaHani());

      this.keihouTen.titles = settings.length == 0 ? [] : settings[0].getKeihouTenTitle();
      this.keihouTen.values = settings.length == 0 ? [] : settings.map(s => s.getKeihouTen());

      this.ketsuatsuKei.titles = settings.length == 0 ? [] : settings[0].getKetsuatsuKeiTitle();
      this.ketsuatsuKei.values = settings.length == 0 ? [] : settings.map(s => s.getKetsuatsuKei());

      // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start
      //this.bv.titles = settings.length == 0 ? [] : settings[0].getBvTitle();
      this.bv.titles = settings.length == 0 ? [] : settings[0].getBvTitle(this.so2Count);
      // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 end
      this.bv.values = settings.length == 0 ? [] : settings.map(s => s.getBv());

      this.primingAndHenketsu.titles = settings.length == 0 ? [] : settings[0].getPrimingAndHenketsuTitle();
      this.primingAndHenketsu.values = settings.length == 0 ? [] : settings.map(s =>
        s.getPrimingAndHenketsu()
      );

      this.dFas.titles = settings.length == 0 ? [] : settings[0].getDFasTitle();
      this.dFas.values = settings.length == 0 ? [] : settings.map(s => s.getDFas());

      this.souchiProgram.titles = settings.length == 0 ? [] : settings[0].getSouchiProgramTitle();
      this.souchiProgram.values = settings.length == 0 ? [] : settings.map(s => s.getSouchiProgram());

      this.ketsuryuuRyouAndTousekiEkiRyuuRyouProgram.titles = settings.length == 0 ? [] : settings[0].getKetsuryuuRyouAndTousekiEkiRyuuRyouProgramTitle();
      this.ketsuryuuRyouAndTousekiEkiRyuuRyouProgram.values = settings.length == 0 ? [] : settings.map(s =>
        s.getKetsuryuuRyouAndTousekiEkiRyuuRyouProgram()
      );

      this.tousekiRyouProgram.titles = settings.length == 0 ? [] : settings[0].getTousekiRyouProgramTitle();
      this.tousekiRyouProgram.values = settings.length == 0 ? [] : settings.map(s =>
        s.getTousekiRyouProgram()
      );

      this.bvUfc.titles = settings.length == 0 ? [] : settings[0].getBvUfcTitle();
      this.bvUfc.values = settings.length == 0 ? [] : settings.map(s => s.getBvUfc());

      this.iHdf.titles = settings.length == 0 ? [] : settings[0].getIHdfTitle();
      this.iHdf.values = settings.length == 0 ? [] : settings.map(s => s.getIHdf());

      this.seitekiJoumyakuAtsu.titles = settings.length == 0 ? [] : settings[0].getSeitekiJoumyakuAtsuTitle();
      this.seitekiJoumyakuAtsu.values = settings.length == 0 ? [] : settings.map(s =>
        s.getSeitekiJoumyakuAtsu()
      );

      this.shijiJouhou.titles = settings.length == 0 ? [] : settings[0].getShijiJouhouTitle();
      this.shijiJouhou.values = settings.length == 0 ? [] : settings.map(s => s.getShijiJouhou());

      this.josuiHoseiJouhou.titles = settings.length == 0 ? [] : settings[0].getJosuiHoseiJouhouTitle();
      this.josuiHoseiJouhou.values = settings.length == 0 ? [] : settings.map(s => s.getJosuiHoseiJouhou());
      // 除水補正モーダルの表示状態を初期化（要素数と同じ長さの配列を作成）
      this.offWaterComponentActive = this.josuiHoseiJouhou.values.map(() => false);

      this.taijuuJouhou.titles = settings.length == 0 ? [] : settings[0].getTaijuuJouhouTitle();
      this.taijuuJouhou.values = settings.length == 0 ? [] : settings.map(s => s.getTaijuuJouhou());

      this.masterJouhou.titles = settings.length == 0 ? [] : settings[0].getMasterJouhouTitle();
      this.masterJouhou.values = settings.length == 0 ? [] : settings.map(s => s.getMasterJouhou());
      // mod #10825 治療記録>装置設定でデータがない場合に別治療日の内容が表示されたままになる 張玲 end

      // 実績：装置設定情報を取得
      await this.fetchRstDeviceSetInfo();
    },
    /* add by yangzhaokai 2022-12-12 #5502 治療記録＞装置設定のタブの不正 --start */
    /**
     * スクロールバーの修正
     * @param id コンボーネントID
     */
    changeScroll(id) {
      setTimeout(function(){
        getScopedElementById(id, this.$el || null)?.scrollIntoView?.();
      },100)
    },
    /* add by yangzhaokai 2022-12-12 #5502 治療記録＞装置設定のタブの不正 --end */
    /**
     * 装置設定取得処理
     */
    fetchSouchiSettei() {
      if(this.isReadOnly) {
        return;
      }
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "",
        title: DIALOG_MESSAGES[13000149].title,
        // message: "装置設定を取得します。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000149].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const param = {
              ordNo: this.getOrdNo
            };
            this.postOrderReadSettingValue(param);
            // 完了ダイアログ
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "",
              // message: "装置設定の取得処理を実行しました。"
              title: DIALOG_MESSAGES[12000268].title,
              message: messageFormat(DIALOG_MESSAGES[12000268].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        }
      });
    },
    /**
     * 実績：装置設定情報取得
     */
    async fetchRstDeviceSetInfo() {
      const response = await this.getTreatmentRecordRstDeviceSetInfo({
        ordNo: this.getOrdNo,
        selectedPatId: this.selectedPatId
      });
      const data = response.data;

      if(data.rst_device_set_info != null){
        this.rstDeviceSetInfo = JSON.parse(data.rst_device_set_info || "{}");
      }
      this.patIdByOrdNo = data.pat_id;
      this.facilityCdByOrdNo = data.facility_cd;
    },
    /**
     * 「データがありません。」ダイアログを表示する
     */
    showDataNotExistDialog() {
      this.$ons.notification.alert({
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // title: "",
        // message: "データがありません。"
        title: DIALOG_MESSAGES[12000328].title,
        message: messageFormat(DIALOG_MESSAGES[12000328].message)
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      });
    },
    /**
     * コンポーネントを表示する
     * @params {string} コンポーネント名
     */
    showDeviceSetInfoComponent(device) {
      this.showModal(device, DATA_SOURCE_TYPE_TREAT)
    },
    /**
     * 除水補正情報コンポーネントを表示する
     */
    showOffWaterComponent(selectedIndex) {
      /**
       * 非同期インポートを待機して表示 ※こうしないとスタイルが正しく適用されない（らしい）
       * ここも一応nextTickでフラグをtrueにする
       * see: src/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue
       */
      this.$nextTick(() => {
        ((this.offWaterComponentActive)[selectedIndex] = true);
        this.setTitle("除水補正");
      });
    },
    /**
     * コンポーネントを非表示にする
     */
    hideDeviceSetInfoComponent() {
      this.activeDeviceSetInfoComponentName = "";
      this.deviceSetInfoComponentActive = false;
    },
    /**
     *
     * 除水補正情報コンポーネントを非表示にする
     */
    hideOffWaterComponent(selectedIndex) {
      ((this.offWaterComponentActive)[selectedIndex] = false);
    },
    /**
     * カテゴリーとjsonKeyから、表示するコンポーネント名を取得する
     *
     * @param {string} category カテゴリー
     * @param {string} jsonKey jsonKey モデルで定義
     * @returns {string} コンポーネント名
     */
    getComponentName(category, jsonKey) {
      //add 9917治療記録>装置設定>静的静脈圧をクリックして詳細画面が開かない zhap start
      // 静的静脈圧
      if(category === CATEGORY.SEITEKI_JOUMYAKU_ATSU) return new Device("静的静脈圧", this.DEVICE_TYPE_IAP);
      //add 9917治療記録>装置設定>静的静脈圧をクリックして詳細画面が開かない zhap end
      // 操作範囲
      if(category === CATEGORY.SOUSA_HANI) return new Device("操作範囲", this.DEVICE_TYPE_OPE);

      // 警報点
      if(category === CATEGORY.KEIHOU_TEN) return new Device("警報点", this.DEVICE_TYPE_WAR);

      // 血圧計
      if(category === CATEGORY.KETSUATSU_KEI) return new Device("血圧計", this.DEVICE_TYPE_BP);

      // BV
      if(category === CATEGORY.BV) return new Device("BV計", this.DEVICE_TYPE_BV);

      // プライミング・返血
      if(category === CATEGORY.PRIMING_AND_HENKETSU) return new Device("プライミング", this.DEVICE_TYPE_PRI);

      // D-FAS
      if(category === CATEGORY.DFAS) return new Device("D-FAS", this.DEVICE_TYPE_DFAS);

      // 血流量・透析液流量プログラム
      if(category === CATEGORY.KETSURYUU_RYOU_AND_TOUSEKIEKI_RYUURYOU_PROGRAM) return new Device("血流量・透析液流量プログラム", this.DEVICE_TYPE_QBQD);

      // 透析量プログラム
      if(category === CATEGORY.TOUSEKI_RYOU_PROGRAM) return new Device("透析量プログラム", this.DEVICE_TYPE_DIA);

      // BV-UFC
      if(category === CATEGORY.BV_UFC) return new Device("BV-UFC", this.DEVICE_TYPE_BVUFC);

      // I-HDF
      if(category === CATEGORY.IHDF) return new Device("I-HDF", this.DEVICE_TYPE_IHDF);

      // FNSI-add 装置設定画面表示の修正 徐 start
      // ECUM設定
      if(category === CATEGORY.ECUM_SETTING) return new Device("ECUM設定", this.DEVICE_TYPE_ECUM);
      // 濃度プログラム自動設定警報
      if(category === CATEGORY.CONCENTRATION_PROGRAM) return new Device("濃度プログラム自動設定警報", this.DEVICE_TYPE_CPRO);
      // 除水プログラム
      if(category === CATEGORY.DIVERSION_PROGRAM) return new Device("除水プログラム", this.DEVICE_TYPE_UFR);
      // Na注入プログラム
      if(category === CATEGORY.NA_INJECTIONPROGRAM) return new Device("Na注入プログラム", this.DEVICE_TYPE_NA);
      // 透析液濃度プログラム
      if(category === CATEGORY.DIALYSIS_SOL_CONCENTRATION_PROGRAM) return new Device("透析液濃度プログラム", this.DEVICE_TYPE_DC);
      // // 装置プログラム
      // if(category === CATEGORY.SOUCHI_PROGRAM) {
      //   if([
      //       "290", "311", "312", "291", "292"
      //       , "293", "294", "295", "296", "297"
      //       , "298", "299", "300", "301", "302"
      //       , "303", "304", "305", "306", "307"
      //       , "308", "309", "310", "313", "314"
      //     // mod FNSI-UFRプログラムの修正 楊 start
      //     //].includes(jsonKey)) return new Device("UFRプログラム", this.DEVICE_TYPE_UFR);
      //   ].includes(jsonKey)) return new Device("除水プログラム", this.DEVICE_TYPE_UFR);
      //   // mod FNSI-UFRプログラムの修正 楊 end

      //   if([
      //       "315", "326", "328", "327", "316"
      //       , "317", "318", "319", "320", "321"
      //       , "322", "323", "324", "325", "329"
      //       , "330", "184"
      //     ].includes(jsonKey)) return new Device("Na注入プログラム", this.DEVICE_TYPE_NA);

      //   if([
      //       "340", "368", "367", "361", "341"
      //       , "342", "343", "344", "345", "346"
      //       , "347", "348", "349", "350", "362"
      //       , "363", "364", "351", "352", "353"
      //       , "354", "355", "356", "357", "358"
      //       , "359", "360", "365", "366"
      //     ].includes(jsonKey)) return new Device("透析液濃度プログラム", this.DEVICE_TYPE_DC);

      //   if([
      //       "16", "17", "18", "19"
      //     ].includes(jsonKey)) return new Device("ECUM専用設定", this.DEVICE_TYPE_ECUM);

      //   if([
      //       "252", "253", "250", "251"
      //     ].includes(jsonKey)) return new Device("濃度プロ自動設定警報", this.DEVICE_TYPE_CPRO);
      // }
      // FNSI-add 装置設定画面表示の修正 徐 end

      return undefined;
    },
    /**
     * 除水補正情報以外のセルを押下したときに実行される関数
     * @param {string} category カテゴリー CATEGORYで定義
     * @param {string} jsonKey jsonキー
     */
    //mod FNSI修正 装置設定バッグ改修 房 start
    // onCellClickNotOffWater(category, jsonKey) {
    onCellClickNotOffWater(category, jsonKey, index) {
      //mod FNSI修正 装置設定バッグ改修 房 end
      const device = this.getComponentName(category, jsonKey);
      if(!device) return;

      //mod FNSI 外結バッグ69 房 start
      //add FNSI修正 装置設定バッグ改修 房 start
      // if(this.rstDeviceSetInfoIsNull) {
      //   this.showDataNotExistDialog();
      //   return;
      // }
      this.setSubParams(this.editParams(index));
      // add #7241 治療記録で装置設定のI-HDF画面を表示するとデータが表示せず編集画面を閉じることができない 付 start
      if (category === 'iHdf') {
        let ihdf = this.editParams(index)
        ihdf = JSON.parse(ihdf)
        if (ihdf.ihdf.dev.A[432] === undefined || ihdf.ihdf.dev.A[432] === null || ihdf.ihdf.dev.A[432] === '') {
          return
        }
      }
      // add #7241 治療記録で装置設定のI-HDF画面を表示するとデータが表示せず編集画面を閉じることができない 付 end
      //add FNSI修正 装置設定バッグ改修 房 end
      //mod FNSI 外結バッグ69 房 end
      this.showDeviceSetInfoComponent(device);
    },
    /**
     * 除水補正情報のセルを押下したときに実行される関数
     * @param {String} category 装置設定のカテゴリ名
     * @param {String} jsonKey クリックしたセル項目のjsonKey
     * @param {Number} selectedIndex クリックしたセルの列番号(0から)
     */
    onCellClickOffWater(category, jsonKey, selectedIndex) {
      this.showOffWaterComponent(selectedIndex);
    },
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      this.init();
    },

    /**
     * 装置設定取得ボタン表示有無を判定する.
     * 表示している実績の治療状況が排液済(rst_dialysis_state=4)以降の場合、falseを返す.
     * @returns {Boolean} 治療状況が排液済以降の場合、falseを返す.
     */
    isDispBtnMachineSetting() {
      // 治療状況が排液済以降はボタンを表示しない
      return ![
        Number(CODES.DIALYSIS_STATE.AFTER_DRAINAGE.cd),
        Number(CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd),
        Number(CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd)
      ].includes(this.getDialysisState);
    },
    //add FNSI修正 装置設定バッグ改修 房 start
    editParams(index){
      const dataSource = this.initData[index].treatCondition;
      //mod FNSI 外結バッグ69 房 start
      const paramData = {
        "bp":{
          "dev":{
            "A":{
              "190":dataSource[190],
              "191":dataSource[191],
              "192":dataSource[192],
              "193":dataSource[193],
              "194":dataSource[194],
              "195":dataSource[195],
              "211":dataSource[211],
              "212":dataSource[212],
              "213":dataSource[213],
              "214":dataSource[214],
              "215":dataSource[215],
              "216":dataSource[216],
              "217":dataSource[217],
              "218":dataSource[218],
              "219":dataSource[219],
              "220":dataSource[220],
              "221":dataSource[221],
              "222":dataSource[222],
              "223":dataSource[223],
              "224":dataSource[224],
              "225":dataSource[225],
              "226":dataSource[226],
              "227":dataSource[227],
              "228":dataSource[228],
              "229":dataSource[229],
              "230":dataSource[230],
              "231":dataSource[231],
              "232":dataSource[232],
              "233":dataSource[233],
              "234":dataSource[234],
              "235":dataSource[235],
              "236":dataSource[236],
              "237":dataSource[237],
              "238":dataSource[238],
              "239":dataSource[239]
            }
          }
        },
        "bv":{
          "dev":{
            "A":{
              "258":dataSource[258],
              "259":dataSource[259] == -1 ? "" : dataSource[259],
              "260":dataSource[260],
              "261":dataSource[261],
              "262":dataSource[262],
              "263":dataSource[263] == -1 ? "" : dataSource[263],
              "264":dataSource[264] == -1 ? "" : dataSource[264],
              "265":dataSource[265] == -1 ? "" : dataSource[265],
              "266":dataSource[266] == -1 ? "" : dataSource[266],
              "267":dataSource[267],
              "277":dataSource[277],
              "278":dataSource[278],
              // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
              "476":dataSource[476],
              // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
              "281":dataSource[281]
            }
          }
        },
        "dc":{
          "dev":{
            "A":{
              "340":dataSource[340],
              "341":dataSource[341],
              "342":dataSource[342],
              "343":dataSource[343],
              "344":dataSource[344],
              "345":dataSource[345],
              "346":dataSource[346],
              "347":dataSource[347],
              "348":dataSource[348],
              "349":dataSource[349],
              "350":dataSource[350],
              "351":dataSource[351],
              "352":dataSource[352],
              "353":dataSource[353],
              "354":dataSource[354],
              "355":dataSource[355],
              "356":dataSource[356],
              "357":dataSource[357],
              "358":dataSource[358],
              "359":dataSource[359],
              "360":dataSource[360],
              "361":dataSource[361],
              "362":dataSource[362],
              "363":dataSource[363],
              "364":dataSource[364],
              "365":dataSource[365],
              "366":dataSource[366],
              "367":dataSource[367],
              "368":dataSource[368]
            },
            "B":{
              "10":0,
              "11":0,
              "12":0,
              "13":0,
              "14":0,
              "15":0,
              "16":0,
              "17":0,
              "18":0,
              "19":0,
              "20":0,
              "21":0,
              "22":0,
              "23":0,
              "24":0,
              "25":0,
              "26":0,
              "27":0,
              "28":0,
              "29":0
            }
          }
        },
        "na":{
          "dev":{
            "A":{
              "184":dataSource[184],
              "315":dataSource[315],
              "316":dataSource[316],
              "317":dataSource[317],
              "318":dataSource[318],
              "319":dataSource[319],
              "320":dataSource[320],
              "321":dataSource[321],
              "322":dataSource[322],
              "323":dataSource[323],
              "324":dataSource[324],
              "325":dataSource[325],
              "326":dataSource[326],
              "327":dataSource[327],
              "328":dataSource[328],
              "329":dataSource[329],
              "330":dataSource[330]
            }
          }
        },
        "dia":{
          "dev":{
            "A":{
              "282":0,
              "288":0
            }
          }
        },
        "iap":{
          "dev":{
            "A":{
              "468":dataSource[468],
              "469":dataSource[469],
              "470":dataSource[470],
              "471":dataSource[471]
            }
          }
        },
        "ope":{
          "dev":{
            "A":{
              "21":dataSource[21],
              "22":dataSource[22],
              "24":dataSource[24],
              "25":dataSource[25],
              "38":dataSource[38],
              "39":dataSource[39],
              "90":dataSource[90],
              "91":dataSource[91],
              "92":dataSource[92],
              "168":dataSource[168],
              "169":dataSource[169],
              "171":dataSource[171],
              "172":dataSource[172],
              "174":dataSource[174],
              "175":dataSource[175],
              "177":dataSource[177],
              "178":dataSource[178],
              "179":dataSource[179],
              "181":dataSource[181],
              "182":dataSource[182],
              "183":dataSource[183],
              "185":dataSource[185],
              "186":dataSource[186],
              "241":dataSource[241],
              "268":dataSource[268],
              "269":dataSource[269],
              "336":dataSource[336],
              "337":dataSource[337],
              "369":dataSource[369],
              "379":"",
              "383":dataSource[383],
              "384":dataSource[384],
              "385":dataSource[385],
              "386":dataSource[386],
              "387":dataSource[387],
              "389":dataSource[389],
              "391":dataSource[391],
              "392":dataSource[392],
              "394":dataSource[394],
              "395":dataSource[395],
              "396":dataSource[396],
              "397":dataSource[397],
              "398":dataSource[398],
              "472":dataSource[472],
              "473":dataSource[473],
              "474":dataSource[474],
              "475":dataSource[475]
            },
            "B":{
              "30":"",
              "31":dataSource[31],
              "32":dataSource[32],
              "33":"",
              "34":dataSource[34],
              "35":dataSource[35],
              "37":"",
              "38":"",
              "39":"",
              "40":dataSource[40]
            },
            "C":{
              "91":"",
              "92":""
            }
          }
        },
        "pri":{
          "dev":{
            "A":{
              "370":dataSource[370],
              "371":dataSource[371],
              "372":dataSource[372]
            }
          },
          "pat":{
            "A":{
              "219":"",
              "220":"",
              "221":"",
              "222":"",
              "223":"",
              "224":"",
              "225":"",
              "226":"",
              "227":"",
              "228":"",
              "229":"",
              "230":"",
              "231":"",
              "232":"",
              "233":"",
              "234":"",
              "235":"",
              "236":"",
              "237":"",
              "238":""
            },
            "B":{
              "32":"",
              "33":"",
              "51":"",
              "52":"",
              "53":""
            }
          }
        },
        "ufr":{
          "dev":{
            "A":{
              "290":dataSource[290],
              "291":dataSource[291],
              "292":dataSource[292],
              "293":dataSource[293],
              "294":dataSource[294],
              "295":dataSource[295],
              "296":dataSource[296],
              "297":dataSource[297],
              "298":dataSource[298],
              "299":dataSource[299],
              "300":dataSource[300],
              "301":dataSource[301],
              "302":dataSource[302],
              "303":dataSource[303],
              "304":dataSource[304],
              "305":dataSource[305],
              "306":dataSource[306],
              "307":dataSource[307],
              "308":dataSource[308],
              "309":dataSource[309],
              "310":dataSource[310],
              "311":dataSource[311],
              "312":dataSource[312],
              "313":dataSource[313],
              "314":dataSource[314]
            },
            "B":{
              "0":0,
              "1":0,
              "2":0,
              "3":0,
              "4":0,
              "5":0,
              "6":0,
              "7":0,
              "8":0,
              "9":0
            }
          }
        },
        "war":{
          "dev":{
            "A":{
              "100":dataSource[100],
              "101":dataSource[101],
              "102":dataSource[102],
              "103":dataSource[103],
              "104":dataSource[104],
              "105":dataSource[105],
              "106":dataSource[106],
              "107":dataSource[107],
              "108":dataSource[108],
              "109":dataSource[109],
              "110":dataSource[110],
              "111":dataSource[111],
              "112":dataSource[112],
              "113":dataSource[113],
              "114":dataSource[114],
              "115":dataSource[115],
              "116":dataSource[116],
              "117":dataSource[117],
              "118":dataSource[118],
              "119":dataSource[119],
              "120":dataSource[120],
              "121":dataSource[121],
              "122":dataSource[122],
              "123":dataSource[123],
              "124":dataSource[124],
              "125":dataSource[125],
              "126":dataSource[126],
              "127":dataSource[127],
              "128":dataSource[128],
              "129":dataSource[129],
              "130":dataSource[130],
              "131":dataSource[131],
              "132":dataSource[132],
              "133":dataSource[133],
              "134":dataSource[134],
              "135":dataSource[135],
              "136":dataSource[136],
              "137":dataSource[137],
              "138":dataSource[138],
              "139":dataSource[139],
              "140":dataSource[140],
              "141":dataSource[141],
              "142":dataSource[142],
              "143":dataSource[143],
              "144":dataSource[144],
              "145":dataSource[145],
              "146":dataSource[146],
              "147":dataSource[147],
              "148":dataSource[148],
              "149":dataSource[149],
              "150":dataSource[150],
              "151":dataSource[151],
              "152":dataSource[152],
              "153":dataSource[153],
              "154":dataSource[154],
              "155":dataSource[155],
              "156":dataSource[156],
              "157":dataSource[157],
              "158":dataSource[158],
              "159":dataSource[159],
              "160":dataSource[160],
              "161":dataSource[161],
              "162":dataSource[162],
              "163":dataSource[163],
              "240":dataSource[240],
              "242":dataSource[242],
              "243":dataSource[243],
              "244":dataSource[244],
              "245":dataSource[245],
              "246":dataSource[246],
              "247":dataSource[247],
              "254":dataSource[254],
              "255":dataSource[255],
              "256":dataSource[256],
              "257":dataSource[257]
            }
          }
        },
        "cpro":{
          "dev":{
            "A":{
              "250":dataSource[250],
              "251":dataSource[251],
              "252":dataSource[252],
              "253":dataSource[253]
            }
          }
        },
        "dfas":{
          "dev":{
            "A":{
              "270":dataSource[270],
              "331":dataSource[331],
              "332":dataSource[332],
              "333":dataSource[333],
              "334":dataSource[334],
              "338":dataSource[338],
              "339":dataSource[339],
              "373":dataSource[373],
              "374":dataSource[374],
              "376":dataSource[376],
              "377":dataSource[377],
              "378":dataSource[378]
            },
            "B":{
              "36":""
            }
          },
          "pat":{
            "B":{
              "1":"",
              "5":"",
              "7":"",
              "8":"",
              "9":"",
              "10":"",
              "54":"",
              "55":"",
              "56":"",
              "57":"",
              "58":"",
              "59":""
            }
          }
        },
        "ecum":{
          "dev":{
            "A":{
              "16":dataSource[16],
              "17":dataSource[17],
              "18":dataSource[18],
              "19":dataSource[19]
            }
          }
        },
        "ihdf":{
          "dev":{
            "A":{
              "200":dataSource[200],
              "201":dataSource[201],
              "202":dataSource[202],
              "203":dataSource[203],
              "204":dataSource[204],
              "205":dataSource[205],
              "432":dataSource[432],
              "433":dataSource[433],
              "434":dataSource[434],
              "435":dataSource[435],
              "436":dataSource[436],
              "437":dataSource[437],
              "438":dataSource[438],
              "439":dataSource[439],
              "440":dataSource[440],
              "441":dataSource[441],
              "442":dataSource[442],
              "443":dataSource[443],
              "444":dataSource[444],
              "445":dataSource[445],
              "446":dataSource[446],
              "447":dataSource[447],
              "448":dataSource[448],
              "449":dataSource[449],
              "450":dataSource[450],
              "451":dataSource[451],
              "452":dataSource[452],
              "453":dataSource[453],
              "454":dataSource[454],
              "455":dataSource[455],
              "456":dataSource[456],
              "457":dataSource[457],
              "458":dataSource[458],
              "459":dataSource[459],
              "460":dataSource[460],
              "461":dataSource[461],
              "462":dataSource[462],
              "463":dataSource[463],
              "464":dataSource[464],
              "465":dataSource[465],
              "466":dataSource[466]
            }
          }
        },
        "qbqd":{
          "dev":{
            "A":{
              "400":dataSource[400],
              "401":dataSource[401],
              "402":dataSource[402],
              "403":dataSource[403],
              "404":dataSource[404],
              "405":dataSource[405],
              "406":dataSource[406],
              "407":dataSource[407],
              "408":dataSource[408],
              "409":dataSource[409],
              "410":dataSource[410],
              "411":dataSource[411],
              "412":dataSource[412],
              "413":dataSource[413],
              "414":dataSource[414],
              "415":dataSource[415],
              "416":dataSource[416],
              "417":dataSource[417],
              "418":dataSource[418],
              "419":dataSource[419],
              "420":dataSource[420],
              "421":dataSource[421],
              "422":dataSource[422],
              "423":dataSource[423],
              "424":dataSource[424],
              "425":dataSource[425],
              "426":dataSource[426],
              "427":dataSource[427],
              "428":dataSource[428],
              "429":dataSource[429],
              "430":dataSource[430],
              "431":dataSource[431]
            }
          }
        },
        "bvufc":{
          "dev":{
            "A":{
              "196":dataSource[196],
              "197":dataSource[197],
              "198":dataSource[198],
              "199":dataSource[199],
              "206":dataSource[206],
              "207":dataSource[207],
              "208":dataSource[208],
              "209":dataSource[209],
              "210":dataSource[210],
              "248":dataSource[248],
              "249":dataSource[249],
              "271":dataSource[271],
              "272":dataSource[272],
              "273":dataSource[273],
              "274":dataSource[274],
              "275":dataSource[275]
            }
          }
        }
      };
      //mod FNSI 外結バッグ69 房 end
      return JSON.stringify(paramData);
    },
    //add FNSI修正 装置設定バッグ改修 房 end
  },
  async created() {
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
    // apiをコールしてΔSO2を使用する装置件数を取得
    await getMachineSo2OptCount(this.facilityCd, this.selectedPatId).then(
      (response) => {
        this.so2Count = response.data;
      }
    ),
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
    await this.init();
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // イベント登録
    EventBus.$on("refresh", this.refresh);
  },

  /**
   * コンポーネント破棄
   */
  beforeUnmount() {
    // イベント解除
    EventBus.$off("refresh", this.refresh);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.fetch-souchi-settei-button-area {
  display: flex;
  justify-content: flex-end !important;
  margin-right: 1em;
  margin-bottom: 1em;
}
ons-list-item {
  overflow: hidden;
  border: 1px solid #dddddd;
}
</style>
