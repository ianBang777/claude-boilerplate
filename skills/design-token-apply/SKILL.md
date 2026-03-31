---
name: design-token-apply
description: >
  디자인 토큰(tailwind) 변경이 발생했을 때, sementic-token.json 업데이트 및
  token-parser build 실행까지 자동화하는 스킬.
  트리거: "디자인 토큰 바꿔줘", "토큰 적용해줘", "시맨틱 토큰 업데이트" 등
---

# Guide

tailwind 디자인 토큰 변경 시 수행해야할 작업 가이드입니다.

## 작업 순서
1. 변경된 시맨틱 토큰 폴더 및 파일 찾기
2. 기존 sementic-token.json 파일에 변경사항 반영하기
3. token-parser 패키지 sementic build 명령어 실행하여 파일 변경
4. 변경 사항에 대한 요약 보고


## 작업 세부 가이드

### 변경된 시맨틱 토큰 폴더 찾기
- 시맨틱 토큰은 주로 하나의 폴더에 여러 테마에 대한 json 파일 형태로 구성됨.
- 해당 폴더 위치를 물어보고 폴더를 찾는다.
- 폴더 내에는 테마별 시맨틱 토큰 json 파일이 존재하며, 파일의 이름이 곧 테마를 나타낸다.

### 기존 파일에 변경사항 반영하기
- 프로젝트 내 token-parser 패키지 내부 sementic-token.json 을 찾는다.
- 해당 파일은 모든 테마에 대한 시맨틱 토큰을 합친 형태로, key(테마) - value(시맨틱 토큰) 구조이다.
- 1번 단계에서 찾은 파일의 제목에 해당하는 테마별로 sementic-token.json 내 테마의 값을 교체한다.

### token-parser 명령어 실행하여 파일 변경
- 프로젝트 루트 경로에서 yarn token build:semantic 명령어를 실행한다.
- 실행하면 패키지 내 madix.css 파일이 변경된다.

### 변경 사항 보고
- 기존 madix.css와 변경된 madix.css를 비교하여 추가/삭제된 토큰을 요약한다.
- 프로젝트 루트에 `token-update-report.md` 파일을 생성하여 변경 내역을 기록한다.
- 보고 형식: 변경일시, 영향받은 테마 목록, 추가/수정/삭제된 토큰 항목.