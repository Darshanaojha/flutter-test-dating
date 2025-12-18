---
name: Neon-glass chat UI integration
overview: Replace only the chat screen UI/animations per `chat-ui-impl.md` while keeping all existing backend APIs/sockets/business logic intact. Introduce an adapter-based message mapping pipeline and a UI state machine derived strictly from backend message states; add sound as hooks only (no audio/video/call/mic features).
todos:
  - id: read-existing-chat
    content: Inspect current chat screen/controller wiring and identify exact backend message model + status fields used for delivery/read/failed/pending/deleted.
    status: pending
  - id: define-adapter-types
    content: Define RawBackendMessage wrapper and MessageAdapter→UIMessage mapping that preserves backend schema and drives UI state machine.
    status: pending
  - id: build-neon-widgets
    content: Implement modular NeonGlass UI widgets (background/particles/topcoat/appbar/message bubbles/inline timestamp/typing indicator/input bar) with tokens and spec timings; remove call/video/mic features.
    status: pending
  - id: wire-actions
    content: Wire existing image upload + block/report actions into the new UI (overflow menu + attach icon) without altering backend calls.
    status: pending
  - id: validate-behavior
    content: Verify the UI remains compatible with existing realtime updates and delivery/read logic; confirm no forbidden features are present.
    status: pending
---

### Constraints (confirmed)

- **No backend/business-logic changes**: keep all existing realtime/socket logic, send/receive APIs, delivery/read logic, timestamps, image upload, block/report as-is.
- **Backend schemas immutable**: do not change response/request shapes.
- **Mapping via adapter**: Backend → `RawBackendMessage` → `MessageAdapter` → `UIMessage`.
- **State machine derived from backend states**: sent/delivered/seen/failed/pending/deleted come from backend fields/events; UI computes only presentation state (grouping, active/pressed, fast-scroll suppression, etc.).
- **UI stateless for message content**: widgets render from `UIMessage` + controller state; no mutation of message payloads in widgets.
- **Forbidden**: audio message recording/playback, video messaging, voice/video calls, mic/camera icons, waveform UI, call buttons/states.
- **Allowed**: text messages, image upload/sending, block + report.
- **Sound**: **hooks only** (call into a notifier/callback; do not implement playback system or add AV scaffolding).

### Target architecture

```mermaid
flowchart LR
  Backend[Backend] --> RawBackendMessage
  RawBackendMessage --> MessageAdapter
  MessageAdapter --> UIMessage
  UIMessage --> MessageController
  MessageController --> NeonGlassUIWidgets
```

### UI components to build (from `chat-ui-impl.md`, adjusted for forbidden controls)

- **Screen root & layers**
  - `BackgroundLayer`: multi-stop gradient + drifting blurred blobs + (optional) noise film + scroll parallax.
  - `AmbientParticlesLayer`: subtle floating dust behind messages.
  - `LightingOverlayTopcoat`: vignette + interaction ripples + message “bounce lighting”.
- **AppBar (floating glass)**
  - Back button (glass)
  - Avatar (glass + neon ring + presence pulse)
  - Name + status
  - Right side: **overflow menu (⋮)** with existing **Block** + **Report** actions.
  - **No call/video buttons**.
- **Message list**
  - Incoming/outgoing neon-glass bubbles (rim glow, blur, shadow)
  - **Inline timestamp inside bubble bottom-right** with active/idle opacity rules and fast-scroll suppression
  - Typing indicator (3 dots loop)
  - Error/failed message visuals (warm rim + retry menu) without changing send logic
  - History-load animations without scroll jumps
- **Input bar (floating glass pill)**
  - Left: **attach icon** for existing image picker/upload flow
  - Center: text field
  - Right: send button
  - **No mic/camera/recording/attachment panels beyond image**

### Interaction + animation/state systems

- **ChatScreenStateMachine** (Idle/Scrolling(Fast/Settle)/InputActive(Typing)/MessageEvent(Incoming/Outgoing/Delivered/Seen/Failed/Retry)) driven by:
  - scroll velocity (fast-scroll suppression)
  - keyboard focus
  - backend message status updates
- **Scroll-linked effects**
  - background parallax drift
  - reduce blur/glow/particles + timestamp opacity during fast scroll
- **Bubble animations**
  - arrival scale/opacity/glow sequence per spec timing
  - unread/read glow attenuation derived from backend read status
- **Gestures**
  - long-press bubble: elevate timestamp opacity + show retry/resend/delete where already supported
- **Sound hooks only**
  - expose callbacks like `onMessageSent()`, `onMessageReceived()`, `onMessageSeen()`; call them from controller/state transitions but do not implement audio playback.

### Integration steps (no backend changes)

- **Audit existing chat wiring** in `[lib/Screens/chatpage/ChatScreenpusher.dart]` and the current chat controller/model usage.
- **Add adapter layer**
  - Define `RawBackendMessage` wrapping existing backend model(s) (no schema change).
  - Implement `MessageAdapter` → `UIMessage` mapping (including status fields + timestamp parsing).
- **Refactor controller to expose UI-ready state**
  - Maintain a single `RxList<UIMessage>` (or equivalent) and derived presentation values (grouping, active message id, fast-scroll flag).
- **Replace the screen widgets** with modular NeonGlass widgets following the layer order and token-driven styling.
- **Preserve existing actions**
  - Block/report: wire overflow menu to existing methods.
  - Image upload: keep existing pick/upload pipeline; only re-skin the trigger control.
- **Validation**
  - Ensure message send/receive, delivery/read updates, image sending, block/report all behave identically.
  - Ensure no forbidden UI elements exist.

### Files likely involved

- `[lib/Screens/chatpage/ChatScreenpusher.dart]` (screen rebuild + wiring)
- Existing chat controller/model files (where messages/status are handled)
- New UI modules under `[lib/ui/chat_neon_glass/]` (layers, bubbles, app bar, input bar)
- New adapter types under `[lib/ui/chat_neon_glass/adapters/]` (or similar)
- Token definitions under `[lib/ui/tokens/]` per spec