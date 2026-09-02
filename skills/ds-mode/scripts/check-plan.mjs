#!/usr/bin/env node

import { readFileSync } from "node:fs";

const path = process.argv[2];
if (!path) {
  console.error("usage: check-plan.mjs <plan.md>");
  process.exit(2);
}

const text = readFileSync(path, "utf8");
const required = [
  "## How to read this",
  "## Program checklist",
  "## Close the program",
  "## Appendix A. Prototype evidence",
  "## Appendix B. Alternatives rejected",
  "## Appendix C. Risks",
];
const unitFields = [
  "**Depends on.**",
  "**Owner.**",
  "**Writable paths.**",
  "**Checkout.**",
  "**Build.**",
  "**You see.**",
  "**Verify.**",
  "**Delivery.**",
];
const nonUnitHeadings = new Set([
  "How to read this",
  "Program checklist",
  "Close the program",
  "Appendix A. Prototype evidence",
  "Appendix B. Alternatives rejected",
  "Appendix C. Risks",
]);
const forbidden = [
  ["/goal", "automatic goal loops are inactive"],
  ["/loop", "automatic polling loops are inactive"],
  ["Graphite", "Graphite is inactive"],
  ["cloud VM", "cloud workers are inactive"],
  ["automatic merge", "automatic merging is inactive"],
];

const errors = [];
for (const heading of required) {
  if (!text.includes(heading)) errors.push(`missing ${heading}`);
}
if (!/^# .+ plan$/m.test(text)) errors.push("missing '# <Program> plan' title");
if (!text.includes("worker role") || !text.includes("canonical child target")) errors.push("missing worker role or canonical-child ownership");
if (!text.includes("worktree") && !text.includes("checkout")) errors.push("missing checkout or worktree decision");

const headingPattern = /^## (.+)$/gm;
const headings = [...text.matchAll(headingPattern)];
const units = [];
for (let index = 0; index < headings.length; index += 1) {
  const title = headings[index][1];
  if (nonUnitHeadings.has(title)) continue;
  const start = headings[index].index;
  const next = headings.find((heading) => heading.index > start);
  const body = text.slice(start, next?.index ?? text.length);
  units.push({ title, body });
}

if (units.length === 0) errors.push("missing task-shaped unit");
for (const unit of units) {
  if (!/^.+ \([^)<>]+\)$/.test(unit.title)) {
    errors.push(`invalid task-shaped unit heading: ## ${unit.title}`);
  }
  for (const field of unitFields) {
    if (!unit.body.includes(field)) errors.push(`unit '${unit.title}' missing ${field}`);
  }
  if (!unit.body.includes("pass predicate")) {
    errors.push(`unit '${unit.title}' missing exact verification pass predicate`);
  }
}

const placeholders = [...text.matchAll(/<[^>\n]+>/g)].map((match) => match[0]);
if (placeholders.length) errors.push(`unfilled placeholders: ${[...new Set(placeholders)].join(", ")}`);
for (const [needle, reason] of forbidden) {
  if (text.includes(needle)) errors.push(`${reason}: found ${needle}`);
}

if (errors.length) {
  for (const error of errors) console.error(error);
  process.exit(1);
}
console.log(`plan contract ok: ${path}`);
