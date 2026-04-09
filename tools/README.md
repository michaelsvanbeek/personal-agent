# Tools

Add executable scripts here. The installer symlinks them to `~/.local/bin/`.

See [docs/building-tools.md](../docs/building-tools.md) for conventions and
examples.

## Adding a tool

1. Create a script in this directory (no file extension)
2. Add a shebang: `#!/usr/bin/env bash` or `#!/usr/bin/env python3`
3. Make it executable: `chmod +x tools/my-tool`
4. Run `./install.sh` to symlink it to your PATH
