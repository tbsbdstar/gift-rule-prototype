# DXSS 收货地址（小程序）— 原型说明

> 丸噗噜（MARUONE）小程序「新增收货地址」交互原型，支持中国大陆 / 日本双区域，含日本邮编自动带出地区

---

## 一、整体功能说明

小程序端的**新增收货地址**表单，用于用户填写并保存收货地址，重点支持**日本地址**的录入体验。

**核心功能：**

| 模块 | 说明 |
|------|------|
| 👤 收件人信息 | 填写收件人姓名、手机号 |
| 🌏 所在地区 | 切换国家/地区（中国大陆 / 日本），不同地区表单适配 |
| 〒 邮编自动带出 | 日本地址输入 7 位邮便番号，自动带出对应都道府县/市区町村等地区信息 |
| 🏠 详细地址 | 详细地址 + 楼名·房号 |
| 🔍 地区搜索 | 支持搜索选择所在地区 |
| 👁 地址预览 | 实时预览完整地址 |
| 💾 保存 | 「保存并使用」保存地址 |

**本项目含 4 个页面：**
- `收货地址页（中日）.html` — 新增地址表单，中国大陆 / 日本 双区域版
- `收货地址页（日）.html` — 新增地址表单，日本地址专用版
- `（中日）地址管理.html` — 收货地址**列表/管理页**（中日）：按 🇨🇳中国大陆 / 🇯🇵日本 分组、可折叠，各国各自保留一个默认地址，支持设默认 / 编辑 / 删除
- `（日）地址管理.html` — 日本地址**列表/管理页**：展示已存日本地址（受取人 / 電話番号 / 郵便番号 / 住所），支持设默认 / 编辑 / 删除

> 说明：本页为**前端交互原型**，内置示例/地址数据，用于演示界面与交互流程。

---

## 二、在线访问与部署（永久链接）

已部署到 GitHub Pages，链接长期有效，更新后约 1 分钟自动生效。

### 🔗 直接分享链接（浏览器打开）

<!--AUTO-LINKS:DIRECT-->
- （日）地址管理.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%EF%BC%88%E6%97%A5%EF%BC%89%E5%9C%B0%E5%9D%80%E7%AE%A1%E7%90%86.html
  ```
- （中日）地址管理.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%EF%BC%88%E4%B8%AD%E6%97%A5%EF%BC%89%E5%9C%B0%E5%9D%80%E7%AE%A1%E7%90%86.html
  ```
- 个人中心.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E4%B8%AA%E4%BA%BA%E4%B8%AD%E5%BF%83.html
  ```
- 收货地址页（日）.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%E9%A1%B5%EF%BC%88%E6%97%A5%EF%BC%89.html
  ```
- 收货地址页（中日）.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%E9%A1%B5%EF%BC%88%E4%B8%AD%E6%97%A5%EF%BC%89.html
  ```
<!--/AUTO-LINKS:DIRECT-->

### 🖼 Axure 内联框架（Inline Frame）地址

<!--AUTO-LINKS:AXURE-->
- （日）地址管理.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%EF%BC%88%E6%97%A5%EF%BC%89%E5%9C%B0%E5%9D%80%E7%AE%A1%E7%90%86.html?v=9
  ```
- （中日）地址管理.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%EF%BC%88%E4%B8%AD%E6%97%A5%EF%BC%89%E5%9C%B0%E5%9D%80%E7%AE%A1%E7%90%86.html?v=8
  ```
- 个人中心.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E4%B8%AA%E4%BA%BA%E4%B8%AD%E5%BF%83.html?v=8
  ```
- 收货地址页（日）.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%E9%A1%B5%EF%BC%88%E6%97%A5%EF%BC%89.html?v=9
  ```
- 收货地址页（中日）.html
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%94%B6%E8%B4%A7%E5%9C%B0%E5%9D%80%E9%A1%B5%EF%BC%88%E4%B8%AD%E6%97%A5%EF%BC%89.html?v=8
  ```
<!--/AUTO-LINKS:AXURE-->

> ⚠️ 末尾 `?v=` 后的数字是**防缓存版本号**（GitHub 页面会被浏览器/Axure 缓存约 10 分钟）。发布工具每次发布本项目时会**自动把数字 +1**；你只需把 Axure 内联框架地址里的数字，同步成与上方链接一致的最新值，即可强制加载最新内容。

### 📚 原型总目录（所有页面集合）

```
https://tbsbdstar.github.io/gift-rule-prototype/catalog.html
```

---

*仓库：[tbsbdstar/gift-rule-prototype](https://github.com/tbsbdstar/gift-rule-prototype) ｜ 提交者：tbsbdstar*

---

## 📌 版本记录

> 每次发布工具会自动在下方追加一条（`v版本号 (时间)`）；如需补充改动说明，可在对应行后面续写。

- v1  (2026-07-08) · 初版发布（中日版 + 日本版两个页面）
- v2  (2026-07-08 12:20)
- v3  (2026-07-08 12:27)
- v4  (2026-07-08 12:31)
- v5  (2026-07-08 12:39)
- v6  (2026-07-16 15:58)
- v7  (2026-07-17 11:15)
- v8  (2026-07-20 11:16)
- （日）地址管理.html -> v9  (2026-07-20 12:55)
- 收货地址页（日）.html -> v9  (2026-07-20 12:55)

<!--PAGEVERS
（日）地址管理.html	9	D3469CA9CC468DA8670F8F4246E1AB60
（中日）地址管理.html	8	49DC566027A8A0F73847604180BEE5E1
个人中心.html	8	48B5DAD2A1AB662DD933CBCB08AA5240
收货地址页（日）.html	9	4E3DFCBEE35D18CAAC9864CD9B6E1316
收货地址页（中日）.html	8	B4C4068737B416FB5374E4E9D41DC405
-->
