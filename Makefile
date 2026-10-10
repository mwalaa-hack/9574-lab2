DIR = test_files
MALICIOUS_DIR = quarantine
INTERVAL = 5

.PHONY: all antivirus restore

all: antivirus

pre-build:
	mkdir -p $(MALICIOUS_DIR)

antivirus: pre-build
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

restore: pre-build
	./restore.sh $(DIR) $(MALICIOUS_DIR)
