/**
* 装置マスタモーダル
*/
<template>
  <div id="machine-modal-content">
    <!-- 基本設定 -->
    <div class="machine-setting">
      <v-ons-row class="input-row-header">
        <v-ons-col class="input-item-name">
          <label>基本設定</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="machine-name">装置名</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="machine-name"
            class="custom-input-required"
            maxlength="40"
            :class="handleJudgeEdited(inputModel.machine_name, 'machine_name')"
            @input="changeColor($event)"
            v-model="inputModel.machine_name">
          </v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="machine-serial">製造番号</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            :disabled="isUsingMachine"
            type="text"
            input-id="machine-serial"
            class="custom-input-required"
            maxlength="8"
            pattern="^[0-9A-Za-z]+$"
            :class="handleJudgeEdited(inputModel.machine_serial, 'machine_serial')"
            @input="changeColor($event)"
            v-model="inputModel.machine_serial">
          </v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="machine-type-cd">型式</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            :disabled="isUsingMachine"
            select-id="machine-type-cd"
            class="custom-select-required"
            v-model="inputModel.machine_type_cd"
            :class="handleJudgeEdited(inputModel.machine_type_cd, 'machine_type_cd')"
            @input="changeColor($event)"
            name="machine-type-cd">
            <option v-for="(item, index) in comboMachineType" :key="index" :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="version">バージョン</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="version"
            maxlength="20"
            :class="handleJudgeEdited(inputModel.version, 'version')"
            v-model="inputModel.version">
          </v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="com-type">通信種別</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            :disabled="isUsingMachine"
            select-id="com-type"
            v-model="inputModel.com_type"
            :class="handleJudgeEdited(inputModel.com_type, 'com_type')"
            name="com-type">
            <option v-for="(item, index) in comboComType" :key="index" :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="com-format-cd">通信フォーマット</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            :disabled="isUsingMachine"
            select-id="com-format-cd"
            v-model="inputModel.com_format_cd"
            :class="handleJudgeEdited(inputModel.com_format_cd, 'com_format_cd')"
            name="com-format-cd">
            <option
              v-for="(item, index) in comboComFormatType"
              :key="index"
              :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="ip-address">IPアドレス</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            :disabled="isUsingMachine"
            type="text"
            input-id="ip-address"
            maxlength="15"
            pattern="^\d{1,3}(\.\d{1,3}){3}$"
            :class="handleJudgeEdited(inputModel.ip_address, 'ip_address')"
            @input="changeColor($event)"
            v-model="inputModel.ip_address">
          </v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="port">ポート番号</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            :disabled="isUsingMachine"
            type="number"
            input-id="port"
            maxlength="5"
            step="1"
            min="0"
            max="65535"
            :class="handleJudgeEdited(inputModel.port, 'port')"
            @input="changeColor($event)"
            v-model="inputModel.port">
          </v-ons-input> -->
          <v-ons-input
            :disabled="isUsingMachine"
            type="number"
            input-id="port"
            maxlength="5"
            step="1"
            :class="handleJudgeEdited(inputModel.port, 'port')"
            @change="changeColor($event, true, '0', '65535')"
            @blur="formatValue($event, 0, '0', '65535')"
            @focus="handleFocus(0)"
            @mousewheel.prevent="stopScrollFun($event, 'port', '0', '65535', 0)"
            onKeypress="return (/[\d]/.test(String.fromCharCode(event.keyCode)))"
            v-model="inputModel.port">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="device-edge-no">デバイスエッジ</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            :disabled="isUsingMachine"
            select-id="device-edge-no"
            v-model="inputModel.device_edge_no"
            :class="handleJudgeEdited(inputModel.device_edge_no, 'device_edge_no')"
            name="device-edge-no">
            <option v-for="(item, index) in comboDeviceEdge" :key="index" :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="is-ftp">データ収集実施</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            select-id="is-ftp"
            v-model="inputModel.is_ftp"
            :class="handleJudgeEdited(inputModel.is_ftp, 'is_ftp')"
            name="is-ftp">
            <option v-for="(item, index) in comboIsFtp" :key="index" :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row" v-if="!isRemsOnly">
        <v-ons-col class="input-item-name">
          <label for="is-va">装置ビューア使用</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            select-id="is-va"
            v-model="inputModel.is_va"
            :class="handleJudgeEdited(inputModel.is_va, 'is_va')"
            name="is-va">
            <option v-for="(item, index) in comboIsVa" :key="index" :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- 通信系アプリ系作業内容確認一覧 王 start      -->
      <v-ons-row v-if="is_pur_show" class="input-row">
        <!-- #9265 装置マスタ詳細の装置モードでHDの文字を押下すると特殊浄化通信アプリで使用がON/OFFされる start      -->
        <!--<v-ons-checkbox
          style="margin-top: 9px; min-width: 22px"
          input-id="is-support-hd"
          v-model="inputModel.is_blood_purify_use">
        </v-ons-checkbox>-->
        <v-ons-checkbox
          style="margin-top: 9px; min-width: 22px"
          input-id="is-pur"
          v-model="inputModel.is_blood_purify_use">
        </v-ons-checkbox>
        <!-- #9265 装置マスタ詳細の装置モードでHDの文字を押下すると特殊浄化通信アプリで使用がON/OFFされる End      -->
        <v-ons-col style="min-width: 251px" class="input-item-name">
          <label for="is-pur">特殊浄化通信アプリで使用</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-select
            v-bind:disabled="!inputModel.is_blood_purify_use"
            select-id="is_blood_purify_use"
            v-model="inputModel.blood_purify_type"
            :class="handleJudgeEdited(inputModel.blood_purify_type, 'blood_purify_type')"
            name="is-pur">
            <option v-for="(item, index) in comboIsPur" :key="index" :value="item.value">
              {{ item.text }}
            </option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- add 通信系アプリ系作業内容確認一覧 王 end     -->
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="setting-date">設置日</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt flex-align-center">
          <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
          <!-- <v-ons-input
            class="ntss-input-date ntss-control-size"
            type="date"
            min='1880-01-01'
            max='2099-12-31'
            style="width: auto;"
            id="setting-date"
            :class="handleJudgeEdited(inputModel.setting_date, 'setting_date')"
            v-model="inputModel.setting_date"
            clearable="true"
          /> -->
          <date-input
            :classes="'ntss-input-date ntss-control-size'"
            min='1880-01-01'
            max='2099-12-31'
            style="width: auto;"
            id="setting-date"
            :class="handleJudgeEdited(inputModel.setting_date, 'setting_date')"
            v-model="inputModel.setting_date"
            @handleClearInput="inputModel.setting_date = null"
            clearable="true"
            :default-date="defaultDate"
          />
          <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
          <common-calendar v-model="inputModel.setting_date" />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="in-hospital-cd-1">連携コード1</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="in-hospital-cd-1"
            maxlength="20"
            :class="handleJudgeEdited(inputModel.in_hospital_cd_1, 'in_hospital_cd_1')"
            v-model="inputModel.in_hospital_cd_1">
          </v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="in-hospital-cd-2">連携コード2</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
          <v-ons-input
            type="text"
            input-id="in-hospital-cd-2"
            maxlength="20"
            :class="handleJudgeEdited(inputModel.in_hospital_cd_2, 'in_hospital_cd_2')"
            v-model="inputModel.in_hospital_cd_2">
          </v-ons-input>
        </v-ons-col>
      </v-ons-row>
    </div>

    <!-- 装置モード -->
    <div
      class="machine-setting"
      v-if="dispExtraFields && !isRemsOnly">
      <v-ons-row class="input-row-header">
        <v-ons-col class="input-item-name">
          <label>装置モード</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-hd"
            v-model="inputModel.is_support_hd">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-hd">HD</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-ecum"
            v-model="inputModel.is_support_ecum">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-ecum">ECUM</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-hdf"
            v-model="inputModel.is_support_hdf">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-hdf">HDF</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-hf"
            v-model="inputModel.is_support_hf">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-hf">HF</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-hd-ho"
            v-model="inputModel.is_support_hd_ho">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-hd-ho">HD＋補液</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-ecum-ho"
            v-model="inputModel.is_support_ecum_ho">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-ecum-ho">ECUM＋補液</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-afbf"
            v-model="inputModel.is_support_afbf">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-afbf">AFBF</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-ohdf"
            v-model="inputModel.is_support_ohdf">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-ohdf">OHDF</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-ohf"
            v-model="inputModel.is_support_ohf">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-ohf">OHF</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-i-hdf"
            v-model="inputModel.is_support_i_hdf">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-i-hdf">I-HDF</label>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-check">
          <v-ons-checkbox
            input-id="is-support-blood-purify"
            v-model="inputModel.is_support_blood_purify">
          </v-ons-checkbox>
        </v-ons-col>
        <v-ons-col class="input-item-check-name">
          <label for="is-support-blood-purify">特殊浄化</label>
        </v-ons-col>
      </v-ons-row>
    </div>

    <!-- TMPゼロ補正中点 -->
    <div
      class="machine-setting"
      v-if="dispExtraFields && !isRemsOnly">
      <v-ons-row class="input-row-header">
        <v-ons-col class="input-item-name">
          <label>TMPゼロ補正中点</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-hd">HD</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
        <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
         <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-hd"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_hd, 'tmp_center_hd')"
            v-model="inputModel.tmp_center_hd">
          </v-ons-input> -->
          <v-ons-input
            type="number"
            input-id="tmp-center-hd"
            step="1"
            @change="changeColor($event,true)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_hd','','', 1)"
            @blur="formatValue($event, 1)"
            @focus="handleFocus(1)"
            :class="handleJudgeEdited(inputModel.tmp_center_hd, 'tmp_center_hd')"
            v-model="inputModel.tmp_center_hd">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
        <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-ecum">ECUM</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-ecum"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_ecum, 'tmp_center_ecum')"
            v-model="inputModel.tmp_center_ecum">
          </v-ons-input> -->
           <v-ons-input
            type="number"
            input-id="tmp-center-ecum"
            step="1"
            @change="changeColor($event,true)"
            @blur="formatValue($event, 2)"
            @focus="handleFocus(2)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_ecum','','', 2)"
            :class="handleJudgeEdited(inputModel.tmp_center_ecum, 'tmp_center_ecum')"
            v-model="inputModel.tmp_center_ecum">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-hdf">HDF</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-hdf"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_hdf, 'tmp_center_hdf')"
            v-model="inputModel.tmp_center_hdf">
          </v-ons-input> -->
           <v-ons-input
            type="number"
            input-id="tmp-center-hdf"
            step="1"
            @change="changeColor($event,true)"
            @blur="formatValue($event, 3)"
            @focus="handleFocus(3)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_hdf','','', 3)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_hdf, 'tmp_center_hdf')"
            v-model="inputModel.tmp_center_hdf">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-hf">HF</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-hf"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_hf, 'tmp_center_hf')"
            v-model="inputModel.tmp_center_hf">
          </v-ons-input> -->
          <v-ons-input
            type="number"
            input-id="tmp-center-hf"
            step="1"
            @change="changeColor($event,true)"
            @blur="formatValue($event, 4)"
            @focus="handleFocus(4)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_hf','','', 4)"
            :class="handleJudgeEdited(inputModel.tmp_center_hf, 'tmp_center_hf')"
            v-model="inputModel.tmp_center_hf">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-hd-ho">HD+補液</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-hd-ho"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_hd_ho, 'tmp_center_hd_ho')"
            v-model="inputModel.tmp_center_hd_ho">
          </v-ons-input> -->
          <v-ons-input
            type="number"
            input-id="tmp-center-hd-ho"
            step="1"
            @change="changeColor($event,true)"
            @blur="formatValue($event, 5)"
            @focus="handleFocus(5)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_hd_ho','','', 5)"
            :class="handleJudgeEdited(inputModel.tmp_center_hd_ho, 'tmp_center_hd_ho')"
            v-model="inputModel.tmp_center_hd_ho">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-ohdf">OHDF</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-ohdf"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_ohdf, 'tmp_center_ohdf')"
            v-model="inputModel.tmp_center_ohdf">
          </v-ons-input> -->
           <v-ons-input
            type="number"
            input-id="tmp-center-ohdf"
            step="1"
            @change="changeColor($event,true)"
            @blur="formatValue($event, 6)"
            @focus="handleFocus(6)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_ohdf','','', 6)"
            :class="handleJudgeEdited(inputModel.tmp_center_ohdf, 'tmp_center_ohdf')"
            v-model="inputModel.tmp_center_ohdf">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label for="tmp-center-ohf">OHF</label>
        </v-ons-col>
        <v-ons-col class="input-item-num">
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy start -->
           <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
          <!-- <v-ons-input
            type="number"
            input-id="tmp-center-ohf"
            step="1"
            min="-200"
            max="200"
            @input="changeColor($event)"
            @mousewheel="stopScrollFun($event)"
            @DOMMouseScroll="stopScrollFun($event)"
            :class="handleJudgeEdited(inputModel.tmp_center_ohf, 'tmp_center_ohf')"
            v-model="inputModel.tmp_center_ohf">
          </v-ons-input> -->
          <v-ons-input
            type="number"
            input-id="tmp-center-ohf"
            step="1"
            @change="changeColor($event,true)"
            @blur="formatValue($event, 7)"
            @focus="handleFocus(7)"
            @mousewheel.prevent="stopScrollFun($event, 'tmp_center_ohf','','', 7)"
            :class="handleJudgeEdited(inputModel.tmp_center_ohf, 'tmp_center_ohf')"
            v-model="inputModel.tmp_center_ohf">
          </v-ons-input>
          <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
          <!-- mod redmine 4519 TMPゼロ補正中点がホイールによるピックアップダウンができない 宋qy end -->
        </v-ons-col>
      </v-ons-row>

    </div>

    <div class="machine-option" v-if="dispExtraFields && !isRemsOnly">
      <v-ons-row>
        <v-ons-row class="input-row-header">
          <v-ons-col class="input-item-name">
            <label>オプション</label>
          </v-ons-col>
          <v-ons-col class="input-item-txt">
          </v-ons-col>
        </v-ons-row>
        <v-ons-col class="table-option">
          <!-- オプション -->
          <table>
            <thead>
            </thead>
            <tbody>
            <tr>
              <td class="td-lbl">HDF/HF</td>
              <td class="td-txt">{{ option.opt_1_1 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">サンプリングポート</td>
              <td class="td-txt">{{ option.opt_1_2 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">透析液フィルタ種類</td>
              <td class="td-txt">{{ option.opt_1_3 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">レベル調整ポンプ</td>
              <td class="td-txt">{{ option.opt_1_4 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">血圧計</td>
              <td class="td-txt">{{ option.opt_1_6 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">ブラッドボリューム計</td>
              <td class="td-txt">{{ option.opt_1_8 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">透析量モニタ</td>
              <td class="td-txt">{{ option.opt_1_9 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">BVplus</td>
              <td class="td-txt">{{ option.opt_1_10 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">通信</td>
              <td class="td-txt">{{ option.opt_1_11 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">自動プライミング</td>
              <td class="td-txt">{{ option.opt_1_12 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">血液ポンプ（右回転）</td>
              <td class="td-txt">{{ option.opt_1_13 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">クリップ式気泡検出器</td>
              <td class="td-txt">{{ option.opt_1_14 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">ダイアライザ入口圧</td>
              <td class="td-txt">{{ option.opt_1_15 === "1" ? "○" : " " }}</td>
            </tr>
            </tbody>
          </table>
        </v-ons-col>
        <v-ons-col class="table-option">
          <!-- オプション -->
          <table>
            <thead>
            </thead>
            <tbody>
            <tr>
              <td class="td-lbl">シングルポンプシングルニードル</td>
              <td class="td-txt">{{ option.opt_2_0 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">熱交換器</td>
              <td class="td-txt">{{ option.opt_2_1 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">循環電磁弁</td>
              <td class="td-txt">{{ option.opt_2_2 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">ＣＦ使用選択</td>
              <td class="td-txt">{{ option.opt_2_3 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">ＣＦ２</td>
              <td class="td-txt">{{ option.opt_2_5 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">補液ポンプ</td>
              <td class="td-txt">{{ option.opt_2_7 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">増設補液ハンガー</td>
              <td class="td-txt">{{ option.opt_2_8 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">熱湯薬液消毒補助ヒータユニット</td>
              <td class="td-txt">{{ option.opt_2_9 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">CFカード</td>
              <td class="td-txt">{{ option.opt_2_10 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">オンライン補充液（透析液）</td>
              <td class="td-txt">{{ option.opt_2_11 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">透析量プログラム</td>
              <td class="td-txt">{{ option.opt_2_12 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">D-FAS</td>
              <td class="td-txt">{{ option.opt_2_13 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">アクセス再循環</td>
              <td class="td-txt">{{ option.opt_2_14 === "1" ? "○" : " " }}</td>
            </tr>
            </tbody>
          </table>
        </v-ons-col>
        <v-ons-col class="table-option">
          <!-- オプション -->
          <table>
            <thead>
            </thead>
            <tbody>
            <tr>
              <td class="td-lbl">Ｂ原液ノズル洗浄ユニット</td>
              <td class="td-txt">{{ option.opt_3_1 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">Ａ原液ノズル洗浄</td>
              <td class="td-txt">{{ option.opt_3_4 === "1" ? "○" : " " }}</td>
            </tr>
            <tr>
              <td class="td-lbl">Ｎａ注入</td>
              <td class="td-txt">{{ option.opt_3_5 === "1" ? "○" : " " }}</td>
            </tr>
            <!-- #11124 2025.07.30 add 酸素飽和度対応 TDC高村 start -->
            <tr>
              <td class="td-lbl">ΔSO2使用選択</td>
              <td class="td-txt">{{ option.opt_3_6 === "1" ? "○" : " " }}</td>
            </tr>
            <!-- #11124 2025.07.30 add 酸素飽和度対応 TDC高村 end -->
            <tr>
              <td class="td-lbl">BV除水制御</td>
              <td class="td-txt">{{ option.opt_3_7 === "1" ? "○" : " " }}</td>
            </tr>
            </tbody>
          </table>
        </v-ons-col>
      </v-ons-row>
    </div>

    <div class="machine-option" v-if="!isRemsOnly">
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-name">
          <label>メモ</label>
        </v-ons-col>
        <v-ons-col class="input-item-txt">
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="input-row">
        <v-ons-col class="input-item-textarea">
          <com-textarea
            :content="inputModel.memo"
            :class="handleJudgeEdited(inputModel.memo, 'memo')"
            cssClass="textarea textarea--transparent textarea-resize-vertical"
            idTextarea="com-textarea-memo"
            propMaxlength="256"
            @set-content-data="setContentData"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import {
  DATE_FORMAT,
  dateFormat,
} from "@/functions/common/DateTimeUtils.js";
import CommonTextArea from "@/components/common/CommonTextArea";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import {sendRequestGetMstFacilityByCd} from "@/apis/facility";
import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
import {EventBus} from "@/eventBus";
import { deepCopy } from "@/functions/common/CommonFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/19 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/19 ×を常に表示するように修正 張博 end
export default {
  components: {
    "common-calendar": commonCalender,
    "com-textarea": CommonTextArea,
    "date-input": DateInput,
  },
  mixins: [MasterMaintenanceMixin],
  name: "mstMachineMainModal",
  data() {
    return {
      inputModel: {
        // 基本設定
        machine_name: "",
        machine_serial: "",
        machine_type_cd: 0,
        version: "",
        com_type: "",
        com_format_cd: "",
        ip_address: "",
        port: 0,
        device_edge_no: 0,
        is_ftp: 0,
        is_va: 0,
        setting_date: "",
        delete_date: "",
        is_disable: false,
        in_hospital_cd_1: "",
        in_hospital_cd_2: "",
        // add 通信系アプリ系作業内容確認一覧 王 start
        is_blood_purify_use: false,
        blood_purify_type: 5,
        // add 通信系アプリ系作業内容確認一覧 王 end
        // 装置モード
        is_support_hd: false,
        is_support_ecum: false,
        is_support_hdf: false,
        is_support_hf: false,
        is_support_hd_ho: false,
        is_support_ecum_ho: false,
        is_support_afbf: false,
        is_support_ohdf: false,
        is_support_ohf: false,
        is_support_i_hdf: false,
        is_support_blood_purify: false,

        // TMPゼロ補正中点
        tmp_center_hd: -30,
        tmp_center_ecum: -65,
        tmp_center_hdf: -30,
        tmp_center_hf: -65,
        tmp_center_hd_ho: -30,
        tmp_center_ohdf: -30,
        tmp_center_ohf: -65,

        // メモ
        memo: ""

      },
      inputModel_clone: {},

      // オプション
      option: "",

      // 装置の施設コード
      machineFacilityCd: "",

      // 装置番号
      machineNo: "",

      // 仮: 型式
      machineTypeModel: "",

      // コンボボックス(DB依存)
      comboMachineType: [],
      comboDeviceEdge: [],
      comboComType: [],
      comboComFormatType: [],

      // コンボボックス(固定)
      comboIsFtp: [
        {value: "0", text: "データ収集しない"},
        {value: "1", text: "データ収集する"}
      ],
      comboIsVa: [
        {value: "0", text: "使用しない"},
        {value: "1", text: "使用する"}
      ],
      // add 通信系アプリ系作業内容確認一覧 王 start
      comboIsPur: [
        {value: "1", text: "ACH-Σ"},
        {value: "2", text: "KM-8900"},
        {value: "3", text: "プラソートiQ21"},
        {value: "4", text: "KM-9000"},
        {value: "5", text: "日機装透析装置"},
      ],
      is_pur_show: false,
      // add 通信系アプリ系作業内容確認一覧 王 end
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start
      min:-200,
      max:200,
      blurFlg:false,
      focusFlg:[false,false,false,false,false,false,false,false],
      // mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      masterName: "getMasterName",
      editRecord: "getEditRecord",
      columns: "getColumns"
    }),
    ...mapGetters("mst-machine", [
      "getMachineTypeList",
      "getDeviceEdgeList",
      "getEditGridData",
      "getSelectedFacilityCd",
      "getEntryMachineList",
      "getIsEditingCode"
    ]),
    ...mapGetters("mst-machine", {
      getFacilitySysUseSetting: "getFacilitySysUseSetting"
    }),
    // 装置モード, TMPゼロ補正中点, オプション の表示フラグ
    dispExtraFields() {
      if (
        this.machineTypeModel === "001" ||
        this.machineTypeModel === "002" ||
        this.machineTypeModel === "003"
      ) {
        return false;
      } else {
        return true;
      }
    },
    // 通信種別 = 通信しない のフラグ
    doNotComunication() {
      if (this.inputModel.com_type === "0") {
        return true;
      } else {
        return false;
      }
    },
    isRemsOnly() {
      return this.getFacilitySysUseSetting === "1";
    },
    /**
     * 条件送信済み～治療中の装置かどうか
     */
    isUsingMachine() {
      const code = this.getIsEditingCode;
      const machines = this.getEntryMachineList;
      if (code && machines && machines.length > 0) {
        const res = machines.filter(m => +m.machineNo === +code);
        return res.length > 0;
      }
      return false;
    },
    defaultDate() {
      return dateFormat.format(new Date(), DATE_FORMAT);
    },
  },
  watch: {
    inputModel: {
      handler(newVal) {
        // 型式コード 変更前の値と異なる場合のみ処理
        if (this.editRecord["machineTypeCd"] !== newVal.machine_type_cd) {
          this.onChangeMachineType(newVal.machine_type_cd);
          this.editRecord["machineTypeCd"] = newVal.machine_type_cd;
          this.$nextTick(() => {
            // 通信種別、通信フォーマットのデフォルト値を変更
            this.resetDataOnChangeMachineType();
          });
        }

        // 通信系の値
        this.editRecord["comFormatCd"] = newVal.com_format_cd;
        this.editRecord["port"] = newVal.port;

        // 通信種別が変化するときの処理
        if (this.editRecord["comType"] !== newVal.com_type) {
          this.onChangeComType();
          this.$nextTick(() => {
            // 通信フォーマットのデフォルト値を変更
            this.setDefaultToComFormatCd();
          });
          // 通信種別によってポート番号を変える
          this.setPort(newVal.com_type);
          // 処理終了後に通信種別変更
          this.editRecord["comType"] = newVal.com_type;
        }

        // その他入力値の反映
        this.editRecord["name"] = newVal.machine_name;
        this.editRecord["machineSerial"] = newVal.machine_serial;
        this.editRecord["version"] = newVal.version;
        this.editRecord["ipAddress"] = newVal.ip_address;
        this.editRecord["deviceEdgeNo"] = newVal.device_edge_no;
        this.editRecord["isFtp"] = newVal.is_ftp;
        this.editRecord["isVa"] = newVal.is_va;
        this.editRecord["settingDate"] = newVal.setting_date;
        this.editRecord["deleteDate"] = newVal.delete_date;
        this.editRecord["inHospitalCd1"] = newVal.in_hospital_cd_1;
        this.editRecord["inHospitalCd2"] = newVal.in_hospital_cd_2;
        // add 通信系アプリ系作業内容確認一覧 王 start
        this.editRecord["isBloodPurifyUse"] = newVal.is_blood_purify_use? "0" : "1";
        this.editRecord["bloodPurifyType"] = newVal.blood_purify_type == 0? "5" : newVal.blood_purify_type;
        // add 通信系アプリ系作業内容確認一覧 王 end

        this.editRecord["tmpCenterHd"] = parseInt(newVal.tmp_center_hd, 10);
        this.editRecord["tmpCenterEcum"] = parseInt(newVal.tmp_center_ecum, 10);
        this.editRecord["tmpCenterHdf"] = parseInt(newVal.tmp_center_hdf, 10);
        this.editRecord["tmpCenterHf"] = parseInt(newVal.tmp_center_hf, 10);
        this.editRecord["tmpCenterHdHo"] = parseInt(newVal.tmp_center_hd_ho, 10);
        this.editRecord["tmpCenterOhdf"] = parseInt(newVal.tmp_center_ohdf, 10);
        this.editRecord["tmpCenterOhf"] = parseInt(newVal.tmp_center_ohf, 10);

        this.editRecord["memo"] = newVal.memo;

        // チェックボックス
        // del redmine 5813 装置マスタ一覧の使用不可の対応忘れ 宋qy start
        //this.editRecord["isDisable"] = newVal.is_disable ? "1" : "0";
        // del redmine 5813 装置マスタ一覧の使用不可の対応忘れ 宋qy end

        this.editRecord["isSupportHd"] = newVal.is_support_hd ? "1" : "0";
        this.editRecord["isSupportEcum"] = newVal.is_support_ecum ? "1" : "0";
        this.editRecord["isSupportHdf"] = newVal.is_support_hdf ? "1" : "0";
        this.editRecord["isSupportHf"] = newVal.is_support_hf ? "1" : "0";
        this.editRecord["isSupportHdHo"] = newVal.is_support_hd_ho ? "1" : "0";
        this.editRecord["isSupportEcumHo"] = newVal.is_support_ecum_ho ? "1" : "0";
        this.editRecord["isSupportAfbf"] = newVal.is_support_afbf ? "1" : "0";
        this.editRecord["isSupportOhdf"] = newVal.is_support_ohdf ? "1" : "0";
        this.editRecord["isSupportOhf"] = newVal.is_support_ohf ? "1" : "0";
        this.editRecord["isSupportIHdf"] = newVal.is_support_i_hdf ? "1" : "0";
        this.editRecord["isSupportBloodPurify"] = newVal.is_support_blood_purify ? "1" : "0";
        //[確認]ボタンの状態の変更をトリガーします
        newVal.tmp_center_hd = Number(newVal.tmp_center_hd)
        newVal.tmp_center_ecum = Number(newVal.tmp_center_ecum)
        newVal.tmp_center_hdf = Number(newVal.tmp_center_hdf)
        newVal.tmp_center_hf = Number(newVal.tmp_center_hf)
        newVal.tmp_center_hd_ho = Number(newVal.tmp_center_hd_ho)
        newVal.tmp_center_ohdf = Number(newVal.tmp_center_ohdf)
        newVal.tmp_center_ohf = Number(newVal.tmp_center_ohf)
        if(JSON.stringify(newVal) !== JSON.stringify(this.inputModel_clone)){
          this.changeButton();
        } else {
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep: true
    },
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    // editRecordから取得
    // 空欄の場合は0を返す
    getSelectByField(field) {
      if (this.editRecord[field] === null || this.editRecord[field] === "") {
        return "";
      } else {
        return this.editRecord[field];
      }
    },
    // editRecordから取得
    // 空欄の場合はデフォルト値を返す
    getSelectByFieldWithDefault(field, defaultVal) {
      if (this.editRecord[field] === null || this.editRecord[field] === "") {
        return defaultVal;
      } else {
        return this.editRecord[field];
      }
    },
    changeColor(e,show,min,max){
      e.target.parentElement.classList.remove("custom-input-invalid");
      e.target.parentElement.classList.remove("input-number-invalid");
      e.target.parentElement.classList.remove("custom-select-invalid");
      //  mod #5589 2023/03/28 数値IFのスタイル全不正 張博 start
        // 数値範囲内かどうかの確認
        if (show===true) {
          const newMax = max ? max : this.max;
          const newMin = min ? min : this.min;
        if (newMin !== undefined && newMax !== undefined) {
          if (Number(e.target.value) > Number(newMax)) {
            e.target.value = newMin;
            this.blurFlg = true;
          } else if (Number(e.target.value) < Number(newMin)) {
            e.target.value = newMax;
            this.blurFlg = true;
          }else{
            this.blurFlg = false;
          }
        }
         }
    },
    stopScrollFun(e, key, min, max,index){
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
       const newMax = max ? max : this.max;
       const newMin = min ? min : this.min;
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > newMax) {
        value = newMin;
      }
      if(value < newMin) {
        value = newMax;
      }
      this.inputModel[key] = value
    },
    formatValue(event,index,min,max){
            // 限界値判定
      let value = event.target.value;
       const newMax = max ? max : this.max;
       const newMin = min ? min : this.min;
      if (value == newMax && this.blurFlg) {
        event.target.value = newMin;
        this.blurFlg = false;
      }else if (value == newMin && this.blurFlg) {
        event.target.value = newMax;
        this.blurFlg = false;
      }
      // #8918装置マスタの詳細画面でポート7000が入力できない 张博 start
       if (newMax==="65535") {
          this.inputModel.port = event.target.value
        }
      // #8918装置マスタの詳細画面でポート7000が入力できない 张博 end
      this.focusFlg[index]=false;
    },
    handleFocus(index){
      this.focusFlg[index]=true;
    },
    //  mod #5589 2023/03/28 数値IFのスタイル全不正 張博 end、
    // String(0:false,1:true)をBoolに変換して取得
    getBoolByField(field) {
      switch (this.editRecord[field]) {
        case "0":
          return false;
        case "1":
          return true;
        default:
          return false;
      }
    },
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    getBoolByField2(field) {
      switch (this.editRecord[field]) {
        case "0":
          return true;
        case 0:
          return true;
        case "1":
          return false;
        case 1:
          return false;
        default:
          return true;
      }
    },
    // 日付のバリデーション
    dateFormatValidation(dateVal) {
      // 日付正規表現
      let reg = new RegExp(
        "^([0-9]{4}-)((0[1-9]|1[0-2])-)((0[1-9]|[1-2][0-9]|3[0-1]))$"
      );
      if (!reg.test(dateVal)) {
        return false;
      }
      const [year, month, day] = dateVal.split("-").map(val => parseInt(val, 10));
      const thirtyDaysMonth = [4,6,9,11];
      const isLeapYear = ((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0);

      // 日のチェック
      if (day >= 31 && thirtyDaysMonth.indexOf(month) >= 0) {
        return false;
      }

      // 日のチェック(2月)
      if (month === 2) {
        if (day >= 30 && isLeapYear) {
          return false;
        } else if (day >= 29 && !isLeapYear) {
          return false;
        }
      }
      return true;
    },
    // 型式コード変更時の処理
    onChangeMachineType(machine_type_cd) {
      // データセットの取得
      const MachineTypeData = this.comboMachineType.filter(item => {
        if(item.value === machine_type_cd) return true;
      })[0];

      // 機種の変更
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'model')" 横展開2  linjunfeng start
      // this.machineTypeModel = MachineTypeData.model;
      this.machineTypeModel = MachineTypeData ? MachineTypeData.model : "";
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'model')" 横展開2 linjunfeng end

      // 通信種別のリストを変更
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'com_type')" 横展開2 linjunfeng start
      // this.comboComType = JSON.parse(MachineTypeData.com_type);
      this.comboComType = MachineTypeData ? JSON.parse(MachineTypeData.com_type) : [];
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'com_type')" 横展開2 linjunfeng end
      if (this.isRemsOnly) {
        // add redmine 4682 型式マスタにて通信種別を指定可能としているが、ReMSのみ施設の場合はオフライン運用の種別を強制除外する 孔 start
        const offlineIndex = this.comboComType.findIndex(item => {
          return item.value === "0"
        })
        if (offlineIndex > -1) {
          this.comboComType.splice( offlineIndex, 1)
        }
        // add redmine 4682 型式マスタにて通信種別を指定可能としているが、ReMSのみ施設の場合はオフライン運用の種別を強制除外する 孔 end
      }
      this.$nextTick(() => {
        // 通信フォーマットのリストを変更
        this.onChangeComType();
      });

      // 装置モードのチェックを変更
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'treat_mode')" 横展開2 linjunfeng start
      // if (MachineTypeData.treat_mode !== null && MachineTypeData.treat_mode.length === 11) {
      if (MachineTypeData?.treat_mode !== null && MachineTypeData?.treat_mode.length === 11) {
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'treat_mode')" 横展開2 linjunfeng end
        const treatModeList = MachineTypeData.treat_mode.split("");
        this.inputModel.is_support_hd = this.strToBool(treatModeList[0]);
        this.inputModel.is_support_ecum = this.strToBool(treatModeList[1]);
        this.inputModel.is_support_hdf = this.strToBool(treatModeList[2]);
        this.inputModel.is_support_hf = this.strToBool(treatModeList[3]);
        this.inputModel.is_support_hd_ho = this.strToBool(treatModeList[4]);
        this.inputModel.is_support_ecum_ho = this.strToBool(treatModeList[5]);
        this.inputModel.is_support_afbf = this.strToBool(treatModeList[6]);
        this.inputModel.is_support_ohdf = this.strToBool(treatModeList[7]);
        this.inputModel.is_support_ohf = this.strToBool(treatModeList[8]);
        this.inputModel.is_support_i_hdf = this.strToBool(treatModeList[9]);
        this.inputModel.is_support_blood_purify = this.strToBool(treatModeList[10]);
      } else {
        this.inputModel.is_support_hd = false;
        this.inputModel.is_support_ecum = false;
        this.inputModel.is_support_hdf = false;
        this.inputModel.is_support_hf = false;
        this.inputModel.is_support_hd_ho = false;
        this.inputModel.is_support_ecum_ho = false;
        this.inputModel.is_support_afbf = false;
        this.inputModel.is_support_ohdf = false;
        this.inputModel.is_support_ohf = false;
        this.inputModel.is_support_i_hdf = false;
        this.inputModel.is_support_blood_purify = false;
      }

      // TMPゼロ補正中点の値をデフォルト値に変更
      this.inputModel.tmp_center_hd = -30;
      this.inputModel.tmp_center_ecum = -65;
      this.inputModel.tmp_center_hdf = -30;
      this.inputModel.tmp_center_hf = -65;
      this.inputModel.tmp_center_hd_ho = -30;
      this.inputModel.tmp_center_ohdf = -30;
      this.inputModel.tmp_center_ohf = -65;

    },
    onChangeComType() {
      if (this.inputModel.com_type !== "") {
        const filteredComType = this.comboComType.filter(type => type.value === this.inputModel.com_type);
        if (filteredComType.length > 0) {
          this.comboComFormatType = filteredComType[0].com_format_cd;
        }
      }
    },
    // 型式コード変更時に値変更をする
    resetDataOnChangeMachineType() {
      if (this.comboComType.length > 0) {
        this.inputModel.com_type = this.comboComType[0].value;
      }
      if (this.comboComFormatType.length > 0) {
        this.inputModel.com_format_cd = this.comboComFormatType[0].value;
      }
    },
    // 通信種別 = 0 から戻した時に通信フォーマットを変える
    setDefaultToComFormatCd() {
      if (this.comboComFormatType.length > 0) {
        this.inputModel.com_format_cd = this.comboComFormatType[0].value;
      }
    },
    // 通信種別 = 1 ～ 3 の時にポートを変える
    setPort(com_type) {
      switch (com_type) {
        case "0":
        case "1":
        case "2":
        case "3":
          this.inputModel.port = "1401";
          return;
        default:
          return;
      }
    },
    // String(0:false,1:true)をBoolに変換
    strToBool(str) {
      switch (str) {
        case "0":
          return false;
        case "1":
          return true;
        default:
          return false;
      }
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      // 基本設定の入力データ
      const machineName = this.inputModel.machine_name;
      const machineSerial = this.inputModel.machine_serial;
      const machineTypeCd = this.inputModel.machine_type_cd;
      const version = this.inputModel.version;
      const ipAddress = this.inputModel.ip_address;
      const port = this.inputModel.port;

      const tmpCenterHd = this.inputModel.tmp_center_hd;
      const tmpCenterEcum = this.inputModel.tmp_center_ecum;
      const tmpCenterHdf = this.inputModel.tmp_center_hdf;
      const tmpCenterHf = this.inputModel.tmp_center_hf;
      const tmpCenterHdHo = this.inputModel.tmp_center_hd_ho;
      const tmpCenterOhdf = this.inputModel.tmp_center_ohdf;
      const tmpCenterOhf = this.inputModel.tmp_center_ohf;

      const memo = this.inputModel.memo;

      // 自由入力欄の桁数データ
      const nameLength = machineName ? machineName.length : 0;
      const versionLength = version ? version.length : 0;
      const ipAddressLength = ipAddress ? ipAddress.length : 0;
      const memoLength = memo ? memo.length : 0;

      // 通信方式
      const comFormatCd = this.inputModel.com_format_cd;

      // IPアドレス正規表現
      let reg = new RegExp(
        "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
      );
      // 装置シリアル正規表現
      const regSerial = new RegExp(/^[a-zA-Z0-9!-/:-@¥[-`{-~]*$/);

      return {
        // 装置名、型式、製造番号の必須入力チェック
        nameValid: machineName !== null && machineName !== "",
        typeValid: machineTypeCd !== null && machineTypeCd !== "",
        serialValid: machineSerial !== null && machineSerial !== "",

        // 各桁チェック
        nameLengthValid: nameLength <= 40,
        versionLengthValid: versionLength <= 20,
        portValid: 0 <= port && port <= 65535,
        serialTextValid: regSerial.test(machineSerial),

        tmpCenterHdValid: -200 <= tmpCenterHd && tmpCenterHd <= 200,
        tmpCenterEcumValid: -200 <= tmpCenterEcum && tmpCenterEcum <= 200,
        tmpCenterHdfValid: -200 <= tmpCenterHdf && tmpCenterHdf <= 200,
        tmpCenterHfValid: -200 <= tmpCenterHf && tmpCenterHf <= 200,
        tmpCenterHdHoValid: -200 <= tmpCenterHdHo && tmpCenterHdHo <= 200,
        tmpCenterOhdfValid: -200 <= tmpCenterOhdf && tmpCenterOhdf <= 200,
        tmpCenterOhfValid: -200 <= tmpCenterOhf && tmpCenterOhf <= 200,

        memoLengthValid: memoLength <= 256,

        // IPアドレスのチェック オフラインならばnull許容
        ipAddressValid: (comFormatCd === "F" && ipAddressLength === 0) || reg.test(ipAddress),
      };
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES[12000110].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
        !validationResult.nameValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "装置名を入力する必要があります。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000110].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.typeValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "型式を入力する必要があります。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000111].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.serialValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "製造番号を入力する必要があります。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000113].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.nameLengthValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "装置名が長すぎます。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000114].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.serialTextValid && validationResult.serialValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "製造番号に使用できない文字が含まれています。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000115].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.versionLengthValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "バージョン番号の桁数が多すぎます。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000116].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.ipAddressValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "IPアドレスが不正です。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000117].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.portValid
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // ? "ポート番号が入力範囲外です。<br>"
          ? messageFormat(DIALOG_MESSAGES[12000118].message)
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          : ""
      }
          ${
        !validationResult.tmpCenterHdValid ||
        !validationResult.tmpCenterEcumValid ||
        !validationResult.tmpCenterHdfValid ||
        !validationResult.tmpCenterHfValid ||
        !validationResult.tmpCenterHdHoValid ||
        !validationResult.tmpCenterOhdfValid ||
        !validationResult.tmpCenterOhfValid
          ? "TMPゼロ補正中点が入力範囲外です。<br>"
          : ""
      }
          ${
        !validationResult.memoLengthValid
          ? "メモの内容が長すぎます。<br>"
          : ""
      }
        `;
      let arr = document.getElementsByClassName("custom-input-required");
      let select = document.getElementsByClassName("custom-select-required");
      if(!validationResult.nameValid || !validationResult.nameLengthValid){
        arr[0]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.serialValid || (!validationResult.serialTextValid && validationResult.serialValid)){
        arr[1]?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.typeValid){
        select[0]?.classList?.add("custom-select-invalid");
      }
      if(!validationResult.ipAddressValid){
        document.getElementById("ip-address").parentElement?.classList?.add("custom-input-invalid");
      }
      if(!validationResult.portValid || !validationResult.versionLengthValid){
        document.getElementById("port").parentElement?.classList?.add("input-number-invalid");
      }
      const map = new Map()
        .set("tmp-center-hd",!validationResult.tmpCenterHdValid)
        .set("tmp-center-ecum",!validationResult.tmpCenterEcumValid)
        .set("tmp-center-hdf",!validationResult.tmpCenterHdfValid)
        .set("tmp-center-hf",!validationResult.tmpCenterHfValid)
        .set("tmp-center-hd-ho",!validationResult.tmpCenterHdHoValid)
        .set("tmp-center-ohdf",!validationResult.tmpCenterOhdfValid)
        .set("tmp-center-ohf",!validationResult.tmpCenterOhfValid);

      for(let [key,value] of map.entries()){
        if(value){
          document.getElementById(key).parentElement?.classList?.add("input-number-invalid");
        }
      }

      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
    setContentData(newValue) {
      this.inputModel.memo = newValue;
    },
    handleJudgeEdited (val, key) {
      if ([null, undefined, ''].includes(this.inputModel_clone[key]) && !val) {
        return ''
      }
      if (this.inputModel_clone && this.inputModel_clone[key] != val) {
        return 'custom-input-edited'
      } else {
        return ''
      }
    }
  },
  async created() {

    // 施設コード
    this.machineFacilityCd = this.getSelectedFacilityCd;

    // コンボボックス取得
    this.comboMachineType = this.getMachineTypeList;
    this.comboDeviceEdge = deepCopy(this.getDeviceEdgeList);
    this.comboDeviceEdge.unshift({ text: "", value: null });

    // 装置番号
    this.machineNo = this.getSelectByField("code");

    // 初期値設定ここから ----------

    // 基本設定
    this.inputModel.machine_name = this.getSelectByField("name");
    this.inputModel.machine_serial = this.getSelectByField("machineSerial");
    this.inputModel.version = this.getSelectByField("version");
    this.inputModel.com_format_cd = this.getSelectByField("comFormatCd");
    this.inputModel.com_type = this.getSelectByField("comType");
    this.inputModel.machine_type_cd = this.getSelectByField("machineTypeCd");
    if (this.getSelectByField("machineTypeCd") !== "" && this.getSelectByField("machineTypeCd")) {
      this.onChangeMachineType(this.inputModel.machine_type_cd);
    }
    if (this.inputModel.com_format_cd === "F") {
      // オフラインではIPアドレスは空欄OK
      this.inputModel.ip_address = this.getSelectByField("ipAddress");
    } else {
      this.inputModel.ip_address = this.getSelectByFieldWithDefault("ipAddress", "192.168.10.101");
    }
    this.inputModel.port = this.getSelectByField("port");
    // redmine 4515 装置マスタ新規追加時にデバイスエッジを選択状態で起動する(デバイスエッジの1番上の選択肢を選択状態とする) 宋qy start
    this.inputModel.device_edge_no = this.getSelectByFieldWithDefault("deviceEdgeNo", this.comboDeviceEdge[0] ? this.comboDeviceEdge[0].value : null);
    // redmine 4515 装置マスタ新規追加時にデバイスエッジを選択状態で起動する(デバイスエッジの1番上の選択肢を選択状態とする) 宋qy end
    this.inputModel.is_ftp = this.getSelectByFieldWithDefault("isFtp", "0");
    this.inputModel.is_va = this.getSelectByFieldWithDefault("isVa", "0");
    // del redmine 5813 装置マスタ一覧の使用不可の対応忘れ 宋qy start
    //this.inputModel.is_disable = this.getBoolByField("isDisable");
    // del redmine 5813 装置マスタ一覧の使用不可の対応忘れ 宋qy end
    // add 通信系アプリ系作業内容確認一覧 王 start
    this.inputModel.is_blood_purify_use = this.getBoolByField2("isBloodPurifyUse");
    this.inputModel.blood_purify_type = this.getSelectByFieldWithDefault("bloodPurifyType", "5");
    // add 通信系アプリ系作業内容確認一覧 王 end
    this.inputModel.in_hospital_cd_1 = this.getSelectByField("inHospitalCd1");
    this.inputModel.in_hospital_cd_2 = this.getSelectByField("inHospitalCd2");

    // 装置モード
    this.inputModel.is_support_hd = this.getBoolByField("isSupportHd");
    this.inputModel.is_support_ecum = this.getBoolByField("isSupportEcum");
    this.inputModel.is_support_hdf = this.getBoolByField("isSupportHdf");
    this.inputModel.is_support_hf = this.getBoolByField("isSupportHf");
    this.inputModel.is_support_hd_ho = this.getBoolByField("isSupportHdHo");
    this.inputModel.is_support_ecum_ho = this.getBoolByField("isSupportEcumHo");
    this.inputModel.is_support_afbf = this.getBoolByField("isSupportAfbf");
    this.inputModel.is_support_ohdf = this.getBoolByField("isSupportOhdf");
    this.inputModel.is_support_ohf = this.getBoolByField("isSupportOhf");
    this.inputModel.is_support_i_hdf = this.getBoolByField("isSupportIHdf");
    this.inputModel.is_support_blood_purify = this.getBoolByField("isSupportBloodPurify")

    // 新規追加時 デフォルト設定
    if (this.getSelectByField("operation") === 1) {
      // 設置日にsysdate設定
      this.inputModel.setting_date = dateFormat.format(new Date(), DATE_FORMAT);
    }

    // 新規追加時に初期値設定しないもの
    if (this.inputModel.machine_serial !== "" || this.inputModel.machine_type_cd !== "") {
      // 設置日・削除日
      if (this.getSelectByField("settingDate") !== "") {
        this.inputModel.setting_date =
          dateFormat.format(new Date(this.getSelectByField("settingDate")), DATE_FORMAT);
      }
      if (this.getSelectByField("deleteDate") !== "") {
        this.inputModel.delete_date =
          dateFormat.format(new Date(this.getSelectByField("deleteDate")), DATE_FORMAT);
      }

      // TMPゼロ補正中点
      this.inputModel.tmp_center_hd = this.getSelectByField("tmpCenterHd");
      this.inputModel.tmp_center_ecum = this.getSelectByField("tmpCenterEcum");
      this.inputModel.tmp_center_hdf = this.getSelectByField("tmpCenterHdf");
      this.inputModel.tmp_center_hf = this.getSelectByField("tmpCenterHf");
      this.inputModel.tmp_center_hd_ho = this.getSelectByField("tmpCenterHdHo");
      this.inputModel.tmp_center_ohdf = this.getSelectByField("tmpCenterOhdf");
      this.inputModel.tmp_center_ohf = this.getSelectByField("tmpCenterOhf");
    }

    // オプション
    if (this.getSelectByField("machineOption") !== "" && this.getSelectByField("machineOption")) {
      this.option = JSON.parse(this.getSelectByField("machineOption"));
    }

    // メモ
    this.inputModel.memo = this.getSelectByField("memo");

    // add 通信系アプリ系作業内容確認一覧 王 start
    let responseFacility = await sendRequestGetMstFacilityByCd(this.getFacilityCd)
    let advanced = JSON.parse(responseFacility.data.advancedSettings)
    if (advanced !== null) {
      this.is_pur_show = advanced.func_advcds.findIndex(item => item.func_advcd === ADVANCED_SETTINGS.PURIFICATION_COMMUNICATION) !== -1;
      if (this.is_pur_show) {
        let a = document.getElementsByClassName("input-item-name")
        for (let i = 0; i < a.length; i++) {
          a[i].style.maxWidth = '278px';
        }
      }
    }
    // add 通信系アプリ系作業内容確認一覧 王 end
    //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
    if(this.inputModel.device_edge_no) {
      this.comboDeviceEdge = this.comboDeviceEdge.filter(
        v => v.del != '1' || (v.del == '1' && v.value == this.inputModel.device_edge_no)
      );
    }else {
      this.comboDeviceEdge = this.comboDeviceEdge.filter(v => v.del == '0');
    }
    //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end
  },
  async mounted() {
    // 縦スクロールバー表示
    let modalObj = document.getElementsByClassName("modal-body");
    if (modalObj.length >= 1){
      modalObj[0].classList.remove("modal-overflow-hidden");
      modalObj[0]?.classList?.add("modal-scroll");
    }
      //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
    this.inputModel_clone = JSON.parse(JSON.stringify(this.inputModel))
  }
};
</script>

<style scoped>
#machine-modal-content {
  padding-left: 20px;
}
.machine-setting {
  border: solid 1px rgb(150, 150, 150);
  border-radius: 5px;
  padding: 10px 20px;
  margin-top: 10px;
  margin-bottom: 20px;
  margin-right: 20px;
}
.machine-setting >>> .text-input {
  font-size: unset;
}
.machine-option {
  border: solid 1px rgb(150, 150, 150);
  border-radius: 5px;
  padding: 10px 20px 20px 20px;
  margin-top: 10px;
  margin-bottom: 20px;
  margin-right: 20px;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
table {
  width: 95%;
  border-collapse: collapse;
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
.input-row-header {
  margin-bottom: 10px;
  padding-bottom: 5px;
  border-bottom: 1px solid #bbb;
}
div >>> textarea {
  width: 100%;
  border: solid 1px rgb(150, 150, 150);
  min-height: 10em;
  resize: both;
}
div >>> textarea:focus {
  border: 2px green solid;
}
.input-item-name {
  font-weight: bold;
  margin-top: 10px;
  max-width: 15%;
}
.input-item-check {
  font-weight: bold;
  margin-top: 10px;
  max-width: 3%;
}
.input-item-check-name {
  font-weight: bold;
  margin-top: 10px;
  max-width: 15%;
}
.input-item-txt {
  max-width: 40%;
}
.input-item-txt-long {
  max-width: 70%;
}
.input-item-textarea {
  max-width: 100%;
}
.input-item-textarea >>> .textarea {
  font-size: unset;
}
.input-item-num {
  max-width: 15%;
}
.td-txt {
  min-width: 2em;
  padding: 5px;
  height: 1.2em;
}
.td-lbl {
  font-weight: bold;
  min-width: 15em;
}
.table-option {
  max-width: 40%;
  margin-bottom: 2.0em;
}
.table-sbt {
  max-width: 40%;
}
@media screen and (max-width: 1024px) {
  .input-item-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 90%;
  }
  .input-item-check {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    max-width: 15%;
  }
  .input-item-check-name {
    text-align: left;
    font-weight: bold;
    margin-bottom: 5px;
    min-width: 50%;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-txt-long {
    text-align: left;
    min-width: 90%;
  }
  .input-item-num {
    min-width: 40%;
  }
  .input-item-margin {
    display: none;
  }
  .table-option {
    min-width: 100%;
    margin-bottom: 0em;
  }
  .table-sbt {
    min-width: 90%;
  }
  .td-lbl {
    min-width: 8em;
    width: 11em;
  }
  .td-txt {
    min-width: 0em;
    text-align: center;
  }
}
textarea:focus {
  border: 2px green solid;
  outline: 0;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
.input-number-invalid >>> input[type="number"] {
  color: black;
  background-color: rgba(255, 0, 0, 0.7) !important;
}
.custom-select-required >>> select{
  background-color: #ffff99 !important;
}
.custom-select-required >>> option{
  background-color: white;
}
.custom-select-invalid >>> select{
  background-color: rgba(255, 0, 0, 0.7) !important;
}
.custom-select-invalid >>> option{
  background-color: white;
}
::v-deep .custom-input-edited>input[type="number"], ::v-deep .custom-input-edited>input[type="date"], ::v-deep .custom-input-edited>select, ::v-deep .custom-input-edited>textarea{
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
</style>
