# Current specification

Read docs/Takimaki_teljes_specifikacio.txt first. Its latest decisions supersede older historical release instructions below. Keep this specification updated and persist it with each source release.

# Takimaki – continuity and delivery

## User requirements

- Preserve the approved splash screen, mascot artwork and role picker unless the user explicitly requests a change.
- Use the shared palette in `lib/theme.dart`: turquoise is the main brand colour; gold is an accent. Do not add unrelated blue or purple card colours.
- Keep content and complete controls clear of Android system bars. Important dashboard controls must fit the tested 360 × 740 viewport; longer forms must remain scrollable with large text and the keyboard open.
- Show the saved account photo throughout account screens. Chats show the actual partner photo, with initials only when no partner photo exists.
- Keep the native adaptive and round launcher icons. Do not replace them with a square image inside a launcher mask.
- The user explicitly requires regular backups and does not want to repeat previous corrections. Preserve project state and deliverable files outside a transient workspace.
- Communicate briefly in Hungarian. Do not claim a build is ready until the actual delivered APK has been built and checked.

## Latest corrections — 1.0.4

- Both profile editors use the same top spacing and shared turquoise card. Show the saved first name beside the editable photo. Name and phone are immutable here.
- Both roles can edit introduction and choose a city. Keep customer_city/provider_city separate; provider availability remains editable.
- Both editors offer the same confirmed account deletion. Explain that both roles are deleted and the phone cannot re-register for three calendar months. Preserve local restrictions through later deletions. This local prototype cannot enforce restrictions after app data is cleared; server enforcement is not implemented.
- The service form must use the full safe-area scroll viewport. Do not add a large bottom spacer alongside a fixed footer. Required fields and save belong to one scrollable form; invalid fields must become visible.
- Test filled profiles with a real back stack, city save/reload, cancelled and confirmed deletion, and service validation/keyboard behavior. A no-overflow assertion alone does not prove a usable viewport.

## Release handoff

1. Record the exact source version and run the relevant tests.
2. Check representative rendered screens for clipping and consistent colours.
3. Build an APK with a new version number; verify its version and signing certificate.
4. Save a source archive and that exact APK to persistent storage before presenting download links. A local download link alone is not a backup.
5. Exclude build caches, machine-specific paths and private signing keys from source archives.
6. Record completed checks and any outstanding limitations in the release notes. Never present an untested checkpoint as a completed release.

## Recovery context

The current source was restored from a saved 1.0.0 source archive after transient workspace files disappeared. The corrections were re-applied for 1.0.3+4. An uploaded 1.0.1 APK remains the reference for the signing certificate and corrected icon assets. An exact 1.0.2 APK was not recovered; do not claim otherwise.

## Current corrections — 1.0.5 (work in progress)

- Wait for the user's explicit end-of-feedback/start signal before implementing a new batch.
- Direct main-menu access on reachable internal screens. Completed order forms must leave the navigation stack.
- Account deletion is in Settings only; retain its confirmation and three-month warning.
- New provider requests must match saved services and be open/unexpired; accepted jobs belong in My Jobs.
- Never auto-generate offers or services during ordinary browsing. Make blocked offer reasons explicit.
- Show partners' first names in chat, requests, offers and order details, including old saved records.
- Compact order details must keep cancellation visible and respect Android bottom insets.
- Original signing key is currently absent after workspace cleanup. Do not silently generate a replacement and present it as an upgrade-compatible release.

## Authorized separate test release

The user authorized a new key and separate Takimaki Teszt APK on 2026-10-04. Use hu.takimaki.test and the persisted test key for subsequent test updates. Keep the original installed app intact. See verification/TEST_RELEASE.md.

## Released corrections — 1.0.6+7

- Subscription entry only in Settings; no dashboard tile.
- Draw branded background once per app viewport.
- Service categories use compact 48dp rows; all eleven fit the normal 360×740 viewport. Three service cards and add action fit. Compact Settings and customer profile action.
- Service form loads provider general availability, offers editing, and saves it to the same provider_wd_from/to and provider_we_from/to preferences. Keep additional individual dates. End time must follow start.
- 115 full-suite tests plus Settings safe-area test passed; visual captures retained. No physical-phone test was performed.
- Signed hu.takimaki.test versionCode 7 APK with existing persisted test certificate 06d38b73714577338dbaac934fa864083c467d7bb063e5510cd948a1468a6b02. Never replace this key.

## Released corrections — 1.0.7+8

1.0.7+8 build complete. 121 tests passed. Customer order form fits 360x740 and 412x892 without scrolling; decoded picture screenshots verified. Provider service selection uses the same picture catalog. Smaller width/large font remains scrollable. Splash unchanged. Signed hu.takimaki.test with existing persisted test certificate. APK signature, package/version, and 16KB alignment verified. No physical-phone test performed.
SHA256 c000440190e49eb15c0adadf09b262ff1a8d17dd37daee045fdcf949c4d3c9af

## Current unreleased work — October 5
Read specification sections 18 and 19. This is a partially implemented, unbuilt checkpoint. Do not present 1.0.7 test/build evidence as validation of this source. Complete backend, native reminders/calendar sync, feedback migration and all verification before delivery. GitHub writes currently fail with 403.

## Current 1.0.9 corrections — October 6

- Account deletion must leave a local tombstone and force the registration entry flow; Android backup must not restore deleted registration data.
- Registration automatically opens the external calendar chooser, while keeping the skip option.
- Monthly and weekly work calendars use the approved visual day cards and work indicators.
- Notifications open from a bell in both profile headers. Own problem tickets belong on both profile dashboards, not in Settings.
- Settings ends with logout and a separately styled destructive profile deletion action.
