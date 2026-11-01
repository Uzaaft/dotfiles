export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Inside nvim's terminal, open man pages in the running nvim.
if [ -n "${NVIM_LISTEN_ADDRESS+x}" ] || [ -n "${NVIM+x}" ]; then
  export MANPAGER="nvr -c 'Man!' -o -"
fi
