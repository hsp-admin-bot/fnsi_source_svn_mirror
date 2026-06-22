import EventIconDefs from "@/models/treatment-record/bvms/event-icon-defs.json";

export class EventIcon {
  constructor() {
    this.list = EventIconDefs && EventIconDefs.event_icon_defs && EventIconDefs.event_icon_defs.event_items;
  }

  getIcon(cd) {
    return this.list && this.list.find(x => x.cd === cd);
  }

  getIconPath(cd) {
    let icon = this.getIcon(cd);
    return icon && icon.path;
  }

  getIconName(cd) {
    let icon = this.getIcon(cd);
    return icon && icon.name;
  }
}
