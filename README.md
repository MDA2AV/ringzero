# ringzero

Pure C io_uring TCP server using liburing. Built for benchmark comparison against [zerg](https://github.com/MDA2AV/zerg) (C# io_uring).

## Architecture

- **1 acceptor thread** — multishot accept, round-robin to N reactors via lock-free SPSC queue
- **N reactor threads** — each with its own io_uring (`SINGLE_ISSUER | DEFER_TASKRUN`), provided buffer ring, and multishot recv
- **Synchronous handler** — runs inline on the reactor thread, zero cross-thread signaling

All liburing `static inline` functions are fully inlined by gcc at `-O2`.

## Building

Requires liburing (`liburing-dev` on Debian/Ubuntu).

```bash
make
```

Produces:
- `rgzero` — server binary (linked against `libringzero.so` with `$ORIGIN` rpath)
- `libringzero.so` — shared library
- `libringzero.a` — static library

## Running

```bash
./rgzero [reactor_count]    # default: 12 reactors
```

Listens on `0.0.0.0:8080`. Stop with `Ctrl+C` or `SIGTERM`.

## Project Structure

```
include/
  constants.h    — UD packing macros, ring/buffer tunables
  queue.h        — lock-free SPSC queue (acceptor → reactor fd handoff)
  listener.h     — TCP listen socket setup
  connection.h   — per-connection state, write buffering
  reactor.h      — reactor struct, event loop, provided buffer ring
  acceptor.h     — multishot accept loop
  engine.h       — thread orchestration (acceptor + N reactors)
  ringzero.h     — umbrella header

src/lib/
  engine.c       — spawn/join acceptor and reactor threads
  acceptor.c     — multishot accept, round-robin fd distribution
  reactor.c      — io_uring event loop (recv/send/cancel)
  connection.c   — write slab management, flush logic
  listener.c     — SO_REUSEADDR/PORT, nonblocking listen socket

src/app/
  main.c         — CLI, signal handling, plaintext HTTP handler
```

## Key io_uring patterns

- **Single syscall loop** — `io_uring_submit_and_wait_timeout` submits + harvests in one kernel entry
- **Zero-copy recv** — provided buffer rings (`io_uring_setup_buf_ring`), kernel writes directly into pre-registered memory
- **Multishot recv** — one SQE arms continuous receive, no re-arming per event
- **Batch CQE processing** — `io_uring_peek_batch_cqe` harvests up to 4096 completions at once
- **User-data packing** — `PACK_UD(kind, fd)` encodes operation type + fd in 64 bits

