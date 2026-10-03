# Bosca Ceoil - Purple

<p align="center">
  A community modification of Bosca Ceoil Blue
</p>

<p align="center">
  <a href="#中文">中文</a> · <a href="#english">English</a>
</p>

---

## 中文

### 项目简介

**Bosca Ceoil - Purple** 是一个面向初学者的音乐制作工具，也是一个基于 **Bosca Ceoil Blue** 的社区二次改编版本。

本项目的改编关系如下：

```text
Terry Cavanagh 的原版 Bosca Ceoil
        ↓
Yuri Sizov 的 Bosca Ceoil Blue（现代 Godot 移植版）
        ↓
Bosca Ceoil - Purple（本项目的二次改编版）
```

Purple 延续了 Bosca Ceoil 简单、直观的创作方式，并在此基础上改进了编辑体验、本地化和视觉效果。

### 主要特点

- 使用钢琴卷帘编辑音符和旋律
- 支持鼠标创建、拖动、调整长度和选择音符
- 支持多音符批量选择、移动和删除
- 默认以 32 分音符的时间精度进行吸附和编辑
- 拖动音符时可以试听当前位置的音高
- 支持多种乐器和乐器分类
- 支持 WAV、MIDI 等导出功能
- 支持柔和配色，降低高饱和度颜色带来的视觉刺激
- 支持在设置中切换语言和外观

### 多语言支持

项目中的界面文本通过统一的本地化系统管理。新增或修改翻译时，建议按照以下方式维护：

- 翻译文件：`translations/`
- 本地化管理器：`globals/LocalizationManager.gd`
- 界面脚本中的文本使用 `tr("...")`
- 新增语言时，同时补充语言名称、界面文本和乐器名称

当前支持的语言：

- English（英语）
- 中文（简体中文）
- 日本語（日语）
- 한국어（韩语）
- Español（西班牙语）
- Français（法语）
- Deutsch（德语）
- Português（葡萄牙语）
- Русский（俄语）

### 项目状态

当前版本：**1.0**。项目仍处于持续开发阶段，部分功能和界面可能发生变化，重要的 `.ceol` 文件建议保留备份。

### 开发环境

- 编辑器版本：Godot 4.7.2 stable
- GDScript
- 项目主场景：`Main.tscn`

### 来源与致谢

- 原版 **Bosca Ceoil**：Terry Cavanagh
- 上游现代 Godot 移植版 **Bosca Ceoil Blue**：Yuri Sizov 与贡献者
- 本项目：基于 Bosca Ceoil Blue 的社区二次改编

上游项目：[YuriSizov/boscaceoil-blue](https://github.com/YuriSizov/boscaceoil-blue)

原版项目：[TerryCavanagh/boscaceoil](https://github.com/TerryCavanagh/boscaceoil)

### 许可

本项目遵循仓库中的 `LICENSE` 文件，并保留原版及上游项目的版权和归属信息。使用、修改或重新发布时，请同时遵守相关上游许可要求。

---

## English

### About

**Bosca Ceoil - Purple** is a beginner-friendly music-making tool and a community second-generation modification based on **Bosca Ceoil Blue**.

The project lineage is:

```text
Terry Cavanagh's original Bosca Ceoil
        ↓
Yuri Sizov's Bosca Ceoil Blue (modern Godot port)
        ↓
Bosca Ceoil - Purple (this community modification)
```

Purple keeps the simple and approachable workflow of Bosca Ceoil while extending the editing experience, localization, and visual customization.

### Features

- Piano-roll editing for notes and melodies
- Mouse-based note creation, dragging, resizing, and selection
- Batch selection, movement, and deletion of notes
- 32nd-note timing precision for snapping and editing
- Position preview while dragging notes
- Multiple instruments and instrument categories
- WAV and MIDI export support
- Softer color modes for more comfortable editing
- Language and appearance settings

### Localization

Interface text is managed through a shared localization system:

- Translation files: `translations/`
- Localization manager: `globals/LocalizationManager.gd`
- UI strings should use `tr("...")`
- New languages should include UI labels, language names, and instrument names

Currently supported languages:

- English
- 中文 (Simplified Chinese)
- 日本語 (Japanese)
- 한국어 (Korean)
- Español (Spanish)
- Français (French)
- Deutsch (German)
- Português (Portuguese)
- Русский (Russian)

### Project status

Current version: **1.0**. Purple is under active development. Features and interfaces may change, so please keep backups of important `.ceol` files.

### Development

- Editor version: Godot 4.7.2 stable
- GDScript
- Main scene: `Main.tscn`

### Credits and lineage

- Original **Bosca Ceoil**: Terry Cavanagh
- Upstream modern Godot port **Bosca Ceoil Blue**: Yuri Sizov and contributors
- This project: a community modification based on Bosca Ceoil Blue

Upstream project: [YuriSizov/boscaceoil-blue](https://github.com/YuriSizov/boscaceoil-blue)

Original project: [TerryCavanagh/boscaceoil](https://github.com/TerryCavanagh/boscaceoil)

### License

This project follows the `LICENSE` file in the repository and preserves the copyright and attribution information from the original and upstream projects. Please follow the applicable upstream license terms when using, modifying, or redistributing the project.
