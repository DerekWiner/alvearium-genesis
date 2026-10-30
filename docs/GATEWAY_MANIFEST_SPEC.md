# Genesis Gateway Manifest Specification

**Status:** Provisional design draft  
**Version:** 0.1.0  
**Schema:** [gateway-manifest.schema.json](../schemas/gateway-manifest.schema.json)  
**Normative status:** Not yet ratified. Changes are expected before implementation compatibility is promised.

## 1. Purpose

A Gateway Manifest is a machine-readable description published by a Genesis gateway. It gives another implementation a small, predictable starting point for identifying the gateway, understanding declared relationships, discovering interfaces, and evaluating declared capabilities.

A manifest is a description, not the gateway itself. It is not an execution environment, identity authority, permission grant, trust certificate, proof of availability, or proof that declared behaviour is real.

The first schema deliberately describes only a limited set of shared concepts. Implementations may maintain richer internal models.

## 2. Design constraints

The v0.1.0 draft follows these constraints.

- A gateway identifier is an identifier, not an owner field.
- No NFT, blockchain, DID method, key algorithm, runtime, hosting provider, or agent framework is mandatory.
- A gateway may publish no public interfaces or capabilities.
- Lineage records describe relationships. They do not create ownership or inherited authority.
- Capability declarations are descriptive. Actual permissions require a separate capability and delegation mechanism.
- Optional extensions are namespaced. Unknown non-critical extensions may be ignored. Unknown critical extensions must not be silently treated as understood.
- A manifest revision is local to the gateway. It is not a global ordering mechanism.
- A manifest can be public, selectively disclosed, or distributed through a private channel. The schema does not require public publication.

## 3. Required fields

| Field | Meaning |
|---|---|
| `protocol` | Fixed protocol family identifier, `alvearium-genesis` |
| `manifestVersion` | Version of this manifest schema, currently `0.1.0` |
| `id` | Gateway identifier expressed as a URI |
| `created` | Creation time expressed as an RFC 3339 date-time |
| `revision` | Positive integer revision selected by the gateway |

The `id` field intentionally accepts different URI-based identity approaches. A deployment may use a DID, an opaque URN, a chain-specific identifier, or another URI scheme. Consumers must not assume that URI syntax alone proves control of the identifier.

## 4. Optional fields

- `displayName` and `description` provide human-readable context.
- `createdBy` is an optional creator reference. It does not establish ownership or current authority.
- `identity` describes an identity method and subject reference. It does not itself prove that the publisher controls that subject.
- `lineage` records one or more explicit ancestry or derivation relationships.
- `interfaces` describes discoverable protocols, versions, endpoints and roles.
- `capabilities` declares what the gateway says it offers or requires. It does not grant access.
- `policies` references policy documents or policy descriptions.
- `extensions` carries namespaced implementation-specific data.

The `updated` field is optional. When present, it should represent the time of the current manifest revision. Implementations should increment `revision` when publishing a materially changed manifest.

## 5. Identity, creator and authority are separate

The manifest does not define a universal controller or owner field. A gateway may be operated by an individual, a collective, an agent, a federation, or an arrangement not represented by a single controller.

A creator reference is historical attribution, not continuing control. Identity verification is a separate operation. Authority is established only through a capability or delegation mechanism that defines the subject, action, scope, constraints and lifecycle.

Do not infer permission from any of the following alone:

- possession of a gateway identifier;
- appearing in `createdBy`;
- appearing in a lineage record;
- publishing an interface or capability;
- signing a manifest with a key that has not been linked to the relevant authority.

## 6. Lineage semantics

The initial relationship values are deliberately narrow.

- `spawned-from` — the publisher asserts that the gateway was instantiated from or by the referenced gateway.
- `forked-from` — the publisher asserts that its implementation or state diverged from the referenced gateway.
- `derived-from` — the publisher asserts a derivation relationship that is not adequately described by the other two terms.

A lineage entry is a claim. The optional `evidence` URI points to material that a verifier may inspect. A consumer should preserve the distinction between an asserted relationship and a cryptographically verified relationship.

No lineage relationship implies key inheritance, ownership, policy inheritance, command authority, or a right to revoke the descendant's existence.

Federation, recognition and endorsement are intentionally not lineage types. They are separate relationships and should be modelled separately if needed.

## 7. Interfaces and capabilities

An interface entry describes a protocol and version at an endpoint. It does not guarantee that the endpoint is online, safe, authentic or compatible. Consumers should negotiate versions and validate the remote party before sending sensitive data or granting authority.

Capability entries use `offers` and `requires` to distinguish direction. They are discovery metadata only. They must not be treated as bearer tokens, access-control rules or delegated permissions.

The future capability specification should define signed, scoped, time-bounded and revocable or expiring grants where supported. It should be developed separately from this manifest schema.

## 8. Extensions and criticality

Extension keys must be URI-style namespaced identifiers. Each extension contains:

- `critical` — whether understanding the extension is required to safely interpret the manifest;
- `value` — extension-defined data.

A consumer that does not understand a non-critical extension may ignore it while preserving it if it reserialises the manifest. A consumer that encounters an unknown critical extension must reject the manifest for the relevant operation or mark it unsupported. It must not silently proceed as if the extension had no effect.

The JSON Schema checks the extension envelope, not the semantics of every extension. Extension specifications must define their own schema, versioning and security implications.

## 9. Canonicalisation, hashing and signatures

The manifest hash must be computed over a canonical representation, not arbitrary JSON text. The proposed canonicalisation method is JSON Canonicalization Scheme (JCS), RFC 8785.

Proposed digest procedure:

1. Parse the JSON and validate it against the applicable schema.
2. Reject duplicate object member names. Do not rely on parser-specific duplicate-key behaviour.
3. Canonicalise the JSON data using RFC 8785.
4. Encode the canonical result as UTF-8.
5. Compute SHA-256 over those bytes.
6. Represent the digest as a 32-byte value or a clearly labelled `sha256` multihash-style string.

The digest identifies a particular manifest revision. A change to any canonicalised field produces a different digest.

Signatures should be detached from the manifest bytes to avoid self-referential hashing. A future signature envelope must identify the digest, signature algorithm, key reference, signer claim and relevant domain separation or context. Verification must establish that the signing key is authorised for the claimed operation. A valid signature alone does not establish that the signer is trustworthy or that the manifest is true.

JCS and SHA-256 are proposed defaults for the first implementation, not a permanent cryptographic commitment for all future Genesis deployments. Algorithm agility and migration must be addressed before production use.

## 10. Publication and privacy

The schema does not require every field to be public. Gateways should avoid publishing private keys, personal information, internal network addresses, sensitive capabilities, private policy details or operational metadata that creates unnecessary attack surface.

A public manifest may point to selectively disclosed information. Consumers must treat remote manifests and endpoint references as untrusted input. Fetching referenced resources can create SSRF, tracking, malware and data-exfiltration risks. A future resolver or discovery specification must define safe retrieval rules.

## 11. Versioning and compatibility

`manifestVersion` identifies the schema contract, not the software release. A gateway's implementation version may be declared through a namespaced extension or an interface-specific field in a later revision.

A consumer must validate against a schema version it supports. It must not silently reinterpret an unknown manifest version as the current one. A newer manifest version may be rejected, handled through a compatible adapter, or treated as partially understood under an explicitly defined compatibility profile.

The top-level schema rejects unknown fields. Extensibility is provided through the explicit `extensions` object so that security-sensitive semantics are not accidentally hidden in arbitrary top-level properties.

## 12. Example

This is an illustrative manifest only. The identifiers and endpoint are placeholders and do not refer to a live gateway.

```json
{
  "protocol": "alvearium-genesis",
  "manifestVersion": "0.1.0",
  "id": "urn:uuid:8a6e5c4a-2d9f-4b18-9f20-1e4c5a7b8d90",
  "created": "2026-10-30T00:00:00Z",
  "revision": 1,
  "displayName": "Example Gateway",
  "identity": {
    "method": "example-key-method",
    "subject": "did:example:gateway-123"
  },
  "lineage": [
    {
      "relationship": "spawned-from",
      "gateway": "urn:uuid:123e4567-e89b-12d3-a456-426614174000"
    }
  ],
  "interfaces": [
    {
      "id": "urn:uuid:11111111-2222-4333-8444-555555555555",
      "protocol": "example-agent-interface",
      "version": "1.0",
      "endpoint": "https://gateway.example.invalid/agent"
    }
  ],
  "capabilities": [
    {
      "id": "urn:example:capability:public-status",
      "direction": "offers",
      "description": "Returns public gateway status."
    }
  ],
  "extensions": {
    "https://example.invalid/genesis/extensions/runtime": {
      "critical": false,
      "value": {
        "family": "example-runtime"
      }
    }
  }
}
```

## 13. Known limitations and unresolved decisions

This draft does not yet define:

- a globally unique identifier allocation method;
- proof of control over a gateway identifier;
- a detached signature envelope;
- a capability grant or delegation format;
- discovery, endpoint resolution or safe remote fetching;
- federation, recognition or endorsement records;
- manifest revocation, supersession or archival rules;
- privacy-preserving selective disclosure;
- an implementation version convention;
- a production cryptographic profile.

These are deliberate boundaries. They should be addressed in separate specifications or later revisions rather than added casually to the first manifest.

## 14. Initial implementation acceptance tests

The first validator should demonstrate at least:

1. A valid minimal manifest is accepted.
2. A manifest missing any required field is rejected.
3. An unsupported `manifestVersion` is rejected.
4. A malformed gateway identifier URI is rejected by a format-aware validator.
5. A manifest with an unknown top-level field is rejected.
6. A namespaced non-critical extension is accepted.
7. A namespaced critical extension has its criticality surfaced to the consumer.
8. A lineage entry does not create or imply authority.
9. Capability declarations are not interpreted as grants.
10. Two JSON serialisations of the same data produce the same JCS bytes and SHA-256 digest.
11. Changing a field changes the digest.
12. Duplicate JSON object keys are rejected before canonicalisation.

Passing these tests demonstrates the validator's stated behaviour. It does not establish the truth of a gateway's claims or the security of its runtime.

---

**Status note:** This is a working protocol draft. The schema and canonicalisation choices require implementation tests and independent review before being treated as stable interoperability commitments.
