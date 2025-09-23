# QLM Studio

A lightweight macOS SwiftUI client inspired by LM Studio. It provides a two-column layout with a chat folder sidebar and a conversation workspace that reads metadata from the bundled DeepSeek model files located at:

```
/Users/abhijeetanand/.lmstudio/models/lmstudio-community/DeepSeek-R1-0528-Qwen3-8B-MLX-4bit/
```

## Features

- SwiftUI UI scaffold for LM Studio style layout (chat list on the left, conversation pane on the right).
- Loads model metadata directly from the supplied `config.json` in the LM Studio model directory.
- Simple placeholder responses that clearly flag the missing inference engine while showing how the UI flow would work once wired up.
- Ready for expansion with real inference backends, persistent chat history, and richer workspace tooling.

## Building the App

1. Open the package in Xcode (`File ▸ Open…` and choose the `Package.swift`).
2. Select the **QLMStudio** scheme and build or run (`⌘R`).
3. Xcode will produce `QLMStudio.app` under `~/Library/Developer/Xcode/DerivedData/…/Build/Products/Debug/`.

If you prefer the command line, you can use `xcodebuild` with the generated SwiftPM project (requires an Xcode toolchain that matches the macOS SDK shipped with CommandLineTools).

### Creating a DMG

After a successful build, package the app into a disk image:

```bash
APP_PATH="~/Library/Developer/Xcode/DerivedData/<QLMStudio build>/Build/Products/Release/QLMStudio.app"
DMG_PATH="~/Desktop/QLMStudio.dmg"
hdiutil create -volname "QLM Studio" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_PATH"
```

Replace `<QLMStudio build>` with the actual folder that Xcode creates.

## Next Steps

- Replace the placeholder response generator with a real inference bridge (e.g. MLX, llama.cpp, or LM Studio MCP).
- Persist chat histories with Core Data or JSON files inside `Application Support`.
- Add project/workspace management and plugin integration panes to match LM Studio’s full feature set.
