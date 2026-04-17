---
name: supabase
description: Supabase 관련 코드 작성 시 따르는 패턴과 베스트 프랙티스입니다.
---

# Supabase Guide

Supabase 관련 코드 작성 시 따르는 패턴과 베스트 프랙티스입니다.

## 클라이언트 초기화

```typescript
// lib/supabase/client.ts - 브라우저용
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/supabase'

export const createClient = () =>
  createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

// lib/supabase/server.ts - 서버 컴포넌트용
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export const createClient = async () => {
  const cookieStore = await cookies()
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll() } }
  )
}
```

## 타입 생성

```bash
# supabase CLI로 타입 자동 생성
npx supabase gen types typescript --project-id <project-id> > src/types/supabase.ts
```

## 쿼리 패턴

```typescript
// 에러 처리는 항상 구조분해로
const { data, error } = await supabase
  .from('table')
  .select('*')
  .eq('id', id)
  .single()

if (error) throw error

// 관계 데이터 조회
const { data } = await supabase
  .from('orders')
  .select(`
    *,
    user:users(id, name),
    items:order_items(*)
  `)
```

## Row Level Security (RLS)

RLS를 항상 활성화합니다. 정책 작성 예시:

```sql
-- 본인 데이터만 조회 가능
CREATE POLICY "users can view own data"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

-- 인증된 사용자만 삽입 가능
CREATE POLICY "authenticated users can insert"
ON orders FOR INSERT
WITH CHECK (auth.role() = 'authenticated');
```

## Auth 패턴

```typescript
// 세션 확인 (서버 컴포넌트)
const { data: { user } } = await supabase.auth.getUser()
if (!user) redirect('/login')

// 로그아웃
await supabase.auth.signOut()
```

## 주의사항

- `getSession()` 대신 `getUser()`를 사용합니다. (서버 측 검증)
- 민감한 작업은 `service_role` 키가 필요한 서버 액션에서만 수행합니다.
- 클라이언트에 `service_role` 키를 절대 노출하지 않습니다.
- Realtime 구독은 컴포넌트 언마운트 시 반드시 해제합니다.
