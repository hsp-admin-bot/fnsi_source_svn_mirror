/**
 * 検査項目マスタモーダル
 */
<template>
  <div id="exam-item-modal-content">
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="exam-item-name" name ="requireNname">検査項目名</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt-long">
        <v-ons-input
          class="input-required"
          type="text"
          input-id="exam-item-name"
          required = true
          maxlength="40"
          v-model="inputModel.exam_item_name"
          @input="setCss($event.target.value)">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="data-type">データ形式</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="data-type"
          v-model="inputModel.data_type"
          name="data-type"
        >
          <option v-for="(item, index) in comboDataType" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="unit">単位</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
          type="text"
          input-id="unit"
          maxlength="20"
          v-model="inputModel.unit">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="normal-value-class">正常値区分</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="normal-value-class"
          v-model="inputModel.normal_value_class"
          name="normal-value-class">
          <option v-for="(item, index) in comboNormalValueClass" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-show="inputModel.normal_value_class === '0'">
      <v-ons-col class="input-item-name">
        <label for="normal-value-class">正常値</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/03/10 メッセージボックス全調整 張博 start -->
        <!-- <v-ons-input
          @input="inputNumber($event)"
          type="number"
          step="0.000000001"
          input-id="normal-value-lower"
          max="999999.999999999"
          min="-999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_lower"
          @change="saveNumber($event,'normal_value_lower')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="normal-value-lower"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 0),saveNumber($event,'normal_value_lower')"
          @click="inputClick($event)"
          :value="inputModel.normal_value_lower"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 0)"
          @focus="handleFocus(0)"
          @input="saveNumber($event,'normal_value_lower')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.normal_value_lower"
          :init-val="initInputModel.normal_value_lower"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.normal_value_lower = val;}"
        />
        <!-- mod #5589 2023/03/10 メッセージボックス全調整 張博 end -->
      </v-ons-col>
      <v-ons-col vertical-align="center" class="input-item-hyphen">
        <label for="normal-value-upper">～</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/03/10 メッセージボックス全調整 張博 start -->
        <!-- <v-ons-input
          @input="inputNumber($event)"
          type="number"
          step="0.000000001"
          input-id="normal-value-upper"
          max="999999.999999999"
          min="-999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_upper"
          @change="saveNumber($event,'normal_value_upper')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="normal-value-upper"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 1)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_upper"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 1)"
          @focus="handleFocus(1)"
          @input="saveNumber($event,'normal_value_upper')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.normal_value_upper"
          :init-val="initInputModel.normal_value_upper"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.normal_value_upper = val;}"
        />
        <!-- mod #5589 2023/03/10 メッセージボックス全調整 張博 end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-show="inputModel.normal_value_class === '1'">
      <v-ons-col class="input-item-name">
        <label for="normal-value-class-m">正常値(男性)</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 start -->
        <!-- <v-ons-input
          @input="inputNumber($event)"
          type="number"
          step="0.000000001"
          input-id="normal-value-lower-m"
          max="999999.999999999"
          min="-999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_lower_m"
          @change="saveNumber($event,'normal_value_lower_m')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="normal-value-lower-m"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 8)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_lower_m"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 8)"
          @focus="handleFocus(8)"
          @input="saveNumber($event,'normal_value_lower_m')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.normal_value_lower_m"
          :init-val="initInputModel.normal_value_lower_m"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.normal_value_lower_m = val;}"
        />
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 end -->
      </v-ons-col>
      <v-ons-col vertical-align="center" class="input-item-hyphen">
        <label for="normal-value-upper-m">～</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 start -->
        <!-- <v-ons-input
          @input="inputNumber($event)"
          type="number"
          step="0.000000001"
          input-id="normal-value-upper-m"
          max="999999.999999999"
          min="-999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_upper_m"
          @change="saveNumber($event,'normal_value_upper_m')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="normal-value-upper-m"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 9)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_upper_m"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 9)"
          @focus="handleFocus(9)"
          @input="saveNumber($event,'normal_value_upper_m')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.normal_value_upper_m"
          :init-val="initInputModel.normal_value_upper_m"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.normal_value_upper_m = val;}"
        />
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-show="inputModel.normal_value_class === '1'">
      <v-ons-col class="input-item-name">
        <label for="normal-value-class-w">正常値(女性)</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 start -->
        <!-- <v-ons-input
          type="number"
          @input="inputNumber($event)"
          step="0.000000001"
          input-id="normal-value-lower-w"
          max="999999.999999999"
          min="-999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_lower_w"
          @change="saveNumber($event,'normal_value_lower_w')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="normal-value-lower-w"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 10)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_lower_w"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 10)"
          @focus="handleFocus(10)"
          @input="saveNumber($event,'normal_value_lower_w')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.normal_value_lower_w"
          :init-val="initInputModel.normal_value_lower_w"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.normal_value_lower_w = val;}"
        />
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 end -->
      </v-ons-col>
      <v-ons-col vertical-align="center" class="input-item-hyphen">
        <label for="normal-value-upper-w">～</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 start -->
        <!-- <v-ons-input
          type="number"
          @input="inputNumber($event)"
          step="0.000000001"
          input-id="normal-value-upper-w"
          max="999999.999999999"
          min="-999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_upper_w"
          @change="saveNumber($event,'normal_value_upper_w')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="normal-value-upper-w"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 11)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.normal_value_upper_w"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 11)"
          @focus="handleFocus(11)"
          @input="saveNumber($event,'normal_value_upper_w')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.normal_value_upper_w"
          :init-val="initInputModel.normal_value_upper_w"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.normal_value_upper_w = val;}"
        />
        <!-- mod #5589 2023/05/23 メッセージボックス全調整 林峻峰 start -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="inputｰfigure">入力桁数 小数部</label>
      </v-ons-col>
      <v-ons-col v-show="false" class="input-item-num">
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start -->
         <!-- <v-ons-input
          type="number"
          oninput="if(value.length>2)value=value.slice(0,2);"
          onchange="if(value.indexOf('-') == 0)value=value.slice(1,2);"
          step="1"
          input-id="input-integer-figure"
          min="0"
          max="99"
          v-model="inputModel.input_integer_figure">
        </v-ons-input> -->
        <v-ons-input
          type="number"
          step="1"
          input-id="input-integer-figure"
          @change="inputNumber($event, 0, 99, 'input_integer_figure')"
          @mousewheel.prevent="handleMouseWheel($event, 0, 99, '1', 2)"
          @blur="handleBlur($event, 0, 99, 2),saveNumber($event,'input_integer_figure')"
          @focus="handleFocus(2)"
          v-model="inputModel.input_integer_figure">
        </v-ons-input>
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start -->
        <!-- <v-ons-input
          oninput="if(value.length>1)value=value.slice(0,1)"
          type="number"
          step="1"
          input-id="input-decimal-figure"
          min="0"
          max="9"
          v-model="inputModel.input_decimal_figure">
        </v-ons-input> -->
        <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng start -->
        <!-- <v-ons-input
          type="number"
          step="1"
          input-id="input-decimal-figure"
          @change="inputNumber($event, 0, 9, 'input_decimal_figure')"
          @mousewheel.prevent="handleMouseWheel($event, 0, 9, '1', 3)"
          @blur="handleBlur($event, 0, 9, 3)"
          @focus="handleFocus(3)"
          v-model="inputModel.input_decimal_figure"
          @input="saveNumber($event,'input_decimal_figure')">
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.input_decimal_figure"
          :init-val="initInputModel.input_decimal_figure"
          :max="8"
          :min="0"
          :step="1"
          :emptyVal="null"
          @handlerInput="handlerInputDecimalFigure"
        />
        <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng end -->
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="input-lower">入力範囲</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
         <!-- <v-ons-input
          type="number"
          @input="inputNumber($event)"
          step="0.000000001"
          input-id="input-lower"
          min="-999999.999999999"
          max="999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.input_lower"
          @change="saveNumber($event,'input_lower')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="input-lower"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 4)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.input_lower"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 4)"
          @focus="handleFocus(4)"
          @input="saveNumber($event,'input_lower')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.input_lower"
          :init-val="initInputModel.input_lower"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.input_lower = val;}"
        />
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-col>
      <v-ons-col vertical-align="center" class="input-item-hyphen">
        <label for="input-upper">～</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start -->
         <!-- <v-ons-input
          type="number"
          @input="inputNumber($event)"
          step="0.000000001"
          input-id="input-upper"
          min="-999999.999999999"
          max="999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.input_upper"
          @change="saveNumber($event,'input_upper')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="input-upper"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 5)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.input_upper"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 5)"
          @focus="handleFocus(5)"
          @input="saveNumber($event,'input_upper')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.input_upper"
          :init-val="initInputModel.input_upper"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.input_upper = val;}"
        />
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="graph-lower">グラフ表示範囲</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start -->
         <!-- <v-ons-input
          type="number"
          @input="inputNumber($event)"
          step="0.000000001"
          input-id="graph-lower"
          min="-999999.999999999"
          max="999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.graph_lower"
          @change="saveNumber($event,'graph_lower')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="graph-lower"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 6)"
          @DOMMouseScroll="stopScrollFun($event)"
          @focus="handleFocus(6)"
          @click="inputClick($event)"
          :value ="inputModel.graph_lower"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 6), saveNumber($event,'graph_lower')"
          @input="saveNumber($event,'graph_lower')"
          >
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.graph_lower"
          :init-val="initInputModel.graph_lower"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.graph_lower = val;}"
        />
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-col>
      <v-ons-col vertical-align="center" class="input-item-hyphen">
        <label for="graph-upper">～</label>
      </v-ons-col>
      <v-ons-col class="input-item-num">
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start -->
        <!-- <v-ons-input
          type="number"
          @input="inputNumber($event)"
          step="0.000000001"
          input-id="graph-upper"
          min="-999999.999999999"
          max="999999.999999999"
          @mousewheel="stopScrollFun($event)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.graph_upper"
          @change="saveNumber($event,'graph_upper')">
        </v-ons-input> -->
        <!-- <v-ons-input
          type="number"
          :step="inputNumberStepValue"
          input-id="graph-upper"
          @mousewheel.prevent="handleMouseWheel($event, -999999.999999999, 999999.999999999, inputNumberStepValue, 7)"
          @DOMMouseScroll="stopScrollFun($event)"
          @click="inputClick($event)"
          :value ="inputModel.graph_upper"
          @focus="handleFocus(7)"
          @change="inputNumber($event, -999999.999999999, 999999.999999999)"
          @blur="handleBlur($event, -999999.999999999, 999999.999999999, 7), saveNumber($event,'graph_upper')"
          @input="saveNumber($event,'graph_upper')">
        </v-ons-input> -->
        <custom-input-number-pro
          :value="inputModel.graph_upper"
          :init-val="initInputModel.graph_upper"
          :max="precision(inputModel.input_decimal_figure, 999999)"
          :min="precision(inputModel.input_decimal_figure, -999999)"
          :step="inputNumberStepValue"
          :emptyVal="null"
          @handlerInput="(val) => {inputModel.graph_upper = val;}"
        />
        <!-- mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="normal-value-class">仮想端末表示</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="console-class"
          v-model="inputModel.console_class"
          name="console-class">
          <option v-for="(item, index) in comboConsoleClass" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
        <!-- Add 院内院外フラグ start -->
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="spitz-is-in-hospital">院内院外フラグ</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="spitz-is-in-hospital"
          v-model="inputModel.is_in_hospital"
          name="exam-class"
        >
          <option
            v-for="(item, index) in comboSpitzInHospitals"
            :key="index"
            :value="item.value"
          >{{ item.text }}</option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <!-- Add 院内院外フラグ end -->
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="spitz-cd">採血管</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="spitz-cd"
          v-model="inputModel.spitz_cd"
          name="exam-class">
          <option v-for="(item, index) in comboSpitzCd" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name" >
        <label for="jlac10-cd">JLAC10コード</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt" style="max-width:15%;margin-right:5%">
        <v-ons-input
          type="text"
          input-id="jlac10-cd"
          oninput="value=value.replace(/[\W]/g,'')"
          v-model="inputModel.jlac10_cd">
        </v-ons-input>
      </v-ons-col>
      <v-ons-col>
        <button
          class="button btn3-normal"
          style="height: 2em;"
          @click="onSelect">臨床検査マスタ検索</button>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="exam-class">検査使用区分</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="exam-class"
          v-model="inputModel.exam_class"
          @change="changeExamClass"
          name="exam-class">
          <option v-for="(item, index) in comboExamClass" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-if="inputModel.exam_class === '0'">
      <v-ons-col class="input-item-name">
        <label for="infection-cd">感染症</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="infection-cd"
          v-model="inputModel.infection_cd"
          @change="changeInfectionCd"
          name="exam-class">
          <option v-for="(item, index) in comboInfectionCd" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-show="inputModel.exam_class === '0'">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">システム標準計算検査項目</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="default-calc-exam-item-cd"
          v-model="inputModel.default_calc_exam_item_cd"
          name="exam-class">
          <option v-for="(item, index) in comboDefaultCalcExamItemCd" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
      <v-ons-col class="input-item-txt" v-if="inputModel.default_calc_exam_item_cd =='0' || inputModel.default_calc_exam_item_cd ==''">
        <v-ons-checkbox  disabled = "true">
        </v-ons-checkbox>透析前&emsp;
        <v-ons-checkbox disabled = "true">
        </v-ons-checkbox>透析後
      </v-ons-col>
      <v-ons-col class="input-item-txt" v-else>
        <v-ons-checkbox
          id = "progressFlag1"
          :checked="progressFlag"
          @change="changeProgressFlag($event)"
        >
        </v-ons-checkbox><span id="progressFlag1-font">透析前&emsp;</span>
        <v-ons-checkbox
          id = "progressFlag2"
          :checked="progressFlag2"
          @change="changeProgressFlag($event)"
        >
        </v-ons-checkbox><span id="progressFlag2-font">透析後</span>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-show="inputModel.exam_class === '1'">
      <v-ons-col class="input-item-name">
        <label for="formulaId">システム標準検査</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <!-- mod redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy start -->
        <v-ons-select
          select-id="formulaId"
          v-model="inputModel.formulaId"
          name="exam-class"
          @change="onSelectDefaultCalc($event)">
          <option v-for="(item, index) in defaultCalcList" :key="index" :value="item.formulaId">
            {{ item.name }}
          </option>
        </v-ons-select>
        <!-- mod redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row" v-show="inputModel.exam_class === '2'">
      <v-ons-col class="input-item-name">
        <label for="exam-calc">検査計算式領域</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt-long">
        <v-ons-input
          readonly
          type="text"
          input-id="exam-calc"
          maxlength="1000"
          v-model="inputModel.exam_calc">
        </v-ons-input>
      </v-ons-col>
      <v-ons-col class="input-item-button">
        <v-ons-button id="formulaEdit" class="btn3-normal" @click="dispFormulaEdit">編集
        </v-ons-button>
      </v-ons-col>
    </v-ons-row>
    <!-- 連携コード一覧 -->
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">連携コード１</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
                  type="text"
                  input-id="in-hospital-cd1"
                  maxlength="20"
                  v-model="inputModel.in_hospital_cd1">
                </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">連携コード２</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
                  type="text"
                  input-id="in-hospital-cd2"
                  maxlength="20"
                  v-model="inputModel.in_hospital_cd2">
                </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">連携コード３</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
                  type="text"
                  input-id="in-hospital-cd3"
                  maxlength="20"
                  v-model="inputModel.in_hospital_cd3">
                </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <!-- 属性コード一覧 -->
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">属性コード１</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
                  type="text"
                  input-id="sbt-cd1"
                  maxlength="20"
                  v-model="inputModel.sbt_cd1">
                </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">属性コード２</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
                  type="text"
                  input-id="sbt-cd2"
                  maxlength="20"
                  v-model="inputModel.sbt_cd2">
                </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="default-calc-exam-item-cd">属性コード３</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
                  type="text"
                  input-id="sbt-cd3"
                  maxlength="20"
                  v-model="inputModel.sbt_cd3">
                </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <!-- 装置記録検索 -->
    <div class="edit-exam-formula-wrapper" id="edit-exam-formula-area" v-if="getIsShowEditFormulaModal">
    <edit-exam-formula />
    <div class="modal-footer flex-container" style="height:5em;">
      <div class="denial-btn-area" style="background:none">
        <button class="button denial-btn" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
<!--        upd #8782 検査計算項目が計算されない ztc 20230607 start-->
        <button class="button registration-btn" @click="validateOnRegistration">確定</button>
<!--        upd #8782 検査計算項目が計算されない ztc 20230607 end-->
      </div>
    </div>
    </div>
  </div>
</template>

<script>
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import { mapActions, mapGetters, mapState } from "@/compat/vue/vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { examItemSystemDefaultCalcList } from "@/constants/mstExamItemDefine";
import EditExamFormulaComponent from "@/components/master-maintenance/mst-exam-item/EditExamFormulaComponent";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { EventBus } from "@/compat/vue/event-bus.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { customComparator } from "@/utils/util"
// add #10713 小数点以下桁数指定を0～8までにする linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro';
// add #10713 小数点以下桁数指定を0～8までにする linjunfeng end

export default {
  mixins: [MasterMaintenanceMixin],
  name: "examItemMainModal",
  components: {
    "edit-exam-formula": EditExamFormulaComponent,
    // add #10713 小数点以下桁数指定を0～8までにする linjunfeng start
    "custom-input-number-pro":CustomInputNumberPro,
    // add #10713 小数点以下桁数指定を0～8までにする linjunfeng end
  },
  data() {
    return {
      inputModel: {
        // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy start
        formulaId: "",
        // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy end
        exam_item_name: "",
        data_type: "",
        unit: "",
        normal_value_class: "",
        normal_value_upper: "",
        normal_value_lower: "",
        normal_value_upper_m: "",
        normal_value_lower_m: "",
        normal_value_upper_w: "",
        normal_value_lower_w: "",
        input_integer_figure: "",
        input_decimal_figure: "",
        input_upper: "",
        input_lower: "",
        graph_upper: "",
        graph_lower: "",
        console_class: "",
        exam_class: "",
        in_hospital_cd1: "",
        sbt_cd1: "",
        in_hospital_cd2: "",
        sbt_cd2: "",
        in_hospital_cd3: "",
        sbt_cd3: "",
        spitz_cd: "",
        is_in_hospital: 0,
        jlac10_cd: "",
        infection_cd: "",
        /* modify by chamaojia 2023-06-27 【結合テスト】检查项目マスタ_登陆不正  --start */
        default_calc_exam_item_cd: "0",
        /* modify by chamaojia 2023-06-27 【結合テスト】检查项目マスタ_登陆不正  --end */
        dialysis_progress_flag:"",
        exam_calc: ""
      },
      // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 start
      initInputModel: {},
      // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 end
      inputNumberValue: {
        upper: "",
        lower: "",
        upper_m: "",
        lower_m: "",
        upper_w: "",
        lower_w: "",
        in_upper: "",
        in_lower: "",
        graph_upper: "",
        graph_lower: ""
      },
      comboDataType: [],
      comboNormalValueClass: [],
      comboConsoleClass: [],
      comboExamClass: [],
      comboSpitzCd: [],
      comboJlac10Cd: [],
      comboInfectionCd: [],
      comboDefaultCalcExamItemCd: [],
      defaultCalcList: [],
      addlist: [],
      //jlac10Cds: [],
      comboSpitzInHospitals: [],
      comboSpitzCds: [],
      progressFlag: false,
      progressFlag2: false,
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false,
      focusFlg: [false, false, false, false, false, false, false, false, false, false, false, false, false],
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
      inputNumberStepValue: 0,
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
      editRecordClone: null
    };
  },
  computed: {
    ...mapState("master-maintenance", ["gridData", "columns"]),
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("master-maintenance", {
        masterName: "getMasterName",
        editRecord: "getEditRecord",
        // columns: "getColumns",
        // getMasterRecordList: "getMasterRecordList",
    }),
    ...mapGetters("mst-exam-item", {
        getIsShowEditFormulaModal : "getIsShowEditFormulaModal",
        getStrFormula : "getStrFormula"
    }),
    ...mapGetters("mst-exam-matome", ["getSelectedMstExamMatome"]),
    ...mapGetters("user", ["getFacilityCd"]),
    jlac10Cds() {
      return this.comboJlac10Cd;
    }
  },
  watch: {
    inputModel: {
      handler(newVal) {
        this.editRecordClone["name"] = newVal.exam_item_name;
        if(!newVal.exam_item_name) this.inputModel.exam_item_name = "";
        this.editRecordClone["dataType"] = newVal.data_type;
        this.editRecordClone["unit"] = newVal.unit;
        this.editRecordClone["normalValueClass"] = newVal.normal_value_class;
        this.editRecordClone["normalValueUpper"] = newVal.normal_value_upper;
        this.editRecordClone["normalValueLower"] = newVal.normal_value_lower;
        this.editRecordClone["normalValueUpperM"] = newVal.normal_value_upper_m;
        this.editRecordClone["normalValueLowerM"] = newVal.normal_value_lower_m;
        this.editRecordClone["normalValueUpperW"] = newVal.normal_value_upper_w;
        this.editRecordClone["normalValueLowerW"] = newVal.normal_value_lower_w;
        this.editRecordClone["inputIntegerFigure"] = newVal.input_integer_figure;
        this.editRecordClone["inputDecimalFigure"] = newVal.input_decimal_figure;
        this.editRecordClone["inputUpper"] = newVal.input_upper;
        this.editRecordClone["inputLower"] = newVal.input_lower;
        this.editRecordClone["graphUpper"] = newVal.graph_upper;
        this.editRecordClone["graphLower"] = newVal.graph_lower;
        this.editRecordClone["consoleClass"] = newVal.console_class;
        this.editRecordClone["examClass"] = newVal.exam_class;
        this.editRecordClone["inHospitalCd1"] = newVal.in_hospital_cd1;
        this.editRecordClone["sbtCd1"] = newVal.sbt_cd1;
        this.editRecordClone["inHospitalCd2"] = newVal.in_hospital_cd2;
        this.editRecordClone["sbtCd2"] = newVal.sbt_cd2;
        this.editRecordClone["inHospitalCd3"] = newVal.in_hospital_cd3;
        this.editRecordClone["sbtCd3"] = newVal.sbt_cd3;
        this.editRecordClone["spitzCd"] = newVal.spitz_cd;
        this.editRecordClone["isInHospital"] = newVal.is_in_hospital;
        this.editRecordClone["jlac10Cd"] = newVal.jlac10_cd;
        this.editRecordClone["infectionCd"] = newVal.infection_cd;
        this.editRecordClone["defaultCalcExamItemCd"] = newVal.default_calc_exam_item_cd;
        this.editRecordClone["dialysisProgressFlag"] = newVal.dialysis_progress_flag;
        this.editRecordClone["freeCalc"] = newVal.exam_calc;
        // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 start
        for(let key in newVal){
          this.handleEditBorderColor(key)
        }
        // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 end
        // this.setEditRecord(this.editRecord);
        // //[確認]ボタンの状態の変更をトリガーします
        if (newVal.unit === "") {
          newVal.unit=null;
        }
        if (newVal.jlac10_cd === "") {
          newVal.jlac10_cd=null;
        }
         if (newVal.in_hospital_cd1 === "") {
          newVal.in_hospital_cd1=null;
        }
         if (newVal.in_hospital_cd2 === "") {
          newVal.in_hospital_cd2=null;
        }
         if (newVal.in_hospital_cd3 === "") {
          newVal.in_hospital_cd3=null;
        }
         if (newVal.sbt_cd1 === "") {
          newVal.sbt_cd1=null;
        }
         if (newVal.sbt_cd2 === "") {
          newVal.sbt_cd2=null;
        }
         if (newVal.sbt_cd3 === "") {
          newVal.sbt_cd3=null;
        }
        newVal.spitz_cd = newVal.spitz_cd.toString()
        EventBus.$emit("mstHolidayRegistered", isEqualWith(newVal, this.initInputModel, customComparator));
      },
      deep: true
    },
    getStrFormula() {
      this.inputModel.exam_calc = this.getStrFormula;
    },
    getIsShowEditFormulaModal() {
      const modalHeader = this.getMasterEditModalHeader();
      if (!modalHeader) {
        return;
      }
      if (this.getIsShowEditFormulaModal){
        modalHeader.style.display="none";
      } else {
        modalHeader.style.display="block";
      }
    },
    comboSpitzIsInHospital:function(){
      let IsInHospital = this.comboSpitzIsInHospital
      if (this.inputModel.spitz_cd === undefined) {
        this.inputModel.spitz_cd = "";
      }
      this.comboSpitzCd = this.comboSpitzCds.filter(a => (a.isInHospital ==IsInHospital || a.isInHospital == "9"));
      let flg = false;
      let spitzCd = this.inputModel.spitz_cd
      this.comboSpitzCd.forEach(item =>{
        if (item.value !== "" && spitzCd.toString() === item.value.toString()) {
          flg = true;
          return true;
        }
      });
      if (flg === false) {
        this.inputModel.spitz_cd = "";
      }
    }
  },
  methods: {
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
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
    getMasterEditModalHeader() {
      const modalContainer = this.$el?.closest?.(".modal-container");
      return Array.from(modalContainer?.children || []).find(element =>
        element.classList?.contains("modal-header")
      ) || null;
    },

    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-exam-item", [
      "setIsShowEditFormulaModal",
      "setStrFormula"
    ]),
    ...mapActions("mst-exam-matome", ["setSearchMstExamMatomeCd"]),
    ...mapActions("multi-sub-modal", ["showMstExamMatomeSearchSubModal"]),
    precision(decPoint, value) {
      let num = parseInt(decPoint);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
    // #10713 小数点以下桁数指定を0～8までにする linjunfeng start
    changeStep(val) {
      this.inputNumberStepValue = val ? Number((Math.pow(10, (0 - Number(val)))).toFixed(Number(val))) : 1;
    },
    handlerInputDecimalFigure(val) {
      if (val >= 0 && val <= 8) {
        this.inputModel.input_decimal_figure = (val == null || val === '') ? null : Number(val);
      } else {
        this.inputModel.input_decimal_figure = val < 0 ? 0 : 8;
      }
      this.changeStep(this.inputModel.input_decimal_figure)
    },
    // #10713 小数点以下桁数指定を0～8までにする linjunfeng end
    //  mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
    // inputNumber(e) {
    inputNumber(e, min, max, name) {
    //  mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
        // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
        const decimalDigits = Math.pow(10, this.inputModel.input_decimal_figure);
        min = Math.ceil(min * decimalDigits) / decimalDigits;
        max = Math.floor(max * decimalDigits) / decimalDigits;
        // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
        // if (e.target.value.length > 1) {
        //   let pointNum = e.target.value.indexOf('.');
        //   if (pointNum > 20 && e.target.value.indexOf('-') < 0)
        //     e.target.value = e.target.value.slice(0,20) + e.target.value.slice(pointNum,e.target.value.length).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        //   if (pointNum > 20 && e.target.value.indexOf('-') < 0)
        //     e.target.value = e.target.value.slice(0,21) + e.target.value.slice(pointNum,e.target.value.length).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        //   if (pointNum > 0 && e.target.value.indexOf('-') >= 0)
        //     e.target.value = e.target.value.slice(0,31).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        //   if (pointNum > 0 && e.target.value.indexOf('-') < 0)
        //      e.target.value = e.target.value.slice(0,30).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        //   if (pointNum < 0 && e.target.value.indexOf('-') >= 0)
        //     e.target.value = e.target.value.slice(0,21);
        //   if (pointNum < 0 && e.target.value.indexOf('-') < 0)
        //     e.target.value = e.target.value.slice(0,20);
        //   if (pointNum == 0 )
        //     e.target.value = e.target.value.slice(0,1);
        // }
        //  mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
        // 数値範囲内かどうかの確認
        if (min !== undefined && max !== undefined) {
          if (e.target.value > max) {
            e.target.value = min;
            this.blurFlg = true
          } else if (e.target.value < min) {
            e.target.value = max;
            this.blurFlg = true
          } else {
            this.blurFlg = false
          }
        }
        // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
        e.target.value = (name === 'input_decimal_figure' || name === 'input_integer_figure') ? e.target.value : Number(e.target.value).toFixed(this.inputModel.input_decimal_figure);
        // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
        //  mod #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
    },
    handleBlur(event, min, max, index){
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
      const decimalDigits = Math.pow(10, this.inputModel.input_decimal_figure);
      min = Math.ceil(min * decimalDigits) / decimalDigits;
      max = Math.floor(max * decimalDigits) / decimalDigits;
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
      if (event.target.value == max && this.blurFlg) {
        event.target.value =  min
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        event.target.value =  max
        this.blurFlg = false
      }
      this.focusFlg[index] = false;
      this.requestViewForceUpdate();
    },
    // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
    handleMouseWheel(e, min, max, step, index) {
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
      const decimalDigits = Math.pow(10, this.inputModel.input_decimal_figure);
      max = Math.floor(max * decimalDigits) / decimalDigits;
      min = Math.ceil(min * decimalDigits) / decimalDigits;
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (step.length > 1) {
        let pointNum = step.indexOf('.');
        if (pointNum > 20 && step.indexOf('-') < 0)
          step = step.slice(0,20) + step.slice(pointNum,step.length).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        if (pointNum > 20 && step.indexOf('-') < 0)
          step = step.slice(0,21) + step.slice(pointNum,step.length).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        if (pointNum > 0 && step.indexOf('-') >= 0)
          step = step.slice(0,31).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        if (pointNum > 0 && step.indexOf('-') < 0)
            step = step.slice(0,30).replace(/^(-)*(\d+)\.(\d\d\d\d\d\d\d\d\d).*$/, '$1$2.$3');
        if (pointNum < 0 && step.indexOf('-') >= 0)
          step = step.slice(0,21);
        if (pointNum < 0 && step.indexOf('-') < 0)
          step = step.slice(0,20);
        if (pointNum == 0)
          step = step.slice(0,1);
      }
      let value = parseFloat(e.target.value);

      const parameterStep = parseFloat(step);
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
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
      e.target.value =  parseFloat(value.toFixed(Number(this.inputModel.input_decimal_figure)))
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
      // #8629 今回正常値、入力範囲、グラフ表示範囲が空白の項目で操作をしているが、値がもともと入っていた場合でも同じ事象が発生する。 林峻峰 start
      if (e.target.value.indexOf('e') > 0)
        e.target.value = parseFloat(e.target.value).toFixed(9)
      if (e.target.value.indexOf('e') > 0 && e.target.value.indexOf('-') == 0)
        e.target.value = "-" + parseFloat(e.target.value.slice(1,e.target.value.length)).toFixed(9)
      // #8629 今回正常値、入力範囲、グラフ表示範囲が空白の項目で操作をしているが、値がもともと入っていた場合でも同じ事象が発生する。 林峻峰 end
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
      if (index === 3) {
        this.inputNumberStepValue = this.inputNumberStepValue ? Number((Math.pow(10, (0 - Number(e.target.value)))).toFixed(Number(e.target.value))) : 1;
        this.inputNumberStepValue = Number(this.inputNumberStepValue)
        this.inputModel.input_decimal_figure = Number(e.target.value)
        this.inputDecimalFigureChange();
      }
      const inputNumberKey = ['normal_value_lower', 'normal_value_upper', 'input_integer_figure', 'input_decimal_figure', 'input_lower', 'input_upper', 'graph_lower', 'graph_upper', 'normal_value_lower_m', 'normal_value_upper_m', 'normal_value_lower_w', 'normal_value_upper_w'];
      this.inputModel[inputNumberKey[index]] = e.target.value
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
    },
    handleFocus(index){
        this.focusFlg[index] = true
    },
    normalizeEditCompareValue(value) {
      if (value === undefined || value === null || value === "") {
        return null;
      }
      return value;
    },
    normalizeEditCompareNumber(value) {
      const normalized = this.normalizeEditCompareValue(value);
      if (normalized === null) {
        return null;
      }
      const num = Number(normalized);
      return Number.isNaN(num) ? normalized : num;
    },
    isNumericEditField(key) {
      return [
        "normal_value_lower",
        "normal_value_upper",
        "normal_value_lower_m",
        "normal_value_upper_m",
        "normal_value_lower_w",
        "normal_value_upper_w",
        "input_integer_figure",
        "input_decimal_figure",
        "input_lower",
        "input_upper",
        "graph_lower",
        "graph_upper",
      ].includes(key);
    },
    isEditFieldChanged(key) {
      let initValue = this.normalizeEditCompareValue(this.initInputModel[key]);
      let editValue = this.normalizeEditCompareValue(this.inputModel[key]);
      if (["formulaId", "default_calc_exam_item_cd"].includes(key)) {
        if (initValue === "0") {
          initValue = null;
        }
        if (editValue === "0") {
          editValue = null;
        }
      }
      if (key === "exam_calc" && initValue === "1") {
        initValue = null;
      }
      if (this.isNumericEditField(key)) {
        return this.normalizeEditCompareNumber(initValue) !== this.normalizeEditCompareNumber(editValue);
      }
      return initValue != editValue;
    },
    resolveEditBorderElement(id) {
      const escapedId = typeof CSS !== "undefined" && typeof CSS.escape === "function"
        ? CSS.escape(id)
        : id;
      return this.getScopedElementById(id)
        || queryScopedSelector(`ons-select[input-id="${id}"] select.select-input`, this)
        || queryScopedSelector(`ons-select[select-id="${id}"] select.select-input`, this)
        || queryScopedSelector(`ons-select select.select-input#${escapedId}`, this);
    },
    applyEditBorder(element, edited) {
      if (!element) {
        return;
      }
      element.style.border = edited ? "2px solid green" : "";
    },
    getInitialProgressFlags() {
      const flag = this.initInputModel.dialysis_progress_flag || "0";
      return {
        flag1: flag === "1" || flag === "3",
        flag2: flag === "2" || flag === "3",
      };
    },
    updateProgressFlagEditedVisual() {
      const init = this.getInitialProgressFlags();
      const flag1El = this.getScopedElementById("progressFlag1-font");
      const flag2El = this.getScopedElementById("progressFlag2-font");
      if (flag1El) {
        flag1El.style.color = this.progressFlag !== init.flag1 ? "green" : "";
      }
      if (flag2El) {
        flag2El.style.color = this.progressFlag2 !== init.flag2 ? "green" : "";
      }
    },
    // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 start
    handleEditBorderColor(key) {
      if (key === "is_in_hospital") {
        return;
      }
      if (["progressFlag1", "progressFlag2"].includes(key)) {
        this.updateProgressFlagEditedVisual();
        return;
      }
      const id = key.replaceAll("_", "-");
      this.applyEditBorder(this.resolveEditBorderElement(id), this.isEditFieldChanged(key));
    },
    // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 end
     /**
     * @description 設定値の小数点桁数算出
     * @param {Number} value 値
     */
     getDecimalPointLength(number){
      var numbers = String(number).split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },
    // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
    inputClick(e) {
      if (e.target.value.indexOf('e') > 0)
        e.target.value = parseFloat(e.target.value).toFixed(9)
      if (e.target.value.indexOf('e') > 0 && e.target.value.indexOf('-') == 0)
        e.target.value = "-" + parseFloat(e.target.value.slice(1,e.target.value.length)).toFixed(9)
    },
    stopScrollFun(e) {
      if (e.target.value.indexOf('e') > 0)
        e.target.value = parseFloat(e.target.value).toFixed(9)
      if (e.target.value.indexOf('e') > 0 && e.target.value.indexOf('-') == 0)
        e.target.value = "-" + parseFloat(e.target.value.slice(1,e.target.value.length)).toFixed(9)
    },
    onSelectDefaultCalc(e){
      // del redmine 6385 検査使用区分をシステム標準計算項目から検査計算項目に変更すると検査計算式領域に入力していない値が入る 宋qy start
      // this.inputModel.exam_calc = this.defaultCalcList[e.target.selectedIndex].formulaId;
      // del redmine 6385 検査使用区分をシステム標準計算項目から検査計算項目に変更すると検査計算式領域に入力していない値が入る 宋qy end
      // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy start
      this.inputModel.exam_item_name = this.defaultCalcList[e.target.selectedIndex].name;
      // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy end
    },
    onSelect() {
      this.setSearchMstExamMatomeCd(this.inputModel.jlac10_cd);
      this.showMstExamMatomeSearchSubModal();
    },
    changeExamClass() {
      /* modify by chamaojia 2023-06-27 【結合テスト】检查项目マスタ_登陆不正  --start */
      this.inputModel.default_calc_exam_item_cd = "0";
      /* modify by chamaojia 2023-06-27 【結合テスト】检查项目マスタ_登陆不正  --end */
      this.inputModel.dialysis_progress_flag ="0";
      // add redmine 6385 検査使用区分をシステム標準計算項目から検査計算項目に変更すると検査計算式領域に入力していない値が入る 宋qy start
      this.inputModel.infection_cd = "";
      this.inputModel.formulaId = "";
      this.inputModel.exam_calc = "";
      // add redmine 6385 検査使用区分をシステム標準計算項目から検査計算項目に変更すると検査計算式領域に入力していない値が入る 宋qy end
    },
    changeInfectionCd() {
      const code = this.inputModel.infection_cd;
      if (!code) return;
      const name = this.comboInfectionCd.find(item => item.value === code)?.text;
      if (!name) return;
      // 選択した感染症の名称を検査項目名に設定する
      this.inputModel.exam_item_name = name;
      this.setCss(this.inputModel.exam_item_name);
    },
    changeProgressFlag(e){
      if (e.target.parentElement.id == "progressFlag1"){
        this.progressFlag = e.target.checked;
        this.handleEditBorderColor('progressFlag1');
      }else{
        this.progressFlag2 = e.target.checked;
        this.handleEditBorderColor('progressFlag2');
      }
      if ( this.progressFlag && this.progressFlag2){
        this.inputModel.dialysis_progress_flag = "3";
      }else if (this.progressFlag2){
        this.inputModel.dialysis_progress_flag = "2";
      }else if (this.progressFlag){
        this.inputModel.dialysis_progress_flag = "1";
      }else{
        this.inputModel.dialysis_progress_flag = "0";
      }
    },
    async dispFormulaEdit(){
      this.setStrFormula(this.inputModel.exam_calc);
      this.setIsShowEditFormulaModal(true);
    },
    validateOnRegistration() {
      let itemNameFalg = true;
      let examItemFalg = true;
      // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy start
      if (this.inputModel.exam_class === "1") {
        this.editRecordClone["defaultCalcExamItemCd"] = this.inputModel.formulaId;
      }
      // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy end
      if (!this.inputModel.exam_item_name) itemNameFalg = false;
      if (this.inputModel.default_calc_exam_item_cd == "0" || !this.inputModel.default_calc_exam_item_cd) {
        this.editRecordClone["dialysisProgressFlag"] = "0";
        // this.setEditRecord(this.editRecord);
      }
      // let that = this;
      if (this.inputModel.default_calc_exam_item_cd != "0")
        this.gridData.forEach(item => {
          if (item.code !=this.editRecord.code && this.inputModel.default_calc_exam_item_cd == item.defaultCalcExamItemCd && item.dialysisProgressFlag != "0" && item.dialysisProgressFlag != "" && item.isDisp !== "0") {
            if (this.inputModel.dialysis_progress_flag == "1" && item.dialysisProgressFlag != "2") examItemFalg = false;
            if (this.inputModel.dialysis_progress_flag == "2" && item.dialysisProgressFlag != "1") examItemFalg = false;
            if (this.inputModel.dialysis_progress_flag == "3" && item.dialysisProgressFlag != "0") examItemFalg = false;
          }
        })

      // mod redmine 6293 同じシステム標準検査が複数登録できる 宋qy start
      let formulaIdFlag = true;
      if (this.inputModel.exam_class === "1") {
        this.gridData.forEach(item => {
          if (item.code !== this.editRecord.code && item.defaultCalcExamItemCd === this.inputModel.formulaId && item.isDisp !== "0" && item.examClass === "1") {
            formulaIdFlag = false;
          }
        })
      }

      // add redmine 6285 システム標準計算検査項目の設定を未登録にできない 宋qy start
      let formulaIdNameFlag = true;
      if (this.inputModel.exam_class === "1") {
        if (!this.inputModel.formulaId || this.inputModel.formulaId === "") formulaIdNameFlag = false;
      }
      // add redmine 6285 システム標準計算検査項目の設定を未登録にできない 宋qy end

      // add redmine 6280 システム標準計算検査項目は、透析前・後どちらかのチェックが必須 宋qy start
      let progress = true;
      if (this.inputModel.exam_class === "0" && this.inputModel.default_calc_exam_item_cd !== "" && this.inputModel.default_calc_exam_item_cd !== "0") {
        if (!(this.progressFlag || this.progressFlag2)) progress = false;
      }
      // add redmine 6280 システム標準計算検査項目の設定を未登録にできない 宋qy end

      if(itemNameFalg && examItemFalg && formulaIdFlag && formulaIdNameFlag && progress) return true;
      // mod redmine 6293 同じシステム標準検査が複数登録できる 宋qy end
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000012].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      // add 全マスタメッセージ調整 王 start
      let message = `
          ${
            !examItemFalg
              // ? "同じな検査項目の透析前、透析後は重複です。<br>"
              ? DIALOG_MESSAGES[12000012].message + "<br>"
              : ""
          }`;

      // add redmine 6293 同じシステム標準検査が複数登録できる 宋qy start
      message = message + `
          ${
        !formulaIdFlag
          // ? "この検査は既に登録されています。<br>"
          ? DIALOG_MESSAGES[12000071].message + "<br>"
          : ""
      }`;
      // add redmine 6293 同じシステム標準検査が複数登録できる 宋qy end

      message =message + `
          ${
            this.inputModel.exam_item_name == ""
              // ? "名称を入力する必要があります。<br>"
              ? DIALOG_MESSAGES[12000013].message + "<br>"
              : ""
          }`;

      // add redmine 6285 システム標準計算検査項目の設定を未登録にできない 宋qy start
      message =message + `
          ${
            !formulaIdNameFlag
              // ? "システム標準検査を入力する必要があります。<br>"
              ? DIALOG_MESSAGES[12000072].message + "<br>"
              : ""
          }`;
      // add redmine 6285 システム標準計算検査項目の設定を未登録にできない 宋qy end

      // add redmine 6280 システム標準計算検査項目は、透析前・後どちらかのチェックが必須 宋qy start
      message =message + `
          ${
        !progress
          // ? "透析前・後を入力する必要があります。<br>"
          ? DIALOG_MESSAGES[12000073].message + "<br>"
          : ""
      }`;
      // add redmine 6280 システム標準計算検査項目は、透析前・後どちらかのチェックが必須 宋qy end

      // add 全マスタメッセージ調整 王 end
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      if (this.inputModel.exam_item_name == "" || this.inputModel.exam_item_name == null) {
        this.getScopedElementsByClassName("input-required")[0]?.classList?.add("input-invalid");
      }
      return false;
    },
    /**
     * 臨床検査マスタ検索モーダルを閉じた時のイベント
     */
    closeSelectMstExamMatome() {
      // 臨床検査マスタ検索未選択の場合
      if (!this.getSelectedMstExamMatome) {
        return;
      }
      // 臨床検査マスタ検索が選択された場合
      const selectedMstExamMatome = this.getSelectedMstExamMatome;
      this.inputModel.jlac10_cd = selectedMstExamMatome.examMatomeCd;
      if (!this.inputModel.exam_item_name || this.inputModel.exam_item_name == "") this.inputModel.exam_item_name = selectedMstExamMatome.analyticalMaterialName;

      if ((!this.inputModel.unit || this.inputModel.unit == "") && selectedMstExamMatome.referenceUnit && selectedMstExamMatome.referenceUnit != "")
      this.inputModel.unit = selectedMstExamMatome.referenceUnit; this.inputModel.data_type = "1";

      if ((!this.inputModel.unit || this.inputModel.unit == "") && (!selectedMstExamMatome.referenceUnit || selectedMstExamMatome.referenceUni == ""))
      this.inputModel.data_type = "0";
    },
    saveNumber(e,name){
      if (e.target.value.indexOf('e') > 0)
        e.target.value = parseFloat(e.target.value).toFixed(9)
      if (e.target.value.indexOf('e') > 0 && e.target.value.indexOf('-') == 0)
        e.target.value = "-" + parseFloat(e.target.value.slice(1,e.target.value.length)).toFixed(9)
      // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
      // this.inputModel[name] = e.target.value;
      this.inputModel[name] = (name === 'input_decimal_figure' || name === 'input_integer_figure') ? e.target.value : Number(e.target.value).toFixed(this.inputModel.input_decimal_figure);
      if (name === 'input_decimal_figure') {
        if (this.inputModel[name] < 0) {
          this.inputModel[name] = 0;
        }
        // #10713 小数点以下桁数指定を0～8までにする linjunfeng start
        // if (this.inputModel[name] > 9) {
        //   this.inputModel[name] = 9;
        // }
        if (this.inputModel[name] > 8) {
          this.inputModel[name] = 8;
        }
        // #10713 小数点以下桁数指定を0～8までにする linjunfeng end
        this.inputNumberStepValue = this.inputNumberStepValue ? Number((Math.pow(10, (0 - this.inputModel.input_decimal_figure))).toFixed(this.inputModel.input_decimal_figure)) : 1;
        if (this.inputNumberStepValue.toString().indexOf('e') > 0)
        this.inputNumberStepValue = parseFloat(this.inputNumberStepValue).toFixed(this.inputModel.input_decimal_figure)
        if (this.inputNumberStepValue.toString().indexOf('e') > 0 && this.inputNumberStepValue.toString().indexOf('-') == 0)
        this.inputNumberStepValue = "-" + parseFloat(this.inputNumberStepValue.slice(1,this.inputNumberStepValue.length)).toFixed(this.inputModel.input_decimal_figure)
        this.inputNumberStepValue = Number(this.inputNumberStepValue)
        this.inputDecimalFigureChange();
      }
    },
    inputDecimalFigureChange(){
      if (this.getScopedElementById('normal-value-lower')) {
        this.getScopedElementById('normal-value-lower').value = this.inputModel.normal_value_lower = this.inputModel.normal_value_lower ? Number(this.inputModel.normal_value_lower).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.normal_value_lower;
      }
      if (this.getScopedElementById('normal-value-upper')) {
        this.getScopedElementById('normal-value-upper').value = this.inputModel.normal_value_upper = this.inputModel.normal_value_upper ? Number(this.inputModel.normal_value_upper).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.normal_value_upper;
      }
      if (this.getScopedElementById('normal-value-lower-m')) {
        this.getScopedElementById('normal-value-lower-m').value = this.inputModel.normal_value_lower_m = this.inputModel.normal_value_lower_m ? Number(this.inputModel.normal_value_lower_m).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.normal_value_lower_m;
      }
      if (this.getScopedElementById('normal-value-upper-m')) {
        this.getScopedElementById('normal-value-upper-m').value = this.inputModel.normal_value_upper_m = this.inputModel.normal_value_upper_m ? Number(this.inputModel.normal_value_upper_m).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.normal_value_upper_m;
      }
      if (this.getScopedElementById('normal-value-lower-w')) {
        this.getScopedElementById('normal-value-lower-w').value = this.inputModel.normal_value_lower_w = this.inputModel.normal_value_lower_w ? Number(this.inputModel.normal_value_lower_w).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.normal_value_lower_w;
      }
      if (this.getScopedElementById('normal-value-upper-w')) {
        this.getScopedElementById('normal-value-upper-w').value = this.inputModel.normal_value_upper_w = this.inputModel.normal_value_upper_w ? Number(this.inputModel.normal_value_upper_w).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.normal_value_upper_w;
      }
      if (this.getScopedElementById('input-lower')) {
        this.getScopedElementById('input-lower').value = this.inputModel.input_lower = this.inputModel.input_lower ? Number(this.inputModel.input_lower).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.input_lower;
      }
      if (this.getScopedElementById('input-upper')) {
        this.getScopedElementById('input-upper').value = this.inputModel.input_upper = this.inputModel.input_upper ? Number(this.inputModel.input_upper).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.input_upper;
      }
      if (this.getScopedElementById('graph-lower')) {
        this.getScopedElementById('graph-lower').value = this.inputModel.graph_lower = this.inputModel.graph_lower ? Number(this.inputModel.graph_lower).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.graph_lower;
      }
      if (this.getScopedElementById('graph-upper')) {
        this.getScopedElementById('graph-upper').value = this.inputModel.graph_upper = this.inputModel.graph_upper ? Number(this.inputModel.graph_upper).toFixed(this.inputModel.input_decimal_figure) : this.inputModel.graph_upper;
      }
    },
    // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
    setCss(value) {
      if(value && this.getScopedElementsByClassName("input-invalid")[0])
        this.getScopedElementsByClassName("input-invalid")[0].classList.remove("input-invalid");
    },
  },
  async created() {
    this.editRecordClone = cloneDeep(this.editRecord);
    // 新規作成かつ初回入力時フラグ(operationが1で選択項目の値が未設定)
    let firstSetFlg = false;
    if(this.editRecord["operation"] === 1 && this.editRecord["normalValueClass"] === ""){
      firstSetFlg = true;
    }
    // 選択したデータを画面表示用に変数へ代入
    this.inputModel.exam_item_name = this.editRecord["name"];
    this.inputModel.data_type = firstSetFlg ? "1" : this.editRecord["dataType"];
    this.inputModel.unit = this.editRecord["unit"];
    this.inputModel.normal_value_class = firstSetFlg ? "0" : this.editRecord["normalValueClass"];
    this.inputModel.normal_value_upper = firstSetFlg ? "" : this.editRecord["normalValueUpper"];
    this.inputModel.normal_value_lower = firstSetFlg ? "" : this.editRecord["normalValueLower"];
    this.inputModel.normal_value_upper_m = firstSetFlg ? "" : this.editRecord["normalValueUpperM"];
    this.inputModel.normal_value_lower_m = firstSetFlg ? "" : this.editRecord["normalValueLowerM"];
    this.inputModel.normal_value_upper_w = firstSetFlg ? "" : this.editRecord["normalValueUpperW"];
    this.inputModel.normal_value_lower_w = firstSetFlg ? "" : this.editRecord["normalValueLowerW"];
    this.inputModel.input_integer_figure = firstSetFlg ? "" : this.editRecord["inputIntegerFigure"];
    this.inputModel.input_decimal_figure = firstSetFlg ? "" : this.editRecord["inputDecimalFigure"];
    this.inputModel.input_upper = firstSetFlg ? "" : this.editRecord["inputUpper"];
    this.inputModel.input_lower = firstSetFlg ? "" : this.editRecord["inputLower"];
    this.inputModel.graph_upper = firstSetFlg ? "" : this.editRecord["graphUpper"];
    this.inputModel.graph_lower = firstSetFlg ? "" : this.editRecord["graphLower"];
    this.inputModel.console_class = firstSetFlg ? "0" : this.editRecord["consoleClass"];
    this.inputModel.exam_class = firstSetFlg ? "0" : this.editRecord["examClass"];
    this.inputModel.in_hospital_cd1 = this.editRecord["inHospitalCd1"];
    this.inputModel.sbt_cd1 = this.editRecord["sbtCd1"];
    this.inputModel.in_hospital_cd2 = this.editRecord["inHospitalCd2"];
    this.inputModel.sbt_cd2 = this.editRecord["sbtCd2"];
    this.inputModel.in_hospital_cd3 = this.editRecord["inHospitalCd3"];
    this.inputModel.sbt_cd3 = this.editRecord["sbtCd3"];
    this.inputModel.spitz_cd = this.editRecord["spitzCd"];
    this.inputModel.is_in_hospital = this.editRecord?.["isInHospital"] || 0;
    this.inputModel.jlac10_cd = this.editRecord["jlac10Cd"];
    this.inputModel.infection_cd = this.editRecord["infectionCd"];
    /* modify by chamaojia 2023-06-27 【結合テスト】检查项目マスタ_登陆不正  --start */
    if (this.editRecord["defaultCalcExamItemCd"]) {
      this.inputModel.default_calc_exam_item_cd = this.editRecord["defaultCalcExamItemCd"];
    } else {
      this.inputModel.default_calc_exam_item_cd = "0";
    }
    /* modify by chamaojia 2023-06-27 【結合テスト】检查项目マスタ_登陆不正  --end */
    // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy start
    this.inputModel.formulaId = this.editRecord["defaultCalcExamItemCd"];
    // add redmine 5992 検査項目名を修正するとシステム標準検査欄が空白になる 宋qy end
    this.inputModel.dialysis_progress_flag = this.editRecord["dialysisProgressFlag"] || "0";
    this.inputModel.exam_calc = this.editRecord["freeCalc"];

    // 正常値範囲を退避させる
    this.inputNumberValue.upper = this.inputModel.normal_value_upper;
    this.inputNumberValue.lower = this.inputModel.normal_value_lower;
    this.inputNumberValue.upper_m = this.inputModel.normal_value_upper_m;
    this.inputNumberValue.lower_m = this.inputModel.normal_value_lower_m;
    this.inputNumberValue.upper_w = this.inputModel.normal_value_upper_w;
    this.inputNumberValue.lower_w = this.inputModel.normal_value_lower_w;
    this.inputNumberValue.in_upper = this.inputModel.input_upper;
    this.inputNumberValue.in_lower = this.inputModel.input_lower;
    this.inputNumberValue.graph_upper = this.inputModel.graph_upper;
    this.inputNumberValue.graph_lower = this.inputModel.graph_lower;
    // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 start
    this.inputNumberStepValue = Number((Math.pow(10, (0 - this.inputModel.input_decimal_figure))).toFixed(this.inputModel.input_decimal_figure))
    // add #8629 テキストボックス内の上下ボタン、マウスホイールによる数値変更の動作不正 林峻峰 end
    // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 start
    this.initInputModel = JSON.parse(JSON.stringify(this.inputModel))
    // #8629 編集を行った項目が緑枠にならない。修正 林峻峰 end
    // 選択リストのデータはsys_master_defineで定義したものを取得
    // データ形式
    let combo1 = this.columns.find((column) => {
      return (column.field === 'dataType');
    });
    this.comboDataType = combo1.values;
    // 正常値区分
    combo1 = this.columns.find((column) => {
      return (column.field === 'normalValueClass');
    });
    this.comboNormalValueClass = combo1.values;
    // 仮想端末表示対象区分
    combo1 = this.columns.find((column) => {
      return (column.field === 'consoleClass');
    });
    this.comboConsoleClass = combo1.values;
    // 検査使用区分
    combo1 = this.columns.find((column) => {
      return (column.field === 'examClass');
    });
    // mod #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end
    // this.comboSpitzInHospitals = [{ value: 0, text: "院内" }, { value: 1, text: "院外" }];
    this.comboSpitzInHospitals = [{ value: 0, text: "院外" }, { value: 1, text: "院内" }];
    // mod #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end
    this.comboExamClass = combo1.values;
    // 採血管コード
    let masterName1 = "mst_spitz";
    let spitz_cd = this.inputModel.spitz_cd
    let isInHospital = 0;
      await Promise.all([
      // JLAC10ｺｰﾄﾞ
      // add マスタ一覧 施設切替を可能とする 王 start
      // ApiHelper.get(`/master_maintenance/${masterName1}/data/${this.getFacilityCd}`).then(response => {
      ApiHelper.get(`/master_maintenance/${masterName1}/data/${this.getFacilitySwitch}`).then(response => {
      // add マスタ一覧 施設切替を可能とする 王 end
        // add #8962 【デグレ】検査項目の採血管を未登録にできない 商 start
        this.comboSpitzCds = [{ value: "", text: "未登録", isInHospital: "9"}];
        // add #8962 【デグレ】検査項目の採血管を未登録にできない 商 end
        if(response.data) {
          response.data.localDataSource.data.forEach(element => {
            // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen start
            if (spitz_cd == "") {
              isInHospital = 0;
            } else
            // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end
            if (element.code == spitz_cd){
              isInHospital = element.isInHospital;
            }
            if (element.isDisp == "1"){
              this.comboSpitzCds.push({
                value: element.code,
                text: element.name,
                isInHospital:element.isInHospital
              });
            }
          });
        }
        this.comboSpitzCd = this.comboSpitzCds;
      })
    ])
    .catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MstExamItemMainModalComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      throw error;
    });
    this.comboSpitzIsInHospital = isInHospital;
    // JLCA10コード
    // TODO マスタが存在しないので仮の値を入れておく.
    // マスタ実装時にはmigrationファイルのcomboカラムも更新する
    //combo1 = this.columns.find((column) => {
    //  return (column.field === 'jlac10Cd');
    //});
    //this.comboJlac10Cd = combo1.values;
    // 感染症コード
    combo1 = this.columns.find((column) => {
      return (column.field === 'infectionCd');
    });
    this.comboInfectionCd = combo1.values;
    // システム標準計算検査項目コード
    combo1 = this.columns.find((column) => {
      return (column.field === 'defaultCalcExamItemCd');
    });
    this.comboDefaultCalcExamItemCd = combo1.values;
    // システム標準検査
    this.defaultCalcList = examItemSystemDefaultCalcList;

    switch (this.inputModel.dialysis_progress_flag) {
      case "1":
        this.progressFlag = true;
        break;
      case "2":
        this.progressFlag2 = true;
      break;
      case "3":
        this.progressFlag = true;
        this.progressFlag2 = true;
      break;
    }
    // 標準医薬品マスタ検索画面が閉じられた時のイベントを登録する.
    EventBus.$on("applyMstExamMatome", this.closeSelectMstExamMatome);

  },
  async mounted() {
    // 縦スクロールバー表示
    let modalObj = this.getScopedElementsByClassName("modal-body");
    if (modalObj.length >= 1){
      modalObj[0].classList.remove("modal-overflow-hidden");
      modalObj[0]?.classList?.add("modal-scroll");
    }
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("applyMstExamMatome", this.closeSelectMstExamMatome);
  },
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
#exam-item-modal-content {
  padding-left: 20px;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
table {
  max-width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}
table thead {
  color: #ffffff;
  background-color: #3f3f3f;
}
table thead tr {
  height: 25px;
}
table tr {
  border-bottom: 1px solid #bbb;
}
.input-row {
  margin-bottom: 5px;
}
.input-item-name {
  margin-top: 10px;
  max-width: 20%;
}
.input-item-txt {
  max-width: 20%;
}
.input-item-txt-long {
  max-width: 70%;
}
.input-item-button {
  max-width: 10%;
}
.input-item-num {
  /*mod redmine 4921 正常範囲や制す部などのテキストボックスが大きすぎる 宋qy start*/
  max-width: 20%;
  /*mod redmine 4921 正常範囲や制す部などのテキストボックスが大きすぎる 宋qy end*/
}
.input-item-hyphen {
  max-width: 10%;
  text-align: center;
}
.input-item-decimal {
  font-weight: bold;
  margin-top: 10px;
  text-align: center;
  max-width: 10%;
}
.td-txt {
  min-width: 4em;
  padding: 5px;
}

.td-lbl-hosp-sbt {
  font-weight: bold;
  min-width: 7em;
  max-width: 20%;
}
.table-inhosp {
  max-width: 40%;
}
.table-sbt {
  max-width: 40%;
}
#formulaEdit{
  padding: 0.2em 1em 0em 1em;
  margin-left: 10%;
  width: 5em;
}
.edit-exam-formula-wrapper {
  z-index: 2;
}
@media screen and (max-width: 1024px) {
  .input-item-name {
    text-align: left;
    margin-bottom: 5px;
    min-width: 90%;
  }
  .input-item-decimal {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 90%;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-txt-long {
    text-align: left;
    min-width: 90%;
  }
  .input-item-button {
    text-align: left;
    min-width: 90%;
  }
  #formulaEdit{
    padding: 0.2em 1em 0em 1em;
    margin: 0.2em 0em 0em 0em;
    width: 5em;
  }
  .input-item-num {
    min-width: 40%;
  }
  .input-item-margin {
    display: none;
  }
  .table-inhosp {
    min-width: 90%;
  }
  .table-sbt {
    min-width: 90%;
  }
}

.input-required :deep(input) {
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(input) {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
</style>
