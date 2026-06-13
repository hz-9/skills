# 约定式提交 1.0.0

> !!! 重要的事，本篇文档 Fork from https://github.com/conventional-commits/conventionalcommits.org

## 概述

约定式提交规范是一种基于提交信息的轻量级约定。
它提供了一组用于创建清晰的提交历史的简单规则；
这使得基于它编写自动化工具变得更加容易。
通过在提交信息中描述功能、修复和破坏性变更，
使得这种约定与 SemVer 相互配合。

提交信息应该使用如下结构：

---
```
<类型>[可选 范围]: <描述>

[可选 正文]

[可选 脚注]
```
---

提交信息包含以下结构化元素，以向类库使用者传达意图：

1. **fix:** _fix_ 类型的提交表示在代码库中修复了一个 bug（这与语义化版本控制中的 [`PATCH`](https://semver.org/#summary) 相对应）。
2. **feat:** _feat_ 类型的提交表示在代码库中新增了一个功能（这与语义化版本控制中的 [`MINOR`](https://semver.org/#summary) 相对应）。
3. **BREAKING CHANGE:** 提交中如果包含 `BREAKING CHANGE:` 或 末尾的 `!`，表示引入了破坏性变更（这与语义化版本控制中的 [`MAJOR`](https://semver.org/#summary) 相对应）。
   破坏性变更可以是任意 _类型_ 提交的一部分。
4. 除 `fix:` 和 `feat:` 之外，也可以使用其他提交 _类型_ ，例如 [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional)（基于 [Angular 约定](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)）中推荐的 `build:`、`chore:`、`ci:`、`docs:`、`style:`、`refactor:`、`perf:`、`test:` 等。

约定式提交规范所期望的提交信息如下：

*   提交信息中带有 `!` 和 `BREAKING CHANGE:` 脚注的为破坏性变更
*   除了 `feat` 和 `fix`，允许使用其他类型，例如：`build:`、`chore:`、`ci:`、`docs:`、`style:`、`refactor:`、`perf:`、`test:` 等。
*   构建在提交信息中附加可选的 `!` 以强调破坏性变更

## 规范

本文中的关键词 "必须（MUST）"、"禁止（MUST NOT）"、"必需（REQUIRED）"、"应当（SHOULD）"、"不应当（SHOULD NOT）"、"推荐（RECOMMENDED）"、"可以（MAY）" 以及 "可选（OPTIONAL）" 应当按照 [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) 中的描述进行解读。

1. 每个提交都 **必须（MUST）** 使用类型（type）作为前缀，类型由名词组成，例如 `feat`、`fix` 等，其后可以跟随一个可选的 **范围（scope）**，**范围（scope）** 后 **必须（MUST）** 跟一个 `!` 或 `:` 和一个空格。
2. 当提交引入了破坏性变更时，**必须（MUST）** 在 `类型/范围（type/scope）` 之后或 `脚注（footer）` 起始位置添加 `BREAKING CHANGE:`，破坏性变更可以与其他类型一同使用。
3. 提交 **必须（MUST）** 在类型（type）/范围（scope）之后提供一个描述（description），用以简短地描述变更。描述以动词开头，使用一般现在时。**不应当（SHOULD NOT）** 以大写字母开头，结尾 **不应当（SHOULD NOT）** 带有句号（.）。
4. 在简短描述之后，**可以（MAY）** 提供较长的提交正文（body），正文 **必须（MUST）** 从描述结束的新一行开始。
5. 提交正文内容**可以（MAY）** 包含对所更改的内容和更改原因的说明。
6. 在一个或多个脚注（footer）之间 **可以（MAY）** 包含一个由空行组成的间隙。
7. 当提交包含 `BREAKING CHANGE:` 脚注或类型/范围后附加了 `!` 时，脚注 **必须（MUST）** 引入破坏性变更。
8. 除了 `feat` 和 `fix`，**可以（MAY）** 在提交中引入其他类型。
9. 除了 BREAKING CHANGE 外，提交解析器 **可以（MAY）** 忽略由开发者设定的其他脚注。

## 示例

### 包含了描述并且带有 `!` 的破坏性变更的提交信息

```
feat!: send an email to the customer when a product is shipped
```

### 包含了 `!` 和 BREAKING CHANGE 脚注的提交信息

```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

### 不包含正文的提交信息

```
docs: correct spelling of CHANGELOG
```

### 包含范围（scope）的提交信息

```
feat(lang): add polish language
```

### 为 fix 编写正文（body）的提交信息

```
fix: correct minor typos in code

see the issue for details

on typos fixed.

Reviewed-by: Z
Refs #133
```

### 包含破坏性变更脚注的提交信息

```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### 包含 `!` 和破坏性变更脚注的提交信息

```
feat!: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### 包含脚注的提交信息

```
feat: allow provided config object to extend other configs

Refs #123, #456
```

## 规范描述

### 类型

| 类型 | 说明 |
|------|------|
| feat | 新功能（feature）|
| fix | 修复 bug |
| docs | 文档（documentation）|
| style | 代码格式（不影响功能，例如空格、分号等格式修正）|
| refactor | 重构（既不是新增功能，也不是修改 bug 的代码变动）|
| perf | 性能优化（performance）|
| test | 增加测试 |
| build | 构建系统或外部依赖的变更（例如 webpack，npm 等）|
| ci | 持续集成的配置或脚本变更（例如 Jenkins, Travis CI, GitHub Actions 等）|
| chore | 其他修改（不修改 src 或 test 文件）|
| revert | 回滚之前的提交 |

### 范围（scope）

范围（scope）是一个可选的参数，用于指定提交更改所影响的位置/模块：

```
feat(auth): add user login with JWT authentication
fix(parser): handle null pointer exception
docs(api): update API documentation
```

### 破坏性变更

当提交包含破坏性变更时，必须在类型/范围后添加 `!` 或在脚注中包含 `BREAKING CHANGE:`：

```
feat(auth)!: redesign authentication system
```

或

```
feat(auth): redesign authentication system

BREAKING CHANGE: the authentication API has been completely redesigned
```

### 关联 Issue

可以在脚注中关联 Issue：

```
feat: add user login feature

Closes #123
```
