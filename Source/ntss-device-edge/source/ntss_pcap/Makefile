#This target is to ensure accidental execution of Makefile as a bash script will not execute commands like rm in unexpected directories and exit gracefully.
.prevent_execution:
	exit 0

CC = gcc -g 

#remove @ for no make command prints
DEBUG = @

APP_DIR = .
APP_INCLUDE_DIRS += -I $(APP_DIR)
APP_NAME = ntss_pcap.exe
APP_SRC_FILES += $(shell find $(APP_DIR)/ -name '*.c')
APP_SRC_FILES += $(shell find ../common/libs/ -name '*.c')
APP_SRC_FILES += ../common/nkklib/nkklib.a
APP_LIB_FILES += -lpcap -lpthread

#Aggregate all include and src directories
INCLUDE_ALL_DIRS += $(APP_INCLUDE_DIRS)

SRC_FILES += $(APP_SRC_FILES)

LD_FLAG += $(APP_LIB_FILES)

# Logging level control
LOG_FLAGS += -DENABLE_IOT_DEBUG
LOG_FLAGS += -DENABLE_IOT_INFO
LOG_FLAGS += -DENABLE_IOT_WARN
LOG_FLAGS += -DENABLE_IOT_ERROR

COMPILER_FLAGS += $(LOG_FLAGS)
#If the processor is big endian uncomment the compiler flag
#COMPILER_FLAGS += -DREVERSED

MAKE_CMD = $(CC) $(SRC_FILES) $(COMPILER_FLAGS) -o $(APP_NAME) $(LD_FLAG) $(EXTERNAL_LIBS) $(INCLUDE_ALL_DIRS)

all:
	$(PRE_MAKE_CMD)
	$(DEBUG)$(MAKE_CMD)
	$(POST_MAKE_CMD)

clean:
	rm -f $(APP_DIR)/$(APP_NAME)
	$(MBED_TLS_MAKE_CMD) clean
