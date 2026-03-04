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

## Running

```bash
./rgzero [reactor_count]    # default: 12 reactors
```

Stop with `Ctrl+C` or `SIGTERM`.

## Project Structure

```
include/    constants.h, queue.h, listener.h, connection.h, reactor.h, acceptor.h, engine.h
src/        main.c, engine.c, acceptor.c, reactor.c, connection.c, listener.c
obj/        build artifacts (gitignored)
```

## Performance

~3.5M req/s on localhost (4 reactors, 100 connections, wrk) vs zerg ~3.3M req/s with the same architecture.
