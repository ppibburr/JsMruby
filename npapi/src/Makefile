TARGET = $(PLUGIN_NAME)
OBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))
CXX = g++
LDSHARED = $(CXX) -shared
MRUBY_PATH = ../../../mruby
LIBMRUBY = $(MRUBY_PATH)/lib/libmruby.a
INC_DIRS = $(INCDIRS) $(MRUBY_PATH)/include ../include ../sdk
CXXFLAGS = $(patsubst %,-I%,$(INC_DIRS))

.PHONY: all clean

all: $(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)

$(TARGET): $(OBJS)
	$(LDSHARED) $(OBJS) $(LIBMRUBY) -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
