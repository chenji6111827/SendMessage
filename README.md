# SeedMessage
World of Warcraft Addon that provides a customizable message sending interface with drag-and-drop positioning, group chat channel management, and configuration options for frequently used messages.


### Feature Overview

This addon is designed to help you quickly send predefined messages. And use build-in api,Support any language.

### How to Use

Hover over the main button to reveal the submenu, then click to send a message.

#### Left-Click Behavior

*   **In a Raid** → Send to `RAID`
*   **Not in Raid but in a Party** → Send to `PARTY`
*   **Neither** → Send to `SAY`

#### Right-Click Behavior

*   **In a Raid and is the Leader** → Send to `RAID_WARNING`
*   **In a Raid but not the Leader** → Send to `RAID`
*   **Not in Raid but in a Party** → Send to `PARTY`
*   **Neither** → Send to `SAY`

### Configuring Predefined Text

1.  **Open Config**: Right-click the main button to show the configuration interface.
2.  **Edit**: Edit your desired text in the input field.
3.  **Save**: Press `Enter` to automatically save to local storage.
4.  **Update**: The message content and button name will update in real-time.  
    

### 功能简介

本插件旨在帮助您快速发送预定义的消息。 使用内置api,支持任何客户端语言。

### 操作指南

将鼠标悬停在主按钮上以展开子菜单，点击相应选项即可发送消息。

#### 左键点击逻辑

*   **在团队中** → 发送至 `团队 (RAID)`
*   **不在团队但在队伍中** → 发送至 `队伍 (PARTY)`
*   **上述皆非** → 发送至 `说 (SAY)`

#### 右键点击逻辑

*   **在团队中且为团长** → 发送至 `团队警告 (RAID_WARNING)`
*   **在团队中但非团长** → 发送至 `团队 (RAID)`
*   **不在团队但在队伍中** → 发送至 `队伍 (PARTY)`
*   **上述皆非** → 发送至 `说 (SAY)`

### 配置预定义文本

1.  **打开配置**：右键点击主按钮以显示配置界面。
2.  **编辑文本**：在输入框中编辑您需要的内容。
3.  **保存**：按下 `回车键` 即可自动保存至本地。
4.  **效果**：消息内容与按钮名称将会实时更新。

### 2026年3月29日 Update
现在可以使用鼠标滚轮调整主按钮和配置界面的缩放比例，缩放范围：50% - 150缩放设置会自动保存，下次登录时自动恢复。
Now you can adjust the scale of the main button and config frame using the mouse wheel.
Scale range: 50% - 150%,Scale settings are automatically saved and restored on next login

### 2026年4月1日 Update
Update for LFG Group