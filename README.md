# ⚡ Codex Global Setting — 원클릭 세팅

> 새 PC에서 Codex 설정을 **복사 → 붙여넣기 수준**으로 적용하는 레포입니다.

---

## 📦 이 레포에 들어있는 것

| 파일 | 역할 |
|---|---|
| `config.toml` | 모델(`gpt-5.3-codex`), 추론 수준(`xhigh`), 샌드박스 등 핵심 설정 |
| `AGENTS.md` | 글로벌 에이전트 운영 규칙 (한국어 우선, 자율 진행, 검증 필수 등) |
| `rules/default.rules` | 위험 명령 실행 제어 (`git push --force` 금지, `rm -rf` 승인 필요 등) |
| `apply_to_new_pc.sh` | 위 파일들을 `~/.codex`에 자동 적용하는 스크립트 |

---

## 🚀 새 PC 세팅 (3단계 딸깍)

### Step 1. 레포 클론

```bash
git clone https://github.com/jungjipdo/codex_setting.git
cd codex_setting
```

### Step 2. 스크립트 실행

```bash
bash ./apply_to_new_pc.sh
```

> 자동으로 기존 설정 백업(`~/.codex/backups/`) → 새 설정 적용

### Step 3. Codex 앱 재시작 & 확인

```bash
# Codex 앱 재시작 후
codex features list
```

✅ **끝!** 이게 전부입니다.

---

## 🔄 설정 변경했을 때

설정 파일을 수정한 뒤 다시 적용하고 싶으면:

```bash
bash ./apply_to_new_pc.sh
```

> 실행할 때마다 이전 설정을 자동 백업합니다.

---

## ⏪ 롤백 (되돌리기)

```bash
# 최신 백업으로 복원
bash ./apply_to_new_pc.sh restore-latest

# 특정 백업으로 복원
bash ./apply_to_new_pc.sh restore <타임스탬프>

# 백업 목록 확인
bash ./apply_to_new_pc.sh list-backups
```

---

## ⚠️ 알아둘 것

- **로컬 파일 기반 설정**입니다. Codex 계정에 자동 동기화되지 않습니다.
- 다른 PC에서 같은 설정을 쓰려면 이 레포를 클론해서 스크립트를 실행하세요.
- `config.toml`의 `[projects]` 섹션은 PC별 프로젝트 경로이므로, 새 PC에서는 필요에 맞게 수정하세요.

---

## 📂 상세 문서

설정 항목별 상세 설명은 [`CODEX_GLOBAL_SETUP_README.md`](./CODEX_GLOBAL_SETUP_README.md)를 참고하세요.
