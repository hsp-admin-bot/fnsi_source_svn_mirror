<!-- ホスト通知 -->
<template>
  <div>
    <v-ons-row class="common-style-header device-info-cell-title">
      <v-ons-col class="header-padding"/>
      <v-ons-col class="header-padding">上限値</v-ons-col>
      <v-ons-col class="header-padding">下限値</v-ons-col>
      <v-ons-col class="header-padding">監視</v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">最高血圧</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpMaxUpper"
            formName="最高血圧 上限値"
            :value="bpMaxUpper"
            :max-value="250"
            :min-value="40"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpMaxLower"
            formName="最高血圧 下限値"
            :value="bpMaxLower"
            :max-value="250"
            :min-value="40"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="bpMaxJudge"
          :value="bpMaxJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">最低血圧</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpMinUpper"
            formName="最低血圧 上限値"
            :value="bpMinUpper"
            :max-value="200"
            :min-value="20"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpMinLower"
            formName="最低血圧 下限値"
            :value="bpMinLower"
            :max-value="200"
            :min-value="20"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="bpMinJudge"
          :value="bpMinJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">平均血圧</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpAveUpper"
            formName="平均血圧 上限値"
            :value="bpAveUpper"
            :max-value="235"
            :min-value="30"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpAveLower"
            formName="平均血圧 下限値"
            :value="bpAveLower"
            :max-value="235"
            :min-value="30"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="bpAveJudge"
          :value="bpAveJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">脈拍</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="pulseUpper"
            formName="脈拍 上限値"
            :value="pulseUpper"
            :max-value="240"
            :min-value="40"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          bpm
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="pulseLower"
            formName="脈拍 下限値"
            :value="pulseLower"
            :max-value="240"
            :min-value="40"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          bpm
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="pulseJudge"
          :value="pulseJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">血流量</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bloodFlowUpper"
            formName="血流量 上限値"
            :value="bloodFlowUpper"
            :max-value="600"
            :min-value="0"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mL/min
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bloodFlowLower"
            formName="血流量 下限値"
            :value="bloodFlowLower"
            :max-value="600"
            :min-value="0"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mL/min
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="bloodFlowJudge"
          :value="bloodFlowJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">IP速度</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="ipSpeedUpper"
            formName="IP速度 上限値"
            :value="ipSpeedUpper"
            :max-value="10.0"
            :min-value="0.0"
            :decimal-digits="1"
            :digits="2"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mL/h
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="ipSpeedLower"
            formName="IP速度 下限値"
            :value="ipSpeedLower"
            :max-value="10.0"
            :min-value="0.0"
            :decimal-digits="1"
            :digits="2"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mL/h
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="ipSpeedJudge"
          :value="ipSpeedJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">除水速度</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="ufrUpper"
            formName="除水速度 上限値"
            :value="ufrUpper"
            :max-value="4.00"
            :min-value="0.00"
            :decimal-digits="2"
            :digits="1"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          L/h
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="ufrLower"
            formName="除水速度 下限値"
            :value="ufrLower"
            :max-value="4.00"
            :min-value="0.00"
            :decimal-digits="2"
            :digits="1"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          L/h
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="ufrJudge"
          :value="ufrJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">静脈圧</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="vpUpper"
            formName="静脈圧 上限値"
            :value="vpUpper"
            :max-value="500"
            :min-value="-200"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="vpLower"
            formName="静脈圧 下限値"
            :value="vpLower"
            :max-value="500"
            :min-value="-200"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="vpJudge"
          :value="vpJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">ダイアライザ入口圧</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="apUpper"
            formName="ダイアライザ入口圧 上限値"
            :value="apUpper"
            :max-value="600"
            :min-value="-200"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="apLower"
            formName="ダイアライザ入口圧 下限値"
            :value="apLower"
            :max-value="600"
            :min-value="-200"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mmHg
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="apJudge"
          :value="apJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">Na濃度</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="naConcUpper"
            formName="Na濃度 上限値"
            :value="naConcUpper"
            :max-value="200"
            :min-value="100"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mEq/L
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="naConcLower"
            formName="Na濃度 下限値"
            :value="naConcLower"
            :max-value="200"
            :min-value="100"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mEq/L
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="naConcJudge"
          :value="naConcJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">透析液温度</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="dialysTempUpper"
            formName="透析液温度 上限値"
            :value="dialysTempUpper"
            :max-value="40.0"
            :min-value="33.0"
            :decimal-digits="1"
            :digits="2"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          ℃
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="dialysTempLower"
            formName="透析液温度 下限値"
            :value="dialysTempLower"
            :max-value="40.0"
            :min-value="33.0"
            :decimal-digits="1"
            :digits="2"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          ℃
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="dialysTempJudge"
          :value="dialysTempJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">ΔBV変化率</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="dBvRocUpper"
            formName="ΔBV変化率 上限値"
            :value="dBvRocUpper"
            :max-value="50.0"
            :min-value="0.0"
            :decimal-digits="1"
            :digits="2"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          %/min
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="dBvRocLower"
            formName="ΔBV変化率 下限値"
            :value="dBvRocLower"
            :max-value="0.0"
            :min-value="-50.0"
            :decimal-digits="1"
            :digits="2"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          %/min
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="dBvRocJudge"
          :value="dBvRocJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">LDQb</v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="ldqbUpper"
            formName="LDQb 上限値"
            :value="ldqbUpper"
            :max-value="600"
            :min-value="0"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mL/min
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="ldqbLower"
            formName="LDQb 下限値"
            :value="ldqbLower"
            :max-value="600"
            :min-value="0"
            :decimal-digits="0"
            :digits="3"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          mL/min
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="ldqbJudge"
          :value="ldqbJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="common-style-header device-info-cell-title">
      <v-ons-col class="header-padding"/>
      <v-ons-col class="header-padding"/>
      <v-ons-col class="header-padding">間隔</v-ons-col>
      <v-ons-col class="header-padding">監視</v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">血圧測定間隔</v-ons-col>
      <v-ons-col class="device-info-cell-value">
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="bpmiInterval"
            formName="血圧測定間隔"
            :value="bpmiInterval"
            :max-value="60"
            :min-value="1"
            :decimal-digits="0"
            :digits="2"
            :is-required="true"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          分
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="bpmiJudge"
          :value="bpmiJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="device-info-cell">
      <v-ons-col class="device-info-cell-name" style="padding-left: 3px;">ケア間隔</v-ons-col>
      <v-ons-col class="device-info-cell-value">
      </v-ons-col>
      <v-ons-col class="device-info-cell-value">
        <span class="device-input-number">
          <custom-input-number
            ref="careiInterval"
            formName="ケア間隔"
            :value="careiInterval"
            :max-value="60"
            :min-value="1"
            :decimal-digits="0"
            :digits="2"
            :is-required="true"
            :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
            @wheel.prevent="setDeviceInfoChange()"
            @keyup.up.prevent="setDeviceInfoChange()"
            @keyup.down.prevent="setDeviceInfoChange()"
            @change="setDeviceInfoChange()"
            @blur="setDeviceInfoChange()"
          />
          分
        </span>
      </v-ons-col>
      <v-ons-col class="device-info-cell-value v-align-center">
        <custom-checkbox
          ref="careiJudge"
          :value="careiJudge"
          checked-value="1"
          unchecked-value="0"
          :disabled="!getItemAuthorized('DevicesetInfo', 'item_baseTareAndOffWater') || getIsOtherFacility"
          @change="setDeviceInfoChange()"
        />
      </v-ons-col>
    </v-ons-row>
  </div>
</template>
<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber.vue";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
// add FNSI-改修内容 権限関連 趙 start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// del #10359 編集権限の動作不正 dengshen end
// add FNSI-改修内容 権限関連 趙 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
import { EventBus } from "@/eventBus.js";
// add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
import { mapActions, mapGetters } from "vuex";

export default {
  components: {
    "custom-input-number": customInputNumber,
    "custom-checkbox": customCheckbox
  },
  // del #10359 編集権限の動作不正 dengshen start
  // // add FNSI-改修内容 権限関連 趙 start
  // mixins: [ComponentGuardMixin],
  // // add FNSI-改修内容 権限関連 趙 end
  // del #10359 編集権限の動作不正 dengshen end
  props: {
    /**
     * 表示画面(マスタ画面/患者情報)
     */
    dataSourceType: {
      type: Number,
      default: null
    },
    /**
     * 患者ID
     */
    propsPatId: {
      type: Number,
      default: null
    },
    /**
     * 施設コード
     */
    propsFacilityCd: {
      type: String,
      default: null
    }
  },

  data() {
    return {
      // mod #10380 ホスト報知のデフォルトデータ修正 宮崎 start
      // == 各項目の割り当てデータ ==
      // 最高血圧_上限値
      bpMaxUpper: {
        initValue: "",
        editValue: ""
      },
      // 最高血圧_下限値
      bpMaxLower: {
        initValue: "",
        editValue: ""
      },
      // 最高血圧_有効/無効
      bpMaxJudge: {
        initValue: "",
        editValue: ""
      },
      // 最低血圧_上限値
      bpMinUpper: {
        initValue: "",
        editValue: ""
      },
      // 最低血圧_下限値
      bpMinLower: {
        initValue: "",
        editValue: ""
      },
      // 最低血圧_有効/無効
      bpMinJudge: {
        initValue: "",
        editValue: ""
      },
      // 平均血圧_上限値
      bpAveUpper: {
        initValue: "",
        editValue: ""
      },
      // 平均血圧_下限値
      bpAveLower: {
        initValue: "",
        editValue: ""
      },
      // 平均血圧_有効/無効
      bpAveJudge: {
        initValue: "",
        editValue: ""
      },
      // 脈拍_上限値
      pulseUpper: {
        initValue: "",
        editValue: ""
      },
      // 脈拍_下限値
      pulseLower: {
        initValue: "",
        editValue: ""
      },
      // 脈拍_有効/無効
      pulseJudge: {
        initValue: "",
        editValue: ""
      },
      // 血流量_上限値
      bloodFlowUpper: {
        initValue: "",
        editValue: ""
      },
      // 血流量_下限値
      bloodFlowLower: {
        initValue: "",
        editValue: ""
      },
      // 血流量_有効/無効
      bloodFlowJudge: {
        initValue: "",
        editValue: ""
      },
      // IP速度_上限値
      ipSpeedUpper: {
        initValue: "",
        editValue: ""
      },
      // IP速度_下限値
      ipSpeedLower: {
        initValue: "",
        editValue: ""
      },
      // IP速度_有効/無効
      ipSpeedJudge: {
        initValue: "",
        editValue: ""
      },
      // 除水速度_上限値
      ufrUpper: {
        initValue: "",
        editValue: ""
      },
      // 除水速度_下限値
      ufrLower: {
        initValue: "",
        editValue: ""
      },
      // 除水速度_有効/無効
      ufrJudge: {
        initValue: "",
        editValue: ""
      },
      // 静脈圧_上限値
      vpUpper: {
        initValue: "",
        editValue: ""
      },
      // 静脈圧_下限値
      vpLower: {
        initValue: "",
        editValue: ""
      },
      // 静脈圧_有効/無効
      vpJudge: {
        initValue: "",
        editValue: ""
      },
      // ダイアライザ入口圧_上限値
      apUpper: {
        initValue: "",
        editValue: ""
      },
      // ダイアライザ入口圧_下限値
      apLower: {
        initValue: "",
        editValue: ""
      },
      // ダイアライザ入口圧_有効/無効
      apJudge: {
        initValue: "",
        editValue: ""
      },
      // Na濃度_上限値
      naConcUpper: {
        initValue: "",
        editValue: ""
      },
      // Na濃度_下限値
      naConcLower: {
        initValue: "",
        editValue: ""
      },
      // Na濃度_有効/無効
      naConcJudge: {
        initValue: "",
        editValue: ""
      },
      // 透析液温度_上限値
      dialysTempUpper: {
        initValue: "",
        editValue: ""
      },
      // 透析液温度_下限値
      dialysTempLower: {
        initValue: "",
        editValue: ""
      },
      // 透析液温度_有効/無効
      dialysTempJudge: {
        initValue: "",
        editValue: ""
      },
      // ΔBV変化率_上限値
      dBvRocUpper: {
        initValue: "",
        editValue: ""
      },
      // ΔBV変化率_下限値
      dBvRocLower: {
        initValue: "",
        editValue: ""
      },
      // ΔBV変化率_有効/無効
      dBvRocJudge: {
        initValue: "",
        editValue: ""
      },
      // LDQb_上限値
      ldqbUpper: {
        initValue: "",
        editValue: ""
      },
      // LDQb_下限値
      ldqbLower: {
        initValue: "",
        editValue: ""
      },
      // LDQb_有効/無効
      ldqbJudge: {
        initValue: "",
        editValue: ""
      },
      // 血圧測定間隔
      bpmiInterval: {
        initValue: "",
        editValue: ""
      },
      // 血圧測定間隔_有効/無効
      bpmiJudge: {
        initValue: "",
        editValue: ""
      },
      // ケア間隔
      careiInterval: {
        initValue: "",
        editValue: ""
      },
      // ケア間隔_有効/無効
      careiJudge: {
        initValue: "",
        editValue: ""
      },
      // ==========================
      // mod #10380 ホスト報知のデフォルトデータ修正 宮崎 end
      // データベースからの取得データ
      mainData: null,
      // add FNSI-改修内容 権限関連 趙 start
      // del #10359 編集権限の動作不正 dengshen start
      // authorityCds: [
      //   AUTHORITY_CODES.PAT_PEDIT,  // 機器保守-代行編集
      //   AUTHORITY_CODES.PAT_EDIT    // 機器保守-編集
      // ],
      // hasDailyCheckAuthority: false
      // del #10359 編集権限の動作不正 dengshen end
      // add FNSI-改修内容 権限関連 趙 end
    };
  },
  // add FNSI-改修内容 権限関連 趙 start
  computed: {
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
    // del #10359 編集権限の動作不正 dengshen start
    // ishasDailyCheckAuthority() {
    //   return this.hasDailyCheckAuthority;
    // }
    // del #10359 編集権限の動作不正 dengshen end

    // 上限値と下限値がある数値入力項目の上限値のデータ名の配列
    limitedUpperValueKeys() {
      return Object.keys(this.$refs).filter(key => key.includes("Upper"));
    },
    // 上限値と下限値がある数値入力項目の下限値のデータ名の配列
    limitedLowerValueKeys() {
      return Object.keys(this.$refs).filter(key => key.includes("Lower"));
    },
    // 上限値と下限値がある数値入力項目の上限値と下限値のデータ参照をペアにした配列
    limitedValuePair() {
      const pairData = [];
      
      for (const key of this.limitedUpperValueKeys) {
        pairData.push({
          name: this.$refs[key].formName.replace("上限値", "").trim(),
          upper: this.$data[key],
          lower: this.$data[key.replace("Upper", "Lower")]
        });
      }
      return pairData;
    },
    // xxxInterval の名称の数値入力項目のデータ名の配列
    intervalValueKeys() {
      return Object.keys(this.$refs).filter(key => key.includes("Interval"));
    },
    // xxxJudge の名称の入力項目のデータ名の配列
    judgeValueKeys() {
      return Object.keys(this.$refs).filter(key => key.includes("Judge"));
    },
    // すべての入力項目のデータ名の配列
    deviceInfoDataKeys() {
      return [...this.limitedUpperValueKeys, ...this.limitedLowerValueKeys, ...this.intervalValueKeys, ...this.judgeValueKeys];
    }
  },
  // add FNSI-改修内容 権限関連 趙 end

  async created() {
    // add FNSI-改修内容 権限関連 趙 start
    // del #10359 編集権限の動作不正 dengshen start
    // this.hasDailyCheckAuthority = this.getDailyCheckAuthority();
    // del #10359 編集権限の動作不正 dengshen end
    // add FNSI-改修内容 権限関連 趙 end
    // ホスト報知情報の取得
    this.mainData = await this.getHostNotificationInfo();
    // 取得したデータを展開
    this.settingHostNoticeData(this.mainData);
  },


  methods: {
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),

    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    /**
     * 入力項目の値が未入力であるかを判定する
     * ※空文字を含み、数値 0 は除く
     * @param value 
     */
    isEmpty(value) {
      return (value === null || value === "");
    },
    /**
     * 入力項目の値の変更イベントハンドラ
     * 入力項目の値が初期値から変更された項目の有無を判定して保存ボタンを活性化する
     * 
     * イベント毎の対応
     * @input (このイベントは判定しない)
     *   ※数値入力イベント発生中は編集値([項目データ].editValue)は未設定のため、判定処理不可のため
     * @wheel, @keyup.up, @keyup.down, @change, @blur
     *   これらのイベント発生時は入力項目の値の変更が確定するため入力項目の値の変更を判定する
     */
    setDeviceInfoChange() {
      let isChange = false;
      // 入力項目のどれかが変更されているかをチェックする
      for (const key of this.deviceInfoDataKeys) {
        const data = this.$data[key];
        // 初期値か編集値のどちらかに変更がある（値がある）か
        // @change イベントで項目が空の場合に editValue が空文字である場合がある（※）null と空文字は値なしとして判定する
        if (!this.isEmpty(data.initValue) || !this.isEmpty(data.editValue)) {
          // 初期値と編集値が異なる場合でデータ型が異なる（null → number または number → null など）場合、
          // または、custom-input-number の▲▼ボタン押下時 (data.editValue が文字列型になる) 場合
          // ※ custom-input-number の▲▼ボタン押下時のデータ型が数値型になるように修正が必要
          if (typeof data.initValue !== typeof data.editValue) {
            // data.editValue が文字列型の場合は初期値と編集値を等価演算子で比較する
            if (data.initValue != data.editValue) {
              isChange = true;
              // １つの入力項目でも変更があれば他の入力項目の判定は不用
              break;
            }
          }
          // 入力項目の初期値と編集値が異なる場合に @wheel, @keyup.up, @keyup.down, @change, @blurのイベントでは厳密等価演算子で空文字と数値(0)を区別する
          else {
            // 初期値と編集値に変更があるか?（厳密等価演算子で空文字と数値(0)を区別する）
            if (data.initValue !== data.editValue) {
              isChange = true;
              // １つの入力項目でも変更があれば他の入力項目の判定は不用
              break;
            }
          }
        }
      }
      EventBus.$emit("deviceSetChanged", isChange);
    },
    /**
     * ホスト報知情報の取得
     */
    async getHostNotificationInfo() {
      let getData = {};
      switch (this.dataSourceType) {
        // 装置設定デフォルトマスタ
        case 1:
        // add FNSI6062-装置情報で項目の不足 周 start
        // del #7668 2022-7-13  装置設定>ホスト報知の設定が保存できない  孟堅 start　　
        // case 2:
        // del #7668 2022-7-13  装置設定>ホスト報知の設定が保存できない  孟堅 end
        // add FNSI6062-装置情報で項目の不足 周 end
          getData = await this.getMstDeviceSetInfoDefault();
          break;

        // 患者情報
        case 2:
          getData = await this.getPatMain();
          break;

        default:
          // 異常値
          break;
      }
      return getData;
    },
    /**
     * 装置設定デフォルトマスタからDBデータ取得
     */
    async getMstDeviceSetInfoDefault() {
      // 施設コードがない場合は空のObjectを返す
      if (!this.propsFacilityCd) {
        return {};
      }
      const url = `deviceSetInfo/getSysHostNoticeById/${this.propsFacilityCd}`;
      // データ取得
      const response = await ApiHelper.get(url).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HostNoticeEditor.vue', 'getMstDeviceSetInfoDefault', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });

      let getData = {};
      if (null !== response.data[0]) {
         getData = JSON.parse((JSON.parse(response.data[0])));
      }
      return getData;
    },
    /**
     * 患者情報からDBデータ取得
     */
    async getPatMain() {
      // 患者IDがない場合は空のObjectを返す
      if (!this.propsPatId) {
        return {};
      }
      // mod #12462 患者情報共有 Ji start
      // const url = `deviceSetInfo/getPatHostNoticeById/${this.propsPatId}`;   "getIsOtherFacility", "getOtherFacilityCd"
      const url = this.getIsOtherFacility
        ? `deviceSetInfo/getPatHostNoticeById/${this.propsPatId}/${this.getOtherFacilityCd}` 
        : `deviceSetInfo/getPatHostNoticeById/${this.propsPatId}`;
      // mod #12462 患者情報共有 Ji end
      // データ取得
      const response = await ApiHelper.get(url).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HostNoticeEditor.vue', 'getPatMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      let getData = {};
      if (null !== response.data[0]) {
        getData = JSON.parse((JSON.parse(response.data[0])));
      }
      return getData;
    },
    /**
     * 取得したデータをセット
     */
    settingHostNoticeData(dataObj) {
      // 最高血圧
      this.bpMaxUpper.initValue = dataObj.bp_max.upper;
      this.bpMaxUpper.editValue = dataObj.bp_max.upper;
      this.bpMaxLower.initValue = dataObj.bp_max.lower;
      this.bpMaxLower.editValue = dataObj.bp_max.lower;
      this.bpMaxJudge.initValue = dataObj.bp_max.judge ? "1" : "0";
      this.bpMaxJudge.editValue = dataObj.bp_max.judge ? "1" : "0";
      // 最低血圧
      this.bpMinUpper.initValue = dataObj.bp_min.upper;
      this.bpMinUpper.editValue = dataObj.bp_min.upper;
      this.bpMinLower.initValue = dataObj.bp_min.lower;
      this.bpMinLower.editValue = dataObj.bp_min.lower;
      this.bpMinJudge.initValue = dataObj.bp_min.judge ? "1" : "0";
      this.bpMinJudge.editValue = dataObj.bp_min.judge ? "1" : "0";
      // 平均血圧
      this.bpAveUpper.initValue = dataObj.bp_ave.upper;
      this.bpAveUpper.editValue = dataObj.bp_ave.upper;
      this.bpAveLower.initValue = dataObj.bp_ave.lower;
      this.bpAveLower.editValue = dataObj.bp_ave.lower;
      this.bpAveJudge.initValue = dataObj.bp_ave.judge ? "1" : "0";
      this.bpAveJudge.editValue = dataObj.bp_ave.judge ? "1" : "0";
      // 脈拍
      this.pulseUpper.initValue = dataObj.pulse.upper;
      this.pulseUpper.editValue = dataObj.pulse.upper;
      this.pulseLower.initValue = dataObj.pulse.lower;
      this.pulseLower.editValue = dataObj.pulse.lower;
      this.pulseJudge.initValue = dataObj.pulse.judge ? "1" : "0";
      this.pulseJudge.editValue = dataObj.pulse.judge ? "1" : "0";
      // 血流量
      this.bloodFlowUpper.initValue = dataObj.blood_flow.upper;
      this.bloodFlowUpper.editValue = dataObj.blood_flow.upper;
      this.bloodFlowLower.initValue = dataObj.blood_flow.lower;
      this.bloodFlowLower.editValue = dataObj.blood_flow.lower;
      this.bloodFlowJudge.initValue = dataObj.blood_flow.judge ? "1" : "0";
      this.bloodFlowJudge.editValue = dataObj.blood_flow.judge ? "1" : "0";
      // IP速度
      this.ipSpeedUpper.initValue = dataObj.ip_speed.upper;
      this.ipSpeedUpper.editValue = dataObj.ip_speed.upper;
      this.ipSpeedLower.initValue = dataObj.ip_speed.lower;
      this.ipSpeedLower.editValue = dataObj.ip_speed.lower;
      this.ipSpeedJudge.initValue = dataObj.ip_speed.judge ? "1" : "0";
      this.ipSpeedJudge.editValue = dataObj.ip_speed.judge ? "1" : "0";
      // 除水速度
      this.ufrUpper.initValue = dataObj.ufr.upper;
      this.ufrUpper.editValue = dataObj.ufr.upper;
      this.ufrLower.initValue = dataObj.ufr.lower;
      this.ufrLower.editValue = dataObj.ufr.lower;
      this.ufrJudge.initValue = dataObj.ufr.judge ? "1" : "0";
      this.ufrJudge.editValue = dataObj.ufr.judge ? "1" : "0";
      // 静脈圧
      this.vpUpper.initValue = dataObj.vp.upper;
      this.vpUpper.editValue = dataObj.vp.upper;
      this.vpLower.initValue = dataObj.vp.lower;
      this.vpLower.editValue = dataObj.vp.lower;
      this.vpJudge.initValue = dataObj.vp.judge ? "1" : "0";
      this.vpJudge.editValue = dataObj.vp.judge ? "1" : "0";
      // ダイアライザ入口圧
      this.apUpper.initValue = dataObj.ap.upper;
      this.apUpper.editValue = dataObj.ap.upper;
      this.apLower.initValue = dataObj.ap.lower;
      this.apLower.editValue = dataObj.ap.lower;
      this.apJudge.initValue = dataObj.ap.judge ? "1" : "0";
      this.apJudge.editValue = dataObj.ap.judge ? "1" : "0";
      // Na濃度
      this.naConcUpper.initValue = dataObj.na_conc.upper;
      this.naConcUpper.editValue = dataObj.na_conc.upper;
      this.naConcLower.initValue = dataObj.na_conc.lower;
      this.naConcLower.editValue = dataObj.na_conc.lower;
      this.naConcJudge.initValue = dataObj.na_conc.judge ? "1" : "0";
      this.naConcJudge.editValue = dataObj.na_conc.judge ? "1" : "0";
      // 透析液温度
      this.dialysTempUpper.initValue = dataObj.dialys_temp.upper;
      this.dialysTempUpper.editValue = dataObj.dialys_temp.upper;
      this.dialysTempLower.initValue = dataObj.dialys_temp.lower;
      this.dialysTempLower.editValue = dataObj.dialys_temp.lower;
      this.dialysTempJudge.initValue = dataObj.dialys_temp.judge ? "1" : "0";
      this.dialysTempJudge.editValue = dataObj.dialys_temp.judge ? "1" : "0";
      // ΔBV変化率
      this.dBvRocUpper.initValue = dataObj.d_bv_roc.upper;
      this.dBvRocUpper.editValue = dataObj.d_bv_roc.upper;
      this.dBvRocLower.initValue = dataObj.d_bv_roc.lower;
      this.dBvRocLower.editValue = dataObj.d_bv_roc.lower;
      this.dBvRocJudge.initValue = dataObj.d_bv_roc.judge ? "1" : "0";
      this.dBvRocJudge.editValue = dataObj.d_bv_roc.judge ? "1" : "0";
      // LDQb
      this.ldqbUpper.initValue = dataObj.ldqb.upper;
      this.ldqbUpper.editValue = dataObj.ldqb.upper;
      this.ldqbLower.initValue = dataObj.ldqb.lower;
      this.ldqbLower.editValue = dataObj.ldqb.lower;
      this.ldqbJudge.initValue = dataObj.ldqb.judge ? "1" : "0";
      this.ldqbJudge.editValue = dataObj.ldqb.judge ? "1" : "0";
      // 血圧測定間隔
      this.bpmiInterval.initValue = dataObj.bpmi.interval;
      this.bpmiInterval.editValue = dataObj.bpmi.interval;
      this.bpmiJudge.initValue = dataObj.bpmi.judge ? "1" : "0";
      this.bpmiJudge.editValue = dataObj.bpmi.judge ? "1" : "0";
      // ケア間隔
      this.careiInterval.initValue = dataObj.care_i.interval;
      this.careiInterval.editValue = dataObj.care_i.interval;
      this.careiJudge.initValue = dataObj.care_i.judge ? "1" : "0";
      this.careiJudge.editValue = dataObj.care_i.judge ? "1" : "0";
    },
    /**
     * 変更有無チェック (実際にデータの差異を確認する処理)
     * @return 変更がある場合はtrueを返す
     */
    preCheckEdit() {
      // 初期値と変更値の差分を取得
      const differenceData = this.summarizeEditData();
      return 0 !== Object.keys(differenceData).length ? true : false;
    },
    /**
     * 変更チェック (上位Componentから呼び出される処理)
     */
    checkEdit(num) {
      if (1 === num) {
        // キャンセルボタンクリック時チェック
        if (this.preCheckEdit()) {
          // 変更箇所があれば変更を破棄するか確認メッセージを表示
          this.showMessage(20010001, "2");
          return true;
        }
      } else {
        // 保存ボタンクリック時チェック
        if (!this.preCheckEdit()) {
          // 変更箇所がなければ警告メッセージを表示
          this.showMessage(23020001, "1");
          return true;
        }
      }
    },
    /**
     * 編集データ集計
     */
    summarizeEditData(allFlg = false) {
      let rtn = {};
      // 最高血圧
      let bpMax = {};
      if (this.bpMaxUpper.initValue !== this.bpMaxUpper.editValue || allFlg) {
        bpMax.upper = this.bpMaxUpper.editValue;
      }
      if (this.bpMaxLower.initValue !== this.bpMaxLower.editValue || allFlg) {
        bpMax.lower = this.bpMaxLower.editValue;
      }
      /* mod #内部6474 by zhangruixue  --start */
      if (this.bpMaxJudge.initValue !== this.bpMaxJudge.editValue || allFlg
      || ((this.bpMaxUpper.initValue !== this.bpMaxUpper.editValue || this.bpMaxLower.initValue !== this.bpMaxLower.editValue) && this.bpMaxJudge.initValue == 1)) {
        bpMax.judge = this.bpMaxJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(bpMax).length !== 0) {
        rtn.bp_max = bpMax;
      }
      // 最低血圧
      let bpMin = {};
      if (this.bpMinUpper.initValue !== this.bpMinUpper.editValue || allFlg) {
        bpMin.upper = this.bpMinUpper.editValue;
      }
      if (this.bpMinLower.initValue !== this.bpMinLower.editValue || allFlg) {
        bpMin.lower = this.bpMinLower.editValue;
      }
      if (this.bpMinJudge.initValue !== this.bpMinJudge.editValue || allFlg
        || ((this.bpMinUpper.initValue !== this.bpMinUpper.editValue || this.bpMinLower.initValue !== this.bpMinLower.editValue) && this.bpMinJudge.initValue == 1)) {
        bpMin.judge = this.bpMinJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(bpMin).length !== 0) {
        rtn.bp_min = bpMin;
      }
      // 平均血圧
      let bpAve = {};
      if (this.bpAveUpper.initValue !== this.bpAveUpper.editValue || allFlg) {
        bpAve.upper = this.bpAveUpper.editValue;
      }
      if (this.bpAveLower.initValue !== this.bpAveLower.editValue || allFlg) {
        bpAve.lower = this.bpAveLower.editValue;
      }
      if (this.bpAveJudge.initValue !== this.bpAveJudge.editValue || allFlg
        || ((this.bpAveUpper.initValue !== this.bpAveUpper.editValue || this.bpAveLower.initValue !== this.bpAveLower.editValue) && this.bpAveJudge.initValue == 1)) {
        bpAve.judge = this.bpAveJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(bpAve).length !== 0) {
        rtn.bp_ave = bpAve;
      }
      // 脈拍
      let pulse = {};
      if (this.pulseUpper.initValue !== this.pulseUpper.editValue || allFlg) {
        pulse.upper = this.pulseUpper.editValue;
      }
      if (this.pulseLower.initValue !== this.pulseLower.editValue || allFlg) {
        pulse.lower = this.pulseLower.editValue;
      }
      if (this.pulseJudge.initValue !== this.pulseJudge.editValue || allFlg
        || ((this.pulseUpper.initValue !== this.pulseUpper.editValue || this.pulseLower.initValue !== this.pulseLower.editValue) && this.pulseJudge.initValue == 1)) {
        pulse.judge = this.pulseJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(pulse).length !== 0) {
        rtn.pulse = pulse;
      }
      // 血流量
      let bloodFlow = {};
      if (this.bloodFlowUpper.initValue !== this.bloodFlowUpper.editValue || allFlg) {
        bloodFlow.upper = this.bloodFlowUpper.editValue;
      }
      if (this.bloodFlowLower.initValue !== this.bloodFlowLower.editValue || allFlg) {
        bloodFlow.lower = this.bloodFlowLower.editValue;
      }
      if (this.bloodFlowJudge.initValue !== this.bloodFlowJudge.editValue || allFlg
        || ((this.bloodFlowUpper.initValue !== this.bloodFlowUpper.editValue || this.bloodFlowLower.initValue !== this.bloodFlowLower.editValue) && this.bloodFlowJudge.initValue == 1)) {
        bloodFlow.judge = this.bloodFlowJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(bloodFlow).length !== 0) {
        rtn.blood_flow = bloodFlow;
      }
      // IP速度
      let ipSpeed = {};
      if (this.ipSpeedUpper.initValue !== this.ipSpeedUpper.editValue || allFlg) {
        ipSpeed.upper = this.ipSpeedUpper.editValue;
      }
      if (this.ipSpeedLower.initValue !== this.ipSpeedLower.editValue || allFlg) {
        ipSpeed.lower = this.ipSpeedLower.editValue;
      }
      if (this.ipSpeedJudge.initValue !== this.ipSpeedJudge.editValue || allFlg
        || ((this.ipSpeedUpper.initValue !== this.ipSpeedUpper.editValue || this.ipSpeedLower.initValue !== this.ipSpeedLower.editValue) && this.ipSpeedJudge.initValue == 1)) {
        ipSpeed.judge = this.ipSpeedJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(ipSpeed).length !== 0) {
        rtn.ip_speed = ipSpeed;
      }
      // 除水速度
      let ufr = {};
      if (this.ufrUpper.initValue !== this.ufrUpper.editValue || allFlg) {
        ufr.upper = this.ufrUpper.editValue;
      }
      if (this.ufrLower.initValue !== this.ufrLower.editValue || allFlg) {
        ufr.lower = this.ufrLower.editValue;
      }
      if (this.ufrJudge.initValue !== this.ufrJudge.editValue || allFlg
        || ((this.ufrUpper.initValue !== this.ufrUpper.editValue || this.ufrLower.initValue !== this.ufrLower.editValue) && this.ufrJudge.initValue == 1)) {
        ufr.judge = this.ufrJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(ufr).length !== 0) {
        rtn.ufr = ufr;
      }
      // 静脈圧
      let vp = {};
      if (this.vpUpper.initValue !== this.vpUpper.editValue || allFlg) {
        vp.upper = this.vpUpper.editValue;
      }
      if (this.vpLower.initValue !== this.vpLower.editValue || allFlg) {
        vp.lower = this.vpLower.editValue;
      }
      if (this.vpJudge.initValue !== this.vpJudge.editValue || allFlg
        || ((this.vpUpper.initValue !== this.vpUpper.editValue || this.vpLower.initValue !== this.vpLower.editValue) && this.vpJudge.initValue == 1)) {
        vp.judge = this.vpJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(vp).length !== 0) {
        rtn.vp = vp;
      }
      // ダイアライザ入口圧
      let ap = {};
      if (this.apUpper.initValue !== this.apUpper.editValue || allFlg) {
        ap.upper = this.apUpper.editValue;
      }
      if (this.apLower.initValue !== this.apLower.editValue || allFlg) {
        ap.lower = this.apLower.editValue;
      }
      if (this.apJudge.initValue !== this.apJudge.editValue || allFlg
        || ((this.apUpper.initValue !== this.apUpper.editValue || this.apLower.initValue !== this.apLower.editValue) && this.apJudge.initValue == 1)) {
        ap.judge = this.apJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(ap).length !== 0) {
        rtn.ap = ap;
      }
      // Na濃度
      let naConc = {};
      if (this.naConcUpper.initValue !== this.naConcUpper.editValue || allFlg) {
        naConc.upper = this.naConcUpper.editValue;
      }
      if (this.naConcLower.initValue !== this.naConcLower.editValue || allFlg) {
        naConc.lower = this.naConcLower.editValue;
      }
      if (this.naConcJudge.initValue !== this.naConcJudge.editValue || allFlg
        || ((this.naConcUpper.initValue !== this.naConcUpper.editValue || this.naConcLower.initValue !== this.naConcLower.editValue) && this.naConcJudge.initValue == 1)) {
        naConc.judge = this.naConcJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(naConc).length !== 0) {
        rtn.na_conc = naConc;
      }
      // 透析液温度
      let dialysTemp = {};
      if (this.dialysTempUpper.initValue !== this.dialysTempUpper.editValue || allFlg) {
        dialysTemp.upper = this.dialysTempUpper.editValue;
      }
      if (this.dialysTempLower.initValue !== this.dialysTempLower.editValue || allFlg) {
        dialysTemp.lower = this.dialysTempLower.editValue;
      }
      if (this.dialysTempJudge.initValue !== this.dialysTempJudge.editValue || allFlg
        || ((this.dialysTempUpper.initValue !== this.dialysTempUpper.editValue || this.dialysTempLower.initValue !== this.dialysTempLower.editValue) && this.dialysTempJudge.initValue == 1)) {
        dialysTemp.judge = this.dialysTempJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(dialysTemp).length !== 0) {
        rtn.dialys_temp = dialysTemp;
      }
      // ΔBV変化率
      let dBvRoc = {};
      if (this.dBvRocUpper.initValue !== this.dBvRocUpper.editValue || allFlg) {
        dBvRoc.upper = this.dBvRocUpper.editValue;
      }
      if (this.dBvRocLower.initValue !== this.dBvRocLower.editValue || allFlg) {
        dBvRoc.lower = this.dBvRocLower.editValue;
      }
      if (this.dBvRocJudge.initValue !== this.dBvRocJudge.editValue || allFlg
        || ((this.dBvRocUpper.initValue !== this.dBvRocUpper.editValue || this.dBvRocLower.initValue !== this.dBvRocLower.editValue) && this.dBvRocJudge.initValue == 1)) {
        dBvRoc.judge = this.dBvRocJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(dBvRoc).length !== 0) {
        rtn.d_bv_roc = dBvRoc;
      }
      // LDQb
      let ldqb = {};
      if (this.ldqbUpper.initValue !== this.ldqbUpper.editValue || allFlg) {
        ldqb.upper = this.ldqbUpper.editValue;
      }
      if (this.ldqbLower.initValue !== this.ldqbLower.editValue || allFlg) {
        ldqb.lower = this.ldqbLower.editValue;
      }
      if (this.ldqbJudge.initValue !== this.ldqbJudge.editValue || allFlg
        || ((this.ldqbUpper.initValue !== this.ldqbUpper.editValue || this.ldqbLower.initValue !== this.ldqbLower.editValue) && this.ldqbJudge.initValue == 1)) {
        ldqb.judge = this.ldqbJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(ldqb).length !== 0) {
        rtn.ldqb = ldqb;
      }
      // 血圧測定間隔
      let bpmi = {};
      if (this.bpmiInterval.initValue !== this.bpmiInterval.editValue || allFlg) {
        bpmi.interval = this.bpmiInterval.editValue;
      }
      if (this.bpmiJudge.initValue !== this.bpmiJudge.editValue || allFlg
        || (this.bpmiInterval.initValue !== this.bpmiInterval.editValue  && this.bpmiJudge.initValue == 1)) {
        bpmi.judge = this.bpmiJudge.editValue === "1" ? true : false;
      }
      if (Object.keys(bpmi).length !== 0) {
        rtn.bpmi = bpmi;
      }
      // ケア間隔
      let carei = {};
      if (this.careiInterval.initValue !== this.careiInterval.editValue || allFlg) {
        carei.interval = this.careiInterval.editValue;
      }
      if (this.careiJudge.initValue !== this.careiJudge.editValue || allFlg
        || (this.careiInterval.initValue !== this.careiInterval.editValue  && this.careiJudge.initValue == 1)) {
        carei.judge = this.careiJudge.editValue === "1" ? true : false;
      }
      /* mod #内部6474 by zhangruixue  --end */
      if (Object.keys(carei).length !== 0) {
        rtn.care_i = carei;
      }
      return rtn;
    },
    /**
     * 更新処理(装置設定デフォルトマスタ、患者情報)
     */
    async updateInfo() {
      // 共通ローダーの表示開始
      this.startLoadingScreen();

      // 上限値と下限値の入力項目データの逆転チェック
      for (const limitedValue of this.limitedValuePair) {
        if (!this.isEmpty(limitedValue.upper.editValue) && !this.isEmpty(limitedValue.lower.editValue)) {
          if (Number(limitedValue.upper.editValue) < Number(limitedValue.lower.editValue)) {
            this.showMessage(12000348, "1", [limitedValue.name]);
            // 共通ローダーの表示終了
            this.finishLoadingScreen();
            return;
          }
        }
      }

      // 必須チェック
      const elements = [];
      for (const refKey in this.$refs) {
        const el = this.$refs[refKey];
        if (typeof el.isRequired === "undefined") {
          continue;
        }
        if (el.isRequired && el.editValue == null) {
          /*add FNSI-装置設定画面必須入力対象のスタイル調整 趙 start*/
          el.isValid = false;
          /*add FNSI-装置設定画面必須入力対象のスタイル調整 趙 end*/
          // 必須状態なのに、データが存在しないもの
          elements.push(el);
        }
      }
      if (elements.length !== 0) {
        // 未入力項目あり
        this.showMessage(22010001, "1", [elements[0].formName]);
        // 共通ローダーの表示終了
        this.finishLoadingScreen();
        return false;
      }
      // 初期値と変更値の差分を取得
      const differenceData = this.summarizeEditData();
      switch (this.dataSourceType) {
        // 装置設定デフォルトマスタ更新
        case 1:
          if (Object.keys(differenceData).length === 0) {
            this.showMessage(23020001, "1");
            break;
          }
          await this.updateMstDeviceSetInfoDefault(differenceData);
          // 患者情報にも反映をするかのメッセージを表示する
          this.showMessage(13010005, "5");
          break;
        // 患者情報更新
        case 2:
          // add #6512 個人装置画面の分の修正 劉 start
          if (Object.keys(differenceData).length === 0) {
            this.showMessage(23020001, "1");
            break;
          }
          // add #6512 個人装置画面の分の修正 劉 end
          await this.updatePatMain(differenceData);
          // モーダルを閉じる
          this.$parent.$parent.$emit("hide-modal");
          break;
        default:
          break;
      }
      // 共通ローダーの表示終了
      this.finishLoadingScreen();
    },
    /**
     * 装置設定デフォルトマスタ更新
     */
    async updateMstDeviceSetInfoDefault(updateData) {
      // 更新情報格納用
      const sendJson = {};
      // 施設コード
      sendJson.facility_cd = this.propsFacilityCd;
      // 更新情報
      sendJson.host_notification_info = JSON.stringify(updateData);
      // 更新日時
      sendJson.up_date = moment().format("YYYY-MM-DD HH:mm:ss.SSS");
      // dataSourceタイプ
      sendJson.data_source_type = this.dataSourceType;
      // データ更新
      await ApiHelper.post(
        "/deviceSetInfo/updateHostNotificationInfo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HostNoticeEditor.vue', 'updateMstDeviceSetInfoDefault', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // 共通ローダーの表示終了
        this.finishLoadingScreen();
        throw error;
      });
    },
    /**
     * 患者情報更新
     */
    async updatePatMain(updateData) {
      // 更新情報格納用
      const sendJson = {};
      // 患者ID
      sendJson.pat_id = this.propsPatId;
      // 施設コード
      sendJson.facility_cd = this.propsFacilityCd;
      // 更新情報
      sendJson.host_notification_info = JSON.stringify(updateData);
      // 更新日時(現在日時)
      sendJson.up_date = moment().format("YYYY-MM-DD HH:mm:ss.SSS");
      // dataSourceタイプ
      sendJson.data_source_type = this.dataSourceType;
      // データ更新
      await ApiHelper.post(
        "/deviceSetInfo/updateHostNotificationInfo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HostNoticeEditor.vue', 'updatePatMain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // 共通ローダーの表示終了
        this.finishLoadingScreen();
        throw error;
      });
    },
    /**
     * 患者情報に装置設定デフォルトマスタで編集した内容を反映
     */
    async reflectPatInfo() {
      // 更新情報格納用
      const sendJson = {};
      // 施設コード
      sendJson.facility_cd = this.propsFacilityCd;
      // 更新情報
      sendJson.host_notification_info = JSON.stringify(await this.summarizeEditData(true));
      // 更新日時(現在日時)
      sendJson.up_date = moment().format("YYYY-MM-DD HH:mm:ss.SSS");
      // dataSourceタイプ(患者情報更新 = 2)
      sendJson.data_source_type = 2;
      // データ更新
      await ApiHelper.post(
        "/deviceSetInfo/updateHostNotificationInfo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('HostNoticeEditor.vue', 'reflectPatInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // 共通ローダーの表示終了
        this.finishLoadingScreen();
        throw error;
      });
    },
    /**
     * 親でメッセージ表示を行う
     * @param code メッセージコード
     * @param type メッセージタイプ
     * @param stringParams メッセージ置換文字列
     * @param targetName メッセージ表示対象名 ex.FUTURE_ORD_MAIN(未来指示)
     */
    showMessage(code, type, stringParams, targetName) {
      // メッセージコードを格納
      this.$parent.$parent.messageDialogInfo.messageCd = code;
      // メッセージタイプを格納
      this.$parent.$parent.messageDialogInfo.type = type;
      // メッセージ置換文字列を格納
      this.$parent.$parent.messageDialogInfo.stringParams =
        undefined !== stringParams ? stringParams : [];
      // メッセージ表示対象名を格納
      this.$parent.$parent.messageDialogInfo.targetName = targetName;
      // メッセージを表示
      setTimeout(() => {
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
      }, 10);
    },
    // del #10359 編集権限の動作不正 dengshen start
    // // add FNSI-改修内容 権限関連 趙 start
    // getDailyCheckAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.PAT_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT);
    // },
    // // add FNSI-改修内容 権限関連 趙 end
    // del #10359 編集権限の動作不正 dengshen end

  }
};
</script>

<style src="../base-modules/BeseDeviceSetInfoStyle.css" scoped></style>
<style>
.header-padding {
  padding: 3px 5px;
}
.v-align-center {
  display: flex;
  align-items: center;
}
</style>
