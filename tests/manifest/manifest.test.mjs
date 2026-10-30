import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import Ajv2020 from "ajv/dist/2020.js";
import addFormats from "ajv-formats";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "../..");
const schema = JSON.parse(
  fs.readFileSync(path.join(root, "schemas/gateway-manifest.schema.json"), "utf8")
);
const ajv = new Ajv2020({ allErrors: true, strict: true });
addFormats(ajv);
const validate = ajv.compile(schema);

function fixture(name) {
  return JSON.parse(
    fs.readFileSync(path.join(here, "fixtures", name), "utf8")
  );
}

test("accepts a minimal valid gateway manifest", () => {
  assert.equal(validate(fixture("minimal.json")), true);
});

test("accepts a recursive gateway manifest with lineage and extensions", () => {
  assert.equal(validate(fixture("recursive.json")), true);
});

test("rejects a manifest missing a required field", () => {
  const manifest = fixture("minimal.json");
  delete manifest.id;
  assert.equal(validate(manifest), false);
});

test("rejects an unsupported manifest schema version", () => {
  const manifest = fixture("minimal.json");
  manifest.manifestVersion = "9.9.9";
  assert.equal(validate(manifest), false);
});

test("rejects unknown top-level fields", () => {
  const manifest = fixture("minimal.json");
  manifest.owner = "did:example:someone";
  assert.equal(validate(manifest), false);
});

test("accepts namespaced non-critical extensions", () => {
  const manifest = fixture("minimal.json");
  manifest.extensions = {
    "https://example.invalid/extensions/demo": {
      critical: false,
      value: { enabled: true }
    }
  };
  assert.equal(validate(manifest), true);
});

test("rejects extension keys without a URI-style namespace", () => {
  const manifest = fixture("minimal.json");
  manifest.extensions = {
    demo: { critical: false, value: {} }
  };
  assert.equal(validate(manifest), false);
});

test("rejects malformed lineage relationships", () => {
  const manifest = fixture("recursive.json");
  manifest.lineage[0].relationship = "owns";
  assert.equal(validate(manifest), false);
});
