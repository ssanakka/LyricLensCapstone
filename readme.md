# LyricLens

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

**LyricLens** is the ultimate companion for music lovers. It automatically detects music playing on your device (or from a connected Spotify account) and fetches synchronized, karaoke-style lyrics from the LRCLIB API to display them in real-time. Whether you're wearing headphones on a noisy subway, trying to sing along at a party, or finally want to settle that debate about whether it's "hold me closer, Tony Danza" - LyricLens has you covered.

### App Evaluation

- **Category:** Music / Entertainment
- **Mobile:** Uniquely mobile. Uses media detection (`MusicKit`/`ShazamKit`), real-time audio analysis, and push notifications for track changes. The core experience of synced lyrics on a pocket device is inherently mobile and cannot be replicated on desktop.
- **Story:** Instantly compelling. "An app that shows you lyrics for whatever you're listening to, right on your screen in karaoke style." Solves the clear pain point of misheard lyrics and adds a fun, interactive element to any listening session.
- **Market:** Large. Targets the massive global music listener market (over 500 million streaming subscribers worldwide). Provides value to both streaming service users whose native lyrics may be missing/incomplete, and local file listeners who have no lyrics at all.
- **Habit:** Highly habit-forming. Users will open the app every time they play music. The auto-detection feature creates a "set it and forget it" addiction. Future features like saving favorite lines add a creation element that increases retention.
- **Scope:** Well-defined. The MVP (detect song → fetch from LRCLIB → display synced lyrics) is clear and technically challenging but achievable. A stripped-down version (manual search by artist/song) remains interesting and functional, providing a solid fallback.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can grant media permissions so the app can detect currently playing audio on their device.
- [x] User can see the app automatically detect the currently playing song (track name, artist, album, duration).
- [x] User can view synchronized lyrics that scroll in real-time with the music, with the current line highlighted.
- [x] User can manually search for lyrics by entering an artist name and track title when auto-detection fails.
- [x] User can see a "No Lyrics Found" or "Instrumental" message when LRCLIB returns no results.

**Optional Nice-to-have Stories**

- [ ] User can connect their Spotify account to display lyrics for Spotify playback.
- [ ] User can tap and hold any lyric line to save it to a personal "favorites" collection.
- [ ] User can share a beautifully formatted lyric card (with album art) to Messages or Instagram.
- [ ] User can access previously viewed lyrics offline (cached lyrics).
- [ ] User can adjust text size and scroll speed of lyrics for accessibility.

### 2. Screen Archetypes

- **Now Playing Screen**
    - Auto-detect currently playing song, display synchronized lyrics in karaoke style, show "no lyrics" message when unavailable.
- **Search Screen**
    - Manually search for lyrics by artist name and track title.
- **Settings / Connect Screen**
    - Manage app permissions, toggle auto-detection, connect Spotify account (optional feature foundation).

### 3. Navigation

**Tab Navigation** (Tab to Screen)

- **Now Playing** - Main screen showing album art and synchronized lyrics
- **Search** - Manual search interface for finding lyrics
- **Favorites** (Future Release) - Collection of saved lyric lines
- **Settings** - App preferences and account connections

**Flow Navigation** (Screen to Screen)

- **Now Playing Screen**
    - Tap search icon → Navigates to **Search Screen**
    - Tap Settings tab → Navigates to **Settings Screen**
    - (Auto-detection runs passively - no navigation needed)

- **Search Screen**
    - Tap Back button → Returns to **Now Playing Screen**
    - Enter search criteria → Displays results list
    - Tap on search result → Fetches lyrics → Navigates to **Now Playing Screen** (populated with new lyrics)

- **Settings Screen**
    - Tap Back button or Now Playing tab → Returns to **Now Playing Screen**
    - Tap "Connect Spotify" → Opens OAuth web view modal → On success, returns to Settings with "Connected" status
    - Toggle "Auto-Detect Music" switch → Updates detection behavior globally

## Wireframes

### Hand-Sketched Wireframes


<img src="https://raw.githubusercontent.com/ssanakka/LyricLensCapstone/refs/heads/main/assets/wireframe.png?token=GHSAT0AAAAAADUP73JZCOSWYCJK3OKQQLYI2OS5YRQ" width=600>

**Wireframe Description:**

The wireframes include three main screens:

1. **Now Playing Screen** - Features album art at the top, track title and artist below, and a scrolling lyrics view taking up most of the screen. The current lyric line is highlighted (represented by a bold/darker text box). A search icon is in the top-right corner, and a bottom tab bar shows Now, Search, and Settings tabs.

2. **Search Screen** - Contains input fields for "Artist Name" and "Track Title", a search button, and a results list below showing matching songs with album names and durations.

3. **Settings Screen** - Shows toggle switches for "Auto-Detect Music", a "Connect Spotify" button, an "About" section with API credits, and a "Clear Cache" button.

**Navigation Arrows:**
- Bottom tab bar connects all three screens
- Search icon on Now Playing → Search Screen
- Search result tap → Back to Now Playing with new lyrics
- Back button on Search → Now Playing

### [BONUS] Digital Wireframes & Mockups

*[To be completed in Unit 9 - optional for bonus points]*

### [BONUS] Interactive Prototype

*[To be completed in Unit 9 - optional for bonus points]*

## Schema

*[This section will be completed in Unit 9]*

### Models

*[Table of models will be added in Unit 9]*

| Model | Properties | Description |
|-------|------------|-------------|
| Song | trackName, artistName, albumName, duration | Represents a detected or searched song |
| Lyrics | plainLyrics, syncedLyrics, instrumental | Lyrics data fetched from LRCLIB |
| Favorite | lyricLine, songId, timestamp | Saved lyric lines (optional feature) |

### Networking

*[Network requests will be documented in Unit 9]*

**LRCLIB API Endpoints (from https://lrclib.net/docs):**

| Endpoint | Method | Purpose | Used By Screen |
|----------|--------|---------|----------------|
| `/api/get` | GET | Fetch lyrics by exact track signature | Now Playing Screen (auto-detect) |
| `/api/get-cached` | GET | Fetch lyrics from cache only (no external lookup) | Now Playing Screen (fallback) |
| `/api/search` | GET | Search for lyrics by keyword(s) | Search Screen |

**Example Request (Auto-Detect):**
GET /api/get?artist_name=Borislav+Slavov&track_name=I+Want+to+Live&album_name=Baldur%27s+Gate+3+(Original+Game+Soundtrack)&duration=233

**Example Response:**
```json
{
  "id": 3396226,
  "trackName": "I Want to Live",
  "artistName": "Borislav Slavov",
  "albumName": "Baldur's Gate 3 (Original Game Soundtrack)",
  "duration": 233,
  "instrumental": false,
  "plainLyrics": "I feel your breath upon my neck...",
  "syncedLyrics": "[00:17.12] I feel your breath upon my neck\n[03:25.72]"
}
