# ==========================================
# C++ VARIABLES BUILD CONFIGURABLES
# ==========================================
CXX      := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Werror -O2
BUILD_DIR := build
TARGET   := $(BUILD_DIR)/naruto

# ==========================================
# DIRECTORIOS & AUTODETECCION
# ==========================================

SRCS     := $(wildcard *.cpp)

OBJS     := $(SRCS:%.cpp=$(BUILD_DIR)/%.o)

# ==========================================
# REGLAS DEL BUILD
# ==========================================

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ==========================================
# UTILITY TARGETS
# ==========================================

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
