/**
 * チェック項目設定モーダルPage
 */
 <template>
  <modal-base @onClose="closeCheckSetModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <div slot="body">
      <div class="main-check-area">
        <div class="left-content" @drop.prevent="onDrop" @mouseup="onDrop">
          <div class="nowrap-block">
            <label class="config-label">タイトル</label>
            <v-ons-input class="custom-input-required check-text-input" @input="changeColor($event)" v-model="checkMaster.name" />
          </div>
          <div class="wrap-block">
            <label class="config-label">チェック動作</label>
            <ons-col class="radio-row">
              <v-ons-radio
                v-model="checkMaster.is_disable"
                name="radio-group-1"
                value="0"
                modifier="round"
                input-id="radio-enable"
              />
              <div class="radio-label">
                <label for="radio-enable" class="item-label">有効</label>
              </div>
              <v-ons-radio
                v-model="checkMaster.is_disable"
                name="radio-group-1"
                value="1"
                modifier="round"
                input-id="radio-disable"
              />
              <div class="radio-label">
                <label for="radio-disable" class="item-label radio-label">無効</label>
              </div>
            </ons-col>
          </div>
          <div class="wrap-block">
            <label class="config-label">表示対象</label>
            <ons-col class="radio-row">
              <v-ons-checkbox
                id="check-before"
                input-id="chk-before"
                value="before"
                v-model="checkMaster.is_disp_before"
              />
              <div class="radio-label">
                <label for="chk-before" class="item-label">前体重</label></div>
              <v-ons-checkbox
                id="check-after"
                input-id="chk-after"
                value="after"
                v-model="checkMaster.is_disp_after"
              />
              <div class="radio-label">
                <label for="chk-after" class="item-label radio-label">後体重</label></div>
            </ons-col>
          </div>
          <div class="wrap-block">
            <label class="config-label">表示条件</label>
            <div>
              <v-ons-select type="number" v-model.number="use_condition">
                <option
                  v-for="item in displayConditionItems"
                  :value="item.value"
                  :key="item.value"
                >{{ item.text }}</option>
              </v-ons-select>
              <div style="margin-top: 10px">
                <v-ons-input
                  style="margin-right: 5px"
                  type="text"
                  name="condition_left"
                  placeholder="左辺"
                  class="condition"
                  v-model="condition_left"
                  pattern="^[0-9a-zA-Z\.\+\-\*\/\^\(\)\[\]]*$"
                  @input="matchLeft(condition_left, $event)"
                  v-bind:disabled="isDisabledInputState"
                ></v-ons-input>
                <!-- mod FNSI-条件比較式名称の変更 徐 start -->
                <!-- <v-ons-select
                  type="number"
                  v-model.number="checkMaster.comparator"
                  v-bind:disabled="isDisabledInputState"
                > -->
                <v-ons-select
                  type="number"
                  v-model.number="checkMaster.condition_ineq"
                  v-bind:disabled="isDisabledInputState"
                >
                <!-- mod FNSI-条件比較式名称の変更 徐 end -->
                  <option
                    v-for="item in comparatorItems"
                    :value="item.value"
                    :key="item.value"
                  >{{ item.text }}</option>
                </v-ons-select>
                <v-ons-input
                  style="margin-left: 5px"
                  type="text"
                  name="condition_right"
                  placeholder="右辺"
                  class="condition"
                  v-model="condition_right"
                  pattern="^[0-9a-zA-Z\.\+\-\*\/\^\(\)\[\]]*$"
                  @input="matchRight(condition_right, $event)"
                  v-bind:disabled="isDisabledInputState"
                />
              </div>
            </div>
          </div>
          <div class="wrap-block">
            <label class="config-label">前表示文字</label>
            <v-ons-input class="check-text-input" v-model="checkMaster.before_word"/>
          </div>
          <div class="wrap-block">
            <label class="config-label">計算式</label>
            <v-ons-input
              class="check-text-input"
              type="text"
              name="calculate"
              v-model="calculate"
              pattern="^[0-9a-zA-Z\.\+\-\*\/\[\]\(\)\^]*$"
              @input="matchCalculate(calculate, $event)"
            />
          </div>
          <div class="wrap-block">
            <label class="config-label">後表示文字</label>
            <v-ons-input class="check-text-input" v-model="checkMaster.after_word"/>
          </div>
          <div class="wrap-block">
            <label class="config-label">小数点桁数</label>
            <!-- mod #5589 2023/04/12 数値IFのスタイル全不正 林峻峰 start -->
            <!-- <v-ons-input
              class="check-number-input"
              type="number"
              min="0"
              max="9"
              v-model.number="checkMaster.decimal_point"
            /> -->
            <v-ons-input
              class="check-number-input"
              type="number"
              v-model.number="checkMaster.decimal_point"
              @change="inputNumber($event, 0, 9)"
              @mousewheel.prevent="handleMouseWheel($event, 0, 9, 'decimal_point')"
              @blur="handleBlur($event, 0 ,9, 'decimal_point')"
            />
            <!-- mod #5589 2023/04/12 数値IFのスタイル全不正 林峻峰 end -->
          </div>
          <div class="wrap-block">
            <label class="config-label">正常範囲</label>
            <div>
              <div>
                <v-ons-checkbox
                  v-model="checkMaster.is_check_warn"
                  false-value="0"
                  true-value="1"
                  input-id="enable-check-warn"
                />
                <label for="enable-check-warn" class="item-label">適用</label>
              </div>
              <div style="line-height: 2em;">
                <label class="item-label">下限:</label>
                <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
                <!-- <v-ons-input
                  type="number"
                  class="normal-range"
                  v-model.number="checkMaster.min_warn"
                ></v-ons-input> -->
                <v-ons-input
                  type="number"
                  class="normal-range"
                  v-model.number="checkMaster.min_warn"
                  @input="inputNumber"
                  @mousewheel="inputNumber"
                ></v-ons-input>
                <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
                <label class="item-label">上限:</label>
                <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
                <!-- <v-ons-input
                  type="number"
                  class="normal-range"
                  v-model.number="checkMaster.max_warn"
                ></v-ons-input> -->
                <v-ons-input
                  type="number"
                  class="normal-range"
                  @input="inputNumber"
                  @mousewheel="inputNumber"
                  v-model.number="checkMaster.max_warn"
                ></v-ons-input>
                <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
              </div>
            </div>
          </div>
          <div class="wrap-block">
            <label class="config-label">条件送信制限</label>
            <ons-col>
              <v-ons-select type="number" v-model.number="checkMaster.sendable">
                <option
                  v-for="item in conditionTransmissionLimitItems"
                  :value="item.value"
                  :key="item.value"
                >{{ item.text }}</option>
              </v-ons-select>
            </ons-col>
          </div>
          <div class="wrap-block">
            <label class="config-label">印字設定</label>
            <div>
              <ons-col class="radio-row" style="margin-bottom: 5px;">
                <v-ons-checkbox
                  id="print-before"
                  input-id="before"
                  value="before"
                  v-model="checkMaster.is_print[0]"
                />
                <div class="config-radio-label">
                  <label for="before" class="item-label">前体重</label></div>
                <v-ons-checkbox
                  id="print-after"
                  input-id="after"
                  value="after"
                  v-model="checkMaster.is_print[1]"
                />
                <div class="config-radio-label">
                  <label for="after" class="item-label">後体重</label></div>
              </ons-col>
              <ons-col class="radio-row">
                <v-ons-checkbox
                  id="print-non"
                  input-id="non"
                  value="non"
                  v-model="checkMaster.is_print[2]"
                />
                <div class="config-radio-label">
                  <label for="non" class="item-label">スケジュールなし</label></div>
                <v-ons-checkbox
                  id="print-notset"
                  input-id="notset"
                  value="notset"
                  v-model="checkMaster.is_print[3]"
                />
                <div class="config-radio-label">
                  <label for="notset" class="item-label">患者未設定</label></div>
              </ons-col>
            </div>
          </div>
          <div class="wrap-block">
            <label class="item-label">メッセージのプレビュー</label>
          </div>
          <div class="wrap-block">
            <div class="preview">
              {{preview}}
              {{previewSample}}
            </div>
          </div>
        </div>
        <div class="right-content">
          <kendo-grid
            id="edit_check_grid"
            ref="grid"
            :data-source="localDataSource"
            :resizable="true"
            :selectable="'row'"
            :scrollable="true"
            :height="'450px'"
            v-on:databound="columnFit"
            v-on:change="onChange"
          >
            <kendo-grid-column :field="'value_name'" :title="'ID'" :width="140" :encoded="false"></kendo-grid-column>
            <kendo-grid-column :field="'code'" :title="'引数'" :width="100"></kendo-grid-column>
            <kendo-grid-column :field="'sample_value'" :title="'サンプル値'"></kendo-grid-column>
          </kendo-grid>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel button denial-btn" @click="closeCheckSetModal">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="common-style-select-button button registration-btn" :disabled="!hasChangeFlag" @click="saveCheckSetModal">確定</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapActions, mapGetters } from "vuex";
import $$ from "jquery";
import BigEval from "@/functions/BigEvalEx";
import { operateLegendData, checkContent } from "@/constants/weightDefine";
import BigNumber from "bignumber.js";
import { EventBus } from "@/eventBus.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import cloneDeep from "lodash/cloneDeep";
import isEqualWith from "lodash/isEqualWith";
import { customComparator } from "@/utils/util.js";

export default {
  name: "mstWeightCheckItemModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      hasChangeFlag: false,
      header: "",
      selectItem: null,
      checkItems: ["前体重", "後体重"],
      checkedList: [],
      localDataSource: operateLegendData.legends,
      displayConditionItems: [
        { text: "常に表示", value: checkContent.use_condition.always },
        { text: "満たす場合に表示", value: checkContent.use_condition.isTrueView },
        { text: "満たさない場合に表示", value: checkContent.use_condition.isFalseView }
      ],
      comparatorItems: [
        { text: "＞", value: checkContent.condition_ineq.more },
        { text: "≧", value: checkContent.condition_ineq.moreEqual },
        { text: "＝", value: checkContent.condition_ineq.equal },
        { text: "≠", value: checkContent.condition_ineq.notEqual },
        { text: "≦", value: checkContent.condition_ineq.lessEqual },
        { text: "＜", value: checkContent.condition_ineq.less }
      ],
      conditionTransmissionLimitItems: [
        { text: "制限なし", value: 0 },
        { text: "正常範囲外確認チェック", value: 1 },
        { text: "正常範囲外送信不可", value: 2 },
        { text: "表示時確認チェック", value: 3 },
        { text: "表示時送信不可", value: 4 }
      ],
      // プレビュー用サンプル値計算式
      prevSampleCalculate: "",
      // 左辺のデータタイプ [0:number 1:date 2:text]
      left_datatype: 2,
      // 右辺のデータタイプ [0:number 1:date 2:text]
      right_datatype: 2,
      // eval代替
      bigEval: new BigEval(),
      checkMaster: {},
      // add FNSI-キャンセルの場合変更データクリア 徐 start
      lastCurrentRowData: {},
      // add FNSI-キャンセルの場合変更データクリア 徐 end
      //Android端末で編集中であることを示すフラグ
      androidFlg: false,
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false,
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
    };
  },
  created() {
    // 端末判別
    if (navigator.userAgent.match(/Android/)) {
      this.androidFlg = true;
    }
    this.checkMaster = this.getCurrentRowData;
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240111 mrx start
    this.checkMasterClone = cloneDeep(this.checkMaster);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240111 mrx end
  },
  computed: {
    ...mapGetters("mst-weight/check", ["getCurrentRowData"]),
    // redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy start
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    // redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy end
    // 表示条件
    use_condition: {
      get() {
        return this.checkMaster.use_condition;
      },
      set(value) {
        // 手入力
        this.checkMaster.use_condition = value;
      }
    },
    isDisabledInputState() {
      // 常に表示の場合は操作不可
      if (this.checkMaster) {
        let dom = document.getElementsByClassName("condition");
        if(this.checkMaster.use_condition == 0 && dom.length > 1){
          dom[1].classList.remove("custom-input-invalid");
          dom[2].classList.remove("custom-input-invalid");
        }
        return !(this.checkMaster.use_condition > 0);
      }
      return true;
    },
    // 左辺
    condition_left: {
      get() {
        return this.checkMaster.condition_left;
      },
      set(value) {
        // 手入力
        this.checkMaster.condition_left = value;
        // 空にした場合
        if (value === "") {
          // 入力タイプをクリア
          this.left_datatype = 2;
        } else {
          // 入力された項目の種類をチェック
          const inputItemType = this.getType(value);
          // 入力項目チェック
          if (this.checkInputType(this.left_datatype, inputItemType) === true) {
            this.left_datatype = inputItemType;
          }
        }
      }
    },
    // 右辺
    condition_right: {
      get() {
        return this.checkMaster.condition_right;
      },
      set(value) {
        // 手入力
        // 空にした場合
        if (value === "") {
          // 入力タイプをクリア
          this.right_datatype = 2;
          this.checkMaster.condition_right = value;
        } else {
          // 入力された項目の種類をチェック
          const inputItemType = this.getType(value);
          // 入力項目チェック
          if (
            this.checkInputType(this.right_datatype, inputItemType) === true
          ) {
            this.right_datatype = inputItemType;
            this.checkMaster.condition_right = value;
          }
        }
      }
    },
    // 計算式
    calculate: {
      get() {
        return this.checkMaster.calculate;
      },
      set(value) {
        // 空にした場合
        this.checkMaster.calculate = value;
        if (value === "") {
          // 入力タイプをクリア
          this.checkMaster.print_datatype = 2;
        } else {
          // サンプル値での表示を計算
          this.prevSampleCalculate = this.calculation();
        }
      }
    },
    // プレビュー
    preview() {
      return `${this.checkMaster.before_word}${this.checkMaster.calculate}${this.checkMaster.after_word}`;
    },
    // プレビューサンプル値
    previewSample() {
      // プレビュー用の計算
      return `${this.checkMaster.before_word}${this.prevSampleCalculate}${this.checkMaster.after_word}`;
    }
  },
  // redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy start
  watch: {
    getFontSize() {
      let colHeader = document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[3].children[0].children[0]
      let colContent = document.getElementsByClassName("k-selectable")[3].children[0]
      if (parseInt(this.getFontSize) == 3) {
        colHeader.children[0].style.width = "201px"
        colHeader.children[1].style.width = "74px"
        colHeader.children[2].style.width = "151px"

        colContent.children[0].style.width = "201px"
        colContent.children[1].style.width = "74px"
        colContent.children[2].style.width = "151px"
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240111 mrx start
    checkMaster: {
      handler(val) {
        this.hasChangeFlag = !isEqualWith(val, this.checkMasterClone, customComparator);
      },
      deep: true
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240111 mrx end
  },
  // redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy end
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("mst-weight/check", ["applyEditingRow"]),
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing"
    }),
    async editStart() {
      if (this.androidFlg) {
        await this.setIsGridEditing(true);
      }
    },
    editEnd() {
      this.setIsGridEditing(false);
    },
    changeColor(e){
      e.target.parentElement.classList.remove("custom-input-invalid");
    },
    // 右辺の入力制限
    matchLeft(oldVal, event) {
      document.getElementsByClassName("condition")[1].classList.remove("custom-input-invalid");
      const re = new RegExp(event.target.pattern);
      const result = re.exec(event.target.value);
      event.target.value = result ? result.input : oldVal;
      this.condition_left = event.target.value;
    },
    // 右辺の入力制限
    matchRight(oldVal, event) {
      document.getElementsByClassName("condition")[2].classList.remove("custom-input-invalid");
      const re = new RegExp(event.target.pattern);
      const result = re.exec(event.target.value);
      event.target.value = result ? result.input : oldVal;
      this.condition_right = event.target.value;
    },
    // 計算式の入力制限
    matchCalculate(oldVal, event) {
      document.getElementsByName("calculate")[0].classList.remove("custom-input-invalid");
      const re = new RegExp(event.target.pattern);
      const result = re.exec(event.target.value);
      event.target.value = result ? result.input : oldVal;
      this.calculate = event.target.value;
    },
    // 入力項目の種類チェック
    checkInputType(targetType, inputType) {
      // 印字時のデータタイプ [0:number 1:date 2:text]
      // numberの場合
      if (targetType === 0 && inputType === 1) {
        return false;
      }
      // dateの場合
      if (targetType === 1 && inputType !== 2) {
        return false;
      }
      return true;
    },
    getType(inputStr) {
      // 入力項目の種類
      let inputItemType = 2;
      // 入力値から最後の項目を切り出し 例:[dw]
      inputStr = inputStr.slice(inputStr.lastIndexOf("["));
      const inputItem = inputStr.slice(0, inputStr.lastIndexOf("]") + 1);

      for (let i = 0; i < operateLegendData.legends.length; i++) {
        const repStr = operateLegendData.legends[i].code;
        // 対象文字がある場合
        if (inputItem === repStr) {
          if (operateLegendData.legends[i].type === "number") {
            // 印字時のデータタイプ [0:number 1:date 2:text]
            inputItemType = 0;
          } else if (operateLegendData.legends[i].type === "date") {
            // 印字時のデータタイプ [0:number 1:date 2:text]
            inputItemType = 1;
          }
        }
      }

      return inputItemType;
    },
    // プレビュー用の計算
    calculation() {
      let calStr = this.checkMaster.calculate;
      // 印字時のデータタイプ [0:number 1:date 2:text]
      this.checkMaster.print_datatype = this.getType(calStr);

      // 引数をサンプル値に変換
      for (let i = 0; i < operateLegendData.legends.length; i++) {
        let repStr = operateLegendData.legends[i].code;
        if (!(typeof repStr === "undefined")) {
          // 対象文字がある場合
          if (calStr.indexOf(repStr) > -1) {
            repStr = repStr.replace("[", "\\[").replace("]", "\\]");
            calStr = calStr.replace(
              new RegExp(repStr, "g"),
              operateLegendData.legends[i].sample_value
            );
          }
        }
      }

      // 印字時のデータタイプ [0:number 1:date 2:text]
      if (this.checkMaster.print_datatype === 0) {
        // 数値の場合
        // 空白削除
        calStr = calStr.replace(/\s+/g, "");
        // 計算式の文字列を計算
        const calcAnswer = this.safeEval(calStr);
        // 小数点桁数を表示
        if (
          typeof calcAnswer === "object" &&
          this.checkMaster.decimal_point >= 0
        ) {
          // 計算が成功している場合はBigNumberオブジェクトが返るが、失敗時は文字列
          const BN = BigNumber.clone({
            ROUNDING_MODE: BigNumber.ROUND_HALF_UP,
            DECIMAL_PLACES: this.checkMaster.decimal_point
          });
          const ans = new BN(calcAnswer.toNumber(), 10);
          return ans.toFixed(this.checkMaster.decimal_point);
        } else {
          return calcAnswer;
        }
      } else {
        // 数値以外の場合
        return calStr;
      }
    },
    // 計算式文字列→計算
    safeEval(val) {
      try {
        const rVal = "";
        const calVal = this.bigEval.exec(val);
        if (typeof calVal === "undefined") {
          return rVal;
        }
        return calVal;
      } catch (e) {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstWeightCheckItemModal.vue', 'safeEval', e);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        return "";
      }
    },
    // Grid表示カラム幅変更
    columnFit() {
      let grid = this.$refs.grid.kendoWidget();
      for (let i = 0; i < grid.columns.length; i++) {
        grid.autoFitColumn(i);
      }
    },
    // グリッドの項目選択イベント
    onChange(event) {
      if (event.sender) {
        const selected = $$.map(event.sender.select(), item => item);
        const inputItem = selected[0].childNodes[1].innerText;
        // 入力項目のデータタイプ [0:number 1:date 2:text]
        const inputItemType = this.getType(inputItem);

        // 入力項目選択前にフォーカスが当たっていた要素チェック
        switch (this.selectItem) {
          case "condition_left":
            // 左辺の場合
            // 入力項目チェック
            if (
              this.checkInputType(this.left_datatype, inputItemType) === true
            ) {
              this.checkMaster.condition_left += inputItem;
              this.left_datatype = inputItemType;
            }
            break;
          case "condition_right":
            // 右辺の場合
            // 入力項目チェック
            if (
              this.checkInputType(this.right_datatype, inputItemType) === true
            ) {
              this.checkMaster.condition_right += inputItem;
              this.right_datatype = inputItemType;
            }
            break;
          case "calculate":
            // 計算式の場合
            // 入力項目チェック
            if (
              this.checkInputType(
                this.checkMaster.print_datatype,
                inputItemType
              ) === true
            ) {
              this.checkMaster.calculate += inputItem;
              // サンプル値での表示を計算
              this.prevSampleCalculate = this.calculation();
            }
            break;
          default:
            break;
        }
      }
    },
    // 要素選択イベント
    onDrop(event) {
      if (event.target.name) {
        this.selectItem = event.target.name;
      } else {
        this.selectItem = null;
      }
    },
    // 確定ボタン
    saveCheckSetModal() {
      // 測定値チェック設定
      const settings = this.checkMaster;
      // 印字時の初期フォーマット
      switch (settings.print_datatype) {
        case 0:
          // 数値の場合
          settings.print_default_format = "3.2";
          break;
        case 1:
          // 日付の場合
          settings.print_default_format = "YYYYMMDD";
          break;
        case 2:
          // テキストの場合
          settings.print_default_format = "";
          break;
        default:
          break;
      }

      // 登録内容チェック(未実装)
      if (this.validateOnRegistration()) {
        // storeに登録
        this.applyEditingRow(settings);

        // モーダルを非表示に
        this.hideModal();

        EventBus.$emit("applyCheckConfigEdit");
      }
    },
    // キャンセルボタン
    closeCheckSetModal() {
      if(this.hasChangeFlag) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: async answer => {
            if (answer === 1) {
              this.hideModal();
            }
          }
        })
      } else {
        // モーダルを非表示に
        this.hideModal();
      }
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        let gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.classList === undefined) {
          gridHeader = this.$refs.grid.$el.firstElementChild;
        }
        gridHeader?.classList?.add("master-grid-header");
      });
    },
    validateData() {
      // 表示条件があるのに条件式が未設定
      let isValidCondition = true;
      let isValidConditionLeft = true;
      let isValidConditionRight = true;
      if (!this.isDisabledInputState) {
        if (
          this.checkMaster.condition_right.trim().length === 0 ||
          this.checkMaster.condition_left.trim().length === 0
        ) {
          isValidCondition = false;
        }
        if (this.checkMaster.condition_right.trim().length === 0) {
          isValidConditionRight = false;
        }
        if(this.checkMaster.condition_left.trim().length === 0){
          isValidConditionLeft = false;
        }

      }
      const checkName = this.checkMaster.name;
      let isValidCalc = true;
      // 計算式異常
      if (this.checkMaster.print_datatype === 0) {
        // 数値の場合
        if (isNaN(Number(this.calculation()))) {
          isValidCalc = false;
        }
      }
      return {
        conditionValid: isValidCondition,
        nameValid: checkName !== null && checkName !== "",
        calcValid: isValidCalc,
        conditionValidLeft: isValidConditionLeft,
        conditionValidRight: isValidConditionRight
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200075'].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "名称を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200075'].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.conditionValid ? "表示条件が未設定です。<br>" : ""
            !validationResult.conditionValid ? messageFormat(DIALOG_MESSAGES['00200104'].message) : ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.calcValid ? "計算式が異常です<br>" : ""
            !validationResult.conditionValid ? messageFormat(DIALOG_MESSAGES['00200105'].message) : ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
        `;
      if(!validationResult.nameValid){
        document.getElementsByClassName("custom-input-required")[1]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.conditionValidLeft){
        document.getElementsByClassName("condition")[1]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.conditionValidRight){
        document.getElementsByClassName("condition")[2]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.calcValid){
        document.getElementsByName("calculate")[0]?.classList?.add("custom-input-invalid");
      }
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
     //  mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
    inputNumber(e,min,max){
      // 数値範囲内かどうかの確認
      if (min !== undefined && max !== undefined) {
        if (e.target.value > max) {
          e.target.value = min;
          this.blurFlg = true;
        } else if (e.target.value < min) {
          e.target.value = max;
          this.blurFlg = true;
        }
      }
    },
    handleBlur(event,min,max, key){
      if (event.target.value == max && this.blurFlg) {
        this.checkMaster[key] = min;
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.checkMaster[key] = max;
        this.blurFlg = false
      }
    },
    handleMouseWheel(e,min,max, key) {
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) || 
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = min
      }    
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > max) {
        value = min;
      }
      if(value < min) {
        value = max;
      }
      this.checkMaster[key] = value
    },
    //  mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
  },
  updated() {
    this.editBackgroundColor();
  },
  mounted() {
    this.editBackgroundColor();
    this.prevSampleCalculate = this.calculation();
  }
};
</script>

<style scoped>
.main-check-area {
  margin: auto;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  font-size: 1em;
}
.wrap-block {
  /*add 測定チェックのモーダルにて入力IF間の間隔がすくなく誤操作要因となる。鞠 start*/
  margin-bottom: 15px;
  /*add 測定チェックのモーダルにて入力IF間の間隔がすくなく誤操作要因となる。鞠 end*/
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  /*add 測定チェックのモーダルにて入力IF間の間隔がすくなく誤操作要因となる。鞠 start*/
  margin-bottom: 15px;
  height: 2em;
  /*add 測定チェックのモーダルにて入力IF間の間隔がすくなく誤操作要因となる。鞠 end*/
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.left-content {
  margin-left: 2%;
  display: inline-block;
  min-width: 35em;
}
.right-content {
  margin-left: 1%;
  margin-right: 2%;
  /* del redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy start */
  /*min-width: 35%;*/
  /* del redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy end */
}

.row-style {
  margin-top: 10px;
}

.condition {
  width: 10em;
}

.normal-range {
  width: 4em;
}

.check-text-input {
  max-width: 10em;
}

.check-number-input {
  max-width: 3em;
}

.config-label {
  width: 7em;
}

.preview {
  text-align: left;
  white-space: pre-wrap;
  word-wrap: break-word;
}
.flex-container-vertical-center {
  vertical-align: center;
}
#edit_check_grid.k-widget {
  font-size: unset;
}
.radio-row {
  display: flex;
}
.radio-label {
  /* mod redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy start */
  width: 3.5em;
  /* mod redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy end */
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
/* add redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy start */
.config-radio-label {
  width: 8.5em;
}
/* add redmine 4739 体重計マスタ＞測定チェック＞詳細モーダルのレイアウト不正 宋qy end */
</style>
