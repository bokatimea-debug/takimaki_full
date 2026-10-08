# Takimaki 1.0.5+6 — corrected source, release blocked

The current authorized batch is implemented. 110 Flutter tests pass (full-tests.log); 15 new marketplace/navigation/layout tests also pass separately. Static analysis reports no errors, one pre-existing unused variable warning, and lint/deprecation notices.

## Implemented
- A main-menu action on internal screens; submitting an order removes the completed form. Accepting an offer clears the intermediate offer/order-list stack.
- Account deletion moved to Settings for both roles; existing confirmation, both-role deletion and three-calendar-month local registration restriction retained.
- Provider new requests match saved categories and are open/unexpired. Offer sending validates current request, category and subscription/suspension, with explicit error messages. Accepted work is excluded from new requests.
- No automatic demo offers or seeded services during ordinary use. Historical TEST offers do not consume the first real provider job.
- Partner first names in chat, requests, offers and order details. New records preserve a separate first name; legacy Hungarian surname-first records have a display-only fallback.
- Compact order details: cancellation visible at 360x740 and 412x892; reachable by scrolling at 320x640 with enlarged text. Android bottom insets are respected. Rendered screenshots inspected.
- Narrow-screen order-submit label wraps instead of overflowing. Duplicate submit guard retained.

## Preserved
Approved splash, role picker, shared palette, native icon and artwork are unchanged from 1.0.4. Dependency versions and original checksum lockfile retained.

## Delivery blocker
Original Android signing private key was not recovered after workspace cleanup. Expected existing certificate SHA-256: 4a0dba4355f719b0aadf3c8dc5fc2e54bbbfa769817b6f7959315b0b18ba6073.
No replacement key was generated, and no APK is represented as upgrade-compatible. The original private key is required to update the installed application without uninstalling it. The previous APK cannot recover that key.

Unsigned Android release compilation succeeded (unsigned-build.log); package version is 1.0.5, code 6. Signature verification confirms that this is unsigned. An unsigned binary is not an installable release. No physical-phone verification of this new version has occurred. Existing application uses local stores; these tests do not establish a server-backed multi-device marketplace or server-enforced registration restriction.
