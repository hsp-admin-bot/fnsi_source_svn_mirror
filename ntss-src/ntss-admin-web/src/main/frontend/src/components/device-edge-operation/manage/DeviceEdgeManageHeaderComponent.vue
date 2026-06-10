
<template>
  <div class="header-item header-device-edge-manage">
    <div class="mark-leftmost-header">
      <div class="header-device-edge-manage-label">
        <label>部署：{{getSelectedDeviceEdge.departmentCd}}</label>
        <label>【{{getSelectedDeviceEdge.facilityName}}】</label>
      </div>
      <div class="header-device-edge-manage-label">
        <label>製造番号：[{{getSelectedDeviceEdge.serialNo}}] </label>
        <label>{{getSelectedDeviceEdge.deviceName}}</label>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  computed: {
    ...mapGetters("device-edge-manage", ["getSelectedDeviceEdge"])
  }
};
</script>
<style scoped>
.header-device-edge-manage {
  display: flex;
  align-items: center;
}
.header-device-edge-manage-label {
  font-size: 1.5em;
}
</style>
