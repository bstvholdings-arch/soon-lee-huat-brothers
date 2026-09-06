# Soon Lee Huat 对外 API (v1) — 鉴权 + 商品/订单

日期: 2026-09-06
目标: 为 Soon Lee Huat 网站编写对外 API,供外部系统安全调用(取商品库存、推订单)。注意:本次是「对外暴露 Soon Lee 自己的 API」,非调用第三方 Atora。

## 鉴权中间件
- `src/lib/api-v1-auth.ts`: `authenticateV1(req)` 校验 `Authorization: Bearer <API_SECRET>`。
  - 用后台「API keys」页生成的 key(复用 `api_keys` 表)。
  - 校验走 RPC `is_api_key_valid()`(SECURITY DEFINER),anon 可调用,**不碰 service_role**。
  - 无/无效 Bearer → 401。
- 两个路由均先过鉴权,非法请求被拦截。

## 路由
- `GET /api/v1/products`: 返回 motorcycle + part 商品列表(SKU、price、实时 stock_quantity、status)。
- `POST /api/v1/orders`: 接收外部订单(buyer_name/email/phone、shipping_address、items[])。
  - 校验: 缺 buyer_name/items → 400; JSON 非法 → 400。
  - 写库: 调用 SECURITY DEFINER 函数 `create_order()`,状态初始化 `pending_shipment`(待发货),生成内部单号 `SLH-YYYYMMDD-xxxxxx`。
  - 库存闭环: 函数内校验 SKU 是否存在、库存是否足够;不足 → 409(insufficient_stock);未知 SKU → 400(unknown_sku);成功 → 200 带回 order_id/order_number/status。

## 数据库迁移(需用户在 Supabase 控制台跑)
- `supabase/add_orders_and_sku.sql`(在 schema.sql + add_api_keys.sql 之后):
  - motorcycles/parts 加 `sku text`、`stock_quantity int`。
  - 新建 `orders`、`order_items` 表 + RLS(authenticated 可读)。
  - `create_order()` SECURITY DEFINER 函数(库存校验+扣减+写订单)。

## 沙箱限制
- 沙箱出网拦截对 supabase.co 的数据请求,无法在此直接写库/生成 key。
- 已验证: 两路由编译通过,无 key 访问均 401。
- 200 成功路径需:① 跑迁移 SQL ② 后台 API keys 生成 key ③ 商品填 SKU/stock 后,才能端到端测。

## 待办/提醒
- 商品(SKU/库存)需在后台补编辑字段才能被 v1/products 返回真实库存(当前默认 0)。
- service_role key 建议 Roll 一次。
