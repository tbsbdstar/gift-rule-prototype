# DXSS 登录方案（小程序）— 原型说明

> 丸噗噜（MARUONE）小程序**邮箱登录 / 注册**两套交互方案对比原型

---

## 一、整体功能说明

针对小程序端的邮箱登录与注册流程，提供 **A / B 两套方案**供对比评估。

**核心功能：**

| 模块 | 说明 |
|------|------|
| 📧 邮箱登录 | 输入邮箱地址 + 密码 / 邮箱验证码登录 |
| 🔢 验证码 | 获取邮箱验证码、图形验证码，带倒计时 |
| 📝 注册 | 邮箱注册（方案 B 含独立注册页、二次确认密码） |
| ↻ 重置演示 | 一键重置演示状态，便于反复走查 |

**本项目含 2 个方案页面：**
- `方案A-邮箱登录即注册(1).html` — **方案 A：邮箱登录即注册**。登录与注册合一：用邮箱登录时若账号不存在则自动完成注册，无独立注册页，流程最短
- `方案B-邮箱登录与注册(1).html` — **方案 B：邮箱登录 + 独立注册页**。登录与注册分离，注册为独立页面并需二次确认密码，流程更规范清晰

> 说明：本页为**前端交互原型**，内置示例数据，用于演示界面与交互流程，不连接真实后端。

---

## 二、在线访问与部署（永久链接）

已部署到 GitHub Pages，链接长期有效，更新后约 1 分钟自动生效。

### 🔗 直接分享链接（浏览器打开）

- 方案A · 邮箱登录即注册：
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E7%99%BB%E5%BD%95%E6%96%B9%E6%A1%88%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%96%B9%E6%A1%88A-%E9%82%AE%E7%AE%B1%E7%99%BB%E5%BD%95%E5%8D%B3%E6%B3%A8%E5%86%8C(1).html
  ```
- 方案B · 邮箱登录 + 独立注册页：
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E7%99%BB%E5%BD%95%E6%96%B9%E6%A1%88%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%96%B9%E6%A1%88B-%E9%82%AE%E7%AE%B1%E7%99%BB%E5%BD%95%E4%B8%8E%E6%B3%A8%E5%86%8C(1).html
  ```

### 🖼 Axure 内联框架（Inline Frame）地址

- 方案A · 邮箱登录即注册：
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E7%99%BB%E5%BD%95%E6%96%B9%E6%A1%88%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%96%B9%E6%A1%88A-%E9%82%AE%E7%AE%B1%E7%99%BB%E5%BD%95%E5%8D%B3%E6%B3%A8%E5%86%8C(1).html?v=1
  ```
- 方案B · 邮箱登录 + 独立注册页：
  ```
  https://tbsbdstar.github.io/gift-rule-prototype/DXSS%E7%99%BB%E5%BD%95%E6%96%B9%E6%A1%88%EF%BC%88%E5%B0%8F%E7%A8%8B%E5%BA%8F%EF%BC%89/%E6%96%B9%E6%A1%88B-%E9%82%AE%E7%AE%B1%E7%99%BB%E5%BD%95%E4%B8%8E%E6%B3%A8%E5%86%8C(1).html?v=1
  ```

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

- v1  (2026-07-15) · 初版发布（方案A + 方案B 两套登录/注册方案）

<!-- pagehash:AD6735E8A6A2BE92E41F971D893BC6D1-FFD1B4963757068C41F0AFCCE73BCAF7 -->
