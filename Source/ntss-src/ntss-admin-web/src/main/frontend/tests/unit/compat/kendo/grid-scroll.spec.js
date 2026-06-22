import { afterEach, describe, expect, test } from "vitest";
import { attachKendoGridLockedContentScrollSync, attachKendoGridLockedLayoutRepair, repairKendoGridLockedColumnLayout } from "@/compat/kendo/grid-scroll.js";

function createLockedGrid({ virtual = false } = {}) {
  const root = document.createElement("div");
  root.className = "k-grid";
  root.innerHTML = `
    <div class="k-grid-header">
      <div class="k-grid-header-wrap"></div>
    </div>
    <div class="k-grid-content-locked"></div>
    <div class="k-grid-content k-auto-scrollable">
      ${virtual ? '<div class="k-virtual-scrollable-wrap"><div></div></div>' : "<div></div>"}
    </div>
    <div class="k-scrollbar k-scrollbar-vertical"><div></div></div>
  `;
  document.body.appendChild(root);
  return root;
}

function createLockedGridWithRows({ masterMaintenance = false } = {}) {
  const host = masterMaintenance ? document.createElement("div") : null;
  if (host) {
    host.className = "master-maintenance-page";
    document.body.appendChild(host);
  }
  const root = document.createElement("div");
  root.className = "k-grid ntss-kendo-grid-legacy";
  root.innerHTML = `
    <div class="k-grid-content-locked">
      <table>
        <tbody>
          <tr id="locked-1"><td id="locked-cell-1">ENin03</td></tr>
          <tr id="locked-2"><td id="locked-cell-2">ENin04</td></tr>
        </tbody>
      </table>
    </div>
    <div class="k-grid-content k-auto-scrollable">
      <table>
        <tbody>
          <tr id="body-1"><td id="body-cell-1">二ノミヤクリニックE03</td></tr>
          <tr id="body-2"><td id="body-cell-2">神奈川県</td></tr>
        </tbody>
      </table>
    </div>
    <div class="k-scrollbar k-scrollbar-vertical"><div></div></div>
  `;
  (host || document.body).appendChild(root);
  return root;
}

function setElementHeight(element, height) {
  element.__naturalTestHeight = height;
  const readHeight = () => Number.parseFloat(element.style.height || "") || element.__naturalTestHeight || 0;
  Object.defineProperty(element, "offsetHeight", { get: readHeight, configurable: true });
  Object.defineProperty(element, "clientHeight", { get: readHeight, configurable: true });
  element.getBoundingClientRect = () => ({ height: readHeight() });
}

function waitForRepairFrame() {
  return new Promise((resolve) => setTimeout(resolve, 32));
}

afterEach(() => {
  document.body.innerHTML = "";
});

describe("Kendo locked grid scroll compatibility", () => {
  test("keeps non-virtual locked content synced from the vertical scrollbar", () => {
    const root = createLockedGrid();
    const lockedContent = root.querySelector(".k-grid-content-locked");
    const verticalScrollbar = root.querySelector(".k-scrollbar-vertical");

    const cleanup = attachKendoGridLockedContentScrollSync(root);
    verticalScrollbar.scrollTop = 240;
    verticalScrollbar.dispatchEvent(new Event("scroll"));

    expect(lockedContent.scrollTop).toBe(240);
    cleanup();
  });

  test("does not let compat write virtual scrollbar movement back through locked content", () => {
    const root = createLockedGrid({ virtual: true });
    const lockedContent = root.querySelector(".k-grid-content-locked");
    const virtualWrap = root.querySelector(".k-virtual-scrollable-wrap");
    const verticalScrollbar = root.querySelector(".k-scrollbar-vertical");

    const cleanup = attachKendoGridLockedContentScrollSync(root, { virtual: true });
    verticalScrollbar.scrollTop = 240;
    verticalScrollbar.dispatchEvent(new Event("scroll"));

    expect(lockedContent.scrollTop).toBe(0);
    expect(virtualWrap.scrollTop).toBe(0);
    expect(verticalScrollbar.scrollTop).toBe(240);
    cleanup();
  });

  test("repairs locked layout without resetting locked content to content scrollTop zero", () => {
    const root = createLockedGrid();
    const lockedContent = root.querySelector(".k-grid-content-locked");
    const content = root.querySelector(".k-grid-content");
    const verticalScrollbar = root.querySelector(".k-scrollbar-vertical");

    Object.defineProperty(content, "clientHeight", { value: 200, configurable: true });
    Object.defineProperty(content, "scrollHeight", { value: 1000, configurable: true });
    Object.defineProperty(lockedContent, "clientHeight", { value: 200, configurable: true });
    Object.defineProperty(lockedContent, "scrollHeight", { value: 1000, configurable: true });

    content.scrollTop = 0;
    verticalScrollbar.scrollTop = 240;

    repairKendoGridLockedColumnLayout(root);

    expect(lockedContent.scrollTop).toBe(240);
  });

  test("does not let locked content scroll become a separate vertical source", () => {
    const root = createLockedGrid();
    const lockedContent = root.querySelector(".k-grid-content-locked");
    const content = root.querySelector(".k-grid-content");
    const verticalScrollbar = root.querySelector(".k-scrollbar-vertical");

    const cleanup = attachKendoGridLockedContentScrollSync(root);
    content.scrollTop = 320;
    verticalScrollbar.scrollTop = 320;
    lockedContent.scrollTop = 40;
    lockedContent.dispatchEvent(new Event("scroll"));

    expect(content.scrollTop).toBe(320);
    expect(verticalScrollbar.scrollTop).toBe(320);
    expect(lockedContent.scrollTop).toBe(320);
    cleanup();
  });

  test("repairs locked and body rows as one logical row height", () => {
    const root = createLockedGridWithRows();
    const lockedRow = root.querySelector("#locked-1");
    const bodyRow = root.querySelector("#body-1");

    setElementHeight(lockedRow, 32);
    setElementHeight(bodyRow, 48);

    repairKendoGridLockedColumnLayout(root);

    expect(lockedRow.style.height).toBe("48px");
    expect(bodyRow.style.height).toBe("48px");
    expect(root.querySelector("#locked-cell-1").style.height).toBe("48px");
    expect(root.querySelector("#body-cell-1").style.height).toBe("48px");
  });

  test("uses locked row height as the master maintenance logical row height", () => {
    const root = createLockedGridWithRows({ masterMaintenance: true });
    const lockedRow = root.querySelector("#locked-1");
    const bodyRow = root.querySelector("#body-1");

    setElementHeight(lockedRow, 40);
    setElementHeight(bodyRow, 41);

    repairKendoGridLockedColumnLayout(root);

    expect(lockedRow.style.height).toBe("40px");
    expect(bodyRow.style.height).toBe("40px");
    expect(root.querySelector("#locked-cell-1").style.height).toBe("40px");
    expect(root.querySelector("#body-cell-1").style.height).toBe("40px");
    expect(root.querySelector("#body-cell-1").style.getPropertyValue("line-height")).toBe("");
  });

  test("keeps master maintenance edit rows tall enough for their editor", () => {
    const root = createLockedGridWithRows({ masterMaintenance: true });
    const lockedRow = root.querySelector("#locked-1");
    const bodyRow = root.querySelector("#body-1");

    bodyRow.classList.add("k-grid-edit-row");
    setElementHeight(lockedRow, 40);
    setElementHeight(bodyRow, 58);

    repairKendoGridLockedColumnLayout(root);

    expect(lockedRow.style.height).toBe("58px");
    expect(bodyRow.style.height).toBe("58px");
    expect(root.querySelector("#locked-cell-1").style.height).toBe("58px");
    expect(root.querySelector("#body-cell-1").style.height).toBe("58px");
    expect(bodyRow.querySelector("td").style.getPropertyValue("line-height")).toBe("");
  });

  test("remeasures reused rows before applying logical row height", () => {
    const root = createLockedGridWithRows();
    const lockedRow = root.querySelector("#locked-1");
    const bodyRow = root.querySelector("#body-1");

    setElementHeight(lockedRow, 32);
    setElementHeight(bodyRow, 60);
    repairKendoGridLockedColumnLayout(root);

    setElementHeight(lockedRow, 36);
    setElementHeight(bodyRow, 30);
    repairKendoGridLockedColumnLayout(root);

    expect(lockedRow.style.height).toBe("36px");
    expect(bodyRow.style.height).toBe("36px");
  });

  test("keeps scroll sync lightweight without remeasuring logical rows on scroll", () => {
    const root = createLockedGridWithRows();
    const lockedContent = root.querySelector(".k-grid-content-locked");
    const content = root.querySelector(".k-grid-content");
    const verticalScrollbar = root.querySelector(".k-scrollbar-vertical");
    const lockedRow = root.querySelector("#locked-1");
    const bodyRow = root.querySelector("#body-1");

    setElementHeight(lockedRow, 32);
    setElementHeight(bodyRow, 60);
    repairKendoGridLockedColumnLayout(root);

    const cleanup = attachKendoGridLockedContentScrollSync(root);
    setElementHeight(lockedRow, 36);
    setElementHeight(bodyRow, 30);
    content.scrollTop = 180;
    content.dispatchEvent(new Event("scroll"));

    expect(lockedContent.scrollTop).toBe(180);
    expect(verticalScrollbar.scrollTop).toBe(180);
    expect(lockedRow.style.height).toBe("60px");
    expect(bodyRow.style.height).toBe("60px");
    cleanup();
  });

  test("repairs logical row heights when grid rows are rebound", async () => {
    const root = createLockedGridWithRows();
    const lockedRow = root.querySelector("#locked-1");
    const bodyRow = root.querySelector("#body-1");
    const bodyTbody = root.querySelector(".k-grid-content tbody");

    setElementHeight(lockedRow, 32);
    setElementHeight(bodyRow, 40);
    const cleanup = attachKendoGridLockedLayoutRepair(root);
    await waitForRepairFrame();

    setElementHeight(lockedRow, 36);
    setElementHeight(bodyRow, 58);
    bodyTbody.appendChild(document.createElement("tr"));
    await waitForRepairFrame();

    expect(lockedRow.style.height).toBe("58px");
    expect(bodyRow.style.height).toBe("58px");
    cleanup();
  });
});
