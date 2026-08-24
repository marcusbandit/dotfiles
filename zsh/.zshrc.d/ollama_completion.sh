#compdef ollama

_ollama_model_names() {
  local -a models
  local line

  models=()
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == NAME* ]] && continue
    models+=("${line%%[[:space:]][[:space:]]*}")
  done < <(ollama list 2>/dev/null)

  (( ${#models[@]} > 0 )) && compadd -- "${models[@]}"
}

_ollama() {
  local context state line

  typeset -A opt_args

  local -a commands
  commands=(
    'serve:Start ollama'
    'create:Create a model'
    'show:Show information for a model'
    'run:Run a model'
    'stop:Stop a running model'
    'pull:Pull a model from a registry'
    'push:Push a model to a registry'
    'signin:Sign in to ollama.com'
    'signout:Sign out from ollama.com'
    'list:List models'
    'ps:List running models'
    'cp:Copy a model'
    'rm:Remove a model'
    'help:Help about any command'
  )

  if (( CURRENT == 2 )); then
    _describe 'ollama command' commands
    return
  fi

  case "${words[2]}" in
    run|show|stop|pull|push)
      if (( CURRENT == 3 )); then
        _ollama_model_names
        return
      fi
      ;;
    cp)
      if (( CURRENT == 3 )); then
        _ollama_model_names
        return
      fi
      if (( CURRENT == 4 )); then
        _message 'destination model name'
        return
      fi
      ;;
    rm)
      _ollama_model_names
      return
      ;;
  esac

  _default
}

compdef _ollama ollama
