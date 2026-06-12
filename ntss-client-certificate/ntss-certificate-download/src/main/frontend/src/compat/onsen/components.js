import VueOnsen from "vue-onsenui";
import * as VueOnsenComponents from "vue-onsenui/esm/components";
import { h } from "vue";

const {
  VOnsCol,
  VOnsIcon,
  VOnsInput: RawVOnsInput,
  VOnsModal,
  VOnsRow
} = VueOnsenComponents;

function installOnsInputEventBridge(host) {
  if (!host || host.__ntssOnsInputEventBridge) {
    return;
  }
  const input = host._input || host.querySelector?.("input, textarea, select");
  if (!input) {
    return;
  }
  host.__ntssOnsInputEventBridge = true;
  const syncValue = (eventType) => {
    try {
      host.value = input.value;
    } catch {
      // noop
    }
    host.dispatchEvent(new Event(eventType, { bubbles: true }));
  };
  input.addEventListener("input", () => syncValue("input"));
  input.addEventListener("change", () => syncValue("change"));
}

function withOnsInputEventBridge(attrs) {
  const forwardedAttrs = { ...attrs };
  const originalMounted = forwardedAttrs.onVnodeMounted;
  const originalUpdated = forwardedAttrs.onVnodeUpdated;
  forwardedAttrs.onVnodeMounted = (vnode) => {
    originalMounted?.(vnode);
    installOnsInputEventBridge(vnode.el);
  };
  forwardedAttrs.onVnodeUpdated = (vnode) => {
    originalUpdated?.(vnode);
    installOnsInputEventBridge(vnode.el);
  };
  return forwardedAttrs;
}

const VOnsInput = {
  name: "VOnsInput",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => h(RawVOnsInput, withOnsInputEventBridge(attrs), slots);
  }
};

const components = [
  VOnsCol,
  VOnsIcon,
  VOnsInput,
  VOnsModal,
  VOnsRow
].filter(Boolean);

const VueOnsenBridge = {
  install(app) {
    app.use(VueOnsen);
    components.forEach((component) => {
      if (component?.name) {
        app.component(component.name, component);
      }
    });
  }
};

export default VueOnsenBridge;
export { VOnsCol, VOnsIcon, VOnsInput, VOnsModal, VOnsRow };
