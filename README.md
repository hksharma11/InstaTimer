# InstaTimer

Shows how long you've been on Instagram today as a live timer in the iPhone's
**Dynamic Island**, which stays at the top of the screen while you scroll. It also shows on the Lock Screen.

> iOS doesn't let apps draw floating bubbles over other apps the way Android does.
> A Live Activity in the Dynamic Island is the closest thing iOS allows.

## What it does
- Opening Instagram starts a timer pill in the Dynamic Island, e.g. `[IG] 23:41`.
- The timer shows your **total for today**, not just this session.
- Closing Instagram saves the session and hides the pill.
- The app shows today's total and a 7-day bar chart.

**Requirements:** iOS 17 or newer. A Dynamic Island (iPhone 14 Pro or newer, or any iPhone 15/16/17) is needed to
see the timer while you're inside Instagram. Older iPhones show it on the Lock Screen only.

## Install: option A, from Windows (no Mac)
1. Create a free GitHub account and a new **private** repository. Upload everything in this
   `InstaTimer` folder, including the hidden `.github` folder, to the repository root.
2. Open the repo's **Actions** tab › **Build IPA** › **Run workflow**. Wait about 5 minutes.
3. Open the finished run and download **InstaTimer-ipa**. Unzip it to get `InstaTimer.ipa`.
4. Install **iTunes** (from apple.com, not the Microsoft Store) and **Sideloadly** (sideloadly.io) on your PC.
5. Plug in your iPhone, open Sideloadly, drag in `InstaTimer.ipa`, enter your Apple ID, and click **Start**.
6. On the iPhone, open **Settings › General › VPN & Device Management**, tap your Apple ID, and tap **Trust**.
7. Turn on **Settings › Privacy & Security › Developer Mode** and restart if iOS asks you to.

With a free Apple ID the app stops opening after **7 days**. Re-run step 5 to refresh it. A paid
developer account ($99/year) removes that limit.

## Install: option B, with a Mac
```
brew install xcodegen
cd InstaTimer && xcodegen generate
open InstaTimer.xcodeproj
```
In Xcode, open each target (InstaTimer and InstaTimerWidget) › **Signing & Capabilities** › pick your Team.
Change `com.example` to something unique if Xcode asks. Then plug in your iPhone and press ▶.

## Set up the automations (one time, required)
iOS doesn't tell apps when Instagram opens, so Shortcuts does it:

1. Open the **Shortcuts** app › **Automation** tab › **+** › **App**.
2. Choose **Instagram**, tick **Is Opened** only, and select **Run Immediately**. Tap **Next**.
3. Tap **New Blank Automation** › **Add Action** › search **Start Instagram Timer** › add it › **Done**.
4. Repeat the steps above with **Is Closed** and the **Stop Instagram Timer** action.

Then open InstaTimer once and tap **Start timer** to check the bubble appears. If iOS asks, allow Live Activities.

## Notes
- Usage data stays on your phone. The app makes no network requests.
- Live Activities can last up to 8 hours, so very long sessions may lose the pill. Time is still recorded.
- If the "closed" automation is missed, a session is capped at 4 hours.
