---
title: Untitled

---

---
title: "Capstone Project: LyricLens"
author: "Your Name"
tags: [capstone, ios, app, brainstorming, product-spec]
---

# 🧠 Activity 1: App Idea Brainstorming

## Step 1: Generate New Ideas (6+)

Here are **6 app ideas** I've brainstormed across different categories:

### 1. 🎵 LyricLens (Music/Entertainment)
**Description:** An app that automatically detects music playing on your device (or from a connected Spotify account) and fetches synchronized, karaoke-style lyrics from the LRCLIB API to display them in real-time. Perfect for singing along or discovering lyrics in noisy environments.

### 2. 📚 FlashForge (Education)
**Description:** Uses the phone's camera and OCR to scan physical textbooks, notes, or documents. The app then automatically generates digital flashcards, practice quizzes, and study guides using AI summarization. Great for students who hate manual flashcard creation.

### 3. 🥾 TrailScout (Travel & Fitness)
**Description:** A hiking companion app that uses GPS and offline maps to track your route. Users can drop voice notes at landmarks, share real-time location with emergency contacts, and discover user-recommended "micro-trails" near them. Focuses on safety and community.

### 4. 🍳 LeftoverLab (Lifestyle)
**Description:** Snap a photo of your fridge leftovers and the app uses image recognition to identify ingredients. It then suggests recipes you can cook with what you have, reducing food waste and saving money. Includes a barcode scanner for packaged items.

### 5. 🧘 MindfulMinutes (Health & Fitness)
**Description:** A gentle mindfulness app that uses the phone's sensors to detect when you've been sedentary or scrolling too long. It offers 1-5 minute guided breathing exercises, stretch breaks, or micro-meditations based on your current heart rate (via Apple Watch) and screen time.

### 6. 📝 TaskBingo (Productivity)
**Description:** Gamifies your to-do list by turning tasks into a bingo card. Each completed task marks off a square. Completing a row, column, or diagonal earns rewards (customizable: focus music, confetti animation, etc.). Perfect for procrastinators who need dopamine hits to stay productive.

### 7. 🎬 SceneKeeper (Social/Entertainment)
**Description:** While watching a movie or show, shake your phone to save a timestamp with a voice memo or text note. Great for remembering quotes, plot holes, or moments you want to discuss with friends. Export your notes as a shareable "watch party" recap.

### 8. 💤 DreamLog (Lifestyle)
**Description:** A dream journal app with voice-to-text transcription. When you wake up, simply tap and speak your dream. The app uses gentle AI to detect recurring themes, people, or emotions, and creates a "dream cloud" visualization of your subconscious patterns.

---

## Step 2.1: The Top Three

After reviewing all 8 ideas against the evaluation criteria, here are my **top 3** most exciting and viable ideas:

| Rank | App Name | Why It Stands Out |
|:---:|:---|:---|
| 🥇 | **LyricLens** | Solves a clear, universal pain point (misheard lyrics) with a unique mobile approach. High habit potential and well-scoped MVP. |
| 🥈 | **TrailScout** | Uniquely mobile with GPS/camera/sensors. Serves a passionate niche audience (hikers) with clear safety value. |
| 🥉 | **MindfulMinutes** | Addresses digital wellness - a growing market. Uses device sensors creatively (screen time + heart rate). Simple MVP. |

---

## Step 2.2: Evaluating Top 3 Ideas

| Criteria | **LyricLens** | **TrailScout** | **MindfulMinutes** |
|:---|:---|:---|:---|
| **Mobile (0-5)** | ⭐⭐⭐⭐ (4/5) <br> Uses media detection, real-time OS integration, push notifications. True mobile experience. | ⭐⭐⭐⭐⭐ (5/5) <br> Uniquely mobile: GPS, camera, accelerometer, offline maps. Impossible on desktop. | ⭐⭐⭐ (3/5) <br> Uses screen time API and heart rate sensor. Works on mobile but could be a web app with manual input. |
| **Story (0-5)** | ⭐⭐⭐⭐ (4/5) <br> Instantly clear value: "See lyrics for whatever is playing." Friends would find it cool and useful immediately. | ⭐⭐⭐ (3/5) <br> Clear value for hikers. Non-hiking friends might appreciate safety features but not use daily. | ⭐⭐⭐⭐ (4/5) <br> Strong story around digital wellness and "take a breath." Relatable to anyone stressed by their phone. |
| **Market (0-5)** | ⭐⭐⭐⭐ (4/5) <br> Massive TAM - anyone who listens to music. Broad appeal across ages and tech comfort levels. | ⭐⭐⭐ (3/5) <br> Smaller, niche market (outdoor enthusiasts). Well-defined audience with high willingness to pay. | ⭐⭐⭐⭐ (4/5) <br> Growing wellness market. Appeals to students, office workers, and anyone with screen fatigue. |
| **Habit (0-5)** | ⭐⭐⭐⭐⭐ (5/5) <br> Highly addictive. Users open it every time they play music. Auto-detection creates "set and forget" loyalty. | ⭐⭐ (2/5) <br> Seasonal/weekend usage. Most users open only during planned hikes. Low frequency. | ⭐⭐⭐⭐ (4/5) <br> Good habit potential. Push reminders + short session length (1-5 min) encourage daily use. |
| **Scope (0-5)** | ⭐⭐⭐⭐ (4/5) <br> Well-defined MVP: detect → fetch → display. Challenging but achievable. Stripped version (manual search) still works. | ⭐⭐ (2/5) <br> Very complex MVP: offline maps, GPS tracking, voice recording, emergency sharing. Too many moving parts. | ⭐⭐⭐⭐ (4/5) <br> Simple MVP: screen time check → offer breathing exercise → log session. Easy to strip down and iterate. |
| **TOTAL** | **21/25** | **15/25** | **19/25** |

---

## Step 2.3: The Final Decision

### 🏆 Winner: LyricLens 🏆

**Why LyricLens?**

After careful evaluation, **LyricLens** is the clear winner for my capstone project because:

1. **Highest total score (21/25)** across all evaluation criteria
2. **Perfect balance** of compelling story + large market + high habit potential
3. **Well-scoped MVP** that is challenging but achievable within the course timeline
4. **Unique mobile differentiator** - the auto-detection feature makes it a "real app," not a website wrapper
5. **Personal excitement** - as a music lover myself, I would genuinely use this app daily

**Runner-up:** MindfulMinutes (19/25) - a strong contender I may build after the course.

---

# ✏️ Activity 2: Product Spec-ing

## App Overview

### App Name: LyricLens

### Description
**LyricLens** is the ultimate companion for music lovers. It listens to (or connects with) the music playing on your iPhone, identifies the track, and instantly displays beautifully formatted, synchronized lyrics that scroll in time with the song. Powered by the open [LRCLIB API](https://lrclib.net/docs), it ensures you never miss a word again - whether you're wearing headphones in a noisy subway or trying to sing along at a party.

### App Evaluation

- **Mobile:** Uniquely mobile. Uses `DeviceActivity` or `ShazamKit` (or Spotify API) for media detection, real-time audio analysis, and push notifications for track changes. The core experience of synced lyrics on a pocket device is inherently mobile and cannot be replicated on desktop.

- **Story:** Instantly compelling. "An app that shows you lyrics for whatever you're listening to, right on your screen in karaoke style." Solves the clear pain point of misheard lyrics ("Is that 'hold me closer, Tony Danza'?") and adds a fun, interactive element to any listening session.

- **Market:** Large. Targets the massive global music listener market (over 500 million streaming subscribers worldwide). Provides value to both streaming service users whose native lyrics may be missing/incomplete, and local file listeners who have no lyrics at all.

- **Habit:** Highly habit-forming. Users will open the app every time they play music. The auto-detection feature creates a "set it and forget it" addiction. Future features like saving favorite lines or sharing lyric cards add a creation/social element that increases retention.

- **Scope:** Well-defined. The MVP (detect song → fetch from LRCLIB → display synced lyrics) is clear and technically challenging but achievable. A stripped-down version (manual search by artist/song) remains interesting and functional, giving me a fallback option.

---

## Product Spec

### 1. User Features (User Stories)

#### Required Features (MVP - Minimum Viable Product)

| # | Feature | Description | Priority |
|:---:|:---|:---|:---:|
| 1 | **Media Detection** | App detects currently playing media on the device using `MusicKit` or `ShazamKit`. Extracts track name, artist, album, and duration. | 🔴 High |
| 2 | **Auto Lyric Fetching** | Automatically uses detected track signature to query LRCLIB API (`/api/get` endpoint) and retrieve lyrics. | 🔴 High |
| 3 | **Synced Lyrics Display** | Shows `syncedLyrics` (LRC format) in a scrolling, karaoke-style view. Highlights current line in real-time based on song position. | 🔴 High |
| 4 | **Manual Search** | Allows user to manually enter artist name and track title when auto-detection fails or is disabled. Uses `/api/search` endpoint. | 🔴 High |

#### Optional Features (Future Releases)

| # | Feature | Description | Priority |
|:---:|:---|:---|:---:|
| 1 | **Spotify Connect** | OAuth integration with Spotify API. Displays lyrics for whatever is playing through the user's Spotify account. | 🟡 Medium |
| 2 | **Save Favorite Lines** | Tap and hold any lyric line to save it to a personal "favorites" collection. View saved lines in a dedicated tab. | 🟢 Low |
| 3 | **Share Lyric Card** | Generate a beautiful shareable image of a selected lyric line with album art overlay. Share to Messages, Instagram, etc. | 🟢 Low |
| 4 | **Offline Cache** | Automatically cache viewed lyrics locally. Allows access to previously viewed songs without internet connection. | 🟡 Medium |
| 5 | **Instrumental Detection** | Display "Instrumental - No Lyrics" message when LRCLIB returns `instrumental: true` flag. | 🟢 Low |

---

### 2. Screen Archetypes

| Screen | Purpose | Required Features Supported |
|:---|:---|:---|
| **Now Playing Screen** | Main screen. Shows album art, track title, artist, and scrolling synchronized lyrics. Includes play/pause mock controls and search icon. | Auto-detection, lyric fetching, synced display |
| **Search Screen** | Allows manual input of track name, artist name, and album name. Displays search results from `/api/search`. | Manual search |
| **Settings / Connect Screen** | Manage app preferences: toggle auto-detection, connect Spotify account (optional), view cached lyrics size, about/credits. | (Foundation for future features) |
| **Favorites Screen** (Optional) | Displays user's saved favorite lyric lines with song title and timestamp reference. | Save favorite lines |

---

### 3. Navigation Flows

#### Tab Navigation (Bottom Tab Bar)
┌─────────────────────────────────────────────────────────┐
│ [🎵 Now Playing] [🔍 Search] [⭐ Favorites*] [⚙️ Settings] │
└─────────────────────────────────────────────────────────┘
*Favorites tab is optional (future release)*

#### Flow Navigation

**From Now Playing Screen:**
- Tap `🔍 Search icon` → Navigates to **Search Screen**
- Tap `⚙️ Settings tab` → Navigates to **Settings Screen**
- Tap `⭐ Favorites tab` (if available) → Navigates to **Favorites Screen**
- (Auto-detection runs passively - no navigation needed)

**From Search Screen:**
- Tap `Back button` → Returns to **Now Playing Screen**
- Enter search criteria → Displays results list
- Tap on a search result → Fetches lyrics for that song → Navigates to **Now Playing Screen** (populated with new lyrics)
- Tap `Cancel` → Clears search field

**From Settings Screen:**
- Tap `Back button` or `Now Playing tab` → Returns to **Now Playing Screen**
- Tap `Connect Spotify` → Opens OAuth web view modal → On success, returns to Settings with "Connected" status
- Toggle `Auto-Detect Music` switch → Updates detection behavior globally

**From Favorites Screen (Optional):**
- Tap on a saved lyric line → Navigates to **Now Playing Screen** with that song loaded
- Swipe to delete → Removes from favorites

#### Navigation Diagram (Text-Based)
┌─────────────────┐
│ │
▼ │
┌───────────────────────────────┐ │
│ │ │
│ NOW PLAYING SCREEN │ │
│ (Main - Synced Lyrics View) │ │
│ │ │
└───────────────┬───────────────┘ │
│ │
┌───────────┼───────────┐ │
│ │ │ │
▼ ▼ ▼ │
┌───────┐ ┌────────┐ ┌────────┐ │
│Search │ │Settings│ │Favorites│ │
│Screen │ │ Screen │ │ Screen* │ │
└───┬───┘ └────────┘ └────────┘ │
│ │
└──────────────────────────────┘
(Select search result)

---

## Next Steps

✅ **Activity 1 & 2 Complete**
⏳ **Activity 3:** Wireframing (hand sketch + optional Figma digital wireframes)
⏳ **Activity 4:** Project setup and GitHub repository configuration

---

*📅 Last Updated: April 5, 2026*
*🎯 Capstone Project - Codepath iOS Development Course*