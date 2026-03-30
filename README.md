# dotfiles

開発環境の設定ファイルを管理するリポジトリ。

## 含まれる設定

| ツール | 設定ファイル | 概要 |
|--------|-------------|------|
| Zsh + Oh My Zsh | `.zshrc`, `.zshenv`, `.p10k.zsh` | Powerlevel10k テーマ、zsh-autosuggestions、zsh-syntax-highlighting |
| Zellij | `config.kdl` | tmux風キーバインド (`Ctrl+b`)、macosテーマ |
| Claude Code | `CLAUDE.md`, `settings.json`, hooks, skills | コーディング規約、pre-commitレビュー、ドキュメント生成スキル |
| Codex CLI | `config.toml`, `rules/` | モデル設定、Chrome DevTools MCP、許可ルール |

## セットアップ

```bash
git clone git@github.com:<user>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` は以下を実行する:

1. Oh My Zsh + Powerlevel10k + プラグインのインストール（未導入時のみ）
2. Zellij のインストール（未導入時のみ）
3. 全設定ファイルへのシンボリックリンク作成

既存ファイルは `dotfiles/.backup/<timestamp>/` に自動退避される。再実行しても安全。

## リンク先一覧

```
zsh/.zshrc                          -> ~/.zshrc
zsh/.zshenv                         -> ~/.zshenv
zsh/.p10k.zsh                       -> ~/.p10k.zsh
zellij/config.kdl                   -> ~/.config/zellij/config.kdl
claude/CLAUDE.md                    -> ~/.claude/CLAUDE.md
claude/settings.json                -> ~/.claude/settings.json
claude/hooks/pre-commit-codex-review.sh -> ~/.claude/hooks/pre-commit-codex-review.sh
claude/skills/codex-review/SKILL.md -> ~/.claude/skills/codex-review/SKILL.md
claude/skills/doc-format/SKILL.md   -> ~/.claude/skills/doc-format/SKILL.md
codex/config.toml                   -> ~/.codex/config.toml
codex/rules/default.rules           -> ~/.codex/rules/default.rules
```

## 注意事項

- 認証情報（`.credentials.json`, `auth.json` 等）はリポジトリに含まない
- `codex/config.toml` の `[projects]` セクションはマシン固有のため、各環境で手動追加する
- Powerlevel10k のプロンプトが崩れる場合は `p10k configure` を再実行する
