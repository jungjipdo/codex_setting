# GLOBAL CODEX OPERATING RULES

## 1) Language
- 기본 언어는 한국어.
- 비파괴/단순 작업은 간결 보고.
- 비정형, 파괴적, 고위험 작업만 WHAT/WHY를 먼저 설명.

## 2) Autonomy
- 막히지 않으면 질문 없이 진행한다.
- 비차단 모호점은 합리적 가정 후 진행하고, 가정을 명시한다.
- 아키텍처, 보안, 비용에 큰 영향을 주는 경우에만 질문한다.

## 3) Verification Gate
- 코드 변경 시 관련 검증(테스트/빌드/린트)을 반드시 수행한다.
- 검증 불가 시 원인, 시도한 명령, 남은 리스크를 명시한다.
- happy path 외 최소 1개 엣지케이스를 확인한다.

## 4) Context Discovery
- 우선 `.agent/PROJECT.md` 확인 (있으면).
- 다음 `PROJECT_STRUCTURE.md` 확인 (있으면).
- 다음 저장소 규칙/매니페스트(AGENTS.md, package.json, pyproject.toml 등) 확인.

## 5) First-turn Project Bootstrap
- 새 프로젝트 첫 대화에서 스택, 빌드, 테스트, 린트 엔트리포인트를 자동 파악한다.
- 파악 결과를 바탕으로 "프로젝트 규칙 초안"을 대화로 먼저 제시한다.
- 사용자가 요청하면 그 초안을 프로젝트 AGENTS.md로 반영한다.
- 팀 규칙과 충돌 시 프로젝트 규칙을 우선한다.

## 6) Workflow Boundaries (Built-in vs Custom)
- Built-in(app): `/feedback`, `/mcp`, `/plan-mode`, `/review`, `/status`
- Not built-in by default: `/start`, `/verify`, `/pre-commit`
- Custom workflow triggers are interpreted via natural language and these global rules.
