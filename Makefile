CC      = gcc
CFLAGS  = -O2 -Wall -march=native -pthread -Iinclude
LDFLAGS = -luring

# ---------- sources ----------
LIB_SRCS = engine.c acceptor.c reactor.c connection.c listener.c
APP_SRCS = main.c

LIB_OBJS     = $(addprefix obj/lib/,$(LIB_SRCS:.c=.o))
LIB_PIC_OBJS = $(addprefix obj/lib-pic/,$(LIB_SRCS:.c=.o))
APP_OBJS     = $(addprefix obj/app/,$(APP_SRCS:.c=.o))

# ---------- targets ----------
all: libringzero.a libringzero.so rgzero

libringzero.a: $(LIB_OBJS)
	ar rcs $@ $^

libringzero.so: $(LIB_PIC_OBJS)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

rgzero: $(APP_OBJS) libringzero.a
	$(CC) $(CFLAGS) -o $@ $(APP_OBJS) -L. -lringzero $(LDFLAGS)

# ---------- compile rules ----------
obj/lib/%.o: src/lib/%.c | obj/lib
	$(CC) $(CFLAGS) -c $< -o $@

obj/lib-pic/%.o: src/lib/%.c | obj/lib-pic
	$(CC) $(CFLAGS) -fPIC -c $< -o $@

obj/app/%.o: src/app/%.c | obj/app
	$(CC) $(CFLAGS) -c $< -o $@

obj/lib:
	mkdir -p $@

obj/lib-pic:
	mkdir -p $@

obj/app:
	mkdir -p $@

clean:
	rm -rf obj libringzero.a libringzero.so rgzero

.PHONY: all clean
