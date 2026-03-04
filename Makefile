CC      = gcc
CFLAGS  = -O2 -Wall -march=native -pthread -Iinclude
LDFLAGS = -luring

SRCDIR  = src
OBJDIR  = obj
SRCS    = main.c engine.c acceptor.c reactor.c connection.c listener.c
OBJS    = $(addprefix $(OBJDIR)/,$(SRCS:.c=.o))
TARGET  = rgzero

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	rm -rf $(OBJDIR) $(TARGET)

.PHONY: all clean
