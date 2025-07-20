DATA_DIR := data
SINGBOX_DIR := sing-box
SINGBOX_SRS_DIR := $(SINGBOX_DIR)/binary
SINGBOX_SOURCE_DIR := $(SINGBOX_DIR)/source
IPSET_DIR := ipset
SMARTDNS_DIR := smartdns

# Usage cat ips | GEOIP_CMD > output
GEOIP_CMD := $(if $(wildcard $(HOME)/go/bin/geoip), $(HOME)/go/bin/geoip, geoip) merge
# Usage SINGBOX_CMD <output> <input>
SINGBOX_CMD := sing-box rule-set compile --output
# Usage IP_TO_SINGBOX_SOURCE <input> <output>
IP_TO_SINGBOX_SOURCE := ./bin/iptext_to_singbox_source.py

IP_TYPES := cn_ip hk_ip
define IP_URLS_MAP
cn_ip_urls := \
    https://raw.githubusercontent.com/metowolf/iplist/master/data/country/CN.txt \
    https://github.com/17mon/china_ip_list/raw/refs/heads/master/china_ip_list.txt \
    https://github.com/Loyalsoldier/geoip/raw/refs/heads/release/text/cn.txt \
    https://github.com/misakaio/chnroutes2/raw/refs/heads/master/chnroutes.txt
hk_ip_urls := \
    https://raw.githubusercontent.com/metowolf/iplist/master/data/country/HK.txt \
    https://github.com/Loyalsoldier/geoip/raw/refs/heads/release/text/hk.txt
endef

$(eval $(IP_URLS_MAP))

SINGBOX_SRS_TARGETS := $(patsubst %, $(SINGBOX_SRS_DIR)/%.srs, $(IP_TYPES))
SINGBOX_SOURCE_TARGETS := $(patsubst %, $(SINGBOX_SOURCE_DIR)/%.json, $(IP_TYPES))
IPSET_TARGETS := $(patsubst %, $(IPSET_DIR)/%.txt, $(IP_TYPES))

all: $(SINGBOX_SRS_TARGETS) $(SINGBOX_SOURCE_TARGETS) $(IPSET_TARGETS)

.PHONY: FORCE

$(DATA_DIR)/%: FORCE
	@echo "--- Downloading and merging raw IP list for $(notdir $@) ---"
	@mkdir -p $(@D)

	@IP_URLS="$($(notdir $@)_urls)"; \
	TMP_FILE=$$(mktemp); \
	for url in $${IP_URLS[@]}; do \
	    echo "Fetching $$url"; \
		curl -sL "$$url" | grep -vE '^[[:space:]]*#|:' >> $$TMP_FILE ;\
	done; \
	cat $$TMP_FILE | $(GEOIP_CMD) > $@; \
	rm $$TMP_FILE;


$(SINGBOX_SRS_DIR)/%.srs: $(SINGBOX_SOURCE_DIR)/%.json
	@echo "--- Creating $(notdir $@) ---"
	@mkdir -p $(@D)
	$(SINGBOX_CMD) $@ $<

$(SINGBOX_SOURCE_DIR)/%.json: $(DATA_DIR)/%
	@echo "--- Creating $(notdir $@) ---"
	@mkdir -p $(@D)
	$(IP_TO_SINGBOX_SOURCE) $< $@

$(IPSET_DIR)/%.txt: $(DATA_DIR)/%
	@echo "--- [ipset] Creating $(notdir $@) ---"
	@mkdir -p $(@D)
	cp $< $@


clean:
	@rm -rf $(DATA_DIR)
