# Magombo App

Church sermon app for **Magombo Assemblies of God — New Jerusalem Temple**.

An offline-first system for recording, syncing, and streaming sermons — built as a Flutter mobile app (pastors record, members listen) paired with a Node.js backend and a React admin portal for moderation and analytics.

---

## How it works

Every phone has two layers:

1. **Local layer** (SQLite) — always available, works with zero internet. Pastors record sermons locally; members can browse and play anything already downloaded, fully offline.
2. **Cloud layer** (PostgreSQL + Backblaze B2) — the shared "meeting point." Sermons recorded on one phone sync up to the cloud, then sync back down to every other phone.

A sermon is born locally, quietly climbs to the cloud when internet is available (or when the user taps **Sync**), and then quietly comes back down onto everyone else's device.

**Sermon vs. Preaching:** a _Sermon_ is a theme/title (e.g. "Faith That Moves Mountains"), created once. A _Preaching_ is one recorded session under that theme (Part 1, Part 2, Part 3...). A pastor continuing a theme doesn't retype the title — they just pick the existing sermon and record the next part.

---

## Project structure

magomboApp/
├── mobile/ # Flutter app — recording (pastors) + listening (members)
├── backend/ # Node.js/Express + Prisma + PostgreSQL REST API
├── frontend/ # React + Vite admin portal (approvals, sermons, donations, analytics)
└── website/ # Public-facing church website

---

## Tech stack

| Layer        | Technology                                                        |
| ------------ | ----------------------------------------------------------------- |
| Mobile       | Flutter (Android + iOS), Riverpod, sqflite, dio, just_audio       |
| Backend      | Node.js, Express, Prisma ORM, PostgreSQL                          |
| File storage | Backblaze B2 (S3-compatible, private bucket + signed URLs)        |
| Admin portal | React, Vite, TypeScript, Tailwind CSS, shadcn/ui, Recharts        |
| Auth (admin) | Simple API key gate (`x-admin-key`) — to be upgraded to real auth |

---

## Core features

### Mobile — Recording (Pastors)

- Role selection on first launch: Pastor or Member
- Multiple preacher profiles per device, with a quick "Who is preaching?" switcher
- Record a new sermon theme, or continue an existing one (auto-labeled as the next Part)
- Background-safe recording, saved locally first — works with no internet
- Manual **Sync** button with live status (idle / syncing / success / failure)

### Mobile — Listening (All users)

- Browse by preacher → sermon theme → parts, in order
- Full player: play/pause/seek, 15-second skip, next/previous part
- Plays local files instantly if not yet synced; streams from the cloud otherwise

### Admin Portal

- **Dashboard** — live stats (preachers, sermons, plays, donations) + activity chart
- **Preacher Approvals** — pending preacher review with device info, registration date, and audio preview before approving/rejecting (prevents unverified users from appearing publicly)
- **Sermons** — browse everything uploaded, with an inline audio player
- **Donations** — table + totals by category (Tithe, Offering, Building Fund, etc.)

### Safety model

New preacher profiles start as `PENDING` and are **not visible publicly** until an admin reviews and approves them via the portal — including listening to their recordings first. This prevents anyone from self-declaring as a pastor and having content appear in the shared sermon library unchecked.

---

## Getting started

### Backend

```bash
cd backend
npm install
cp .env.example .env   # fill in DATABASE_URL, B2 credentials, ADMIN_API_KEY
npx prisma migrate dev
npm run dev
```

### Mobile

```bash
cd mobile
flutter pub get
cp .env.example .env   # set API_BASE_URL to your backend's address
flutter run
```

### Admin Portal

```bash
cd frontend
npm install
cp .env.example .env   # set VITE_API_BASE_URL and VITE_ADMIN_API_KEY
npm run dev
```

---

## Environment variables

Each of `backend/`, `mobile/`, and `frontend/` has its own `.env` (never committed — see `.gitignore`). Required keys:

**backend/.env**

DATABASE_URL=
B2_KEY_ID=
B2_APPLICATION_KEY=
B2_BUCKET_NAME=
B2_ENDPOINT=
B2_REGION=
ADMIN_API_KEY=
PORT=3001

---

## Roadmap

- [x] Phase 1 — Local recording, local playback, single-device
- [x] Phase 2 — Backend + sync, preacher approval workflow, private cloud audio storage
- [ ] Phase 3 — Donations (mobile money integration)
- [ ] Phase 4 — Push notifications, search/filter, offline download polish
- [ ] Phase 5 — Livestream tab, real admin authentication, production deployment (Render + Vercel)

---

## Status

Actively in development and testing. Not yet deployed to production.
