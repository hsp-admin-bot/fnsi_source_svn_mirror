import { afterEach, describe, expect, test } from "vitest";
import { findKendoGridBodyRows, findKendoGridLockedRows, findKendoGridLogicalTable } from "@/compat/kendo/dom.js";

function createKendo2026LockedGrid() {
  const root = document.createElement("div");
  root.className = "k-grid";
  root.innerHTML = `
    <div class="k-grid-container">
      <div class="k-grid-content-locked">
        <table class="k-grid-table">
          <tbody>
            <tr id="locked-1"></tr>
            <tr id="locked-2"></tr>
          </tbody>
        </table>
      </div>
      <div class="k-grid-content k-auto-scrollable">
        <table class="k-grid-table">
          <tbody>
            <tr id="body-1"></tr>
            <tr id="body-2"></tr>
          </tbody>
        </table>
      </div>
    </div>
  `;
  document.body.appendChild(root);
  return root;
}

afterEach(() => {
  document.body.innerHTML = "";
});

describe("Kendo grid DOM compatibility", () => {
  test("keeps locked rows out of the canonical body row collection", () => {
    const root = createKendo2026LockedGrid();

    expect(findKendoGridBodyRows(root).map((row) => row.id)).toEqual(["body-1", "body-2"]);
    expect(findKendoGridLockedRows(root).map((row) => row.id)).toEqual(["locked-1", "locked-2"]);
  });

  test("builds one logical table from locked and body row pairs", () => {
    const root = createKendo2026LockedGrid();
    const logicalTable = findKendoGridLogicalTable(root);

    expect(logicalTable.rows.map((row) => [
      row.lockedRow?.id,
      row.bodyRow?.id
    ])).toEqual([
      ["locked-1", "body-1"],
      ["locked-2", "body-2"]
    ]);
  });
});
