/**
 * 風袋/除水補正モーダルPage
 */
 <template>
  <modal-base @onClose="closeTareWaterEditModal">
    <template #header>
      <div>
      <component :is="header"></component>
    </div>
    </template>
    <template #body>
      <div style="height: calc(100% - 1em); overflow: auto;">
      <div>
        <v-ons-row>
          <v-ons-segment
            ref="segment"
            class="send-condition-tare-water-edit-modal-mode-segment"
            v-model:index="nowMode"
          >
            <!-- gボタン -->
            <button @click="changeUnit(0)">g</button>
            <!-- kgボタン -->
            <button @click="changeUnit(1)">kg</button>
          </v-ons-segment>
        </v-ons-row>
        <v-ons-row>
          <!-- 名称1 -->
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start-->
<!--          <v-ons-col :width="nameAreaWidth">-->
<!--            <custom-simple-textarea-b-->
<!--              class="send-condition-tare-water-edit-modal-input-area-name"-->
<!--              v-model="editData.name_1"-->
<!--              @input="inputName()"-->
<!--              @keydown="inputFieldResize('nname_1')"-->
<!--              ref="nname_1"-->
<!--              style="font-size: 2em; margin-bottom: -2px;"-->
<!--            />-->
          <v-ons-col :width="nameAreaWidth">
            <custom-simple-textarea-b
              class="send-condition-tare-water-edit-modal-input-area-name"
              v-model="editData.name_1"
              @keydown="inputFieldResize('nname_1')"
              ref="nname_1"
              style="font-size: 2em; margin-bottom: -2px;"
            />
<!--            mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end-->
          </v-ons-col>
          <!-- 重さ1 -->
          <v-ons-col :width="valueAreaWidth">
            <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
            <!-- <v-ons-input
              class="send-condition-tare-water-edit-modal-input-area-value"
              type="number"
              v-bind:step="editStep"
              @input="checkWeight(editData.weight_1, $event)"
              v-model.number="editData.weight_1"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}</label> -->
            <v-ons-input
              id="tareWaterID_1"
              class="send-condition-tare-water-edit-modal-input-area-value"
              :class="inputClass"
              type="number"
              v-bind:step="editStep"
              @focus="setOldVal1(editWeight1)"
              @blur="checkWeight(1, editWeightOld1, $event)"
              @keydown.enter="moveFocus($event)"
              @keydown="onKeyDown"
              @input="checkLoop"
              readonly="readonly"
              v-model.number="editWeight1"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}<img height="25px" style="vertical-align: bottom" :src="image_src" @click="show(1)"/></label>
            <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <div>
          <v-ons-popover cancelable id="tareWaterIDPopOver_1" v-model:visible="cavisible_1" :target="popoverTarget" direction="down" class="popoverClass" @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change" style="float:right"  />
          </v-ons-popover>
        </div>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
        <v-ons-row>
          <!-- 名称2 -->
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start-->
<!--          <v-ons-col :width="nameAreaWidth">-->
<!--            <custom-simple-textarea-b-->
<!--              class="send-condition-tare-water-edit-modal-input-area-name"-->
<!--              v-model="editData.name_2"-->
<!--              @input="inputName()"-->
<!--              @keydown="inputFieldResize('nname_2')"-->
<!--              ref="nname_2"-->
<!--              style="font-size: 2em; margin-bottom: -2px;"-->
<!--            />-->
          <v-ons-col :width="nameAreaWidth">
            <custom-simple-textarea-b
              class="send-condition-tare-water-edit-modal-input-area-name"
              v-model="editData.name_2"
              @keydown="inputFieldResize('nname_2')"
              ref="nname_2"
              style="font-size: 2em; margin-bottom: -2px;"
            />
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end-->
          </v-ons-col>
          <!-- 重さ2 -->
          <v-ons-col :width="valueAreaWidth">
            <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
            <!-- <v-ons-input
              class="send-condition-tare-water-edit-modal-input-area-value"
              type="number"
              v-bind:step="editStep"
              @input="checkWeight(editData.weight_2, $event)"
              v-model.number="editData.weight_2"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}</label> -->
            <v-ons-input
              id="tareWaterID_2"
              class="send-condition-tare-water-edit-modal-input-area-value"
              :class="inputClass"
              type="number"
              v-bind:step="editStep"
              @focus="setOldVal2(editWeight2)"
              @blur="checkWeight(2, editWeightOld2, $event)"
              @keydown.enter="moveFocus($event)"
              @keydown="onKeyDown"
              @input="checkLoop"
              readonly="readonly"
              v-model.number="editWeight2"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}<img height="25px" style="vertical-align: bottom" :src="image_src" @click="show(2)"/></label>
            <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <div>
          <v-ons-popover cancelable id="tareWaterIDPopOver_2" v-model:visible="cavisible_2" :target="popoverTarget" direction="down" class="popoverClass" @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change" style="float:right"  />
          </v-ons-popover>
        </div>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
        <v-ons-row>
          <!-- 名称3 -->
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start-->
<!--          <v-ons-col :width="nameAreaWidth">-->
<!--            <custom-simple-textarea-b-->
<!--              class="send-condition-tare-water-edit-modal-input-area-name"-->
<!--              v-model="editData.name_3"-->
<!--              @input="inputName()"-->
<!--              @keydown="inputFieldResize('nname_3')"-->
<!--              ref="nname_3"-->
<!--              style="font-size: 2em; margin-bottom: -2px;"-->
<!--            />-->
          <v-ons-col :width="nameAreaWidth">
            <custom-simple-textarea-b
              class="send-condition-tare-water-edit-modal-input-area-name"
              v-model="editData.name_3"
              @keydown="inputFieldResize('nname_3')"
              ref="nname_3"
              style="font-size: 2em; margin-bottom: -2px;"
            />
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end-->
          </v-ons-col>
          <!-- 重さ3 -->
          <v-ons-col :width="valueAreaWidth">
            <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
            <!-- <v-ons-input
              class="send-condition-tare-water-edit-modal-input-area-value"
              type="number"
              v-bind:step="editStep"
              @input="checkWeight(editData.weight_3, $event)"
              v-model.number="editData.weight_3"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}</label> -->
            <v-ons-input
              id="tareWaterID_3"
              class="send-condition-tare-water-edit-modal-input-area-value"
              :class="inputClass"
              type="number"
              v-bind:step="editStep"
              @focus="setOldVal3(editWeight3)"
              @blur="checkWeight(3, editWeightOld3, $event)"
              @keydown.enter="moveFocus($event)"
              @keydown="onKeyDown"
              @input="checkLoop"
              readonly="readonly"
              v-model.number="editWeight3"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}<img height="25px" style="vertical-align: bottom" :src="image_src" @click="show(3)"/></label>
            <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <div>
          <v-ons-popover cancelable id="tareWaterIDPopOver_3" v-model:visible="cavisible_3" :target="popoverTarget" direction="down" class="popoverClass" @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change" style="float:right"  />
          </v-ons-popover>
        </div>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
        <v-ons-row>
          <!-- 名称4 -->
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start-->
<!--          <v-ons-col :width="nameAreaWidth">-->
<!--            <custom-simple-textarea-b-->
<!--              class="send-condition-tare-water-edit-modal-input-area-name"-->
<!--              v-model="editData.name_4"-->
<!--              @input="inputName()"-->
<!--              @keydown="inputFieldResize('nname_4')"-->
<!--              ref="nname_4"-->
<!--              style="font-size: 2em; margin-bottom: -2px;"-->
<!--            />-->
          <v-ons-col :width="nameAreaWidth">
            <custom-simple-textarea-b
              class="send-condition-tare-water-edit-modal-input-area-name"
              v-model="editData.name_4"
              @keydown="inputFieldResize('nname_4')"
              ref="nname_4"
              style="font-size: 2em; margin-bottom: -2px;"
            />
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end-->
          </v-ons-col>
          <!-- 重さ4 -->
          <v-ons-col :width="valueAreaWidth">
            <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
            <!-- <v-ons-input
              class="send-condition-tare-water-edit-modal-input-area-value"
              type="number"
              v-bind:step="editStep"
              @input="checkWeight(editData.weight_4, $event)"
              v-model.number="editData.weight_4"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}</label> -->
            <v-ons-input
              id="tareWaterID_4"
              class="send-condition-tare-water-edit-modal-input-area-value"
              :class="inputClass"
              type="number"
              v-bind:step="editStep"
              @focus="setOldVal4(editWeight4)"
              @blur="checkWeight(4, editWeightOld4, $event)"
              @keydown.enter="moveFocus($event)"
              @keydown="onKeyDown"
              @input="checkLoop"
              readonly="readonly"
              v-model.number="editWeight4"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}<img height="25px" style="vertical-align: bottom" :src="image_src" @click="show(4)"/></label>
            <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <div>
          <v-ons-popover cancelable id="tareWaterIDPopOver_4" v-model:visible="cavisible_4" :target="popoverTarget" direction="down" class="popoverClass" @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change" style="float:right"  />
          </v-ons-popover>
        </div>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
        <v-ons-row>
          <!-- 名称5 -->
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start-->
<!--          <v-ons-col :width="nameAreaWidth">-->
<!--            <custom-simple-textarea-b-->
<!--              class="send-condition-tare-water-edit-modal-input-area-name"-->
<!--              v-model="editData.name_5"-->
<!--              @input="inputName()"-->
<!--              @keydown="inputFieldResize('nname_5')"-->
<!--              ref="nname_5"-->
<!--              style="font-size: 2em; margin-bottom: -2px;"-->
<!--            />-->
          <v-ons-col :width="nameAreaWidth">
            <custom-simple-textarea-b
              class="send-condition-tare-water-edit-modal-input-area-name"
              v-model="editData.name_5"
              @keydown="inputFieldResize('nname_5')"
              ref="nname_5"
              style="font-size: 2em; margin-bottom: -2px;"
            />
<!--          mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end-->
          </v-ons-col>
          <!-- 重さ5 -->
          <v-ons-col :width="valueAreaWidth">
            <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
            <!-- <v-ons-input
              class="send-condition-tare-water-edit-modal-input-area-value"
              type="number"
              v-bind:step="editStep"
              @input="checkWeight(editData.weight_5, $event)"
              v-model.number="editData.weight_5"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}</label> -->
            <v-ons-input
              id="tareWaterID_5"
              class="send-condition-tare-water-edit-modal-input-area-value"
              :class="inputClass"
              type="number"
              v-bind:step="editStep"
              @focus="setOldVal5(editWeight5)"
              @blur="checkWeight(5, editWeightOld5, $event)"
              @keydown.enter="moveFocus($event)"
              @keydown="onKeyDown"
              @input="checkLoop"
              readonly="readonly"
              v-model.number="editWeight5"
            ></v-ons-input>
            <label class="send-condition-tare-water-edit-modal-unit">{{unit}}<img height="25px" style="vertical-align: bottom" :src="image_src" @click="show(5)"/></label>
            <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <!-- add FNSI-体重計モードテンキーの追加 徐 start -->
        <div>
          <v-ons-popover cancelable id="tareWaterIDPopOver_5" v-model:visible="cavisible_5" :target="popoverTarget" direction="down" class="popoverClass" @posthide="tenkeyClose">
            <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input" :change="change" style="float:right"  />
          </v-ons-popover>
        </div>
        <!-- add FNSI-体重計モードテンキーの追加 徐 end -->
      </div>
    </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
        <!-- <v-ons-button class="button denial-btn" @click="closeTareWaterEditModal">キャンセル</v-ons-button> -->
        <v-ons-button
          class="btn2-cancel denial-btn"
          style="width: 7em; font-size: 1.5em; height: 2em;"
          @click="closeTareWaterEditModal"
        >キャンセル</v-ons-button>
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
        <!-- <v-ons-button
          class="button registration-btn"
          @click="saveTareWaterEditModalStore"
          :disabled="!enableOkButton"
        >{{okBtnName}}</v-ons-button> -->
        <v-ons-button
          class="btn1-execute registration-btn"
          style="width: 5em; font-size: 1.5em; height: 2em;"
          @click="saveTareWaterEditModalStore"
          :disabled="!enableOkButton"
        >{{okBtnName}}</v-ons-button>
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll, getScopedUserAgent } from "@/functions/common/LayoutMeasureHelper";
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
import BigNumber from "@/compat/number/bignumber";
import { weightScaleClass, dialysisState } from "@/constants/weightDefine";
// add FNSI-体重計モードテンキーの追加 徐 start
// add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import TouchKeyboard from "@/compat/keyboard/TouchKeyboard.vue";
import { publicAssetPath } from "@/compat/assets/public-path";
// add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
// add FNSI-体重計モードテンキーの追加 徐 end

const dataMode = { tare: 1, offWater: 0 },
  unitMode = { g: 0, kg: 1 };
export default {
  name: "TareWaterEditModal",
  components: {
    "modal-base": ModalBase,
    "custom-input-number": customInputNumber,
    // add FNSI-体重計モードテンキーの追加 徐 start
    "vue-touch-keyboard": TouchKeyboard,
    // add FNSI-体重計モードテンキーの追加 徐 end
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB
  },
  data() {
    return {
      main: "",
      header: "",
      editList: [],
      nowMode: unitMode.g,
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      // isChanged: false,
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      // add FNSI-体重計モードテンキーの追加 徐 start
      cavisible_1: false,
      cavisible_2: false,
      cavisible_3: false,
      cavisible_4: false,
      cavisible_5: false,
      editWeightOld1: "",
      editWeightOld2: "",
      editWeightOld3: "",
      editWeightOld4: "",
      editWeightOld5: "",
      clearFlg: 0,
      layout: null,
      input: null,
      options: {
        useKbEvents: false,
        preventClickEvent: false
      },
      image_src: publicAssetPath("img/keyboard/keyboard.png"),
      popoverTarget: null,
      // add FNSI-体重計モードテンキーの追加 徐 end
      doClearTwice: false,
      isPostHide: false,
      isAndroid: false,
      isIOS: false,
      nameAreaWidth: "50%",
      valueAreaWidth: "50%",
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      editData: {},
      // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      initData: {},
      blurflg: true,
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
    };
  },
  computed: {
    ...mapGetters("send-condition/scale", [
      "getEditModalData",
      "getEditModalDataMode",
      "getScaleClass",
      "getIsCurrentDialysisStateEqualDialysisState"
    ]),
    ...mapGetters("send-condition/scale/setting", ["getWeightScaleConfigInfo"]),
    // add FNSI-体重計モードテンキーの追加 徐 start
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    // add FNSI-体重計モードテンキーの追加 徐 end
    ...mapGetters("window-size", ["getWindowWidth"]),
    // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
    // editData: {
    //   get() {
    //     return JSON.parse(JSON.stringify(this.getEditModalData));
    //   }
    // },
    // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
    editWeight1: {
      cache: false,
      get() {
        let retval = this.adjustDigits(this.editData.weight_1);
        if (this.doClearTwice) {
          // クリア処理の2回目を時間差で行う
          setTimeout(() => {
            this.clearValue();
            this.moveCursor();
          }, 10);
          this.doClearTwice = false;
        }
        return retval;
      },
      set(val) {
        if(this.cavisible_1 && !this.isPostHide) {
          return;
        }
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
        // this.editData.weight_1 = val;
        this.editData.weight_1 = Number(val);
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      }
    },
    editWeight2: {
      cache: false,
      get() {
        let retval = this.adjustDigits(this.editData.weight_2);
        if (this.doClearTwice) {
          // クリア処理の2回目を時間差で行う
          setTimeout(() => {
            this.clearValue();
            this.moveCursor();
          }, 10);
          this.doClearTwice = false;
        }
        return retval;
      },
      set(val) {
        if(this.cavisible_2 && !this.isPostHide) {
          return;
        }
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
        // this.editData.weight_2 = val;
        this.editData.weight_2 = Number(val);
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      }
    },
    editWeight3: {
      cache: false,
      get() {
        let retval = this.adjustDigits(this.editData.weight_3);
        if (this.doClearTwice) {
          // クリア処理の2回目を時間差で行う
          setTimeout(() => {
            this.clearValue();
            this.moveCursor();
          }, 10);
          this.doClearTwice = false;
        }
        return retval;
      },
      set(val) {
        if(this.cavisible_3 && !this.isPostHide) {
          return;
        }
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
        // this.editData.weight_3 = val;
        this.editData.weight_3 = Number(val);
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      }
    },
    editWeight4: {
      cache: false,
      get() {
        let retval = this.adjustDigits(this.editData.weight_4);
        if (this.doClearTwice) {
          // クリア処理の2回目を時間差で行う
          setTimeout(() => {
            this.clearValue();
            this.moveCursor();
          }, 10);
          this.doClearTwice = false;
        }
        return retval;
      },
      set(val) {
        if(this.cavisible_4 && !this.isPostHide) {
          return;
        }
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
        // this.editData.weight_4 = val;
        this.editData.weight_4 = Number(val);
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      }
    },
    editWeight5: {
      cache: false,
      get() {
        let retval = this.adjustDigits(this.editData.weight_5);
        if (this.doClearTwice) {
          // クリア処理の2回目を時間差で行う
          setTimeout(() => {
            this.clearValue();
            this.moveCursor();
          }, 10);
          this.doClearTwice = false;
        }
        return retval;
      },
      set(val) {
        if(this.cavisible_5 && !this.isPostHide) {
          return;
        }
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
        // this.editData.weight_5 = val;
        this.editData.weight_5 = Number(val);
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      }
    },
    editStep: {
      get() {
        if (this.nowMode === unitMode.g) {
          return 1;
        } else {
          // return 0.001;
          // add FNSI-書式設定 徐 end
          return 0.01;
          // add FNSI-書式設定 徐 end
        }
      }
    },
    unit: {
      get() {
        return this.nowMode === unitMode.g ? "g" : "kg";
      }
    },
    okBtnName: {
      get() {
        // Redmine 指摘 #3645 指示変更時は「スケジュールに登録」としていたが、一般利用者にはわかりづらいので「確定」でいい
        if (this.getScaleClass === weightScaleClass.before) {
          return "保存";
        }
        return "確定";
      }
    },
    enableOkButton: {
      get() {
        if (
          this.getIsCurrentDialysisStateEqualDialysisState(dialysisState.checkedSendCondition) ||
          this.getIsCurrentDialysisStateEqualDialysisState(dialysisState.dialysis) ||
          this.getIsCurrentDialysisStateEqualDialysisState(dialysisState.afterPastRecord)
        ) {
          // 条件確認済み、治療中、実績確定済みの場合は変更不可
          return false;
        }
        if (!this.isChanged) {
          return false;
        }
        return true;
      }
    },
    inputMax: {
      get() {
        if (this.getEditModalDataMode === dataMode.tare) {
          // 風袋
          return 300000;
        } else {
          // 除水補正
          return 30000;
        }
      }
    },
    inputMin: {
      get() {
        if (this.getEditModalDataMode === dataMode.tare) {
          // 風袋
          return -300000;
        } else {
          // 除水補正
          return -30000;
        }
      }
    },
    inputClass: {
      get() {
        let className = this.nowMode === unitMode.g ? "unitmode-g" : "unitmode-kg";
        if (this.isIOS || this.isAndroid) {
          className = className + ' input-mobile';
        }
        return className;
      }
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
    isChanged(){
      // #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      // return JSON.stringify(this.getEditModalData) !== JSON.stringify(this.editData)
      return JSON.stringify(this.initData) !== JSON.stringify(this.editData)
      // #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
    }
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
  },
  created() {
    if (this.getEditModalDataMode === dataMode.tare) {
      // 風袋
      this.changeUnit(this.getWeightScaleConfigInfo.tareUnitClass);
    } else {
      // 除水補正
      this.changeUnit(this.getWeightScaleConfigInfo.waterUnitClass);
    }
    // 端末判別
    const ua = getScopedUserAgent(this.$el || null);
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    if (this.getWindowWidth <= 480) {
      this.nameAreaWidth = "43%";
      this.valueAreaWidth = "57%";
    }
  },
  mounted() {
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
    this.editData = JSON.parse(JSON.stringify(this.getEditModalData))
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
    // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
    this.initData = JSON.parse(JSON.stringify(this.editData));
    if (this.nowMode == unitMode.kg) {
      this.changeUnitData(unitMode.kg);
      if (this.initData) {
        const arr = ["weight_1", "weight_2", "weight_3", "weight_4", "weight_5"];
        for(let key of arr) {
          this.initData[key] = this.initData[key] == null ? null : new BigNumber(this.initData[key]).div(1000).toNumber();
        }
      }
    }
    // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
    setTimeout(() => {
      this.addWheelEvent();
    }, 1000);
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  methods: {
    getScopedElementById(id) {
      return getScopedElementById(id, this);
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this);
    },
    getScopedQuery(selector) {
      return queryScopedSelector(selector, this);
    },
    getScopedQueryAll(selector) {
      return queryScopedSelectorAll(selector, this);
    },

    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("send-condition/scale", ["setRegistEditModalData"]),
    // 単位変更ボタン
    changeUnit(mode) {
      // モードが変わった場合のみ
      if (this.nowMode !== mode) {
        // 表示変換
        this.changeUnitData(mode);

        this.nowMode = mode;
      }
    },
    // 表示変換
    changeUnitData(mode) {
      const keys = ["weight_1", "weight_2", "weight_3", "weight_4", "weight_5"];
      
      for (const key of keys) {
        const val = this.editData[key];
        if (val === null) {
          this.editData[key] = null;
          continue;
        }
      
        // g表示（kg から g へ：1000倍）
        if (mode === unitMode.g) {
          this.editData[key] = new BigNumber(val).times(1000).toNumber();
        } 
        // kg表示（g から kg へ：procDecimal で除算＋丸め）
        else {
          this.editData[key] = this.procDecimal(val);
        }
      }
      
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      if (mode !== unitMode.g) {
        this.blurflg = true;
      }
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
    },
    /**
     * 小数点操作 ※患者経過総合ビューア、装置設定デフォルトマスタ、治療記録＞装置設定、装置設定 と同じ処理
     * @description 風袋->小数点第三位切り捨て、除水補正->小数点第3位切り上げ
     * @param value 小数点操作を行う値
     */
    procDecimal(value) {
      // 風袋
      if (this.getEditModalDataMode === dataMode.tare) {
        return new BigNumber(value).div(1000).dp(2, BigNumber.ROUND_DOWN).toNumber()
      } else {
        return new BigNumber(value).div(1000).dp(2, BigNumber.ROUND_UP).toNumber()
      }
    },
    validWeight() {
      this.editData.weight_1 =
        this.editData.weight_1 === null ||
        isNaN(this.editData.weight_1) ||
        this.editData.weight_1 === ""
          ? null
          : this.editData.weight_1;
      this.editData.weight_2 =
        this.editData.weight_2 === null ||
        isNaN(this.editData.weight_2) ||
        this.editData.weight_2 === ""
          ? null
          : this.editData.weight_2;
      this.editData.weight_3 =
        this.editData.weight_3 === null ||
        isNaN(this.editData.weight_3) ||
        this.editData.weight_3 === ""
          ? null
          : this.editData.weight_3;
      this.editData.weight_4 =
        this.editData.weight_4 === null ||
        isNaN(this.editData.weight_4) ||
        this.editData.weight_4 === ""
          ? null
          : this.editData.weight_4;
      this.editData.weight_5 =
        this.editData.weight_5 === null ||
        isNaN(this.editData.weight_5) ||
        this.editData.weight_5 === ""
          ? null
          : this.editData.weight_5;
    },
    /**
     * 各入力欄の変更前の値をセットする処理
     */
    setOldVal1(value) {
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      this.blurflg = false;
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
      this.editWeightOld1 = value;
    },
    setOldVal2(value) {
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      this.blurflg = false;
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
      this.editWeightOld2 = value;
    },
    setOldVal3(value) {
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      this.blurflg = false;
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
      this.editWeightOld3 = value;
    },
    setOldVal4(value) {
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      this.blurflg = false;
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
      this.editWeightOld4 = value;
    },
    setOldVal5(value) {
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
      this.blurflg = false;
      // add #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
      this.editWeightOld5 = value;
    },
    // weight_1の入力制限
    checkWeight(weightNo, oldVal, event) {
      // 入力範囲の設定
      if ((this.cavisible_1 || this.cavisible_2 || this.cavisible_3 || this.cavisible_4 || this.cavisible_5) && !this.isPostHide) {
        return;
      }
      // 空文字の場合
      // add FNSI-空文字の場合の修正 徐 start
      // if (event.target.value === "") {
      //   return;
      // }
      if (event.target.value === "" || event.target.value === null) {
         event.target.value = 0;
      }
      // add FNSI-空文字の場合の修正 徐 end
      // gモードの場合
      if (this.nowMode === unitMode.g) {
        // add FNSI-体重計モードテンキーの追加 徐 start
        // let pattern = "^(0|[1-9][0-9]{0,5})?$";
        let pattern = "^(0|-?[0-9][0-9]{0,5})?$";
        // add FNSI-体重計モードテンキーの追加 徐 end
        const re = new RegExp(pattern);
        const result = re.exec(event.target.value);
        // 入力上限超過 → 元の値に戻す
        if (result && Number(event.target.value) > this.inputMax) {
          result.input = oldVal;
        }
        // 入力下限未満 → 元の値に戻す
        if (result && Number(event.target.value) < this.inputMin) {
          result.input = oldVal;
        }
        if (result) {
          // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
          // if (result.input !== oldVal) {
          //   this.isChanged = true;
          // }
          // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
          // add FNSI-体重計モードテンキーの追加 徐 start
          // event.target.value = result.input;
          event.target.value = Number(result.input);
          // add FNSI-体重計モードテンキーの追加 徐 end
        } else {
          event.target.value = oldVal;
        }
      }
      // kgモードの場合
      else if (this.nowMode === unitMode.kg) {
        // add FNSI-体重計モードテンキーの追加 徐 start
        // let pattern = "^([1-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
        // mod FNSI-改修内容5621修正 chen　start
        // let pattern = "^([0-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
       // add FNSI-体重計モードテンキーの追加 徐 end
        // const re = new RegExp(pattern);
        // const result = re.exec(event.target.value);
        //  if (result) {
        //   if (result.input !== oldVal) {
        //     this.isChanged = true;
        //   }
        let patternkg = "^(-?[0-9][0-9]{0,2}|0)(.[0-9]{1,3})?$";
        const rekg = new RegExp(patternkg);
        let value = event.target.value;
        if (value.substring(value.length-1) === ".") {
          value = value + "0";
        }
        if (value.substring(0,1) === ".") {
          value = "0" + value ;
        }
        event.target.value = value;
        const resultkg = rekg.exec(event.target.value);
        // 入力上限超過 → 元の値に戻す
        if (resultkg && Number(event.target.value) > (this.inputMax / 1000)) {
          resultkg.input = oldVal;
        }
        // 入力下限未満 → 元の値に戻す
        if (resultkg && Number(event.target.value) < (this.inputMin / 1000)) {
          resultkg.input = oldVal;
        }
        if (resultkg) {
          // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
          // if (resultkg.input !== oldVal) {
          //   this.isChanged = true;
          // }
          // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
          // add FNSI-体重計モードテンキーの追加 徐 start
          // event.target.value = result.input;
          // event.target.value = Number(result.input);
          event.target.value = Number(resultkg.input).toFixed(2);
          // mod FNSI-改修内容5621修正 chen　end
          // add FNSI-体重計モードテンキーの追加 徐 end
        } else {
          // add FNSI-体重計モードテンキーの追加 徐 start
          // event.target.value = oldVal;
          // 体重計モード
          if (this.getWeightMode.isWeightMode) {
            if (event.target.value === null || event.target.value === "") {
              event.target.value = "";
            } else {
              let valueSplit = String(event.target.value).split(".");
              if (valueSplit.length === 2) {
                if (valueSplit[0].length > 3) {
                  event.target.value = oldVal;
                } else if (valueSplit[1].length > 3) {
                  event.target.value = oldVal;
                } else if (valueSplit[0].length === 0 && valueSplit[1].length === 0) {
                  event.target.value = null;
                }
              }
            }
          } else {
            // 通常モード
            event.target.value = oldVal;
          }
          // add FNSI-体重計モードテンキーの追加 徐 end
        }
        event.target.value = Number(event.target.value).toFixed(2);
      }
      // 変更値をセット
      if (weightNo === 1) {
        this.editWeight1 = event.target.value;
      } else if (weightNo === 2) {
        this.editWeight2 = event.target.value;
      } else if (weightNo === 3) {
        this.editWeight3 = event.target.value;
      } else if (weightNo === 4) {
        this.editWeight4 = event.target.value;
      } else if (weightNo === 5) {
        this.editWeight5 = event.target.value;
      }
    },
    // 変更ありフラグ
    // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
    // inputName() {
    //   this.isChanged = true;
    // },
    // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
    // 入力欄のリサイズ発火処理
    inputFieldResize(name) {
      this.$refs[name].resizeFlg = !this.$refs[name].resizeFlg;
    },
    // 確定ボタン
    saveTareWaterEditModalStore() {
      // add FNSI-体重計モードテンキーの追加 徐 start
      if (this.editData.weight_1 === null || this.editData.weight_1 === "") {
        this.editData.weight_1 = 0;
      }
      if (this.editData.weight_2 === null || this.editData.weight_2 === "") {
        this.editData.weight_2 = 0;
      }
      if (this.editData.weight_3 === null || this.editData.weight_3 === "") {
        this.editData.weight_3 = 0;
      }
      if (this.editData.weight_4 === null || this.editData.weight_4 === "") {
        this.editData.weight_4 = 0;
      }
      if (this.editData.weight_5 === null || this.editData.weight_5 === "") {
        this.editData.weight_5 = 0;
      }
      // add FNSI-体重計モードテンキーの追加 徐 end
      // kgモードの場合のみ
      if (this.nowMode === unitMode.kg) {
        // 編集内容をg表示に変換
        this.changeUnitData(unitMode.g);
      }

      // 編集内容セット
      this.validWeight();
      this.setRegistEditModalData(this.editData);

      // モーダルを非表示に
      this.hideModal();
    },
    // キャンセルボタン
    closeTareWaterEditModal() {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 1) {
              this.hideModal();
            }
          },
        });
      } else {
        this.hideModal();
      }
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
    },

    // 入力欄の桁数自動調整
    adjustDigits(target) {
      if (this.cavisible_1 || this.cavisible_2 || this.cavisible_3 || this.cavisible_4 || this.cavisible_5 || this.isPostHide) {
        return;
      }
      if (this.nowMode === unitMode.g) {
        return target;
      } else {
        // 体重計_除水風袋g/kg変換不正です 林峻峰 start
        // return Number(target).toFixed(2);
        // #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng start
        // return this.getEditModalDataMode === dataMode.tare ? (Math.floor(target * 100) / 100).toFixed(2) : (Math.ceil(target * 100) / 100).toFixed(2);
        if(this.blurflg){
          const round = this.getEditModalDataMode === dataMode.tare ? BigNumber.ROUND_DOWN : BigNumber.ROUND_UP;
          return new BigNumber(target).decimalPlaces(2,  round).toFormat(2);
        }
        // #11364 【たくしん会】体重計マスタで風袋・除水補正の初期表示単位を㎏に指定した場合に、数値を換算せずg単位のままの数値で表示する。　V1.0B linjunfeng end
        // 体重計_除水風袋g/kg変換不正です 林峻峰 end
      }
    },
    // 入力欄のフォーカス移動
    moveFocus(event) {
      event.target.blur();
    },

    // 入力欄のマウスホイールイベント設定
    addWheelEvent() {
      let tareWaterID1 = this.getScopedElementById("tareWaterID_1");
      if (tareWaterID1) {
        tareWaterID1.addEventListener('wheel', () => {});
      }
      let tareWaterID2 = this.getScopedElementById("tareWaterID_2");
      if (tareWaterID2) {
        tareWaterID2.addEventListener('wheel', () => {});
      }
      let tareWaterID3 = this.getScopedElementById("tareWaterID_3");
      if (tareWaterID3) {
        tareWaterID3.addEventListener('wheel', () => {});
      }
      let tareWaterID4 = this.getScopedElementById("tareWaterID_4");
      if (tareWaterID4) {
        tareWaterID4.addEventListener('wheel', () => {});
      }
      let tareWaterID5 = this.getScopedElementById("tareWaterID_5");
      if (tareWaterID5) {
        tareWaterID5.addEventListener('wheel', () => {});
      }
    },

    // テンキー表示時にキー入力無効化
    onKeyDown(event) {
      if (this.cavisible_1 || this.cavisible_2 || this.cavisible_3 || this.cavisible_4 || this.cavisible_5) {
        event.preventDefault();
      }
    },

    // 数値範囲内ループチェック
    checkLoop(event) {
      // テキスト入力の場合は除外
      if (event.inputType && event.inputType === "insertText") {
        return;
      }

      // テンキー入力の場合は除外
      if (this.cavisible_1 || this.cavisible_2 || this.cavisible_3 || this.cavisible_4 || this.cavisible_5) {
        return;
      }

      // 数値範囲内かどうかの確認
      if (this.nowMode === unitMode.g) {
        if (event.target.value > this.inputMax) {
          event.target.value = this.inputMin;
        } else if (event.target.value < this.inputMin) {
          event.target.value = this.inputMax;
        }
      } else if (this.nowMode === unitMode.kg) {
        if (event.target.value > (this.inputMax / 1000)) {
          event.target.value = (this.inputMin / 1000);
        } else if (event.target.value < (this.inputMin / 1000)) {
          event.target.value = (this.inputMax / 1000);
        }
      }
    },

    // add FNSI-体重計モードテンキーの追加 徐 start
    show(e) {
      if (e === 1) {
        let tareWaterID1 = this.getScopedElementById("tareWaterID_1");
        tareWaterID1.setAttribute("type", "text");
        this.input = tareWaterID1.firstElementChild;
        this.popoverTarget = tareWaterID1;
        this.cavisible_1 = !this.cavisible_1;
        this.clearFlg = 1;
        if (this.cavisible_2) {
          this.cavisible_2 = false;
        }
        if (this.cavisible_3) {
          this.cavisible_3 = false;
        }
        if (this.cavisible_4) {
          this.cavisible_4 = false;
        }
        if (this.cavisible_5) {
          this.cavisible_5 = false;
        }
      } else if (e === 2) {
        let tareWaterID2 = this.getScopedElementById("tareWaterID_2");
        tareWaterID2.setAttribute("type", "text");
        this.input = tareWaterID2.firstElementChild;
        this.popoverTarget = tareWaterID2;
        this.cavisible_2 = !this.cavisible_2;
        this.clearFlg = 2;
        if (this.cavisible_1) {
          this.cavisible_1 = false;
        }
        if (this.cavisible_3) {
          this.cavisible_3 = false;
        }
        if (this.cavisible_4) {
          this.cavisible_4 = false;
        }
        if (this.cavisible_5) {
          this.cavisible_5 = false;
        }
      } else if (e === 3) {
        let tareWaterID3 = this.getScopedElementById("tareWaterID_3");
        tareWaterID3.setAttribute("type", "text");
        this.input = tareWaterID3.firstElementChild;
        this.popoverTarget = tareWaterID3;
        this.cavisible_3 = !this.cavisible_3;
        this.clearFlg = 3;
        if (this.cavisible_1) {
          this.cavisible_1 = false;
        }
        if (this.cavisible_2) {
          this.cavisible_2 = false;
        }
        if (this.cavisible_4) {
          this.cavisible_4 = false;
        }
        if (this.cavisible_5) {
          this.cavisible_5 = false;
        }
      } else if (e === 4) {
        let tareWaterID4 = this.getScopedElementById("tareWaterID_4");
        tareWaterID4.setAttribute("type", "text");
        this.input = tareWaterID4.firstElementChild;
        this.popoverTarget = tareWaterID4;
        this.cavisible_4 = !this.cavisible_4;
        this.clearFlg = 4;
        if (this.cavisible_1) {
          this.cavisible_1 = false;
        }
        if (this.cavisible_2) {
          this.cavisible_2 = false;
        }
        if (this.cavisible_3) {
          this.cavisible_3 = false;
        }
        if (this.cavisible_5) {
          this.cavisible_5 = false;
        }
      } else if (e === 5) {
        let tareWaterID5 = this.getScopedElementById("tareWaterID_5");
        tareWaterID5.setAttribute("type", "text");
        this.input = tareWaterID5.firstElementChild;
        this.popoverTarget = tareWaterID5;
        this.cavisible_5 = !this.cavisible_5;
        this.clearFlg = 5;
        if (this.cavisible_1) {
          this.cavisible_1 = false;
        }
        if (this.cavisible_2) {
          this.cavisible_2 = false;
        }
        if (this.cavisible_3) {
          this.cavisible_3 = false;
        }
        if (this.cavisible_4) {
          this.cavisible_4 = false;
        }
      }
      this.input.setAttribute("readonly", "readonly");
      this.selectAllInput(this.input);
      let name = ["{reverse} {clr} {backspace}", "7 8 9", "4 5 6", "1 2 3", "{zero} . {cancel}"];
      let meta = {
        "reverse": { func: "next", text: "＋/－"},
        "clr": { func: "accept", text: "CLR", classes: "control"},
        "backspace": { func: "backspace", classes: "control"},
        "zero": { key: "0"},
        "cancel": { func: "cancel", text: "確定", classes: "featured"}
      };
      let layoutparam = {default: name, _meta: meta};
      this.layout = layoutparam;
    },

    // テンキー用関数 accept: 全文字クリア
    accept() {
      const targetId = "tareWaterID_" + this.clearFlg;
      const clearTargetValue = this.getScopedElementById(targetId).value;
      // 入力前の値が"0.00"以外の場合、全文字クリア処理を2回行う
      if (clearTargetValue !== "0.00") this.doClearTwice = true;

      this.clearValue();
      this.moveCursor();
    },

    // テンキー用関数 cancel: 画面テンキーを閉じる
    cancel() {
      this.isPostHide = true;

      if (this.cavisible_1) {
        this.getScopedElementById("tareWaterIDPopOver_1").hide();
        this.cavisible_1 = false;
      }
      if (this.cavisible_2) {
        this.getScopedElementById("tareWaterIDPopOver_2").hide();
        this.cavisible_2 = false;
      }
      if (this.cavisible_3) {
        this.getScopedElementById("tareWaterIDPopOver_3").hide();
        this.cavisible_3 = false;
      }
      if (this.cavisible_4) {
        this.getScopedElementById("tareWaterIDPopOver_4").hide();
        this.cavisible_4 = false;
      }
      if (this.cavisible_5) {
        this.getScopedElementById("tareWaterIDPopOver_5").hide();
        this.cavisible_5 = false;
      }
    },

    // テンキー用関数 next: 正負反転
    next() {
      let reverseVal = 0;
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      // this.isChanged = true;
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end

      if (this.clearFlg === 1) {
        reverseVal = this.getReverseVal(this.getScopedElementById("tareWaterID_1").value);
        this.getScopedElementById("tareWaterID_1").value = reverseVal;
        this.editData.weight_1 = reverseVal;
      } else if (this.clearFlg === 2) {
        reverseVal = this.getReverseVal(this.getScopedElementById("tareWaterID_2").value);
        this.getScopedElementById("tareWaterID_2").value = reverseVal;
        this.editData.weight_2 = reverseVal;
      } else if (this.clearFlg === 3) {
        reverseVal = this.getReverseVal(this.getScopedElementById("tareWaterID_3").value);
        this.getScopedElementById("tareWaterID_3").value = reverseVal;
        this.editData.weight_3 = reverseVal;
      } else if (this.clearFlg === 4) {
        reverseVal = this.getReverseVal(this.getScopedElementById("tareWaterID_4").value);
        this.getScopedElementById("tareWaterID_4").value = reverseVal;
        this.editData.weight_4 = reverseVal;
      } else if (this.clearFlg === 5) {
        reverseVal = this.getReverseVal(this.getScopedElementById("tareWaterID_5").value);
        this.getScopedElementById("tareWaterID_5").value = reverseVal;
        this.editData.weight_5 = reverseVal;
      }

      this.moveCursor();
    },

    // テンキー用関数 change: 値変更時
    change() {
    },

    // テンキー用関数 tenkeyClose: 画面テンキーを閉じた際の内部処理
    tenkeyClose() {
      this.isPostHide = true;

      if (this.clearFlg === 1) {
        // 入力を番号に戻す
        this.getScopedElementById("tareWaterID_1").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.checkWeight(this.clearFlg, this.editData.weight_1, {target: this.getScopedElementById("tareWaterID_1")});
      } else if (this.clearFlg === 2) {
        // 入力を番号に戻す
        this.getScopedElementById("tareWaterID_2").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.checkWeight(this.clearFlg, this.editData.weight_2, {target: this.getScopedElementById("tareWaterID_2")});
      } else if (this.clearFlg === 3) {
        // 入力を番号に戻す
        this.getScopedElementById("tareWaterID_3").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.checkWeight(this.clearFlg, this.editData.weight_3, {target: this.getScopedElementById("tareWaterID_3")});
      } else if (this.clearFlg === 4) {
        // 入力を番号に戻す
        this.getScopedElementById("tareWaterID_4").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.checkWeight(this.clearFlg, this.editData.weight_4, {target: this.getScopedElementById("tareWaterID_4")});
      } else if (this.clearFlg === 5) {
        // 入力を番号に戻す
        this.getScopedElementById("tareWaterID_5").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.checkWeight(this.clearFlg, this.editData.weight_5, {target: this.getScopedElementById("tareWaterID_5")});
      }

      this.input = null;
      this.isPostHide = false;
    },

    // テンキー用内部関数 getReverseVal: 正負反転した値を返す(g,kg考慮)
    getReverseVal(val) {
      const reverseVal = Number(val) * (-1);
      if (this.nowMode === unitMode.g) {
        return reverseVal;
      } else {
        return Number(reverseVal).toFixed(2);
      }
    },

    // テンキー用内部関数 moveCursor: カーソル位置を右端にセットする
    moveCursor() {
      this.input.focus();
      this.input.setSelectionRange(10, 10);
    },
    // テンキー用内部関数 selectAllInput: 入力内容を全選択状態にする
    selectAllInput(inputElement) {
      inputElement.focus();
      inputElement.setSelectionRange(0, inputElement.value.length);
    },

    // テンキー用内部関数 clearValue: 測定値をクリアする
    clearValue() {
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      // this.isChanged = true;
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
      if (this.clearFlg === 1) {
        this.getScopedElementById("tareWaterID_1").value = null;
        this.editData.weight_1 = null;
      } else if (this.clearFlg === 2) {
        this.getScopedElementById("tareWaterID_2").value = null;
        this.editData.weight_2 = null;
      } else if (this.clearFlg === 3) {
        this.getScopedElementById("tareWaterID_3").value = null;
        this.editData.weight_3 = null;
      } else if (this.clearFlg === 4) {
        this.getScopedElementById("tareWaterID_4").value = null;
        this.editData.weight_4 = null;
      } else if (this.clearFlg === 5) {
        this.getScopedElementById("tareWaterID_5").value = null;
        this.editData.weight_5 = null;
      }
    }
    // add FNSI-体重計モードテンキーの追加 徐 end
  }
};
</script>

<style scoped>
/* add FNSI-体重計モードテンキーの追加 徐 start */
.send-condition-tare-water-edit-modal-input-area-name :deep(.text-input) {
  text-align: left;
}
.send-condition-tare-water-edit-modal-input-area-value :deep(.text-input) {
  text-align: right;
  color: var(--send-cond-font-color) !important;
  background-color: var(--ntss-base-background-color) !important;
  opacity: 1 !important;
  height: 1.6em !important;
}
.send-condition-tare-water-edit-modal-input-area-value :deep(input[type="text"]) {
  padding-right: 15px;
}
.input-mobile :deep(input[type="text"]) {
  padding-right: 0px !important;
}
.popoverClass :deep(.popover--top) {
  width: auto;
}
/* add FNSI-体重計モードテンキーの追加 徐 end */
/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
ons-col textarea:focus {
  border-style: inset;
  border-color: unset;
}
</style>
