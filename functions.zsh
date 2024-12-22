# User defined functions
# ----------------------
function proxy() {
  export ALL_PROXY=socks5://localhost:1080
  export HTTP_PROXY=http://localhost:1087
  export HTTPS_PROXY=http://localhost:1087
}
function noproxy() {
  unset ALL_PROXY
  unset HTTP_PROXY
  unset HTTPS_PROXY
}
# proxy  # default: set proxy!

(( $+commands[dnslookup] )) && \
  function dns() { dnslookup ${1} https://dns.google/dns-query } && \
  function dnscn() { dnslookup ${1} https://dns.alidns.com/dns-query }

# Add a convenient function to use macOS's default DNS resolver that gives consistent results with native macOS apps.
# https://superuser.com/questions/1400250/how-to-query-macos-dns-resolver-from-terminal
(( $+commands[dscacheutil] )) && function osdns() { dscacheutil -q host -a name ${1} }

if (( ${+PRIVATE_IP_QUERY_URL} )); then
  function ipp() {
    curl ${PRIVATE_IP_QUERY_URL}/${1}
  }
fi

if (( ${+IPINFO_API_TOKEN} )); then
  function ipinfo4() {
    curl "https://ipinfo.io/${1}?token=${IPINFO_API_TOKEN}"
  }
  function ipinfo6() {
    curl "https://v6.ipinfo.io/${1}?token=${IPINFO_API_TOKEN}"
  }
  function ipinfo() {
    ipinfo4
    ipinfo6
  }
  function domainip() {
    DNSTOOL=dig
    # (( ! ${+commands[drill]} )) || DNSTOOL=drill
    IP=$($DNSTOOL +short ${1})
    echo ${1} 'resolved to' ${IP}
    IP=$(echo -n $IP | grep -m1 '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
    curl "ipinfo.io/${IP}?token=${IPINFO_API_TOKEN}"
    if (( ${+PRIVATE_IP_QUERY_URL} )); then
      ipp ${IP}
    fi
  }
fi

function ipim() {
  curl https://ip.im/info
}
