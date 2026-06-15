# 短信记录管理 — 后台原型说明

> 玛鲁丸 / 会员购 电商后台「系统设置 → 短信记录管理」交互原型页

---

## 一、整体功能说明

本页面是后台管理系统中的**短信发送记录查询与管理**模块，用于运营/客服人员查看、筛选、核对系统对外发送的全部短信，并排查发送失败原因。

**核心功能：**

| 模块 | 说明 |
|------|------|
| 🔍 多条件查询 | 支持按「手机号、渠道（玛鲁丸 / 会员购）、状态（成功 / 失败 / 发送中）、内容关键词、发送时间区间」组合筛选 |
| 📅 日期筛选 | 起止日期日历选择，并提供「今日 / 本周 / 本月 / 今年」快捷区间 |
| 📊 统计概览 | 实时显示发送总量、发送成功、发送失败、发送中、成功率 5 项指标 |
| 📋 记录列表 | 表格展示短信ID、手机号（脱敏）、短信内容、渠道、发送时间、状态、失败原因，按时间倒序，每页 8 条分页 |
| 📄 详情抽屉 | 点击「详情」侧滑展开单条短信的完整内容、运营商回执、流水号、短信类型、关联业务单号等 |
| ⭳ 导出 Excel | 将当前筛选结果导出为表格 |

**短信类型覆盖：** 验证码、业务通知、催付提醒、逾期提醒等。

> 说明：本页为**前端交互原型**，数据为内置示例数据，用于演示界面与交互流程，不连接真实短信网关。

---

## 二、在线访问与部署（永久链接）

页面已部署到 GitHub Pages，链接长期有效，更新后约 1 分钟自动生效。

**🔗 直接分享链接**（可直接发给他人在浏览器打开）：

```
https://tbsbdstar.github.io/gift-rule-prototype/%E7%9F%AD%E4%BF%A1%E8%AE%B0%E5%BD%95%E7%AE%A1%E7%90%86/%E7%9F%AD%E4%BF%A1%E8%AE%B0%E5%BD%95%E7%AE%A1%E7%90%86.html
```

**🖼 Axure 内联框架（Inline Frame）地址**（在 Axure 中拖入「内联框架」元件，把下面地址填入即可内嵌本页）：

```
https://tbsbdstar.github.io/gift-rule-prototype/%E7%9F%AD%E4%BF%A1%E8%AE%B0%E5%BD%95%E7%AE%A1%E7%90%86/%E7%9F%AD%E4%BF%A1%E8%AE%B0%E5%BD%95%E7%AE%A1%E7%90%86.html?v=1
```

> ⚠️ 末尾的 `?v=1` 是**防缓存版本号**。GitHub 页面会被浏览器/Axure 缓存约 10 分钟，更新后可能看不到最新内容。**每次更新本页面后，把 `v=` 的数字 +1**（改成 `?v=2`、`?v=3`……），Axure 就会强制加载最新版。**当前版本：v=1**

通用 `iframe` 嵌入代码（用于其他网页 / 文档内嵌，同样每次更新 +1）：

```html
<iframe src="https://tbsbdstar.github.io/gift-rule-prototype/%E7%9F%AD%E4%BF%A1%E8%AE%B0%E5%BD%95%E7%AE%A1%E7%90%86/%E7%9F%AD%E4%BF%A1%E8%AE%B0%E5%BD%95%E7%AE%A1%E7%90%86.html?v=1"
        width="100%" height="800" frameborder="0"></iframe>
```

**📚 原型总目录**（所有页面集合）：

```
https://tbsbdstar.github.io/gift-rule-prototype/catalog.html
```

---

*仓库：[tbsbdstar/gift-rule-prototype](https://github.com/tbsbdstar/gift-rule-prototype) ｜ 提交者：tbsbdstar*
