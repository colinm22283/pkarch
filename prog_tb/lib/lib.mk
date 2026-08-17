LIB_OBJDIR=$(BUILD_DIR)/lib_obj

LIB_SRCDIR=lib
LIB_INCLUDEDIR=include

_LIB_OBJS+=startup.o
_LIB_OBJS+=print.o

LIB_OBJS=$(foreach o, $(_LIB_OBJS), $(LIB_OBJDIR)/$o)
LIB_HEADERS=$(shell find $(LIB_INCLUDEDIR) -name "*.h" -type f)

$(LIB_OBJDIR)/%.o: $(LIB_SRCDIR)/%.c $(LIB_HEADERS)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $< -o $@

$(LIB_OBJDIR)/%.o: $(LIB_SRCDIR)/%.s
	mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

