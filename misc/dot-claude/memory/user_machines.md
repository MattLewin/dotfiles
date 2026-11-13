The user's machines and their CPU architectures:

- **Mac:** MacBook Air M2, Apple Silicon (`arm64` / `linux/arm64` in Docker). Rosetta is not installed and never will be; don't suggest it.
- **Unraid server:** x86_64 (`linux/amd64`); hosts Docker containers
- **Windows PC:** x86_64

**Why:** Builds, binaries and container images made on one machine may not run on another.

**How to apply:** Test Docker images natively (arm64) on the Mac, and build the deployable `linux/amd64` image on Unraid itself. Without Rosetta, amd64 on the Mac means slow QEMU emulation; use it only for one-off checks. Pick matching release assets (arm64 for the Mac, x86_64/amd64 for Unraid and Windows).
