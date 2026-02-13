# Codex Global Setup Guide

이 문서는 특정 사용자 정보 없이 재사용 가능한 Codex 글로벌 설정 가이드입니다.

## 1. 목적

다음 목표를 한 번에 적용합니다.
- 고정밀 추론 기본값(`xhigh`) 사용
- 글로벌 운영 규칙(AGENTS) 표준화
- 위험 명령에 대한 실행 제어 규칙 적용
- 다른 PC로 동일 설정 이관 가능 상태 구성

## 2. 적용 파일 구조

Codex 사용자 설정은 기본적으로 `~/.codex` 아래에 저장됩니다.

- `~/.codex/config.toml`
- `~/.codex/AGENTS.md`
- `~/.codex/rules/default.rules`

## 3. 권장 `config.toml`

```toml
model = "gpt-5.3-codex"
model_reasoning_effort = "xhigh"
model_reasoning_summary = "detailed"
model_verbosity = "high"
approval_policy = "on-failure"
sandbox_mode = "workspace-write"
web_search = "cached"
project_doc_max_bytes = 65536
personality = "pragmatic"
```

## 4. 글로벌 AGENTS 정책(요약)

`~/.codex/AGENTS.md`에 아래 성격의 규칙을 둡니다.

- 한국어 우선 응답
- 불필요한 질문 최소화(자율 진행)
- 코드 변경 후 검증(테스트/빌드/린트) 필수
- 컨텍스트 탐색 우선순위 고정
- 새 프로젝트 첫 대화에서 프로젝트 규칙 초안 제시
- 앱 내장 워크플로우와 커스텀 워크플로우 경계 명시

## 5. `default.rules` 예시

`~/.codex/rules/default.rules`에 실행 제어 규칙을 둡니다.

```rules
prefix_rule(
  pattern = ["git", "push", "--force"],
  decision = "forbidden",
  justification = "강제 푸시는 사용자 명시 승인 후 수동으로 수행."
)

prefix_rule(
  pattern = ["rm", "-rf"],
  decision = "prompt",
  justification = "파괴적 삭제는 매번 승인 필요."
)

prefix_rule(
  pattern = ["gh", "pr", "view"],
  decision = "prompt",
  justification = "외부 조회 명령은 승인 후 실행."
)
```

## 6. 로컬 적용 절차

수동 복사 대신 스크립트 1회 실행을 기본으로 사용합니다.

1. 대상 PC에 Codex App(필요 시 CLI) 설치 및 로그인
2. 이 `codex_setting` 폴더를 대상 PC로 복사
3. 대상 PC에서 실행:

```bash
cd /path/to/codex_setting
bash ./apply_to_new_pc.sh
```

스크립트가 자동으로 수행하는 일:
- 기존 `~/.codex` 설정 백업 생성 (`~/.codex/backups/<timestamp>`)
- `config.toml`, `AGENTS.md`, `rules/default.rules` 적용
- 롤백에 필요한 백업 위치 출력

적용 후:
- Codex App 재시작
- 검증:
  - 앱에서 `/status`
  - 터미널에서 `codex features list`

## 7. 계정 연동 vs 로컬 저장

- 이 설정은 계정 서버에 자동 동기화되는 프로필이 아니라 로컬 파일 기반 설정입니다.
- 같은 계정으로 다른 PC에서 사용하려면 설정 파일을 직접 복사해야 합니다.

## 8. 다른 PC로 이관하는 방법

1. 소스 PC에서 `codex_setting` 폴더 전체를 전달
2. 대상 PC에서 `bash ./apply_to_new_pc.sh` 실행
3. Codex App 재시작 후 검증

선택 옵션:
- 백업 목록 확인: `bash ./apply_to_new_pc.sh list-backups`
- 최신 백업 복원: `bash ./apply_to_new_pc.sh restore-latest`
- 특정 백업 복원: `bash ./apply_to_new_pc.sh restore <timestamp_or_path>`

## 9. 롤백 방법

`apply_to_new_pc.sh`가 적용 전에 자동 백업을 생성합니다.

```bash
# 최신 백업으로 복원
bash ./apply_to_new_pc.sh restore-latest

# 특정 백업으로 복원
bash ./apply_to_new_pc.sh restore <timestamp_or_path>
```

## 10. 참고 문서

- https://developers.openai.com/codex/config-basic
- https://developers.openai.com/codex/app/settings
- https://developers.openai.com/codex/guides/agents-md
- https://developers.openai.com/codex/app/commands
- https://developers.openai.com/codex/app/features
