import { LogClass } from "@/models/master-maintenance/mst-alarm-notification/LogClass";
import { TargetModel } from "@/models/master-maintenance/mst-alarm-notification/TargetModel";

/**
 * 装置記録（machine_record）を表現するクラス
 */
export class MachineRecord {
  constructor(cd, message, is_default, log_class, target_model, beSendEmail) {
    this.cd = cd;
    this.message = message;
    this.isDefault = is_default;
    this.logClass = log_class || 0;
    this.targetModel = target_model || 0;
    // 送信対象の装置記録かどうか
    this.beSendEmail = beSendEmail;
  }
  get recordContent() {
    return `${this.cd}${this.message}`;
  }
  get logClassName() {
    return this.logClass === 0 ? "" : LogClass[this.logClass];
  }
  get targetModelName() {
    return this.targetModel === 0 ? "" : TargetModel[this.targetModel];
  }
}
