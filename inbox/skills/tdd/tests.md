# 好测试与坏测试

## 好测试

**集成风格**：通过真实接口测试，而不是模拟内部部件。

```typescript
// 好：测试可观察的行为
test("用户可以使用有效购物车结账", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特征：

- 测试用户/调用者关心的行为
- 仅使用公共 API
- 在内部重构后仍能通过
- 描述 WHAT（什么），而不是 HOW（如何）
- 每个测试一个逻辑断言

## 坏测试

**实现细节测试**：与内部结构耦合。

```typescript
// 差：测试实现细节
test("结账调用 paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

警示信号：

- Mock 内部协作对象
- 测试私有方法
- 断言调用次数/顺序
- 重构（未改变行为）时测试失败
- 测试名称描述 HOW 而不是 WHAT
- 通过外部手段而非接口进行验证

```typescript
// 差：绕过接口进行验证
test("createUser 保存到数据库", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// 好：通过接口验证
test("createUser 使用户可被检索", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```
