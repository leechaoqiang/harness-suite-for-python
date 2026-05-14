# 文档模板说明

## 目录结构

本目录为 `docs/` 的模板文件，在执行 `/harness:setup` 时会复制到目标项目。

## 各目录用途

| 目录 | 用途 |
|------|------|
| `architecture/` | 架构知识、隐性约定 |
| `product/` | 产品规则、接口规范 |
| `standards/` | 测试规范、数据库规范 |

## OpenSpec 目录说明

`openspec/` 目录**不在**此模板中，它由 setup 动态创建：

```
openspec/
├─ changes/
│  ├─ <change-id>/        ← 每次 /harness:propose 时创建
│  └─ archive/            ← 每次 /harness:archive 时归档
└─ specs/
   └─ index.md
```
