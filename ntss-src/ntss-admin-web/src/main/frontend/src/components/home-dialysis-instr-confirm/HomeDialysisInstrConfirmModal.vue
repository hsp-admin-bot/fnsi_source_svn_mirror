/**
 * 検査結果グラフモーダルPage
 */
 <template>
  <modal-base @onClose="closeModal" class="custom-modal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <!-- 表 -->
    <div slot="body" class="modal-content">
      あなたの透析条件です。指示通りの透析を行ってください。<br>
      指示された材料が自宅に届きます。適切に使用してください。<br>
      <div class="disp-item-content-area">
        <v-ons-row class="row-content">
          <v-ons-col class="line-text-s">
            透析時間・頻度
          </v-ons-col>
          <v-ons-col><input
            :value="dialysTime"
            class="textbox-gray k-textbox textbox-size-s"
            disabled="disabled"
          /> 時間</v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            ダイアライザー
          </v-ons-col>
          <v-ons-col><input
            :value="dialyzer"
            class="textbox-gray k-textbox textbox-size-l"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            血液回路
          </v-ons-col>
          <v-ons-col><input
            :value="bloodCircuit"
            class="textbox-gray k-textbox textbox-size-l"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            針の種類、サイズ
          </v-ons-col>
          <v-ons-col><input
            :value="needle"
            class="textbox-gray k-textbox textbox-size-l"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            血流量(ml/分)
          </v-ons-col>
          <v-ons-col><input
            :value="bloodFlow"
            class="textbox-gray k-textbox textbox-size-l"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            透析液流量(ml/分)
          </v-ons-col>
          <v-ons-col><input
            :value="dialysateFlow"
            class="textbox-gray k-textbox textbox-size-l"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            抗凝固薬の種類、使用量
          </v-ons-col>
          <v-ons-col><input
            :value="anticoagulantType"
            class="textbox-gray k-textbox textbox-size-l"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="empty-text">
          </v-ons-col>
          <v-ons-col width="250px">
            初回  <input
            :value="anticoagulantFirst"
            class="textbox-gray k-textbox textbox-size-s"
            disabled="disabled"
          />  単位</v-ons-col>
          <v-ons-col>
            持続  <input
            :value="anticoagulantContinue"
            class="textbox-gray k-textbox textbox-size-s"
            disabled="disabled"
          />  単位/h</v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="line-text">
            透析液の種類、量(L瓶/透析)
          </v-ons-col>
          <v-ons-col width="295px"><input
            :value="dialysateType"
            class="textbox-gray k-textbox textbox-size-m"
            disabled="disabled"
          /></v-ons-col>
          <v-ons-col><input
            :value="dialysateAmount"
            class="textbox-gray k-textbox textbox-size-s"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content" v-for="(medi, index) in medication" :key="index">
          <v-ons-col class="line-text">
            投与薬剤の種類、使用量
          </v-ons-col>
          <v-ons-col width="295px"><input
            :value="medi.type"
            class="textbox-gray k-textbox textbox-size-m"
            disabled="disabled"
          /></v-ons-col>
          <v-ons-col><input
            :value="medi.amount"
            class="textbox-gray k-textbox textbox-size-s"
            disabled="disabled"
          /></v-ons-col>
        </v-ons-row>
        <v-ons-row class="row-content">
          <v-ons-col class="empty-text">
          </v-ons-col>
          <v-ons-col class="line-text" width="250px">
          </v-ons-col>
          <v-ons-col class="instractor-signature" style="text-align: left;">
            {{ instractorSignature }}
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <!-- フッター -->
    <div slot="footer" class="flex-container flex-container-footer">
      <div class="denial-btn-area" style="background:none; margin-right: 1em;">
        <button class="button registration-btn" @click="closeModal">閉じる</button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import moment from "moment";
import { IND_COND_ID } from "@/constants/IndCondInfoConstants.js";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

export default {
  name: "HomeDialysisInstrConfirmModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      main: "",
      header: "",

      // 各項目の値
      dialysTime: "", // 透析時間
      dialyzer: "", // ダイアライザー
      bloodCircuit: "", // 血液回路
      needle: "", // 針の種類
      bloodFlow: "", // 血流量
      dialysateFlow: "", // 透析液流量
      anticoagulantType: "", // 抗凝固薬の種類
      anticoagulantFirst: "", // 抗凝固薬（初回）
      anticoagulantContinue: "", // 抗凝固薬（持続）
      anticoagulantUnit: "", // 抗凝固薬（単位）
      dialysateType: "", // 透析液の種類
      dialysateAmount: "", // 透析液の量
      salineType: "", // 生理食塩液の種類
      salineAmount: "", // 生理食塩液の量
      esaType: "", // ESA製剤の種類
      esaAmount: "", // ESA製剤の量
      instractorSignature: "", // 医師の署名

      // 在宅患者治療パターン
      indCondInfo: "", // 治療条件情報
      indMediInfo: "", // 投与薬剤情報

      // 投与薬剤
      medication: [],

      // 署名関係
      instractorCd: 0,
      signatureDate: "",
      findInstractor: false,

      // マスタ
      mstDialyzerInfo: null,
      mstEquipmentInfo: null,
      mstMedicineInfo: null,
      mstPersonalUserInfo: null,
      mstPatHhdPatternInfo: null,
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPat"]),
    // maxueqiang add メモリにて利用者マスタ一覧取得 Start
    ...mapGetters("user", {
      getMstPersonalUser: "getMstPersonalUser"
    }),
    // maxueqiang add メモリにて利用者マスタ一覧取得 End
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),

    // ------------------------------------------------------------------
    // 各種マスタ取得メソッド
    // ------------------------------------------------------------------

    /**
     * ダイアライザマスタを取得する
     */
    async getMstDialyzer() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstDialyzerInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstDialyzer",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HomeDialysisInstrConfirmModal.vue', 'getMstDialyzer', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      if (200 !== response.status) {
        return null;
      }
      this.mstDialyzerInfo = response.data;
    },

    /**
     * 医療材料マスタを取得する
     */
    async getMstEquipment() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstEquipmentInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstEquipment",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HomeDialysisInstrConfirmModal.vue', 'getMstEquipment', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      if (200 !== response.status) {
        return null;
      }
      this.mstEquipmentInfo = response.data;
    },

    /**
     * 薬剤マスタを取得する
     */
    async getMstMedicine() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstMedicineInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicine",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HomeDialysisInstrConfirmModal.vue', 'getMstMedicine', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      if (200 !== response.status) {
        return null;
      }
      this.mstMedicineInfo = response.data;
    },

    /**
     * 利用者マスタを取得する
     */
    async getPersonalUser() {
      const paramJson = {};
      paramJson.facility_cd = this.getFacilityCd;
      this.mstPersonalUserInfo = this.getMstPersonalUser;
      if (null === this.mstPersonalUserInfo){
        await ApiHelper.get(
        "/mstInfo/mstPersonalUser",
          paramJson
        ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HomeDialysisInstrConfirmModal.vue', 'getPersonalUser', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw error;
        }).then(({data}) =>{
          this.mstPersonalUserInfo = data;
        })
      // if (200 !== response.status) {
      //   return null;
      // }
      // this.mstPersonalUserInfo = response.data;
      }

    },

    /**
     * 在宅患者治療パターンを取得する
     */
    async getPatHhdPattern() {
      const paramJson = {};
      paramJson.facility_cd = this.getFacilityCd;
      this.mstPatHhdPatternInfo = null;
      const response = await ApiHelper.get(
        "/pat_home_dialysis/getPatHhdPattern",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HomeDialysisInstrConfirmModal.vue', 'getPatHhdPattern', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      if (200 !== response.status) {
        return null;
      }
      this.mstPatHhdPatternInfo = response.data;
    },

    // ------------------------------------------------------------------
    // 指示者コード取得
    // ------------------------------------------------------------------

    getInstractorCd(ind_user_id) {
      if (ind_user_id && false === this.findInstractor) {
        this.instractorCd = ind_user_id;
        this.findInstractor = true;
      }
    },

    // ------------------------------------------------------------------
    // モーダル操作メソッド
    // ------------------------------------------------------------------

    // 閉じるボタン
    closeModal() {
      // モーダルを非表示に
      this.hideModal();
    }
  },
  async created() {
    // 並行処理用
    const funcGetMstDialyzer = this.getMstDialyzer();
    const funcGetMstEquipment = this.getMstEquipment();
    const funcGetMstMedicine = this.getMstMedicine();
    const funcGetPersonalUser = this.getPersonalUser();
    const funcGetPatHhdPattern = this.getPatHhdPattern();

    // 今日の日付(YYYYMMDD)
    const today = moment().format("YYYYMMDD");

    // DBから治療情報などを取得
    const patId = this.selectedPatId;
    if (null === patId || "" === patId) {
      this.indCondInfo = "";
    } else {
      // DBからデータを並行で取得する
      Promise.all([
        funcGetMstDialyzer,
        funcGetMstEquipment,
        funcGetMstMedicine,
        funcGetPersonalUser,
        funcGetPatHhdPattern
      ])
      .then(() => {
        if (null !== this.mstPatHhdPatternInfo) {
          const mstPatHhdPattern = this.mstPatHhdPatternInfo.filter(
            obj => obj.patId === patId && obj.indTreatStartDate <= today
          );
          let sortedPatHhdPattern = mstPatHhdPattern.slice();
          sortedPatHhdPattern.sort((a, b) => {
            if (a.revision < b.revision) {
              return 1;
            } else {
              return -1;
            }
          });
          if (0 < sortedPatHhdPattern.length) {
            this.indCondInfo = JSON.parse(sortedPatHhdPattern[0].indCondInfo);
            this.indMediInfo = JSON.parse(sortedPatHhdPattern[0].indMediInfo);
            this.signatureDate = moment(sortedPatHhdPattern[0].upDate, "YYYY-MM-DDTHH:mm:ss.SSSZ");
          } else {
            this.indCondInfo = "";
            this.indMediInfo = "";
            this.signatureDate = "";
          }
        }

        // 透析時間: No1
        if (this.indCondInfo[IND_COND_ID.DIALYSIS_TIME]) {
          this.dialysTime = Math.floor(this.indCondInfo[IND_COND_ID.DIALYSIS_TIME].value / 60);
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.DIALYSIS_TIME].ind_user_id);
        } else {
          this.dialysTime = "";
        }

        // ダイアライザー: No5
        if (this.indCondInfo[IND_COND_ID.DIALYZER]) {
          const dialyzerCd = this.indCondInfo[IND_COND_ID.DIALYZER].value;
          if (null === dialyzerCd || "" === dialyzerCd) {
            this.dialyzer = "";
          } else {
            if (null !== this.mstDialyzerInfo) {
              const mstDialyzer = this.mstDialyzerInfo.filter(
                obj => obj.dialyzerCd === dialyzerCd
              );
              if (0 < mstDialyzer.length) {
                this.dialyzer = mstDialyzer[0].modelNumber;
              } else {
                this.dialyzer = "";
              }
            }
          }
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.DIALYZER].ind_user_id);
        } else {
          this.dialyzer = "";
        }

        // 血液回路: No13
        if (this.indCondInfo[IND_COND_ID.BLOODCIRCUIT]) {
          const equipmentCd = this.indCondInfo[IND_COND_ID.BLOODCIRCUIT].value;
          if (null === equipmentCd || "" === equipmentCd) {
            this.bloodCircuit = "";
          } else {
            if (null !== this.mstEquipmentInfo) {
              const mstEquipment = this.mstEquipmentInfo.filter(
                obj => obj.equipmentCd === equipmentCd
              );
              if (0 < mstEquipment.length) {
                this.bloodCircuit = mstEquipment[0].equipmentName;
              } else {
                this.bloodCircuit = "";
              }
            }
          }
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.BLOODCIRCUIT].ind_user_id);
        } else {
          this.bloodCircuit = "";
        }

        // 針の種類: No9～12
        // [条件判断]シングルニードル使用: No12 {1:使用する 0:使用しない}
        // 項目が存在しない場合、 0:使用しない をセットする
        let useSingleNeedle = 0;
        if (this.indCondInfo[IND_COND_ID.SINGLENEEDLE]) {
          useSingleNeedle = this.indCondInfo[IND_COND_ID.SINGLENEEDLE].value;
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.SINGLENEEDLE].ind_user_id);
        } else {
          useSingleNeedle = 0;
        }

        // シングルニードル未使用
        if (0 === useSingleNeedle) {
          // 穿刺針(A): No9
          let needleA = "";
          if (this.indCondInfo[IND_COND_ID.NEEDLE_A]) {
            const needleACd = this.indCondInfo[IND_COND_ID.NEEDLE_A].value;
            if (null !== this.mstEquipmentInfo) {
              if (null === needleACd || "" === needleACd) {
                needleA = "";
              } else {
                const mstEquipmentNeedleA = this.mstEquipmentInfo.filter(
                  obj => obj.equipmentCd === needleACd
                );
                if (0 < mstEquipmentNeedleA.length) {
                  needleA = mstEquipmentNeedleA[0].equipmentName;
                  this.needle = "(A)" + needleA;
                } else {
                  needleA = "";
                }
              }
            }
            this.getInstractorCd(this.indCondInfo[IND_COND_ID.NEEDLE_A].ind_user_id);
          }

          // 穿刺針(V): No10
          let needleV = "";
          if (this.indCondInfo[IND_COND_ID.NEEDLE_V]) {
            const needleVCd = this.indCondInfo[IND_COND_ID.NEEDLE_V].value;
            if (null !== this.mstEquipmentInfo) {
              if (null === needleVCd || "" === needleVCd) {
                needleV = "";
              } else {
                const mstEquipmentNeedleV = this.mstEquipmentInfo.filter(
                  obj => obj.equipmentCd == needleVCd // mod #9973 value Number→文字列  shiyw
                );
                if (0 < mstEquipmentNeedleV.length) {
                  needleV = mstEquipmentNeedleV[0].equipmentName;
                  this.needle = this.needle + " (V)" + needleV;
                } else {
                  needleV = "";
                }
              }
            }
            this.getInstractorCd(this.indCondInfo[IND_COND_ID.NEEDLE_V].ind_user_id);
          }
        }

        // シングルニードル使用
        // 穿刺針(SN): No11
        if (this.indCondInfo[IND_COND_ID.NEEDLE_SN] && 1 === useSingleNeedle) {
          const equipmentCd = this.indCondInfo[IND_COND_ID.NEEDLE_SN].value;
          if (null === equipmentCd || "" === equipmentCd) {
            this.needle = "";
          } else {
            if (null !== this.mstEquipmentInfo) {
              const mstEquipment = this.mstEquipmentInfo.filter(
                obj => obj.equipmentCd == equipmentCd // mod #9973 value Number→文字列  shiyw
              );
              if (0 < mstEquipment.length) {
                this.needle = "(SN)" + mstEquipment[0].equipmentName;
              } else {
                this.needle = "";
              }
            }
          }
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.NEEDLE_SN].ind_user_id);
        }

        // 血流量: No14
        if (this.indCondInfo[IND_COND_ID.BLOODFLOW]) {
          this.bloodFlow = this.indCondInfo[IND_COND_ID.BLOODFLOW].value;
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.BLOODFLOW].ind_user_id);
        } else {
          this.bloodFlow = "";
        }

        // 透析液流量: No16
        if (this.indCondInfo[IND_COND_ID.DIALYSISFLUID_FLOW]) {
          this.dialysateFlow = this.indCondInfo[IND_COND_ID.DIALYSISFLUID_FLOW].value;
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.DIALYSISFLUID_FLOW].ind_user_id);
        } else {
          this.dialysateFlow = "";
        }

        // 抗凝固薬の種類: No25
        if (this.indCondInfo[IND_COND_ID.ANTICOAGULANT]) {
          const medicineCd = this.indCondInfo[IND_COND_ID.ANTICOAGULANT].value;
          if (null === medicineCd || "" === medicineCd) {
            this.anticoagulantType = "";
          } else {
            if (null !== this.mstMedicineInfo) {
              const mstMedicine = this.mstMedicineInfo.filter(
                obj => obj.medicineCd == medicineCd // mod #9973 value Number→文字列  shiyw
              );
              if (0 < mstMedicine.length) {
                this.anticoagulantType = mstMedicine[0].medicineName;
              } else {
                this.anticoagulantType = "";
              }
            }
          }
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.ANTICOAGULANT].ind_user_id);
        } else {
          this.anticoagulantType = "";
        }

        // 抗凝固薬（初回）: No26
        if (this.indCondInfo[IND_COND_ID.ANTICOAGULANT_ONESHOT]) {
          this.anticoagulantFirst = (1 * this.indCondInfo[IND_COND_ID.ANTICOAGULANT_ONESHOT].value).toFixed(2);
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.ANTICOAGULANT_ONESHOT].ind_user_id);
        } else {
          this.anticoagulantFirst = "";
        }

        // 抗凝固薬（持続）: No28
        if (this.indCondInfo[IND_COND_ID.ANTICOAGULANT_AMOUNT]) {
          this.anticoagulantContinue = this.indCondInfo[IND_COND_ID.ANTICOAGULANT_AMOUNT].value;
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.ANTICOAGULANT_AMOUNT].ind_user_id);
        } else {
          this.anticoagulantContinue = "";
        }

        // 透析液の種類: No15
        if (this.indCondInfo[IND_COND_ID.DIALYSISFLUID]) {
          const medicineCd = this.indCondInfo[IND_COND_ID.DIALYSISFLUID].value;
          if (null === medicineCd || "" === medicineCd) {
            this.dialysateType = "";
          } else {
            if (null !== this.mstMedicineInfo) {
              const mstMedicine = this.mstMedicineInfo.filter(
                obj => obj.medicineCd == medicineCd // mod #9973 value Number→文字列  shiyw
              );
              if (0 < mstMedicine.length) {
                this.dialysateType = mstMedicine[0].medicineName;
              } else {
                this.dialysateType = "";
              }
            }
          }
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.DIALYSISFLUID].ind_user_id);
        } else {
          this.dialysateType = "";
        }

        // 透析液の量: No17
        if (this.indCondInfo[IND_COND_ID.DIALYSISFLUID_AMOUNT]) {
          this.dialysateAmount = (1 * this.indCondInfo[IND_COND_ID.DIALYSISFLUID_AMOUNT].value).toFixed(2);
          this.getInstractorCd(this.indCondInfo[IND_COND_ID.DIALYSISFLUID_AMOUNT].ind_user_id);
        } else {
          this.dialysateAmount = "";
        }

        // 指示者署名
        if (true === this.findInstractor) {
          if (null !== this.mstPersonalUserInfo) {
            const mstPersonalUser = this.mstPersonalUserInfo.filter(
              obj => obj.userId === this.instractorCd
            );
            if (0 < mstPersonalUser.length && "" != this.signatureDate) {
              this.instractorSignature =
                this.signatureDate.format('YYYY年MM月DD日 ') +
                mstPersonalUser[0].userLastName +
                mstPersonalUser[0].userFirstName;
            } else {
              this.instractorSignature = "";
            }
          }
        } else {
          this.instractorSignature = "";
        }

        // 投与薬剤
        // 生理食塩液・ESA製剤を含むと思われる
        if ("" === this.indMediInfo || null === this.indMediInfo) {
          this.medication = [];
        } else {
          for (let idx = 0; idx < this.indMediInfo.length; idx++) {
            const mediInfo = this.indMediInfo[String(idx)];
            const medicineCd = mediInfo.cd;
            const mediInfoAmount = mediInfo.amount;
            let mediInfoType = "";
            if (null !== this.mstMedicineInfo) {
              const mstMedicine = this.mstMedicineInfo.filter(
                obj => obj.medicineCd == medicineCd // mod #9973 value Number→文字列  shiyw
              );
              if (0 < mstMedicine.length) {
                mediInfoType = mstMedicine[0].medicineName;
              } else {
                mediInfoType = "";
              }
            }
            this.medication.push({
              type: mediInfoType,
              amount: mediInfoAmount
            });
          }
        }

      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HomeDialysisInstrConfirmModal.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
    }
  }
};
</script>

<style scoped>
.row-content > ons-col {
  padding: 5px;
}

.textbox-size-s {
  width: 120px;
}
.textbox-size-m {
  width: 250px;
}
.textbox-size-l {
  width: 380px;
}
.line-text-s {
  margin-top: 5px;
  flex: 0 0 300px;
  max-width: 300px;
}
.line-text {
  margin-top: 5px;
  flex: 0 0 300px;
  max-width: 300px;
}
.empty-text {
  margin-top: 5px;
  flex: 0 0 300px;
  max-width: 300px;
}
.instractor-signature {
  margin-top: 5px;
  flex: 0 0 300px;
  max-width: 300px;
  border-bottom: 1.5px solid var(--ntss-border-color);
}

/** iPhone X/8/7/6 or Android(M,L) */
/** Device Width:360-480           */
@media only screen and (min-device-width:360px) and (max-device-width:480px) {
  .textbox-size-l {
    width: 280px;
  }
  .instractor-signature {
    flex: 0 0 280px;
  }
}

/** iPad(not Pro) or AndroidTablet */
/** Device Width:600-800           */
@media only screen and (min-device-width:600px) and (max-device-width:800px) {
  .line-text-s {
    margin-top: 5px;
    flex: 0 0 220px;
  }
  .line-text {
    margin-top: 5px;
    flex: 0 0 360px;
    max-width: 360px;
  }
  .empty-text {
    margin-top: 5px;
    flex: 0 0 0px;
  }
}

.textbox-gray {
  background-color: #BBBBBB;
  opacity: 1 !important;
}
.modal-content {
  font-size: 2.0em;
  padding: 1em;
}
.flex-container-footer {
  justify-content: flex-end;
}
</style>
