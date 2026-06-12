import { describe, expect, test } from "vitest";
import { createApp, nextTick } from "@/compat/vue/runtime";

describe("Vue2 instance compatibility", () => {
  test("allows legacy primitive comparisons against component refs in arrays", async () => {
    const Child = {
      template: "<span></span>",
      data() {
        return {
          isRequired: true,
          editValue: true
        };
      }
    };
    const Root = {
      components: { Child },
      template: '<div><Child v-for="item in items" :key="item" ref="move_in_out" /></div>',
      data() {
        return {
          items: [1]
        };
      },
      methods: {
        isRefPresent() {
          return this.$refs.move_in_out != "";
        }
      }
    };
    const host = document.createElement("div");
    document.body.appendChild(host);
    const app = createApp(Root);
    const vm = app.mount(host);

    await nextTick();

    expect(vm.isRefPresent()).toBe(true);

    app.unmount();
    host.remove();
  });
});
